//
//  GenieHelper.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIAlertView.h>
#import "GenieGlobal.h"
#import "GenieHomePageController.h"
#import "GenieCoreData.h"
#import "GPBusinessHelper.h"
#import "GPWaitDialog.h"


#ifdef __GENIE_IPHONE__
#import "GenieiPhoneiPodAppDelegate.h"
#else
#import "GenieiPadAppDelegate.h"
#endif

#define Genie_AlertView_Tag_RebootRouterPrompt 3000
@interface GenieHelper : NSObject <UIAlertViewDelegate>{
    GPBusinessHelper                        * GenieBusinessHelper;
    BOOL                                    m_isGenieCertified;
    GenieFunctionType                       m_activeFunction;
    NSString                                * m_currentRouterAdmin;
    NSString                                * m_currentRouterPassword;
    NSMutableDictionary                     * m_configInfo;
    NSMutableDictionary                     * m_userHabitsInfo;
}
@property (nonatomic, readonly) GPBusinessHelper * GenieBusinessHelper;
@property (nonatomic, assign) BOOL m_isGenieCertified;
@property (nonatomic, assign) GenieFunctionType m_activeFunction;
@property (nonatomic, retain) NSString * m_currentRouterAdmin;
@property (nonatomic, retain) NSString * m_currentRouterPassword;
@property (nonatomic, readonly) NSMutableDictionary * m_configInfo;
@property (nonatomic, readonly) NSMutableDictionary * m_userHabitsInfo;
- (void) initConfigInfo;
- (void) initUserHabitsInfo;
- (void) saveConfigInfo;
- (void) saveUserHabitsInfo;

////////////////////////////////////////////////////////public function
+ (GenieHelper*) GetInstance;
+ (id) allocWithZone:(NSZone *)zone;
+ (void) ReleaseInstance;

+ (BOOL) isGenieCertified;

+ (void) configGenieLogin_outStatus:(BOOL)isCertified;
+ (void) logoutGenie;

+ (GenieFunctionType) getActiveFuncton;
+ (void) configActiveFunction:(GenieFunctionType) func;

+ (BOOL) isGenieLoginModeIsRemoteLogin;
+ (void) setGenieLoginModeForRemoteLogin:(BOOL)isRemoteLogin;

//*************管理当前路由器的登陆账号和密码
+ (NSString *) getCurrentRouterAdmin;
+ (NSString *) getCurrentRouterPassword;
+ (void) setCurrentRouterAdmin:(NSString *)admin password:(NSString *)password;
+ (void) clearCurrentRouterAdminAndPassword;

//genie config info
+ (BOOL) getRouterLoginRememberMeFlag;
+ (void) setRouterLoginRememberMeFlag:(BOOL)flag;
+ (NSString *) getLocalRouterPassword;
+ (NSString *) getLocalRouterAdmin;
+ (void) saveLocalRouterPassword:(NSString*)password;

+ (BOOL) getSmartNetworkRememberMeFlag;
+ (void) setSmartNetworkRememberMeFlag:(BOOL)flag;
+ (NSString *) getSmartNetworkAccount;
+ (void) saveSmartNetworkAccount:(NSString*)account;
+ (NSString *) getSmartNetworkPassword;
+ (void) saveSmartNetworkPassword:(NSString*)password;

//smart network 

/*
 *isSmartNetworkAvailable  判断当前Genie是否应该支持smart network
 *对于目前版本的Genie,只有当Genie在本地【成功登陆】过一款【支持smart network 的路由器】后，
 *Genie才会开启对smart network 的支持,并且 以后一直保持对smart network 的支持
 *否则，讲不会支持smart network流程
 */
+ (BOOL) isSmartNetworkAvailable;
+ (void) setSmartNetworkAvailable;

+ (BOOL) isSmartNetwork;//判断Genie当前是否处于smart network模式
+ (void) logoutSmartNetwork;
#ifdef __GENIE_IPHONE__
+ (GenieiPhoneiPodAppDelegate*) getGenieDelegate;
#else
+ (GenieiPadAppDelegate*) getGenieDelegate;
#endif
//genie  core data
+ (void) InitGenieCoreData;
+ (void) ReleaseCoreData;
+ (GenieHomePageController*) getRootViewController;
+ (GPBusinessHelper*) shareGenieBusinessHelper;

+ (GenieRouterInfo*) getRouterInfo;
+ (GenieWirelessData*) getWirelessData;
+ (GenieGuestData*) getGuestData;
+ (GenieMapData*) getMapData;
+ (GenieLPCData*) getLPCData;
+ (GenieTrafficData*) getTrafficData;

+ (void) setRouterInfo:(GenieRouterInfo*)data;
+ (void) setWirelessData:(GenieWirelessData*)data;
+ (void) setGuestData:(GenieGuestData*)data;
+ (void) setMapData:(GenieMapData*)data;
+ (void) setLPCData:(GenieLPCData*)data;
+ (void) setTrafficData:(GenieTrafficData*)data;
+ (void) clearGenieCoreData;

//custom msg box
+ (void) showMsgBoxWithMsg:(NSString*)msg;//"Close" btn
+ (void) showMsgBoxWithMsg:(NSString *)msg cancelBtn:(NSString*)btn;

//go back to rootviewcontroller box
+ (void) showGobackToMainPageMsgBoxWithMsg:(NSString*)msg;//"OK"btn
+ (void) showGobackToMainPageMsgBoxWithMsg:(NSString *)msg cancelBtn:(NSString*)btn;
//........
+ (void) showRebootRouterPrompt:(NSString*)prompt WithDelegate:(id)alertDelegate;
// file manage
+ (NSString*) readRouterIconFromXMLWithModelName:(NSString*)routerModel;
+ (NSDictionary*) readDeviceTypeString2DeviceIconMapFromXML;

+ (NSString*) getFileDomain;
+ (BOOL) isFileExistsAtPath:(NSString*)path;
+ (void) write:(NSDictionary*)info toFile:(NSString*)file;//自动保存到libary域下
+ (NSDictionary*) readFile:(NSString*)file;

//general process OP result
+ (void) generalProcessAsyncOpCallback:(GenieCallbackObj*)obj withErrorCode:(GenieErrorType*)err;
+ (void) generalProcessGenieError:(GenieErrorType)err;

+ (void) configForSetProcessOrLPCProcessStart;//if router type is not cg or dg  set process should be wraped
+ (void) resetConfigForSetProcessOrLPCProcessFinish;//if router type is not cg or dg  we should reset soap for not wraped



@end


