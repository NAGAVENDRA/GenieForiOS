//
//  GenieHelper.m
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieHelper.h"
#import "GenieHelper_TimePeriod.h"


@implementation GenieHelper
@synthesize GenieBusinessHelper;
@synthesize m_isGenieCertified;
@synthesize m_activeFunction;
@synthesize m_currentRouterAdmin;
@synthesize m_currentRouterPassword;
@synthesize m_configInfo;
@synthesize m_userHabitsInfo;
static GenieHelper* g_instance = nil;



- (id) init
{
    self = [super init];
    if (self)
    {
        m_isGenieCertified = NO;
        m_activeFunction = GenieFunctionHomePage;
        m_currentRouterAdmin = nil;
        m_currentRouterPassword = nil;
        [self initConfigInfo];
        [self initUserHabitsInfo];
        
        {
            //删除v1.0.15的配置文件： routerinfo.info   GenieIstInfo.ini 
            NSString * homeDic = [GenieHelper getFileDomain];
            NSString * file1 = [NSString stringWithFormat:@"%@/routerinfo.info",homeDic];
            NSString * file2 = [NSString stringWithFormat:@"%@/GenieIstInfo.ini",homeDic];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            if ( [fileManager fileExistsAtPath:file1] )
            {
                [fileManager removeItemAtPath:file1 error:nil];
            }
            if ([fileManager fileExistsAtPath:file2])
            {
                [fileManager removeItemAtPath:file2 error:nil];
            }
        }
        
        FXSoapHelper * fxSoapHelper = [[FXSoapHelper alloc] initWithSessionID:@"10588AE69687E58D9A00"];
        DCWebApi * lpcHelper = [[DCWebApi alloc] initWithApiKey:@"3D8C85A77ADA886B967984DF1F8B3711"];
        GWebInfoHelper * webInfoHelper = [[GWebInfoHelper alloc] init];
        GenieBusinessHelper = [[GPBusinessHelper alloc] initWithSoapHelper:fxSoapHelper LPCHelper:lpcHelper GWebInfoHelper:webInfoHelper];
        [webInfoHelper release];
        [lpcHelper release];
        [fxSoapHelper release];
    }
    return self;
}

- (void) dealloc
{
    [GenieBusinessHelper release];
    [m_userHabitsInfo release];
    [m_configInfo release];
    [m_currentRouterAdmin release];
    [m_currentRouterPassword release];
    [super dealloc];
}
#pragma mark ------------
const BOOL Login_Mode_IS_Remote = YES;
static NSString * config_current_login_mode_is_remote_login_key = @"config_current_login_mode_is_remote_login_key";

static NSString * config_routerlogin_remember_PasswordFlag_key = @"config_routerlogin_remember_PasswordFlag_key";
static NSString * config_routerlogin_password_key = @"config_routerlogin_password_key";

static NSString * config_smartNetwork_remember_me_Flag_key = @"config_smartNetwork_remember_me_Flag_key";
static NSString * config_smartNetwork_username_key = @"config_smartNetwork_username_key";
static NSString * config_smartNetwork_password_key = @"config_smartNetwork_password_key";
#define RememberMeFlagON     YES
#define RememberMeFlagOFF    NO

#define DefaultRouterPassword         @"password"

