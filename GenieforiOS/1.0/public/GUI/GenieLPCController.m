//
//  GenieLPCController.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieLPCController.h"
#import "GenieHelper.h"
#import "GenieLPCFilterLevelList.h"
#import "GenieLPCChildList.h"
#import "GenieLPCChildAccount.h"
#import "GenieHelper_Statistics.h"

//注：LPC模块中不处理V1.0.15版本中的用户相关数据
#ifdef __GENIE_IPHONE__
#define TextFieldFrame                 CGRectMake(0,0,160,31)
#else
#define TextFieldFrame                 CGRectMake(0,0,320,31)
#endif
@implementation GenieLPCController
static NSString * configInfo_opendnsAccount_key = @"opendns_account";
static NSString * configInfo_opendnsPassword_key = @"opendns_password";
static NSString * configInfo_routerMacAddress = @"router_macaddress";

- (id) init
{
    self = [super init];
    if (self)
    {
        m_tableview = nil;
        m_pageMode = LPCPageForNone;
        m_inputError = LPCInput_NoError;
        //__ui item
        m_createAccount_userNameTextField = nil;
        m_createAccount_passwordTextField = nil;
        m_createAccount_confirmPasswordTextField = nil;
        m_createAccount_emailTextField = nil;
        m_createAccount_confirmEmailTextField = nil;
        m_login_userNameTextField = nil;
        m_login_passwordTextField = nil;
        m_switcher = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_switcher release];
    [m_login_passwordTextField release];
    [m_login_userNameTextField release];
    [m_createAccount_confirmEmailTextField release];
    [m_createAccount_emailTextField release];
    [m_createAccount_confirmPasswordTextField release];
    [m_createAccount_passwordTextField release];
    [m_createAccount_userNameTextField release];
    [m_tableview release];
    [[GenieHelper getLPCData] clear];//
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChange:) 
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:nil];
    UIView * v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = v;
    [v release];
    m_tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    UIControl * tableBgView = [[UIControl alloc] init];
    [tableBgView addTarget:self action:@selector(backgroundTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    m_tableview.backgroundView = tableBgView;
    [tableBgView release];
#ifndef __GENIE_IPHONE__
    m_tableview.backgroundColor = BACKGROUNDCOLOR;
#endif
    m_tableview.dataSource = self;
    m_tableview.delegate = self;
    [self.view addSubview:m_tableview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([GenieHelper isSmartNetwork])
    {
        NSDictionary * lpcConfigInfo = [self readLPCConfigInfoDictionary];
        [GenieHelper getLPCData].openDNSAccount = [lpcConfigInfo objectForKey:configInfo_opendnsAccount_key];
        [GenieHelper getLPCData].openDNSPassword = [lpcConfigInfo objectForKey:configInfo_opendnsPassword_key];
        NSString * routerMacAddr = [lpcConfigInfo objectForKey:configInfo_routerMacAddress];
        if ([[GenieHelper getRouterInfo].mac isEqualToString:routerMacAddr])
        {
            [self getLpcInfoWithWaitMsg:Local_WaitForLoadLPCInfo callback:@selector(smartNetworkAutoLoginLPC_Callback:)];//不需要pingopenDNS的server
        }
        else
        {
            [self showSpecialAlertViewForUserOptionPrompt];
        }
    }
    else
    {
        if ([GenieHelper getRouterInfo].notSupportLPC)
        {
            [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForGenieFuncNotSupport];
        }
        else
        {
            NSMutableDictionary * lpcConfigInfo = [NSMutableDictionary dictionaryWithDictionary:[self readLPCConfigInfoDictionary]];
            [GenieHelper getLPCData].openDNSAccount = [lpcConfigInfo objectForKey:configInfo_opendnsAccount_key];
            [GenieHelper getLPCData].openDNSPassword = [lpcConfigInfo objectForKey:configInfo_opendnsPassword_key];
            NSString * routerMacAddr = [lpcConfigInfo objectForKey:configInfo_routerMacAddress];
            GTAsyncOp * op = nil;
            SEL callback = nil;
            if ([[GenieHelper getRouterInfo].mac isEqualToString:routerMacAddr])
            {
                [GenieHelper configForSetProcessOrLPCProcessStart];//config for start soap in lpc process
                op = [[GenieHelper shareGenieBusinessHelper] startAutoLoginLPC:[GenieHelper getCurrentRouterAdmin] 
                                                                routerPassword:[GenieHelper getCurrentRouterPassword] 
                                                                openDNSAccount:[GenieHelper getLPCData].openDNSAccount 
                                                               openDNSPassword:[GenieHelper getLPCData].openDNSPassword 
                                                                     deviceKey:[NSString stringWithFormat:@"%@-%@",[GenieHelper getRouterInfo].modelName,[GenieHelper getRouterInfo].mac]];
                callback = @selector(autoLoginLPC_Callback:);
            }
            else
            {
                op = [[GenieHelper shareGenieBusinessHelper] startPingOpenDNSHost];
                callback = @selector(pingOpenDNSHost_Callback:);
            }
            [GPWaitDialog show:op withTarget:self selector:callback waitMessage:Local_WaitForLoadLPCInfo timeout:Genie_Get_LPC_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOrientation:self.interfaceOrientation];
    [m_tableview reloadData];
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
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showViewWithOrientation:toInterfaceOrientation];
}

#pragma mark ----------------
- (NSDictionary*) readLPCConfigInfoDictionary
{
    return [GenieHelper readFile:Genie_File_LPC_Config_Info];
}
- (void) saveLPCConfigInfo
{
    NSMutableDictionary * lpcConfigInfoDic = [[NSMutableDictionary alloc] init];
    [lpcConfigInfoDic setObject:[GenieHelper getLPCData].openDNSAccount forKey:configInfo_opendnsAccount_key];
    [lpcConfigInfoDic setObject:[GenieHelper getLPCData].openDNSPassword forKey:configInfo_opendnsPassword_key];
    NSString * routerMac = [GenieHelper getRouterInfo].mac;
    if (!routerMac)
    {
        routerMac = @"";
    }
    [lpcConfigInfoDic setObject:routerMac forKey:configInfo_routerMacAddress];
    [GenieHelper write:lpcConfigInfoDic toFile:Genie_File_LPC_Config_Info];
    [lpcConfigInfoDic release];
}
#pragma mark ---ui element
- (void) prepareUIElemsForCreateAccountPage
{
    m_createAccount_userNameTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_createAccount_userNameTextField.backgroundColor = [UIColor clearColor];
    m_createAccount_userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_createAccount_userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_createAccount_userNameTextField.delegate = self;
    m_createAccount_userNameTextField.returnKeyType = UIReturnKeyDone;
    m_createAccount_userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_createAccount_userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    m_createAccount_passwordTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_createAccount_passwordTextField.backgroundColor = [UIColor clearColor];
    m_createAccount_passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_createAccount_passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_createAccount_passwordTextField.secureTextEntry = YES;
    m_createAccount_passwordTextField.delegate = self;
    m_createAccount_passwordTextField.returnKeyType = UIReturnKeyDone;
    m_createAccount_passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_createAccount_passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    m_createAccount_confirmPasswordTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_createAccount_confirmPasswordTextField.backgroundColor = [UIColor clearColor];
    m_createAccount_confirmPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_createAccount_confirmPasswordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_createAccount_confirmPasswordTextField.secureTextEntry = YES;
    m_createAccount_confirmPasswordTextField.delegate = self;
    m_createAccount_confirmPasswordTextField.returnKeyType = UIReturnKeyDone;
    m_createAccount_confirmPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    m_createAccount_emailTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_createAccount_emailTextField.backgroundColor = [UIColor clearColor];
    m_createAccount_emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_createAccount_emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_createAccount_emailTextField.delegate = self;
    m_createAccount_emailTextField.returnKeyType = UIReturnKeyDone;
    m_createAccount_emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    m_createAccount_emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_createAccount_emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    m_createAccount_confirmEmailTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_createAccount_confirmEmailTextField.backgroundColor = [UIColor clearColor];
    m_createAccount_confirmEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_createAccount_confirmEmailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_createAccount_confirmEmailTextField.delegate = self;
    m_createAccount_confirmEmailTextField.returnKeyType = UIReturnKeyDone;
    m_createAccount_confirmEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    m_createAccount_confirmEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_createAccount_confirmEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}
- (void) prepareUIElemsForLoginPage
{
    m_login_userNameTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_login_userNameTextField.backgroundColor = [UIColor clearColor];
    m_login_userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_login_userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_login_userNameTextField.returnKeyType = UIReturnKeyDone;
    m_login_userNameTextField.delegate = self;
    m_login_userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_login_userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    m_login_passwordTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_login_passwordTextField.backgroundColor = [UIColor clearColor];
    m_login_passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_login_passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_login_passwordTextField.secureTextEntry = YES;
    m_login_passwordTextField.returnKeyType = UIReturnKeyDone;
    m_login_passwordTextField.delegate = self;
    m_login_passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}
- (void) prepareUIElemsForShowLPCInfoPage
{
    m_switcher = [[UISwitch alloc] init];
    [m_switcher addTarget:self action:@selector(switcherChanged) forControlEvents:UIControlEventValueChanged];
}

#ifdef __GENIE_IPHONE__
- (void) adjustCreateAccountPageWithOrientation:(UIInterfaceOrientation)orientation//解决在createAccount页面，由于textField较多，键盘会挡住输入框的问题
{
    CGFloat createPageOffsetUpForKeyboardShowed = 0;//Y轴向上偏移量
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        if (  [m_createAccount_confirmPasswordTextField isFirstResponder]
            ||[m_createAccount_emailTextField isFirstResponder]
            ||[m_createAccount_confirmEmailTextField isFirstResponder])
        {
            createPageOffsetUpForKeyboardShowed = -44;
        }
        else
        {
            createPageOffsetUpForKeyboardShowed = 0;
        }
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if ([m_createAccount_passwordTextField isFirstResponder])
        {
            createPageOffsetUpForKeyboardShowed = -30;
        }
        else if ([m_createAccount_confirmPasswordTextField isFirstResponder])
        {
            createPageOffsetUpForKeyboardShowed = -30*2;
        }
        else if ([m_createAccount_emailTextField isFirstResponder])
        {
            createPageOffsetUpForKeyboardShowed = -(44*5/2);
        }
        else if ([m_createAccount_confirmEmailTextField isFirstResponder])
        {
            createPageOffsetUpForKeyboardShowed = -44*3;
        }
        else
        {
            createPageOffsetUpForKeyboardShowed = 0;
        }
    }
    [UIView animateWithDuration:0.2 animations:^
     {
        m_tableview.center = CGPointMake(m_tableview.frame.size.width/2, m_tableview.frame.size.height/2+createPageOffsetUpForKeyboardShowed);
     }];
}
#endif
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        m_tableview.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenWidth, iOSDeviceScreenHeight-iOSStatusBarHeight-Navi_Bar_Height_Portrait);
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        m_tableview.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenHeight, iOSDeviceScreenWidth-iOSStatusBarHeight-Navi_Bar_Height_Landscape);
    }
    [self layoutViewWithCurrentPageMode];
