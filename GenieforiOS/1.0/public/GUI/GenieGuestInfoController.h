//
//  GenieGuestInfoController.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieGuestInfoController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate> {
    UITableView                             * m_tableview;
    NSMutableArray                          * m_data;
    UISwitch                                * m_switcher;
}

- (id) init;
- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation;
@end
