//
//  GenieRemoteRouterLoginPage.h
//  GenieiPad
//
//  Created by cs Siteview on 12-6-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GenieRemoteRouterInfo;
@interface GenieRemoteRouterLoginPage : UIViewController <UITextFieldDelegate>{
    UIControl                       * m_view;
    UIControl                       * m_loginPanelBg;
    UIControl                       * m_loginPanel;//
    UILabel                         * m_accountLabel;
    UITextField                     * m_accountTextField;
    UILabel                         * m_passwordLabel;
    UITextField                     * m_passwordTextField;
    UILabel                         * m_rememberMeLabel;
    UISwitch                        * m_rememberMeSwitcher;
    UIButton                        * m_loginBtn;
    UIButton                        * m_cancelBtn;
    
    GenieRemoteRouterInfo           * m_routerInfo;
    NSMutableArray                  * m_routerLoginInfoList;
    //
    id                              m_target;//assign
    SEL                             m_selector;
}
- (id) initwithRouterInfo:(GenieRemoteRouterInfo*)router;
- (void) setRouterLoginFinish:(id)target callback:(SEL) selector;
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;
- (void) adjustLoginPanelWithOrientation:(UIInterfaceOrientation) orientation;
- (void) showSpecialAlertViewForLoginKeyInvalid;

- (void) layoutLoginPanel;

/*
 *第一次登陆时，默认选择记住密码
 *只要【成功登陆过】的路由器的账号密码信息都会记录到列表中【只记录正确的密码】

 *只要用户改变了记住密码开关的状态，都应该将该路由器账号密码信息以及记住密码这以状态进行修改 【如之前没有记录过该路由器信息，还应该增加该信息】
 *因为用户是否记住密码【这个状态】需要记录下来
 
 *所有的操作在缓存中进行  最后一起写入文件
 */
- (void) cachingRouterLoginInfoForLoginOrSwitchChanged:(BOOL)isLogin;//缓存路由器登陆信息列表到内存
- (void) writeRouterLoginInfo;//将内存的路由器登陆信息列表写入文件
- (NSMutableArray*) readRouterLoginInfoList;
@end