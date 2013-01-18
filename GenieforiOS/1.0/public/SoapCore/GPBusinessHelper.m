//
//  GPBusinessHelper.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPBusinessHelper.h"
#import "GPBusinessImpl.h"


@implementation GPBusinessHelper
- (id) initWithSoapHelper:(FXSoapHelper *)soapHelper LPCHelper:(DCWebApi *)lpcHelper GWebInfoHelper:(GWebInfoHelper *)webInfoHelper
{
    return [super initWithSoapHelper:soapHelper LPCHelper:lpcHelper GWebInfoHelper:webInfoHelper];
}

- (GTAsyncOp*) startGetSmartNetworkList
{
    return [[[GPGetSNRouterListOp alloc] initWithCore:self] autorelease];
}

- (GTAsyncOp*) startRouterLoginWithAdmin:(NSString*)admin password:(NSString*) password
{
    return [self startRouterLoginWithAdmin:admin password:password controlPointID:@""];
}
- (GTAsyncOp*) startRouterLoginWithAdmin:(NSString *)admin password:(NSString *)password controlPointID:(NSString*)controlPointID
{
    return [[[GPRouterLoginOp alloc] initWithCore:self admin:admin password:password controlPointID:controlPointID] autorelease];
}

- (GTAsyncOp*) startGetRouterInfo
{
    return [[[GPGetRouterInfoOp alloc] initWithCore:self] autorelease];
}

- (GTAsyncOp*) startGetWirelessInfo
{
    return [[[GPGetWirelessOp alloc] initWithCore:self] autorelease];
}
- (GTAsyncOp*) startGetGuestInfo
{
    return [[[GPGetGuestOp alloc] initWithCore:self] autorelease];
}

- (GTAsyncOp*) startGetTrafficInfo
{
    return [[[GPGetTrafficOp alloc] initWithCore:self] autorelease];
}

- (GTAsyncOp*) startGetNetworkMapInfo
{
    return [[[GPGetNetworkMapOp alloc] initWithCore:self] autorelease];
}
- (GTAsyncOp*) startAutoLoginLPC:(NSString*)routerAdmin routerPassword:(NSString*) password openDNSAccount:(NSString*)account openDNSPassword:(NSString*)openDNSKey deviceKey:(NSString*)deviceKey
{
    return [[[GPLPCAutoLoginOp alloc] initWithCore:self admin:routerAdmin password:password openDNSAccount:account openDNSKey:openDNSKey deviceKey:deviceKey autoLogin:YES] autorelease];
}
- (GTAsyncOp*) startPingOpenDNSHost
{
    return [[[GPLPCAutoLoginOp alloc] initWithCore:self admin:nil password:nil openDNSAccount:nil openDNSKey:nil deviceKey:nil autoLogin:NO] autorelease];
}
- (GTAsyncOp*) startQueryLpcInfo:(NSString*)routerAdmin routerPassword:(NSString*) password openDNSAccount:(NSString*)account openDNSPassword:(NSString*)openDNSKey deviceKey:(NSString*)deviceKey
{
    return [[[GPQueryLpcInfoOp alloc] initWithCore:self admin:routerAdmin password:password openDNSAccount:account openDNSKey:openDNSKey deviceKey:deviceKey] autorelease];
}
- (GTAsyncOp*) startGetLPCAccountRelay:(NSString*)token
{
    return [[[GPGetLPCAccountRelayOp alloc] initWithCore:self token:token] autorelease];
}
- (GTAsyncOp*) startCreateOpenDNSUserName:(NSString*)userName password:(NSString*)password email:(NSString*)email
{
    return [[[GPLPCCreateAccountOp alloc] initWithCore:self userName:userName password:password email:email] autorelease];
}

//////////
- (GTAsyncOp*) startSetWirelessInfoNeedSecurityWithSsid:(NSString*) ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode securityMode:(NSString*)securitymode WPAPassPhrase:(NSString*)phrase
{
    return  [[[GPSetWirelessOp alloc] initWithCore:self ssid:ssid region:region channel:channel wirelessMode:wirelessMode securityMode:securitymode WPAPassPhrase:phrase] autorelease];
}

- (GTAsyncOp*) startSetWirelessInfoNoSecurityWithSsid:(NSString*) ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode
{
    return [self startSetWirelessInfoNeedSecurityWithSsid:ssid region:region channel:channel wirelessMode:wirelessMode securityMode:nil WPAPassPhrase:nil];
}


