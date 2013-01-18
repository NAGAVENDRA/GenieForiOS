//
//  GEBusinessOp.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPBusinessImpl.h"
#import "GPBusinessCore.h"
#import "FXSoapHelper.h"
#import "LPCCore.h"

@implementation GPBusinessOp
@synthesize  asynOp = m_op;

- (id) initWithCore:(GPBusinessCore*)core
{
    self = [super init];
    if (self)
    {
        [core retain];
        m_core = core;
        m_op = nil;
        m_atomOpMode = GTAsyncOpMode_Unknown;
        m_result = [[NSMutableDictionary alloc] init];
        m_selector = nil;
        m_target = nil;
        m_finished = NO;
        m_succeeded = YES;
        m_aborted = NO;
        m_responseCode = GPBusiness_UnKnownError;
        //[self start];start 必须延迟到子类。 因为start可能会需要子类的成员变量
    }
    return self;
}
- (void) dealloc
{
    self.asynOp = nil;
    [m_result release];
    [m_target release];
    [m_core release];
    [super dealloc];
}
- (void) start
{
    return;
}

- (void) processFinallyResult
{
    if (m_aborted)
    {
        return;
    }
    [self easilyCheckIfNeedNextOp];
    [self notifyFinished];
}

- (void) setCurrentOpMode:(GTAsyncOpMode) mode
{
    m_atomOpMode = mode;
}

- (BOOL) easilyCheckIfNeedNextOp
{
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        [m_result addEntriesFromDictionary:[self.asynOp result]];
        switch (m_atomOpMode)
        {
            case GTAsyncOpMode_FXSoap:
                [self processFXSoapResponseCode];
                break;
            case GTAsyncOpMode_OpneDNS:
                [self processOpneDNSResponseCode];
                break;
            case GTAsyncOpMode_BusinessOp:
                [self processBusinessOpResponseCode];
                break;
            case GTAsyncOpMode_CSSetting:
                m_responseCode = GPBusiness_NoError;
                break;
            default:
                break;
        }
    }
    else
    {
        m_succeeded = NO;
    }
    if (!m_succeeded || m_responseCode != GPBusiness_NoError)
    {
        [self notifyFinished];
        return NO;
    }
    return YES;
}

- (int) processFXSoapResponseCode
{
    int errCode = [self.asynOp responseCode];
    if (errCode == GTStatus_Ok)
    {
        m_responseCode = GPBusiness_NoError;
    }
    else
    {
        m_responseCode = GPBusiness_UnKnownError;
        if (errCode == 401)
        {
            m_responseCode = GPBusiness_Soap401;
        }
        else if (errCode == 501)
        {
            m_responseCode = GPBusiness_Soap501;
        }
        else if (errCode == GTStatus_RouterAuthFailed)
        {
            m_responseCode = GPBusiness_SN_RouterAuth_Failed;
        }
        else if (errCode == GTStatus_SmartNetworkAuthFailed)
        {
            m_responseCode = GPBusiness_SN_Authenticate_Failed;
        }
    }
    return m_responseCode;
}

- (int) processOpneDNSResponseCode
{
    int errCode = [self.asynOp responseCode];
    if (errCode == WTFStatus_NoError)
    {
        m_responseCode = GPBusiness_NoError;
    }
    else if (errCode == WTFStatus_AuthenticationFailed)
    {
        m_responseCode = GPBusiness_LPC_SignInOpenDNS_PassKey_Wrong;
    }
    else
    {
        m_responseCode = GPBusiness_LPC_UnexpectedError;
    }
    return m_responseCode;
}

- (int) processGCSettingOpResponseCode
{
    //
    return m_responseCode;
}
- (int) processBusinessOpResponseCode
{
    m_responseCode = [self.asynOp responseCode];
    return m_responseCode;
}
- (void)notifyFinished
{
    if (m_finished)
    {
        return;
    }
    m_finished = YES;
    if (m_target)
    {
        if (!m_aborted)
        {
            [m_target performSelector:m_selector withObject:self];
        }
        [m_target release];
        m_target = nil;
    }
}

- (BOOL)aborted
{
    return m_aborted;
}

- (BOOL)finished
{
    return m_finished;
}

- (BOOL)succeeded
{
    return m_succeeded;
}


- (BOOL)setFinishCallback:(id)target selector:(SEL)selector
{
    if (m_finished)
    {
        return NO;
    }
    [m_target release];
    m_target = [target retain];
    m_selector = selector;
    return YES;
}

- (void)abort
{
    if (m_finished)
    {
        return;
    }
    m_aborted = YES;
    [m_op abort];
    [m_op release];
    m_op = nil;
    [self notifyFinished];
}

- (NSDictionary*)result
{
    return m_result;
}

- (int)responseCode
{
    return m_responseCode;
}

- (NSString*)stringForKey:(NSString*)key
{
    return [m_result objectForKey:key];
}

- (BOOL)containsKey:(NSString*)key
{
    return [[m_result allKeys] containsObject:key];
}
@end

@implementation GPGetSNRouterListOp

- (id) initWithCore:(GPBusinessCore *)core
{
    self = [super initWithCore:core];
    if (self)
    {
        [self start];
    }
    return self;
}

- (void) start
{
    self.asynOp = [m_core.soapHelper listActiveRouters];
    [self.asynOp setFinishCallback:self selector:@selector(listActiveRouters_callback)];
}