#ifdef __GENIE_IPHONE__
    [self adjustCreateAccountPageWithOrientation:orientation];
#endif
}
- (void) prepareDataSourceForTableView
{
    if (m_pageMode == LPCPageForLogin)
    {
        if (!m_login_passwordTextField)
        {
            [self prepareUIElemsForLoginPage];
        }
        m_login_userNameTextField.text = [GenieHelper getLPCData].openDNSAccount;
        [m_login_userNameTextField becomeFirstResponder];
    }
    else if (m_pageMode == LPCPageForCreateOpenDNSAccount)
    {
        if (!m_createAccount_confirmEmailTextField)
        {
            [self prepareUIElemsForCreateAccountPage];
        }
        [m_createAccount_userNameTextField becomeFirstResponder];
    }
    else if (m_pageMode == LPCPageForShowInformation)
    {
        if (!m_switcher)
        {
            [self prepareUIElemsForShowLPCInfoPage];
        }
    }
}
- (void) layoutViewWithCurrentPageMode
{
    switch (m_pageMode)
    {
        case LPCPageForShowInformation:
        {
            self.title = Localization_Lpc_FirstPage_ShowInfo_Title;
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                        target:self 
                                                                                        action:@selector(rightButtonPress)];
            self.navigationItem.rightBarButtonItem = rightButton;
            rightButton.enabled = YES;
            [rightButton release];
        }
            break;
            
        case LPCPageForCreateOpenDNSAccount:
        {
            self.title = Localization_Lpc_FirstPage_CreateAccount_Title;
            UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:Localization_Lpc_CreateAccount_Btn_Title 
                                                                             style:UIBarButtonItemStyleBordered 
                                                                            target:self
                                                                            action:@selector(rightButtonPress)];
            self.navigationItem.rightBarButtonItem = rightButton;
            rightButton.enabled = NO;
            [rightButton release];
        }
            break;
            
        case LPCPageForLogin:
        {
            self.title = Localization_Lpc_FirstPage_Login_Title; 
            UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:Localization_Lpc_Login_Btn_Title 
                                                                             style:UIBarButtonItemStyleBordered 
                                                                            target:self
                                                                            action:@selector(rightButtonPress)];
            self.navigationItem.rightBarButtonItem = rightButton;
            rightButton.enabled = NO;
            [rightButton release];
        }
            break;
            
        case LPCPageForNone:
        {
            self.title = Localization_Lpc_FirstPage_ShowInfo_Title;
            self.navigationItem.rightBarButtonItem = nil;
        }
            break;
            
        default:
            break;
    }
    [self prepareDataSourceForTableView];
}
- (void) replaceCurrentPageWithPage:(LPCPageMode)pageMode
{
    m_pageMode = pageMode;
    [self layoutViewWithCurrentPageMode];
    [m_tableview reloadData];
}
#pragma mark tableView callback
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (m_pageMode == LPCPageForShowInformation)
    {
        if([GenieHelper getLPCData].enable == GenieFunctionEnabled)
        {
            return 4;
        }
        else
        {
            return 1;
        }
    }
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(m_pageMode == LPCPageForCreateOpenDNSAccount)
	{
        return 5;
	}
	else if(m_pageMode == LPCPageForLogin)
	{
		return 2;
	}
	else if (m_pageMode == LPCPageForShowInformation)
    {
        if (section == 1)//显示LPC信息的第二个section
        {
            return 2;
        }
        
        if (section == 3 && [GenieHelper isSmartNetwork])//smart network not support bypass
        {
            return 0;
        }
        
        return 1;
    }
	return 0;
}

