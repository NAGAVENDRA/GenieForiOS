//
//  GenieWirelessModifyController.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieWirelessModifyController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate> {
    UITableView                         * m_tableview;
    UITextField                         * m_ssidTextField;
    UITextField                         * m_passwordTextField;
    
    NSString                            * m_channelInfo;
    NSString                            * m_secutityModeInfo;
    BOOL                                m_noSecurity;
    BOOL                                m_isInfoChanged;//标记信息是否被更改，是否需要save
    
    //smart network set流程之后，需要返回上一级界面并刷新数据
    id                                  m_target_SN_set;
    SEL                                 m_selector_SN_set;
}

- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation;
- (void) setModifyFinished:(id)target callback:(SEL)selector;
@end
