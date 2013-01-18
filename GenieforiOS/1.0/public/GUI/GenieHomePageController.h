//
//  GenieHomePageController.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenieLoginDialog.h"
#import <CoreLocation/CoreLocation.h>


@class GPageControl;
@class GPBusinessHelper;
@class GenieRemoteRouterList;
@interface GenieHomePageController : UIViewController <UIPopoverControllerDelegate,UIActionSheetDelegate,UISearchBarDelegate,UIScrollViewDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>{
    GenieLoginDialog                        * m_loginDialog;

    UIView                                  * m_view;//所有的UI都在m_view上完成
    UIScrollView                            * mainView;//显示function icons 的view
    GPageControl                            * pageControl;
    UISearchBar                             * searchBar;
    NSMutableArray                          * allFuncIcons;
    
    GenieRemoteRouterList                   * m_remoteRouterList;
    UINavigationController                  * m_remoteRouterNaviController;
  }
@property (nonatomic, readonly) GenieRemoteRouterList * remoteRouterList;

- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;
- (void) showFunctionsHomePageWith:(UIInterfaceOrientation) orientation;
- (void) initUIElements;
- (void) initFunctionsHomePage;
- (void) initFunctionIcons;
- (void) addFunctionWithTitle:(NSString*)name logoImage:(NSString*)img type:(GenieFunctionType) type operation:(SEL) selector;
- (void) setNaviItemLeftBtnTitle;
//----------
- (void) showSpecialAlertViewForShowAboutInfo;
@end
