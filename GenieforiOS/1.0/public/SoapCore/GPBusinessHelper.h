//
//  GPBusinessHelper.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPBusinessCore.h"
#import "GTAsyncOp.h"
@interface GPBusinessHelper : GPBusinessCore
- (id) initWithSoapHelper:(FXSoapHelper *)soapHelper LPCHelper:(DCWebApi *)lpcHelper GWebInfoHelper:(GWebInfoHelper *)webInfoHelper;
- (GTAsyncOp*) startGetSmartNetworkList;

- (GTAsyncOp*) startRouterLoginWithAdmin:(NSString*)admin password:(NSString*) password;//登陆本地路由器接口
- (GTAsyncOp*) startRouterLoginWithAdmin:(NSString *)admin password:(NSString *)password controlPointID:(NSString*)controlPointID;//登陆远程路由器接口
- (GTAsyncOp*) startGetRouterInfo;
- (GTAsyncOp*) startGetWirelessInfo;
- (GTAsyncOp*) startGetGuestInfo;
- (GTAsyncOp*) startGetTrafficInfo;
- (GTAsyncOp*) startGetNetworkMapInfo;
- (GTAsyncOp*) startAutoLoginLPC:(NSString*)routerAdmin routerPassword:(NSString*) password openDNSAccount:(NSString*)account openDNSPassword:(NSString*)openDNSKey deviceKey:(NSString*)deviceKey;
- (GTAsyncOp*) startPingOpenDNSHost;
- (GTAsyncOp*) startQueryLpcInfo:(NSString*)routerAdmin routerPassword:(NSString*) password openDNSAccount:(NSString*)account openDNSPassword:(NSString*)openDNSKey deviceKey:(NSString*)deviceKey;
- (GTAsyncOp*) startGetLPCAccountRelay:(NSString*)token;
- (GTAsyncOp*) startCreateOpenDNSUserName:(NSString*)userName password:(NSString*)password email:(NSString*)email;
////
- (GTAsyncOp*) startSetWirelessInfoNeedSecurityWithSsid:(NSString*) ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode securityMode:(NSString*)securitymode WPAPassPhrase:(NSString*)phrase;
- (GTAsyncOp*) startSetWirelessInfoNoSecurityWithSsid:(NSString*) ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode;

- (GTAsyncOp*) startCloseGuestAccess;
- (GTAsyncOp*) startOpenGuestAccessSSID:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4;
- (GTAsyncOp*) startSetGuestAccessNetworkSSID:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4;


- (GTAsyncOp*) startSetEnableBlockStatusOn;
- (GTAsyncOp*) startSetEnableBlockStatusOff;
- (GTAsyncOp*) startSetDeviceBlocked:(NSString*)deviceMac;
- (GTAsyncOp*) startSetDeviceAllow:(NSString*)deviceMac;
- (GTAsyncOp*) startOpenTrafficMeter;
- (GTAsyncOp*) startCloseTrafficMeter;
- (GTAsyncOp*) startSetTrafficMeterOptionWithControlMode:(NSString*)controlMode monthlyLimit:(NSString*)monthlyLimit counterRestartDay:(NSString*)day hour:(NSString*)hour minute:(NSString*)minute;
- (GTAsyncOp*) startOpenParentalControlsWithRouterAdmin:(NSString*)admin password:(NSString*)password token:(NSString*)token deviceID:(NSString*)deviceId;
- (GTAsyncOp*) startCloseParentalControlsWithRouterAdmin:(NSString*)admin password:(NSString*)password;
- (GTAsyncOp*) startSetParentalControlsFilterLevel:(NSString*)token deviceID:(NSString*)deviceId bundel:(NSString*)bundle;

- (GTAsyncOp*) startGetLPCByPassAccoutInfo:(NSString*)deviceID mac:(NSString*) mac;
- (GTAsyncOp*) startLoginLPCByPassAccount:(NSString*)admin routerPassword:(NSString*)routerPassword account:(NSString*)account password:(NSString*) password parentalDeviceID:(NSString*) deviceid mac:(NSString*)localmac;
- (GTAsyncOp*) startLogoutLPCByPassAccount:(NSString*)admin password:(NSString*) password  mac:(NSString*) localMac;
@end
