//
//  GenieLoginController.m
//  GenieiPad
//
//  Created by cs Siteview on 12-6-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieLoginController.h"
#import "Reachability.h"
#import "GenieGlobal.h"
#import "GenieHelper.h"
#import "GenieRemoteRouterList.h"



#ifdef __GENIE_IPHONE__
#define LoginPanelBgFrame                  CGRectMake(0, 0, 300, 220)
#define LoginPanelWidth                    285.0f
#define LoginPanelHeight                   200.0f
#define LabelLength                        110.0f
#define DefaultRowHeight                   24
#else
#define LoginPanelBgFrame                  CGRectMake(0, 0, 600, 460)
#define LoginPanelWidth                    500.0f
#define LoginPanelHeight                   300.0f
#define LabelLength                        200.0f
#define DefaultRowHeight                   32
#endif

#define LoginPanelFrame         CGRectMake(0, 0, LoginPanelWidth, LoginPanelHeight)
#define KeyLabelFrame           CGRectMake(0, 0, LabelLength, DefaultRowHeight)
#define TextFieldFrame          CGRectMake(0, 0, LoginPanelWidth - LabelLength, DefaultRowHeight)

//#define GENIE_TEST
@implementation GenieLoginController


- (id)init
{
    self = [super init];
    if (self) 
    {
        m_loginMode = GenieLoginModeLocal;
        if ([GenieHelper isGenieLoginModeIsRemoteLogin])
        {
            m_loginMode = GenieLoginModeRemote;
        }
        
        m_view = nil;
        m_loginPanelBg = nil;
        m_loginPanel_local = nil;
        m_loginPanel_remote = nil;
        m_loginModeLabel = nil;
        m_loginModeSwitcher = nil;
        m_accountLabel = nil;
        m_accountTextField = nil;
        m_passwordLabel = nil;
        m_passwordTextField = nil;
        m_rememberMeLabel = nil;
        m_rememberMeSwitcher = nil;
        m_forgerPasswordHyper = nil;
        m_signUpHyper = nil;
        m_defaultPasswordPromptLabel = nil;
        m_loginBtn = nil;
        m_cancelBtn = nil;
        
        m_selector_local = nil;
        m_target_local = nil;
        m_selector_remote = nil;
        m_target_remote = nil;
        m_selector_no_remote_router = nil;
        m_target_no_remote_router = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_cancelBtn release];
    [m_loginBtn release];
    [m_defaultPasswordPromptLabel release];
    [m_signUpHyper release];
    [m_forgerPasswordHyper release];
    [m_rememberMeSwitcher release];
    [m_rememberMeLabel release];
    [m_passwordTextField release];
    [m_passwordLabel release];
    [m_accountTextField release];
    [m_accountLabel release];
    [m_loginModeSwitcher release];
    [m_loginModeLabel release];
    [m_loginPanel_remote release];
    [m_loginPanel_local release];
    [m_loginPanelBg release];
    [m_view release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView
{
    UIView* v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = v;
    [v release];
    m_view = [[UIControl alloc] init];
    [m_view addTarget:self action:@selector(callbackKyeBoard) forControlEvents:UIControlEventTouchUpInside];
    m_view.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:m_view];
    self.title = Localization_Login_MainPage_Title;
}

- (UIWebView*) getHyperLinkViewCSS:(NSString*)cssString href:(NSString*)hrefString
{
    CGRect rec;
#ifdef __GENIE_IPHONE__
    rec = CGRectMake(0, 0, LoginPanelWidth/2, 14);
#else
    rec = CGRectMake(0, 0, LoginPanelWidth/2, 25);
#endif
    UIWebView * webPage = [[UIWebView alloc] initWithFrame:rec];
    [webPage loadHTMLString:[cssString stringByAppendingString:hrefString] baseURL:nil];
    webPage.delegate = self;
    webPage.backgroundColor = [UIColor clearColor];
    webPage.opaque = NO;
    for (UIView *subView in [webPage subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            UIScrollView * v = (UIScrollView*)subView;
            v.scrollEnabled = NO;
        }
    }
    webPage.dataDetectorTypes = UIDataDetectorTypeNone;
    return [webPage autorelease];
}

- (void) initDefaultPasswordPromptLabel
{
#ifdef __GENIE_IPHONE__
    CGFloat fontSize = 11;
    CGFloat labelHight = 14;
#else
    CGFloat fontSize = 17;
    CGFloat labelHight = 20;
#endif
    m_defaultPasswordPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LoginPanelWidth - LabelLength, labelHight)];
    m_defaultPasswordPromptLabel.text = Localization_Login_MainPage_DefaultPasswordPrompt;
    m_defaultPasswordPromptLabel.font = [UIFont systemFontOfSize:fontSize];
    m_defaultPasswordPromptLabel.textAlignment = UITextAlignmentLeft;
    m_defaultPasswordPromptLabel.backgroundColor = [UIColor clearColor];
}
- (void) initLoginViewItems
{
#ifdef __GENIE_IPHONE__
    CGFloat labelTextFontSize = 15;
#else
    CGFloat labelTextFontSize = 23;
#endif
    m_loginPanelBg = [[UIControl alloc] initWithFrame:LoginPanelBgFrame];
    UIImageView * bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_panel_bg"]];
    bg.frame = m_loginPanelBg.frame;
    [m_loginPanelBg addSubview:bg];
    [bg release];
    [m_loginPanelBg addTarget:self action:@selector(callbackKyeBoard) forControlEvents:UIControlEventTouchUpInside];
    [m_view addSubview:m_loginPanelBg];
    
    m_loginPanel_local = [[UIControl alloc] initWithFrame:LoginPanelFrame];
    [m_loginPanel_local addTarget:self action:@selector(callbackKyeBoard) forControlEvents:UIControlEventTouchUpInside];
    m_loginPanel_local.backgroundColor = [UIColor clearColor];
    
    m_loginPanel_remote = [[UIControl alloc] initWithFrame:LoginPanelFrame];
    [m_loginPanel_remote addTarget:self action:@selector(callbackKyeBoard) forControlEvents:UIControlEventTouchUpInside];
    m_loginPanel_remote.backgroundColor = [UIColor clearColor];
    
    {
        CGRect rec = m_loginPanelBg.frame;
#ifdef __GENIE_IPHONE__
        m_loginPanel_local.center = CGPointMake(rec.size.width/2, rec.size.height/2);
        m_loginPanel_remote.center = CGPointMake(rec.size.width/2, rec.size.height/2);
#else
        CGFloat offset = 55;
        m_loginPanel_local.center = CGPointMake(rec.size.width/2, rec.size.height/2 + offset);
        m_loginPanel_remote.center = CGPointMake(rec.size.width/2, rec.size.height/2 + offset);
#endif
        [m_loginPanelBg addSubview:m_loginPanel_local];
        [m_loginPanelBg addSubview:m_loginPanel_remote];
    }
    
    //////////
    m_loginModeLabel = [[UILabel alloc] initWithFrame:KeyLabelFrame];
    m_loginModeLabel.text = Localization_Login_MainPage_LoginMode_Switcher_Title;
    m_loginModeLabel.font = [UIFont systemFontOfSize:labelTextFontSize];
    m_loginModeLabel.textAlignment = UITextAlignmentLeft;
    m_loginModeLabel.backgroundColor = [UIColor clearColor];
    
    m_loginModeSwitcher = [[UISwitch alloc] init];
    [m_loginModeSwitcher addTarget:self action:@selector(loginModeSwitcherValueChanged) forControlEvents:UIControlEventValueChanged];
    
    ////////////
    m_accountLabel = [[UILabel alloc] initWithFrame:KeyLabelFrame];
    m_accountLabel.font = [UIFont systemFontOfSize:labelTextFontSize];
    m_accountLabel.textAlignment = UITextAlignmentLeft;
    m_accountLabel.backgroundColor = [UIColor clearColor];
    
    m_accountTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_accountTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_accountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_accountTextField.delegate = self;
    m_accountTextField.returnKeyType = UIReturnKeyJoin;
    m_accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_accountTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    ///////
    m_passwordLabel = [[UILabel alloc] initWithFrame:KeyLabelFrame];
    m_passwordLabel.text = Localization_Login_MainPage_Password_Title;
    m_passwordLabel.font = [UIFont systemFontOfSize:labelTextFontSize];
    m_passwordLabel.textAlignment = UITextAlignmentLeft;
    m_passwordLabel.backgroundColor = [UIColor clearColor];
    
    m_passwordTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_passwordTextField.delegate = self;
    m_passwordTextField.returnKeyType = UIReturnKeyJoin;
    m_passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_passwordTextField.secureTextEntry = YES;
    
    ////////
    m_rememberMeLabel = [[UILabel alloc] initWithFrame:KeyLabelFrame];
    m_rememberMeLabel.text = Localization_Login_MainPage_RememberMe_Switcher_Title;
    m_rememberMeLabel.font = [UIFont systemFontOfSize:labelTextFontSize];
    m_rememberMeLabel.textAlignment = UITextAlignmentLeft;
    m_rememberMeLabel.backgroundColor = [UIColor clearColor];
    
    m_rememberMeSwitcher = [[UISwitch alloc] init];
    [m_rememberMeSwitcher addTarget:self action:@selector(rememberMeSwitcherValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self initDefaultPasswordPromptLabel];
    
    ///////
    NSString * cssString = nil;
    NSString * href = nil;
    CGFloat font_size;
    CGFloat margin_left;
    CGFloat margin_top;
#ifdef __GENIE_IPHONE__
    font_size = 10;
    margin_left = 4;
    margin_top = 0;
#else
    font_size = 18.0f;
    margin_left = 15.0f;
    margin_top = 0.0f;
#endif
    cssString = [NSString stringWithFormat:@"<style>body{font-size:%fpx;font-family:Helvetica;color:white;text-align:left;margin-left:%fpx;margin-top:%fpx}a:link{color:#6666cc}} </style>",font_size, margin_left, margin_top];
    href = Local_MsgForSmartNetworkForgetPasswordHTML;
    m_forgerPasswordHyper = [[self getHyperLinkViewCSS:cssString href:href] retain];
    
    cssString = [NSString stringWithFormat:@"<style>body{font-size:%fpx;font-family:Helvetica;color:black;text-align:left;margin-left:%fpx;margin-top:%fpx}a:link{color:#6666cc}} </style>",font_size, margin_left, margin_top];
    href = Local_MsgForSmartNetworkSignUpHTML;
    m_signUpHyper = [[self getHyperLinkViewCSS:cssString href:href] retain];
    
#ifdef __GENIE_IPHONE__
    CGRect btn_frame = CGRectMake(0, 0, LoginPanelWidth/2*0.9, 28);
    CGFloat btn_font = 18;
#else
    CGRect btn_frame = CGRectMake(0, 0, LoginPanelWidth/2*0.9, 40);
    CGFloat btn_font = 24;
#endif
    m_loginBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    m_loginBtn.titleLabel.font = [UIFont systemFontOfSize:btn_font];
    [m_loginBtn setTitle:Localization_Login forState:UIControlStateNormal];
    [m_loginBtn addTarget:self action:@selector(loginBtnPress) forControlEvents:UIControlEventTouchUpInside];
    m_loginBtn.frame = btn_frame;
    
    m_cancelBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    m_cancelBtn.titleLabel.font = [UIFont systemFontOfSize:btn_font];
    [m_cancelBtn setTitle:Localization_Cancel forState:UIControlStateNormal];
    [m_cancelBtn addTarget:self action:@selector(cancelBtnPress) forControlEvents:UIControlEventTouchUpInside];
    m_cancelBtn.frame = btn_frame;
}
#pragma mark ----------------Genie Test
#ifdef GENIE_TEST
#define tag_testField  30000
- (void) initItemsForTest
{
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleBordered target:self action:@selector(testFunction)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [rightBtn release];
#ifdef __GENIE_IPHONE__
    CGFloat w = 300;
    CGFloat h = 30;
#else
    CGFloat w = 360;
    CGFloat h = 35;
#endif
    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    textField.tag = tag_testField;
    
    textField.text = @"appgenie-staging.netgear.com";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.hidden = YES;
    [m_view addSubview:textField];
    [textField release];
}

- (void) setSmartNetworkServerBaseUrlDone
{
    UITextField * tf = (UITextField*)[m_view viewWithTag:tag_testField];
    if ([tf.text length])
    {
        [[GenieHelper shareGenieBusinessHelper].soapHelper setSmartNetworkBaseUrl:tf.text];
    }
    
    [tf resignFirstResponder];
    tf.hidden = YES;
    self.navigationItem.rightBarButtonItem.title = @"Test";
}
- (void) testFunction
{
    UITextField * tf = (UITextField*)[m_view viewWithTag:tag_testField];
    if (tf.hidden)
    {
        self.navigationItem.rightBarButtonItem.title = @"Done";
        tf.hidden = NO;
        [tf becomeFirstResponder];
    }
    else
    { 
        [self setSmartNetworkServerBaseUrlDone];
    }
}



#endif
#pragma mark --------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
#ifdef GENIE_TEST
    [self initItemsForTest];
#endif
    [self initLoginViewItems]; 
    if (![GenieHelper isSmartNetworkAvailable])
    {
        [self showLocalLoginPanelForNotSupportSmartNetwork];
    }
    else
    {
        [self showLoginPanelForLoginMode:m_loginMode];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOritation:self.interfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showViewWithOritation:toInterfaceOrientation];
}
#pragma mark -- webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![[UIApplication sharedApplication] openURL:[request URL]];
}

