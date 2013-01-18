//
//  GenieUtilityController.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-5-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieUtilityController.h"
#import "GenieHelper.h"
#import "Reachability.h"


@implementation GenieUtilityController

static NSString * GRouter_Model = @"model";
static NSString * GRouter_Serial = @"serial";
static NSString * GRouter_Id = @"id";

- (id) init
{
    self = [super init];
    if (self) 
    {
        m_view = nil;
        m_naviBar = nil;
        m_tableview = nil;
        m_smartnetwork_switcher = nil;
        m_remember_me_switcher = nil;
        m_snUsernameField = nil;
        m_snPasswordField = nil;
        m_loginPanel = nil;
        m_data = [[NSMutableArray alloc] init];
        m_selectedRouterSerial = [[self readDefaultSelectedRouterSerialInfo] retain];
    }
    return self;
}

- (void)dealloc
{
    [m_selectedRouterSerial release];
    [m_data release];
    [m_smartnetwork_switcher release];
    [m_remember_me_switcher release];
    [m_loginPanel release];
    [m_snPasswordField release];
    [m_snUsernameField release];
    [m_tableview release];
    [m_naviBar release];
    [m_view  release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIView * v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = v;
    [v release];
    m_view = [[UIView alloc] init];
    m_view.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:m_view];
}

- (void) initInputField
{
    m_snUsernameField = [[UITextField alloc] init];
    m_snUsernameField.delegate = self;
    m_snUsernameField.borderStyle = UITextBorderStyleRoundedRect;
    m_snUsernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_snUsernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_snUsernameField.returnKeyType = UIReturnKeyDone;
    m_snUsernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_snUsernameField.keyboardType = UIKeyboardTypeEmailAddress;
    
    m_snPasswordField = [[UITextField alloc] init];
    m_snPasswordField.delegate = self;
	m_snPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    m_snPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	m_snPasswordField.secureTextEntry=YES;
    m_snPasswordField.clearButtonMode=UITextFieldViewModeWhileEditing;
    m_snPasswordField.returnKeyType = UIReturnKeyDone;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_naviBar = [[UINavigationBar alloc] init];
    m_naviBar.barStyle = UIBarStyleBlack;
    UINavigationItem * naviItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    UIBarButtonItem * leftBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPress)]; 
    naviItem.leftBarButtonItem = leftBtnItem;
    [leftBtnItem release];
    [m_naviBar pushNavigationItem:naviItem animated:NO];
    [naviItem release];
    [m_view addSubview:m_naviBar];
    
    m_tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    m_tableview.delegate = self;
    m_tableview.dataSource = self;
#ifndef __GENIE_IPHONE__
    UIView * tableBgView = [[UIView alloc] init];
    m_tableview.backgroundView = tableBgView;
    [tableBgView release];
    m_tableview.backgroundColor = BACKGROUNDCOLOR;
#endif
    [m_view addSubview:m_tableview];
    
    m_smartnetwork_switcher = [[UISwitch alloc] init];
    m_smartnetwork_switcher.on = NO;
    [m_smartnetwork_switcher addTarget:self action:@selector(openSmartnetwork_switcherValueChanged) forControlEvents:UIControlEventValueChanged];
    
    m_remember_me_switcher = [[UISwitch alloc] init];
    m_remember_me_switcher.on = [GenieHelper getSmartNetworkRememberMeFlag];
    [m_remember_me_switcher addTarget:self action:@selector(remember_me_switcherValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOritation:self.interfaceOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showViewWithOritation:toInterfaceOrientation];
}
#pragma mark --view
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation
{
    CGFloat naviBarHight = 0;
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        m_view.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenWidth, iOSDeviceScreenHeight-iOSStatusBarHeight);
        naviBarHight = Navi_Bar_Height_Portrait;
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        m_view.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenHeight, iOSDeviceScreenWidth-iOSStatusBarHeight);
        naviBarHight = Navi_Bar_Height_Landscape;
    }
    m_naviBar.frame = CGRectMake(CGZero, CGZero, m_view.frame.size.width, naviBarHight);
    m_tableview.frame = CGRectMake(CGZero, m_naviBar.frame.size.height, m_view.frame.size.width, m_view.frame.size.height - m_naviBar.frame.size.height);
}

