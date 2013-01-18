//
//  GenieRemoteRouterLoginPage.m
//  GenieiPad
//
//  Created by cs Siteview on 12-6-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieRemoteRouterLoginPage.h"
#import "GenieGlobal.h"
#import "GenieHelper.h"

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

const BOOL isForLogin = YES;
const BOOL isForSwitcherChanged = NO;
@implementation GenieRemoteRouterLoginPage

- (id) initwithRouterInfo:(GenieRemoteRouterInfo*)router
{
    self = [super init];
    if (self) 
    {
        m_view = nil;
        m_loginPanelBg = nil;
        m_accountLabel = nil;
        m_accountTextField = nil;
        m_passwordLabel = nil;
        m_passwordTextField = nil;
        m_rememberMeLabel = nil;
        m_rememberMeSwitcher = nil;
        m_loginBtn = nil;
        m_cancelBtn = nil;
        
        m_routerInfo = [router retain];
        
        m_routerLoginInfoList = [[self readRouterLoginInfoList] retain];
        if (!m_routerLoginInfoList)
        {
            m_routerLoginInfoList = [[NSMutableArray alloc] init];
        }
        
        m_selector = nil;
        m_target = nil;
    }
    return self;
}

- (id) init
{
    return [self initwithRouterInfo:nil];
}

- (void)dealloc
{
    [self writeRouterLoginInfo];
    //
    [m_routerLoginInfoList release];
    [m_routerInfo release];
    [m_cancelBtn release];
    [m_loginBtn release];
    [m_rememberMeSwitcher release];
    [m_rememberMeLabel release];
    [m_passwordTextField release];
    [m_passwordLabel release];
    [m_accountTextField release];
    [m_accountLabel release];
    [m_loginPanel release];
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
    self.title = Localization_Login_RemoteRouterLogin_PageTitle;
}

- (void) initLoginView
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
    
    m_loginPanel = [[UIControl alloc] initWithFrame:LoginPanelFrame];
    [m_loginPanel addTarget:self action:@selector(callbackKyeBoard) forControlEvents:UIControlEventTouchUpInside];
    m_loginPanel.backgroundColor = [UIColor clearColor];
    
    {
        CGRect rec = m_loginPanelBg.frame;
#ifdef __GENIE_IPHONE__
        m_loginPanel.center = CGPointMake(rec.size.width/2, rec.size.height/2);
#else
        CGFloat offset = 55;//ipad版本的背景图片加入了一个图标（h = 110），因此需要将loginPanel向下偏移
        m_loginPanel.center = CGPointMake(rec.size.width/2, rec.size.height/2 + offset);
#endif
        [m_loginPanelBg addSubview:m_loginPanel];
    }

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLoginView];  
    [self layoutLoginPanel];
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

#pragma mark - custom
static NSString * remote_router_login_info_list_key = @"remote_router_login_info_list_key";
static NSString * remote_router_serial_key = @"remote_router_serial_key";
static NSString * remote_router_login_remember_me_flag_key = @"remote_router_login_remember_me_flag_key";
static NSString * remote_router_login_account_key = @"remote_router_login_account_key";
static NSString * remote_router_login_password_key = @"remote_router_login_password_key";
- (void) cachingRouterLoginInfoForLoginOrSwitchChanged:(BOOL)isLogin
{
    //removo the old recode of this router
    NSDictionary * dic1 = nil;
    for (NSDictionary * dic in m_routerLoginInfoList)
    {
        if ([m_routerInfo.serial isEqualToString:[dic objectForKey:remote_router_serial_key]])
        {
            dic1 = dic;
            break;
        }
    }
    [m_routerLoginInfoList removeObject:dic1];
    
    //
    if (isLogin == isForSwitcherChanged)
    {
        NSMutableDictionary * routerLoginInfo = [[NSMutableDictionary alloc] init];
        [routerLoginInfo setObject:m_routerInfo.serial forKey:remote_router_serial_key];
        [routerLoginInfo setObject:[NSNumber numberWithBool:m_rememberMeSwitcher.on] forKey:remote_router_login_remember_me_flag_key];
        NSString * admin = @"";
        NSString * password = @"";
        [routerLoginInfo setObject:admin forKey:remote_router_login_account_key];
        [routerLoginInfo setObject:password forKey:remote_router_login_password_key];
        [m_routerLoginInfoList addObject:routerLoginInfo];
        [routerLoginInfo release];
    }
    else
    {
        NSMutableDictionary * routerLoginInfo = [[NSMutableDictionary alloc] init];
        [routerLoginInfo setObject:m_routerInfo.serial forKey:remote_router_serial_key];
        [routerLoginInfo setObject:[NSNumber numberWithBool:m_rememberMeSwitcher.on] forKey:remote_router_login_remember_me_flag_key];
        NSString * admin = @"";
        NSString * password = @"";
        if (m_rememberMeSwitcher.on)
        {
            admin = m_accountTextField.text;
            password = m_passwordTextField.text;
        }
        [routerLoginInfo setObject:admin forKey:remote_router_login_account_key];
        [routerLoginInfo setObject:password forKey:remote_router_login_password_key];
        [m_routerLoginInfoList addObject:routerLoginInfo];
        [routerLoginInfo release];
    }
}
- (void) writeRouterLoginInfo
{
    if ([m_routerLoginInfoList count])//list 中没有数据时，不写入文件
    {
        [GenieHelper write:[NSDictionary dictionaryWithObject:m_routerLoginInfoList forKey:remote_router_login_info_list_key] toFile:Genie_File_SN_Authenticated_Routers_Info];
    }
}
- (NSMutableArray*) readRouterLoginInfoList
{
    return [[GenieHelper readFile:Genie_File_SN_Authenticated_Routers_Info] objectForKey:remote_router_login_info_list_key];
}

