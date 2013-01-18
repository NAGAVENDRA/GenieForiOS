//
//  GEBusinessOp.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTAsyncOp.h"

typedef enum 
{
    GTAsyncOpMode_FXSoap = 0,
    GTAsyncOpMode_OpneDNS,
    GTAsyncOpMode_CSSetting,
    GTAsyncOpMode_BusinessOp,
    GTAsyncOpMode_Unknown
}GTAsyncOpMode;
@class GPBusinessCore;
@interface GPBusinessOp : GTAsyncOp {
    GPBusinessCore                              * m_core;
    GTAsyncOp                                   * m_op;
    int                                         m_atomOpMode;
    NSMutableDictionary                         * m_result;
	id                                          m_target;
	SEL                                         m_selector;
	BOOL                                        m_finished;
	BOOL                                        m_aborted;
	BOOL                                        m_succeeded;
	int                                         m_responseCode;
}
@property (nonatomic,retain) GTAsyncOp * asynOp;
- (id) initWithCore:(GPBusinessCore*)core;
- (void) start;
- (void) processFinallyResult;

/* 
    * 只有当需要对当期OP进行一些通用处理和分析（即调用easilyCheckIfNeedNextOp方法）的时候，
    * 才有必要调用该方法设置当前OP的mode
*/
- (void) setCurrentOpMode:(GTAsyncOpMode) mode;//共有多种种不同的OP  每种OP的responseCode的分析过程相同 但是  不同的OP 其rspCode的含义不同

/*
    * - (BOOL) easilyCheckIfNeedNextOp;
    * 简单的分析当前OP的successed状态以及responseCode 并处理result的数据,
    * 使用通用逻辑判断是否需要进行下一步的OP调用（当self.asyncOp 的successed以及responseCode都表示正常时返回YES,否则返回NO）
    * 是get流程的通用处理
*/
- (BOOL) easilyCheckIfNeedNextOp;
- (int) processFXSoapResponseCode;
- (int) processOpneDNSResponseCode;
- (int) processBusinessOpResponseCode;

- (void)notifyFinished;
- (BOOL)aborted;
- (BOOL)finished;
- (BOOL)succeeded;
- (BOOL)setFinishCallback:(id)target selector:(SEL)selector;
- (void)abort;
- (NSDictionary*)result;
- (int)responseCode;
- (NSString*)stringForKey:(NSString*)key;
- (BOOL)containsKey:(NSString*)key;
@end

@interface GPGetSNRouterListOp : GPBusinessOp 
- (id) initWithCore:(GPBusinessCore *)core;
@end

@interface GPRouterLoginOp : GPBusinessOp{
    NSString                    * m_admin;
    NSString                    * m_password;
    NSString                    * m_controlPointID;//for smart network
}
- (id) initWithCore:(GPBusinessCore *)core admin:(NSString*)admin password:(NSString*)password controlPointID:(NSString*)controlPointID;
@end

@interface GPGetRouterInfoOp : GPBusinessOp
- (id) initWithCore:(GPBusinessCore *)core;
@end

@interface GPGetWirelessOp : GPBusinessOp 
- (id) initWithCore:(GPBusinessCore *)core;
@end


@interface GPGetGuestOp : GPBusinessOp 
- (id) initWithCore:(GPBusinessCore *)core;
@end


@interface GPGetTrafficOp : GPBusinessOp 
- (id) initWithCore:(GPBusinessCore *)core;
@end

@interface GPGetNetworkMapOp : GPBusinessOp
- (id) initWithCore:(GPBusinessCore *)core;
@end

@interface GPGetLPCAccountRelayOp : GPBusinessOp {
    NSString                    * m_token;
}
- (id) initWithCore:(GPBusinessCore *)core token:(NSString*)token;
@end

@interface GPLPCCreateAccountOp : GPBusinessOp {
    NSString                    * m_userName;
    NSString                    * m_password;
    NSString                    * m_email;
}
- (id) initWithCore:(GPBusinessCore *)core userName:(NSString*)userName password:(NSString*)password email:(NSString*)email;
@end

@interface GPQueryLpcInfoOp : GPBusinessOp {
    NSString                    * m_routerAdmin;
    NSString                    * m_routerPassword;
    NSString                    * m_openDNSAccount;
    NSString                    * m_openDNSPassword;
    NSString                    * m_deviceKey;
    NSString                    * m_token;//缓存token 某些调用会用到该值
    NSString                    * m_deviceID;//存deviceID 某些调用会用到该值
}
- (id) initWithCore:(GPBusinessCore *)core admin:(NSString *)admin password:(NSString *)password openDNSAccount:(NSString*)openDNSAccount openDNSKey:(NSString*) openDNSPassword deviceKey:(NSString*)deviceKey;
@end
@interface GPLPCAutoLoginOp : GPBusinessOp{
    NSString                    * m_routerAdmin;
    NSString                    * m_routerPassword;
    NSString                    * m_openDNSAccount;
    NSString                    * m_openDNSPassword;
    NSString                    * m_deviceKey;
    BOOL                        m_autoLoginWithRegister;//标记登陆方式是否为根据配置记录进行自动登陆
}
- (id) initWithCore:(GPBusinessCore *)core admin:(NSString *)admin password:(NSString *)password openDNSAccount:(NSString*)openDNSAccount openDNSKey:(NSString*) openDNSPassword deviceKey:(NSString*)deviceKey autoLogin:(BOOL) autoLogin;
@end