#pragma mark ---  default selected router
static NSString * default_remoate_router = @"default_remoate_router_serial";
- (NSString *) readDefaultSelectedRouterSerialInfo
{
    return [[GenieHelper readFile:Genie_File_SN_Selected_Router_Info] objectForKey:default_remoate_router];
}

- (void) writeDefaultSelectedRouterSerialInfo:(NSString*) router_serial
{
    [GenieHelper write:[NSDictionary dictionaryWithObject:router_serial forKey:default_remoate_router] toFile:Genie_File_SN_Selected_Router_Info];
}

#pragma mark panel view
- (void) callbackKeyBoard
{
    [m_snUsernameField resignFirstResponder];
    [m_snPasswordField resignFirstResponder];
}
- (void) panelViewBgClicked
{
    [self callbackKeyBoard];
}
- (CGFloat)panelView:(GPanelView *)panelView heightForRowIndex:(NSInteger)index
{
    if (index == 3 || index == 4)
    {
        
#ifdef __GENIE_IPHONE__
        return 18;
#else
        return 28;
#endif
    }
    else
    {        
#ifdef __GENIE_IPHONE__
        return 30;
#else
        return 40;
#endif
    }
}

- (void) loginSmartNetwork
{
    //保存账号密码的动作只能在这里进行，因为，有两种方式：点击登陆框的登陆按钮 或者 软键盘的done键
    if ([GenieHelper getSmartNetworkRememberMeFlag])
    {
        [GenieHelper saveSmartNetworkAccount:m_snUsernameField.text];
        [GenieHelper saveSmartNetworkPassword:m_snPasswordField.text];
    }
    
    [GenieHelper saveSmartNetworkAccount:m_snUsernameField.text];
    [[GenieHelper shareGenieBusinessHelper].soapHelper setSmartNetworkUsername:m_snUsernameField.text password:m_snPasswordField.text];
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startGetSmartNetworkList];
    [GPWaitDialog show:op withTarget:self selector:@selector(getSNRouterList_callback:) waitMessage:Local_Wait timeout:-1 cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}
- (void) panelView:(GPanelView*)panelView clickBtnWithBtnIndex:(NSInteger)index
{
    [self callbackKeyBoard];
    [m_loginPanel dismiss];
    if (index == 0)//highlight btn
    {
        [self loginSmartNetwork];
    }
    else
    {
        m_smartnetwork_switcher.on = NO;
    }
}

- (NSInteger) numberOfRowsInPanelView:(GPanelView*)panelView
{
    return 5;
}

static NSString * Hyper_URL_Forget_password = @"http://appgenie-staging.netgear.com/UserProfile/#ForgotPasswordPlace:";
static NSString * Hyper_URL_Signup = @"http://appgenie-staging.netgear.com/UserProfile/#NewUserPlace:";

- (GPanelViewCell*) panelView:(GPanelView*)panelView cellForRowAtIndex:(NSInteger)index
{
#ifdef __GENIE_IPHONE__
    CGFloat keyLabFontSize = 15;
#else
    CGFloat keyLabFontSize = 23;
#endif
    GPanelViewCell * cell = [[[GPanelViewCell alloc] init] autorelease];
    if (index == 0)
    {
        cell.keyLabel.text = @"Email";
        cell.valueView = m_snUsernameField;
    }
    else if (index == 1)
    {
        cell.keyLabel.text = @"Password";
        cell.valueView = m_snPasswordField;
    }
    else if (index == 2)
    {
        cell.keyLabel.text = @"Remember Me";
        cell.valueView = m_remember_me_switcher;
    }
    else//登陆框上  两个超链接
    {
#ifdef __GENIE_IPHONE__
        CGFloat fontsize = 10;
        CGFloat margin_top = 1;
#else
        CGFloat fontsize = 15;
        CGFloat margin_top = 2;
#endif
        NSString * cssString = nil;
        NSString * href = nil;
        if (index == 3)
        {
            cssString = [NSString stringWithFormat:@"<style>body{font-size:%.0fpx;font-family:Helvetica;color:white;text-align:left;margin-left:0px;margin-top:%.0fpx}a:link{color:#6666cc}} </style>",fontsize,margin_top];
            href = [NSString stringWithFormat:@"<a href=%@>Forgot your password?</a>", Hyper_URL_Forget_password];
        }
        else if (index == 4)
        {
            cssString = [NSString stringWithFormat:@"<style>body{font-size:%.0fpx;font-family:Helvetica;color:white;text-align:left;margin-left:0px;margin-top:%.0fpx}a:link{color:#6666cc}} </style>",fontsize,margin_top];
            href = [NSString stringWithFormat:@"Don't have an ID?<a href=%@>Sign up</a>", Hyper_URL_Signup];
        }
        cell.keyLabel.text = nil;
        cell.valueView = [self getHyperLinkViewCSS:cssString href:href delegate:self];
    }
    cell.keyLabel.font = [UIFont systemFontOfSize:keyLabFontSize];
    return cell;
}