- (void) listActiveRouters_callback
{
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == GTStatus_Ok)
        {
            m_responseCode = GPBusiness_NoError;
            [m_result addEntriesFromDictionary:[self.asynOp result]];
        }
        else if ([self.asynOp responseCode] == GTStatus_SmartNetworkAuthFailed)
        {
            m_responseCode = GPBusiness_SN_Authenticate_Failed;
        }
        else
        {
            m_responseCode = GPBusiness_UnKnownError;
        }
    }
    else
    {
        m_succeeded = NO;
    }
    [self notifyFinished];
}
@end

@implementation GPRouterLoginOp
- (id) initWithCore:(GPBusinessCore *)core admin:(NSString*)admin password:(NSString*)password controlPointID:(NSString*)controlPointID
{
    self = [super initWithCore:core];
    if (self)
    {
        m_admin = [admin retain];
        m_password = [password retain];
        m_controlPointID = [controlPointID retain];
        [m_core.soapHelper setRouterUsername:m_admin password:m_password];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_controlPointID release];
    [m_admin release];
    [m_password release];
    [super dealloc];
}

- (void) startSmartNetworkRouterLogin
{
    //关闭session
    self.asynOp = [m_core.soapHelper closeSession];
    
    if (!self.asynOp)//第一次 session id 为空，直接返回， self.asynop = nil
    {
        [self performSelector:@selector(closeSession_smartnetwork_callback)];
    }
    else
    {
        [self.asynOp setFinishCallback:self selector:@selector(closeSession_smartnetwork_callback)];
    }
}

- (void) startLocalyRouterLogin
{
    self.asynOp = [m_core.webInfoHelper getcurrentSetting];
    [self setCurrentOpMode:GTAsyncOpMode_CSSetting];
    [self.asynOp setFinishCallback:self selector:@selector(getRouterType_Callback)];
}

- (BOOL) isSmartNetwork
{
    if (![m_controlPointID length])
        return NO;
    return YES;
}

- (void) start
{
    if (![self isSmartNetwork])
    {
        [self startLocalyRouterLogin];
    }
    else
    {
        [self startSmartNetworkRouterLogin];
    }
}

//startLocalyRouterLogin
- (void) getRouterType_Callback
{
    if (m_aborted)
    {
        return;
    }
    //getRouterType需要进行特定分析，不是一个简单的get流程，所以不能用easilyCheckIfNeedNextOp方法进行通用处理
    m_succeeded = YES;//取currentsetting 出错，则认定为非路由器，login流程正常结束。
    NSString * routerModalStr = nil;
    if (![self.asynOp succeeded])
    {
        m_responseCode = GPBusiness_CSettingFailed;
    }
    else
    {
        NSString * CurrentSetting_Model_String = @"Model";
        routerModalStr = [self.asynOp stringForKey:[CurrentSetting_Model_String lowercaseString]];
        if ([routerModalStr length] > 0)
        {
            [m_result addEntriesFromDictionary:[self.asynOp result]];
            m_responseCode = GPBusiness_NoError;
        }
        else
        {
            m_responseCode = GPBusiness_CSettingFailed;
        }
    }
    if (m_responseCode != GPBusiness_NoError)
    {
        [self notifyFinished];
    }
    else
    {
        //sentFinishConfigurationAction  
        self.asynOp = [m_core.soapHelper DeviceConfig_ConfigurationFinished:@"ChangesApplied"];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(sentFinishConfigurationAction_Callback)];
        //________________
        NSString * typeStr = [[routerModalStr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
        if ([typeStr isEqualToString:@"DG"]||[typeStr isEqualToString:@"CG"])
        {
            [m_core setSoapWrapMode:YES];
        }
        else
        {
            [m_core setSoapWrapMode:NO];
        }
    }
}

- (void) closeSession_smartnetwork_callback
{
    //对于关闭session这个操作，不需要关心它是否调用成功，只要操作回调就执行下一步操作
    [m_core.soapHelper setControlPointID:m_controlPointID];
    
    //获取路由器类型 ，先默认为是DG CG等型号处理
    [m_core setSoapWrapMode:YES];//
    self.asynOp = [m_core.soapHelper DeviceInfo_GetInfo];
    [self.asynOp setFinishCallback:self selector:@selector(getRouterType_Callback_SmartNetwork)];
}

- (void) getRouterType_Callback_SmartNetwork
{
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        NSInteger rsp = [self processFXSoapResponseCode];
        if (rsp == GPBusiness_NoError)
        {
            static NSString * DeviceInfo_ModelName = @"ModelName";
            NSString * routerModalStr = [self.asynOp stringForKey:DeviceInfo_ModelName];
            //sentFinishConfigurationAction  
            self.asynOp = [m_core.soapHelper DeviceConfig_ConfigurationFinished:@"ChangesApplied"];
            [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
            [self.asynOp setFinishCallback:self selector:@selector(sentFinishConfigurationAction_Callback)];
            //________________
            NSString * typeStr = [[routerModalStr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
            if ([typeStr isEqualToString:@"DG"]||[typeStr isEqualToString:@"CG"])
            {
                [m_core setSoapWrapMode:YES];
            }
            else
            {
                [m_core setSoapWrapMode:NO];
            }
        }
        else 
        {
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

- (void) sentFinishConfigurationAction_Callback//每次在登陆时，对路由器发送一个finish命令，用来保存之前的设置。
{
    if (m_aborted)
    {
        return;
    }
    self.asynOp = [m_core.soapHelper ParentalControl_Authenticate:m_admin NewPassword:m_password];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_Authenticate_Callback)];
}

- (void) ParentalControl_Authenticate_Callback
{
    if (m_aborted)
    {
        return;
    }
    //分析router认证结果  0---successed   401-----Invalid username and/or password  2 --- error
    if (![self.asynOp succeeded])
    {
        m_succeeded = NO;
    }
    else
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == 0)
        {
            m_responseCode = GPBusiness_NoError;
        }
        else if ([self.asynOp responseCode] == 401)
        {
            m_responseCode = GPBusiness_Authenticate_KeyInvalid;
        }
        else
        {
            [self processFXSoapResponseCode];
        }
    }
    if (!m_succeeded || m_responseCode != GPBusiness_NoError)
    {
        [self notifyFinished];
    }
    else
    {
        GPGetRouterInfoOp * op = [[GPGetRouterInfoOp alloc] initWithCore:m_core];
        self.asynOp = op;
        [op release];
        [self setCurrentOpMode:GTAsyncOpMode_BusinessOp];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];//这是一个get流程，用通用处理就可以了
    }
}


@end

@implementation GPGetRouterInfoOp
- (id) initWithCore:(GPBusinessCore *)core
{
    self = [super initWithCore:core];
    if (self)
    {
        [self start];
    }
    return self;
}

- (void) start
{
    self.asynOp = [m_core.soapHelper DeviceInfo_GetInfo];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(DeviceInfo_GetInfo_Callback)];
}