#pragma mark - custom
- (BOOL) isEnableWIFI
{
    if (![Reachability IsEnableWIFI])
    {
        [GenieHelper logoutGenie];
        [GenieHelper showMsgBoxWithMsg:Local_MsgForNoWIFI];
        return NO;
    }
    return YES;
}

- (BOOL) isEnableInternet
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [GenieHelper logoutGenie];
        [GenieHelper showMsgBoxWithMsg:Local_MsgForNoInternetDetected];
        return NO;
    }
    return YES;
}

- (BOOL) isNetworkAvailable
{
    //smart network 支持3G模式,只要能连上INTERNET 所以此时不应该提示NO WIFI
    if (m_loginMode == GenieLoginModeRemote)
    {
        return [self isEnableInternet];
    }
    else
    {
        return [self isEnableWIFI];
    }
}

- (void) setLocalRouterLoginFinish:(id)target callback:(SEL)selector
{
    m_target_local = target;
    m_selector_local = selector;
}
- (void) setSmartNetworkLoginFinish:(id)target callback:(SEL)selector
{
    m_target_remote = target;
    m_selector_remote = selector;
}
- (void) setNoRemoteRouter:(id)target callback:(SEL)selector
{
    m_target_no_remote_router = target;
    m_selector_no_remote_router = selector;
}
- (void) adjustLoginPanelWithOrientation:(UIInterfaceOrientation) orientation
{
#ifdef __GENIE_IPHONE__
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        m_loginPanelBg.center = CGPointMake(m_view.frame.size.width/2, m_view.frame.size.height*2/5);
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        CGFloat offset_y = 0;//y轴向上偏移量
        if ([m_accountTextField isFirstResponder] || [m_passwordTextField isFirstResponder])
        {
            offset_y = 30;
        }
        else
        {
            offset_y = 0;
        }
        m_loginPanelBg.center = CGPointMake(m_view.frame.size.width/2, m_view.frame.size.height/2 - offset_y);
    }
