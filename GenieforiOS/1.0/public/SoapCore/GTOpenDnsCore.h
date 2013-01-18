//
//  GTOpenDnsCore.h
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAsyncOp.h"

@interface GTOpenDnsCore : NSObject
{
	NSString *m_apiKey;
}

- (id)initWithApiKey:(NSString*)apiKey;
- (GTAsyncOp*)invoke:(NSString*)function names:(NSArray*)names values:(NSArray*)values;
- (NSString*)apiKey;

@end

@interface GTOpenDnsOpImpl : GTAsyncOp
{
	NSMutableDictionary *m_result;
	id m_target;
	SEL m_selector;
	BOOL m_aborted;
	BOOL m_finished;
	BOOL m_succeeded;
	int m_responseCode;
	NSURLConnection *m_conn;
	NSMutableData *m_data;
}

- (id)initWithCore:(GTOpenDnsCore*)core request:(NSURLRequest*)request;
- (void)start;
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

@end;

@interface GTSimpleJsonParser : NSObject {
	NSMutableDictionary *m_result;
	NSMutableString *m_source;
	const char *m_ptr;
	const char *m_end;
	NSMutableString *m_str;
	double m_num;
    NSMutableString *m_numStr;
}

- (BOOL) parse:(NSString*)json;
- (NSDictionary*) result;

@end

@interface DNSQueryOp : GTAsyncOp
{
	NSMutableDictionary *m_result;
	id m_target;
	SEL m_selector;
	BOOL m_aborted;
	BOOL m_finished;
	BOOL m_succeeded;
	int m_responseCode;
	NSString *m_hostName;
}

+ (GTAsyncOp*)query:(NSString*)hostName;

@end;