- (void) DeviceInfo_GetInfo_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_GetInfo];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}
@end

@implementation GPGetWirelessOp
- (id) initWithCore:(GPBusinessCore *)core
{
    self = [super initWithCore:core];
    if (self)
    {
        [self start];
    }
    return self;
}

- (void) start
{
    self.asynOp = [m_core.soapHelper WLANConfiguration_GetInfo];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(WLANConfiguration_GetInfo_Callback)];
}

/////////////////
- (void) WLANConfiguration_GetInfo_Callback
{
    if (m_aborted)
    {
        return;
    }
    BOOL ret = [self easilyCheckIfNeedNextOp];
    if (ret)
    {
        NSString * basicEncryption = [m_result valueForKey:@"NewBasicEncryptionModes"];
        if ([[basicEncryption uppercaseString] isEqualToString:@"NONE"])
        {
            [self notifyFinished];
            return;
        }
        else if ([[basicEncryption uppercaseString] isEqualToString:@"WEP"])
        {
            self.asynOp = [m_core.soapHelper WLANConfiguration_GetWEPSecurityKeys];
        }
        else
        {
            self.asynOp = [m_core.soapHelper WLANConfiguration_GetWPASecurityKeys];
        }
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}

@end


@implementation GPGetGuestOp
- (id) initWithCore:(GPBusinessCore *)core
{
    self = [super initWithCore:core];
    if (self)
    {
        [self start];
    }
    return self;
}

- (void) start
{
    self.asynOp = [m_core.soapHelper WLANConfiguration_GetGuestAccessEnabled];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(WLANConfiguration_GetGuestAccessEnabled_Callback)];
}

- (void) WLANConfiguration_GetGuestAccessEnabled_Callback
{
    if (m_aborted)
    {
        return;
    }
    BOOL ret = [self easilyCheckIfNeedNextOp];
    if(ret)
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_GetGuestAccessNetworkInfo];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}

@end


@implementation GPGetTrafficOp
- (id) initWithCore:(GPBusinessCore *)core
{
    self = [super initWithCore:core];
    if (self)
    {
        [self start];
    }
    return self;
}

- (void) start
{
    self.asynOp = [m_core.soapHelper DeviceConfig_GetTrafficMeterEnabled];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(DeviceConfig_GetTrafficMeterEnabled_Callback)];
}

- (void) DeviceConfig_GetTrafficMeterEnabled_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        NSString * enableStatus = [m_result valueForKey:@"NewTrafficMeterEnable"];
        if ([enableStatus isEqualToString:@"1"])
        {
            [self performSelector:@selector(getTrafficMeterOptions) withObject:nil afterDelay:6];
            return;
        }
        [self notifyFinished];
    }
}

- (void) getTrafficMeterOptions
{
    self.asynOp = [m_core.soapHelper DeviceConfig_GetTrafficMeterOptions];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(DeviceConfig_GetTrafficMeterOptions_Callback)];
}

- (void) DeviceConfig_GetTrafficMeterOptions_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        self.asynOp = [m_core.soapHelper DeviceConfig_GetTrafficMeterStartistics];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}

@end

@implementation GPGetNetworkMapOp
- (id) initWithCore:(GPBusinessCore *)core
{
    self = [super initWithCore:core];
    if (self)
    {
        [self start];
    }
    return self;
}

- (void) getBlockDeviceInfo
{
    self.asynOp = [m_core.soapHelper DeviceConfig_GetBlockDeviceEnableStatus];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(DeviceConfig_GetBlockDeviceEnableStatus_Callback)];
}

- (void) startGetLocalNetworkMapOp
{
    self.asynOp = [m_core.webInfoHelper getcurrentSetting];
    [self setCurrentOpMode:GTAsyncOpMode_CSSetting];
    [self.asynOp setFinishCallback:self selector:@selector(getRouterInternetStatus_Callback)];
}

- (void) startGetRemoteNetworkMapOp
{
    [self getBlockDeviceInfo];
}

- (void)start
{
    if ([m_core.soapHelper isSmartNetwork])
    {
        [self startGetRemoteNetworkMapOp];
    }
    else
    {
        [self startGetLocalNetworkMapOp];
    }
}

