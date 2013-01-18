//
//  GPBussinessCore.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXSoapHelper.h"
#import "LPCCore.h"
#import "GWebInfoHelper.h"
enum GPBusinessError
{
    GPBusiness_NoError = 0,
    GPBusiness_UnKnownError,
    GPBusiness_Soap401,
    GPBusiness_Soap501,
    GPBusiness_Authenticate_UnknownError,
    GPBusiness_Authenticate_KeyInvalid,
    
    GPBusiness_SN_RouterAuth_Failed = GPBusiness_Authenticate_KeyInvalid,
    GPBusiness_SN_Authenticate_Failed = 100,
    
    GPBusiness_CSettingFailed = 200,
    
    GPBusiness_LPC_NoInternet = 500,
    GPBusiness_LPC_AutoLogin_Failed,//自动登陆LPC失败，需要返回的创建OPENDNS账号页面或者登陆页面
    GPBusiness_LPC_AuthenticateRouter_Failed,
    GPBusiness_LPC_UnavailableAccount,//account is not belonged to device
    GPBusiness_LPC_CheckUserName_NO,//
    GPBusiness_LPC_SignInOpenDNS_PassKey_Wrong,
    GPBusiness_LPC_UnexpectedError
};

@interface GPBusinessCore : NSObject {
    FXSoapHelper                * m_soapHelper;
    DCWebApi                    * m_lpcHelper;
    GWebInfoHelper              * m_getWebInfoHelper;
}
@property (nonatomic, readonly) FXSoapHelper * soapHelper;
@property (nonatomic, readonly) DCWebApi * lpcHelper;
@property (nonatomic, readonly) GWebInfoHelper * webInfoHelper;

- (id) initWithSoapHelper:(FXSoapHelper*)soapHelper LPCHelper:(DCWebApi*)lpcHelper GWebInfoHelper:(GWebInfoHelper*)webInfoHelper;
- (void)setSoapWrapMode:(BOOL)wrap;
- (BOOL)wrapMode;
@end
