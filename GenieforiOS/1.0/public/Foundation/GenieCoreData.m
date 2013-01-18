//
//  GenieCoreData.m
//  GenieDemo
//
//  Created by cs Siteview on 12-3-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieCoreData.h"


@implementation GenieCoreData
@synthesize routerInfo = m_routerInfo;
@synthesize wirelessData = m_wirelessData;
@synthesize guestData = m_guestData;
@synthesize mapData = m_mapData;
@synthesize lpcData = m_lpcData;
@synthesize trafficData = m_trafficData;
static GenieCoreData * g_instance = nil;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_routerInfo = [[GenieRouterInfo alloc] init];
        m_wirelessData = [[GenieWirelessData alloc] init];
        m_guestData = [[GenieGuestData alloc] init];
        m_mapData = [[GenieMapData alloc] init];
        m_lpcData = [[GenieLPCData alloc] init];
        m_trafficData = [[GenieTrafficData alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [self.trafficData release];
    [self.lpcData release];
    [self.mapData release];
    [self.guestData release];
    [self.wirelessData release];
    [self.routerInfo release];
    [super dealloc];
}

+ (GenieCoreData*) GetInstance
{
    @synchronized(self)
    {
        if (!g_instance)
        {
            g_instance = [[GenieCoreData alloc] init];
        }
    }
    return g_instance;
}
+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)//域锁
    {
        if (!g_instance)
        {
            g_instance = [super allocWithZone:zone];
        }
        return g_instance;
    }
    return nil;
}
+ (void) ReleaseInstance
{
    if (g_instance)
    {
        [g_instance release];
        g_instance = nil;
    }
}
- (void) clear
{
    [m_routerInfo clear];
    [m_wirelessData clear];
    [m_guestData clear];
    [m_mapData clear];
    [m_lpcData clear];
    [m_trafficData clear];
}
@end


//////////////
//router info
////////////
@implementation GenieRouterInfo
@synthesize modelName = m_modelName;
@synthesize icon = m_icon;
@synthesize firmware = m_firmware;
@synthesize ip = m_ipAddr;
@synthesize mac = m_macAddr;
@synthesize internetStatus = m_internetStatus;
@synthesize notSupportLPC = m_notSupportLPC;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_modelName = nil;
        m_icon = nil;
        m_firmware = nil;
        m_ipAddr = nil;
        m_macAddr = nil;
        m_internetStatus = GenieNetWorkOnline;
        m_notSupportLPC = NO;
    }
    return self;
}

- (void) dealloc
{
    self.mac = nil;
    self.ip = nil;
    self.firmware = nil;
    self.icon = nil;
    self.modelName = nil;
    [super dealloc];
}

- (void) clear
{
    self.modelName = nil;
    self.icon = nil;
    self.firmware = nil;
    self.ip = nil;
    self.mac = nil;
    self.internetStatus = GenieNetWorkOnline; 
    self.notSupportLPC = NO;
}
@end

//////////
///GenieRemoteRouterInfo
///////////
@implementation GenieRemoteRouterInfo
@synthesize modelName = m_modelName;
@synthesize friendlyName = m_friendlyName;
@synthesize serial = m_serial;
@synthesize controlId = m_controlId;
@synthesize icon = m_icon;
@synthesize activityStatus = m_activityStatus;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_modelName = nil;
        m_friendlyName = nil;
        m_serial = nil;
        m_controlId = nil;
        m_icon = nil;
        m_activityStatus = GenieRouterActivity;
    }
    return self;
}

- (void) dealloc
{
    self.modelName = nil;
    self.friendlyName = nil;
    self.serial = nil;
    self.controlId = nil;
    self.icon = nil;
    [super dealloc];
}

- (NSComparisonResult) compare:(GenieRemoteRouterInfo*) obj
{
    if (self.activityStatus == GenieRouterInactivity)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedAscending;
    }
}
@end



////////////////
//wireless setting
///////////////
@implementation GenieWirelessData
@synthesize ssid = m_ssid;
@synthesize password = m_password;
@synthesize channel = m_channel;
@synthesize wirelessMode = m_wirelessMode;
@synthesize region = m_region;
@synthesize basicSecurityMode = m_basicSecurityMode;
@synthesize securityMode = m_securityMode;
- (id) init
{
    self = [super init];
    if (self)
    {
        m_ssid = nil;
        m_password = nil;
        m_channel = nil;
        m_wirelessMode = nil;
        m_region = nil;
        m_securityMode = nil;
        m_basicSecurityMode = GenieBasicSecurityModeWPA;
    }
    return self;
}