- (void) layoutRouterInfo
{
#ifdef __GENIE_IPHONE__
    CGFloat  infoViewHeight = 55;
#else
    CGFloat  infoViewHeight = 85;
#endif
    CGRect rec1 = CGRectMake(0, 0, LoginPanelWidth, infoViewHeight);
    UIControl * routerInfoView = [[UIControl alloc] initWithFrame:rec1];
    [routerInfoView addTarget:self action:@selector(callbackKyeBoard) forControlEvents:UIControlEventTouchUpInside];
    routerInfoView.backgroundColor = [UIColor clearColor];
    [m_loginPanel addSubview:routerInfoView];
    
    NSString * routerIconStr = m_routerInfo.icon;
    if (!routerIconStr)
    {
        routerIconStr = @"router_default_icon";
    }
    UIImageView * routerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, infoViewHeight, infoViewHeight)];
     routerIcon.image = [UIImage imageNamed:routerIconStr];
    routerIcon.backgroundColor = [UIColor clearColor];
    [routerInfoView addSubview:routerIcon];
    [routerIcon release];
       
    CGRect rec2 = CGRectMake(0, 0, (LoginPanelWidth-infoViewHeight)*0.95/2, infoViewHeight/2);
#ifdef __GENIE_IPHONE__
    CGFloat font_size1 = 13.0f;
    CGFloat font_size2 = 9.0f;
    CGFloat offset_x = 3;//label 与icon的边缘间距 以及与右边缘的距离
#else
    CGFloat font_size1 = 20.0f;
    CGFloat font_size2 = 17.0f;
    CGFloat offset_x = 5;
#endif
    UILabel * friendlyNameLabel = [[UILabel alloc] initWithFrame:rec2];
    friendlyNameLabel.center = CGPointMake(infoViewHeight + offset_x + rec2.size.width/2, infoViewHeight/4);
    friendlyNameLabel.font = [UIFont systemFontOfSize:font_size1]; 
    friendlyNameLabel.text = m_routerInfo.friendlyName;
    friendlyNameLabel.backgroundColor = [UIColor clearColor];
    
    UILabel * serialLabel = [[UILabel alloc] initWithFrame:rec2];
    serialLabel.center = CGPointMake(infoViewHeight + offset_x + rec2.size.width/2, infoViewHeight*3/4);
    serialLabel.font = [UIFont systemFontOfSize:font_size2];
    serialLabel.text = [NSString stringWithFormat:@"%@:%@",Localization_Login_RemoteRouterList_Serial_Title, m_routerInfo.serial];
    serialLabel.backgroundColor = [UIColor clearColor];
    
    UILabel * modelNameLable = [[UILabel alloc] initWithFrame:rec2];
    modelNameLable.center = CGPointMake(LoginPanelWidth - rec2.size.width/2 - offset_x, infoViewHeight/4);
    modelNameLable.font = [UIFont systemFontOfSize:font_size2];
    modelNameLable.text = [m_routerInfo.modelName stringByAppendingString:@" "];
    modelNameLable.textAlignment = UITextAlignmentRight;
    modelNameLable.backgroundColor = [UIColor clearColor];
    
    UILabel * statusLabel = [[UILabel alloc] initWithFrame:rec2];
    statusLabel.center = CGPointMake(LoginPanelWidth - rec2.size.width/2 - offset_x, infoViewHeight*3/4);
    statusLabel.font = [UIFont systemFontOfSize:font_size2];
    statusLabel.text = [Localization_Login_RemoteRouter_online_status stringByAppendingString:@" "];
    statusLabel.textAlignment = UITextAlignmentRight;
    statusLabel.backgroundColor = [UIColor clearColor];
    
    [routerInfoView addSubview:friendlyNameLabel];
    [routerInfoView addSubview:serialLabel];
    [routerInfoView addSubview:modelNameLable];
    [routerInfoView addSubview:statusLabel];
    [friendlyNameLabel release];
    [serialLabel release];
    [modelNameLable release];
    [statusLabel release];
    
    [routerInfoView release];
}

