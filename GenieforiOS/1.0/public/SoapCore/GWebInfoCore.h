//
//  GWebInfoCore.h
//  GenieiPad
//
//  Created by cs Siteview on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWebInfoCoreImpl.h"
#import "GTAsyncOp.h"

@interface GWebInfoCore: GTAsyncOp {
    GWebInfoCoreImpl                            * m_impl;
	NSMutableDictionary                         * m_result;
	id                                          m_target;
	SEL                                         m_selector;
	BOOL                                        m_finished;
	BOOL                                        m_aborted;
	BOOL                                        m_succeeded;
	int                                         m_responseCode;
}
- (id) initWithUrlStr:(NSString*)url timeout:(NSTimeInterval)timeout connectionCount:(NSInteger)count;

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
@end

@interface GWebInfoGCSetting : GWebInfoCore {
}
- (id) init;
@end

@interface GWebInfoLPCReachAbilityHost : GWebInfoCore {
}
- (id) init;
@end