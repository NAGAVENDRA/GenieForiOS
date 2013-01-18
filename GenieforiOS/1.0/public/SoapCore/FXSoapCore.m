//
//  FXSoapCore.m
//  MobDemo
//
//  Created by yiyang on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "FXSoapCore.h"

@interface SoapResultExtractor : NSObject <NSXMLParserDelegate>
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
	FXSoap *m_soap;
}

@end

@implementation SoapResultExtractor

- (id)initWithAction:(NSString*)action soap:(FXSoap*)soap
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

@implementation FXSoap

- (id)init
{
	self = [super init];
	if (self) {
		m_conn = nil;
		m_aborted = NO;
		m_finished = NO;
		m_data = [[NSMutableData alloc] init];
		m_action = [[NSMutableString alloc] init];
		m_allValues = [[NSMutableDictionary alloc] init];
		m_fallbackPorts = [[NSMutableArray alloc] init];
		m_responseCode = -1;
		m_req = nil;
		m_soapCore = nil;
	}
	return self;
}

- (void)dealloc
{
	[m_soapCore release];
	[m_fallbackPorts release];
	[m_req release];
	[m_allValues release];
	[m_action release];
	[m_target release];
	[m_conn release];
	[m_data release];
	[super dealloc];
}

- (void)notifyFinished
{
	if (!m_finished) {
		m_finished = YES;
		if (m_conn) {
			[m_conn release];
			m_conn = nil;
		}
		if (m_target) {
            if (!m_aborted)
            {
                [m_target performSelector:m_selector withObject:self];
            }
			[m_target release];
			m_target = nil;
		}
		if (m_soapCore) {
			[m_soapCore release];
			m_soapCore = nil;
		}
	}
}