- (NSString*) parseLPCBundle:(NSString*)bundel
{
    if ([bundel isEqualToString:Genie_LPC_Bundle_High])
    {
        return Localization_Lpc_FilterLevel_High_Title;
    }
    else if ([bundel isEqualToString:Genie_LPC_Bundle_Moderate])
    {
        return Localization_Lpc_FilterLevel_Moderate_Title;
    }
    else if ([bundel isEqualToString:Genie_LPC_Bundle_Low])
    {
        return Localization_Lpc_FilterLevel_Low_Title;
    }
    else if ([bundel isEqualToString:Genie_LPC_Bundle_Minimal])
    {
        return Localization_Lpc_FilterLevel_Minimal_Title;
    }
    else if ([bundel isEqualToString:Genie_LPC_Bundle_None])
    {
        return Localization_Lpc_FilterLevel_None_Title;
    }
    else
    {
        return Localization_Lpc_FilterLevel_Custom_Title;
    }
}
- (void) customShowInfoPageCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSString * keyString = nil;
    switch (section)
    {
        case 0:
            keyString = Localization_Lpc_ShowInfoPage_Switcher_Title;
            if ([GenieHelper getLPCData].enable == GenieFunctionEnabled)
            {
                m_switcher.on = YES;
            }
            else
            {
                m_switcher.on = NO;
            }
            cell.accessoryView = m_switcher;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
        {
            if (row == 0)//filter level
            {
                keyString = Localization_Lpc_ShowInfoPage_FilterLevel_Title;
                cell.detailTextLabel.text = [self parseLPCBundle:[GenieHelper getLPCData].bundle];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            }
            else if (row == 1)//custom settings
            {
                keyString = Localization_Lpc_ShowInfoPage_CustomSetting_Title;
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;            
        }
            break;
        case 2:
        {
            keyString = Localization_Lpc_ShowInfoPage_OpenDNSAccount_Title;
            NSString * account = [GenieHelper getLPCData].openDNSAccount;
            if (![account length])
            {
                account = Genie_N_A;
            }
            cell.detailTextLabel.text = account;
            cell.selectionStyle = UITableViewCellEditingStyleNone;
        }
            break;
        case 3:
        {
            keyString = Localization_Lpc_ShowInfoPage_BypassAccount_Title;
            
            NSString * valueStr = [GenieHelper getLPCData].currentChildAccount;
            if (!valueStr)
            {
                valueStr = @"";
            }
            cell.detailTextLabel.text = valueStr;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
            break;
        default:
            break;
    }
    cell.textLabel.text = keyString;
}
- (void) customLoginPageCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    if (indexPath.row == 0)//user name
    {
        cell.textLabel.text = Localization_Lpc_LoginPage_Username_Title;
        cell.accessoryView = m_login_userNameTextField;
    }
    else
    {
        cell.textLabel.text = Localization_Lpc_LoginPage_Password_Title;
        cell.accessoryView = m_login_passwordTextField;
    }
}

