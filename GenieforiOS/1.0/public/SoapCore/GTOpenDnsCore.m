//
//  GTOpenDnsCore.m
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTOpenDnsCore.h"

NSString* encodeString(NSString* s)
{
	return (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)s, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

@implementation GTOpenDnsCore

NSString *API_KEY = @"3D8C85A77ADA886B967984DF1F8B3711";

- (id)init
{
	return [self initWithApiKey:nil];
}

- (id)initWithApiKey:(NSString*)apiKey
{
	self = [super init];
	if (self) {
		if (apiKey) {
			m_apiKey = [[NSString alloc] initWithString:apiKey];
		} else {
			m_apiKey = [[NSString alloc] initWithString:API_KEY];
		}
	}
	return self;
}

- (NSString*)apiKey
{
	return m_apiKey;
}

- (GTAsyncOp*)invoke:(NSString*)function names:(NSArray*)names values:(NSArray*)values
{
	NSUInteger count = [names count];
	if (count != [values count]) {
		return nil;
	}

	if ((names == nil || values == nil) && (names != values)) {
		return nil;
	}

	NSMutableString *postText = [NSMutableString string];
	[postText appendFormat:@"api_key=%@", encodeString(m_apiKey)];
	[postText appendFormat:@"&method=%@", encodeString(function)];

	for (NSUInteger i = 0; i < count; i++) {
		[postText appendFormat:@"&%@=%@", encodeString([names objectAtIndex:i]), encodeString([values objectAtIndex:i])];
	}
	
	NSLog(@"%@", postText);
	
	NSData *postData = [postText dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger postDataLen = [postData length];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.opendns.com/v1/"]];
	[req setHTTPMethod:@"POST"];
	[req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req addValue:[NSString stringWithFormat:@"%d", postDataLen] forHTTPHeaderField:@"Content-Length"];
	[req setHTTPBody:postData];
	GTOpenDnsOpImpl *op = [[GTOpenDnsOpImpl alloc] initWithCore:self request:req];
	[op start];
	return [op autorelease];
}

@end

@implementation GTOpenDnsOpImpl

- (id)initWithCore:(GTOpenDnsCore*)core request:(NSURLRequest*)request
{
	self = [super init];
	if (self) {
		m_target = nil;
		m_aborted = NO;
		m_finished = NO;
		m_succeeded = NO;
		m_conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		m_data = [[NSMutableData alloc] init];
		m_result = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_data release];
	[m_conn release];
	[m_target release];
	[m_result release];
	[super dealloc];
}

- (void)start
{
	[m_conn start];
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
		[m_conn cancel];
		[m_conn release];
		m_conn = nil;
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *resultJson = [[[NSString alloc] initWithData:m_data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", resultJson);
	GTSimpleJsonParser *parser = [[GTSimpleJsonParser alloc] init];
	if ([parser parse:resultJson]) {
		m_succeeded = YES;
		[m_result addEntriesFromDictionary:[parser result]];
		NSString *s = [m_result objectForKey:@"status"];
		if (s != nil) {
			if ([s isEqualToString:@"success"]) {
				m_responseCode = 0;
			} else {
				s = [m_result objectForKey:@"error"];
				if (s != nil) {
					m_responseCode = [s intValue];
				}
			}
		}
	} else {
		m_succeeded = NO;
	}
	[parser release];
	[self notifyFinished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);
	m_succeeded = NO;
	[self notifyFinished];
}

@end

@implementation GTSimpleJsonParser

typedef NSObject *Token;

NSObject *Token_Begin = @"1";
NSObject *Token_End = @"2";
NSObject *Token_String = @"3";
NSObject *Token_Number = @"4";
NSObject *Token_Comma = @"5";
NSObject *Token_Colon = @"6";
NSObject *Token_LBracket = @"7";
NSObject *Token_RBracket = @"8";
NSObject *Token_NULL = @"9";
NSObject *Token_EOF = @"a";
NSObject *Token_ERROR = @"b";

- (void)resetState
{
	m_ptr = NULL;
	m_end = NULL;
}

- (BOOL)isNumberLike:(char)c
{
	if (c == '+' || c == '-' || (c >= '0' && c <= '9') || c == '.') {
		return YES;
	}
	return NO;
}

- (id)init
{
	if ((self = [super init])) {
		m_result = [[NSMutableDictionary alloc] init];
		m_source = [[NSMutableString alloc] init];
		m_str = [[NSMutableString alloc] init];
        m_numStr = [[NSMutableString alloc] init];
		[self resetState];
	}
	return self;
}

- (void)dealloc
{
	[m_result release];
	[m_source release];
	[m_str release];
    [m_numStr release];
	[super dealloc];
}

- (Token)nextToken
{
	if (!m_ptr) {
		return Token_ERROR;
	}
	
	if (m_ptr == m_end) {
		return Token_EOF;
	}
	
	static const char *ws = " \t\n\r";
	
	// skip whitespace
	while (m_ptr != m_end && strchr(ws, *m_ptr)) {
		++m_ptr;
	}
	
	if (m_ptr == m_end) {
		return Token_EOF;
	}
	
	char c = *m_ptr++;
	
	switch (c) {
		case '{':
			return Token_Begin;
		case '}':
			return Token_End;
		case ':':
			return Token_Colon;
		case ',':
			return Token_Comma;
		case '[':
			return Token_LBracket;
		case ']':
			return Token_RBracket;
	}
	
	// string ?
	if (c == '"') {
		[m_str setString:[NSString string]];
		const char *ss = m_ptr;
		while (m_ptr != m_end && *m_ptr != '"') {
			++m_ptr;
		}
		if (m_ptr == m_end) {
			return Token_ERROR;
		}
		
		[m_str setString:[[[NSString alloc] initWithBytes:ss length:(m_ptr++ - ss) encoding:NSUTF8StringEncoding] autorelease]];
		return Token_String;
	}
	
	// number ?
	if ([self isNumberLike:c]) {
		const char *ss = m_ptr - 1;
		while (m_ptr != m_end && [self isNumberLike:*m_ptr]) {
			++m_ptr;
		}
		bool ok;
        [m_numStr setString:[[[NSString alloc] initWithBytes:ss length:(m_ptr - ss) encoding:NSUTF8StringEncoding] autorelease]];
		m_num = atof([m_numStr UTF8String]);
		ok = true;
		if (!ok) {
			return Token_ERROR;
		}
		return Token_Number;
	}
	
	// null ?
	if (c == 'n' && m_ptr + 2 < m_end && m_ptr[0] == 'u' && m_ptr[1] == 'l' && m_ptr[2] == 'l') {
		m_ptr += 3;
		return Token_NULL;
	}
	
	return Token_ERROR;
}

- (BOOL) parse:(NSString*)json
{
	[self resetState];
	
	[m_source setString:json];
	m_ptr = [m_source UTF8String];
	m_end = m_ptr + [m_source length];
	
	NSMutableArray *stack = [NSMutableArray array];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	NSMutableArray *expectedTokens = [NSMutableArray array];
	[expectedTokens addObject:Token_Begin];
	Token prevToken = Token_ERROR;
	
	BOOL inList = NO;
	NSMutableArray *ls0 = [NSMutableArray array];
	
	NSMutableString *prefix = [NSMutableString string];
	NSMutableString *lastKey = [NSMutableString string];
	
	for (;;) {
		Token token = [self nextToken];
		if ([expectedTokens indexOfObject:token] == NSNotFound) {
			//DBGLOG(LOG_ERROR, 2, QString::fromUtf8("unexpected token %1").arg(token));
			return NO;
		}
		if (token == Token_ERROR) {
			return NO;
		} else if (token == Token_EOF) {
			if ([stack count] > 0) {
				//DBGLOG(LOG_ERROR, 2, QString::fromUtf8("unblanced { }, bad json!"));
				return NO;
			}
			[m_result setDictionary:result];
			return YES;
		} else if (token == Token_Begin) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token BEGIN"));
			if ([stack count] == 0) {
				[stack addObject:[NSString string]];
			} else {
				[stack addObject:[NSString stringWithString:prefix]];
				[prefix appendString:lastKey];
				[prefix appendString:[NSString stringWithUTF8String:"."]];
			}
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_End];
			[expectedTokens addObject:Token_String];
		} else if (token == Token_End) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token END"));
			[prefix setString:[stack lastObject]];
			[stack removeLastObject];
			if ([stack count] > 0) {
				[expectedTokens setArray:[NSArray array]];
				[expectedTokens addObject:Token_Comma];
				[expectedTokens addObject:Token_End];
			} else {
				[expectedTokens addObject:Token_EOF];
			}
		} else if (token == Token_Comma) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token COMMA"));
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_End];
			[expectedTokens addObject:Token_String];
		} else if (token == Token_Colon) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token COLON"));
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_Begin];
			[expectedTokens addObject:Token_String];
			[expectedTokens addObject:Token_Number];
			[expectedTokens addObject:Token_LBracket];
			[expectedTokens addObject:Token_NULL];
		} else if (token == Token_String) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token STRING [%1]").arg(QString::fromUtf8(m_str)));
			
			if (inList) {
				[ls0 addObject:[NSString stringWithString:m_str]];
				
				[expectedTokens setArray:[NSArray array]];
				[expectedTokens addObject:Token_Comma];
				[expectedTokens addObject:Token_RBracket];
			} else {
				if (prevToken == Token_Colon) {
					//DBGLOG(LOG_DEBUG, 12, QString::fromUtf8("submit '%3%1'='%2'").arg(lastKey).arg(QString::fromUtf8(m_str)).arg(prefix));
					NSMutableString *key = [NSMutableString stringWithString:prefix];
					[key appendString:lastKey];
					[result setObject:[NSString stringWithString:m_str] forKey:key];
				} else {
					[lastKey setString:m_str];
				}
				
				// TODO:
				[expectedTokens setArray:[NSArray array]];
				[expectedTokens addObject:Token_End];
				[expectedTokens addObject:Token_Comma];
				[expectedTokens addObject:Token_Colon];
			}
		} else if (token == Token_Number) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token NUMBER [%1]").arg(m_num));
			//DBGLOG(LOG_DEBUG, 12, QString::fromUtf8("submit '%3%1'=%2").arg(lastKey).arg(m_num).arg(prefix));
			NSMutableString *key = [NSMutableString stringWithString:prefix];
			[key appendString:lastKey];
			//[result setObject:[NSNumber numberWithDouble:m_num] forKey:key];
            [result setObject:[NSString stringWithString:m_numStr] forKey:key];
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_End];
			[expectedTokens addObject:Token_Comma];
		} else if (token == Token_LBracket) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token LBracket"));
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_String];
			[expectedTokens addObject:Token_RBracket];
			inList = YES;
			[ls0 setArray:[NSArray array]];
		} else if (token == Token_RBracket) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token RBracket"));
			NSMutableString *key = [NSMutableString stringWithString:prefix];
			[key appendString:lastKey];
			[result setObject:[NSArray arrayWithArray:ls0] forKey:key];
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_End];
			[expectedTokens addObject:Token_Comma];
			inList = NO;
		} else if (token == Token_NULL) {
			//DBGLOG(LOG_DEBUG, 8, QString::fromUtf8("token RBracket"));
			NSMutableString *key = [NSMutableString stringWithString:prefix];
			[key appendString:lastKey];
			[result setObject:[NSNull null] forKey:key];
			[expectedTokens setArray:[NSArray array]];
			[expectedTokens addObject:Token_End];
			[expectedTokens addObject:Token_Comma];
		}
		
		prevToken = token;
	}
	
	return NO;
}