- (void) initLoginInfoWithConfigInfo
{
    m_rememberMeSwitcher.on = YES;
    m_accountTextField.text = Genie_ADMIN;
    m_passwordTextField.text = @"";
    
    for (NSDictionary * dic in m_routerLoginInfoList)
    {
        if ([m_routerInfo.serial isEqualToString:[dic objectForKey:remote_router_serial_key]])
        {
            if ([[dic objectForKey:remote_router_login_remember_me_flag_key] boolValue])
            {
                m_rememberMeSwitcher.on = YES;
                m_passwordTextField.text = [dic objectForKey:remote_router_login_password_key];
            }
            else
            {
                m_rememberMeSwitcher.on = NO;
            }
            break;
        }
    }
}

- (void) layoutLoginPanel
{
    [self layoutRouterInfo]; 
#ifdef __GENIE_IPHONE__
    int y = 68;
    CGFloat rowSpace = 13;
#else
    int y = 108;
    CGFloat rowSpace = 23;
#endif
    
    m_accountLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_accountLabel.text = Localization_Login_MainPage_RouterAdmin_Title;
    m_accountTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    m_accountTextField.enabled = NO;
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel addSubview:m_accountLabel];
    [m_loginPanel addSubview:m_accountTextField];
    
    m_passwordLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_passwordTextField.center = CGPointMake(LabelLength + (LoginPanelWidth-LabelLength)/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace/2;
    [m_loginPanel addSubview:m_passwordLabel];
    [m_loginPanel addSubview:m_passwordTextField];
    
    m_rememberMeLabel.center = CGPointMake(LabelLength/2, y + DefaultRowHeight/2);
    m_rememberMeSwitcher.center = CGPointMake(LabelLength + m_rememberMeSwitcher.frame.size.width/2, y + DefaultRowHeight/2);
    y += DefaultRowHeight;
    y += rowSpace;
    [m_loginPanel addSubview:m_rememberMeLabel];
    [m_loginPanel addSubview:m_rememberMeSwitcher];
    
    m_loginBtn.center = CGPointMake(LoginPanelWidth*3/4, y + m_loginBtn.frame.size.height/2);
    m_cancelBtn.center = CGPointMake(LoginPanelWidth/4, y + m_cancelBtn.frame.size.height/2);
    [m_loginPanel addSubview:m_loginBtn];
    [m_loginPanel addSubview:m_cancelBtn];
    
    ////////
    [self initLoginInfoWithConfigInfo];
}

- (void) setRouterLoginFinish:(id)target callback:(SEL) selector
{
    m_target = target;
    m_selector = selector;
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
        CGFloat offset_y = 0;//向上偏移量
        if ([m_accountTextField isFirstResponder] || [m_passwordTextField isFirstResponder])
        {
            offset_y = 90;
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
            offset_y = 110;
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
        m_view.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenWidth, iOSDeviceScreenHeight-iOSStatusBarHeight-Navi_Bar_Height_Portrait);
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        m_view.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenHeight, iOSDeviceScreenWidth-iOSStatusBarHeight-Navi_Bar_Height_Landscape);
    }
    [self adjustLoginPanelWithOrientation:orientation];
}

#pragma mark --------action
- (void) callbackKyeBoard
{
    [m_accountTextField resignFirstResponder];
    [m_passwordTextField resignFirstResponder];
    [self adjustLoginPanelWithOrientation:self.interfaceOrientation];
}

- (void) rememberMeSwitcherValueChanged
{
    [self cachingRouterLoginInfoForLoginOrSwitchChanged:isForSwitcherChanged];
}

- (void) login
{
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startRouterLoginWithAdmin:m_accountTextField.text password:m_passwordTextField.text controlPointID:[m_routerInfo controlId]];
    [GPWaitDialog show:op withTarget:self selector:@selector(loginCallback:) waitMessage:Local_Wait timeout:Genie_Login_ProcessTimeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
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
    [textField resignFirstResponder];
    [self adjustLoginPanelWithOrientation:self.interfaceOrientation];
    [self login];
    return YES;
}

#pragma  mark --callback
- (void) loginCallback:(GenieCallbackObj*) obj
{
    //do something
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self cachingRouterLoginInfoForLoginOrSwitchChanged:isForLogin];
        [GenieHelper setCurrentRouterAdmin:m_accountTextField.text password:m_passwordTextField.text];
        [m_target performSelector:m_selector withObject:obj];
    }
    else
    {
        if (err == GenieErrorLoginPasskeyInvalid)
        {
            [self showSpecialAlertViewForLoginKeyInvalid];
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
}

#pragma mark ______________special alert view and delegate
#define AlertView_LoginFailedPrompt_Tag             100

- (void) showSpecialAlertViewForLoginKeyInvalid
{
    UIAlertView * keyInvalidAlertView = [[UIAlertView alloc] initWithTitle:nil message:Local_MsgForLoginGenieKeyInvalid delegate:self cancelButtonTitle:Localization_Ok otherButtonTitles:nil];
    keyInvalidAlertView.tag = AlertView_LoginFailedPrompt_Tag;
    [keyInvalidAlertView show];
    [keyInvalidAlertView release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertView_LoginFailedPrompt_Tag)
    {
        [m_passwordTextField becomeFirstResponder];
    }
}
@end