- (void) getRouterInternetStatus_Callback
{
    if (m_aborted)
    {
        return;
    }
    
    /* 不需要关注currentsetting的结果，因为其结果只是为了获取路由器的网络状态
    if ([self easilyCheckIfNeedNextOp])
    {
        [self getBlockDeviceInfo];
    }
    */
    [self easilyCheckIfNeedNextOp];
    [self getBlockDeviceInfo];
}

- (void) DeviceConfig_GetBlockDeviceEnableStatus_Callback
{
    if (m_aborted)
    {
        return;
    }
    //不是所有的路由器都支持block功能,所以本op的responseCode和result结果不会影响后面的调用，需要特殊处理
    if (![self.asynOp succeeded])
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
    else
    {
        m_succeeded = YES;
        [m_result addEntriesFromDictionary:[self.asynOp result]];
        self.asynOp = [m_core.soapHelper DeviceInfo_GetAttachDevice];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}
@end

@implementation GPGetLPCAccountRelayOp
- (id) initWithCore:(GPBusinessCore *)core token:(NSString*)token
{
    self = [super initWithCore:core];
    if (self)
    {
        m_token = [token retain];
        [self start];
    }
    return self;
}
- (void) dealloc
{
    [m_token release];
    [super dealloc];
}
- (void) start
{
    self.asynOp = [m_core.lpcHelper accountRelay:m_token];
    [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
    [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
}
@end

@implementation GPLPCCreateAccountOp
- (id) initWithCore:(GPBusinessCore *)core userName:(NSString*)userName password:(NSString*)password email:(NSString*)email
{
    self = [super initWithCore:core];
    if (self)
    {
        m_userName = [userName retain];
        m_password = [password retain];
        m_email = [email retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_userName release];
    [m_password release];
    [m_email release];
    [super dealloc];
}
- (void) start
{
    self.asynOp = [m_core.lpcHelper checkNameAvailable:m_userName];
    [self.asynOp setFinishCallback:self selector:@selector(checkNameAvailable_Callback)];
}
- (void) checkNameAvailable_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == WTFStatus_NoError)
        {
            if ([(NSNumber*)[[self.asynOp result] objectForKey:@"varAvailable"] boolValue])
            {
                self.asynOp = [m_core.lpcHelper createAccount:m_userName password:m_password email:m_email];
                [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
                [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
            }
            else
            {
                m_responseCode = GPBusiness_LPC_CheckUserName_NO;
                [self notifyFinished];
            }
        }
        else
        {
            m_responseCode = GPBusiness_LPC_UnexpectedError;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
@end

@implementation GPQueryLpcInfoOp

- (id) initWithCore:(GPBusinessCore *)core admin:(NSString *)admin password:(NSString *)password openDNSAccount:(NSString*)openDNSAccount openDNSKey:(NSString*) openDNSPassword deviceKey:(NSString *)deviceKey
{
    self = [super initWithCore:core];
    if (self)
    {
        m_routerAdmin = [admin retain];
        m_routerPassword = [password retain];
        m_openDNSAccount = [openDNSAccount retain];
        m_openDNSPassword = [openDNSPassword retain];
        m_deviceKey = [deviceKey retain];
        m_token = nil;
        m_deviceID = nil;
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_routerAdmin release];
    [m_routerPassword release];
    [m_openDNSAccount release];
    [m_openDNSPassword release];
    [m_deviceKey release];
    [m_token release];
    [m_deviceID release];
    [super dealloc];
}

- (void) start
{
    self.asynOp = [m_core.lpcHelper login:m_openDNSAccount password:m_openDNSPassword];
    [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
    [self.asynOp setFinishCallback:self selector:@selector(openDNS_Login_Callback)];
}

- (void) openDNS_Login_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        m_token = [[self.asynOp stringForKey:@"varToken"] retain];
        self.asynOp = [m_core.soapHelper ParentalControl_Authenticate:m_routerAdmin NewPassword:m_routerPassword];
        [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_Authenticate_Callback)];
    }
}
- (void) ParentalControl_Authenticate_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        int rsp = [self.asynOp responseCode];
        if (rsp == 0)
        {
            self.asynOp = [m_core.soapHelper ParentalControl_GetDNSMasqDeviceID];
            [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
            [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_GetDNSMasqDeviceID_Callback)];
        }
        else
        {
            m_responseCode = GPBusiness_LPC_AuthenticateRouter_Failed;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

- (void) setNewDeviceID
{
    self.asynOp = [m_core.lpcHelper getDevice:m_token deviceKey:m_deviceKey];
    [self.asynOp setFinishCallback:self selector:@selector(openDNS_GetDevice_Callback)];
}
- (void) getLPCInformation
{
    self.asynOp = [m_core.soapHelper ParentalControl_GetEnableStatus];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_GetEnableStatus_Callback)];
}
- (void) ParentalControl_GetDNSMasqDeviceID_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        [m_deviceID release];
        m_deviceID = [[self.asynOp stringForKey:@"NewDeviceID"] retain]; 
        if (![m_deviceID length])//NewDeviceID is None
        {
            [self setNewDeviceID];
        }
        else
        {
            self.asynOp = [m_core.lpcHelper getLabel:m_token deviceId:m_deviceID];
            [self.asynOp setFinishCallback:self selector:@selector(openDNS_GetLabel_Callback)];
        }
    }
}

- (void) openDNS_GetLabel_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        NSInteger rsp = [self.asynOp responseCode];
        if (rsp == WTFStatus_UnexpectedError)
        {
            m_responseCode = GPBusiness_LPC_UnexpectedError;
            [self notifyFinished];
        }
        if (rsp == WTFStatus_Failed)
        {
            int err = [(NSNumber*)[[self.asynOp result] valueForKey:@"varErrorCode"] intValue];
            if (err == 4003)
            {
                //clear deviceID
                [m_deviceID release];
                m_deviceID = nil;
            }
            else if (err == 4001)//this is not my device
            {
                m_responseCode = GPBusiness_LPC_UnavailableAccount;
                [self notifyFinished];
            }
        }
        if ([m_deviceID length])
        {
            //get lpc info
            [self getLPCInformation];
        }
        else
        {
            [self setNewDeviceID];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

///////setNewDeviceID callback
- (void) openDNS_GetDevice_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        NSInteger rsp = [self.asynOp responseCode];
        if (rsp == WTFStatus_NoError)
        {
            //soap  WrapSetDeviceID
            [m_deviceID release];
            m_deviceID = [[self.asynOp stringForKey:@"varDeviceID"] retain];
            self.asynOp = [m_core.soapHelper ParentalControl_SetDNSMasqDeviceID:m_deviceID];
            [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_SetDNSMasqDeviceID_Callback)];
        }
        else if (rsp == WTFStatus_Failed)
        {
            //create device
            self.asynOp = [m_core.lpcHelper createDevice:m_token deviceKey:m_deviceKey];
            [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
            [self.asynOp setFinishCallback:self selector:@selector(openDNS_CreateDevice_Callback)];
        }
        else
        {
            m_responseCode = GPBusiness_LPC_UnexpectedError;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

- (void) openDNS_CreateDevice_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        [m_deviceID release];
        m_deviceID = [[self.asynOp stringForKey:@"varDeviceID"] retain];
        self.asynOp = [m_core.soapHelper ParentalControl_SetDNSMasqDeviceID:m_deviceID];
        [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_SetDNSMasqDeviceID_Callback)];
    }
}