- (void) backupUserDataOnV_1_0_15//处理1.0.15版本的用户配置文件数据
{
    if (m_configInfo)
    {
        NSString * homeDic = [GenieHelper getFileDomain];
        NSString * filePath = [NSString stringWithFormat:@"%@/GenieCofig.ini",homeDic];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if ( ![fileManager fileExistsAtPath:filePath] )
        {
            return;
        }
        UserInfo info;
        memset((void*)&info, 0x00, sizeof(UserInfo));
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        memcpy((void*)&info, (void*)[data bytes], sizeof(UserInfo));
        BOOL savePasswordFlag =  RememberMeFlagON;
        if (!info.isSave)
        {
            savePasswordFlag = RememberMeFlagOFF;
        }
        [m_configInfo setObject:[NSNumber numberWithBool:savePasswordFlag] forKey:config_routerlogin_remember_PasswordFlag_key];
        [m_configInfo setObject:[NSString stringWithUTF8String:info.password] forKey:config_routerlogin_password_key];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void) initConfigInfo
{
    m_configInfo = [[NSMutableDictionary alloc] init];
    [m_configInfo setObject:[NSNumber numberWithBool:!Login_Mode_IS_Remote] forKey:config_current_login_mode_is_remote_login_key];//默认登陆本地路由器
    
    [m_configInfo setObject:[NSNumber numberWithBool:RememberMeFlagON] forKey:config_routerlogin_remember_PasswordFlag_key];
    [m_configInfo setObject:DefaultRouterPassword forKey:config_routerlogin_password_key];
    
    [m_configInfo setObject:[NSNumber numberWithBool:RememberMeFlagON] forKey:config_smartNetwork_remember_me_Flag_key]; 
    [m_configInfo setObject:@"" forKey:config_smartNetwork_username_key];
    [m_configInfo setObject:@"" forKey:config_smartNetwork_password_key];
    [self backupUserDataOnV_1_0_15];
    
    [m_configInfo addEntriesFromDictionary:[GenieHelper readFile:Genie_File_ConfigInfo]];
}

static NSString * userHabits = @"userhabits_functionIndex:";
- (void) initUserHabitsInfo
{
    m_userHabitsInfo = [[NSMutableDictionary alloc] init];
    for (NSInteger i = GenieFunctionTypeBegin+1; i < GenieFunctionTypeEnd; i++)
    {
        [m_userHabitsInfo setObject:[NSNumber numberWithUnsignedInt:0] forKey:[NSString stringWithFormat:@"%@%d",userHabits,i]];
    }
    [m_userHabitsInfo addEntriesFromDictionary:[GenieHelper readFile:Genie_File_UserHabits_Info]];
}
- (void) saveConfigInfo
{
    [GenieHelper write:m_configInfo toFile:Genie_File_ConfigInfo];
}
- (void) saveUserHabitsInfo
{
    [GenieHelper write:m_userHabitsInfo toFile:Genie_File_UserHabits_Info];
}

///////////////////////////////////
#pragma mark --------------
+ (GenieHelper*) GetInstance
{
    @synchronized(self)
    {
        if (!g_instance)
        {
            g_instance = [[GenieHelper alloc] init];
        }
    }
    return g_instance;
}
+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
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

+ (BOOL) isGenieCertified
{
    return [GenieHelper GetInstance].m_isGenieCertified;
}
+ (void) configGenieLogin_outStatus:(BOOL)isCertified
{
    //timeperiod
    if (isCertified)
    {
        [GenieHelper startMoniteGuestTimePeriod];
    }
    else
    {
        [GenieHelper resetTimePeriodMoniter];
    }
    
    [GenieHelper GetInstance].m_isGenieCertified = isCertified;
}
+ (void) logoutGenie
{
    [GenieHelper configActiveFunction:GenieFunctionHomePage];
    [GenieHelper configGenieLogin_outStatus:GenieLogout];
    [GenieHelper clearGenieCoreData];
    [GenieHelper clearCurrentRouterAdminAndPassword];
    [[GenieHelper getRootViewController] setNaviItemLeftBtnTitle];
}
+ (GenieFunctionType) getActiveFuncton
{
    return [GenieHelper GetInstance].m_activeFunction;
}
+ (void) configActiveFunction:(GenieFunctionType) func
{
    [GenieHelper GetInstance].m_activeFunction = func;
    
    if (func != GenieFunctionHomePage)
    {
        unsigned int clickCount = [[[GenieHelper GetInstance].m_userHabitsInfo objectForKey:[NSString stringWithFormat:@"%@%d",userHabits,func]] unsignedIntValue];
        clickCount++;
        [[GenieHelper GetInstance].m_userHabitsInfo setObject:[NSNumber numberWithUnsignedInt:clickCount] forKey:[NSString stringWithFormat:@"%@%d",userHabits,func]];
    }
}

+ (BOOL) isGenieLoginModeIsRemoteLogin
{
    return [[[GenieHelper GetInstance].m_configInfo objectForKey:config_current_login_mode_is_remote_login_key] boolValue];
}
+ (void) setGenieLoginModeForRemoteLogin:(BOOL)isRemoteLogin
{
    [[GenieHelper GetInstance].m_configInfo setObject:[NSNumber numberWithBool:isRemoteLogin] forKey:config_current_login_mode_is_remote_login_key];
}

//*************
+ (NSString *) getCurrentRouterAdmin
{
    NSString * admin = [GenieHelper GetInstance].m_currentRouterAdmin;
    if (!admin)
    {
        admin = @"";
    }
    return admin;
}
+ (NSString *) getCurrentRouterPassword
{
    NSString * password = [GenieHelper GetInstance].m_currentRouterPassword;
    if (!password)
    {
        password = @"";
    }
    return password;
}
+ (void) setCurrentRouterAdmin:(NSString *)admin password:(NSString *)password
{
    if (!admin)
    {
        admin = @"";
    }
    if (!password)
    {
        password = @"";
    }
    [GenieHelper GetInstance].m_currentRouterAdmin = admin;
    [GenieHelper GetInstance].m_currentRouterPassword = password;
}

+ (void) clearCurrentRouterAdminAndPassword
{
    [GenieHelper setCurrentRouterAdmin:nil password:nil];
}

+ (BOOL) getRouterLoginRememberMeFlag
{
    return [[[GenieHelper GetInstance].m_configInfo objectForKey:config_routerlogin_remember_PasswordFlag_key] boolValue];
}
+ (void) setRouterLoginRememberMeFlag:(BOOL)flag
{
    [[GenieHelper GetInstance].m_configInfo setObject:[NSNumber numberWithBool:flag] forKey:config_routerlogin_remember_PasswordFlag_key];
}
+ (NSString *) getLocalRouterPassword
{
    return [[GenieHelper GetInstance].m_configInfo objectForKey:config_routerlogin_password_key];
}
+ (NSString *) getLocalRouterAdmin
{
    return Genie_ADMIN;
}
+ (void) saveLocalRouterPassword:(NSString*)password
{
    if (!password)
    {
        password = DefaultRouterPassword;
    }
    [[GenieHelper GetInstance].m_configInfo setObject:password forKey:config_routerlogin_password_key];
}

+ (BOOL) getSmartNetworkRememberMeFlag
{
    return [[[GenieHelper GetInstance].m_configInfo objectForKey:config_smartNetwork_remember_me_Flag_key] boolValue];
}
+ (void) setSmartNetworkRememberMeFlag:(BOOL)flag
{
    [[GenieHelper GetInstance].m_configInfo setObject:[NSNumber numberWithBool:flag] forKey:config_smartNetwork_remember_me_Flag_key];
}
+ (NSString *) getSmartNetworkAccount
{
    return [[GenieHelper GetInstance].m_configInfo objectForKey:config_smartNetwork_username_key];
}
+ (void) saveSmartNetworkAccount:(NSString*)account
{
    if (!account)
    {
        account = @"";
    }
    [[GenieHelper GetInstance].m_configInfo setObject:account forKey:config_smartNetwork_username_key];
}
+ (NSString *) getSmartNetworkPassword
{
    return [[GenieHelper GetInstance].m_configInfo objectForKey:config_smartNetwork_password_key];
}
+ (void) saveSmartNetworkPassword:(NSString*)password
{
    if (!password)
    {
        password = @"";
    }
    [[GenieHelper GetInstance].m_configInfo setObject:password forKey:config_smartNetwork_password_key];
}

// smart network available 相关
static NSString * smart_network_available_flag_key = @"smart_network_available_flag_key";
+ (BOOL) isSmartNetworkAvailable
{
    NSDictionary * dic = [GenieHelper readFile:Genie_File_SN_SmartNetworkAvailable_Flag_Info];
    if (dic && [[dic objectForKey:smart_network_available_flag_key] boolValue])//smart_network_available_flag 为【真】时，开启smart network
    {
        return YES;
    }
    return NO;
}
+ (void) setSmartNetworkAvailable
{
    [GenieHelper write:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:smart_network_available_flag_key] toFile:Genie_File_SN_SmartNetworkAvailable_Flag_Info];
}


