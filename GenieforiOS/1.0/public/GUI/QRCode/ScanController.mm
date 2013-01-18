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

//判断是否有摄像头
-(BOOL)hasCamera{
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
        return NO;
    }
    return YES;
}

- (void)myLabel:(CustomLabel *)myLabel touchesWtihTag:(NSInteger)tag {
    if ([self isURL:myLabel.text]) {
        [[UIApplication sharedApplication] 
         openURL:[NSURL URLWithString:myLabel.text]];
    }
}

//判断是否包含 头'http:'(是否是超链接)
-(BOOL)isURL:(NSString*)paramStr{
    NSString *regex = @"[hH][tT][tT][pP]([sS]?)://.*";
//    NSString *regex = @"http|ftp|https:\/\/[\w\-_]+\.[\w\-_]+[\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([predicate evaluateWithObject:paramStr]) {
        return YES;
    }
    return NO;
}

#pragma mark 
#pragma mark - Wireless format checking


//判断字符串是否为合法格式 "WIRELESS:DNR3500;PASSWORD:12345678"
-(BOOL)isCorrectString:(NSString*)paramString{
    
    if ([paramString length]<=19) {
        return NO;
    }
    if (![paramString hasPrefix:@"WIRELESS:"]) {
        return NO;
    }
    NSRange range2 = [paramString rangeOfString:@"PASSWORD:"];
    if (range2.location==NSNotFound) {
        return NO;
    }
    
    //“;”出现次数
    NSUInteger cnt = 0, length = [paramString length];
    NSRange range = NSMakeRange(0, length); 
    while(range.location != NSNotFound)
    {
        range = [paramString rangeOfString: @";" options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            cnt++; 
        }
    }
    if (cnt>1) {
        return NO;
    }

    return YES;
}

//解析WIFI字符串
-(NSArray*)getSSIDPWD:(NSString*)paramString{
    //    NSRange ssidRange = [paramString rangeOfString:@"WIRELESS:"];
    NSRange pwdRange = [paramString rangeOfString:@"PASSWORD:"];
    NSString * ssidString = 
    [paramString substringWithRange:NSMakeRange(9, pwdRange.location-pwdRange.length-1)];
    NSString * pwdString = [paramString substringFromIndex:pwdRange.location+pwdRange.length];
    
    NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:2];

    [tempArray addObject:ssidString];
    [tempArray addObject:pwdString];
    
    return  tempArray;
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

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
  
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
    else if([self isCorrectString:result]){//如果字符串以Genie开头 WIRELESS:DNR3500;PASSWORD:12345678
            NSArray * array = [self getSSIDPWD:result];
            NSString *ssid = [array objectAtIndex:0]; 
            NSString *pwd = [array objectAtIndex:1];
            
            NSString * viewTxt=[NSString stringWithFormat:@"%@: %@\n%@: %@\n",Localization_QRCode_WIFI_SSID_Title,ssid,Localization_QRCode_WIFI_Password_Title,pwd];
            
            resultsView.text=viewTxt;
            
            UIPasteboard *pasteboard=[UIPasteboard generalPasteboard]; 
            pasteboard.string = pwd; 
                        
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil
                                                            message:
                                   [NSString stringWithFormat:@"%@\n%@",viewTxt,Localization_QRCode_WIFI_info_Prompt]
                                                           delegate:self
                                                  cancelButtonTitle:Localization_Close 
                                                  otherButtonTitles:nil, nil];
             alert.tag=2;
            [alert show];
            [alert release];


    }
    else{
        resultsView.text= result ;
    }
    
    
    
    [self dismissModalViewControllerAnimated:NO];
        
}



- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    
    [self dismissModalViewControllerAnimated:NO];
}

-(void)zxingController:(ZXingWidgetController *)controller didScanResultImage:(UIImage *)image{
    
    resultImage.image= image;
    resultImage.transform = CGAffineTransformMakeRotation(M_PI_2);
//    [resultImage setNeedsDisplay];
}





-(void)test:(NSString*)paramStr{
    UIAlertView *talert = [[UIAlertView alloc]initWithTitle:@"test" message:paramStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
    [talert show];
    [talert release];
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
//    resultsView.text=@"WIRELESS:DNR3500;PASSWORD:12345678";
    resultsView.delegate=self;
    
    resultImage = [[UIImageView alloc]init];
    
    scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect ];
    [scanButton setTitle:Localization_QRCode_Scan_Btn_Title forState:UIControlStateNormal];
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
