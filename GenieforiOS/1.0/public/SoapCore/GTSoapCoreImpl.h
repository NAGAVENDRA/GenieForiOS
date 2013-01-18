//
//  GTSoapCoreImpl.h
//  MobDemo
//
//  Created by yiyang on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTSoapCore.h"
#import "SmartNetworkCore.h"

@class GTSoapCoreImpl;
@class GTBasicSoap;

@interface GTSoapResultExtractor : NSObject <NSXMLParserDelegate>
{
	int m_level;
	BOOL m_bodyFlag;
	BOOL m_respFlag;
	BOOL m_gpFlag;
	NSString *m_actionResp;
	NSMutableString *m_key3;
	NSMutableString *m_value3;
	NSMutableString *m_key4;
	NSMutableString *m_value4;
	GTBasicSoap *m_soap;
}

@end

@interface GTBaseAsyncOp : GTAsyncOp
{
	NSMutableDictionary *m_result;
	id m_target;
	SEL m_selector;
	BOOL m_finished;
	BOOL m_aborted;
	BOOL m_succeeded;
	int m_responseCode;
}

- (id)init;
- (BOOL)aborted;
- (BOOL)finished;
- (BOOL)succeeded;
- (BOOL)setFinishCallback:(id)target selector:(SEL)selector;
- (void)abort;
- (NSDictionary*)result;
- (int)responseCode;
- (NSString*)stringForKey:(NSString*)key;
- (BOOL)containsKey:(NSString*)key;
- (void)notifyFinished;
- (void)doAbort;

@end

@interface GTBasicSoap : GTAsyncOp {
	GTSoapCoreImpl *m_core;
	NSURLConnection *m_conn;
	NSMutableData *m_data;
	NSMutableDictionary *m_result;
	NSString *m_action;
	id m_target;
	SEL m_selector;
	BOOL m_finished;
	BOOL m_aborted;
	BOOL m_succeeded;
	int m_responseCode;
}

- (id)initWithCore:(GTSoapCoreImpl*)core request:(NSURLRequest*)req action:(NSString*)action;
- (void)start;
- (void)notifyFinished;
- (void)internalSetL3String:(NSString*)string forKey:(NSString*)key;
- (void)internalSetL4String:(NSString*)string forKey:(NSString*)key;

@end

@interface GTFallbackSoap : GTAsyncOp {
	GTSoapCoreImpl *m_core;
	NSMutableArray *m_ports;
	NSString *m_service;
	NSString *m_action;
	NSArray *m_names;
	NSArray *m_values;
	NSMutableDictionary *m_result;
	GTAsyncOp *m_soap;
	id m_target;
	SEL m_selector;
	BOOL m_aborted;
	BOOL m_finished;
	BOOL m_succeeded;
	int m_responseCode;
	int m_activePort;
}

- (id)initWithCore:(GTSoapCoreImpl*)core ports:(NSArray*)ports service:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (void)start;
- (void)notifyFinished;

@end

@interface GTWrappedSoap : GTAsyncOp {
	GTSoapCoreImpl *m_core;
	NSString *m_service;
	NSString *m_action;
	NSArray *m_names;
	NSArray *m_values;
	NSMutableDictionary *m_result;
	GTAsyncOp *m_soap;
	id m_target;
	SEL m_selector;
	BOOL m_aborted;
	BOOL m_finished;
	BOOL m_succeeded;
	int m_responseCode;
	int m_configStartRetryCount;
	BOOL m_callConfigFinish;
	NSString *m_finishStatus;
}

- (id)initWithCore:(GTSoapCoreImpl*)core service:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (void)start;
- (void)notifyFinished;

@end

@interface GTSoapCoreImpl : NSObject {
    NSMutableString *m_sessionId;
	NSMutableArray *m_ports;
	BOOL m_wrapMode;
	SmartNetworkSession *m_smartNetworkSession;
    NSMutableString *m_localUrl;
    NSMutableString *m_localPath;
}

- (id)initWithSessionID:(NSString*)sessionID;
- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (GTAsyncOp*)invokeAction:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (GTAsyncOp*)invokeWrappedAction:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (GTAsyncOp*)invokeBasicAction:(int)port service:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (GTAsyncOp*)invokeFcml:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values;
- (void)adjustPort:(int)port;
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

