//
//  GenieGuestInfoController.m
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieGuestInfoController.h"
#import "GenieHelper.h"
#import "GenieHelper_TimePeriod.h"
#import "GenieGuestModifyController.h"
#import "GenieQRCodeTableCellView.h"


@implementation GenieGuestInfoController


- (id) init
{
    self = [super init];
    if (self)
    {
        m_tableview = nil;
        m_data = nil;
        m_switcher = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_switcher release];
    [m_data release];
    [m_tableview release];
    [[GenieHelper getGuestData] clear];
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
    UIView * v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    v.backgroundColor = BACKGROUNDCOLOR;
    self.view = v;
    [v release];
    
    m_tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
#ifndef __GENIE_IPHONE__
    UIView * tableBgView = [[UIView alloc] init];
    m_tableview.backgroundView = tableBgView;
    [tableBgView release];
    m_tableview.backgroundColor = BACKGROUNDCOLOR;
#endif    
    m_tableview.dataSource = self;
    m_tableview.delegate = self;
    [self.view addSubview:m_tableview];
    self.title = Localization_Guest_InfoPage_Title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    [rightBtnItem release];
    
    m_data = [[NSMutableArray alloc] init];
    m_switcher = [[UISwitch alloc] init];
    [m_switcher addTarget:self action:@selector(switcherChanged) forControlEvents:UIControlEventValueChanged];
    
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startGetGuestInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(loadGuestAccessInfoCallback:) waitMessage:Local_WaitForLoadGuestInfo timeout:Genie_Get_Guest_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOrientation:self.interfaceOrientation];
    [m_tableview reloadData];//打开guest access后进入设置界面，然后不保存而是直接返回，这是需要在此刷新switcher的UI
}
- (void)viewDidUnload
{
    [super viewDidUnload];
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
#pragma mark table delegate and data source
- (void) gotoModifyPageForOpenGuestAccess:(BOOL) flag
{
    GenieGuestModifyController * modifyer = [[GenieGuestModifyController alloc] init];
    modifyer.isOpenGuestAccessPage = flag;
    [modifyer setModifyFinished:self callback:@selector(modifyFinished_Callback)];
    [self.navigationController pushViewController:modifyer animated:YES];
    [modifyer release];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [self gotoModifyPageForOpenGuestAccess:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([m_data count] == 0)
    {
        return 0;
    }
    else if ([m_data count] == 1)
    {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    if (section == 1)
    {
        if ([GenieHelper isSmartNetwork])
        {
            return 2;//在smart network 模式下，不支持time period功能
        }
        return 3;
    }
    if (section == 2)
    {
        if ([m_data count] == 0)//如果第一个section没有内容，那么第二个section也不该有内容
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        if (indexPath.section == 2)//qrcode image
        {
            cell = [[[GenieQRCodeTableCellView alloc] initWithReuseIdentifier:cellID ssid:[GenieHelper getGuestData].ssid password:[GenieHelper getGuestData].password] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
            [self customCell:cell atIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    
    return cell;
}


#define STANDARD_ROW_HEITHT 44

#ifdef __GENIE_IPHONE__
#define ROW_HIGHT_QRCODE_IMG  185
#else
#define ROW_HIGHT_QRCODE_IMG  305
#endif
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) //qrcode
    {
        return ROW_HIGHT_QRCODE_IMG;
    }
    else
    {
        return STANDARD_ROW_HEITHT;
    }
}

#pragma mark -----

#ifdef __GENIE_IPHONE__
#define Height_Header           40  
#define Height_Seg_Control      32  //segmentControl放在header区域
#else
#define Height_Header           70  
#define Height_Seg_Control      38
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
}


- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString * keyString = nil;
    NSString * valueString = nil;
    NSInteger index = indexPath.row;
    NSInteger sec = indexPath.section;
    NSInteger elemsNumInFirstSection = 1;
    if (sec == 0)
    {
        keyString = Localization_Guest_Switcher_Title;
        valueString = nil;
        GenieFunctionEnableStatus s = [[m_data objectAtIndex:0] intValue];
        if (s == GenieFunctionEnabled)
        {
            m_switcher.on = YES;
        }
        else
        {
            m_switcher.on = NO;
        }
        cell.accessoryView = m_switcher;
    }
    else
    {
        switch (index)
        {
            case 0:
                keyString = Localization_Guest_SSID_Title;
                valueString = [m_data objectAtIndex:index+elemsNumInFirstSection];
                break;
            case 1:
                keyString = Localization_Guest_Password_Title;
                valueString = [m_data objectAtIndex:index+elemsNumInFirstSection];
                break;
            case 2:
            {
                keyString = Localization_Guest_TimePeriod_Title;
                valueString = [m_data objectAtIndex:index+elemsNumInFirstSection];
            }
                break;
            default:
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = keyString;
    cell.detailTextLabel.text = valueString;
    cell.selectionStyle = (sec == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
}

- (void) switcherChanged
{
    if (m_switcher.on)//open guest access
    {
        [self gotoModifyPageForOpenGuestAccess:YES];
    }
    else
    {
        [GenieHelper showRebootRouterPrompt:Local_MsgForSetAndRebootRouterPrompt WithDelegate:self];
    }
}
- (void) refresh
{
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetGuestInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(refreshGuestAccessInfoCallback:) waitMessage:Local_WaitForRefreshGuestInfo timeout:Genie_Get_Guest_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}


#pragma mark alertview delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == Genie_AlertView_Tag_RebootRouterPrompt)
    {
        if (buttonIndex == 0)
        {
            m_switcher.on = YES;//取消关闭guess access 操作
        }
        else
        {
            [GenieHelper configForSetProcessOrLPCProcessStart];
            GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startCloseGuestAccess];
            [GPWaitDialog show:op withTarget:self selector:@selector(clossGuestAccessCallback:) waitMessage:Local_WaitForSetGuestInfo timeout:Genie_Set_Guest_Process_Timeout cancelBtn:nil needCountDown:YES waitTillTimeout:YES];
        }
    }
}

#pragma mark reload GUI
//////
- (void) reloadGUI:(GenieFunctionEnableStatus) status
{
    [m_data removeAllObjects];
    GenieGuestData * data = [GenieHelper getGuestData];
    if (status == GenieFunctionNotSupport)
    {
        return;
    }
    if (status == GenieFunctionNotEnbaled)
    {
        [m_data addObject:[NSNumber numberWithInt:data.enable]];
    }
    else
    {
        [m_data addObject:[NSNumber numberWithInt:data.enable]];
        if (data.ssid)
        {
            [m_data addObject:data.ssid];
        }
        else
        {
            [m_data addObject:Genie_N_A];
        }
        if (!data.password)
        {
            [m_data addObject:@""];//密码为空时，什么都不显示
        }
        else
        {
            [m_data addObject:data.password];
        }
        if (data.timePeriod)
        {
            [m_data addObject:data.timePeriod];
        }
        else
        {
            [m_data addObject:Genie_N_A];
        }
    }
    [m_tableview reloadData];
}
#pragma mark ----Modify Traffic Callback
- (void) modifyFinished_Callback
{
    [self reloadGUI:GenieFunctionEnabled];//
}
#pragma mark Guest Access xml label
static NSString * Guest_NewGuestAccessEnabled = @"NewGuestAccessEnabled";
static NSString * Guest_NewSSID = @"NewSSID";
static NSString * Guest_NewSecurityMode = @"NewSecurityMode";
static NSString * Guest_NewKey = @"NewKey";
#pragma mark business process callback
- (NSString*) localizationStringForTimePeriodMode:(NSString*)timePeriod
{
    if ([timePeriod isEqualToString:Genie_Guest_TimePeriod_OneHour])
    {
        return Localization_Guest_Time_Period_OneHour;
    }
    else if ([timePeriod isEqualToString:Genie_Guest_TimePeriod_FiveHours])
    {
        return Localization_Guest_Time_Period_FiveHours;
    }
    else if ([timePeriod isEqualToString:Genie_Guest_TimePeriod_TenHours])
    {
        return Localization_Guest_Time_Period_TenHours;
    }
    else if ([timePeriod isEqualToString:Genie_Guest_TimePeriod_OneDay])
    {
        return Localization_Guest_Time_Period_OneDay;
    }
    else if ([timePeriod isEqualToString:Genie_Guest_TimePeriod_OneWeek])
    {
        return Localization_Guest_Time_Period_OneWeek;
    }
    else 
    {
        return Localization_Guest_Time_Period_Allways;
    }
}
- (NSString*)readTimePeriodMode
{
    return [self localizationStringForTimePeriodMode:[GenieHelper readTimePeriodMode]];
}
- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"getGuestAccessInfoProcess",dic);
    GenieGuestData * data = [[GenieGuestData alloc] init];
    NSString * enableStatus = [dic valueForKey:Guest_NewGuestAccessEnabled];
    
    if ([enableStatus isEqualToString:@"0"] || [enableStatus isEqualToString:@"1"])
    {
        if ([enableStatus isEqualToString:@"0"])
        {
            data.enable = GenieFunctionNotEnbaled;
        }
        else
        {
            data.enable = GenieFunctionEnabled;
        }
        
        data.ssid = [dic valueForKey:Guest_NewSSID];
        data.securityMode = GenieSecurityModeStringWPA_PSK;//default is WPA_PSK
        NSString * modeStr = [dic valueForKey:Guest_NewSecurityMode];
        if ([[modeStr uppercaseString] isEqualToString:@"NONE"])
        {
            data.securityMode = GenieSecurityModeStringNone;
            data.password = nil;
        }
        else
        {
            NSSet * modes = Genie_Security_Mode_Set;
            if ([modes containsObject:modeStr])
            {
                data.securityMode = GenieSecurityModeStringWPA_PSK_WPA2_PSK;
            }
            data.password = [dic valueForKey:Guest_NewKey];
        }
    }
    else//== @"2"
    {
        data.enable = GenieFunctionNotSupport;
    }
    
    data.timePeriod = [self readTimePeriodMode];
    [GenieHelper setGuestData:data];
    [data release];
}
- (void) loadGuestAccessInfoCallback:(GenieCallbackObj*) obj
{
    //do something
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        GenieFunctionEnableStatus s = [GenieHelper getGuestData].enable;
        if (s == GenieFunctionNotSupport)
        {
            [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForGenieFuncNotSupport];
        }
        else
        {
            [self reloadGUI:s];
        }
    }
    else
    {
        if (err == GenieErrorSoap401)
        {
            [GenieHelper showGobackToMainPageMsgBoxWithMsg:Local_MsgForGenieFuncNotSupport];
        }
        else
        {
            [GenieHelper generalProcessGenieError:err];
        }
    }
}

- (void) refreshGuestAccessInfoCallback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        GenieFunctionEnableStatus s = [GenieHelper getGuestData].enable;
        if (s != GenieFunctionNotSupport)
        {
            [self reloadGUI:s];
        }
    }
}

- (void) resignTimePeriodNotification
{
    [GenieHelper resignTimePeriod];
}
- (void) clossGuestAccessCallback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    
    if ([GenieHelper isSmartNetwork])
    {
        [GenieHelper getGuestData].enable = GenieFunctionNotEnbaled;
        [self reloadGUI:GenieFunctionNotEnbaled];
    }
    else
    {
        [self resignTimePeriodNotification];//在smart network 模式下，不支持time period功能
        [GenieHelper logoutGenie];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
