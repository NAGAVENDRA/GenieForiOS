//
//  GenieGuestModifyController.m
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieGuestModifyController.h"
#import "GenieHelper.h"
#import "GenieHelper_TimePeriod.h"
#import "GenieItemListController.h"

#ifdef __GENIE_IPHONE__
#define TextFieldFrame CGRectMake(0,0,160,31)
#else
#define TextFieldFrame CGRectMake(0,0,320,31)
#endif

#define TextField_SSID_FontOnIphone  13
#define CellTextLable_Font_AtSectionFirstOnIphone       14
#define PasswordMaxLength               64
#define PasswordMinLength               8
#define SSIDMaxLength                   32

#define modifyTimeperiodRowIndex                        0
#define modifySecurityRowIndex                          1

@implementation GenieGuestModifyController
@synthesize isOpenGuestAccessPage = m_isOpenGuestAccessPage;

static NSString * Default_Guest_SSID = @"NETGEAR_GUEST";
- (id) init
{
    self = [super init];
    if (self)
    {
        m_tableview = nil;
        m_ssidTextField = nil;
        m_passwordTextField = nil;
        //
        m_noSecurity = NO;
        m_isInfoChanged = NO;
        m_isOpenGuestAccessPage = NO;
        
        m_secutityModeInfo = [[GenieHelper getGuestData].securityMode retain];
        m_timePeriodInfo = [[GenieHelper getGuestData].timePeriod retain];
        
        m_target_SN_set = nil;
        m_selector_SN_set = nil;
    }
    return  self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_target_SN_set release];
    [m_timePeriodInfo release];
    [m_secutityModeInfo release];
    [m_passwordTextField release];
    [m_ssidTextField release];
    [m_tableview release];
    [super dealloc];
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
    self.title = Localization_Guest_SetPage_Title;
    /////
    
    m_ssidTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_ssidTextField.text = [GenieHelper getGuestData].ssid;
    m_ssidTextField.delegate = self;
    m_ssidTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_ssidTextField.returnKeyType = UIReturnKeyDone;
    m_ssidTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_ssidTextField.backgroundColor = [UIColor clearColor];
    m_ssidTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_ssidTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
#ifdef __GENIE_IPHONE__
    m_ssidTextField.font = [UIFont systemFontOfSize:TextField_SSID_FontOnIphone];
#endif
    
    m_passwordTextField = [[UITextField alloc] initWithFrame:TextFieldFrame];
    m_passwordTextField.text = [GenieHelper getGuestData].password;
    m_passwordTextField.delegate = self;
    m_passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_passwordTextField.returnKeyType = UIReturnKeyDone;
    m_passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_passwordTextField.backgroundColor = [UIColor clearColor];
    m_passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_passwordTextField.secureTextEntry = YES;
    
    //在打开guest开关的时候，【可能】会出现取不到GUEST ACCESS数据的情况,此时设置 默认SSID为NETGEAR_GUEST 默认加密方式为 None
    if (m_isOpenGuestAccessPage)
    {
        if (![[GenieHelper getGuestData].ssid length])
        {
            m_ssidTextField.text = Default_Guest_SSID;
        }
        if ([[GenieHelper getGuestData].password length] < 8)
        {
            m_passwordTextField.text = @"";
            m_secutityModeInfo = [GenieSecurityModeStringNone retain];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * btnItem = [[UIBarButtonItem alloc] initWithTitle:Localization_Save style:UIBarButtonItemStyleBordered target:self action:@selector(saveBtnPress)];
    self.navigationItem.rightBarButtonItem = btnItem;
    [btnItem release];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([m_secutityModeInfo isEqualToString:GenieSecurityModeStringNone])
    {
        m_noSecurity = YES;
        m_passwordTextField.text = @"";
    }
    else
    {
        m_noSecurity = NO;
    }
    [self showViewWithOrientation:self.interfaceOrientation];
    ///________________________
    //当GUEST从disable状态变到enable状态时，save按钮可被点击
    //当GUEST从enbale状态变到修改状态时，如没有发生修改行为，save不可被点击
    //通过[GenieHelper getGuestData].securityMode == nil来判断GUEST从disable变到enable状态
    if (!m_isInfoChanged && !m_isOpenGuestAccessPage)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if ([m_ssidTextField.text length] == 0)
    {
        [m_ssidTextField becomeFirstResponder];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (!m_noSecurity && [m_passwordTextField.text length] < PasswordMinLength)
    {
        [m_passwordTextField becomeFirstResponder];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [m_tableview reloadData];
}

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

#pragma mark TableView delegate and data source  TextField delegate
- (void) setModifyFinished:(id)target callback:(SEL)selector
{
    [m_target_SN_set release];
    m_target_SN_set = [target retain];
    m_selector_SN_set = selector;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0  && !m_noSecurity)
    {
#ifdef __GENIE_IPHONE__
        float promptSize = 10.0f;
#else
        float promptSize = 15.0f;
#endif
        UILabel * tip = [[[UILabel alloc] init] autorelease];
        tip.font = [UIFont systemFontOfSize: promptSize];
        tip.text = Localization_Guest_Password_Length_Prompt;
        tip.textAlignment = UITextAlignmentCenter;
        tip.backgroundColor = [UIColor clearColor];
        return tip;
    }
    return nil;
}

#ifndef __GENIE_IPHONE__
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 25;
}
#endif

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.navigationItem.rightBarButtonItem.enabled)
    {
        [GenieHelper showRebootRouterPrompt:Local_MsgForSetAndRebootRouterPrompt WithDelegate:self];
    }
	[textField resignFirstResponder];
	return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //////////////////////确保可以正常删除
	if(![string length])
	{
		return YES;
	}
	///////////////////
    
    if ( textField == m_passwordTextField && [textField.text length] > PasswordMaxLength) return NO;
    if (textField == m_ssidTextField && [textField.text length] > SSIDMaxLength) return NO;
    return YES;
}


