//
//  GenieRemoteRouterList.h
//  GenieiPad
//
//  Created by cs Siteview on 12-6-11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GenieCallbackObj;
@interface GenieRemoteRouterList : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UITextFieldDelegate>{
    UIView                  * m_view;
    UITableView             * m_tableview;
    NSMutableArray          * m_data;//all remote routers
    
    id                      m_target_routerLogin;
    SEL                     m_selector_routerLogin;
    id                      m_target_logout;
    SEL                     m_selector_logout;
}
- (id) init;
- (void) setRemoteRouterLoginFinish:(id)target callback:(SEL)selector;
- (void) setSmartNetworkLogout:(id) target callback:(SEL) selector;
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;

//________
- (void) getRemoteRouters:(GenieCallbackObj*) obj;
- (BOOL) noRemoteDevicesFound;
@end


@interface GenieRemoteRouterInfoCell : UITableViewCell {
    UILabel                             * m_friendlyNameLabel;
    UILabel                             * m_serialLabel;
    UILabel                             * m_modelNameLable;
    UILabel                             * m_statusLabel;
}
@property (nonatomic, retain) UILabel * friendlyNameLabel;
@property (nonatomic, retain) UILabel * serialLabel;
@property (nonatomic, retain) UILabel * modelNameLabel;
@property (nonatomic, retain) UILabel * statusLabel;
- (id) init; 
@end