+ (BOOL) isSmartNetwork
{
    return [[GenieHelper shareGenieBusinessHelper].soapHelper isSmartNetwork];
}
+ (void) logoutSmartNetwork
{
    [[GenieHelper shareGenieBusinessHelper].soapHelper logoutSmartNetwork];
    [[GenieHelper shareGenieBusinessHelper].soapHelper setControlPointID:@""];//
}
#pragma mark genie core data
#ifdef __GENIE_IPHONE__
+ (GenieiPhoneiPodAppDelegate*) getGenieDelegate
{
    return (GenieiPhoneiPodAppDelegate*)[UIApplication sharedApplication].delegate;
}
#else
+ (GenieiPadAppDelegate*) getGenieDelegate
{
    return (GenieiPadAppDelegate*)[UIApplication sharedApplication].delegate;
}
#endif

+ (void) InitGenieCoreData
{
    [GenieCoreData GetInstance];
}
+ (void) ReleaseCoreData
{
    [GenieCoreData ReleaseInstance];
}
+ (GenieHomePageController*) getRootViewController
{
    return [[[GenieHelper getGenieDelegate].GenieRootController viewControllers] objectAtIndex:0];
}

+ (GPBusinessHelper*) shareGenieBusinessHelper
{
    return [GenieHelper GetInstance].GenieBusinessHelper;
}

