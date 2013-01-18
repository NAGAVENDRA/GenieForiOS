//
//  GenieCoreData.h
//  GenieDemo
//
//  Created by cs Siteview on 12-3-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenieGlobal.h"

@class GenieRouterInfo;
@class GenieWirelessData;
@class GenieGuestData;
@class GenieMapData;
@class GenieLPCData;
@class GenieTrafficData;

@interface GenieCoreData : NSObject {
    GenieRouterInfo             * m_routerInfo;
    GenieWirelessData           * m_wirelessData;
    GenieGuestData              * m_guestData;
    GenieMapData                * m_mapData;
    GenieLPCData                * m_lpcData;
    GenieTrafficData            * m_trafficData;
}
@property (nonatomic, retain) GenieRouterInfo * routerInfo;
@property (nonatomic, retain) GenieWirelessData * wirelessData;
@property (nonatomic, retain) GenieGuestData * guestData;
@property (nonatomic, retain) GenieMapData * mapData;
@property (nonatomic, retain) GenieLPCData * lpcData;
@property (nonatomic, retain) GenieTrafficData * trafficData;
+ (GenieCoreData*) GetInstance;
+ (id) allocWithZone:(NSZone *)zone;
+ (void) ReleaseInstance;
- (void) clear;
@end

///////////////current router info class
@interface GenieRouterInfo : NSObject {
    NSString                    * m_modelName;
    NSString                    * m_icon;
    NSString                    * m_firmware;
    NSString                    * m_ipAddr;
    NSString                    * m_macAddr;
    GenieNetWorkStatus          m_internetStatus;
    BOOL                        m_notSupportLPC;
}
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * firmware;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * mac;
@property (nonatomic, assign) GenieNetWorkStatus internetStatus;
@property (nonatomic, assign) BOOL notSupportLPC;
- (id) init;
- (void) clear;
@end

//////////////remote router info clas
typedef enum
{
    GenieRouterActivity = 100,
    GenieRouterInactivity
}GenieRouterActivityStatus;
@interface GenieRemoteRouterInfo : NSObject {
    NSString                            * m_modelName;
    NSString                            * m_friendlyName;
    NSString                            * m_serial;
    NSString                            * m_controlId;
    NSString                            * m_icon;
    GenieRouterActivityStatus           m_activityStatus;
}
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSString * friendlyName;
@property (nonatomic, retain) NSString * serial;
@property (nonatomic, retain) NSString * controlId;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, assign) GenieRouterActivityStatus activityStatus;

- (NSComparisonResult) compare:(GenieRemoteRouterInfo*) obj;
@end


//////////////wireless data class
@interface GenieWirelessData : NSObject {
    NSString                    * m_ssid;
    NSString                    * m_password;
    NSString                    * m_channel;
    NSString                    * m_wirelessMode;
    NSString                    * m_region;
    NSString                    * m_securityMode;
    GenieBasicSecurityMode      m_basicSecurityMode;
}
@property (nonatomic, retain) NSString * ssid;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSString * wirelessMode;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * securityMode;
@property (nonatomic, assign) GenieBasicSecurityMode basicSecurityMode;

- (id) init;
- (void) clear;
@end

//////////////////guest data class
@interface GenieGuestData : NSObject {
    GenieFunctionEnableStatus       m_enable;
    NSString                        * m_ssid;
    NSString                        * m_password;
    NSString                        * m_securityMode;
    NSString                        * m_timePeriod;
}
@property (nonatomic, assign) GenieFunctionEnableStatus enable;
@property (nonatomic, retain) NSString * ssid;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * securityMode;
@property (nonatomic, retain) NSString * timePeriod;

- (id) init;
- (void) clear;
@end

