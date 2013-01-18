//
//  GenieiPhoneiPodAppDelegate.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieiPhoneiPodAppDelegate.h"
#import "GenieHomePageController.h"
#import "GenieHelper.h"
#import "DLNAShareApi.h"


@implementation GenieiPhoneiPodAppDelegate
@synthesize GenieRootController;
@synthesize window=_window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GenieHelper InitGenieCoreData];
    [GenieHelper GetInstance];
    GenieHomePageController * rootController = [[GenieHomePageController alloc] init];
    GenieRootController = [[UINavigationController alloc] initWithRootViewController:rootController];
    [rootController release];
    GenieRootController.navigationBar.barStyle = UIBarStyleBlack;
   
    //[self.window addSubview:GenieRootController.view];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {   
        self.window.rootViewController = GenieRootController;  
    }
    else
    {
        [self.window addSubview:GenieRootController.view];   
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[GenieHelper GetInstance] saveConfigInfo];
    [[GenieHelper GetInstance] saveUserHabitsInfo];
    saveDLNAConfigInfo();
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}


//
- (void) checkLocationService
{
    UIAlertView * alert;
    if (kCLAuthorizationStatusAuthorized != [CLLocationManager authorizationStatus])
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable (@"Attention title",@"Localizable", nil)
                                               message:NSLocalizedStringFromTable (@"Attention content",@"Localizable", nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok",@"Localizable", nil)
                                     otherButtonTitles:nil];
        }
        else
        {
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable (@"Attention title",@"Localizable", nil)
                                               message:NSLocalizedStringFromTable (@"Attention content6",@"Localizable", nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"ok",@"Localizable", nil)
                                     otherButtonTitles:nil];
        }
        [alert show];
        [alert release];
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if ([GenieHelper getActiveFuncton] == GenieFunctionMyMedia)
    {
        [self checkLocationService];
    }
    

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return YES;
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
          return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{    
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc
{
      [GenieRootController release];
    [GenieHelper ReleaseInstance];
    [GenieHelper ReleaseCoreData];
    [_window release];
    [super dealloc];
}
@end