- (void) customCreateAccountPageCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    NSString * keyString = nil;
    UIView * accessView = nil;
    switch (indexPath.row)
    {
        case 0:
            keyString = Localization_Lpc_CreantAccountPage_UserName_Title;
            accessView = m_createAccount_userNameTextField;
            break;
        case 1:
            keyString = Localization_Lpc_CreantAccountPage_Password_Title;
            accessView = m_createAccount_passwordTextField;
            break;
        case 2:
            keyString = Localization_Lpc_CreantAccountPage_Password2_Title;
            accessView = m_createAccount_confirmPasswordTextField;
            break;
        case 3:
            keyString = Localization_Lpc_CreantAccountPage_Email_Title;
            accessView = m_createAccount_emailTextField;
            break;
        case 4:
            keyString = Localization_Lpc_CreateAccountPage_Email2_Title;
            accessView = m_createAccount_confirmEmailTextField;
            break;
        default:
            break;
    }
#ifdef __GENIE_IPHONE__
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
#endif
    cell.textLabel.text = keyString;
    cell.accessoryView = accessView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellid = [NSString stringWithFormat:@"cell%d%d%d",m_pageMode,indexPath.row,indexPath.section];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
    }
    if (m_pageMode == LPCPageForLogin)
    {
        [self customLoginPageCell:cell atIndexPath:indexPath];
    }
    else if (m_pageMode == LPCPageForShowInformation)
    {
        [self customShowInfoPageCell:cell atIndexPath:indexPath];
    }
    else if (m_pageMode == LPCPageForCreateOpenDNSAccount)
    {
        [self customCreateAccountPageCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void) getAccountRelay_Token
{ 
    //just openDNS process  不需要设置SOAP的包裹状态
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetLPCAccountRelay:[GenieHelper getLPCData].token];
    [GPWaitDialog show:op withTarget:self selector:@selector(getAccountRelay_Token_Callback:) waitMessage:Local_WaitForGetLPCAccountRelay timeout:Genie_Get_LPC_AccountRelay_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            GenieLPCFilterLevelList * filterList = [[GenieLPCFilterLevelList alloc] init];
            [self.navigationController pushViewController:filterList animated:YES];
            [filterList release];
        }
        else
        {
            [self getAccountRelay_Token];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if (indexPath.section == 3)//bypass account
    {
        NSString * account = [GenieHelper getLPCData].currentChildAccount;
        if (account)//进入LOGOUT页面
        {
            GenieLPCChildAccount * accountPage = [[GenieLPCChildAccount alloc] initWithChilidAccount:account];
            [accountPage setBypassAccountLogoutSuccessed:self selector:@selector(bypassAccountLogout_callback)];
            [self.navigationController pushViewController:accountPage animated:YES];
            [accountPage release];
        }
        else
        {
            [GenieHelper configForSetProcessOrLPCProcessStart];
            GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetLPCByPassAccoutInfo:[GenieHelper getLPCData].deviceID mac:[[GenieHelper getLocalMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@""]];
            [GPWaitDialog show:op withTarget:self selector:@selector(getLPCByPassAccoutInfo_callback:) waitMessage:Local_Wait timeout:Genie_NoTimeOut cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
        }
    
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self getAccountRelay_Token];
}
#pragma mark textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void) textFieldTextDidChange :(NSNotification*)notify
{
    BOOL allTextFieldsTextAreAvailable = NO;
    if (m_pageMode == LPCPageForLogin)
    {
        if ([m_login_userNameTextField.text length] && [m_login_passwordTextField.text length])
        {
            allTextFieldsTextAreAvailable = YES;
        }
    }
    else if (m_pageMode == LPCPageForCreateOpenDNSAccount)
    {
        if (   [m_createAccount_userNameTextField.text length]
            && [m_createAccount_passwordTextField.text length]
            && [m_createAccount_confirmPasswordTextField.text length]
            && [m_createAccount_emailTextField.text length]
            && [m_createAccount_confirmEmailTextField.text length])
        {
            allTextFieldsTextAreAvailable = YES;
        }
    }
    self.navigationItem.rightBarButtonItem.enabled = allTextFieldsTextAreAvailable;
}

- (void) textFieldDidBeginEditing:(UITextField*)textField
{
#ifdef __GENIE_IPHONE__
    [self adjustCreateAccountPageWithOrientation:self.interfaceOrientation];
#endif
}

- (void) getLpcInfoWithWaitMsg:(NSString*)msg callback:(SEL)selector
{
    [GenieHelper configForSetProcessOrLPCProcessStart];//
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startQueryLpcInfo:[GenieHelper getCurrentRouterAdmin] 
                                                                routerPassword:[GenieHelper getCurrentRouterPassword] 
                                                                openDNSAccount:[GenieHelper getLPCData].openDNSAccount 
                                                               openDNSPassword:[GenieHelper getLPCData].openDNSPassword 
                                                                     deviceKey:[NSString stringWithFormat:@"%@-%@",[GenieHelper getRouterInfo].modelName,[GenieHelper getRouterInfo].mac]];
    [GPWaitDialog show:op withTarget:self selector:selector waitMessage:msg timeout:Genie_Get_LPC_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

//openDNS errCode:3006; Usernames must start and end with a letter or number and can also contain '.', '-' and '_'.
- (BOOL) checkUserName:(NSString*)userName{
    if (![userName length])
    {
        return NO;
    }
    NSString * format = @"(^[a-z0-9][a-z0-9\\.\\-\\_]*[a-z0-9]$)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format];
    return [pred evaluateWithObject:userName];
}
- (BOOL) checkEmailString:(NSString*)email//openDNS errCode:3004; Invalid email address.  openDNS Server对邮箱检测不严格 只要是形如这样的格式就可以 a@a.c
{
    if (![email length])
    {
        return NO;
    }
    NSString * format = @"(^\\p{Alpha}\\w{2,15}[@][a-z0-9]{3,}[.]\\p{Lower}{2,}$)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format];
    return [pred evaluateWithObject:email];
}
- (BOOL) checkPasswordString:(NSString*)password//Invalid password length[6-20]
{
    return ([password length]<6 || [password length]>20) ? NO : YES;
}
- (BOOL) easilyCheckForCreateAccountOption
{
    m_inputError = LPCInput_NoError;
    if (![self checkUserName:m_createAccount_userNameTextField.text])//用户名合法性
    { 
        m_inputError = LPCInput_CreateAccount_UserNameFormat_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountUserNameFormatIllegal];
    }
    else if (![self checkPasswordString:m_createAccount_passwordTextField.text])
    {
        m_inputError = LPCInput_CreateAccount_PasswordLength_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountPasswordLengthIllegal];
    }
    else if (![m_createAccount_passwordTextField.text isEqualToString:m_createAccount_confirmPasswordTextField.text])
    {
        m_inputError = LPCInput_CreateAccount_ConformPassword_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountConfirmPasswordIllegal];
    }
    else if (![self checkEmailString:m_createAccount_emailTextField.text])//email地址有效性
    {
        m_inputError = LPCInput_CreateAccount_EmailFormat_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountEmailFormatIllegal];
    }
    else if (![m_createAccount_emailTextField.text isEqualToString:m_createAccount_confirmEmailTextField.text])
    {
        m_inputError = LPCInput_CreateAccount_ConformEmail_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountConfirmEmailIllegal];
    }
    if (m_inputError != LPCInput_NoError)
    {
        return NO;
    }
    return YES;
}
- (void) doRightBtnTouchedUpInsideFunction
{
    if (m_pageMode == LPCPageForLogin)
    {
        [GenieHelper getLPCData].openDNSAccount = m_login_userNameTextField.text;//记忆上一次输入的账号信息
        [GenieHelper getLPCData].openDNSPassword = m_login_passwordTextField.text;
        [self getLpcInfoWithWaitMsg:Local_WaitForSignInOpenDNS callback:@selector(LoginLpc_Callback:)];
    }
    else if (m_pageMode == LPCPageForCreateOpenDNSAccount)
    {
        if ([self easilyCheckForCreateAccountOption])
        {
            GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startCreateOpenDNSUserName:m_createAccount_userNameTextField.text password:m_createAccount_passwordTextField.text email:m_createAccount_emailTextField.text];
            [GPWaitDialog show:op withTarget:self selector:@selector(createAccount_Callback:) waitMessage:Local_WaitForCreateOpenDNSAccount timeout:Genie_Create_OpenDNSAccount_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
        }
    }
    else if (m_pageMode == LPCPageForShowInformation)
    {
        [self getLpcInfoWithWaitMsg:Local_WaitForRefreshLPCInfo callback:@selector(refreshLpcInfo_Callback:)];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.navigationItem.rightBarButtonItem.enabled)
    {
        [self doRightBtnTouchedUpInsideFunction];
    }
    [textField resignFirstResponder];
#ifdef __GENIE_IPHONE__
    [self adjustCreateAccountPageWithOrientation:self.interfaceOrientation];
#endif
	return YES;
}
#pragma mark  control event action
- (void) callbackKeyBoard
{
    if (m_pageMode == LPCPageForCreateOpenDNSAccount)
    {
        [m_createAccount_userNameTextField resignFirstResponder];
        [m_createAccount_passwordTextField resignFirstResponder];
        [m_createAccount_confirmPasswordTextField resignFirstResponder];
        [m_createAccount_emailTextField resignFirstResponder];
        [m_createAccount_confirmEmailTextField resignFirstResponder];
#ifdef __GENIE_IPHONE__
        [self adjustCreateAccountPageWithOrientation:self.interfaceOrientation];
#endif
    }
    else if (m_pageMode == LPCPageForLogin)
    {
        [m_login_userNameTextField resignFirstResponder];
        [m_login_passwordTextField resignFirstResponder];
    }
}
- (void) backgroundTouchUpInside
{
    [self callbackKeyBoard];
}