- (void) dealloc
{
    self.securityMode = nil;
    self.region = nil;
    self.wirelessMode = nil;
    self.channel = nil;
    self.password = nil;
    self.ssid = nil;
    [super dealloc];
}
- (void) clear
{
    self.basicSecurityMode = GenieBasicSecurityModeWPA;
    self.securityMode = nil;
    self.region = nil;
    self.wirelessMode = nil;
    self.channel = nil;
    self.password = nil;
    self.ssid = nil;
}
@end

/////////////
//guest access
/////////////
@implementation GenieGuestData
@synthesize enable = m_enable;
@synthesize ssid = m_ssid;
@synthesize password = m_password;
@synthesize securityMode = m_securityMode;
@synthesize timePeriod = m_timePeriod;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_enable = GenieFunctionNotSupport;
        m_ssid = nil;
        m_password = nil;
        m_securityMode = nil;
        m_timePeriod = nil;
    }
    return self;
}

- (void) dealloc
{
    self.timePeriod = nil;
    self.securityMode = nil;
    self.password = nil;
    self.ssid = nil;
    [super dealloc];
}

- (void) clear
{
    self.enable = GenieFunctionNotEnbaled;
    self.ssid = nil;
    self.password = nil;
    self.securityMode = nil;
    self.timePeriod = nil;
}
@end


///////////
//device info
/////////////
@implementation GenieDeviceInfo
@synthesize name = m_name;
@synthesize ip = m_ip;
@synthesize mac = m_mac;
@synthesize speed = m_speed;
@synthesize signalStrength = m_signalStrength;
@synthesize icon = m_icon;
@synthesize typeString = m_typeString;
@synthesize blocked = m_blocked;
@synthesize connectMode = m_connectMode;
@synthesize networkStatus = m_networkStatus;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_name = nil;
        m_ip = nil;
        m_mac = nil;
        m_speed = nil;
        m_signalStrength = nil;
        m_icon = nil;
        m_typeString = nil;
        m_blocked = NO;
        m_connectMode = GenieConnectWireless;
        m_networkStatus = GenieNetWorkOnline;
    }
    return self;
}

- (void) dealloc
{
    self.typeString = nil;
    self.icon = nil;
    self.signalStrength = nil;
    self.speed = nil;
    self.mac = nil;
    self.ip = nil;
    self.name = nil;
    [super dealloc];
}

#define key_name            @"device_name"
#define key_ip              @"device_ip"
#define key_mac             @"device_mac"
#define key_speed           @"device_speed"
#define key_signal          @"device_signal"
#define key_icon            @"device_icon"
#define key_type            @"device_type"
#define key_block           @"device_block"
#define key_connMode        @"device_connMode"
#define key_networkStatus   @"device_networkStatus"
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:m_name forKey:key_name];
    [aCoder encodeObject:m_ip forKey:key_ip];
    [aCoder encodeObject:m_mac forKey:key_mac];
    [aCoder encodeObject:m_speed forKey:key_speed];
    [aCoder encodeObject:m_signalStrength forKey:key_signal];
    [aCoder encodeObject:m_icon forKey:key_icon];
    [aCoder encodeObject:m_typeString forKey:key_type];
    [aCoder encodeBool:m_blocked forKey:key_block];
    [aCoder encodeInt:m_connectMode forKey:key_connMode];
    [aCoder encodeInt:m_networkStatus forKey:key_networkStatus];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.name = [aDecoder decodeObjectForKey:key_name];
        self.ip = [aDecoder decodeObjectForKey:key_ip];
        self.mac = [aDecoder decodeObjectForKey:key_mac];
        self.speed = [aDecoder decodeObjectForKey:key_speed];
        self.signalStrength = [aDecoder decodeObjectForKey:key_signal];
        self.icon = [aDecoder decodeObjectForKey:key_icon];
        self.typeString = [aDecoder decodeObjectForKey:key_type];
        self.blocked = [aDecoder decodeBoolForKey:key_block];
        self.connectMode = [aDecoder decodeIntForKey:key_connMode];
        self.networkStatus = [aDecoder decodeIntForKey:key_networkStatus];
    }
    return self;
}
@end

////////////
//map data
/////////
@implementation GenieMapData
@synthesize blockEnabled = m_blockEnabled;
@synthesize allDevices = m_allDevices;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_blockEnabled = GenieBlockNotSupport;
        m_allDevices = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void) addDeviceInfo:(GenieDeviceInfo*) info
{
    [m_allDevices addObject:info];
}
- (void) clear
{
    self.blockEnabled = GenieBlockNotSupport;
    [m_allDevices removeAllObjects];
}
- (void) dealloc
{
    [m_allDevices release];
    [super dealloc];
}

@end


