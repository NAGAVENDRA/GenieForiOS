//
//  LPCCore.h
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTOpenDnsCore.h"

enum WTFStatus
{
	WTFStatus_NoError,
	WTFStatus_Aborted,
	WTFStatus_Timeout,
	WTFStatus_UnexpectedError,
	WTFStatus_UnknownError,
	WTFStatus_Failed,
	WTFStatus_NetworkError,
	WTFStatus_AuthenticationFailed,
	WTFStatus_SocketConnectFaild,
	WTFStatus_SocketWriteFailed,
	WTFStatus_SocketReadFailed,

	WebApiStatus_DeviceKeyError = 400,
	WebApiStatus_DeviceIdNotMine,
	WebApiStatus_RouterAuthenticationFailed,

	RouterStatus_NoNetwork = 600,
	RouterStatus_NoRouter,
	RouterStatus_ParentalControlNotEnabled,
	RouterStatus_NoDefaultDeviceId,
};

@interface DCWebApi : GTOpenDnsCore
{
}

- (GTAsyncOp*)checkNameAvailable:(NSString*)username;
- (GTAsyncOp*)createAccount:(NSString*)username password:(NSString*)password email:(NSString*)email;
- (GTAsyncOp*)login:(NSString*)username password:(NSString*)password;
- (GTAsyncOp*)getLabel:(NSString*)token deviceId:(NSString*)deviceId;
- (GTAsyncOp*)getDevice:(NSString*)token deviceKey:(NSString*)deviceKey;
- (GTAsyncOp*)createDevice:(NSString*)token deviceKey:(NSString*)deviceKey;
- (GTAsyncOp*)getFilters:(NSString*)token deviceId:(NSString*)deviceId;
- (GTAsyncOp*)setFilters:(NSString*)token deviceId:(NSString*)deviceId bundle:(NSString*)bundle;
- (GTAsyncOp*)accountRelay:(NSString*)token;
- (GTAsyncOp*)getUsersForDeviceId:(NSString*)deviceId;
- (GTAsyncOp*)getDeviceChild:(NSString*)parentDeviceId username:(NSString*)username password:(NSString*)password;
- (GTAsyncOp*)getUserForChildDeviceId:(NSString*)childDeviceId;

@end