- (void) textFieldTextDidChange :(NSNotification*)notify//需要处理无密码时的情况。
{
    if (!m_noSecurity)//有密码
    {
        if ([m_ssidTextField.text length] == 0 || [m_passwordTextField.text length] < PasswordMinLength)
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    else
    {
        if ([m_ssidTextField.text length] == 0)
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    m_isInfoChanged = YES;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && m_noSecurity)
    {
        return 1;
    }
    
    if ([GenieHelper isSmartNetwork] && section == 1)
    {
        return 1;//在smart network 模式下，不支持time period功能
    }
    
    return 2;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellid = [NSString stringWithFormat:@"cell%d%d",indexPath.row,indexPath.section];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
    }
    [self customCell:cell atIndexPath:indexPath];
    return cell;
}

- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath row];
    if (indexPath.section == 0)
    {
#ifdef __GENIE_IPHONE__
        cell.textLabel.font = [UIFont boldSystemFontOfSize:CellTextLable_Font_AtSectionFirstOnIphone];
#endif
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (index == 0)
        {
            cell.textLabel.text = Localization_Guest_SSID_Title;
            cell.accessoryView = m_ssidTextField;
        }
        else
        {
            cell.textLabel.text = Localization_Guest_Password_Title;
            cell.accessoryView = m_passwordTextField;
        }
    }
    else
    {
        if (![GenieHelper isSmartNetwork] && (index == 0))//在smart network 模式下，不支持time period功能
        {
            cell.textLabel.text = Localization_Guest_TimePeriod_Title;
            cell.detailTextLabel.text = m_timePeriodInfo;
        }
        else
        {
            cell.textLabel.text = Localization_Guest_SecurityMode_Title;
            cell.detailTextLabel.text = m_secutityModeInfo;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void) showItemListForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) return;
    NSInteger row = [indexPath row];
    NSString * selectedItem = nil;
    NSString * itemListTitle = nil;
    SEL selector = nil;
    NSMutableArray * items = [[NSMutableArray alloc] init];
    if (![GenieHelper isSmartNetwork] && row == modifyTimeperiodRowIndex)//在smart network 模式下，不支持time period功能
    {
        [items addObject:Localization_Guest_Time_Period_Allways];
        [items addObject:Localization_Guest_Time_Period_OneHour];
        [items addObject:Localization_Guest_Time_Period_FiveHours];
        [items addObject:Localization_Guest_Time_Period_TenHours];
        [items addObject:Localization_Guest_Time_Period_OneDay];
        [items addObject:Localization_Guest_Time_Period_OneWeek];
        itemListTitle = Localization_Guest_TimePeriod_Title;
        selectedItem = m_timePeriodInfo;
        selector = @selector(timeperiodChanged_Callback:);
    }
    else
    {
        [items addObject:GenieSecurityModeStringNone];
        [items addObject:GenieSecurityModeStringWPA_PSK];
        [items addObject:GenieSecurityModeStringWPA_PSK_WPA2_PSK];
        itemListTitle = Localization_Guest_SecurityMode_Title;
        selectedItem = m_secutityModeInfo;
        selector = @selector(securityModeChanged_Callback:);
    }
    GenieItemListController * itemlist = [[GenieItemListController alloc] initWithItmeList:items andSelectedItem:selectedItem];
    [itemlist setModifyCallback:self callback:selector];
    itemlist.title = itemListTitle;
    [items release];
    [self.navigationController pushViewController:itemlist animated:YES];
    [itemlist release];
}

- (void) timeperiodChanged_Callback:(NSString*) timeperiod
{
    [m_timePeriodInfo release];
    m_timePeriodInfo = [timeperiod retain];
    m_isInfoChanged = YES;
}