- (void) ParentalControl_SetDNSMasqDeviceID_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        //SetDNSMasqDeviceID出错的情况不处理，因为不会影响到当前UI以及下一步的获取LPC数据的流程
        //get lpc info
        [self getLPCInformation];
    }
    else
    {
        m_succeeded = NO;
    }
}

//////////getLPCInformation callback
- (void) ParentalControl_GetEnableStatus_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self easilyCheckIfNeedNextOp])
    {
        //get Filter
        if ([[self.asynOp stringForKey:@"ParentalControl"] isEqualToString:@"1"])
        {
            self.asynOp = [m_core.lpcHelper getFilters:m_token deviceId:m_deviceID];
            [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
            [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
        }
        else
        {
            [self notifyFinished];
        }
    }
}
@end


@implementation GPLPCAutoLoginOp
- (id) initWithCore:(GPBusinessCore *)core admin:(NSString *)admin password:(NSString *)password openDNSAccount:(NSString*)openDNSAccount openDNSKey:(NSString*) openDNSPassword deviceKey:(NSString*)deviceKey autoLogin:(BOOL) autoLogin
{
    self = [super initWithCore:core];
    if (self)
    {
        m_routerAdmin = [admin retain];
        m_routerPassword = [password retain];
        m_openDNSAccount = [openDNSAccount retain];
        m_openDNSPassword = [openDNSPassword retain];
        m_deviceKey = [deviceKey retain];
        m_autoLoginWithRegister = autoLogin;
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_openDNSPassword release];
    [m_openDNSAccount release];
    [m_routerPassword release];
    [m_routerAdmin release];
    [m_deviceKey release];
    [super dealloc];
}
static NSString * openDNSHost = @"using.netgear.opendns.com";
- (void) start
{
    self.asynOp = [DNSQueryOp query:openDNSHost];
    [self.asynOp setFinishCallback:self selector:@selector(pingOpenDNSHost_Callback)];
}

- (void) pingOpenDNSHost_Callback
{
    if (m_aborted)
    {
        return;
    }
    m_succeeded = YES;//elf.asyncOp是否successed 都是有意义的状态,它表明了openDNS主机是否可达这一状态。
    if ([self.asynOp succeeded])//可以ping通OpenDNS host
    {
        if (m_autoLoginWithRegister)
        {
            //SignIn Process
            GPQueryLpcInfoOp * op = [[GPQueryLpcInfoOp alloc] initWithCore:m_core admin:m_routerAdmin password:m_routerPassword openDNSAccount:m_openDNSAccount openDNSKey:m_openDNSPassword deviceKey:m_deviceKey];
            self.asynOp = op;
            [self.asynOp setFinishCallback:self selector:@selector(autoLogin_Callback)];
            [op release];
        }
        else
        {
            m_responseCode = GPBusiness_NoError;
            [self notifyFinished];
        }
    }
    else
    {
        m_responseCode = GPBusiness_LPC_NoInternet;
        [self notifyFinished];
    }
}

- (void) autoLogin_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        [m_result addEntriesFromDictionary:[self.asynOp result]];
        int rsp = [self.asynOp responseCode];
        if (rsp == GPBusiness_LPC_AuthenticateRouter_Failed)
        {
            m_responseCode = rsp;
        }
        else if ([self.asynOp responseCode] == GPBusiness_NoError)
        {
            m_responseCode = GPBusiness_NoError;
        }
        else
        {
            m_responseCode = GPBusiness_LPC_AutoLogin_Failed;
        }
    }
    else
    {
        m_succeeded = NO;
    }
    [self notifyFinished];
}
@end


