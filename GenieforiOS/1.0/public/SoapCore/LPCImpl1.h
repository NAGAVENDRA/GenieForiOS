//
//  LPCImpl1.h
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPCCore.h"

@interface DCBaseOp : GTAsyncOp
{
	GTAsyncOp *m_op;
	NSMutableDictionary *m_result;
	id m_target;
	SEL m_selector;
	BOOL m_finished;
	BOOL m_aborted;
	BOOL m_succeeded;
	int m_responseCode;
	DCWebApi *m_core;
}

- (id)initWithCore: (DCWebApi*)core command:(NSString*)command names:(NSArray*)names values:(NSArray*)values;
- (void)notifyFinished;
- (BOOL)aborted;
- (BOOL)finished;
- (BOOL)succeeded;
- (BOOL)setFinishCallback:(id)target selector:(SEL)selector;
- (void)abort;
- (NSDictionary*)result;
- (int)responseCode;
- (NSString*)stringForKey:(NSString*)key;
- (BOOL)containsKey:(NSString*)key;
- (void)setResult:(NSObject*)value forKey:(NSString*)key;
- (int)processResult:(GTAsyncOp*)op;

@end

@interface DCCheckNameAvailableOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core username:(NSString*)username;

@end

@interface DCCreateAccountOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core username:(NSString*)username password:(NSString*)password email:(NSString*)email;

@end

@interface DCLoginOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core username:(NSString*)username password:(NSString*)password;

@end

@interface DCGetLabelOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core token:(NSString*)token deviceId:(NSString*)deviceId;

@end

@interface DCGetDeviceOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core token:(NSString*)token deviceKey:(NSString*)deviceKey;

@end

@interface DCCreateDeviceOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core token:(NSString*)token deviceKey:(NSString*)deviceKey;

@end

@interface DCGetFiltersOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core token:(NSString*)token deviceId:(NSString*)deviceId;

@end

@interface DCSetFiltersOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core token:(NSString*)token deviceId:(NSString*)deviceId bundle:(NSString*)bundle;

@end

@interface DCAccountRelayOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core token:(NSString*)token;

@end

@interface DCGetUsersForDeviceIdOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core deviceId:(NSString*)deviceId;

@end

@interface DCGetDeviceChildOp : DCBaseOp

- (id)initWithCore:(DCWebApi*)core parentDeviceId:(NSString*)parentDeviceId username:(NSString*)username password:(NSString*)password;

@end

@interface DCGetUserForChildDeviceId : DCBaseOp

- (id)initWithCore:(DCWebApi*)core childDeviceId:(NSString*)childDeviceId;

@end