#else
    CGFloat offset_y = 0;//向上偏移量
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        offset_y = 55;
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if ([m_accountTextField isFirstResponder] || [m_passwordTextField isFirstResponder])
        {
            offset_y = 100;
        }
        else
        {
            offset_y = 55;
        }
    }
    m_loginPanelBg.center = CGPointMake(m_view.frame.size.width/2, m_view.frame.size.height/2 - offset_y);
#endif
}

- (void) showViewWithOritation:(UIInterfaceOrientation) orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        self.view.backgroundColor = BACKGROUNDCOLOR;
        m_view.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenWidth, iOSDeviceScreenHeight-iOSStatusBarHeight-Navi_Bar_Height_Portrait);
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        self.view.backgroundColor = BACKGROUNDCOLOR;
        m_view.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenHeight, iOSDeviceScreenWidth-iOSStatusBarHeight-Navi_Bar_Height_Landscape);
    }
    [self adjustLoginPanelWithOrientation:orientation];
    
    
#ifdef GENIE_TEST
#ifdef __GENIE_IPHONE__
    CGFloat height = 16;
#else
    CGFloat height = 40;
#endif
    UITextField * tf = (UITextField*)[m_view viewWithTag:tag_testField];
    tf.center = CGPointMake(m_view.frame.size.width/2, height);
