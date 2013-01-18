//
//  GenieiPhoneiPodAppDelegate.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieiPhoneiPodAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
    UINavigationController                      * GenieRootController;
 }

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) UINavigationController * GenieRootController;



@end