- (void) rightButtonPress
{
    [self callbackKeyBoard];
    [self doRightBtnTouchedUpInsideFunction];
}
- (void) switcherChanged
{
    [GenieHelper configForSetProcessOrLPCProcessStart];
    GTAsyncOp * op = nil;
    if (m_switcher.on)
    {
        op = [[GenieHelper shareGenieBusinessHelper] startOpenParentalControlsWithRouterAdmin:[GenieHelper getCurrentRouterAdmin] password:[GenieHelper getCurrentRouterPassword] token:[GenieHelper getLPCData].token deviceID:[GenieHelper getLPCData].deviceID];
    }
    else
    {
        op = [[GenieHelper shareGenieBusinessHelper] startCloseParentalControlsWithRouterAdmin:[GenieHelper getCurrentRouterAdmin] password:[GenieHelper getCurrentRouterPassword]];
    }
    [GPWaitDialog show:op withTarget:self selector:@selector(setLPCEnableSattus_Callback:) waitMessage:Local_WaitForSetLPCEnableStatus timeout:Genie_Set_LPC_Enable_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}
#pragma mark ----
#pragma mark alertView
#define AlertView_UserOptionPrompt_Tag                                      1011
#define AlertView_InputErrorPrompt_Tag                                      1012
#define AlertView_NoBypassAccount_Tag                                       1013

static NSString * lpc_main_page = @"http://netgear.opendns.com";
- (void) showSpecialAlertViewForUserOptionPrompt
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Local_MsgForAskUserIfHaveOpenDnsAccount delegate:self cancelButtonTitle:Localization_Lpc_HaveOpenDNSAccount_NO_Title otherButtonTitles:Localization_Lpc_HaveOpenDNSAccount_YES_Title,nil];
    alert.tag = AlertView_UserOptionPrompt_Tag;
    [alert show];
    [alert release];
}
- (void) showSpecialAlertViewForInputErrorWithMsg:(NSString*)msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:Localization_Close otherButtonTitles:nil];
    alert.tag = AlertView_InputErrorPrompt_Tag;
    [alert show];
    [alert release];
}