////////////
//lpc data
/////////
@implementation GenieLPCData
@synthesize enable = m_enable;
@synthesize openDNSAccount = m_openDNSAccount;
@synthesize openDNSPassword = m_openDNSPassword;
@synthesize deviceID = m_deviceId;
@synthesize token = m_token;
@synthesize relay_token = m_relay_token;
@synthesize bundle = m_bundle;
@synthesize currentChildAccount = m_currentChildAccount;
- (id) init
{
    self = [super init];
    if (self)
    {
        m_enable = GenieFunctionNotEnbaled;
        m_openDNSAccount = nil;
        m_openDNSPassword = nil;
        m_deviceId = nil;
        m_token = nil;
        m_relay_token = nil;
        m_bundle = nil;
        m_currentChildAccount = nil;
    }
    return self;
}

- (void) dealloc
{
    self.openDNSAccount = nil;
    self.openDNSPassword = nil;
    self.deviceID = nil;
    self.token = nil;
    self.relay_token = nil;
    self.bundle = nil;
    self.currentChildAccount = nil;
    [super dealloc];
}
- (void) clear
{
    self.enable = GenieFunctionNotEnbaled;
    self.openDNSAccount = nil;
    self.openDNSPassword = nil;
    self.deviceID = nil;
    self.token = nil;
    self.relay_token = nil;
    self.bundle = nil;
    self.currentChildAccount = nil;
}

@end


///////////
//traffic meter data
/////////
@implementation GenieTrafficStatisticsData
@synthesize connTime = m_connTime;
@synthesize upload = m_upload;
@synthesize download = m_download;
- (id) init
{
    self = [super init];
    if (self)
    {
        m_connTime = nil;
        m_upload = nil;
        m_download = nil;
    }
    return self;
}
- (void) dealloc
{
    self.connTime = nil;
    self.upload = nil;
    self.download = nil;
    [super dealloc];
}
- (void) clear
{
    self.connTime = nil;
    self.upload = nil;
    self.download = nil;
}
@end

@implementation GenieTrafficData
@synthesize enable = m_enable;
@synthesize monthlyMeter = m_monthlyMeter;
@synthesize day = m_day;
@synthesize hour = m_hour;
@synthesize minute = m_minute;
@synthesize limitMode = m_limitMode;
@synthesize todayStatistics = m_todayStatistics;
@synthesize yesterdayStatistics = m_yesterdayStatistics;
@synthesize weekStatistics = m_weekStatistics;
@synthesize monthStatistics = m_monthStatistics;
@synthesize lastMonthStatistics = m_lastMonthStatistics;

- (id) init
{
    self = [super init];
    if (self)
    {
        m_enable = GenieFunctionNotSupport;
        m_monthlyMeter = nil;
        m_limitMode = nil;
        m_day = nil;
        m_hour = nil;
        m_minute = nil;
        m_todayStatistics = [[GenieTrafficStatisticsData alloc] init];
        m_yesterdayStatistics = [[GenieTrafficStatisticsData alloc] init];
        m_weekStatistics = [[GenieTrafficStatisticsData alloc] init];
        m_monthStatistics = [[GenieTrafficStatisticsData alloc] init];
        m_lastMonthStatistics = [[GenieTrafficStatisticsData alloc] init];
    }
    return self;
}
- (void) dealloc
{
    self.monthlyMeter = nil;
    self.limitMode = nil;
    self.day = nil;
    self.hour = nil;
    self.minute = nil;
    self.todayStatistics = nil;
    self.yesterdayStatistics = nil;
    self.weekStatistics = nil;
    self.monthStatistics = nil;
    self.lastMonthStatistics = nil;
    [super dealloc];
}
- (void) clear
{
    self.enable = GenieFunctionNotSupport;
    self.monthlyMeter = nil;
    self.day = nil;
    self.hour = nil;
    self.minute = nil;
    self.limitMode = nil;
    [self.todayStatistics clear];
    [self.yesterdayStatistics clear];
    [self.weekStatistics clear];
    [self.monthStatistics clear];
    [self.lastMonthStatistics clear];
}

@end


//.///////////////
@implementation GenieCallbackObj
@synthesize error = m_error;
@synthesize userInfo = m_info;

- (id) initWithResopnseCode:(GenieErrorType) err userInfo:(id) info
{
    self = [super init];
    if (self)
    {
        m_error = err;
        self.userInfo = info;
    }
    return self;
}

- (void) dealloc
{
    self.userInfo = nil;
    [super dealloc];
}
+ (id) callbackObjWithResponseCode:(GenieErrorType) err userInfo:(id)info
{
    return [[[GenieCallbackObj alloc] initWithResopnseCode:err userInfo:info] autorelease];
}
@end
