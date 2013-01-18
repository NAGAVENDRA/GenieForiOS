//
//  GenieWirelessInfoController.m
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieWirelessInfoController.h"
#import "GenieHelper.h"
#import "GenieWirelessModifyController.h"
#import "GenieQRCodeTableCellView.h"


@implementation GenieWirelessInfoController

- (id) init
{
    self = [super init];
    if (self)
    {
        m_data = nil;
        m_tableview = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_tableview release];
    [m_data release];
    [[GenieHelper getWirelessData] clear];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    m_tableview.delegate = self;
    m_tableview.dataSource = self;
    [self.view addSubview:m_tableview];
    
    self.title = Localization_Wireless_InfoPage_Title;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    [rightBtnItem release];
    
    m_data = [[NSMutableArray alloc] init];

    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetWirelessInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(loadWirelessInfoCallback:) waitMessage:Local_WaitForLoadWirelessInfo timeout:Genie_Get_Wireless_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOrientation:self.interfaceOrientation];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)//qrcode img
    {
        return;
    }
    
    GenieWirelessModifyController * modifyer = [[GenieWirelessModifyController alloc] init];
    [modifyer setModifyFinished:self callback:@selector(modifyFinished_Callback)];
    [self.navigationController pushViewController:modifyer animated:YES];
    [modifyer release];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [m_data count];
    }
    else
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"cell%d%d", indexPath.row, indexPath.section];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        if (indexPath.section == 1)//qrcode image
        {
            cell = [[[GenieQRCodeTableCellView alloc] initWithReuseIdentifier:cellID ssid:[GenieHelper getWirelessData].ssid password:[GenieHelper getWirelessData].password] autorelease];
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
    if (indexPath.section == 0)
    {
        return STANDARD_ROW_HEITHT;
    }
    else
    {
        return ROW_HIGHT_QRCODE_IMG;
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
    valueString = [m_data objectAtIndex:index];
    switch (index)
    {
        case 0:
            keyString = Localization_Wireless_SSID_Title;
            break;
        case 1:
            keyString = Localization_Wireless_Channel_Title;
            break;
        case 2:
            keyString = Localization_Wireless_Password_Title;
            break;
        default:
            break;
    }
    cell.textLabel.text = keyString;
    cell.detailTextLabel.text = valueString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void) refresh
{
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetWirelessInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(refreshWirelessInfoCallback:) waitMessage:Local_WaitForRefreshWirlessInfo timeout:Genie_Get_Wireless_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) reloadGUI
{
    [m_data removeAllObjects];
    GenieWirelessData * data = [GenieHelper getWirelessData];
    if (data.ssid)
    {
        [m_data addObject:data.ssid];
    }
    else
    {
        [m_data addObject:Genie_N_A];
    }
    
    if (data.channel)
    {
        [m_data addObject:data.channel];
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
    [m_tableview reloadData];
}

#pragma mark ----Modify Traffic Callback
- (void) modifyFinished_Callback
{
    [self reloadGUI];//
} 

#pragma mark ---------XML-----------Wireless Setting  label
//static NSString * Wireless_NewEnable = @"NewEnable";
static NSString * Wireless_NewSSID = @"NewSSID";
static NSString * Wireless_NewWPAPassphrase = @"NewWPAPassphrase";//WPA password label
static NSString * Wireless_NewWEPKey = @"NewWEPKey";//WEP  password label
static NSString * Wireless_NewRegion = @"NewRegion";
static NSString * Wireless_NewChannel = @"NewChannel";
static NSString * Wireless_NewWirelessMode = @"NewWirelessMode";
static NSString * Wireless_NewBasicEncryptionModes = @"NewBasicEncryptionModes";
static NSString * Wireless_NewWPAEncryptionModes = @"NewWPAEncryptionModes";
#pragma mark business process callback
- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"getWirelessInfoProcess",dic);
    // do something parser data
    GenieWirelessData* data = [[GenieWirelessData alloc] init];
    data.ssid = [dic valueForKey:Wireless_NewSSID];
    ///////////
    NSString * channelStr = [dic valueForKey:Wireless_NewChannel];
    if ([[channelStr uppercaseString] isEqualToString:@"AUTO"])
    {
        channelStr = AutoChannel;
    }
    else
    {
        channelStr = [NSString stringWithFormat:@"%d",[channelStr intValue]];//对channel的格式进行规范化处理
    }
    data.channel = channelStr;
    
    data.region = [dic valueForKey:Wireless_NewRegion];
    if ([data.region isEqualToString:@"USA"])
    {
        data.region = @"US";
    }
    data.wirelessMode = [dic valueForKey:Wireless_NewWirelessMode];
    data.basicSecurityMode = GenieBasicSecurityModeWPA;//default is WPA
    data.securityMode = GenieSecurityModeStringWPA_PSK;//default is WPA_PSK
    NSString * basicEncryption = [dic valueForKey:Wireless_NewBasicEncryptionModes];
    if ([[basicEncryption uppercaseString] isEqualToString:@"NONE"])
    {
        data.securityMode = GenieSecurityModeStringNone;
        data.password = nil;
    }
    else 
    {
        if ([[basicEncryption uppercaseString] isEqualToString:@"WEP"])
        {
            data.basicSecurityMode = GenieBasicSecurityModeWEP;
            data.password = [dic valueForKey:Wireless_NewWEPKey];
        }
        else
        {
            data.basicSecurityMode = GenieBasicSecurityModeWPA;
            NSString * wpaEncryption = [dic valueForKey:Wireless_NewWPAEncryptionModes];
            NSSet * modes = Genie_Security_Mode_Set;
            if ([modes containsObject:wpaEncryption])
            {
                data.securityMode = GenieSecurityModeStringWPA_PSK_WPA2_PSK;
            }
            data.password = [dic valueForKey:Wireless_NewWPAPassphrase];
        }
    }

    [GenieHelper setWirelessData:data];
    [data release];
}
- (void) loadWirelessInfoCallback:(GenieCallbackObj*) obj
{
    //do something
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self reloadGUI];
    }
    else
    {
        [GenieHelper generalProcessGenieError:err];
    }
}

- (void) refreshWirelessInfoCallback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self reloadGUI];
    }
}

@end
