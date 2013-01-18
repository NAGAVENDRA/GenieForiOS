//
//  FXSoapHelper.m
//  MobDemo
//
//  Created by yiyang on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "FXSoapHelper.h"

@implementation FXSoapHelper
#define Service(service_name)  @"urn:NETGEAR-ROUTER:service:"service_name@":1"
NSString *NS_DEVICE_INFO = Service(@"DeviceInfo");
NSString *NS_WLAN_CONFIGURATION = Service(@"WLANConfiguration");
NSString *NS_DEVICE_CONFIG = Service(@"DeviceConfig");
NSString *NS_PARENTAL_CONTROL = Service(@"ParentalControl");

//////
- (GTAsyncOp*)DeviceInfo_GetInfo
{
	return [self invoke:NS_DEVICE_INFO action:@"GetInfo"];
}

- (GTAsyncOp*)DeviceInfo_GetAttachDevice
{
    return [self invoke:NS_DEVICE_INFO action:@"GetAttachDevice"];
}
///////
- (GTAsyncOp*)WLANConfiguration_GetInfo
{
	return [self invoke:NS_WLAN_CONFIGURATION action:@"GetInfo"];
}
- (GTAsyncOp*)WLANConfiguration_GetWPASecurityKeys
{
	return [self invoke:NS_WLAN_CONFIGURATION action:@"GetWPASecurityKeys"];
}
- (GTAsyncOp*)WLANConfiguration_GetWEPSecurityKeys
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"GetWEPSecurityKeys"];
}
- (GTAsyncOp*)WLANConfiguration_GetGuestAccessEnabled
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"GetGuestAccessEnabled"];
}
- (GTAsyncOp*)WLANConfiguration_GetGuestAccessNetworkInfo
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"GetGuestAccessNetworkInfo"];
}



- (GTAsyncOp*)WLANConfiguration_SetWLANNoSecurityWithSSID:(NSString*)ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"SetWLANNoSecurity" names:[NSArray arrayWithObjects:@"NewSSID",@"NewRegion",@"NewChannel",@"NewWirelessMode",nil] values:[NSArray arrayWithObjects:ssid,region,channel,wirelessMode,nil]];
}
- (GTAsyncOp*)WLANConfiguration_SetWLANWPAPSKByPassphraseWithSSID:(NSString*)ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode securityMode:(NSString*)securitymode WPAPassPhrase:(NSString*)phrase
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"SetWLANWPAPSKByPassphrase" names:[NSArray arrayWithObjects:@"NewSSID",@"NewRegion",@"NewChannel",@"NewWirelessMode",@"NewWPAEncryptionModes",@"NewWPAPassphrase",nil] values:[NSArray arrayWithObjects:ssid,region,channel,wirelessMode,securitymode,phrase,nil]];
}

- (GTAsyncOp*)WLANConfiguration_SetGuedtAccessEnabled//close access func
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"SetGuestAccessEnabled" name:@"NewGuestAccessEnabled" value:@"0"];
}
- (GTAsyncOp*) WLANConfiguration_SetGuestAccessEnabled2ssid:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4//open access func and config
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"SetGuestAccessEnabled2" names:[NSArray arrayWithObjects:@"NewGuestAccessEnabled",@"NewSSID",@"NewSecurityMode",@"NewKey1",@"NewKey2",@"NewKey3",@"NewKey4", nil] values:[NSArray arrayWithObjects:@"1",ssid,securityMode,k1,k2,k3,k4,nil]];
}
- (GTAsyncOp*)WLANConfiguration_SetGuestAccessNetworkSsid:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)k1 key2:(NSString*)k2 key3:(NSString*)k3 key4:(NSString*)k4//config access
{
    return [self invoke:NS_WLAN_CONFIGURATION action:@"SetGuestAccessEnabled2" names:[NSArray arrayWithObjects:@"NewSSID",@"NewSecurityMode",@"NewKey1",@"NewKey2",@"NewKey3",@"NewKey4", nil] values:[NSArray arrayWithObjects:ssid,securityMode,k1,k2,k3,k4,nil]];
}


////////////
- (GTAsyncOp*)DeviceConfig_ConfigurationStarted:(NSString*)NewSessionID
{
	if (NewSessionID) {
		return [self invoke:NS_DEVICE_CONFIG action:@"ConfigurationStarted" names:[NSArray arrayWithObject:@"NewSessionID"] values:[NSArray arrayWithObject:NewSessionID]];
	} else {
		return [self invoke:NS_DEVICE_CONFIG action:@"ConfigurationStarted"];
	}
}

- (GTAsyncOp*)DeviceConfig_ConfigurationFinished:(NSString*)NewStatus
{
	return [self invoke:NS_DEVICE_CONFIG action:@"ConfigurationFinished" names:[NSArray arrayWithObject:@"NewStatus"] values:[NSArray arrayWithObject:NewStatus]];
}

