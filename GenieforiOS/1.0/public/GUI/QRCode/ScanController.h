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
@interface ScanController : UIViewController 
<ZXingDelegate,CustomLabelDelegate,UIAlertViewDelegate>
{
    NSString *resultsToDisplay;
    BOOL  noCamera;
    
    UIImageView *resultImage;
    UIButton * scanButton;
    UIAlertView * alertMsgView;
      
    CustomLabel *  resultsView;
}
-(void)setScreenWidth;
-(void)scanPressed;
-(void)initUI;
-(BOOL)isURL:(NSString*)paramStr;
-(BOOL)hasCamera;
-(BOOL)isCorrectString:(NSString*)paramString;
-(NSArray*)getSSIDPWD:(NSString*)paramString;
@end
