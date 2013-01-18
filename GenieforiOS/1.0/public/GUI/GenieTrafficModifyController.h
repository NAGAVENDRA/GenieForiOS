//
//  GenieTrafficModifyController.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieTrafficModifyController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    UITableView                         * m_tableview;
    UITextField                         * m_monthLimitTextField;
    UITextField                         * m_hourTextField;
    UITextField                         * m_minuteTextField;
    BOOL                                m_isInfoChanged;
    
    NSString                            * m_dayInfo;
    NSString                            * m_trafficLimitModeInfo;
    id                                  m_target;//retain
    SEL                                 m_selector;
}

- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation;
- (void) setModifyFinished:(id)target callback:(SEL)selector;
@end