@implementation GPGetLPCBypassAccountInfo
- (id) initWithCore:(GPBusinessCore *)core deviceID:(NSString*)deviceID mac:(NSString*) mac
{
    self = [super initWithCore:core];
    if (self)
    {
        m_mainDeviceID = [deviceID retain];
        m_mac = [mac retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_mainDeviceID release];
    [m_mac release];
    [super dealloc];
}

- (void) start
{
    self.asynOp = [m_core.soapHelper ParentalControl_GetDNSMasqDeviceIDForChild:m_mac];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_GetDNSMasqDeviceIDForChild_callback)];
}

- (void) getUsersForParentalDevice
{
    self.asynOp = [m_core.lpcHelper getUsersForDeviceId:m_mainDeviceID];
    [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
    [self.asynOp setFinishCallback:self selector:@selector(getUsersForParentalDevice_callback)];
}

- (void) getUsersForParentalDevice_callback
{
    if (m_aborted)
    {
        return;
    }
    
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        m_responseCode = GPBusiness_NoError;//此时，不论是否取到子账户列表，都认为NoError
        
        NSInteger err = [self.asynOp responseCode];
        if (err == WTFStatus_NoError)
        {
            [m_result addEntriesFromDictionary:[self.asynOp result]];
        }
        else
        {
            [m_result setObject:[NSArray array] forKey:@"varList"];//没有取到设备时，置列表为空
        }
    }
    else
    {
        m_succeeded = NO;
    }
    [self notifyFinished];
}

- (void) ParentalControl_GetDNSMasqDeviceIDForChild_callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        NSString * childDevice_id = [self.asynOp stringForKey:@"NewDeviceID"];
        if (childDevice_id)
        {
            self.asynOp = [m_core.lpcHelper getUserForChildDeviceId:childDevice_id];
            [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
            [self.asynOp setFinishCallback:self selector:@selector(getUserForChildDeviceId_callback)];
        }
        else
        {
            [self getUsersForParentalDevice];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
- (void) getUserForChildDeviceId_callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        int rsp = [self.asynOp responseCode];
        
        if (rsp == WTFStatus_NoError)
        {
            m_succeeded = YES;
            m_responseCode = GPBusiness_NoError;
            [m_result addEntriesFromDictionary:[self.asynOp result]];//若果已经有子账户登陆，直接返回
            [self notifyFinished];
        }
        else
        {
            [self getUsersForParentalDevice];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

@end

@implementation GPLoginLPCBypassAccoutOp
- (id) initWithCore:(GPBusinessCore *)core routerAdmin:(NSString*)admin routerPassword:(NSString*)routerPassword account:(NSString*) account password:(NSString*) password parentalDeviceID:(NSString*) deviceID mac:(NSString*) mac
{
    self = [super initWithCore:core];
    if (self)
    {
        m_routerAdmin = [admin retain];
        m_routerPassword = [routerPassword retain];
        m_account = [account retain];
        m_password = [password retain];
        m_parentalDeviceID = [deviceID retain];
        m_mac = [mac retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_routerAdmin release];
    [m_routerPassword release];
    [m_account release];
    [m_password release];
    [m_parentalDeviceID release];
    [m_mac release];
    [super dealloc];
}

- (void) start
{
    self.asynOp = [m_core.soapHelper ParentalControl_Authenticate:m_routerAdmin NewPassword:m_routerPassword];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_Authenticate_Callback)];
}

- (void) ParentalControl_Authenticate_Callback
{
    if (m_aborted)
    {
        return;
    }
    
    if ([self easilyCheckIfNeedNextOp])
    {
        self.asynOp = [m_core.lpcHelper getDeviceChild:m_parentalDeviceID username:m_account password:m_password];
        [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
        [self.asynOp setFinishCallback:self selector:@selector(getDeviceChild_callback)];
    }
}

- (void) getDeviceChild_callback
{
    if (m_aborted)
    {
        return;
    }
    
    if ([self easilyCheckIfNeedNextOp])
    {
        NSString * childDeviceID = [self.asynOp stringForKey:@"varChildDeviceId"];
        self.asynOp = [m_core.soapHelper ParentalControl_SetDNSMasqDeviceID:childDeviceID mac:m_mac];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}
@end

@implementation GPLogoutLPCBypassAccountOp

- (id) initWithCore:(GPBusinessCore *)core routerAdmin:(NSString*)admin routerPassword:(NSString*)routerPassword mac:(NSString*)mac
{
    self = [super initWithCore:core];
    if (self)
    {
        m_routerAdmin = [admin retain];
        m_routerPassword = [routerPassword retain];
        m_mac = [mac retain];
        [self start];
    }
    return self;
}
- (void) dealloc
{
    [m_routerAdmin release];
    [m_routerPassword release];
    [m_mac release];
    [super dealloc];
}
- (void) start
{
    self.asynOp = [m_core.soapHelper ParentalControl_Authenticate:m_routerAdmin NewPassword:m_routerPassword];
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_Authenticate_Callback)];
}

- (void) ParentalControl_Authenticate_Callback
{
    if (m_aborted)
    {
        return;
    }
    
    if ([self easilyCheckIfNeedNextOp])
    {
        self.asynOp = [m_core.soapHelper ParentalControl_DeleteMACAddress:m_mac];
        [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
}
@end

@implementation GPSetWirelessOp
/*
@synthesize ssid = m_ssid;
@synthesize password = m_password;
@synthesize channel = m_channel;
@synthesize securityMode = m_securityMode;
 */

- (id) initWithCore:(GPBusinessCore *)core ssid:(NSString*)ssid region:(NSString*)region channel:(NSString*)channel wirelessMode:(NSString*)wirelessMode securityMode:(NSString*)securitymode WPAPassPhrase:(NSString*)phrase
{
    self = [super initWithCore:core];
    if (self)
    {
        m_ssid = [ssid retain];
        m_password = [phrase retain];
        m_channel = [channel retain];
        m_securityMode = [securitymode retain];
        m_region = [region retain];
        m_wirelessMode = [wirelessMode retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_ssid release];
    [m_securityMode release];
    [m_channel release];
    [m_password release];
    [m_region release];
    [m_wirelessMode release];
    [super dealloc];
}

- (void) start
{
    if (!m_password || !m_securityMode || [[m_securityMode lowercaseString] isEqualToString:@"none"])
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_SetWLANNoSecurityWithSSID:m_ssid region:m_region channel:m_channel wirelessMode:m_wirelessMode];
    }
    else
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_SetWLANWPAPSKByPassphraseWithSSID:m_ssid region:m_region channel:m_channel wirelessMode:m_wirelessMode securityMode:m_securityMode WPAPassPhrase:m_password];
    }
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
}

@end


@implementation GPSetGuestOp
- (id) initWithCore:(GPBusinessCore *)core enable:(NSString*)enable ssid:(NSString*)ssid securityMode:(NSString*)securityMode key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3 key4:(NSString*)key4
{
    self = [super initWithCore:core];
    if (self)
    {
        m_enabled = [enable retain];
        m_ssid = [ssid retain];
        m_securityMode = [securityMode retain];
        m_key1 = [key1 retain];
        m_key2 = [key2 retain];
        m_key3 = [key3 retain];
        m_key4 = [key4 retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_enabled release];
    [m_ssid release];
    [m_securityMode release];
    [m_key1 release];
    [m_key2 release];
    [m_key3 release];
    [m_key4 release];
    [super dealloc];
}

- (void) start
{
    if ([m_enabled isEqualToString:@"0"])
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_SetGuedtAccessEnabled];
    }
    else if ([m_enabled isEqualToString:@"1"])
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_SetGuestAccessEnabled2ssid:m_ssid securityMode:m_securityMode key1:m_key1 key2:m_key2 key3:m_key3 key4:m_key4];
    }
    else
    {
        self.asynOp = [m_core.soapHelper WLANConfiguration_SetGuestAccessNetworkSsid:m_ssid securityMode:m_securityMode key1:m_key1 key2:m_key2 key3:m_key3 key4:m_key4];
    }
    [self setCurrentOpMode:GTAsyncOpMode_FXSoap];
    [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
}
@end


