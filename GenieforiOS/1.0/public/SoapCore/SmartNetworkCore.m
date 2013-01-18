//
//  SmartNetworkCore.m
//  MobDemo
//
//  Created by yiyang on 12-4-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SmartNetworkCore.h"

@implementation XMLSegmentExtractor

- (id)initWithXml:(NSString*)xml
{
	self = [super init];
	if (self) {
		m_xml = [xml retain];
		m_first = YES;
		m_tagName = [[NSMutableString alloc] init];
		m_dict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_xml release];
	[m_tagName release];
	[m_dict release];
	[super dealloc];
}

- (NSString*)tagName
{
	return m_tagName;
}

- (NSDictionary*)dict
{
	return m_dict;
}

- (BOOL)parse
{
	const char *s = [m_xml UTF8String];
	NSData *data = [NSData dataWithBytes:s length:strlen(s)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	BOOL retval = [parser parse];
	[parser release];
	return retval;
}

+ (NSString*)extract:(NSString *)xml attrs:(NSMutableDictionary *)attrs
{
	XMLSegmentExtractor *x = [[[XMLSegmentExtractor alloc] initWithXml:xml] autorelease];
	if ([x parse]) {
		[attrs setDictionary: [x dict]];
		return [NSString stringWithString:[x tagName]];
	}
	return @"";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"%@", elementName);
	if (m_first) {
		m_first = NO;
		[m_tagName setString:elementName];
		[m_dict setDictionary:attributeDict];
	}
}

@end

static NSString *SMARTNETWORK_BASEURL = @"https://appgenie-staging.netgear.com";

@implementation SmartNetworkCore

