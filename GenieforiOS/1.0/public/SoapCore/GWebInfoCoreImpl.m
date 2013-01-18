//
//  GWebInfoCoreImpl.m
//  GenieiPad
//
//  Created by cs Siteview on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GWebInfoCoreImpl.h"

@implementation GWebInfoCoreImpl
- (id) initWithReq:(NSURLRequest *)req count:(NSInteger)count
{
    self = [super init];
    if (self)
    {
        m_connArr = [[NSMutableArray alloc] init];
        m_req = [req retain];
        m_data = [[NSMutableData alloc] init];
        m_connectionCount = count;
        m_target = nil;
        m_selector = nil;
        m_finished = NO;
        m_succeeded = NO;
        m_aborted = NO;
        m_responseCode = -1;
        [self start];
    }
    return self;
}

- (void) start 
{
    for (NSInteger i = 0; i < m_connectionCount; i++)
    {
        NSLog(@"----------------------start Connection index:%d---------------------",i);
        GWebInfoCoreConnection * conn = [[GWebInfoCoreConnection alloc] initWithReq:m_req]; 
        [conn setFinishCallback:self selector:@selector(connectionFinishedCallback:)];
        [m_connArr addObject:conn];
        [conn release];
    }
}

- (void) removeAllConnections
{
    for (NSInteger i= 0; i < [m_connArr count]; i++ )
    {
        GWebInfoCoreConnection * conn = [m_connArr objectAtIndex:i];
        [conn abort];//此时可能是aborted 也可能是successed. conn 依然会回调到这一层，所以回调函数要加上两层判断
    }
    [m_connArr removeAllObjects];
}
- (void) connectionFinishedCallback:(GWebInfoCoreConnection*)conn
{
    if (m_aborted || m_succeeded)
    {
        return;
    }
    NSLog(@"----------------------connection index :%d callback---------------------",[m_connArr indexOfObject:conn]);
    if ([conn succeeded])
    {
        m_succeeded = YES;
        [m_data setData:[conn data]];
        [self removeAllConnections];
        [self notifyFinished];
        return;
    }
    else
    {
        [m_connArr removeObject:conn];
        if (![m_connArr count])
        {
            m_succeeded = NO;
            [self notifyFinished];
        }
    }
}

- (void) dealloc
{
    [m_connArr release];
    [m_req release];
    [m_data release];
    [m_target release];
    [super dealloc];
}

- (NSMutableData*) data
{
    return m_data;
}
- (BOOL)aborted
{
	return m_aborted;
}

- (BOOL)finished
{
	return m_finished;
}

- (BOOL)succeeded
{
	return m_succeeded;
}

- (BOOL)setFinishCallback:(id)target selector:(SEL)selector
{
	if (m_finished)
    {
        return NO;
    }
    [m_target release];
    m_target = [target retain];
    m_selector = selector;
    return YES;
}

- (void)abort
{
    if (m_finished)
    {
        return;
    }
    m_aborted = YES;
    [self removeAllConnections];
    [self notifyFinished];
}

- (int)responseCode
{
    return m_responseCode;
}

- (void) notifyFinished
{
    NSLog(@"----------------------Finish all connections---------------------");
    if (m_finished)
    {
        return;
    }
    m_finished = YES;
    if (m_target)
    {
        if (!m_aborted)
        {
            [m_target performSelector:m_selector withObject:self];
        }
        [m_target release];
        m_target = nil;
    }
}

@end


@implementation GWebInfoCoreConnection
- (id) initWithReq:(NSURLRequest *)req
{
    self = [super init];
    if (self)
    {
        m_data = [[NSMutableData alloc] init];
        m_target = nil;
        m_selector = nil;
        m_finished = NO;
        m_succeeded = NO;
        m_aborted = NO;
        m_conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    }
    return self;
}

- (void) connectionFinishedCallback:(NSURLConnection*)conn
{
    if (m_aborted)
    {
        return;
    }
    [self notifyFinished];
}

- (void) dealloc
{
    [m_conn release];
    [m_data release];
    [m_target release];
    [super dealloc];
}

- (NSMutableData*) data
{
    return m_data;
}
- (BOOL)aborted
{
	return m_aborted;
}

- (BOOL)finished
{
	return m_finished;
}

- (BOOL)succeeded
{
	return m_succeeded;
}

- (BOOL)setFinishCallback:(id)target selector:(SEL)selector
{
	if (m_finished)
    {
        return NO;
    }
    [m_target release];
    m_target = [target retain];
    m_selector = selector;
    return YES;
}

- (void)abort
{
    if (m_finished)
    {
        return;
    }
    m_aborted = YES;
    [m_conn cancel];
    [m_conn release];
    m_conn = nil;
    [self notifyFinished];
}


- (void) notifyFinished
{
    if (m_finished)
    {
        return;
    }
    m_finished = YES;
    if (m_target)
    {
        if (!m_aborted)
        {
            [m_target performSelector:m_selector withObject:self];
        }
        [m_target release];
        m_target = nil;
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [m_data appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    m_succeeded = YES;
    [self connectionFinishedCallback:connection];
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"HTTP Connection Error:%@",[error localizedDescription]);
    m_succeeded = NO;
    [self connectionFinishedCallback:connection];
}
@end