@implementation GPSetEnableBlockStatusOp
- (id) initWithCore:(GPBusinessCore *)core enable:(NSString *)enable
{
    self = [super initWithCore:core];
    if (self)
    {
        m_enable = [enable retain];
        [self start];
    }
    return self;
}

- (void) setEnableBlockStatus
{
    self.asynOp = [m_core.soapHelper DeviceConfig_SetBlockDeviceEnable:m_enable];
    [self.asynOp setFinishCallback:self selector:@selector(DeviceConfig_SetBlockDeviceEnable_Callback)];
}
- (void) dealloc
{
    [m_enable release];
    [super dealloc];
}
- (void) start
{
    if ([m_enable isEqualToString:@"1"])
    {
        self.asynOp = [m_core.soapHelper DeviceConfig_EnableBlockDeviceForAll];
        [self.asynOp setFinishCallback:self selector:@selector(DeviceConfig_EnableBlockDeviceForAll_Callback)];
    }
    else
    {
        [self setEnableBlockStatus];
    }
}
- (void) DeviceConfig_EnableBlockDeviceForAll_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == 0)
        {
            m_responseCode = GPBusiness_NoError;
            [self setEnableBlockStatus];
        }
        else
        {
            m_responseCode = GPBusiness_UnKnownError;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

- (void) DeviceConfig_SetBlockDeviceEnable_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        //不论设置block status是否成功 都需要刷新attachdevice数据  因为EnableBlockDeviceForAll调用成功了
        GPGetNetworkMapOp * op = [[GPGetNetworkMapOp alloc] initWithCore:m_core];
        self.asynOp = op;
        [op release];
        [self setCurrentOpMode:GTAsyncOpMode_BusinessOp];
        [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
@end

@implementation GPSetDeviceBlockOrAllowOp
- (id) initWithCore:(GPBusinessCore *)core macAddr:(NSString *)mac allowOrBlock:(NSString *)allowOrBlock
{
    self = [super initWithCore:core];
    if (self)
    {
        m_deviceMac = [mac retain];
        m_allowOrBlock = [allowOrBlock retain]; 
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_allowOrBlock release];
    [m_deviceMac release];
    [super dealloc];
}

- (void) start
{
    self.asynOp = [m_core.soapHelper DeviceConfig_SetBlockDeviceByMAC:m_deviceMac block:m_allowOrBlock];
    [self.asynOp setFinishCallback:self selector:@selector(DeviceConfig_SetBlockDeviceByMAC_Callback)];
}

- (void) DeviceConfig_SetBlockDeviceByMAC_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == 0)
        {
            GPGetNetworkMapOp * op = [[GPGetNetworkMapOp alloc] initWithCore:m_core];
            self.asynOp = op;
            [op release];
            [self setCurrentOpMode:GTAsyncOpMode_BusinessOp];
            [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
        }
        else
        {
            m_responseCode = GPBusiness_UnKnownError;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
@end


@implementation GPSetTrafficOp
- (id) initWithCore:(GPBusinessCore *)core enable:(NSString *)enable controlMode:(NSString*)controlMode monthlyLimit:(NSString*)monthlyLimit restartDay:(NSString*)day hour:(NSString*)hour minute:(NSString*)minute
{
    self = [super initWithCore:core];
    if (self)
    {
        m_enable = [enable retain];
        m_controlMode = [controlMode retain];
        m_monthlyLimit = [monthlyLimit retain];
        m_restartDay = [day retain];
        m_restartHour = [hour retain];
        m_restartMinute = [minute retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_enable release];
    [m_controlMode release];
    [m_monthlyLimit release];
    [m_restartDay release];
    [m_restartHour release];
    [m_restartMinute release];
    [super dealloc];
}

- (void) start
{
    if (![m_enable length])
    {
        self.asynOp = [m_core.soapHelper DeviceConfig_SetTrafficMeterOptionsControlMode:m_controlMode monthlyLimit:m_monthlyLimit restartHour:m_restartHour minute:m_restartMinute day:m_restartDay];
        [self.asynOp setFinishCallback:self selector:@selector(setTrafficMeterOptions_Callback)];
    }
    else
    {
        SEL selector = nil;
        if ([m_enable isEqualToString:@"1"])//open traffic meter
        {
            selector = @selector(openTrafficMeter_Callback);
        }
        else if ([m_enable isEqualToString:@"0"])//close traffic meter
        {
            selector = @selector(closeTrafficMeter_Callback);
        }
        self.asynOp = [m_core.soapHelper DeviceConfig_EnableTrafficMeter:m_enable];
        [self.asynOp setFinishCallback:self selector:selector];
    }
}


//注意：trafficMeter的设置流程中，返回码responseCode可能会出现1的情况  1 (reboot required)  但是，设置已经成功  
- (void) setTrafficMeterOptions_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == 0 || [self.asynOp responseCode] == 1)
        {
            m_responseCode = GPBusiness_NoError;
        }
        [self notifyFinished];
    }
    else 
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
- (void) closeTrafficMeter_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == 0 || [self.asynOp responseCode] == 1)
        {
            m_responseCode = GPBusiness_NoError;
        }
        [self notifyFinished];
    }
    else 
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
- (void) openTrafficMeter_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        if ([self.asynOp responseCode] == 0 || [self.asynOp responseCode] == 1)
        {
            m_responseCode = GPBusiness_NoError;
            GPGetTrafficOp * op = [[GPGetTrafficOp alloc] initWithCore:m_core];
            self.asynOp = op;
            [op release];
            [self setCurrentOpMode:GTAsyncOpMode_BusinessOp];
            [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
        }
        else
        {
            [self notifyFinished];
        }
    }
    else 
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}
@end