- (void) showSpecialAlertViewForNoBypassAccount
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil 
                                                     message:@"Please login your Live Parental Controls account and add a bypass account." 
                                                    delegate:self 
                                           cancelButtonTitle:Localization_Cancel 
                                           otherButtonTitles:Localization_Ok,nil];
    alert.tag = AlertView_NoBypassAccount_Tag;
    [alert show];
    [alert release];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertView_UserOptionPrompt_Tag)
    {
        if (buttonIndex == 0)//select "NO" btn
        {
            [self replaceCurrentPageWithPage:LPCPageForCreateOpenDNSAccount];
        }
        else
        {
            [self replaceCurrentPageWithPage:LPCPageForLogin];
        }
    }
    else if (alertView.tag == AlertView_InputErrorPrompt_Tag)
    {
        if (m_pageMode == LPCPageForCreateOpenDNSAccount)
        {
            switch ((int)m_inputError)
            {
                case LPCInput_CreateAccount_UserNameCheckUnavailable_Error:
                case LPCInput_CreateAccount_UserNameFormat_Error:
                case LPCInput_CreateAccount_Unkonwn_Error:
                    [m_createAccount_userNameTextField becomeFirstResponder];
                    break;
                case LPCInput_CreateAccount_PasswordLength_Error:
                    [m_createAccount_passwordTextField becomeFirstResponder];
                    break;
                case LPCInput_CreateAccount_ConformPassword_Error:
                    [m_createAccount_confirmPasswordTextField becomeFirstResponder];
                    break;
                case LPCInput_CreateAccount_EmailFormat_Error:
                case LPCInput_CreateAccount_EmailIsUnavailable_Error:
                    [m_createAccount_emailTextField becomeFirstResponder];
                    break;
                case LPCInput_CreateAccount_ConformEmail_Error:
                    [m_createAccount_confirmEmailTextField becomeFirstResponder];
                    break;
                //
                case LPCInput_LoginOpenDNS_account_key_NoMatch_Error:
                case LPCInput_LoginOpenDNS_account_device_NoMatch_Error:
                    [m_login_userNameTextField becomeFirstResponder];
                    break;
                default:
                    break;
            }
        }
    }
    else if (alertView.tag == AlertView_NoBypassAccount_Tag)
    {
        if (buttonIndex)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lpc_main_page]];
        }
    }
}
#pragma mark ---------XML-----------Prental Controls  label
static NSString * LPC_NewDeviceID = @"NewDeviceID";
static NSString * LPC_varDeviceID = @"varDeviceID";
static NSString * LPC_ParentalControl = @"ParentalControl";
static NSString * LPC_varToken = @"varToken";
static NSString * LPC_varRelayToken = @"varRelayToken";
static NSString * LPC_varBundle = @"varBundle";
static NSString * LPC_varApiKey = @"varApiKey";
static NSString * LPC_varBaseUrl = @"varBaseUrl";
static NSString * LPC_varErrorCode = @"varErrorCode";