+ (GenieRouterInfo*) getRouterInfo
{
    return [GenieCoreData GetInstance].routerInfo;
}
+ (GenieWirelessData*) getWirelessData
{
    return [GenieCoreData GetInstance].wirelessData;
}
+ (GenieGuestData*) getGuestData
{
    return [GenieCoreData GetInstance].guestData;
}
+ (GenieMapData*) getMapData
{
    return [GenieCoreData GetInstance].mapData;
}
+ (GenieLPCData*) getLPCData
{
    return [GenieCoreData GetInstance].lpcData;
}
+ (GenieTrafficData*) getTrafficData
{
    return [GenieCoreData GetInstance].trafficData;
}

+ (void) setRouterInfo:(GenieRouterInfo*)data
{
    [GenieCoreData GetInstance].routerInfo = data;
    return;
}
+ (void) setWirelessData:(GenieWirelessData*)data
{
    [GenieCoreData GetInstance].wirelessData = data;
    return;
}
+ (void) setGuestData:(GenieGuestData*)data
{
    [GenieCoreData GetInstance].guestData = data;
    return;
}
+ (void) setMapData:(GenieMapData*)data
{
    [GenieCoreData GetInstance].mapData = data;
    return;
}
+ (void) setLPCData:(GenieLPCData*)data
{
    [GenieCoreData GetInstance].lpcData = data;
    return;
}
+ (void) setTrafficData:(GenieTrafficData*)data
{
    [GenieCoreData GetInstance].trafficData = data;
    return;
}
+ (void) clearGenieCoreData
{
    [[GenieCoreData GetInstance] clear];
}
#pragma mark custom box
+(void) showMsgBoxWithMsg:(NSString*)msg
{
    [GenieHelper showMsgBoxWithMsg:msg cancelBtn:Localization_Close];
}
+(void) showMsgBoxWithMsg:(NSString *)msg cancelBtn:(NSString*)btn
{
    UIAlertView * msgBox = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:btn otherButtonTitles:nil];
    [msgBox show];
    [msgBox release];
}