@implementation GPSetLPCEnableOp
- (id) initWithCore:(GPBusinessCore *)core enable:(BOOL) enable admin:(NSString *)admin password:(NSString *)password token:(NSString*)token deviceID:(NSString*)deviceId
{
    self = [super initWithCore:core];
    if (self)
    {
        m_enable = enable;
        m_admin = [admin retain];
        m_password = [password retain];
        m_token = [token retain];
        m_deviceID = [deviceId retain];
        [self start];
    }
    return self;
}
- (void) dealloc
{
    [m_admin release];
    [m_password release];
    [m_token release];
    [m_deviceID release];
    [super dealloc];
}
- (void) start
{
    self.asynOp = [m_core.soapHelper ParentalControl_Authenticate:m_admin NewPassword:m_password];
    [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_Authenticate_Callback)];
}

- (void) ParentalControl_Authenticate_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        int rsp = [self.asynOp responseCode];
        if (rsp == 0)
        {
            NSString * enable = @"0";
            if (m_enable)
            {
                enable = @"1";
            }
            self.asynOp = [m_core.soapHelper ParentalControl_EnableParentalControl:enable];
            [self.asynOp setFinishCallback:self selector:@selector(ParentalControl_EnableParentalControl_Callback)];
        }
        else
        {
            m_responseCode = GPBusiness_LPC_AuthenticateRouter_Failed;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

- (void) ParentalControl_EnableParentalControl_Callback
{
    if (m_aborted)
    {
        return;
    }
    if ([self.asynOp succeeded])
    {
        m_succeeded = YES;
        int rsp = [self.asynOp responseCode];
        if (rsp == 0)
        {
            if (m_enable)//表明当前设置操作是开启LPC功能
            {
                self.asynOp = [m_core.lpcHelper getFilters:m_token deviceId:m_deviceID];
                [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
                [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
            }
            else
            {
                m_responseCode = GPBusiness_NoError;
                [self notifyFinished];
            }
        }
        else
        {
            m_responseCode = GPBusiness_UnKnownError;
            [self notifyFinished];
        }
    }
    else
    {
        m_succeeded = NO;
        [self notifyFinished];
    }
}

@end

@implementation GPSetLPCFilterOp
- (id) initWithCore:(GPBusinessCore *)core token:(NSString*)token deviceID:(NSString*)deviceId bundle:(NSString*)bundle
{
    self = [super initWithCore:core];
    if (self)
    {
        m_bundle = [bundle retain];
        m_token = [token retain];
        m_deviceID = [deviceId retain];
        [self start];
    }
    return self;
}

- (void) dealloc
{
    [m_bundle release];
    [m_token release];
    [m_deviceID release];
    [super dealloc];
}
- (void) start
{
    self.asynOp = [m_core.lpcHelper setFilters:m_token deviceId:m_deviceID bundle:m_bundle];
    [self setCurrentOpMode:GTAsyncOpMode_OpneDNS];
    [self.asynOp setFinishCallback:self selector:@selector(processFinallyResult)];
}
@end