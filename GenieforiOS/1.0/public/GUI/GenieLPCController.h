//
//  GenieLPCController.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum 
{
    LPCPageForNone = 0,
    LPCPageForShowInformation,
    LPCPageForCreateOpenDNSAccount,
    LPCPageForLogin
}LPCPageMode;

typedef enum 
{
    LPCInput_NoError = 0,
    LPCInput_CreateAccount_UserNameCheckUnavailable_Error,
    LPCInput_CreateAccount_UserNameFormat_Error,
    LPCInput_CreateAccount_PasswordLength_Error,
    LPCInput_CreateAccount_ConformPassword_Error,
    LPCInput_CreateAccount_ConformEmail_Error,
    LPCInput_CreateAccount_EmailFormat_Error,
    LPCInput_CreateAccount_EmailIsUnavailable_Error,
    LPCInput_CreateAccount_Unkonwn_Error,
    //
    LPCInput_LoginOpenDNS_account_key_NoMatch_Error,
    LPCInput_LoginOpenDNS_account_device_NoMatch_Error
}LPCInputError;
@interface GenieLPCController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITableView                             * m_tableview;
    LPCPageMode                             m_pageMode;
    LPCInputError                           m_inputError;
    //----------
    UITextField                             * m_createAccount_userNameTextField;
    UITextField                             * m_createAccount_passwordTextField;
    UITextField                             * m_createAccount_confirmPasswordTextField;
    UITextField                             * m_createAccount_emailTextField;
    UITextField                             * m_createAccount_confirmEmailTextField;
    UITextField                             * m_login_userNameTextField;
    UITextField                             * m_login_passwordTextField;
    UISwitch                                * m_switcher;
}
- (void) prepareUIElemsForCreateAccountPage;
- (void) prepareUIElemsForLoginPage;
- (void) prepareUIElemsForShowLPCInfoPage;
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation;
- (void) layoutViewWithCurrentPageMode;
- (NSDictionary*) readLPCConfigInfoDictionary;
- (void) saveLPCConfigInfo;
- (void) showSpecialAlertViewForUserOptionPrompt;
- (void) showSpecialAlertViewForInputErrorWithMsg:(NSString*)msg;

- (void) getLpcInfoWithWaitMsg:(NSString*)msg callback:(SEL)selector;
@end