#pragma mark business process callback
- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"LPCInformation",dic);
    GenieLPCData * data = [GenieHelper getLPCData];
    if ([[dic objectForKey:LPC_ParentalControl] isEqualToString:@"1"])
    {
        data.enable = GenieFunctionEnabled;
    }
    else
    {
        data.enable = GenieFunctionNotEnbaled;
    }
    if (data.enable == GenieFunctionEnabled)
    {
        data.bundle = [dic valueForKey:LPC_varBundle];
    }
    else
    {
        data.bundle = nil;
    }
    if ([[dic allKeys] containsObject:LPC_varDeviceID])//若出现varDeviceID标签，则说明重新生成过deviceID
    {
        data.deviceID = [dic valueForKey:LPC_varDeviceID];
    }
    else
    {
        data.deviceID = [dic valueForKey:LPC_NewDeviceID];
    }
    data.token = [dic valueForKey:LPC_varToken];
}
- (void) autoLoginLPC_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];//
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self replaceCurrentPageWithPage:LPCPageForShowInformation];
        [self saveLPCConfigInfo];
    }
    else if (err == GenieError_LPC_NoInternet)
    {
        [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForOpenDNSHostIsNotAvailable];
    }
    else if (err == GenieError_LPC_AutoLogin_Failed)
    {
        [self showSpecialAlertViewForUserOptionPrompt];
    }
    else
    {
        [GenieHelper generalProcessGenieError:err];
    }
}

- (void) smartNetworkAutoLoginLPC_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];//
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self replaceCurrentPageWithPage:LPCPageForShowInformation];
        [self saveLPCConfigInfo];
    }
    else if (err == GenieErrorAsyncOpCancel)
    {
        [GenieHelper generalProcessGenieError:err];
    }
    else
    {
        [self showSpecialAlertViewForUserOptionPrompt];
    }
}

- (void) pingOpenDNSHost_Callback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self showSpecialAlertViewForUserOptionPrompt];
    }
    else if (err == GenieError_LPC_NoInternet)
    {
        [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForOpenDNSHostIsNotAvailable];
    }
    else
    {
        [GenieHelper generalProcessGenieError:err];
    }
}
- (void) LoginLpc_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];//
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self replaceCurrentPageWithPage:LPCPageForShowInformation];
        [self saveLPCConfigInfo];
    }
    else if (err == GenieError_LPC_UnavailableAccount)//device is not mine
    {
        m_inputError = LPCInput_LoginOpenDNS_account_device_NoMatch_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCSignInOpenDNSDeviceIsNotMine];
    }
    else if (err == GenieError_LPC_SignInOpenDNS_PassKey_Wrong)
    {
        m_inputError = LPCInput_LoginOpenDNS_account_key_NoMatch_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCSignInOpenDNSPassKeyWrong];
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

