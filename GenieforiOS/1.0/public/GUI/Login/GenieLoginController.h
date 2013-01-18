//
//  GenieLoginController.h
//  GenieiPad
//
//  Created by cs Siteview on 12-6-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum 
{
    GenieLoginModeLocal = 0,
    GenieLoginModeRemote
}GenieLoginMode;
@interface GenieLoginController : UIViewController<UITextFieldDelegate, UIWebViewDelegate> {
    GenieLoginMode                  m_loginMode;
    //
    UIControl                       * m_view;
    UIControl                       * m_loginPanelBg;
    UIControl                       * m_loginPanel_local;//
    UIControl                       * m_loginPanel_remote;//
    UILabel                         * m_loginModeLabel;
    UISwitch                        * m_loginModeSwitcher;
    UILabel                         * m_accountLabel;
    UITextField                     * m_accountTextField;
    UILabel                         * m_passwordLabel;
    UITextField                     * m_passwordTextField;
    UILabel                         * m_rememberMeLabel;
    UISwitch                        * m_rememberMeSwitcher;
    UIWebView                       * m_forgerPasswordHyper;
    UIWebView                       * m_signUpHyper;
    UILabel                         * m_defaultPasswordPromptLabel;
    UIButton                        * m_loginBtn;
    UIButton                        * m_cancelBtn;
    
    //
    id                              m_target_local;//assign   local login callback
    SEL                             m_selector_local;
    id                              m_target_remote;//assign local login callback
    SEL                             m_selector_remote;
    id                              m_target_no_remote_router;
    SEL                             m_selector_no_remote_router;
    BOOL                            m_timeout;
    NSTimer*                        m_timer;
}
- (void) setLocalRouterLoginFinish:(id)target callback:(SEL)selector;
- (void) setSmartNetworkLoginFinish:(id)target callback:(SEL)selector;
- (void) setNoRemoteRouter:(id)target callback:(SEL)selector;
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;
- (void) adjustLoginPanelWithOrientation:(UIInterfaceOrientation) orientation;
- (void) showSpecialAlertViewForNotNetgearRouter;
- (void) showSpecialAlertViewForLoginKeyInvalid;
- (void) showSpecialAlertViewForLoginSmartnetworkKeyInvalid;
- (void) showSpecialAlertViewForNoRemoteDevices;

- (void) showLocalLoginPanelForNotSupportSmartNetwork;
- (void) showLoginPanelForLoginMode:(GenieLoginMode)mode;
- (void) showLocalLoginPanel;
- (void) showRemoteLoginPanel;
- (void) handleTimer:(NSTimer*)time;
@end