#pragma textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == m_snPasswordField)
    {
        [m_loginPanel dismiss];
        [self loginSmartNetwork];
    }
    return YES;
}
#pragma mark tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1)
    {
        return 1;
    }
    else 
    {
        return [m_data count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cellID%d%d",indexPath.row, indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        if (indexPath.section == 0)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
        }
        else if(indexPath.section == 1)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        else
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
    }
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = @"About";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            break;
        case 1:
            cell.textLabel.text = @"Smart Network";
            cell.accessoryView = m_smartnetwork_switcher;
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            break;
        case 2:
        {
            NSDictionary * snRouter = (NSDictionary*)[m_data objectAtIndex:indexPath.row];
            cell.textLabel.text = [snRouter objectForKey:GRouter_Model];
            NSString * serial = [snRouter objectForKey:GRouter_Serial];
            cell.detailTextLabel.text = [@"S/N: " stringByAppendingString:serial];
            if ([m_selectedRouterSerial isEqualToString:serial])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void) selectRemoatRouter:(NSDictionary*) router
{
    [GenieHelper configSmartNetworkControlPointID:[router objectForKey:GRouter_Id]];
    [m_selectedRouterSerial release];
    m_selectedRouterSerial = [[router objectForKey:GRouter_Serial] retain];
    [self writeDefaultSelectedRouterSerialInfo:m_selectedRouterSerial];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self showSpecialAlertViewForShowAboutInfo];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == 2)
    {
        NSDictionary * router = [m_data objectAtIndex:indexPath.row];
        [self selectRemoatRouter:router];
        [m_tableview reloadData];
    }
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#ifdef __GENIE_IPHONE__
    return 13;
#else
    return 20;
#endif    
}
 
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 3 && [m_data count])//section for router list
    {
#ifdef __GENIE_IPHONE__
        CGFloat promptSize = 10.0f;
        CGFloat space = 10;
#else
        CGFloat promptSize = 15.0f;
        CGFloat space = 45;
#endif
        UIView * headerView = [[[UIView alloc] init] autorelease];
        NSString * promptText = @"Remote Router List";
        UIFont * promptTextFont = [UIFont systemFontOfSize: promptSize];
        CGSize textSize = [promptText sizeWithFont:promptTextFont];
        UILabel * tip = [[UILabel alloc] initWithFrame:CGRectMake(space, CGZero, textSize.width, textSize.height)];
        tip.font = promptTextFont;
        tip.text = promptText;
        tip.backgroundColor = [UIColor clearColor];
        [headerView addSubview:tip];
        [tip release];
        return headerView;
    }
    return nil;
}*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2 && [m_data count])
    {
        return @"Remote Router List";
    }
    return nil;
}

#pragma mark hyperlink
- (UIWebView*) getHyperLinkViewCSS:(NSString*)cssString href:(NSString*)hrefString delegate:(id)delegate
{
    UIWebView * webPage = [[UIWebView alloc] init];
    [webPage loadHTMLString:[cssString stringByAppendingString:hrefString] baseURL:nil];
    webPage.delegate = delegate;
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

#pragma mark -- webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![[UIApplication sharedApplication] openURL:[request URL]];
}

