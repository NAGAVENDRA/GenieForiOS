//
//  FXSoapCore.h
//  MobDemo
//
//  Created by yiyang on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FXSoap;

@interface FXSoapCore : NSObject {
    NSMutableString *m_sessionId;
	NSMutableArray *m_portList;
	int m_activePort;
}

- (id)init;
- (id)initWithSessionId:(NSString*)sessionId;
- (void)setSessionId:(NSString*)sessionId;
- (FXSoap*)invoke:(NSString*)service action:(NSString*)action;
- (FXSoap*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;

@end

@interface FXSoap : NSObject {
	NSURLConnection *m_conn;
	BOOL m_aborted;
	BOOL m_finished;
	BOOL m_errorFlag;
	NSMutableData *m_data;
	id m_target;
	SEL m_selector;
	NSMutableString *m_action;
	NSMutableDictionary *m_allValues;
	int m_responseCode;
	NSMutableURLRequest *m_req;
	NSMutableArray *m_fallbackPorts;
	FXSoapCore *m_soapCore;
	int m_activePort;
}

- (BOOL)aborted;
- (BOOL)finished;
- (BOOL)succeeded;
- (void)setFinishCallback:(id)target selector:(SEL)aSelector;
- (void)abort;
- (BOOL)contains:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (int)responseCode;
- (NSDictionary*) resultDict;

@end
