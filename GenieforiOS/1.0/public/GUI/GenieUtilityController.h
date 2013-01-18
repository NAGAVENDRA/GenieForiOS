//
//  GenieUtilityController.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-5-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPanelView.h"

@interface GenieUtilityController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,GPanelViewDelegate,GPanelViewDataSource,UITextFieldDelegate,UIWebViewDelegate>{
    UIView                  * m_view;
    UINavigationBar         * m_naviBar;
    UITableView             * m_tableview;
    UISwitch                * m_smartnetwork_switcher;
    UISwitch                * m_remember_me_switcher;
    UITextField             * m_snUsernameField;
    UITextField             * m_snPasswordField;
    GPanelView              * m_loginPanel;
    
    NSMutableArray          * m_data;
    NSString                * m_selectedRouterSerial;
}

- (id) init;
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;
- (void) showSpecialAlertViewForShowAboutInfo;
- (void) showSpecialAlertViewForLoginSmartnetworkKeyInvalid;
- (NSString *) readDefaultSelectedRouterSerialInfo;
- (void) writeDefaultSelectedRouterSerialInfo:(NSString*) router_serial;

- (void) showLoginPanel;//show 登陆框 
- (UIWebView*) getHyperLinkViewCSS:(NSString*)cssString href:(NSString*)hrefString delegate:(id)delegate;
@end
