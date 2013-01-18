//
//  ScanController.h
//  GenieiPhoneiPod
//
//  Created by siteview siteview on 12-4-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

//#import "ZBarSDK.h"
#import <UIKit/UIKit.h>
#import "CustomLabel.h"
#import "ZXingWidgetController.h"
#import "GenieHelper.h"
@interface ScanController : UIViewController 
<ZXingDelegate,CustomLabelDelegate,UIAlertViewDelegate>
{
//    UIImageView *resultImage;
//    //    UITextView *resultText;
//    
//    CustomLabel *  webSite;
//    UIButton * scanButton;
//    
//    BOOL   *isCamera;
    
    NSString *resultsToDisplay;
    
    UIImageView *resultImage;
    UIButton * scanButton;
    UIAlertView * alertMsgView;
   
    BOOL  noCamera;
    
    CustomLabel *  resultsView;

    
}

//-(void)viewRotateTo:(UIInterfaceOrientation) oritation;
//-(void)scanButtonTapped;
//-(BOOL)isURL:(NSString*)paramStr;
//-(void)setScreenWidth;
//-(void)initUI;


-(void)setScreenWidth;
-(void)scanPressed;
-(void)initUI;
-(BOOL)isURL:(NSString*)paramStr;
-(BOOL)hasCamera;

@end