#endif
}

- (void) showLoginPanelForLoginMode:(GenieLoginMode)mode
{
    if (mode == GenieLoginModeLocal)
    {
        m_loginModeSwitcher.on = NO;
        [self showLocalLoginPanel];
    }
    else
    {
        m_loginModeSwitcher.on = YES;
        [self showRemoteLoginPanel];
    }
}

- (void) clearLoginPanel
{
#ifdef GENIE_TEST
    if (m_loginMode == GenieLoginModeLocal)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        UITextField * tf = (UITextField*)[m_view viewWithTag:tag_testField];
        [tf resignFirstResponder];
        tf.hidden = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.title = @"Test";
    }
#endif
    for (UIView * v1 in [m_loginPanel_remote subviews])
    {
        [v1 removeFromSuperview];
    }
    for (UIView * v2 in [m_loginPanel_local subviews])
    {
        [v2 removeFromSuperview];
    }
}

- (void) showLocalLoginPanelForNotSupportSmartNetwork//
{
#ifdef __GENIE_IPHONE__
    CGFloat rowSpace = 13;
#else
    CGFloat rowSpace = 24;
#endif
    int y = 25;

    m_accountLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_accountLabel.text = Localization_Login_MainPage_RouterAdmin_Title;
    m_accountTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    m_accountTextField.text = [GenieHelper getLocalRouterAdmin];
    m_accountTextField.enabled = NO;
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_accountLabel];
    [m_loginPanel_local addSubview:m_accountTextField];
    
    m_passwordLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_passwordTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace/2;
    [m_loginPanel_local addSubview:m_passwordLabel];
    [m_loginPanel_local addSubview:m_passwordTextField];
    
    CGFloat h = m_defaultPasswordPromptLabel.frame.size.height;
    m_defaultPasswordPromptLabel.center = CGPointMake((int)(LabelLength + (LoginPanelWidth-LabelLength)/2), (int)(y + h/2));
    y += h;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_defaultPasswordPromptLabel];
    
    m_rememberMeLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_rememberMeSwitcher.center = CGPointMake(LabelLength + m_rememberMeSwitcher.frame.size.width/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_rememberMeLabel];
    [m_loginPanel_local addSubview:m_rememberMeSwitcher];
    
    m_cancelBtn.center = CGPointMake(LoginPanelWidth/4, y + m_cancelBtn.frame.size.height/2);
    m_loginBtn.center = CGPointMake(LoginPanelWidth*3/4, y + m_loginBtn.frame.size.height/2);
    [m_loginPanel_local addSubview:m_loginBtn];
    [m_loginPanel_local addSubview:m_cancelBtn];
    
    ////////
    m_rememberMeSwitcher.on = YES;
    m_passwordTextField.text = @"";
    if (![GenieHelper getRouterLoginRememberMeFlag])
    {
        m_rememberMeSwitcher.on = NO;
    }
    if (m_rememberMeSwitcher.on)
    {
        NSString * key = [GenieHelper getLocalRouterPassword];
        if ([key length])
        {
            m_passwordTextField.text = key;
        }
    }
    
    m_loginPanel_remote.hidden = YES;
    m_loginPanel_local.hidden = NO;
}