- (void) securityModeChanged_Callback:(NSString*) securityMode
{
    [m_secutityModeInfo release];
    m_secutityModeInfo = [securityMode retain];
    m_isInfoChanged = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(backgroundTouchUpInside)];
    if([indexPath section])
    {
        [self showItemListForIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark  control event action
static NSString * Default_Key_value    =   @"0";
- (void) callbackKeyBoard
{
    [m_ssidTextField resignFirstResponder];
    [m_passwordTextField resignFirstResponder];
}
- (void) backgroundTouchUpInside
{
    [self callbackKeyBoard];
}

- (void) saveBtnPress
{
    [GenieHelper showRebootRouterPrompt:Local_MsgForSetAndRebootRouterPrompt WithDelegate:self];
}
- (void) beginSetProcess
{
    GTAsyncOp * op = nil;
    GenieFunctionEnableStatus enable = [GenieHelper getGuestData].enable;
    NSString * securityMode = GenieSecurityModeStringWPA_PSK_SET;
    if ([m_secutityModeInfo isEqualToString:GenieSecurityModeStringWPA_PSK_WPA2_PSK])
    {
        securityMode = GenieSecurityModeStringWPA_PSK_WPA2_PAK_SET;
    }
    else if ([m_secutityModeInfo isEqualToString:GenieSecurityModeStringNone])
    {
        securityMode = GenieSecurityModeStringNone;
    }
    
    [GenieHelper configForSetProcessOrLPCProcessStart];//
    if (enable == GenieFunctionEnabled)
    {
            op = [[GenieHelper shareGenieBusinessHelper] startSetGuestAccessNetworkSSID:m_ssidTextField.text securityMode:securityMode key1:m_passwordTextField.text key2:Default_Key_value key3:Default_Key_value key4:Default_Key_value];
    }
    else if (enable == GenieFunctionNotEnbaled)
    {
            op = [[GenieHelper shareGenieBusinessHelper] startOpenGuestAccessSSID:m_ssidTextField.text securityMode:securityMode key1:m_passwordTextField.text key2:Default_Key_value key3:Default_Key_value key4:Default_Key_value];
    }
    [GPWaitDialog show:op withTarget:self selector:@selector(setGuestAccessCallback:) waitMessage:Local_WaitForSetGuestInfo timeout:Genie_Set_Guest_Process_Timeout cancelBtn:nil needCountDown:YES waitTillTimeout:YES];
}
#pragma mark -----alertview delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == Genie_AlertView_Tag_RebootRouterPrompt)
    {
        if (buttonIndex == 1)
        {
            [self callbackKeyBoard];;
            [self beginSetProcess];
        }
    }
}

#pragma mark --
- (NSString*) timePeriodModeFromLocalization:(NSString*)local
{
    if ([local isEqualToString:Localization_Guest_Time_Period_OneHour])
    {
        return Genie_Guest_TimePeriod_OneHour;
    }
    else if ([local isEqualToString:Localization_Guest_Time_Period_FiveHours])
    {
        return Genie_Guest_TimePeriod_FiveHours;
    }
    else if ([local isEqualToString:Localization_Guest_Time_Period_TenHours])
    {
        return Genie_Guest_TimePeriod_TenHours;
    }
    else if ([local isEqualToString:Localization_Guest_Time_Period_OneDay])
    {
        return Genie_Guest_TimePeriod_OneDay;
    }
    else if ([local isEqualToString:Localization_Guest_Time_Period_OneWeek])
    {
        return Genie_Guest_TimePeriod_OneWeek;
    }
    else
    {
        return Genie_Guest_TimePeriod_Always;
    }
}

- (void) registTimePeriodNotification
{
    [GenieHelper saveTimePeriod:[self timePeriodModeFromLocalization:m_timePeriodInfo] routerMac:[GenieHelper getRouterInfo].mac];
}
- (void) setGuestAccessCallback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    
    if (![GenieHelper isSmartNetwork])//在smart network 模式下，不支持time period功能
    {
        [self registTimePeriodNotification];
    }
    
    if ([GenieHelper isSmartNetwork])
    {
        GenieGuestData * data = [GenieHelper getGuestData];
        data.enable = GenieFunctionEnabled;
        data.ssid = m_ssidTextField.text;
        data.timePeriod = m_timePeriodInfo;
        data.securityMode = m_secutityModeInfo;
        if (m_noSecurity)
        {
            data.password = nil;
        }
        else
        {
            data.password = m_passwordTextField.text;
        }
        if (m_target_SN_set)
        {
            [m_target_SN_set performSelector:m_selector_SN_set];
            [m_target_SN_set release];
            m_target_SN_set = nil;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [GenieHelper logoutGenie];
        [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForSetAndRebootRouterSuccessedPrompt];
    }
}

@end
