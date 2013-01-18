//
//  LPCImpl1.m
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LPCImpl1.h"

@implementation DCBaseOp

- (id)initWithCore:(DCWebApi *)core command:(NSString *)command names:(NSArray *)names values:(NSArray *)values
{
	self = [super init];
	if (self) {
		m_result = [[NSMutableDictionary alloc] init];
		m_op = [core invoke:command names:names values:values];
		[m_op retain];
		[m_op setFinishCallback:self selector:@selector(opFinished1:)];
		m_aborted = NO;
		m_finished = NO;
		m_succeeded = NO;
		m_target = nil;
		m_responseCode = -1;
		m_core = [core retain];
	}
	return self;
}

- (void)dealloc
{
	[m_core release];
	[m_target release];
	[m_op release];
	[m_result release];
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
	if (m_finished) {
		return NO;
	}
	[target retain];
	[m_target release];
	m_target = target;
	m_selector = selector;
	return YES;
}

- (void)abort
{
	if (!m_finished) {
		m_aborted = YES;
		[m_op abort];
		[m_op release];
		m_op = nil;
		[self notifyFinished];
	}
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
	return (NSString*)[m_result objectForKey:key];
}

- (BOOL)containsKey:(NSString*)key
{
	return [[m_result allKeys] containsObject:key];
}

- (void)notifyFinished
{
	m_finished = YES;
	if (m_target) {
		if (!m_aborted) {
			[m_target performSelector:m_selector withObject:self];
		}
		[m_target release];
		m_target = nil;
	}
}

- (void)opFinished1:(GTAsyncOp*)op
{
	if (m_aborted) {
		return;
	}

	[m_op release];
	m_op = nil;

	if ([op succeeded]) {
		m_succeeded = YES;
		/*if ([op responseCode] != 0) {
			NSString *err = [op stringForKey:@"error"];
			if (err) {
				[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			}
		}*/
		m_responseCode = [self processResult:op];
	} else {
		m_succeeded = NO;
	}
	[self notifyFinished];
}

- (void)setResult:(NSObject*)value forKey:(NSString*)key
{
	[m_result setObject:value forKey:key];
}

- (int)processResult:(GTAsyncOp*)op
{
	return WTFStatus_UnexpectedError;
}

@end

@implementation DCCheckNameAvailableOp

- (id)initWithCore:(DCWebApi *)core username:(NSString *)username
{
	self = [super initWithCore:core command:@"check_username" names:[NSArray arrayWithObject:@"username"] values:[NSArray arrayWithObject:username]];
	return self;
}

- (int)processResult:(GTAsyncOp*)op
{
	if ([op responseCode] == 0) {
		NSString *avail = [op stringForKey:@"response.available"];
		if (avail == nil) {
			return WTFStatus_UnexpectedError;
		}
		if (NSOrderedSame == [avail compare:@"yes" options:NSCaseInsensitiveSearch]) {
			[self setResult:[NSNumber numberWithBool:YES] forKey:@"varAvailable"];
		} else {
			[self setResult:[NSNumber numberWithBool:NO] forKey:@"varAvailable"];
		}
	} else {
		return WTFStatus_UnexpectedError;
	}
	return WTFStatus_NoError;
}

@end

@implementation DCCreateAccountOp