- (void) showLocalLoginPanel
{
    [self clearLoginPanel];//
    
#ifdef __GENIE_IPHONE__
    CGFloat rowSpace = 13;
#else
    CGFloat rowSpace = 23;
#endif
    
    int y = 0;
    
#ifdef __GENIE_IPHONE__
    m_loginModeLabel.center = CGPointMake(LabelLength/2, m_loginModeSwitcher.frame.size.height/2);
    m_loginModeSwitcher.center = CGPointMake(LabelLength + m_loginModeSwitcher.frame.size.width/2, DefaultRowHeight/2);
    y += m_loginModeSwitcher.frame.size.height;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_loginModeLabel];
    [m_loginPanel_local addSubview:m_loginModeSwitcher];
#else
    m_loginModeLabel.center = CGPointMake(LabelLength/2, DefaultRowHeight/2);
    m_loginModeSwitcher.center = CGPointMake(LabelLength + m_loginModeSwitcher.frame.size.width/2, DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_loginModeLabel];
    [m_loginPanel_local addSubview:m_loginModeSwitcher];
#endif
    
    m_accountLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_accountLabel.text = Localization_Login_MainPage_RouterAdmin_Title;
    m_accountTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    m_accountTextField.text = [GenieHelper getLocalRouterAdmin];
    m_accountTextField.enabled = NO;
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_accountLabel];
    [m_loginPanel_local addSubview:m_accountTextField];
    
    m_passwordLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_passwordTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace/2;
    [m_loginPanel_local addSubview:m_passwordLabel];
    [m_loginPanel_local addSubview:m_passwordTextField];
    
    CGFloat h = m_defaultPasswordPromptLabel.frame.size.height;
    m_defaultPasswordPromptLabel.center = CGPointMake((int)(LabelLength + (LoginPanelWidth-LabelLength)/2), (int)(y + h/2));
    y += h;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_defaultPasswordPromptLabel];
    
    m_rememberMeLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_rememberMeSwitcher.center = CGPointMake(LabelLength + m_rememberMeSwitcher.frame.size.width/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_local addSubview:m_rememberMeLabel];
    [m_loginPanel_local addSubview:m_rememberMeSwitcher];
    
    m_cancelBtn.center = CGPointMake(LoginPanelWidth/4, y + m_cancelBtn.frame.size.height/2);
    m_loginBtn.center = CGPointMake(LoginPanelWidth*3/4, y + m_loginBtn.frame.size.height/2);
    [m_loginPanel_local addSubview:m_loginBtn];
    [m_loginPanel_local addSubview:m_cancelBtn];
    
    ////////
    m_rememberMeSwitcher.on = YES;
    m_passwordTextField.text = @"";
    if (![GenieHelper getRouterLoginRememberMeFlag])
    {
        m_rememberMeSwitcher.on = NO;
    }
    if (m_rememberMeSwitcher.on)
    {
        NSString * key = [GenieHelper getLocalRouterPassword];
        if ([key length])
        {
            m_passwordTextField.text = key;
        }
    }
    
    m_loginPanel_remote.hidden = YES;
    m_loginPanel_local.hidden = NO;
}

