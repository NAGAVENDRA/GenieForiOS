//
//  ScanController.m
//  GenieiPhoneiPod
//
//  Created by siteview siteview on 12-4-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ScanController.h"
#import "CustomLabel.h"
#import "GenieHelper.h"
#import "QRCodeReader.h"

@interface  ScanController()

@end

@implementation ScanController

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
static CGFloat SCREEN_WIDTH;
static CGFloat  SCREEN_HIGH;




//判断是否有摄像头
-(BOOL)hasCamera{
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
        return NO;
    }
    return YES;
}

- (void)scanPressed{
    
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    [widController.overlayView setDisplayedMessage:Localization_QRCode_HowTO_Scanning_Prompt];
    
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    [qrcodeReader release];
    widController.readers = readers;
    [readers release];
    //    NSBundle *mainBundle = [NSBundle mainBundle];
    //    widController.soundToPlay =
    //    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
    [self presentModalViewController:widController animated:NO];
    [widController release];
}

- (void)myLabel:(CustomLabel *)myLabel touchesWtihTag:(NSInteger)tag {
    if ([self isURL:myLabel.text]) {
        [[UIApplication sharedApplication] 
         openURL:[NSURL URLWithString:myLabel.text]];
    }
}

//判断是否包含 头'http:'(是否是超链接)
-(BOOL)isURL:(NSString*)paramStr{
    NSString *regex = @"http+:[^\\s]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([predicate evaluateWithObject:paramStr]) {
        return YES;
    }
    return NO;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
     
    if (buttonIndex ==1) {
        
        if (alertView.tag==1) {
            NSURL *url = [NSURL URLWithString:resultsView.text];
            [[UIApplication sharedApplication] openURL:url];        
        }
    }
    
       
}

//文本左对齐
- (void)willPresentAlertView:(UIAlertView *)alertView{
    if (alertView.tag ==2) {
        for(UIView *subview in alertView.subviews)
        {
            if([[subview class] isSubclassOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel*)subview;
                label.textAlignment = UITextAlignmentLeft;
            }
        }

    }
}  



#pragma mark -
#pragma mark ZXingDelegateMethods

-(void)zxingController:(ZXingWidgetController *)controller didScanResultImage:(UIImage *)image{

    resultImage.image=image;
    [resultImage setNeedsDisplay];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
  
    NSString * fontStr = [result substringToIndex:5];
    if ([self isURL:result]) {  
        
         NSString *tempStr = 
        [NSString stringWithFormat:@"%@\n%@\n%@ ",Localization_QRCode_FIND_URL_Prompt,result,Localization_QRCode_OPEN_URL_Prompt];
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil
                                                        message:tempStr
                                                       delegate:nil
                                              cancelButtonTitle:Localization_Close 
                                              otherButtonTitles:Localization_Ok, nil];
        alert.delegate = self;
        alert.tag=1;
        [alert show];
        [alert release];

        
        resultsView.text= result ;
        }
    else if([fontStr isEqualToString:@"Genie"]){//如果字符串以Genie开头
        
        NSString * number = [result substringWithRange:NSMakeRange(5, 6)];
        
        
        int total = [[number substringWithRange:NSMakeRange(0, 2)] intValue];
        int ssidCount = [[number substringWithRange:NSMakeRange(2, 2)] intValue];
        int pwdCount = [[number substringWithRange:NSMakeRange(4, 2)] intValue];
        NSString * content = [result substringFromIndex:11];
        
        if (total ==ssidCount+pwdCount&&[content length]==total) {
            
            NSString *ssid = [content substringToIndex:ssidCount]; 
            NSString *pwd = [content substringFromIndex:ssidCount];
            
            NSString * viewTxt=[NSString stringWithFormat:@"%@: %@\n%@: %@\n",Localization_QRCode_WIFI_SSID_Title,ssid,Localization_QRCode_WIFI_Password_Title,pwd];
            
            resultsView.text=viewTxt;
            
            UIPasteboard *pasteboard=[UIPasteboard generalPasteboard]; 
            pasteboard.string = pwd; 
            
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil
                                                            message:
                                   [NSString stringWithFormat:@"%@\n%@ %@.",viewTxt,Localization_QRCode_WIFI_info_Prompt,ssid]
                                                           delegate:self
                                                  cancelButtonTitle:Localization_Close 
                                                  otherButtonTitles:nil, nil];
            
            alert.tag=2;
            [alert show];
            [alert release];

           
        }
    }
    else{
        resultsView.text= result ;
    }
    
    
    
    [self dismissModalViewControllerAnimated:NO];
        
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.title=Localization_QRCode_Page_Title;
    
    [self.view setBackgroundColor: BACKGROUNDCOLOR];
    
    if ([self hasCamera]) {
        [self scanPressed];
        [self setScreenWidth];
        [self initUI];
    }
    else{
        [GenieHelper showGobackToMainPageMsgBoxWithMsg:Localization_QRCode_Not_Support];
    }
        
}



-(void)setScreenWidth{
    if (isPad) {
        SCREEN_WIDTH =768;
        SCREEN_HIGH  = 1004;
    }
    else{
        SCREEN_WIDTH =320;
        SCREEN_HIGH  = 460;
    }
}

-(void)initUI{
    resultsView = [[CustomLabel alloc]init];
    resultsView.backgroundColor=[UIColor clearColor];
    resultsView.tag=1998;
    resultsView.textAlignment=UITextAlignmentCenter;
    
    resultImage = [[UIImageView alloc]init];
    //    resultImage.image = [UIImage imageNamed:@"286.png"];
    
    scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect ];
    [scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (isPad) {
        resultsView.frame=CGRectMake(SCREEN_WIDTH/2-SCREEN_WIDTH/4*3/2, 79, SCREEN_WIDTH/4*3, 100);
        resultImage.frame= CGRectMake(SCREEN_WIDTH/2-SCREEN_WIDTH/3/2, 280, SCREEN_WIDTH/3,  SCREEN_WIDTH/3);
        scanButton.frame=CGRectMake(SCREEN_WIDTH/2-SCREEN_WIDTH/3/2, 700, SCREEN_WIDTH/3, 60);
    }else{
        resultsView.frame=CGRectMake(SCREEN_WIDTH/2-150, 40, 300, 100);
        resultImage.frame= CGRectMake(SCREEN_WIDTH/2-150/2, 180, 150, 150);
        scanButton.frame=CGRectMake(SCREEN_WIDTH/2-200/2, 360, 200, 30);
    }
    
    [self.view addSubview:resultsView];
    [self.view addSubview:scanButton];
    [self.view addSubview:resultImage];
}





- (void)dealloc {
    [super dealloc];
    [resultsView release];
    [resultsToDisplay release];
    [resultImage release];
    
}

@end
