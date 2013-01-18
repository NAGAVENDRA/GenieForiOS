//
//  GTSoapCoreImpl.m
//  MobDemo
//
//  Created by yiyang on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTSoapCoreImpl.h"

@implementation GTSoapResultExtractor

- (id)initWithAction:(NSString*)action soap:(GTBasicSoap*)soap
{
	self = [super init];
	if (self) {
		m_level = 0;
		m_bodyFlag = NO;
		m_respFlag = NO;
		m_gpFlag = NO;
		m_actionResp = [[NSString alloc] initWithFormat:@"%@Response", action];
		m_key3 = [[NSMutableString alloc] init];
		m_value3 = [[NSMutableString alloc] init];
		m_key4 = [[NSMutableString alloc] init];
		m_value4 = [[NSMutableString alloc] init];
		m_soap = soap;
	}
	return self;
}

- (void)dealloc
{
	[m_actionResp release];
	[m_key3 release];
	[m_value3 release];
	[m_key4 release];
	[m_value4 release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	++m_level;
	if (m_level == 1) {
		if (![elementName isEqualToString:@"Envelope"]) {
			[parser abortParsing];
		}
	} else if (m_level == 2) {
		if ([elementName isEqualToString:@"Body"]) {
			m_bodyFlag = YES;
		}
	} else if (m_level == 3) {
		if (m_bodyFlag) {
			[m_key3 setString:elementName];
			[m_value3 setString:@""];
		}
	} else if (m_level == 4) {
		if (m_bodyFlag) {
			[m_key4 setString:elementName];
			[m_value4 setString:@""];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (m_level == 2) {
		if (m_bodyFlag) {
			m_bodyFlag = NO;
		}
	} else if (m_level == 3) {
		if (m_bodyFlag && ![m_key3 isEqualToString:m_actionResp]) {
			[m_soap internalSetL3String:m_value3 forKey:m_key3];
		}
	} else if (m_level == 4) {
		if (m_bodyFlag) {
			[m_soap internalSetL4String:m_value4 forKey:m_key4];
		}
	}
	--m_level;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (m_bodyFlag) {
		if (m_level == 3) {
			[m_value3 appendString:string];
		} else if (m_level == 4) {
			[m_value4 appendString:string];
		}
	}
}

@end


@implementation GTSoapCoreImpl

NSString *DEFAULT_SESSION_ID = @"EA188AE69687E58D9A00";
NSString *DEFAULT_LOCAL_URL = @"http://routerlogin.net";
NSString *DEFAULT_LOCAL_PATH = @"/soap/server_sa/";

- (id)initWithSessionID:(NSString*)sessionID
{
	self = [super init];
	if (self) {
		if (sessionID) {
			m_sessionId = [[NSMutableString alloc] initWithString:sessionID];
		} else {
			m_sessionId = [[NSMutableString alloc] initWithString:DEFAULT_SESSION_ID];
		}
		m_ports = [[NSMutableArray alloc] init];
		//[m_ports addObject:[NSNumber numberWithInt:2000]];
		//[m_ports addObject:[NSNumber numberWithInt:3000]];
		//[m_ports addObject:[NSNumber numberWithInt:4000]];
		[m_ports addObject:[NSNumber numberWithInt:5000]];
		[m_ports addObject:[NSNumber numberWithInt:80]];
		m_wrapMode = NO;
		m_smartNetworkSession = [[SmartNetworkSession alloc] initWithUsername:nil password:nil];
        m_localUrl = [[NSMutableString alloc] initWithString:DEFAULT_LOCAL_URL];
        m_localPath = [[NSMutableString alloc] initWithString:DEFAULT_LOCAL_PATH];
	}
	return self;
}

- (void)dealloc
{
    [m_localUrl release];
    [m_localPath release];
	[m_smartNetworkSession release];
	[m_ports release];
	[super dealloc];
}

- (void)adjustPort:(int)port
{
	[m_ports removeObject:[NSNumber numberWithInt:port]];
	[m_ports insertObject:[NSNumber numberWithInt:port] atIndex:0];
}

- (void)setWrapMode:(BOOL)wrap
{
	m_wrapMode = wrap;
}

- (BOOL)wrapMode
{
	return m_wrapMode;
}

- (GTAsyncOp*)listActiveRouters
{
	return [m_smartNetworkSession listActiveRouters];
}


- (void)setSmartNetworkUsername:(NSString*)username password:(NSString*)password
{
	[m_smartNetworkSession setUsername:username password:password];
}

- (void)setRouterUsername:(NSString*)username password:(NSString*)password
{
	[m_smartNetworkSession setRouterUsername:username password:password];
}

- (void)setControlPointID:(NSString*)cpid
{
	[m_smartNetworkSession setControlPointID:cpid];
}

- (BOOL)isSmartNetwork
{
    return [[m_smartNetworkSession controlPointID] length] > 0;
}

- (void)logoutSmartNetwork
{
    [m_smartNetworkSession logout];
}

- (GTAsyncOp*)closeSession
{
    return [m_smartNetworkSession closeSession];
}

- (void)setLocalUrl:(NSString*)url path:(NSString*)path
{
    if ([url length] != 0) {
        [m_localUrl setString:url];
    } else {
        [m_localUrl setString:DEFAULT_LOCAL_URL];
    }
    
    if ([path length] != 0) {
        [m_localPath setString:path];
    } else {
        [m_localPath setString:DEFAULT_LOCAL_PATH];
    }
}

- (void)setSmartNetworkBaseUrl:(NSString*)url
{
    [m_smartNetworkSession setBaseUrl:url];
}

- (GTAsyncOp*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values
{
	if (m_wrapMode) {
		return [self invokeWrappedAction:service action:action names:names values:values];
	}
	return [self invokeAction:service action:action names:names values:values];
}

- (GTAsyncOp*)invokeFcml:(NSString *)service action:(NSString *)action names:(NSArray *)names values:(NSArray *)values
{
	NSArray *parts = [service componentsSeparatedByString:@":"];
	NSString *objectName = [parts objectAtIndex:3];
	return [m_smartNetworkSession invokeSoap:objectName method:action names:names values:values];
}

- (GTAsyncOp*)invokeWrappedAction:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values
{
	if ([service isEqualToString:@"urn:NETGEAR-ROUTER:service:DeviceConfig:1"]) {
		if ([action isEqualToString:@"ConfigurationStarted"] || [action isEqualToString:@"ConfigurationFinished"]) {
			return [self invokeAction:service action:action names:names values:values];
		}
	}
	GTWrappedSoap *soap = [[GTWrappedSoap alloc] initWithCore:self service:service action:action names:names values:values];
	[soap start];
	return [soap autorelease];
}

- (GTAsyncOp*)invokeAction:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values
{
	GTFallbackSoap *soap = [[GTFallbackSoap alloc] initWithCore:self ports:m_ports service:service action:action names:names values:values];
	[soap start];
	return [soap autorelease];
}

- (GTAsyncOp*)invokeBasicAction:(int)port service:(NSString *)service action:(NSString *)action names:(NSArray *)names values:(NSArray *)values
{
	if ([[m_smartNetworkSession controlPointID] length] > 0) {
		return [self invokeFcml:service action:action names:names values:values];
	}

	NSUInteger numParams = [names count];
	if (numParams != [values count]) {
		return nil;
	}

	if (names != values && (names == nil || values == nil)) {
		return nil;
	}

	BOOL actionNS = YES;
	if ([service isEqualToString:@"urn:NETGEAR-ROUTER:service:ParentalControl:1"]/* && [action isEqualToString:@"Authenticate"]2012.4.29*/) {
		actionNS = NO;
	}

	NSArray *names1 = names;
	NSArray *values1 = values;

	if ([service isEqualToString:@"urn:NETGEAR-ROUTER:service:DeviceConfig:1"] && [action isEqualToString:@"ConfigurationStarted"]) {
		if (names != nil && [[names objectAtIndex:0] isEqualToString:@"NewSessionID"]) {
			NSString *sessionId = [values objectAtIndex:0];
			if (sessionId) {
				[m_sessionId setString:sessionId];
			}
		} else if (names == nil && values == nil) {
			names1 = [NSArray arrayWithObject:@"NewSessionID"];
			values1 = [NSArray arrayWithObject:m_sessionId];
			numParams = 1;
		}
	}

	const char *tmpl =
		"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\r\n"
		"<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">\r\n"
		"<SOAP-ENV:Header>\r\n"
		"<SessionID>%@</SessionID>\r\n"
		"</SOAP-ENV:Header>\r\n"
		"<SOAP-ENV:Body>\r\n"
		"%@\r\n"
		"</SOAP-ENV:Body>\r\n"
		"</SOAP-ENV:Envelope>";

	const char *body1 =
		"<M1:%@ xmlns:M1=\"%@\">\r\n"
		"%@"
		"</M1:%@>";

	const char *body2 =
		"<%@>\r\n"
		"%@"
		"</%@>";

	NSMutableString *paramXml = [NSMutableString string];
	if (names1 != nil) {
		for (NSUInteger i = 0; i != numParams; i++) {
			NSString *paramName = [names1 objectAtIndex:i];
			NSString *paramValue = [values1 objectAtIndex:i];
			[paramXml appendFormat:@"  <%@>%@</%@>\r\n", paramName, paramValue, paramName];
		}
	}

	NSMutableString *bodyXml = [NSMutableString string];
	if (actionNS) {
		[bodyXml appendFormat:[NSString stringWithUTF8String:body1], action, service, paramXml, action];
	} else {
		[bodyXml appendFormat:[NSString stringWithUTF8String:body2], action, paramXml, action];
	}

	NSMutableString *soapXml = [NSMutableString stringWithFormat:[NSString stringWithUTF8String:tmpl], m_sessionId, bodyXml];

	NSString *soapAction = [NSString stringWithFormat:@"\"%@#%@\"", service, action];

	NSLog(@"%@", soapAction);
	NSLog(@"%@", soapXml);

	const char *soapText = [soapXml UTF8String];
	int soapTextLen = strlen(soapText);

	NSURL *url;
	if (port == 80) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", m_localUrl, m_localPath]];
		//url = [NSURL URLWithString:@"http://routerlogin.net/soap/server_sa/"];
	} else {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%d%@", m_localUrl, port, m_localPath]];
		//url = [NSURL URLWithString:[NSString stringWithFormat:@"http://routerlogin.net:%d/soap/server_sa/", port]];
	}

	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
	[req setHTTPMethod:@"POST"];
	[req setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
	[req setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
	[req setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[req setValue:[NSString stringWithFormat:@"%d", soapTextLen] forHTTPHeaderField:@"Content-Length"];
	//[req setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
	//[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setHTTPBody:[NSData dataWithBytes:soapText length:soapTextLen]];

	GTBasicSoap *soap = [[GTBasicSoap alloc] initWithCore:self request:req action:action];
	[req release];
	[soap start];
	return [soap autorelease];
}

@end

@implementation GTBaseAsyncOp

- (id)init
{
	self = [super init];
	if (self) {
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

@implementation GTBasicSoap

- (id)initWithCore:(GTSoapCoreImpl *)core request:(NSURLRequest *)req action:(NSString*)action
{
	self = [super init];
	if (self) {
		m_core = [core retain];
		m_conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
		m_data = [[NSMutableData alloc] init];
		m_result = [[NSMutableDictionary alloc] init];
		m_action = [action retain];
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
	[m_action release];
	[m_target release];
	[m_result release];
	[m_data release];
	[m_conn release];
	[m_core release];
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
	NSString *resultXml = [[[NSString alloc] initWithData:m_data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", resultXml);

	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:m_data] autorelease];
	[parser setShouldProcessNamespaces:YES];
	GTSoapResultExtractor *extractor = [[GTSoapResultExtractor alloc] initWithAction:m_action soap:self];
	[parser setDelegate:extractor];
	if ([parser parse]) {
		m_succeeded = YES;
		NSString *resp = [m_result objectForKey:@"ResponseCode"];
		if (resp) {
			m_responseCode = [resp intValue];
		}
	} else {
		m_succeeded = NO;
	}
	[extractor release];
	[self notifyFinished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);
	m_succeeded = NO;
	[self notifyFinished];
}

- (void)internalSetL3String:(NSString*)string forKey:(NSString*)key
{
	[m_result setObject:[NSString stringWithString:string] forKey:key];
	NSLog(@"GP [%@]=[%@]", key, string);
}

- (void)internalSetL4String:(NSString*)string forKey:(NSString*)key
{
	[m_result setObject:[NSString stringWithString:string] forKey:key];
	NSLog(@"L4 [%@]=[%@]", key, string);
}

@end

@implementation GTFallbackSoap

- (id)initWithCore:(GTSoapCoreImpl*)core ports:(NSArray*)ports service:(NSString *)service action:(NSString *)action names:(NSArray *)names values:(NSArray *)values
{
	self = [super init];
	if (self) {
		m_core = [core retain];
		m_ports = [[NSMutableArray alloc] initWithArray:ports];
		m_service = [service retain];
		m_action = [action retain];
		m_names = [names retain];
		m_values = [values retain];
		m_result = [[NSMutableDictionary alloc] init];
		m_soap = nil;
		m_aborted = NO;
		m_finished = NO;
		m_succeeded = NO;
		m_responseCode = -1;
		m_target = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_target release];
	[m_soap release];
	[m_result release];
	[m_values release];
	[m_names release];
	[m_action release];
	[m_service release];
	[m_ports release];
	[m_core release];
	[super dealloc];
}

- (void)start
{
	m_activePort = [[m_ports objectAtIndex:0] intValue];
	[m_ports removeObjectAtIndex:0];
	m_soap = [m_core invokeBasicAction:m_activePort service:m_service action:m_action names:m_names values:m_values];
	[m_soap retain];
	[m_soap setFinishCallback:self selector:@selector(soapFinishCallback:)];
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

- (void)soapFinishCallback:(GTAsyncOp*)op
{
	if (m_aborted) {
		NSLog(@"aborted %d", m_activePort);
		return;
	}

	[m_soap release];
	m_soap = nil;

	if ([op succeeded]) {
		m_succeeded = YES;
		m_responseCode = [op responseCode];
		[m_result addEntriesFromDictionary:[op result]];
		[m_core adjustPort:m_activePort];
		[self notifyFinished];
	} else {
		if ([m_ports count] > 0) {
			[self start];
		} else {
			m_succeeded = NO;
			[self notifyFinished];
		}
	}
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
		[m_soap abort];
		[m_soap release];
		m_soap = nil;
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

@end

@implementation GTWrappedSoap

- (id)initWithCore:(GTSoapCoreImpl *)core service:(NSString *)service action:(NSString *)action names:(NSArray *)names values:(NSArray *)values
{
	self = [super init];
	if (self) {
		m_core = [core retain];
		m_service = [service retain];
		m_action = [action retain];
		m_names = [names retain];
		m_values = [values retain];
		m_result = [[NSMutableDictionary alloc] init];
		m_soap = nil;
		m_aborted = NO;
		m_finished = NO;
		m_succeeded = NO;
		m_responseCode = -1;
		m_target = nil;
		m_configStartRetryCount = 2;
		m_callConfigFinish = YES;
		m_finishStatus = [[NSString alloc] initWithString:@"ChangesApplied"];
	}
	return self;
}

- (void)dealloc
{
	[m_finishStatus release];
	[m_target release];
	[m_soap release];
	[m_result release];
	[m_values release];
	[m_names release];
	[m_action release];
	[m_service release];
	[m_core release];
	[super dealloc];
}

- (void)start
{
	m_soap = [m_core invokeAction:@"urn:NETGEAR-ROUTER:service:DeviceConfig:1" action:@"ConfigurationStarted" names:nil values:nil];
	[m_soap retain];
	[m_soap setFinishCallback:self selector:@selector(soapFinishCallback1:)];
}

- (void)soapFinishCallback1:(GTAsyncOp*)op
{
	if (m_aborted) {
		return;
	}

	[m_soap release];
	m_soap = nil;

	if ([op succeeded]) {
		if ([op responseCode] == 0) {
			m_soap = [m_core invokeAction:m_service action:m_action names:m_names values:m_values];
			[m_soap retain];
			[m_soap setFinishCallback:self selector:@selector(soapFinishCallback2:)];
		} else {
			if (m_configStartRetryCount > 0) {
				--m_configStartRetryCount;
				[self start];
			} else {
				m_succeeded = YES;
				m_responseCode = [op responseCode];
				[self notifyFinished];
			}
		}
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)soapFinishCallback2:(GTAsyncOp*)op
{
	if (m_aborted) {
		return;
	}
	
	[m_soap release];
	m_soap = nil;

	if ([op succeeded]) {
		m_responseCode = [op responseCode];
		[m_result addEntriesFromDictionary:[op result]];
		if (m_callConfigFinish) {
			m_soap = [m_core invokeAction:@"urn:NETGEAR-ROUTER:service:DeviceConfig:1" action:@"ConfigurationFinished" names:[NSArray arrayWithObject:@"NewStatus"] values:[NSArray arrayWithObject:m_finishStatus]];
			[m_soap retain];
			[m_soap setFinishCallback:self selector:@selector(soapFinishCallback3:)];
		} else {
			m_succeeded = YES;
			[self notifyFinished];
		}
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
}

- (void)soapFinishCallback3:(GTAsyncOp*)op
{
	if (m_aborted) {
		return;
	}

	[m_soap release];
	m_soap = nil;
	
	if ([op succeeded]) {
		m_succeeded = YES;
		[self notifyFinished];
	} else {
		m_succeeded = NO;
		[self notifyFinished];
	}
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
		[m_soap abort];
		[m_soap release];
		m_soap = nil;
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

@end
