//
//  GenieGuestModifyController.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieGuestModifyController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate> {
    UITableView                         * m_tableview;
    UITextField                         * m_ssidTextField;
    UITextField                         * m_passwordTextField;
    
    NSString                            * m_timePeriodInfo;
    NSString                            * m_secutityModeInfo;
    BOOL                                m_noSecurity;
    BOOL                                m_isInfoChanged;
    BOOL                                m_isOpenGuestAccessPage;
    
    //smart network set流程之后，需要返回上一级界面并刷新数据
    id                                  m_target_SN_set;
    SEL                                 m_selector_SN_set;
}
//区分当前的modify 页面是为了重新打开Guest Access功能 还是Modify当前guest access的设置  默认为NO  即修改设置
@property (nonatomic, assign) BOOL isOpenGuestAccessPage;

- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation;
- (void) setModifyFinished:(id)target callback:(SEL)selector;
@end