- (void)abort
{
	if (!m_finished && !m_aborted) {
		[m_conn cancel];
		m_aborted = YES;
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
	return !m_errorFlag;
}

- (void)setFinishCallback:(id)target selector:(SEL)aSelector;
{
	[target retain];
	[m_target release];
	m_target = target;
	m_selector = aSelector;
}

- (BOOL)contains:(NSString*)key
{
	return [[m_allValues allKeys] containsObject:key];
}

- (NSString*)stringForKey:(NSString*)key
{
	return [m_allValues objectForKey:key];
}

- (int)responseCode
{
	return m_responseCode;
}

- (NSDictionary*) resultDict
{
	return m_allValues;
}

- (void)internalSetL3String:(NSString*)string forKey:(NSString*)key
{
	[m_allValues setObject:string forKey:key];
	NSLog(@"GP [%@]=[%@]", key, string);
}

- (void)internalSetL4String:(NSString*)string forKey:(NSString*)key
{
	[m_allValues setObject:string forKey:key];
	NSLog(@"L4 [%@]=[%@]", key, string);
}

- (void)start:(NSString*)service action:(NSString*)action request:(NSMutableURLRequest*)req core:(FXSoapCore*)core ports:(NSArray*)ports;
{
	m_conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
	[m_action setString:action];
	[req retain];
	m_req = req;
	[core retain];
	m_soapCore = core;
	m_activePort = [[[req URL] port] intValue];
	if (m_activePort == 0) {
		m_activePort = 80;
	}
	[m_fallbackPorts addObjectsFromArray:ports];
	[m_conn start];
}

- (void)retry
{
	if ([m_fallbackPorts count] > 0) {
		NSNumber *num = [m_fallbackPorts objectAtIndex:0];
		int portNum = [num intValue];
		[m_fallbackPorts removeObjectAtIndex:0];
		if (m_conn) {
			[m_conn release];
		}
		[m_data setData:[NSData data]];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://routerlogin.net:%d/soap/server_sa/", portNum]];
		[m_req setURL:url];
		m_conn = [[NSURLConnection alloc] initWithRequest:m_req delegate:self startImmediately:NO];
		m_activePort = portNum;
		[m_conn start];
	} else {
		m_errorFlag = YES;
		[self notifyFinished];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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
	SoapResultExtractor *extractor = [[SoapResultExtractor alloc] initWithAction:m_action soap:self];
	[parser setDelegate:extractor];
	if ([parser parse]) {
		[extractor release];
		m_errorFlag = NO;
		NSString *resp = [m_allValues objectForKey:@"ResponseCode"];
		if (resp) {
			m_responseCode = [resp intValue];
		}
		[m_soapCore internalNotifyPort:m_activePort];
		[self notifyFinished];
	} else {
		[extractor release];
		[self retry];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);
	[self retry];
}

@end

@implementation FXSoapCore

- (id)init
{
	return [self initWithSessionId:nil];
}

- (id)initWithSessionId:(NSString*)sessionId
{
	self = [super init];
	if (self) {
		m_sessionId = [[NSMutableString alloc] init];
		[self setSessionId:sessionId];
		m_portList = [[NSMutableArray alloc] init];
		//[m_portList addObject:[NSNumber numberWithInt:6000]];
		//[m_portList addObject:[NSNumber numberWithInt:4000]];
		//[m_portList addObject:[NSNumber numberWithInt:3000]];
		[m_portList addObject:[NSNumber numberWithInt:80]];
		[m_portList addObject:[NSNumber numberWithInt:5000]];
		m_activePort = -1;
	}
	return self;
}

- (void)setSessionId:(NSString*)sessionId
{
	if (sessionId) {
		[m_sessionId setString:sessionId];
	} else {
		[m_sessionId setString:@"E6A88AE69687E58D9K77"];
	}
}

- (void)dealloc
{
	[m_sessionId release];
	[super dealloc];
}

- (void)internalNotifyPort:(int)port
{
	m_activePort = port;
}

- (FXSoap*)invoke:(NSString*)service action:(NSString*)action
{
	return [self invoke:service action:action names:nil values:nil];
}

- (FXSoap*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values port:(int)port
{
	NSUInteger numParams = [names count];
	if (numParams != [values count]) {
		return nil;
	}
	if (names != values && (names == nil || values == nil)) {
		return nil;
	}
	
	BOOL actionNS = YES;
	if ([service isEqualToString:@"urn:NETGEAR-ROUTER:service:ParentalControl:1"] && [action isEqualToString:@"Authenticate"]) {
		actionNS = NO;
	}

	NSArray *names1 = names;
	NSArray *values1 = values;
	
	if ([service isEqualToString:@"urn:NETGEAR-ROUTER:service:DeviceConfig:1"] && [action isEqualToString:@"ConfigurationStarted"]) {
		if (names != nil && [[names objectAtIndex:0] isEqualToString:@"NewSessionID"]) {
			NSString *sessionId = [values objectAtIndex:0];
			[self setSessionId:sessionId];
		} else if (names == nil && values == nil) {
			names1 = [NSArray arrayWithObject:@"NewSession"];
			values1 = [NSArray arrayWithObject:m_sessionId];
			numParams = 1;
		}
	}
	
	NSMutableString *soapXml = [NSMutableString string];
	[soapXml appendString:@"<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
	//[soapXml appendFormat:@"<SOAP-ENV:Header><SessionID xsi:type=\"xsd:string\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\">%@</SessionID></SOAP-ENV:Header>", m_sessionId];
	[soapXml appendFormat:@"<SOAP-ENV:Header><SessionID>%@</SessionID></SOAP-ENV:Header>", m_sessionId];
	[soapXml appendString:@"<SOAP-ENV:Body>"];
	if (actionNS) {
		[soapXml appendFormat:@"<M1:%@ xmlns:M1=\"%@\">", action, service];
	} else {
		[soapXml appendFormat:@"<%@>", action];
	}
	if (names1 != nil) {
		for (NSUInteger i = 0; i != numParams; i++) {
			NSString *paramName = [names1 objectAtIndex:i];
			NSString *paramValue = [values1 objectAtIndex:i];
//			[soapXml appendFormat:@"<%@ xsi:type=\"xsd:string\" xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\">%@</%@>", paramName, paramValue, paramName];
			[soapXml appendFormat:@"<%@>%@</%@>", paramName, paramValue, paramName];
		}
	}
	if (actionNS) {
		[soapXml appendFormat:@"</M1:%@>", action];
	} else {
		[soapXml appendFormat:@"</%@>", action];
	}
	[soapXml appendString:@"</SOAP-ENV:Body>"];
	[soapXml appendString:@"</SOAP-ENV:Envelope>"];

	NSString *soapAction = [NSString stringWithFormat:@"\"%@#%@\"", service, action];

	NSLog(@"%@", soapAction);
	NSLog(@"%@", soapXml);

	const char *soapText = [soapXml UTF8String];
	int soapTextLen = strlen(soapText);
	
	if (m_activePort != -1) {
		port = m_activePort;
	}

	NSURL *url;
	if (port == 80) {
		url = [NSURL URLWithString:@"http://routerlogin.net/soap/server_sa/"];
	} else {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://routerlogin.net:%d/soap/server_sa/", port]];
	}

	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
	[req setHTTPMethod:@"POST"];
	[req setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
	[req setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
	[req setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[req setValue:[NSString stringWithFormat:@"%d", soapTextLen] forHTTPHeaderField:@"Content-Length"];
	[req setHTTPBody:[NSData dataWithBytes:soapText length:soapTextLen]];

	FXSoap *soap = [[FXSoap alloc] init];
	[soap start:service action:action request:req core:self ports:m_portList];
	[req release];
	[soap autorelease];
	return soap;
}

- (FXSoap*)invoke:(NSString*)service action:(NSString*)action names:(NSArray*)names values:(NSArray*)values
{
	return [self invoke:service action:action names:names values:values port:5000];
}

@end

