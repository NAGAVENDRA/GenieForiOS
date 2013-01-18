//
//  GWebInfoCoreImpl.h
//  GenieiPad
//
//  Created by cs Siteview on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPWaitDialog.h"


@class GWebInfoCoreConnection;
@interface GWebInfoCoreImpl : NSObject {
    NSMutableArray                              * m_connArr;
    NSURLRequest                                * m_req;
	NSMutableData                               * m_data;
    NSInteger                                   m_connectionCount;
	id                                          m_target;
	SEL                                         m_selector;
	BOOL                                        m_finished;
	BOOL                                        m_aborted;
	BOOL                                        m_succeeded;
	int                                         m_responseCode;
}
- (id) initWithReq:(NSURLRequest*) req count:(NSInteger) count;
- (void) start;
- (void) connectionFinishedCallback:(GWebInfoCoreConnection*)conn;

- (void)notifyFinished;
- (BOOL)aborted;
- (BOOL)finished;
- (BOOL)succeeded;
- (BOOL)setFinishCallback:(id)target selector:(SEL)selector;
- (void)abort;
- (int)responseCode;
- (NSMutableData*) data;
@end

@interface GWebInfoCoreConnection : NSObject {
    NSURLConnection                             * m_conn;
	NSMutableData                               * m_data;
	id                                          m_target;
	SEL                                         m_selector;
	BOOL                                        m_finished;
	BOOL                                        m_aborted;
	BOOL                                        m_succeeded;
}
- (id) initWithReq:(NSURLRequest*) req;

- (void)notifyFinished;
- (BOOL)aborted;
- (BOOL)finished;
- (BOOL)succeeded;
- (BOOL)setFinishCallback:(id)target selector:(SEL)selector;
- (void)abort;
- (NSMutableData*) data;
@end