- (GTAsyncOp*) DeviceConfig_GetTrafficMeterEnabled
{
    return [self invoke:NS_DEVICE_CONFIG action:@"GetTrafficMeterEnabled"];
}
- (GTAsyncOp*) DeviceConfig_GetTrafficMeterOptions
{
    return [self invoke:NS_DEVICE_CONFIG action:@"GetTrafficMeterOptions"];
}
- (GTAsyncOp*) DeviceConfig_GetTrafficMeterStartistics
{
    return [self invoke:NS_DEVICE_CONFIG action:@"GetTrafficMeterStatistics"];
}
- (GTAsyncOp*) DeviceConfig_GetBlockDeviceEnableStatus
{
    return [self invoke:NS_DEVICE_CONFIG action:@"GetBlockDeviceEnableStatus"];
}

- (GTAsyncOp*) DeviceConfig_EnableBlockDeviceForAll
{
    return [self invoke:NS_DEVICE_CONFIG action:@"EnableBlockDeviceForAll"];
}
- (GTAsyncOp*) DeviceConfig_SetBlockDeviceEnable:(NSString*)enable
{
    return [self invoke:NS_DEVICE_CONFIG action:@"SetBlockDeviceEnable" name:@"NewBlockDeviceEnable" value:enable];
}

- (GTAsyncOp*) DeviceConfig_SetBlockDeviceByMAC:(NSString*)macAddr block:(NSString*)block
{
    return [self invoke:NS_DEVICE_CONFIG action:@"SetBlockDeviceByMAC" names:[NSArray arrayWithObjects:@"NewMACAddress", @"NewAllowOrBlock", nil] values:[NSArray arrayWithObjects:macAddr, block, nil]];
}

- (GTAsyncOp*) DeviceConfig_EnableTrafficMeter:(NSString*)enable//@"0"  or  @"1"
{
    return [self invoke:NS_DEVICE_CONFIG action:@"EnableTrafficMeter" name:@"NewTrafficMeterEnable" value:enable];
}
- (GTAsyncOp*) DeviceConfig_SetTrafficMeterOptionsControlMode:(NSString*)controlMode monthlyLimit:(NSString*)monthlyLimit restartHour:(NSString*)hour minute:(NSString*)minute day:(NSString*)day
{
    return [self invoke:NS_DEVICE_CONFIG action:@"SetTrafficMeterOptions" names:[NSArray arrayWithObjects:@"NewControlOption",@"NewMonthlyLimit",@"RestartHour",@"RestartMinute",@"RestartDay",nil] values:[NSArray arrayWithObjects:controlMode,monthlyLimit,hour,minute,day,nil]];
}
///////////
- (GTAsyncOp*)ParentalControl_Authenticate:(NSString*)NewUsername NewPassword:(NSString*)NewPassword
{
	return [self invoke:NS_PARENTAL_CONTROL action:@"Authenticate" names:[NSArray arrayWithObjects:@"NewUsername", @"NewPassword", nil] values:[NSArray arrayWithObjects:NewUsername, NewPassword, nil]];
}

- (GTAsyncOp*) ParentalControl_GetDNSMasqDeviceID
{
    return [self invoke:NS_PARENTAL_CONTROL action:@"GetDNSMasqDeviceID" name:@"NewMACAddress" value:@"default"];
}

- (GTAsyncOp*) ParentalControl_GetDNSMasqDeviceIDForChild:(NSString*)mac
{
        return [self invoke:NS_PARENTAL_CONTROL action:@"GetDNSMasqDeviceID" name:@"NewMACAddress" value:mac];
}

- (GTAsyncOp*) ParentalControl_SetDNSMasqDeviceID:(NSString*)deviceID
{
    return [self invoke:NS_PARENTAL_CONTROL action:@"SetDNSMasqDeviceID" names:[NSArray arrayWithObjects:@"NewMACAddress", @"NewDeviceID",nil]  values:[NSArray arrayWithObjects:@"default", deviceID,nil]];
}

- (GTAsyncOp*) ParentalControl_SetDNSMasqDeviceID:(NSString *)deviceID mac:(NSString*) mac
{
    return [self invoke:NS_PARENTAL_CONTROL action:@"SetDNSMasqDeviceID" names:[NSArray arrayWithObjects:@"NewMACAddress", @"NewDeviceID",nil]  values:[NSArray arrayWithObjects:mac, deviceID,nil]];
}

- (GTAsyncOp*) ParentalControl_GetEnableStatus
{
    return [self invoke:NS_PARENTAL_CONTROL action:@"GetEnableStatus"];
}
- (GTAsyncOp*) ParentalControl_EnableParentalControl:(NSString *)enable
{
    return [self invoke:NS_PARENTAL_CONTROL action:@"EnableParentalControl" name:@"NewEnable" value:enable];
}
- (GTAsyncOp*) ParentalControl_DeleteMACAddress:(NSString*)mac
{
    return [self invoke:NS_PARENTAL_CONTROL action:@"DeleteMACAddress" name:@"NewMACAddress" value:mac];
}


//fcml colse session
- (GTAsyncOp*) closeSession
{
    return [super closeSession];
}
@end