- (GTAsyncOp*) startCloseGuestAccess
{
    return [[[GPSetGuestOp alloc] initWithCore:self enable:@"0" ssid:nil securityMode:nil key1:nil key2:nil key3:nil key4:nil] autorelease];
}
- (GTAsyncOp*) startOpenGuestAccessSSID:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4
{
    return [[[GPSetGuestOp alloc] initWithCore:self enable:@"1" ssid:ssid securityMode:securityMode key1:k1 key2:k2 key3:k3 key4:k4] autorelease];
}
- (GTAsyncOp*) startSetGuestAccessNetworkSSID:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4
{
    return [[[GPSetGuestOp alloc] initWithCore:self enable:nil ssid:ssid securityMode:securityMode key1:k1 key2:k2 key3:k3 key4:k4] autorelease];
}


- (GTAsyncOp*) startSetEnableBlockStatusOn
{
    return [[[GPSetEnableBlockStatusOp alloc] initWithCore:self enable:@"1"] autorelease];
}
- (GTAsyncOp*) startSetEnableBlockStatusOff
{
    return [[[GPSetEnableBlockStatusOp alloc] initWithCore:self enable:@"0"] autorelease];
}
- (GTAsyncOp*) startSetDeviceBlocked:(NSString*)deviceMac
{
    return [[[GPSetDeviceBlockOrAllowOp alloc] initWithCore:self macAddr:deviceMac allowOrBlock:@"Block"] autorelease];
}
- (GTAsyncOp*) startSetDeviceAllow:(NSString*)deviceMac
{
    return [[[GPSetDeviceBlockOrAllowOp alloc] initWithCore:self macAddr:deviceMac allowOrBlock:@"Allow"] autorelease];
}
- (GTAsyncOp*) startOpenTrafficMeter
{
    return [[[GPSetTrafficOp alloc] initWithCore:self enable:@"1" controlMode:nil monthlyLimit:nil restartDay:nil hour:nil minute:nil] autorelease];
}
- (GTAsyncOp*) startCloseTrafficMeter
{
    return [[[GPSetTrafficOp alloc] initWithCore:self enable:@"0" controlMode:nil monthlyLimit:nil restartDay:nil hour:nil minute:nil] autorelease];
}
- (GTAsyncOp*) startSetTrafficMeterOptionWithControlMode:(NSString*)controlMode monthlyLimit:(NSString*)monthlyLimit counterRestartDay:(NSString*)day hour:(NSString*)hour minute:(NSString*)minute
{
    return [[[GPSetTrafficOp alloc] initWithCore:self enable:nil controlMode:controlMode monthlyLimit:monthlyLimit restartDay:day hour:hour minute:minute] autorelease];
}

- (GTAsyncOp*) startOpenParentalControlsWithRouterAdmin:(NSString*)admin password:(NSString*)password token:(NSString*)token deviceID:(NSString*)deviceId
{
    return [[[GPSetLPCEnableOp alloc] initWithCore:self enable:YES admin:admin password:password token:token deviceID:deviceId] autorelease];
}
- (GTAsyncOp*) startCloseParentalControlsWithRouterAdmin:(NSString*)admin password:(NSString*)password
{
    return [[[GPSetLPCEnableOp alloc] initWithCore:self enable:NO admin:admin password:password token:nil deviceID:nil] autorelease];
}
- (GTAsyncOp*) startSetParentalControlsFilterLevel:(NSString*)token deviceID:(NSString*)deviceId bundel:(NSString*)bundle
{
    return [[[GPSetLPCFilterOp alloc] initWithCore:self token:token deviceID:deviceId bundle:bundle] autorelease];
}

- (GTAsyncOp*) startGetLPCByPassAccoutInfo:(NSString*)deviceID mac:(NSString*) mac
{
    return [[[GPGetLPCBypassAccountInfo alloc] initWithCore:self deviceID:deviceID mac:mac] autorelease];
}

- (GTAsyncOp*) startLoginLPCByPassAccount:(NSString*)admin routerPassword:(NSString*)routerPassword account:(NSString*)account password:(NSString*) password parentalDeviceID:(NSString*) deviceid mac:(NSString*)localmac
{
    return [[[GPLoginLPCBypassAccoutOp alloc] initWithCore:self routerAdmin:admin routerPassword:routerPassword account:account password:password parentalDeviceID:deviceid mac:localmac] autorelease];
}
- (GTAsyncOp*) startLogoutLPCByPassAccount:(NSString*)admin password:(NSString*) password  mac:(NSString*) localMac
{
    return [[[GPLogoutLPCBypassAccountOp alloc] initWithCore:self routerAdmin:admin routerPassword:password mac:localMac ] autorelease];
}
@end