#define Genie_AlertView_Tag_GobackToMainPagePrompt 4000
+ (void) showGobackToMainPageMsgBoxWithMsg:(NSString*)msg //"OK"btn
{
    [GenieHelper showGobackToMainPageMsgBoxWithMsg:msg cancelBtn:Localization_Ok];
}
+ (void) showGobackToMainPageMsgBoxWithMsg:(NSString *)msg cancelBtn:(NSString*)btn
{
    UIAlertView * msgBox = [[UIAlertView alloc] initWithTitle:nil 
                                                      message:msg 
                                                     delegate:[GenieHelper GetInstance] 
                                            cancelButtonTitle:btn otherButtonTitles:nil];
    msgBox.tag = Genie_AlertView_Tag_GobackToMainPagePrompt;
    [msgBox show];
    [msgBox release];
}

+ (void) showRebootRouterPrompt:(NSString*)prompt WithDelegate:(id)alertDelegate
{
    UIAlertView * rebootPromptAlert = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:alertDelegate cancelButtonTitle:Localization_Cancel otherButtonTitles:Localization_Ok, nil];
    rebootPromptAlert.tag = Genie_AlertView_Tag_RebootRouterPrompt;
    [rebootPromptAlert show];
    [rebootPromptAlert release];
}
#pragma mark file manage
+ (NSString*) readRouterIconFromXMLWithModelName:(NSString*)routerModel
{
    //58种路由器
    NSString * img = nil;
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GenieRouterModelName2Image" ofType:@"plist"]];
    GeniePrint(@"routerModal----->Img", dic);
    if (routerModel)
    {
        for (NSString* key in [dic allKeys])
        {
            if ([routerModel rangeOfString:key].length > 0)
            {
                img = [dic objectForKey:key];
                break;
            }
        }
    }
    return img;
}
+ (NSDictionary*) readDeviceTypeString2DeviceIconMapFromXML
{
    //33种设备类型  2012.3.27
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GenieDeviceType2Image" ofType:@"plist"]];
}

