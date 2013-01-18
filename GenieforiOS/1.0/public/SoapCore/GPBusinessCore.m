//
//  GPBussinessCore.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPBusinessCore.h"



@implementation GPBusinessCore
@synthesize soapHelper = m_soapHelper;
@synthesize lpcHelper = m_lpcHelper;
@synthesize webInfoHelper = m_getWebInfoHelper;

- (id) init
{
    return [self initWithSoapHelper:nil LPCHelper:nil GWebInfoHelper:nil];
}
- (id) initWithSoapHelper:(FXSoapHelper*)soapHelper LPCHelper:(DCWebApi*)lpcHelper GWebInfoHelper:(GWebInfoHelper*)webInfoHelper
{
    self = [super init];
    if (self)
    {
        if (!soapHelper)
        {
            m_soapHelper = [[FXSoapHelper alloc] init];
        }
        else
        {
            m_soapHelper = soapHelper;
            [m_soapHelper retain];
        }
        if (!lpcHelper)
        {
            m_lpcHelper = [[DCWebApi alloc] init];
        }
        else
        {
            m_lpcHelper = lpcHelper;
            [m_lpcHelper retain];
        }
        if (!webInfoHelper)
        {
            m_getWebInfoHelper = [[GWebInfoHelper alloc] init];
        }
        else
        {
            m_getWebInfoHelper = [webInfoHelper retain];
        }
    }
    return self;
}

- (void) dealloc
{
    [m_getWebInfoHelper release];
    [m_lpcHelper release];
    [m_soapHelper release];
    [super dealloc];
}

- (void)setSoapWrapMode:(BOOL)wrap
{
    [m_soapHelper setWrapMode:wrap];
}

- (BOOL)wrapMode
{
    return [m_soapHelper wrapMode];
}

@end