////////////////device  class
@interface GenieDeviceInfo : NSObject <NSCoding>{
    NSString                    * m_name;
    NSString                    * m_ip;
    NSString                    * m_mac;
    NSString                    * m_speed;
    NSString                    * m_signalStrength;
    NSString                    * m_icon;
    NSString                    * m_typeString;
    BOOL                        m_blocked;
    GenieConnectMode            m_connectMode;
    GenieNetWorkStatus          m_networkStatus;
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * mac;
@property (nonatomic, retain) NSString * speed;
@property (nonatomic, retain) NSString * signalStrength;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * typeString;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, assign) GenieConnectMode connectMode;
@property (nonatomic, assign) GenieNetWorkStatus networkStatus;

- (id) init;
@end


///////map class
@interface GenieMapData : NSObject {
    GenieBlockType      m_blockEnabled;
    NSMutableArray      * m_allDevices;
}
@property (nonatomic, assign) GenieBlockType blockEnabled;
@property (nonatomic, readonly) NSMutableArray * allDevices;

- (id) init;
- (void) addDeviceInfo:(GenieDeviceInfo*) info;
- (void) clear;
@end


///////////lpc data class
@interface GenieLPCData : NSObject {
    GenieFunctionEnableStatus           m_enable;
    NSString                            * m_openDNSAccount;
    NSString                            * m_openDNSPassword;
    NSString                            * m_deviceId;
    NSString                            * m_token;
    NSString                            * m_relay_token;
    NSString                            * m_bundle;
    NSString                            * m_currentChildAccount;
}
@property (nonatomic, assign) GenieFunctionEnableStatus enable;
@property (nonatomic, retain) NSString * openDNSAccount;
@property (nonatomic, retain) NSString * openDNSPassword;
@property (nonatomic, retain) NSString * deviceID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * relay_token;
@property (nonatomic, retain) NSString * bundle;
@property (nonatomic, retain) NSString * currentChildAccount;
- (id) init;
- (void) clear;
@end


////////traffic data class
@interface GenieTrafficStatisticsData : NSObject {
    NSString            * m_connTime;
    NSString            * m_download;
    NSString            * m_upload;
}
@property (nonatomic, retain) NSString * connTime;
@property (nonatomic, retain) NSString * download;
@property (nonatomic, retain) NSString * upload;

- (id) init;
- (void) clear;
@end

@interface GenieTrafficData : NSObject {
    GenieFunctionEnableStatus           m_enable;
    NSString                            * m_monthlyMeter;
    NSString                            * m_limitMode;
    NSString                            * m_day;
    NSString                            * m_hour;
    NSString                            * m_minute;
    
    GenieTrafficStatisticsData          * m_todayStatistics;
    GenieTrafficStatisticsData          * m_yesterdayStatistics;
    GenieTrafficStatisticsData          * m_weekStatistics;
    GenieTrafficStatisticsData          * m_monthStatistics;
    GenieTrafficStatisticsData          * m_lastMonthStatistics;
}
@property (nonatomic, assign) GenieFunctionEnableStatus enable;
@property (nonatomic, retain) NSString * monthlyMeter;
@property (nonatomic, retain) NSString * limitMode;
@property (nonatomic, retain) NSString *  day;
@property (nonatomic, retain) NSString *  hour;
@property (nonatomic, retain) NSString *  minute;
@property (nonatomic, retain) GenieTrafficStatisticsData * todayStatistics;
@property (nonatomic, retain) GenieTrafficStatisticsData * yesterdayStatistics;
@property (nonatomic, retain) GenieTrafficStatisticsData * weekStatistics;
@property (nonatomic, retain) GenieTrafficStatisticsData * monthStatistics;
@property (nonatomic, retain) GenieTrafficStatisticsData * lastMonthStatistics;

- (id) init;
- (void) clear;
@end


@interface GenieCallbackObj : NSObject {
    GenieErrorType              m_error;
    id                          m_info;
}
@property (nonatomic, assign) GenieErrorType error;
@property (nonatomic, retain) id userInfo;

- (id) initWithResopnseCode:(GenieErrorType) err userInfo:(id) info;
+ (id) callbackObjWithResponseCode:(GenieErrorType) err userInfo:(id)info; 
@end