- (void) showRemoteLoginPanel
{
    [self clearLoginPanel];//
 
#ifdef __GENIE_IPHONE__
    CGFloat rowSpace = 12;
#else
    CGFloat rowSpace = 20;
#endif
    CGFloat y = 0;
    
#ifdef __GENIE_IPHONE__
    m_loginModeLabel.center = CGPointMake(LabelLength/2, m_loginModeSwitcher.frame.size.height/2);
    m_loginModeSwitcher.center = CGPointMake(LabelLength + m_loginModeSwitcher.frame.size.width/2, DefaultRowHeight/2);
    y += m_loginModeSwitcher.frame.size.height;
    y += rowSpace;
    [m_loginPanel_remote addSubview:m_loginModeLabel];
    [m_loginPanel_remote addSubview:m_loginModeSwitcher];
#else
    m_loginModeLabel.center = CGPointMake(LabelLength/2, DefaultRowHeight/2);
    m_loginModeSwitcher.center = CGPointMake(LabelLength + m_loginModeSwitcher.frame.size.width/2, DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_remote addSubview:m_loginModeLabel];
    [m_loginPanel_remote addSubview:m_loginModeSwitcher];
#endif
    
    m_accountLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_accountLabel.text = Localization_Login_MainPage_SN_Account_Title;
    m_accountTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    m_accountTextField.text = @"";
    m_accountTextField.enabled = YES;
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_remote addSubview:m_accountLabel];
    [m_loginPanel_remote addSubview:m_accountTextField];
    
    m_passwordLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_passwordTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_remote addSubview:m_passwordLabel];
    [m_loginPanel_remote addSubview:m_passwordTextField];
    
    m_rememberMeLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_rememberMeSwitcher.center = CGPointMake(LabelLength + m_rememberMeSwitcher.frame.size.width/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel_remote addSubview:m_rememberMeLabel];
    [m_loginPanel_remote addSubview:m_rememberMeSwitcher];

    CGFloat w = m_signUpHyper.frame.size.width;
    CGFloat h = m_signUpHyper.frame.size.height;
    
    m_forgerPasswordHyper.center = CGPointMake(w/2, y + h/2);
    m_signUpHyper.center = CGPointMake(w + w/2, y + h/2);
    y += h;
    y += rowSpace;
    [m_loginPanel_remote addSubview:m_forgerPasswordHyper];
    [m_loginPanel_remote addSubview:m_signUpHyper];

    m_loginBtn.center = CGPointMake(LoginPanelWidth*3/4, y + m_loginBtn.frame.size.height/2);
    m_cancelBtn.center = CGPointMake(LoginPanelWidth/4, y + m_cancelBtn.frame.size.height/2);
    [m_loginPanel_remote addSubview:m_loginBtn];
    [m_loginPanel_remote addSubview:m_cancelBtn];
    
    //////
    m_rememberMeSwitcher.on = [GenieHelper getSmartNetworkRememberMeFlag];
    m_accountTextField.text = @"";
    m_passwordTextField.text = @"";
    if (m_rememberMeSwitcher.on)
    {
        m_accountTextField.text = [GenieHelper getSmartNetworkAccount];
        m_passwordTextField.text = [GenieHelper getSmartNetworkPassword];
    }
    
    m_loginPanel_local.hidden = YES;
    m_loginPanel_remote.hidden = NO;
}


#pragma mark --------action
- (void) callbackKyeBoard
{
    [m_accountTextField resignFirstResponder];
    [m_passwordTextField resignFirstResponder];
    [self adjustLoginPanelWithOrientation:self.interfaceOrientation];
}

- (void) loginModeSwitcherValueChanged
{
    [GenieHelper setGenieLoginModeForRemoteLogin:m_loginModeSwitcher.on];
    
    if (m_loginModeSwitcher.on)
    {
        m_loginMode = GenieLoginModeRemote;
    }
    else
    {
        m_loginMode = GenieLoginModeLocal;
    }
    [self showLoginPanelForLoginMode:m_loginMode];
}

- (void) rememberMeSwitcherValueChanged
{
    if (m_loginMode == GenieLoginModeLocal)
    {
        [GenieHelper setRouterLoginRememberMeFlag:m_rememberMeSwitcher.on];
        
        if (!m_rememberMeSwitcher.on)
        {
            [GenieHelper saveLocalRouterPassword:@""];//清空密码记录
        }
    }
    else
    {
        [GenieHelper setSmartNetworkRememberMeFlag:m_rememberMeSwitcher.on];
        
        if (!m_rememberMeSwitcher.on)
        {
            [GenieHelper saveSmartNetworkAccount:@""];
            [GenieHelper saveSmartNetworkPassword:@""];
        }
    }
}

