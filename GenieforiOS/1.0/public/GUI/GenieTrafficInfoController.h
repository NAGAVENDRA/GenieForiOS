//
//  GenieTrafficInfoController.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieTrafficInfoController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    UITableView                             * m_tableview;
    UISwitch                                * m_switcher;
    NSMutableArray                          * m_controlData;
}

- (id) init;
- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation;
@end