- (void) refreshLpcInfo_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];//
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [m_tableview reloadData];
    }
}

- (void) setLPCEnableSattus_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        GenieLPCData * data = [GenieHelper getLPCData];

        if (m_switcher.on)
        {
            data.enable = GenieFunctionEnabled;
            data.bundle = [[(GTAsyncOp*)obj.userInfo result] valueForKey:LPC_varBundle];
        }
        else
        {
            data.enable = GenieFunctionNotEnbaled;
        }
        
        [m_tableview reloadData];
    }
    else
    {
        m_switcher.on = !m_switcher.on;
    }
}

- (void) getAccountRelay_Token_Callback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    GenieLPCData * data = [GenieHelper getLPCData];
    if (err == GenieErrorAsyncOpCancel)//用户取消
    {
        return;
    }
    data.relay_token = nil;//不缓存relay_token
    NSDictionary * dic = [(GTAsyncOp*)obj.userInfo result];
    NSString * baseUrl = @"http://netgear.opendns.com/sign_in.php";
    NSString * url = nil;
    if (err == GenieErrorNoError)
    {
        data.relay_token = [dic valueForKey:LPC_varRelayToken];
        baseUrl = [dic valueForKey:LPC_varBaseUrl];
    }
    if (data.relay_token)
    {
        url = [NSString stringWithFormat:@"%@?device_id=%@&api_key=%@&relay_token=%@",baseUrl,data.deviceID,[dic valueForKey:LPC_varApiKey],data.token];
    }
    else
    {
        url = baseUrl;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) createAccount_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorAsyncOpCancel)//用户取消
    {
        return;
    }
    if (err == GenieErrorNoError)
    {
        [GenieHelper getLPCData].openDNSAccount = m_createAccount_userNameTextField.text;
        [self replaceCurrentPageWithPage:LPCPageForLogin];
        [GenieHelper showMsgBoxWithMsg:Local_MsgForLPCCreateAccountSuccessed];
    }
    else if (err == GenieError_LPC_CheckUserName_NO)
    {
        m_inputError = LPCInput_CreateAccount_UserNameCheckUnavailable_Error;
        [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCheckUserNameNotAvailable];
    }
    else
    {
        int err = [[[(GTAsyncOp*)obj.userInfo result] valueForKey:LPC_varErrorCode] intValue];
        if (err == 3004)//Invalid email address.  格式错误
        {
            m_inputError = LPCInput_CreateAccount_EmailFormat_Error;
            [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountEmailFormatIllegal];
        }
        if (err == 3005)//Email exists
        {
            m_inputError = LPCInput_CreateAccount_EmailIsUnavailable_Error;
            [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountEmailIsUnavailable];
        }
        else if (err == 3006)//Usernames must start and end with a letter or number and can also contain '.', '-' and '_'.
        {
            m_inputError = LPCInput_CreateAccount_UserNameFormat_Error;
            [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountUserNameFormatIllegal]; 
        }
        else if (err == 3007)//Invalid password length[6-20]
        {
            m_inputError = LPCInput_CreateAccount_PasswordLength_Error;
            [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountPasswordLengthIllegal];
        }
        else 
        {
            m_inputError = LPCInput_CreateAccount_Unkonwn_Error;
            [self showSpecialAlertViewForInputErrorWithMsg:Local_MsgForLPCCreateAccountFailed];
        }
    }
}

#pragma mark bypass account
- (void) showLPCChildListWithList:(NSArray*) childList
{
    if (![childList count])
    {
        [self showSpecialAlertViewForNoBypassAccount];
    }
    else
    {
        GeniePrint(@"lpcchild:", childList);
        GenieLPCChildList * list = [[GenieLPCChildList alloc] initWithChildList:childList];
        [list setBypassAccountLoginSuccessed:self selector:@selector(bypassAccountLogin_callback:)];
        [self.navigationController pushViewController:list animated:YES];
        [list release];
    }
}
static NSString * LPC_varList = @"varList";//子账号列表 bypass account list
static NSString * LPC_varUserName = @"varUserName";//绑定当前设备的bypass account
- (void) getLPCByPassAccoutInfo_callback:(GenieCallbackObj*) obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];//
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        NSDictionary * dic = [(GTAsyncOp*)obj.userInfo result];
        NSArray * childList = [dic objectForKey:LPC_varList];
        NSString * bindingUserName = [dic objectForKey:LPC_varUserName];
        if (bindingUserName)
        {
            [GenieHelper getLPCData].currentChildAccount = bindingUserName;
            [m_tableview reloadData];
        }
        else if (childList)
        {
            [self showLPCChildListWithList:childList];
        }
    }
    else if (err != GenieErrorAsyncOpCancel)
    {
        [GenieHelper showMsgBoxWithMsg:Local_MsgForTimeout];
    }
}

- (void) bypassAccountLogin_callback:(NSString*) accountName
{
    [GenieHelper getLPCData].currentChildAccount = accountName;
}

- (void) bypassAccountLogout_callback
{
    [GenieHelper getLPCData].currentChildAccount = nil;
}
@end