static NSString * baseUrl = @"genie.netgear.com";//不需要http://头
- (void) loginSmartNetwork
{
#ifndef GENIE_TEST
    [[GenieHelper shareGenieBusinessHelper].soapHelper setSmartNetworkBaseUrl:baseUrl];
#endif
    [[GenieHelper shareGenieBusinessHelper].soapHelper setSmartNetworkUsername:m_accountTextField.text password:m_passwordTextField.text];
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startGetSmartNetworkList];
    [GPWaitDialog show:op withTarget:self selector:@selector(getSNRouterList_callback:) waitMessage:Local_Wait timeout:Genie_NoTimeOut cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) loginLocalRouter
{
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startRouterLoginWithAdmin:m_accountTextField.text password:m_passwordTextField.text];
    [GPWaitDialog show:op withTarget:self selector:@selector(localLoginCallback:) waitMessage:Local_Wait timeout:Genie_Login_ProcessTimeout cancelBtn:Localization_Cancel needCountDown:YES waitTillTimeout:NO];
    m_timer = [NSTimer scheduledTimerWithTimeInterval: 10
                                               target: self
                                             selector: @selector(handleTimer:)
                                             userInfo: nil
                                              repeats: YES];
}

- (void)handleTimer:(NSTimer*)time
{
    m_timeout = YES;
}

- (void) login
{
    if (![self isNetworkAvailable])
    {
        return;
    }
    
    if (m_loginMode == GenieLoginModeLocal)
    {
        [self loginLocalRouter];
    }
    else
    {
        [self loginSmartNetwork];
    }
}

- (void) loginBtnPress
{
    [self callbackKyeBoard];
    [self login];
}

- (void) cancelBtnPress
{
    [self callbackKyeBoard];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - textfield callback
- (void) textFieldDidBeginEditing:(UITextField*)textField
{
    [self adjustLoginPanelWithOrientation:self.interfaceOrientation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
#ifdef GENIE_TEST
    UITextField * tf = (UITextField*)[m_view viewWithTag:tag_testField];
    if (tf == textField)
    {
        [self setSmartNetworkServerBaseUrlDone];
        return YES;
    }
#endif
    //////////////
    [textField resignFirstResponder];
    [self adjustLoginPanelWithOrientation:self.interfaceOrientation];
    [self login];
    return YES;
}

#pragma  mark --callback
- (void) localLoginCallback:(GenieCallbackObj*) obj
{
    //do something
    GenieErrorType err = obj.error;
    if ([m_timer isValid])
    {
        [m_timer invalidate];
    }
    GTAsyncOp * op = (GTAsyncOp*)obj.userInfo;
    
    if (obj.error != GenieErrorAsyncOpCancel)
    {
        if ([op result].count <= 0 && m_timeout)
        {
            err = GenieErrorAsyncOpTimeout;
        }
    }
    
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        if (m_rememberMeSwitcher.on)
        {
            [GenieHelper saveLocalRouterPassword:m_passwordTextField.text];
        }
        
        [GenieHelper setCurrentRouterAdmin:m_accountTextField.text password:m_passwordTextField.text];
        [m_target_local performSelector:m_selector_local withObject:obj];
    }
    else
    {
        if (err == GenieErrorNotNetgearRouter)
        {
            [self showSpecialAlertViewForNotNetgearRouter];
        }
        else if (err == GenieErrorLoginPasskeyInvalid)
        {
            [self showSpecialAlertViewForLoginKeyInvalid];
        }
        else if (err != GenieErrorAsyncOpCancel)
        {
            [GenieHelper showMsgBoxWithMsg:Local_MsgForTimeout];
        }
        else
        {
            return;
        }
    }
}

- (void) getSNRouterList_callback:(GenieCallbackObj*) obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        if (m_rememberMeSwitcher.on)
        {
            [GenieHelper saveSmartNetworkAccount:m_accountTextField.text];
            [GenieHelper saveSmartNetworkPassword:m_passwordTextField.text];
        }
        
        GenieRemoteRouterList * list = [GenieHelper getRootViewController].remoteRouterList;
        [list getRemoteRouters:obj];
        if ([list noRemoteDevicesFound])
        {
            [m_target_no_remote_router performSelector:m_selector_no_remote_router];
            [self showSpecialAlertViewForNoRemoteDevices];
        }
        else
        {
            [m_target_remote performSelector:m_selector_remote];
        }
    }
    else if (err == GenieError_SN_Authenticate_Failed)
    {
        [self showSpecialAlertViewForLoginSmartnetworkKeyInvalid];
    }
    else if (err != GenieErrorAsyncOpCancel)
    {
        [GenieHelper showMsgBoxWithMsg:Local_MsgForNetworkError];
    }
    else
    {
        return;
    }
}