+ (NSString*) getFileDomain
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}
+ (BOOL) isFileExistsAtPath:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        return NO;
    }
    return YES;
}
+ (void) write:(NSDictionary*)info toFile:(NSString*)file
{
	NSString *filePath = [NSString stringWithFormat:@"%@/%@",[GenieHelper getFileDomain],file];
    if (![GenieHelper isFileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [info writeToFile:filePath atomically:YES];
}
+ (NSDictionary*) readFile:(NSString*)file
{
	NSString *filePath = [NSString stringWithFormat:@"%@/%@",[GenieHelper getFileDomain],file];
	if(![GenieHelper isFileExistsAtPath:filePath]) 
        return nil;
    else
        return [NSDictionary dictionaryWithContentsOfFile:filePath]; 
}

#pragma mark genie process
+ (void) startGetNetworkMapInfoProcessWithTarget:(id)targer selector:(SEL)selector;
{
    [[[GenieHelper shareGenieBusinessHelper] startGetNetworkMapInfo] setFinishCallback:targer selector:selector];
}


+ (void) generalProcessAsyncOpCallback:(GenieCallbackObj*)obj withErrorCode:(GenieErrorType*)err
{
    if (*err != GenieErrorNoError)
    {
//        *err = obj.error;//timeout or cancel  :GenieErrorAsyncOpTimeout GenieErrorAsyncOpCancel
        return;
    }
    GTAsyncOp * op = (GTAsyncOp*)obj.userInfo;
    if (![op succeeded])
    {
        *err = GenieErrorBadError;
    }
    else
    {
        int rspCode = [op responseCode];
        switch (rspCode)
        {
            case GPBusiness_NoError:
                *err = GenieErrorNoError;
                break;
            //smart network
            case GPBusiness_SN_Authenticate_Failed:
                *err = GenieError_SN_Authenticate_Failed;
                break;
            //fxsoap err
            case GPBusiness_Soap401:
                *err = GenieErrorSoap401;
                break;
            case GPBusiness_Soap501:
                *err = GenieErrorSoap501;
                break;
            //login err  
            case GPBusiness_CSettingFailed:
                *err = GenieErrorNotNetgearRouter;
                break;
            case GPBusiness_Authenticate_KeyInvalid: //GPBusiness_SN_RouterAuth_Failed
                *err = GenieErrorLoginPasskeyInvalid;
                break;
            case GPBusiness_Authenticate_UnknownError:
                *err = GenieErrorLoginPasskeyInvalid;
                break;
            //lpc err
            case GPBusiness_LPC_AuthenticateRouter_Failed:
                *err = GenieError_LPC_AuthenticateRouter_Failed;
                break;
            case GPBusiness_LPC_AutoLogin_Failed:
                *err = GenieError_LPC_AutoLogin_Failed;
                break;
            case GPBusiness_LPC_NoInternet:
                *err = GenieError_LPC_NoInternet;
                break;
            case GPBusiness_LPC_UnavailableAccount:
                *err = GenieError_LPC_UnavailableAccount;
                break;
            case GPBusiness_LPC_CheckUserName_NO:
                *err = GenieError_LPC_CheckUserName_NO;
                break;
            case GPBusiness_LPC_SignInOpenDNS_PassKey_Wrong:
                *err = GenieError_LPC_SignInOpenDNS_PassKey_Wrong;
                break;
            case GPBusiness_LPC_UnexpectedError:
                *err = GenieError_LPC_UnexpectedError;
                break;
            default:
                *err = GenieErrorUnknown;
                break;
        }
    }
}

+ (void) generalProcessGenieError:(GenieErrorType)err
{
    switch ((int)err)
    {
        case GenieErrorAsyncOpCancel:
            [[GenieHelper getGenieDelegate].GenieRootController popToRootViewControllerAnimated:YES];
            break;
        case GenieErrorAsyncOpTimeout:
            [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForTimeout];
            break;
        default:
            [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForTimeout];
            break;
    }
}

//...........
+ (void) configForSetProcessOrLPCProcessStart//if router type is not cg or dg  set process should be wraped
{
    NSString * routerModalStr = [[[GenieHelper getRouterInfo].modelName uppercaseString] substringWithRange:NSMakeRange(0, 2)];
    if ([routerModalStr isEqualToString:@"DG"]||[routerModalStr isEqualToString:@"CG"])
    {
        return;
    }
    else
    {
        [[GenieHelper shareGenieBusinessHelper] setSoapWrapMode:YES];
    }
}
+ (void) resetConfigForSetProcessOrLPCProcessFinish//if router type is not cg or dg  we should reset soap for not wraped
{
    NSString * routerModalStr = [[[GenieHelper getRouterInfo].modelName uppercaseString] substringWithRange:NSMakeRange(0, 2)];
    if ([routerModalStr isEqualToString:@"DG"]||[routerModalStr isEqualToString:@"CG"])
    {
        return;
    }
    else
    {
        [[GenieHelper shareGenieBusinessHelper] setSoapWrapMode:NO];
    }
}


#pragma mark Genie Goback to Rootviewcontroller func  -------time period

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (Genie_AlertView_Tag_GobackToMainPagePrompt == alertView.tag && buttonIndex == 0)
    {
        [[GenieHelper getGenieDelegate].GenieRootController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == Genie_AlertView_Tag_RebootRouterPrompt)
    {
        if (buttonIndex == 0)
        {
            [GenieHelper resetTimePeriodMoniter];
            //[GenieHelper resignTimePeriod];
        }
        else
        {
            [GenieHelper configForSetProcessOrLPCProcessStart];
            GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startCloseGuestAccess];
            [GPWaitDialog show:op withTarget:self selector:@selector(clossGuestAccessCallback:) waitMessage:Local_WaitForSetGuestInfo timeout:Genie_Set_Guest_Process_Timeout cancelBtn:nil needCountDown:YES waitTillTimeout:YES];
        }
    }
}

- (void)clossGuestAccessCallback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    [GenieHelper resignTimePeriod];
    [GenieHelper logoutGenie];
    [[GenieHelper getGenieDelegate].GenieRootController popToRootViewControllerAnimated:YES];
}



                          
@end
