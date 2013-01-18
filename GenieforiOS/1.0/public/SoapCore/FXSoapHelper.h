//
//  FXSoapHelper.h
//  MobDemo
//
//  Created by yiyang on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTSoapCore.h"

@interface FXSoapHelper : GTSoapCore

- (GTAsyncOp*) DeviceInfo_GetInfo;
- (GTAsyncOp*) DeviceInfo_GetAttachDevice;


//
- (GTAsyncOp*) WLANConfiguration_GetInfo;
- (GTAsyncOp*) WLANConfiguration_GetWPASecurityKeys;
- (GTAsyncOp*) WLANConfiguration_GetWEPSecurityKeys;
- (GTAsyncOp*) WLANConfiguration_GetGuestAccessEnabled;
- (GTAsyncOp*) WLANConfiguration_GetGuestAccessNetworkInfo;


- (GTAsyncOp*) WLANConfiguration_SetWLANNoSecurityWithSSID:(NSString*)ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode;
- (GTAsyncOp*) WLANConfiguration_SetWLANWPAPSKByPassphraseWithSSID:(NSString*)ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode securityMode:(NSString*)securitymode WPAPassPhrase:(NSString*)phrase;
- (GTAsyncOp*) WLANConfiguration_SetGuedtAccessEnabled;//close access func
- (GTAsyncOp*) WLANConfiguration_SetGuestAccessEnabled2ssid:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4;//open access func and config 
- (GTAsyncOp*) WLANConfiguration_SetGuestAccessNetworkSsid:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4;//config access



- (GTAsyncOp*) DeviceConfig_ConfigurationStarted:(NSString*)NewSessionID;
- (GTAsyncOp*) DeviceConfig_ConfigurationFinished:(NSString*)NewStatus;
- (GTAsyncOp*) DeviceConfig_GetTrafficMeterEnabled;
- (GTAsyncOp*) DeviceConfig_GetTrafficMeterOptions;
- (GTAsyncOp*) DeviceConfig_GetTrafficMeterStartistics;
- (GTAsyncOp*) DeviceConfig_GetBlockDeviceEnableStatus;
- (GTAsyncOp*) DeviceConfig_EnableBlockDeviceForAll;
- (GTAsyncOp*) DeviceConfig_SetBlockDeviceEnable:(NSString*)enable;
- (GTAsyncOp*) DeviceConfig_SetBlockDeviceByMAC:(NSString*)macAddr block:(NSString*)block;
- (GTAsyncOp*) DeviceConfig_EnableTrafficMeter:(NSString*)enable;//@"0"  or  @"1"
- (GTAsyncOp*) DeviceConfig_SetTrafficMeterOptionsControlMode:(NSString*)controlMode monthlyLimit:(NSString*)monthlyLimit restartHour:(NSString*)hour minute:(NSString*)minute day:(NSString*)day;

- (GTAsyncOp*) ParentalControl_Authenticate:(NSString*)NewUsername NewPassword:(NSString*)NewPassword;
- (GTAsyncOp*) ParentalControl_GetDNSMasqDeviceID;
- (GTAsyncOp*) ParentalControl_GetDNSMasqDeviceIDForChild:(NSString*)mac;//bypass account
- (GTAsyncOp*) ParentalControl_SetDNSMasqDeviceID:(NSString*)deviceID;
- (GTAsyncOp*) ParentalControl_SetDNSMasqDeviceID:(NSString *)deviceID mac:(NSString*) mac;//bypass account
- (GTAsyncOp*) ParentalControl_GetEnableStatus;
- (GTAsyncOp*) ParentalControl_EnableParentalControl:(NSString *)enable;
- (GTAsyncOp*) ParentalControl_DeleteMACAddress:(NSString*)mac;

@end

