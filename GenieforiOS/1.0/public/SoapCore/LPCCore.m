//
//  LPCCore.m
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LPCCore.h"
#import "LPCImpl1.h"

@implementation DCWebApi

- (GTAsyncOp*)checkNameAvailable:(NSString*)username
{
	return [[[DCCheckNameAvailableOp alloc] initWithCore:self username:username] autorelease];
}

- (GTAsyncOp*)createAccount:(NSString*)username password:(NSString*)password email:(NSString*)email
{
	return [[[DCCreateAccountOp alloc] initWithCore:self username:username password:password email:email] autorelease];
}

- (GTAsyncOp*)login:(NSString*)username password:(NSString*)password
{
	return [[[DCLoginOp alloc] initWithCore:self username:username password:password] autorelease];
}

- (GTAsyncOp*)getLabel:(NSString*)token deviceId:(NSString*)deviceId
{
	return [[[DCGetLabelOp alloc] initWithCore:self token:token deviceId:deviceId] autorelease];
}

- (GTAsyncOp*)getDevice:(NSString*)token deviceKey:(NSString*)deviceKey
{
	return [[[DCGetDeviceOp alloc] initWithCore:self token:token deviceKey:deviceKey] autorelease];
}

- (GTAsyncOp*)createDevice:(NSString*)token deviceKey:(NSString*)deviceKey
{
	return [[[DCCreateDeviceOp alloc] initWithCore:self token:token deviceKey:deviceKey] autorelease];
}
- (GTAsyncOp*)getFilters:(NSString*)token deviceId:(NSString*)deviceId
{
	return [[[DCGetFiltersOp alloc] initWithCore:self token:token deviceId:deviceId] autorelease];
}

- (GTAsyncOp*)setFilters:(NSString*)token deviceId:(NSString*)deviceId bundle:(NSString*)bundle
{
	return [[[DCSetFiltersOp alloc] initWithCore:self token:token deviceId:deviceId bundle:bundle] autorelease];
}

- (GTAsyncOp*)accountRelay:(NSString*)token
{
	return [[[DCAccountRelayOp alloc] initWithCore:self token:token] autorelease];
}

- (GTAsyncOp*)getUsersForDeviceId:(NSString*)deviceId
{
	return [[[DCGetUsersForDeviceIdOp alloc] initWithCore:self deviceId:deviceId] autorelease];
}

- (GTAsyncOp*)getDeviceChild:(NSString*)parentDeviceId username:(NSString*)username password:(NSString*)password
{
	return [[[DCGetDeviceChildOp alloc] initWithCore:self parentDeviceId:parentDeviceId username:username password:password] autorelease];
}

- (GTAsyncOp*)getUserForChildDeviceId:(NSString*)childDeviceId
{
	return [[[DCGetUserForChildDeviceId alloc] initWithCore:self childDeviceId:childDeviceId] autorelease];
}

@end
