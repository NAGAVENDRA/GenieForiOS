//
//  SmartNetworkCore.h
//  MobDemo
//
//  Created by yiyang on 12-4-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAsyncOp.h"

enum SNStatus {
	SNStatus_Ok = 0,
	SNStatus_AuthFailed = -1000,
	SNStatus_RouterAuthFailed = -1001,
	SNStatus_UnknownError = -1,
};

@interface XMLSegmentExtractor : NSObject <NSXMLParserDelegate>
{
	NSString *m_xml;
	BOOL m_first;
	NSMutableString *m_tagName;
	NSMutableDictionary *m_dict;
}

+ (NSString*)extract:(NSString*)xml attrs:(NSMutableDictionary*)attrs;

@end

@interface SmartNetworkCore : NSObject {
    NSMutableString *m_cookie;
	NSMutableString *m_smartNetworkUsername;
	NSMutableString *m_smartNetworkPassword;
	NSMutableString *m_uiid;
	NSMutableString *m_domain;
    NSMutableString *m_smartNetworkUrl;
	NSUInteger m_serialNo;
}

- (id)init;
- (id)initWithUsername:(NSString*)username password:(NSString*)password;
- (GTAsyncOp*)openURL:(NSString*)url withData:(NSString*)data;
- (void)setCookie:(NSString*)cookie;
- (NSString*)cookie;
- (GTAsyncOp*)authInit:(NSString*)username password:(NSString*)password;
- (NSString*)smartNetworkUsername;
- (NSString*)smartNetworkPassword;
- (void)notifyInitFinished:(NSString*)uiid domain:(NSString*)domain;
- (GTAsyncOp*)receive;
- (NSString*)uiid;
- (GTAsyncOp*)send:(NSString*)xml;
- (GTAsyncOp*)sendTo:(NSString*)client domain:(NSString*)domain object:(NSString*)object method:(NSString*)method names:(NSArray*)names values:(NSArray*)values;
- (GTAsyncOp*)invokeFcml:(NSString*)client domain:(NSString*)domain object:(NSString*)object method:(NSString*)method names:(NSArray*)names values:(NSArray*)values;
- (BOOL)authed;
- (NSUInteger)serialNo;
- (GTAsyncOp*)listActiveRouters;
- (void)setUsername:(NSString*)username password:(NSString*)password;
- (NSString*)smartNetworkUrl;
- (void)setBaseUrl:(NSString*)url;

@end

@interface SNBaseAsyncOp : GTAsyncOp
{
	SmartNetworkCore *m_core;
	NSMutableDictionary *m_result;
	id m_target;
	SEL m_selector;
	BOOL m_finished;
	BOOL m_aborted;
	BOOL m_succeeded;
	int m_responseCode;
}

- (id)initWithCore:(SmartNetworkCore*)core;
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

@interface SNHttpOp : SNBaseAsyncOp
{
	NSData *m_data;
	NSURLConnection *m_conn;
	NSString *m_url;
	NSMutableData *m_respData;
	NSHTTPURLResponse *m_resp;
}

- (id)initWithCore:(SmartNetworkCore *)core url:(NSString*)url data:(NSString*)data;
- (void)start;

@end

@interface SNAuthInitOp : SNBaseAsyncOp
{
	GTAsyncOp *m_op;
}

- (id)initWithCore:(SmartNetworkCore*)core;
- (void)start;

@end

@interface SNReceiveOp : SNBaseAsyncOp
{
	GTAsyncOp *m_op;
}

- (id)initWithCore:(SmartNetworkCore *)core;
- (void)start;

@end

@interface SNSendOp : SNBaseAsyncOp
{
	GTAsyncOp *m_op;
	NSString *m_xml;
}

- (id)initWithCore:(SmartNetworkCore *)core data:(NSString*)xml;
- (void)start;

@end

@interface SNFcmlOp : SNBaseAsyncOp
{
	GTAsyncOp *m_op;
	NSString *m_client;
	NSString *m_domain;
	NSString *m_object;
	NSString *m_method;
	NSArray *m_names;
	NSArray *m_values;
	NSUInteger m_serialNo;
}

- (id)initWithCore:(SmartNetworkCore *)core client:(NSString*)client domain:(NSString*)domain object:(NSString*)object method:(NSString*)method names:(NSArray*)names values:(NSArray*)values;
- (void)start;
- (void)startAuth;
- (void)startReceive;

@end;

@interface FcmlNode : NSObject
{
	NSString *m_tagName;
	NSDictionary *m_attrDict;
	NSMutableArray *m_children;
}

- (id)initWithTagName:(NSString*)tagName attrs:(NSDictionary*)attrs;
- (void)addChild:(FcmlNode*)child;
- (NSString*)tagName;
- (NSDictionary*)attrDict;
- (NSArray*)children;

@end

@interface SNFcmlExtractor : NSObject <NSXMLParserDelegate>
{
	int m_level;
	int m_fcmlLevel;
	int m_serialNo;
	NSUInteger m_lastSerialNo;
	BOOL m_found;
	BOOL m_inBlock;
	NSMutableArray *m_stack;
	FcmlNode *m_rootNode;
}

- (id)initWithSerialNo:(int)serialNo;
- (BOOL)found;
- (BOOL)shouldContinue;
- (FcmlNode*)rootNode;

@end

@interface SNListRoutersOp : SNBaseAsyncOp {
	GTAsyncOp *m_op;
}

- (id)initWithCore:(SmartNetworkCore *)core;
- (void)start;

@end

@interface SmartNetworkSession : SmartNetworkCore
{
	NSMutableString *m_routerUsername;
	NSMutableString *m_routerPassword;
	NSMutableString *m_cpid;
	NSMutableString *m_sessionId;
}

- (id)init;
- (id)initWithUsername:(NSString *)username password:(NSString *)password;
- (void)setRouterUsername:(NSString*)username password:(NSString*)password;
- (void)setControlPointID:(NSString*)cpid;
- (GTAsyncOp*)invokeSoap:(NSString*)object method:(NSString*)method names:(NSArray*)names values:(NSArray*)values;
- (NSString*)routerUsername;
- (NSString*)routerPassword;
- (NSString*)controlPointID;
- (NSString*)sessionID;
- (void)setSessionID:(NSString*)sessionID;
- (void)logout;
- (GTAsyncOp*)closeSession;

@end

@interface SNSoapOp : SNBaseAsyncOp
{
	GTAsyncOp *m_op;
	NSString *m_object;
	NSString *m_method;
	NSArray *m_names;
	NSArray *m_values;
}

- (id)initWithCore:(SmartNetworkCore *)core object:(NSString*)object method:(NSString*)method names:(NSArray*)names values:(NSArray*)values;
- (void)start;

@end

@interface SNCloseOp : SNBaseAsyncOp
{
    GTAsyncOp *m_op;
}

- (id)initWithCore:(SmartNetworkCore *)core;
- (void)start;

@end