- (NSDictionary*)result
{
	return m_result;
}

@end

#include <netdb.h>
#include <arpa/inet.h>

@implementation DNSQueryOp

- (id)initWithHostName:(NSString*)hostName
{
	self = [super init];
	if (self) {
		m_target = nil;
		m_aborted = NO;
		m_finished = NO;
		m_succeeded = NO;
		m_result = [[NSMutableDictionary alloc] init];
		m_hostName = [[NSString alloc] initWithString:hostName];
	}
	return self;
}

- (void)dealloc
{
	[m_hostName release];
	[m_target release];
	[m_result release];
	[super dealloc];
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

- (void)dnsWorkerFinished:(id)arg
{
	if (m_succeeded) {
		m_responseCode = 0;
	} else {
		m_responseCode = -1;
	}
	[self notifyFinished];
}

- (void)dnsWorker:(id)arg
{
	struct hostent *entry;
	struct in_addr addr;
	BOOL succeeded = NO;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	entry = gethostbyname([m_hostName cStringUsingEncoding:NSUTF8StringEncoding]);
	if (entry && entry->h_addrtype == AF_INET) {
		for (char **p = entry->h_addr_list; *p != 0; p++) {
			addr.s_addr = *(in_addr_t*)(*p);
			NSLog(@"%s", inet_ntoa(addr));
			succeeded = YES;
		}
		
	}
	[pool release];
	m_succeeded = succeeded;
	[self performSelectorOnMainThread:@selector(dnsWorkerFinished:) withObject:nil waitUntilDone:FALSE];
}

- (void)start
{
	[self performSelectorInBackground:@selector(dnsWorker:) withObject:nil];
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
		// TODO:
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

+ (GTAsyncOp*)query:(NSString*)hostName
{
	DNSQueryOp *op = [[DNSQueryOp alloc] initWithHostName:hostName];
	[op start];
	return [op autorelease];
}

@end
