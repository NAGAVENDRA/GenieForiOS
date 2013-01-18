//
//  GTSoapCore.h
//  MobDemo
//
//  Created by yiyang on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAsyncOp.h"

enum GTStatus
{
	GTStatus_Ok = 0,
	GTStatus_SmartNetworkAuthFailed = -1000,
	GTStatus_RouterAuthFailed = -1001,
	GTStatus_UnknownError = -1,
};

@class GTSoapCoreImpl;

@interface GTSoapCore : NSObject
{
	@private
	GTSoapCoreImpl *m_impl;
}

- (id)initWithSessionID:(NSString*)sessionID;
- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action;
- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action name:(NSString*)name value:(NSString*)value;
- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (void)setWrapMode:(BOOL)wrap;
- (BOOL)wrapMode;
- (GTAsyncOp*)listActiveRouters;
- (void)setSmartNetworkUsername:(NSString*)username password:(NSString*)password;
- (void)setRouterUsername:(NSString*)username password:(NSString*)password;
- (void)setControlPointID:(NSString*)cpid;
- (BOOL)isSmartNetwork;
- (void)logoutSmartNetwork;
- (void)setSmartNetworkBaseUrl:(NSString*)url;
- (GTAsyncOp*)closeSession;
- (void)setLocalUrl:(NSString*)url path:(NSString*)path;


@end
