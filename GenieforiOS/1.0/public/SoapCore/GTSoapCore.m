//
//  GTSoapCore.m
//  MobDemo
//
//  Created by yiyang on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTSoapCoreImpl.h"

@implementation GTSoapCore

- (id)init
{
	return [self initWithSessionID:nil];
}

- (id)initWithSessionID:(NSString *)sessionID
{
	self = [super init];
	if (self) {
		m_impl = [[GTSoapCoreImpl alloc] initWithSessionID:sessionID];
	}
	return self;
}

- (void)dealloc
{
	[m_impl release];
	[super dealloc];
}

- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action
{
	return [m_impl invoke:service action:action names:nil values:nil];
}

- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action name:(NSString*)name value:(NSString*)value
{
	return [m_impl invoke:service action:action names:[NSArray arrayWithObject:name] values:[NSArray arrayWithObject:value]];
}

- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values
{
	return [m_impl invoke:service action:action names:names values:values];
}

- (void)setWrapMode:(BOOL)wrap
{
	[m_impl setWrapMode:wrap];
}

- (BOOL)wrapMode
{
	return [m_impl wrapMode];
}

- (GTAsyncOp*)listActiveRouters
{
	return [m_impl listActiveRouters];
}

- (void)setSmartNetworkUsername:(NSString*)username password:(NSString*)password
{
	return [m_impl setSmartNetworkUsername:username password:password];
}

- (void)setRouterUsername:(NSString*)username password:(NSString*)password
{
	return [m_impl setRouterUsername:username password:password];
}

- (void)setControlPointID:(NSString*)cpid
{
	return [m_impl setControlPointID:cpid];
}

- (BOOL)isSmartNetwork
{
    return [m_impl isSmartNetwork];
}

- (void)logoutSmartNetwork
{
    [m_impl logoutSmartNetwork];
}

- (void)setSmartNetworkBaseUrl:(NSString*)url
{
    [m_impl setSmartNetworkBaseUrl:url];
}

- (GTAsyncOp*)closeSession
{
    return [m_impl closeSession];
}

- (void)setLocalUrl:(NSString*)url path:(NSString*)path
{
    [m_impl setLocalUrl:url path:path];
}

@end