@interface GPGetLPCBypassAccountInfo : GPBusinessOp 
{
    NSString                    * m_mainDeviceID;//主账号对应的id
    NSString                    * m_mac;//用来获取当前登陆的子账户的id  本机设备的MAC
}
- (id) initWithCore:(GPBusinessCore *)core deviceID:(NSString*)deviceID mac:(NSString*) mac;
@end

@interface GPLoginLPCBypassAccoutOp : GPBusinessOp {
    NSString                    * m_routerAdmin;
    NSString                    * m_routerPassword;
    NSString                    * m_account;
    NSString                    * m_password;
    NSString                    * m_parentalDeviceID;
    NSString                    * m_mac;//将本机MAC地址与当前的childDeviceID作为一个pair存入路由器完成 子账户的登陆  本机设备的MAC
}
- (id) initWithCore:(GPBusinessCore *)core routerAdmin:(NSString*)admin routerPassword:(NSString*)routerPassword account:(NSString*) account password:(NSString*) password parentalDeviceID:(NSString*) deviceID mac:(NSString*) mac;
@end

@interface GPLogoutLPCBypassAccountOp : GPBusinessOp {
    NSString                    * m_routerAdmin;
    NSString                    * m_routerPassword;
    NSString                    * m_mac;
}
- (id) initWithCore:(GPBusinessCore *)core routerAdmin:(NSString*)admin routerPassword:(NSString*)routerPassword mac:(NSString*)mac;
@end

@interface GPSetWirelessOp : GPBusinessOp {
    NSString                    * m_ssid;
    NSString                    * m_password;
    NSString                    * m_channel;
    NSString                    * m_securityMode;
    NSString                    * m_region;
    NSString                    * m_wirelessMode;
}
- (id) initWithCore:(GPBusinessCore *)core ssid:(NSString*)ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode securityMode:(NSString*)securitymode WPAPassPhrase:(NSString*)phrase;
/*对于设置wireless setting后 不重启的路由器，直接将此处的值缓存到Genie的核心数据区，然后GUI根据核心数据区数据重新刷新界面即可   暂时没有处理此类情况 2012.4.13
@property (nonatomic, readonly) NSString * ssid;
@property (nonatomic, readonly) NSString * password;
@property (nonatomic, readonly) NSString * channel;
@property (nonatomic, readonly) NSString * securityMode;
 */
@end



@interface GPSetGuestOp : GPBusinessOp {
    NSString                * m_enabled;
    NSString                * m_ssid;
    NSString                * m_securityMode;
    NSString                * m_key1;
    NSString                * m_key2;
    NSString                * m_key3;
    NSString                * m_key4;
}
- (id) initWithCore:(GPBusinessCore *)core enable:(NSString*)enable ssid:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3 key4:(NSString*)key4;
@end


@interface GPSetEnableBlockStatusOp : GPBusinessOp {
    NSString                * m_enable;
}
- (id) initWithCore:(GPBusinessCore *)core enable:(NSString*) enable;
@end

@interface GPSetDeviceBlockOrAllowOp : GPBusinessOp {
    NSString                * m_allowOrBlock;
    NSString                * m_deviceMac;
}
- (id) initWithCore:(GPBusinessCore *)core macAddr:(NSString*)mac allowOrBlock:(NSString*)allowOrBlock;
@end



@interface GPSetTrafficOp : GPBusinessOp {
    NSString                    * m_enable;
    NSString                    * m_controlMode;
    NSString                    * m_monthlyLimit;
    NSString                    * m_restartDay;
    NSString                    * m_restartHour;
    NSString                    * m_restartMinute;
}
- (id) initWithCore:(GPBusinessCore *)core enable:(NSString *)enable controlMode:(NSString*)controlMode monthlyLimit:(NSString*)monthlyLimit restartDay:(NSString*)day hour:(NSString*)hour minute:(NSString*)minute;
@end

@interface GPSetLPCEnableOp : GPBusinessOp {
    BOOL                        m_enable;
    NSString                    * m_admin;//认证路由器
    NSString                    * m_password;
    NSString                    * m_token;//查询filter信息
    NSString                    * m_deviceID;
}
- (id) initWithCore:(GPBusinessCore *)core enable:(BOOL) enable admin:(NSString *)admin password:(NSString *)password token:(NSString*)token deviceID:(NSString*)deviceId;
@end

@interface GPSetLPCFilterOp : GPBusinessOp {
    NSString                    * m_bundle;
    NSString                    * m_token;
    NSString                    * m_deviceID;
}
- (id) initWithCore:(GPBusinessCore *)core token:(NSString*)token deviceID:(NSString*)deviceId bundle:(NSString*)bundle;
@end