#pragma mark about
#define AlertView_AboutDialog_Tag                   200
#define AlertView_Login_SN_FailedPrompt_Tag         201
- (void) showSpecialAlertViewForShowAboutInfo
{
	NSMutableString* msg = [[NSMutableString alloc] init];
    
    NSString * routerModel = nil;
    routerModel = [GenieHelper getRouterInfo].modelName;
    if ([routerModel length] == 0)
    {
        routerModel = Genie_N_A;
    }
    NSString * firmwareVersion = [GenieHelper getRouterInfo].firmware;
    if ([firmwareVersion length] == 0)
    {
        firmwareVersion = Genie_N_A;
    }
    [msg setString:[NSString stringWithFormat:@"%@: %@",Localization_HP_AboutDialog_RouterModel_Title,routerModel]];
    [msg appendString:@"\n"];
    [msg appendFormat:@"%@: %@",Localization_HP_AboutDialog_FirmwareVersion_Title,firmwareVersion];
    [msg appendString:@"\n\n"];
    [msg appendFormat:@"%@ %@",Localization_HP_AboutDialog_GenieVersion_Title,[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]];
    [msg appendString:@"\n"];
    [msg appendString:Localization_HP_AboutDialog_CopyRight_Info];
    [msg appendString:@"\n"];
    [msg appendString:Localization_HP_AboutDialog_AllRight_Info];
    [msg appendString:@"\n"];
    [msg appendString:Localization_HP_AboutDialog_PoweredBy_Info];
    
    UIAlertView* aboutDialog = [[UIAlertView alloc] initWithTitle:Localization_HP_AboutDialog_Title
                                                          message:msg
                                                         delegate:self
                                                cancelButtonTitle:Localization_Close 
                                                otherButtonTitles:Localization_HP_AboutDialog_License_Title ,nil];
	aboutDialog.tag = AlertView_AboutDialog_Tag;
	[msg release];
	[aboutDialog show];
	[aboutDialog release];
	
    
}

- (void) showSpecialAlertViewForLoginSmartnetworkKeyInvalid
{
    UIAlertView * keyInvalidAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Invalid User Name or Password." delegate:self cancelButtonTitle:Localization_Ok otherButtonTitles:nil];
    keyInvalidAlertView.tag = AlertView_Login_SN_FailedPrompt_Tag;
    [keyInvalidAlertView show];
    [keyInvalidAlertView release];
}

- (void) showLicenseInfo
{
    NSString * license = @"Terms and Conditions\n\nNETGEAR Genie is distributed under license.No title to or ownership rights in NETGEAR Genie or any portion of NETGEAR Genie are transferred.The end user of NETGEAR Genie agrees not to reverse engineer, decompile, disassemble or otherwise attempt to discover the source code.\n\nWithin the NETGEAR Genie distribution\n\n";
    NSString * licenseFilePath = [[NSBundle mainBundle] pathForResource:@"neptune_license" ofType:@"rtf"];
    NSString * neptune_license = [NSString stringWithContentsOfFile:licenseFilePath encoding:NSUTF8StringEncoding error:nil];
    license = [license stringByAppendingString:neptune_license];
    //license for qrcode
    license = [license stringByAppendingString:@"\n/*\n"
               "* Copyright 2008 ZXing authors\n"
               "*\n"
               "* Licensed under the Apache License, Version 2.0 (the \"License\");\n"
               "* you may not use this file except in compliance with the License.\n"
               "* You may obtain a copy of the License at\n"
               "*\n"
               "*      http://www.apache.org/licenses/LICENSE-2.0\n"
               "*\n"
               "* Unless required by applicable law or agreed to in writing, software\n"
               "* distributed under the License is distributed on an \"AS IS\" BASIS,\n"
               "* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n"
               "* See the License for the specific language governing permissions and\n"
               "* limitations under the License.\n"
               "*/"];
    UIAlertView * licenseDig = [[UIAlertView alloc] initWithTitle:Localization_HP_AboutDialog_License_Title 
                                                          message:license 
                                                         delegate:nil 
                                                cancelButtonTitle:Localization_Close
                                                otherButtonTitles:nil];
    [licenseDig show];
    [licenseDig release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertView_AboutDialog_Tag)
    {
        if (buttonIndex == 1)
        {
            [self showLicenseInfo];
        }
    }
    else if (alertView.tag == AlertView_Login_SN_FailedPrompt_Tag)
    {
        [self showLoginPanel];
    }
}
#pragma mark btn press
- (void) doneBtnPress
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) showLoginPanel
{
    m_snUsernameField.text = @"";
    m_snPasswordField.text = @"";
    if (m_remember_me_switcher.on)
    {
        m_snUsernameField.text = [GenieHelper getSmartNetworkAccount];
        m_snPasswordField.text = [GenieHelper getSmartNetworkPassword];
    }
    [m_loginPanel show];
}