#pragma mark ______________special alert view and delegate
#define AlertView_LoginFailedPrompt_Tag             100
#define AlertView_NotNetgearRouter_Prompt_Tag       101
#define AlertView_Login_SN_FailedPrompt_Tag         201
#define AlertView_SN_No_Devices_FoundPrompt_Tag     202

- (void) showSpecialAlertViewForNotNetgearRouter
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n" delegate:self cancelButtonTitle:Localization_Close otherButtonTitles:nil];
    alert.tag = AlertView_NotNetgearRouter_Prompt_Tag;
    [alert show];
    [alert release];
}
- (void) showSpecialAlertViewForLoginKeyInvalid
{
    UIAlertView * keyInvalidAlertView = [[UIAlertView alloc] initWithTitle:nil message:Local_MsgForLoginGenieKeyInvalid delegate:self cancelButtonTitle:Localization_Ok otherButtonTitles:nil];
    keyInvalidAlertView.tag = AlertView_LoginFailedPrompt_Tag;
    [keyInvalidAlertView show];
    [keyInvalidAlertView release];
}
- (void) showSpecialAlertViewForLoginSmartnetworkKeyInvalid
{
    UIAlertView * keyInvalidAlertView = [[UIAlertView alloc] initWithTitle:nil message:Local_MsgForSmartNetworkLoginKeyWrong delegate:self cancelButtonTitle:Localization_Ok otherButtonTitles:nil];
    keyInvalidAlertView.tag = AlertView_Login_SN_FailedPrompt_Tag;
    [keyInvalidAlertView show];
    [keyInvalidAlertView release];
}

- (void) showSpecialAlertViewForNoRemoteDevices
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:Localization_Close otherButtonTitles:nil];
    alert.tag = AlertView_SN_No_Devices_FoundPrompt_Tag;
    [alert show];
    [alert release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertView_LoginFailedPrompt_Tag)
    {
        [m_passwordTextField becomeFirstResponder];
    }
}

- (void) willPresentAlertView:(UIAlertView *)alertView
{
    if (alertView.tag == AlertView_NotNetgearRouter_Prompt_Tag)
    {
        CGFloat offset = 5.0f;
        CGRect rec = alertView.frame;
        UIWebView * webPage = [[UIWebView alloc]init];
        webPage.frame = CGRectMake(0, 0, rec.size.width*0.95, rec.size.height*0.5);
        webPage.center = CGPointMake(rec.size.width/2, webPage.frame.size.height/2 + offset);
        NSString * cssString = @"<style>body{font-family:Helvetica;color:white;text-align:center}a:link{color:#6666cc}} </style>";
        [webPage loadHTMLString:[cssString stringByAppendingString:Local_MsgForNotNetgearRouter_HTML] 
                        baseURL:nil];
        webPage.delegate = self;
        webPage.backgroundColor = [UIColor clearColor];
        webPage.opaque = NO;
        for (UIView *subView in [webPage subviews])
        {
            if ([subView isKindOfClass:[UIScrollView class]])
            {
                UIScrollView * v = (UIScrollView*)subView;
                v.scrollEnabled = NO;
            }
        }
        webPage.dataDetectorTypes = UIDataDetectorTypeNone;
        [alertView addSubview:webPage];
        [webPage release];
    }
    else if (alertView.tag == AlertView_SN_No_Devices_FoundPrompt_Tag)
    {
        for (UIView * v in alertView.subviews)
        {
            if ([v isKindOfClass:[UIWebView class]])
            {
                [v removeFromSuperview];
            }
        }
        CGFloat offset = 15.0f;
        CGRect rec = alertView.frame;
        UIWebView * webPage = [[UIWebView alloc]init];
        webPage.frame = CGRectMake(0, 0, rec.size.width*0.95, rec.size.height*0.68);
        webPage.center = CGPointMake(rec.size.width/2, webPage.frame.size.height/2 + offset);
        NSString * cssString = @"<style>body{font-family:Helvetica;color:white;text-align:left}a:link{color:#6666cc}} </style>";
        [webPage loadHTMLString:[cssString stringByAppendingString:Local_MsgForSmartNetworkNoDeviceFound] 
                        baseURL:nil];
        webPage.delegate = self;
        webPage.backgroundColor = [UIColor clearColor];
        webPage.opaque = NO;
        webPage.dataDetectorTypes = UIDataDetectorTypeNone;
        [alertView addSubview:webPage];
        [webPage release];
    }
}
@end
