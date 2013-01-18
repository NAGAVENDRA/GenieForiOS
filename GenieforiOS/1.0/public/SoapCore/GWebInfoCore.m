//
//  GWebInfoCore.m
//  GenieiPad
//
//  Created by cs Siteview on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GWebInfoCore.h"


@implementation GWebInfoCore

- (id) initWithUrlStr:(NSString*)url timeout:(NSTimeInterval)timeout connectionCount:(NSInteger)count
{
    self = [super init];
    if (self)
    {
        m_result = [[NSMutableDictionary alloc] init];
        m_target = nil;
        m_selector = nil;
        m_finished = NO;
        m_succeeded = NO;
        m_aborted = NO;
        m_responseCode = -1;
        NSURLRequest * req = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout] autorelease];
        m_impl = [[GWebInfoCoreImpl alloc] initWithReq:req count:count];
        [m_impl setFinishCallback:self selector:@selector(asyncFinishedCallback)];
    }
    return self;
}

- (void) asyncFinishedCallback
{
    return;
}

- (void) dealloc
{
    [m_impl release];
    [m_result release];
    [m_target release];
    [super dealloc];
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
    [m_impl abort];
    [self notifyFinished];
}

- (NSDictionary*)result
{
    return m_result;
}

- (int)responseCode
{
    return m_responseCode;
}

- (NSString*)stringForKey:(NSString*)key
{
    return [m_result objectForKey:key];
}

- (BOOL)containsKey:(NSString*)key
{
    return [[m_result allKeys] containsObject:key];
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
@end


@implementation GWebInfoGCSetting
const int GCSettingMaxConnectionCount = 4;
const NSTimeInterval GCSettingTimeout = 20.0f;
static NSString * GCSettingUrlStr = @"http://routerlogin.net/currentsetting.htm";
- (id) init
{
    return  [super initWithUrlStr:GCSettingUrlStr timeout:GCSettingTimeout connectionCount:GCSettingMaxConnectionCount];
}

- (void) asyncFinishedCallback
{
    if (m_aborted)
    {
        return;
    }
    if ([m_impl succeeded])
    {
        NSString * str = [[NSString alloc] initWithData:[m_impl data] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        if (![str length])
        {
            m_succeeded = NO;
        }
        else
        {
            NSArray * arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\r\n"]];
            for (NSString * s in arr)
            {
                if (![s length])
                {
                    continue;
                }
                NSArray * a = [s componentsSeparatedByString:@"="];
                if ([a count] == 2)
                {
                    //将所有的字段名称都强制转换为小写，以实现对返回字段名的大小写不敏感处理    外部操作统一使用小写
                    [m_result setObject:[a objectAtIndex:1] forKey:[(NSString*)[a objectAtIndex:0] lowercaseString]];
                }
            }
            [m_result setObject:str forKey:[@"GCSettingHTTPString" lowercaseString]];
            m_succeeded = YES;
        }
        [str release];
    }
    else
    {
        m_succeeded = NO;
    }
    [self notifyFinished];
}

@end