- (void) openSmartnetwork_switcherValueChanged
{
    if (m_smartnetwork_switcher.on)
    {
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        {
            [GenieHelper showMsgBoxWithMsg:Local_MsgForNoInternetDetected];
            m_smartnetwork_switcher.on = NO;
            return;
        }
        //.........................
        if (!m_loginPanel)
        {
            [self initInputField];
            m_loginPanel = [[GPanelView alloc] initWithTitle:@"Router Login" highLightBtn:Localization_Login anotherBtn:Localization_Cancel];
            m_loginPanel.delegate = self;
            m_loginPanel.dataSource = self;
            [m_loginPanel addTarget:self selector:@selector(panelViewBgClicked) forEvent:UIControlEventTouchUpInside];
        /*
            [m_loginPanel show];
        }
        else
        {
            [self loginSmartNetwork];
        }
        /*/
        }    
        [self showLoginPanel];
        //*/
    }
    else
    {
        [m_data removeAllObjects];
        [m_tableview reloadData];
        [GenieHelper resignSmartNetwork];
    }
}

- (void) remember_me_switcherValueChanged
{
    [GenieHelper setSmartNetworkRememberMeFlag:m_remember_me_switcher.on];
    
    if (!m_remember_me_switcher.on)
    {
        [GenieHelper saveSmartNetworkAccount:@""];
        [GenieHelper saveSmartNetworkPassword:@""];
    }
}
#pragma mark callback
static NSString * router_list_flag = @"list";
- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"sn router list:",dic);
    // do something parser data
    [m_data removeAllObjects];
    for (NSDictionary* router in (NSArray*)[dic objectForKey:router_list_flag])
    {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[router objectForKey:GRouter_Model] forKey:GRouter_Model];
        [dic setObject:[router objectForKey:GRouter_Serial] forKey:GRouter_Serial];
        [dic setObject:[router objectForKey:GRouter_Id] forKey:GRouter_Id];
        [m_data addObject:dic];
        [dic release];
    }
}
- (void) getSNRouterList_callback:(GenieCallbackObj*) obj
{
    //
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        if (![m_data count])
        {
            m_smartnetwork_switcher.on = NO;
            [GenieHelper showMsgBoxWithMsg:@"No Devices Found."];
        }
        else
        {
            BOOL flag = NO;//标记 获取到的远程路由器列表中 是否包含了上一次用户选择过的路由器
            
            if (m_selectedRouterSerial)
            {
                for (NSDictionary * router in m_data)
                {
                    if ([m_selectedRouterSerial isEqualToString:[router objectForKey:GRouter_Serial]])
                    {
                        flag = YES;
                        [self selectRemoatRouter:router];
                        break;
                    }
                }
            }
            
            if (!flag)
            {
                [self selectRemoatRouter:[m_data objectAtIndex:0]];
            }
            
            m_smartnetwork_switcher.on = YES;
            [m_tableview reloadData];
        }
    }
    else 
    {
        m_smartnetwork_switcher.on = NO;
        [self showSpecialAlertViewForLoginSmartnetworkKeyInvalid];
    }
}

@end