- (id)initWithCore:(DCWebApi *)core username:(NSString *)username password:(NSString *)password email:(NSString *)email
{
	self = [super initWithCore:core command:@"account_create" names:[NSArray arrayWithObjects:@"username", @"password", @"email", nil] values:[NSArray arrayWithObjects:username, password, email, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp*)op
{
	if ([op responseCode] == 0) {
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCLoginOp

- (id)initWithCore:(DCWebApi *)core username:(NSString *)username password:(NSString *)password
{
	self = [super initWithCore:core command:@"account_signin" names:[NSArray arrayWithObjects:@"username", @"password", nil] values:[NSArray arrayWithObjects:username, password, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSString *token = [op stringForKey:@"response.token"];
		if (token == nil) {
			return WTFStatus_UnexpectedError;
		}
		[self setResult:token forKey:@"varToken"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			switch ([op responseCode]) {
				case 1004:
					return WTFStatus_AuthenticationFailed;
				default:
					return WTFStatus_Failed;
			}
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCGetLabelOp

- (id)initWithCore:(DCWebApi *)core token:(NSString *)token deviceId:(NSString *)deviceId
{
	self = [super initWithCore:core command:@"label_get" names:[NSArray arrayWithObjects:@"token", @"device_id", nil] values:[NSArray arrayWithObjects:token, deviceId, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCGetDeviceOp

- (id)initWithCore:(DCWebApi *)core token:(NSString *)token deviceKey:(NSString *)deviceKey
{
	self = [super initWithCore:core command:@"device_get" names:[NSArray arrayWithObjects:@"token", @"device_key", nil] values:[NSArray arrayWithObjects:token, deviceKey, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSString *deviceId = [op stringForKey:@"response.device_id"];
		if (deviceId == nil) {
			return WTFStatus_UnexpectedError;
		}
		[self setResult:deviceId forKey:@"varDeviceID"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCCreateDeviceOp

- (id)initWithCore:(DCWebApi *)core token:(NSString *)token deviceKey:(NSString *)deviceKey
{
	self = [super initWithCore:core command:@"device_create" names:[NSArray arrayWithObjects:@"token", @"device_id", nil] values:[NSArray arrayWithObjects:token, deviceKey, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp*)op
{
	if ([op responseCode] == 0) {
		NSString *deviceId = [op stringForKey:@"response.device_id"];
		if (deviceId == nil) {
			return WTFStatus_UnexpectedError;
		}
		[self setResult:deviceId forKey:@"varDeviceID"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCGetFiltersOp

- (id)initWithCore:(DCWebApi *)core token:(NSString *)token deviceId:(NSString *)deviceId
{
	self = [super initWithCore:core command:@"filters_get" names:[NSArray arrayWithObjects:@"token", @"device_id", nil] values:[NSArray arrayWithObjects:token, deviceId, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSString *bundle = [op stringForKey:@"response.bundle"];
		if (bundle != nil) {
			[self setResult:bundle forKey:@"varBundle"];
		} else {
			[self setResult:@"custom" forKey:@"varBundle"];
		}
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			switch ([op responseCode]) {
				case 4001:
					return WebApiStatus_DeviceIdNotMine;
				default:
					return WTFStatus_Failed;
			}
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCSetFiltersOp

- (id)initWithCore:(DCWebApi *)core token:(NSString *)token deviceId:(NSString *)deviceId bundle:(NSString *)bundle
{
	self = [super initWithCore:core command:@"filters_set" names:[NSArray arrayWithObjects:@"token", @"device_id", @"bundle", nil] values:[NSArray arrayWithObjects:token, deviceId, bundle, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCAccountRelayOp

- (id)initWithCore:(DCWebApi *)core token:(NSString *)token
{
	self = [super initWithCore:core command:@"account_relay" names:[NSArray arrayWithObject:@"token"] values:[NSArray arrayWithObject:token]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSString *relayToken = [op stringForKey:@"response.relay_token"];
		if (relayToken == nil) {
			return WTFStatus_UnexpectedError;
		}

		[self setResult:relayToken forKey:@"varRelayToken"];
		[self setResult:[m_core apiKey] forKey:@"varApiKey"];
		[self setResult:@"http://netgear.opendns.com/sign_in.php" forKey:@"varBaseUrl"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCGetUsersForDeviceIdOp

- (id)initWithCore:(DCWebApi *)core deviceId:(NSString *)deviceId
{
	self = [super initWithCore:core command:@"device_children_get" names:[NSArray arrayWithObject:@"parent_device_id"] values:[NSArray arrayWithObject:deviceId]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSArray *arr = [[op result] objectForKey:@"response"];
		if (arr == nil) {
			return WTFStatus_UnexpectedError;
		}
		[self setResult:arr forKey:@"varList"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCGetDeviceChildOp

- (id)initWithCore:(DCWebApi *)core parentDeviceId:(NSString *)parentDeviceId username:(NSString *)username password:(NSString *)password
{
	self = [super initWithCore:core command:@"device_child_get" names:[NSArray arrayWithObjects:@"parent_device_id", @"device_username", @"device_password", nil] values:[NSArray arrayWithObjects:parentDeviceId, username, password, nil]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSString *resp = [op stringForKey:@"response"];
		if (resp == nil) {
			return WTFStatus_UnexpectedError;
		}
		[self setResult:resp forKey:@"varChildDeviceId"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			switch ([op responseCode]) {
				case 3003:
					return WTFStatus_AuthenticationFailed;
				default:
					return WTFStatus_Failed;
			}
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end

@implementation DCGetUserForChildDeviceId

- (id)initWithCore:(DCWebApi *)core childDeviceId:(NSString *)childDeviceId
{
	self = [super initWithCore:core command:@"device_child_username_get" names:[NSArray arrayWithObject:@"device_id"] values:[NSArray arrayWithObject:childDeviceId]];
	return self;
}

- (int)processResult:(GTAsyncOp *)op
{
	if ([op responseCode] == 0) {
		NSString *resp = [op stringForKey:@"response"];
		if (resp == nil) {
			return WTFStatus_UnexpectedError;
		}
		[self setResult:resp forKey:@"varUserName"];
	} else {
		if ([op containsKey:@"error"]) {
			[self setResult:[NSNumber numberWithInt:[op responseCode]] forKey:@"varErrorCode"];
			return WTFStatus_Failed;
		} else {
			return WTFStatus_UnexpectedError;
		}
	}
	return WTFStatus_NoError;
}

@end