- (id)init
{
	return [self initWithUsername:nil password:nil];
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password
{
	self = [super init];
	if (self) {
		m_cookie = [[NSMutableString alloc] init];
		m_smartNetworkUsername = [[NSMutableString alloc] initWithString:username ? username : @""];
		m_smartNetworkPassword = [[NSMutableString alloc] initWithString:password ? password : @""];
		m_uiid = [[NSMutableString alloc] init];
		m_domain = [[NSMutableString alloc] init];
        m_smartNetworkUrl = [[NSMutableString alloc] initWithString:SMARTNETWORK_BASEURL];
		m_serialNo = 1000000;
	}
	return self;
}

- (GTAsyncOp*)openURL:(NSString *)url withData:(NSString *)data
{
	SNHttpOp *op = [[SNHttpOp alloc] initWithCore:self url:url data:data];
	[op start];
	return [op autorelease];
}

- (void)setCookie:(NSString*)cookie
{
	[m_cookie setString:cookie];
}

- (NSString*)cookie
{
	return m_cookie;
}

- (void)dealloc
{
    [m_smartNetworkUrl release];
	[m_cookie release];
	[m_smartNetworkUsername release];
	[m_smartNetworkPassword release];
	[m_uiid release];
	[m_domain release];
	[super dealloc];
}

- (GTAsyncOp*)authInit:(NSString *)username password:(NSString *)password
{
	if (username) {
		[m_smartNetworkUsername setString:username];
	}
	if (password) {
		[m_smartNetworkPassword setString:password];
	}
	SNAuthInitOp *op = [[SNAuthInitOp alloc] initWithCore:self];
	[op start];
	return [op autorelease];
}

- (NSString*)smartNetworkUsername
{
	return m_smartNetworkUsername;
}

- (NSString*)smartNetworkPassword
{
	return m_smartNetworkPassword;
}

- (void)notifyInitFinished:(NSString *)uiid domain:(NSString *)domain
{
	[m_uiid setString:uiid];
	[m_domain setString:domain];
}

- (GTAsyncOp*)receive
{
	SNReceiveOp *op = [[SNReceiveOp alloc] initWithCore:self];
	[op start];
	return [op autorelease];
}

- (NSString*)uiid
{
	return m_uiid;
}

- (GTAsyncOp*)send:(NSString *)xml
{
	SNSendOp *op = [[SNSendOp alloc] initWithCore:self data:xml];
	[op start];
	return [op autorelease];
}

- (GTAsyncOp*)sendTo:(NSString*)client domain:(NSString*)domain object:(NSString*)object method:(NSString*)method names:(NSArray*)names values:(NSArray*)values
{
	NSMutableString *fcml = [[NSMutableString alloc] init];
	[fcml appendFormat:@"<fcml from=\"%@@%@\" to=\"%@@%@\" _tracer=\"%d\">", m_uiid, m_domain, client, domain, m_serialNo++];
	if (object) {
		[fcml appendFormat:@"<%@.%@", object, method];
	} else {
		[fcml appendFormat:@"<%@", method];
	}
	if (names && [names count] > 0) {
		for (NSUInteger i = 0; i < [names count]; i++) {
			[fcml appendFormat:@" %@=\"%@\"", [names objectAtIndex:i], [values objectAtIndex:i]];
		}
	}
	[fcml appendString:@"/></fcml>"];
	NSLog(@"fcml: %@", fcml);
	GTAsyncOp *op = [self send:fcml];
	[fcml release];
	return op;
}

- (GTAsyncOp*)invokeFcml:(NSString *)client domain:(NSString *)domain object:(NSString *)object method:(NSString *)method names:(NSArray *)names values:(NSArray *)values
{
	SNFcmlOp *op = [[SNFcmlOp alloc] initWithCore:self client:client domain:domain object:object method:method names:names values:values];
	[op start];
	return [op autorelease];
}

- (BOOL)authed
{
	return [m_uiid length] > 0;
}

- (NSUInteger)serialNo
{
	return m_serialNo;
}

- (GTAsyncOp*)listActiveRouters
{
	SNListRoutersOp *op = [[SNListRoutersOp alloc] initWithCore:self];
	[op start];
	return [op autorelease];
}

- (void)setUsername:(NSString *)username password:(NSString *)password
{
	[m_smartNetworkUsername setString:username];
	[m_smartNetworkPassword setString:password];
}

- (NSString*)smartNetworkUrl
{
    return m_smartNetworkUrl;
}

- (void)setBaseUrl:(NSString*)url
{
    [m_smartNetworkUrl setString:[NSString stringWithFormat:@"https://%@", url]];
}

@end

@implementation SNBaseAsyncOp

- (id)initWithCore:(SmartNetworkCore *)core
{
	self = [super init];
	if (self) {
		m_core = [core retain];
		m_result = [[NSMutableDictionary alloc] init];
		m_aborted = NO;
		m_finished = NO;
		m_succeeded = NO;
		m_target = nil;
		m_responseCode = -1;
	}
	return self;
}

- (void)dealloc
{
	[m_target release];
	[m_result release];
	[m_core release];
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
		[self doAbort];
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

- (void)doAbort
{
}

@end

@implementation SNHttpOp

- (id)initWithCore:(SmartNetworkCore *)core url:(NSString*)url data:(NSString *)data
{
	self = [super initWithCore:core];
	if (self) {
		if (data) {
			const char *str = [data UTF8String];
			m_data = [[NSData alloc] initWithBytes:str length:strlen(str)];
		} else {
			m_data = nil;
		}
		m_conn = nil;
		m_url = [url retain];
		m_respData = [[NSMutableData alloc] init];
		m_resp = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_resp release];
	[m_respData release];
	[m_url release];
	[m_conn release];
	[m_data release];
	[super dealloc];
}

- (void)start
{
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:m_url]];
	[req setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
	NSString *cookie = [m_core cookie];
	if ([cookie length] > 0) {
		[req setValue:cookie forHTTPHeaderField:@"Cookie"];
	}
	
	if (m_data) {
		[req setValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
		[req setValue:[NSString stringWithFormat:@"%d", [m_data length]] forHTTPHeaderField:@"Content-Length"];
		[req setHTTPMethod:@"POST"];
		[req setHTTPBody:m_data];
	} else {
		[req setHTTPMethod:@"GET"];
	}
	
	m_conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
	[req release];
	[m_conn start];
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_respData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([m_resp statusCode] != 200) {
		m_succeeded = NO;
		[self notifyFinished];
		return;
	}
	
	NSString *cookieStr = [[m_resp allHeaderFields] valueForKey:@"Set-Cookie"];
	if (cookieStr) {
		NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
		NSArray *parts = [cookieStr componentsSeparatedByString:@", "];
		for (int i = [parts count] - 1; i >= 0; i--) {
			NSString *cs = [parts objectAtIndex:i];
			NSLog(@"cs: %@", cs);
			NSArray *parts2 = [cs componentsSeparatedByString:@"; "];
			[s appendString:[parts2 objectAtIndex:0]];
			if (i != 0) {
				[s appendString:@"; "];
			}
		}
		NSLog(@"kk: %@", s);
		[m_core setCookie:s];
	}
	m_succeeded = YES;
	[m_respData appendBytes:"\0" length:1];
	NSString *responseText = [NSString stringWithUTF8String:[m_respData bytes]];
	NSLog(@"resp: %@", responseText);
	[m_result setObject:responseText forKey:@"data"];
	[self notifyFinished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);
	m_succeeded = NO;
	[self notifyFinished];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
	NSLog(@"%d %@", [resp statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[resp statusCode]]);
	NSDictionary *dict = [resp allHeaderFields];
	NSLog(@"%p", dict);
	[m_resp release];
	m_resp = [resp retain];
}

@end

@implementation SNAuthInitOp

- (id)initWithCore:(SmartNetworkCore *)core
{
	self = [super initWithCore:core];
	if (self) {
		m_op = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_op release];
	[super dealloc];
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

- (void)initFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;

	if ([op succeeded]) {
		NSString *xml = [op stringForKey:@"data"];
		NSLog(@"tttt %@", xml);

		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
		NSString *tagName = [XMLSegmentExtractor extract:xml attrs:attrs];
		if (!tagName || NSOrderedSame != [tagName compare:@"init" options:NSCaseInsensitiveSearch]) {
			m_succeeded = NO;
			[self notifyFinished];
			return;
		}
		
		NSString *uiid = [attrs objectForKey:@"name"];
		NSString *domain = [attrs objectForKey:@"domain"];
		if (!uiid || !domain) {
			m_succeeded = NO;
			[self notifyFinished];
			return;
		}
		
		[m_core notifyInitFinished:uiid domain:domain];
		
		m_succeeded = YES;
		m_responseCode = SNStatus_Ok;
		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)startInit
{
	NSString *url = [NSString stringWithFormat:@"%@/fcp/init", [m_core smartNetworkUrl]];
	m_op = [m_core openURL:url withData:@"<init type=\"ui\" fcmb=\"true\"/>"];
	[m_op setFinishCallback:self selector:@selector(initFinished:)];
	[m_op retain];
}

- (void)authFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;

	if ([op succeeded]) {
		NSString *xml = [op stringForKey:@"data"];
		NSLog(@"ssss %@", xml);
		
		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
		NSString *tagName = [XMLSegmentExtractor extract:xml attrs:attrs];
		if (!tagName || NSOrderedSame != [tagName compare:@"authenticate" options:NSCaseInsensitiveSearch]) {
			m_succeeded = NO;
			[self notifyFinished];
			return;
		}
		
		NSString *authAttr = [attrs objectForKey:@"authenticated"];
		if (!authAttr) {
			m_succeeded = NO;
			[self notifyFinished];
			return;
		}

		if (NSOrderedSame != [authAttr compare:@"true" options:NSCaseInsensitiveSearch]) {
			m_succeeded = YES;
			m_responseCode = SNStatus_AuthFailed;
			[self notifyFinished];
			return;
		}
		
		[self startInit];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)start
{
	NSString *url = [NSString stringWithFormat:@"%@/fcp/authenticate", [m_core smartNetworkUrl]];
	m_op = [m_core openURL:url withData:[NSString stringWithFormat:@"<authenticate type=\"basic\" username=\"%@\" password=\"%@\"/>", [m_core smartNetworkUsername], [m_core smartNetworkPassword]]];
	[m_op setFinishCallback:self selector:@selector(authFinished:)];
	[m_op retain];
}

@end

@implementation SNReceiveOp

- (id)initWithCore:(SmartNetworkCore *)core
{
	self = [super initWithCore:core];
	if (self) {
		m_op = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_op release];
	[super dealloc];
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

- (void)recvFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		NSString *xml = [op stringForKey:@"data"];
		[m_result setObject:xml forKey:@"data"];
		NSLog(@"ssss %@", xml);
		m_succeeded = YES;
		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)start
{
	NSString *url = [NSString stringWithFormat:@"%@/fcp/receive?n=%@", [m_core smartNetworkUrl], [m_core uiid]];
	m_op = [m_core openURL:url withData:nil];
	[m_op setFinishCallback:self selector:@selector(recvFinished:)];
	[m_op retain];
}

@end

@implementation SNSendOp

- (id)initWithCore:(SmartNetworkCore *)core data:(NSString *)xml
{
	self = [super initWithCore:core];
	if (self) {
		m_op = nil;
		m_xml = [xml retain];
	}
	return self;
}

- (void)dealloc
{
	[m_op release];
	[m_xml release];
	[super dealloc];
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

- (void)sendFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		NSString *xml = [op stringForKey:@"data"];
		[m_result setObject:xml forKey:@"data"];
		NSLog(@"kkkk %@", xml);
		m_succeeded = YES;
		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)start
{
	NSString *url = [NSString stringWithFormat:@"%@/fcp/send?n=%@", [m_core smartNetworkUrl], [m_core uiid]];
	m_op = [m_core openURL:url withData:m_xml];
	[m_op setFinishCallback:self selector:@selector(sendFinished:)];
	[m_op retain];
}

@end

@implementation SNFcmlExtractor

- (id)initWithSerialNo:(int)serialNo
{
	self = [super init];
	if (self) {
		m_level = 0;
		m_serialNo = serialNo;
		m_lastSerialNo = 0;
		m_found = NO;
		m_inBlock = NO;
		m_stack = [[NSMutableArray alloc] init];
		m_rootNode = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_stack release];
	[m_rootNode release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	++m_level;
	if (m_level == 1) {
		if ([elementName isEqual:@"fcmb"]) {
			m_fcmlLevel = 2;
		} else if ([elementName isEqual:@"fcml"]) {
			m_fcmlLevel = 1;
		} else {
			[parser abortParsing];
			return;
		}
	}

	if (m_level == m_fcmlLevel) {
		if (![elementName isEqual:@"fcml"]) {
			[parser abortParsing];
			return;
		}

		NSString *tracer = [attributeDict objectForKey:@"_tracer"];
		if (tracer) {
			int serialNo = [tracer intValue];
			if (serialNo == m_serialNo) {
				m_found = YES;
				m_inBlock = YES;
				NSLog(@"NNN: %d", serialNo);
			}
			m_lastSerialNo = serialNo;
		}
	}
	
	if (m_inBlock) {
		NSLog(@"SSS: %@", elementName);
		FcmlNode *node = [[FcmlNode alloc] initWithTagName:elementName attrs:attributeDict];
		if ([m_stack count] > 0) {
			[[m_stack lastObject] addChild:node];
		}
		[m_stack addObject:node];
		[node release];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (m_inBlock) {
		NSLog(@"EEE: %@", elementName);
		if ([m_stack count] == 1) {
			m_rootNode = [[m_stack lastObject] retain];
		}
		[m_stack removeLastObject];
	}
	
	if (m_level == m_fcmlLevel) {
		if (m_inBlock) {
			m_inBlock = NO;
		}
	}
	--m_level;
}

- (BOOL)found
{
	return m_found;
}

- (BOOL)shouldContinue
{
	return !m_found && m_lastSerialNo < m_serialNo;
}

- (FcmlNode*)rootNode
{
	return m_rootNode;
}

@end

@implementation SNFcmlOp

- (id)initWithCore:(SmartNetworkCore *)core client:(NSString *)client domain:(NSString *)domain object:(NSString *)object method:(NSString *)method names:(NSArray *)names values:(NSArray *)values
{
	self = [super initWithCore:core];
	if (self) {
		m_client = [client retain];
		m_domain = [domain retain];
		m_object = [object retain];
		m_method = [method retain];
		m_names = [names retain];
		m_values = [values retain];
		m_op = nil;
		m_serialNo = 0;
	}
	return self;
}

- (void)dealloc
{
	[m_op release];
	[m_client release];
	[m_domain release];
	[m_object release];
	[m_method release];
	[m_names release];
	[m_values release];
	[super dealloc];
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

- (void)processResult:(NSString*)xml
{
	SNFcmlExtractor *x = [[SNFcmlExtractor alloc] initWithSerialNo:m_serialNo];
	const char *s = [xml UTF8String];
	NSData *data = [NSData dataWithBytes:s length:strlen(s)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:x];
	BOOL parseOk = [parser parse];
	[parser release];
	if (parseOk) {
		if ([x found]) {
			[m_result setObject:[x rootNode] forKey:@"rootNode"];
			[x release];
			m_succeeded = YES;
			m_responseCode = SNStatus_Ok;
			[self notifyFinished];
		} else if ([x shouldContinue]) {
			[x release];
			[self startReceive];
		} else {
			[x release];
			m_succeeded = NO;
			[self notifyFinished];
		}
	} else {
		[x release];
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)receiveFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		[self processResult:[op stringForKey:@"data"]];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)startReceive
{
	m_op = [m_core receive];
	[m_op setFinishCallback:self selector:@selector(receiveFinished:)];
	[m_op retain];
}

- (void)sendFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		NSString *data = [op stringForKey:@"data"];
		if ([data length] > 0) {
			[self startAuth];
		} else {
			[self startReceive];
		}
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)startFcml
{
	m_serialNo = [m_core serialNo];
	m_op = [m_core sendTo:m_client domain:m_domain object:m_object method:m_method names:m_names values:m_values];
	[m_op setFinishCallback:self selector:@selector(sendFinished:)];
	[m_op retain];
}

- (void)authFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		if ([op responseCode] == SNStatus_Ok) {
			[self startFcml];
		} else {
			m_succeeded = YES;
			m_responseCode = [op responseCode];
			[self notifyFinished];
		}
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)startAuth
{
	m_op = [m_core authInit:nil password:nil];
	[m_op setFinishCallback:self selector:@selector(authFinished:)];
	[m_op retain];
}

- (void)start
{
	if ([m_core authed]) {
		[self startFcml];
	} else {
		[self startAuth];
	}
}

@end

@implementation FcmlNode

- (id)initWithTagName:(NSString *)tagName attrs:(NSDictionary *)attrs
{
	self = [super init];
	if (self) {
		m_tagName = [tagName retain];
		m_attrDict = [attrs retain];
		m_children = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_tagName release];
	[m_attrDict release];
	[m_children release];
	[super dealloc];
}

- (void)addChild:(FcmlNode *)child
{
	[m_children addObject:child];
}

- (NSString*)tagName
{
	return m_tagName;
}

- (NSDictionary*)attrDict
{
	return m_attrDict;
}

- (NSArray*)children
{
	return m_children;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"name: %@, attrs: %@ children: %@", m_tagName, [m_attrDict description], [m_children description]];
}

@end

@implementation SNListRoutersOp

- (id)initWithCore:(SmartNetworkCore *)core
{
	self = [super initWithCore:core];
	if (self) {
		m_op = nil;
	}
	return self;
}

- (void)invokeFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	
	if ([op succeeded]) {
        if ([op responseCode] != SNStatus_Ok) {
            m_succeeded = YES;
            m_responseCode = [op responseCode];
            [self notifyFinished];
            return;
        }
        
		FcmlNode *rootNode = [[op result] objectForKey:@"rootNode"];
		if (!rootNode || ![[rootNode tagName] isEqual:@"fcml"]) {
			m_succeeded = NO;
			[self notifyFinished];
			return;
		}

		NSMutableArray *ls = [NSMutableArray array];
		NSMutableDictionary *nodeDict = [NSMutableDictionary dictionary];
		for (FcmlNode *childNode in [rootNode children]) {
			NSArray *parts = [[childNode tagName] componentsSeparatedByString:@"."];
			if ([parts count] == 4 /*&& [[[childNode attrDict] objectForKey:@"active"] isEqual:@"true"]*/) {
				[nodeDict setObject:[NSString stringWithString:[parts objectAtIndex:2]] forKey:@"id"];
				[nodeDict addEntriesFromDictionary:[childNode attrDict]];
				[ls addObject:[NSDictionary dictionaryWithDictionary:nodeDict]];
			}
		}

		[m_result setObject:ls forKey:@"list"];
		m_succeeded = YES;
		m_responseCode = SNStatus_Ok;
		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)start
{
	m_op = [m_core invokeFcml:@"router" domain:@"portal" object:nil method:@"get" names:nil values:nil];
	[m_op setFinishCallback:self selector:@selector(invokeFinished:)];
	[m_op retain];
}

- (void)dealloc
{
	[m_op release];
	[super dealloc];
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

@end

@implementation SmartNetworkSession

- (id)init
{
	return [self initWithUsername:nil password:nil];
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password
{
	self = [super initWithUsername:username password:password];
	if (self) {
		m_routerUsername = [[NSMutableString alloc] initWithString:@"admin"];
		m_routerPassword = [[NSMutableString alloc] initWithString:@"password"];
		m_cpid = [[NSMutableString alloc] init];
		m_sessionId = [[NSMutableString alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_routerUsername release];
	[m_routerPassword release];
	[m_cpid release];
	[m_sessionId release];
	[super dealloc];
}

- (void)setRouterUsername:(NSString*)username password:(NSString*)password
{
	[m_routerUsername setString:username];
	[m_routerPassword setString:password];
}

- (void)setControlPointID:(NSString*)cpid
{
	[m_cpid setString:cpid];
}

- (GTAsyncOp*)invokeSoap:(NSString *)object method:(NSString *)method names:(NSArray *)names values:(NSArray *)values
{
	SNSoapOp *op = [[SNSoapOp alloc] initWithCore:self object:object method:method names:names values:values];
	[op start];
	return [op autorelease];
}

- (GTAsyncOp*)closeSession
{
    if ([m_sessionId length] == 0) {
        return nil;
    }
    SNCloseOp *op = [[SNCloseOp alloc] initWithCore:self];
    [op start];
    [m_sessionId setString:@""];
    return [op autorelease];
}

- (NSString*)routerUsername
{
	return m_routerUsername;
}

- (NSString*)routerPassword
{
	return m_routerPassword;
}

- (NSString*)controlPointID
{
	return m_cpid;
}

- (NSString*)sessionID
{
	return m_sessionId;
}

- (void)setSessionID:(NSString *)sessionID
{
	[m_sessionId setString:sessionID];
}

- (void)logout
{
    [m_sessionId setString:@""];
    [m_cookie setString:@""];
    [m_uiid setString:@""];
}

@end

@implementation SNSoapOp

- (id)initWithCore:(SmartNetworkCore *)core object:(NSString *)object method:(NSString *)method names:(NSArray *)names values:(NSArray *)values
{
	self = [super initWithCore:core];
	if (self) {
		m_op = nil;
		m_object = [object retain];
		m_method = [method retain];
		m_names = [names retain];
		m_values = [values retain];
	}
	return self;
}

- (void)dealloc
{
	[m_op release];
	[m_object release];
	[m_method release];
	[m_names release];
	[m_values release];
	[super dealloc];
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

- (void)sessionStarted:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		m_succeeded = YES;
		if ([op responseCode] != SNStatus_Ok) {
			m_responseCode = [op responseCode];
			[self notifyFinished];
			return;
		}
		
		FcmlNode *rootNode = [[op result] objectForKey:@"rootNode"];
		if ([[rootNode children] count] == 0) {
			m_responseCode = SNStatus_UnknownError;
			[self notifyFinished];
			return;
		}
		FcmlNode *childNode = [[rootNode children] objectAtIndex:0];
		if ([[childNode tagName] isEqual:@"error"]) {
			if ([[[childNode attrDict] objectForKey:@"code"] isEqual:@"17"]) {
				m_responseCode = SNStatus_RouterAuthFailed;
			} else {
				m_responseCode = SNStatus_UnknownError;
			}
			[self notifyFinished];
			return;
		}

		if ([[childNode tagName] hasSuffix:@"SessionManagement.startSession"]) {
			SmartNetworkSession *sess = (SmartNetworkSession*)m_core;
			[sess setSessionID:[[childNode attrDict] objectForKey:@"sessionId"]];
			[self start];
			return;
		}
		
		m_responseCode = SNStatus_UnknownError;
		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)startSession
{
	SmartNetworkSession *sess = (SmartNetworkSession*)m_core;
	m_op = [sess invokeFcml:@"netrouter" domain:[sess controlPointID] object:@"SessionManagement" method:@"startSession" names:[NSArray arrayWithObjects:@"username", @"password", nil] values:[NSArray arrayWithObjects:[sess routerUsername], [sess routerPassword], nil]];
	[m_op setFinishCallback:self selector:@selector(sessionStarted:)];
	[m_op retain];
}

- (void)soapFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	if ([op succeeded]) {
		m_succeeded = YES;
		if ([op responseCode] != SNStatus_Ok) {
			m_responseCode = [op responseCode];
			[self notifyFinished];
			return;
		}
		
		FcmlNode *rootNode = [[op result] objectForKey:@"rootNode"];
		if ([[rootNode children] count] == 0) {
			m_responseCode = SNStatus_UnknownError;
			[self notifyFinished];
			return;
		}
		FcmlNode *childNode = [[rootNode children] objectAtIndex:0];
		if ([[childNode tagName] isEqual:@"error"]) {
			if ([[[childNode attrDict] objectForKey:@"code"] isEqual:@"16"]) {
				[self startSession];
			} else {
				m_responseCode = SNStatus_UnknownError;
				[self notifyFinished];
			}
			return;
		}
		
		NSString *tagSuffix = [NSString stringWithFormat:@"%@.%@", m_object, m_method];
		if (![[childNode tagName] hasSuffix:tagSuffix]) {
			m_responseCode = SNStatus_UnknownError;
			[self notifyFinished];
			return;
		}

		m_responseCode = SNStatus_Ok;
		
		NSDictionary *dict = [childNode attrDict];
		for (NSString *key in [dict allKeys]) {
			NSString *value = [dict objectForKey:key];
			if ([key isEqual:@"_responseCode"]) {
				m_responseCode = [value intValue];
			} else if ([key isEqual:@"_sessionId"]) {
				NSLog(@"ppp sessionId: %@", value);
			} else {
				[m_result setObject:[NSString stringWithString:value] forKey:key];
			}
		}

		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)start
{
	SmartNetworkSession *sess = (SmartNetworkSession*)m_core;
	NSMutableArray *names = [NSMutableArray arrayWithArray:m_names];
	NSMutableArray *values = [NSMutableArray arrayWithArray:m_values];
	[names addObject:@"_sessionId"];
	[values addObject:[sess sessionID]];
	m_op = [sess invokeFcml:@"netrouter" domain:[sess controlPointID] object:m_object method:m_method names:names values:values];
	[m_op setFinishCallback:self selector:@selector(soapFinished:)];
	[m_op retain];
}

@end

@implementation SNCloseOp

- (id)initWithCore:(SmartNetworkCore *)core
{
	self = [super initWithCore:core];
	if (self) {
		m_op = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_op release];
	[super dealloc];
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

- (void)fcmlFinished:(GTAsyncOp*)op
{
	[m_op release];
	m_op = nil;
	m_succeeded = YES;
	[self notifyFinished];
}

- (void)start
{
	SmartNetworkSession *sess = (SmartNetworkSession*)m_core;
	NSMutableArray *names = [NSMutableArray array];
	NSMutableArray *values = [NSMutableArray array];
	[names addObject:@"sessionId"];
	[values addObject:[sess sessionID]];
	m_op = [sess invokeFcml:@"netrouter" domain:[sess controlPointID] object:@"SessionManagement" method:@"endSession" names:names values:values];
	[m_op setFinishCallback:self selector:@selector(fcmlFinished:)];
	[m_op retain];
}

@end
