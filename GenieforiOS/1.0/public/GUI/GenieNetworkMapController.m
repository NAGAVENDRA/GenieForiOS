//
//  GenieNetworkMapController.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieNetworkMapController.h"
#import "GenieHelper.h"
#import "GenieHelper_Statistics.h"
#import "GenieNetworkMapView.h"
#import "GPageControl.h"
#import "GenieNetworkDeviceTypeListView.h"


#ifdef __GENIE_IPHONE__
#define PageControlSpaceFromBottom          5
#define  MaxDeviceNumberPerPage             5//设备数目至少是2 否则每页都只能画出本机  因为每页都至少要显示本机
#else
#define PageControlSpaceFromBottom          15
#define  MaxDeviceNumberPerPage             7
#endif

#define GenieDeviceDefaultTypeStr                @"Network Device"
#define GeneiLocalDeviceiPadTypeStr              @"iPad"
#define GenieLocalDeviceiPadIcon                 @"device_ipad_genie_icon"
#define GeneiLocalDeviceiPhoneTypeStr            @"iPhone"
#define GenieLocalDeviceiPhoneIcon               @"device_iphone_genie_icon"
#define GeneiLocalDeviceiPodTypeStr              @"iPod Touch"
#define GenieLocalDeviceiPodIcon                 @"device_ipod_genie_icon"

#define str_deviceIsBlocked                          @"Block"
#define str_deviceIsAllow                            @"Allow"
#define MaxItemNumberShowInPanelView             8
#define AppropriateRowsInPanelView               6   //panel的推荐行数，若超过该值，会影响panel的UI效果

@implementation GenieNetworkMapController
enum{f_item1=0,f_item2=1,f_item3=2,f_item4=3,f_item5=4,f_item6=5,f_item7=6,f_item8=7};
static bool g_deviceInfo_flag[MaxItemNumberShowInPanelView] = {false};//标记是否需要显示某条信息. 
static bool f_isRouterInfo = false;//标记将要显示的是否是路由器信息
static bool f_isSelfDeviceInfo = false;
static GPanelView * g_panelView = nil;//全局变量，每次使用时需要new出对象，使用后应该立即释放
static GenieDeviceInfo* g_activeCustomDevice = nil;//全局指针，指向当前可被自定义属性的设备信息对象   assign对象

- (void) backupUserDataOnV_1_0_15//处理1.0.15版本的用户配置文件数据
{
    if (m_devRecordList)
    {
        NSString * homeDic = [GenieHelper getFileDomain];
        NSString * filePath = [NSString stringWithFormat:@"%@/routerMap.info",homeDic];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if ( ![fileManager fileExistsAtPath:filePath] )
        {
            return;
        }
        NSMutableArray * tmp = [NSMutableArray arrayWithContentsOfFile:filePath];
        for ( id  arr in tmp)
        {
            if ([arr isKindOfClass:[NSArray class]])
            {
                GenieDeviceInfo * device = [[GenieDeviceInfo alloc] init];
                device.name = [arr objectAtIndex:0];
                device.mac = [arr objectAtIndex:3];
                device.typeString = [arr objectAtIndex:5];
                [m_devRecordList addObject:device];
                [device release];
            }
        }
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
        m_view = nil;
        m_scrollView = nil;
        m_pageControl = nil;
        m_alldevices = [[NSMutableArray alloc] init];
        m_devType2ImgMap = [[GenieHelper readDeviceTypeString2DeviceIconMapFromXML] retain];
        GeniePrint(@"devtype---->image:", m_devType2ImgMap);
        m_devRecordList = [self getUserCustomInfo];
        if (!m_devRecordList)
        {
            m_devRecordList = [[NSMutableArray alloc] init];
        }
        else
        {
            [m_devRecordList retain];
        }
        [self backupUserDataOnV_1_0_15];
        m_panelData = [[NSMutableArray alloc] initWithCapacity:MaxItemNumberShowInPanelView];
        m_customNameField = nil;
        m_customTypeBtn = nil;
        m_listView = nil;
        m_blockSwitcher = nil;
        m_blockSwitcherTitleLabel = nil;
        m_deviceBlockSwitcher = nil;
    }
    return self;
}

- (void) dealloc
{
    [m_deviceBlockSwitcher release];
    [m_blockSwitcherTitleLabel release];
    [m_blockSwitcher release];
    [m_customTypeBtn release];
    [m_listView release];
    [m_customNameField release];
    [m_panelData release];
    [m_devRecordList release];
    [m_devType2ImgMap release];
    [m_pageControl release];
    [m_scrollView release];
    [m_view release];
    [m_alldevices release];
    [super dealloc];
}
- (void) initializeCustomControls
{
#ifdef __GENIE_IPHONE__
    CGFloat customNameFieldFontSize = 12;
    CGFloat customTypeBtnFontSize = 13;
#else
    CGFloat customNameFieldFontSize = 18;
    CGFloat customTypeBtnFontSize = 20;
#endif
    //________________初始化与自定义设备信息相关的控件
    m_customNameField = [[UITextField alloc] init];
    m_customNameField.delegate = self;
    m_customNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_customNameField.borderStyle = UITextBorderStyleRoundedRect;
    m_customNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_customNameField.textAlignment = UITextAlignmentCenter;
    //m_customNameField.backgroundColor = [UIColor clearColor]; 解决ios4 与ios5 GUI表现不一致
    m_customNameField.font = [UIFont systemFontOfSize:customNameFieldFontSize];
    m_customNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    m_customTypeBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    m_customTypeBtn.backgroundColor = [UIColor clearColor];
    m_customTypeBtn.titleLabel.font = [UIFont systemFontOfSize:customTypeBtnFontSize];
    [m_customTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [m_customTypeBtn setBackgroundImage:[UIImage imageNamed:@"networkmap_customtype_btn"] forState:UIControlStateNormal];
    [m_customTypeBtn setBackgroundImage:[UIImage imageNamed:@"networkmap_customtype_touched_btn"] forState:UIControlEventTouchUpInside];
    [m_customTypeBtn addTarget:self action:@selector(showDeviceTypeList) forControlEvents:UIControlEventTouchUpInside];
}
- (void) loadView
{
    UIView * v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = v;
    [v release];
    m_view = [[UIView alloc] init];
    [m_view setBackgroundColor:BACKGROUNDCOLOR];
    [self.view addSubview:m_view];
    self.title = Localization_NetworkMap_InfoPage_Title;
    [self initializeCustomControls];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    [rightBtnItem release];
    
    m_scrollView = [[UIScrollView alloc] init];
    m_scrollView.backgroundColor = [UIColor clearColor];
    m_scrollView.delegate = self;
    m_scrollView.pagingEnabled = YES;
    m_scrollView.showsVerticalScrollIndicator = NO;
    m_scrollView.showsHorizontalScrollIndicator = NO;
    [m_view addSubview:m_scrollView];
    
    m_pageControl = [[GPageControl alloc] init];
    m_pageControl.currentPage = 0;
    m_pageControl.numberOfPages = 0;
    m_pageControl.userInteractionEnabled = NO;
    m_pageControl.backgroundColor = [UIColor clearColor];
    m_pageControl.hidesForSinglePage = YES;
    [m_view addSubview:m_pageControl];
    
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startGetNetworkMapInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(loadNetworkMapInfoCallback:) waitMessage:Local_WaitForLoadNetworkMapInfo timeout:Genie_Get_NetworkMap_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOritation:self.interfaceOrientation];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [self saveUserCustomInfo];
}
#pragma mark -----------------
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

- (void) showBlockSwitcher:(UIInterfaceOrientation)orientation
{
    GenieBlockType type = [GenieHelper getMapData].blockEnabled;
    if (type != GenieBlockNotSupport)
    {
#ifdef __GENIE_IPHONE__
        CGFloat blockSwitcher_right_margin = 4.0f;
        CGFloat blockSwitcher_bottom_margin = 4.0f;
        CGFloat blockSwitcher_font_size = 10.0f;
        CGSize  blockSwitcherLabelSize = CGSizeMake(72, 12);
#else
        CGFloat blockSwitcher_right_margin = 25.0f;
        CGFloat blockSwitcher_bottom_margin = 20.0f;
        CGFloat blockSwitcher_font_size = 13.0f;        
        CGSize  blockSwitcherLabelSize = CGSizeMake(100, 21);
#endif
        if (!m_deviceBlockSwitcher)
        {
            m_deviceBlockSwitcher = [[UISwitch alloc] init];//for each device
            [m_deviceBlockSwitcher addTarget:self action:@selector(allowOrBlockDeviceSwitchChanged) forControlEvents:UIControlEventValueChanged];
        }
        //block总开关
        if (!m_blockSwitcher)
        {
            m_blockSwitcher = [[UISwitch alloc] init];
            [m_blockSwitcher addTarget:self action:@selector(setEnableBlockStatusSwitcherChanged) forControlEvents:UIControlEventValueChanged];
            [m_view addSubview:m_blockSwitcher];
            
            m_blockSwitcherTitleLabel = [[UILabel alloc] init];
            m_blockSwitcherTitleLabel.textAlignment = UITextAlignmentRight;
            m_blockSwitcherTitleLabel.backgroundColor = [UIColor clearColor];
            m_blockSwitcherTitleLabel.text = Localization_NetworkMap_BlockSwitcher_Title;
            m_blockSwitcherTitleLabel.font = [UIFont systemFontOfSize:blockSwitcher_font_size];
            [m_view addSubview:m_blockSwitcherTitleLabel];
        }
        
        CGSize s = [m_blockSwitcher frame].size;
        m_blockSwitcher.center = CGPointMake(m_view.frame.size.width - s.width/2 - blockSwitcher_right_margin, m_view.frame.size.height - s.height/2 - blockSwitcher_bottom_margin);
        if (type == GenieBlockEnable)
        {
            m_blockSwitcher.on = YES;
        }
        else
        {
            m_blockSwitcher.on = NO;
        }
        
        m_blockSwitcherTitleLabel.frame = CGRectMake(0, 0, blockSwitcherLabelSize.width, blockSwitcherLabelSize.height);
#ifdef __GENIE_IPHONE__
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            m_blockSwitcherTitleLabel.center = CGPointMake((NSInteger)(m_blockSwitcher.center.x - s.width/2 - blockSwitcherLabelSize.width/2), (NSInteger)(m_blockSwitcher.center.y));
        }
        else if (UIInterfaceOrientationIsLandscape(orientation))
        {
            m_blockSwitcherTitleLabel.center = CGPointMake((NSInteger)(m_blockSwitcher.center.x), (NSInteger)(m_blockSwitcher.center.y - s.height/2 - blockSwitcherLabelSize.height/2));
        }
#else
        m_blockSwitcherTitleLabel.center = CGPointMake(m_blockSwitcher.center.x - s.width/2 - blockSwitcherLabelSize.width/2, m_blockSwitcher.center.y);
#endif
    }
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
    m_scrollView.frame = m_view.frame;
    [self drawNetworkMap];
    m_pageControl.center = CGPointMake(m_view.frame.size.width/2, m_view.frame.size.height-PageControlSpaceFromBottom);
    [self showBlockSwitcher:orientation];
}

#pragma mark device info
- (NSString*) getLocalDeviceIp
{
    NSString * ip = [GenieHelper getLocalIpAddress];
    if (ip)
    {
        return ip;
    }
    return Genie_N_A;
}

- (NSString*) getLocalDeviceMacAddr
{
    NSString * mac = [GenieHelper getLocalMacAddress];
    if (mac)
    {
        return mac;
    }
    return Genie_N_A;
}


- (GenieDeviceInfo*) getLocalDeviceInfo
{
    GenieDeviceInfo * localDevice = [[[GenieDeviceInfo alloc] init] autorelease];
    localDevice.name = [UIDevice currentDevice].name;
    localDevice.ip = [self getLocalDeviceIp];
    localDevice.mac = [self getLocalDeviceMacAddr];
    localDevice.connectMode = GenieConnectWireless;
#ifdef __GENIE_IPHONE__
    NSString * localDeviceName = [[UIDevice currentDevice] model];
    if ([[localDeviceName lowercaseString]rangeOfString:@"ipod"].length
        || [[localDeviceName lowercaseString]rangeOfString:@"itouch"].length)
    {
        localDevice.typeString = GeneiLocalDeviceiPodTypeStr;
        localDevice.icon = GenieLocalDeviceiPodIcon;
    }
    else
    {
        localDevice.typeString = GeneiLocalDeviceiPhoneTypeStr;
        localDevice.icon = GenieLocalDeviceiPhoneIcon;
    }
#else
    localDevice.typeString = GeneiLocalDeviceiPadTypeStr;
    localDevice.icon = GenieLocalDeviceiPadIcon;
#endif
    return localDevice;
}

- (void) drawNetworkMap
{
    for (UIView * view in [m_scrollView subviews])
    {
        [view removeFromSuperview];
    }
    [m_alldevices removeAllObjects];
    NSInteger pageCount = 0;
    GenieMapData * mapData = [GenieHelper getMapData];
    
    if ([mapData.allDevices count] == 0)
    {
        if (![GenieHelper isSmartNetwork])//在smart network条件下，不需要绘制本机信息
        {
            [m_alldevices addObject:[self getLocalDeviceInfo]];
        }
    }
    else
    {
        [m_alldevices addObjectsFromArray:mapData.allDevices];
    }
    
    NSInteger allDeviceCount = [m_alldevices count];
    if (allDeviceCount == 0)//设备数目为0 在smart network 条件下会出现
    {
        pageCount = 1;
    }
    else if (allDeviceCount%MaxDeviceNumberPerPage != 0)
    {
        pageCount = allDeviceCount/MaxDeviceNumberPerPage + 1;
    }
    else
    {
        pageCount = allDeviceCount/MaxDeviceNumberPerPage;
    }
    m_pageControl.numberOfPages = pageCount;
    CGRect rec = m_scrollView.frame;
    m_scrollView.contentSize = CGSizeMake(rec.size.width*pageCount, rec.size.height);
    
    for (NSInteger i = 0; i < pageCount; i++)
    {
        rec.origin.x = i*rec.size.width;
        GenieNetworkMapView * mapView = [[GenieNetworkMapView alloc] initWithFrame:CGRectMake(rec.size.width*i, CGZero, rec.size.width, rec.size.height)];
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        
        if ([GenieHelper isSmartNetwork])//在smart network 条件下，不需要在特定的地方绘制本机的信息
        {
            for (NSInteger j = 0; j < MaxDeviceNumberPerPage; j++)
            {
                NSInteger index = j + i*MaxDeviceNumberPerPage;
            
                if ([m_alldevices count] == 0)
                    break;
                if (index > [m_alldevices count]-1)
                    break;
                [arr addObject:[m_alldevices objectAtIndex:index]];
            }
        }
        else
        {
            [arr addObject:[m_alldevices objectAtIndex:0]];
            for (NSInteger j = 1; j < MaxDeviceNumberPerPage; j++)
            {
                NSInteger index = j + i*(MaxDeviceNumberPerPage-1);
                if (index > [m_alldevices count]-1)
                    break;
                [arr addObject:[m_alldevices objectAtIndex:index]];
            }
        }
        
        mapView.devices = arr;
        [arr release];
        [mapView addTarget:self selector:@selector(showDeviceInfo:)];
        [m_scrollView addSubview:mapView];
        [mapView release];
    }
    [m_scrollView scrollRectToVisible:CGRectMake(m_pageControl.currentPage*m_scrollView.frame.size.width, CGZero, m_scrollView.frame.size.width, m_scrollView.frame.size.height) animated:YES];
}

#pragma mark config file manager
- (void) saveUserCustomInfo
{
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",[GenieHelper getFileDomain],Genie_File_NetworkMap_UserDefined_Info];
    if (![GenieHelper isFileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [NSKeyedArchiver archiveRootObject:m_devRecordList toFile:filePath];
}

- (NSMutableArray*) getUserCustomInfo
{
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",[GenieHelper getFileDomain],Genie_File_NetworkMap_UserDefined_Info];
    if (![GenieHelper isFileExistsAtPath:filePath])
    {
        return nil;
    }
    else
    {
        return (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
}
#pragma mark action func
- (void) refresh
{
    //reset flag
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startGetNetworkMapInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(refreshNetworkMapInfoCallback:) waitMessage:Local_WaitForRefreshNetWorkMapInfo timeout:Genie_Get_NetworkMap_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) refreshMapViewForCustomFinished
{
    [self showViewWithOritation:self.interfaceOrientation];
}
- (void) showDeviceTypeList
{
    [m_customNameField resignFirstResponder];
    if (!g_activeCustomDevice)
    {
        return;
    }
    if (!m_listView)
    {
        m_listView = [[GenieNetworkDeviceTypeListView alloc] init];
        [m_listView setFinishCallback:self selector:@selector(customDeviceTypeFinished:)];
    }
    [[g_panelView backgroundView] addSubview:m_listView];//g_panelview 每次都是 新new出来的，所以可以直接使用add subview方法
    [m_listView showForDevice:g_activeCustomDevice selectedItem:[m_customTypeBtn titleForState:UIControlStateNormal]];
}

- (void) customDeviceTypeFinished:(NSString*)customTypeStr
{
    [m_customTypeBtn setTitle:customTypeStr forState:UIControlStateNormal];
    [self refreshMapViewForCustomFinished];
}
- (void) showDeviceInfo:(id)info
{
    //初始化各个标志位 以及全局变量
    for (NSInteger i = 0; i < MaxItemNumberShowInPanelView; i++)
    {
        g_deviceInfo_flag[i] = false;
    }
    f_isRouterInfo = false;
    f_isSelfDeviceInfo = false;
    g_activeCustomDevice = nil;
    //______
    g_panelView = [[GPanelView alloc] initWithTitle:nil highLightBtn:Localization_Close anotherBtn:nil];
    g_panelView.centerOffsetY = 20;//向下偏移
    g_panelView.delegate = self;
    g_panelView.dataSource = self;
    [g_panelView addTarget:self selector:@selector(panelBgClicked) forEvent:UIControlEventTouchUpInside];
    //________panelview 显示规则_________________
    //item1 device:
    //item2 type/firmware version:
    //item3 ip address:
    //item4 status:
    //item5 signal strength:
    //item6 link rate:
    //item7 mac address:
    //item8 block:
    //____________这些信息的显示与否不确定，用一组标志位来标记是否需要显示_________________
    [m_panelData removeAllObjects];
    if ([info isKindOfClass:[GenieRouterInfo class]])
    {
        //__________item1
        GenieRouterInfo * router = (GenieRouterInfo*)info;
        f_isRouterInfo = true;
        if (router.modelName)
        {
            [m_panelData addObject:router.modelName];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item1] = true;
        //__________item2
        if (router.firmware)
        {
            [m_panelData addObject:router.firmware];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item2] = true;
        //__________item3
        if (router.ip)
        {
            [m_panelData addObject:router.ip];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item3] = true;
        //___________item4
        if (router.internetStatus == GenieNetWorkOffline)
        {
            [m_panelData addObject:Localization_NetworkMap_Offline_status];
        }
        else
        {
            [m_panelData addObject:Localization_NetworkMap_Online_status];
        }
        g_deviceInfo_flag[f_item4] = true;
        //___________item5
        [m_panelData addObject:Genie_N_A];
        g_deviceInfo_flag[f_item5] = false;
        //___________item6
        [m_panelData addObject:Genie_N_A];
        g_deviceInfo_flag[f_item6] = false;
        //___________item7
        if (router.mac)
        {
            [m_panelData addObject:router.mac];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item7] = true;
        //__________item8
        [m_panelData addObject:Genie_N_A];
        g_deviceInfo_flag[f_item8] = false;
    }
    else
    {
        //item1
        GenieDeviceInfo * device = (GenieDeviceInfo*)info;
        g_activeCustomDevice = device;
        if ([device isEqual:[m_alldevices objectAtIndex:0]])
        {
            //在smart network条件下，不再有本机设备这以概念
            if (![GenieHelper isSmartNetwork])
            {
                f_isSelfDeviceInfo = true;
            }
            else
            {
                f_isSelfDeviceInfo = false;
            }
        }
        if (device.name)
        {
            [m_panelData addObject:device.name];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item1] = true;
        //item2
        if (device.typeString)
        {
            [m_panelData addObject:device.typeString];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item2] = true;
        //item3
        if (device.ip)
        {
            [m_panelData addObject:device.ip];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item3] = true;
        //item4
        if (device.networkStatus == GenieNetWorkOffline)
        {
            [m_panelData addObject:Localization_NetworkMap_Offline_status];
        }
        else
        {
            [m_panelData addObject:Localization_NetworkMap_Online_status];
        }
        g_deviceInfo_flag[f_item4] = true;
        if (device.connectMode == GenieConnectWired)//有线设备
        {
            [m_panelData addObject:Genie_N_A];
            g_deviceInfo_flag[f_item5] = false;
            [m_panelData addObject:Genie_N_A];
            g_deviceInfo_flag[f_item6] = false;
        }
        else
        {
            //item5
            if (device.signalStrength)
            {
                [m_panelData addObject:device.signalStrength];
                g_deviceInfo_flag[f_item5] = true;
            }
            else
            {
                [m_panelData addObject:Genie_N_A];
                g_deviceInfo_flag[f_item5] = false;
            }
            //item6
            if (device.speed)
            {
                [m_panelData addObject:device.speed];
                g_deviceInfo_flag[f_item6] = true;
            }
            else
            {
                [m_panelData addObject:Genie_N_A];
                g_deviceInfo_flag[f_item6] = false;
            }
        }
        //item7
        if (device.mac)
        {
            [m_panelData addObject:device.mac];
        }
        else
        {
            [m_panelData addObject:Genie_N_A];
        }
        g_deviceInfo_flag[f_item7] = true;
        //item8
        BOOL isRouterSupportBlock = [GenieHelper getMapData].blockEnabled;
        if (f_isSelfDeviceInfo || isRouterSupportBlock == GenieBlockNotSupport || isRouterSupportBlock == GenieBlockDisable)
        {
            [m_panelData addObject:Genie_N_A];
            g_deviceInfo_flag[f_item8] = false;
        }
        else
        {
            if (device.blocked)
            {
                [m_panelData addObject:str_deviceIsBlocked];
            }
            else
            {
                [m_panelData addObject:str_deviceIsAllow];
            }
            g_deviceInfo_flag[f_item8] = true;
        }
    }
    [g_panelView show];
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    g_activeCustomDevice.name = textField.text;
    [self refreshMapViewForCustomFinished];
}
- (void) panelBgClicked
{
    [m_customNameField resignFirstResponder];
    [m_listView dismiss];
}
#pragma mark delegate function
//scrollview
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    m_pageControl.currentPage = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
}

#pragma mark GPanelView delegate and datasource
- (CGFloat)panelView:(GPanelView *)panelView heightForRowIndex:(NSInteger)index
{
#ifdef __GENIE_IPHONE__
    if ((index == f_item1 || index == f_item2) && !f_isSelfDeviceInfo && !f_isRouterInfo)//deviceName textfield and typeBtn
    {
        return 28;//定制 第一行 和 第二行 的行高
    }
    else if (index == f_item8)//block ui
    {
        return 28;//定制block开关的行高
    }
    else//根据行数目 定制普通行（只显示label）的行高
    {
        if (panelView.rows > AppropriateRowsInPanelView)//行数太多 影响UI 故调整行高
        {
            return 18;
        }
        return 25;
    }
#else
    return 40;
#endif
}

- (void) cachingUserCustomInfo
{
    if (f_isRouterInfo || f_isSelfDeviceInfo)
    {
        return;
    }
    NSString * currentDeviceMacAddr = g_activeCustomDevice.mac;
    NSInteger index = -1;
    for (GenieDeviceInfo * device in m_devRecordList)
    {
        if ( [device.mac isEqualToString:currentDeviceMacAddr] )
        {
            index = [m_devRecordList indexOfObject:device];
            break;
        }
    }
    if (index >= 0)
    {
        [m_devRecordList replaceObjectAtIndex:index withObject:g_activeCustomDevice];
    }
    else
    {
        [m_devRecordList addObject:g_activeCustomDevice];
    }
}
- (void) dismissPanelView
{
    [g_panelView dismiss];
    [g_panelView release];
    g_panelView = nil;
    [self cachingUserCustomInfo];
}
- (void) panelView:(GPanelView*)panelView clickBtnWithBtnIndex:(NSInteger)index
{
    [self dismissPanelView];
}
- (NSInteger) numberOfRowsInPanelView:(GPanelView*)panelView
{
    NSInteger count = 0;
    for (NSInteger i = 0; i < MaxItemNumberShowInPanelView; i++)
    {
        if (g_deviceInfo_flag[i])
        {
            count++;
        }
    }
    return count;
}
- (GPanelViewCell*) panelView:(GPanelView*)panelView cellForRowAtIndex:(NSInteger)rowIndex
{
#ifdef __GENIE_IPHONE__
    CGFloat keyLabFontSize = 13;
    CGFloat ipLabFontSite = 12;
    CGFloat macLabFontSize = 11;
    CGFloat genelLabFontSize = 12;
    if (panelView.rows > AppropriateRowsInPanelView)
    {
        keyLabFontSize = 12;
        ipLabFontSite = 11;
        macLabFontSize = 10;
        genelLabFontSize = 11;
    }
#else
    CGFloat keyLabFontSize = 20;
    CGFloat ipLabFontSite = 18;
    CGFloat macLabFontSize = 16.5;
    CGFloat genelLabFontSize = 18;
#endif
    GPanelViewCell * cell = [[[GPanelViewCell alloc] init] autorelease];
    switch (rowIndex)
    {
        case f_item1://name
        {
            cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_Name_Title];
            if (f_isRouterInfo || f_isSelfDeviceInfo)
            {
                UILabel * deviceNameLab = [[UILabel alloc] init];
                deviceNameLab.font = [UIFont systemFontOfSize:genelLabFontSize];
                deviceNameLab.textColor = [UIColor whiteColor];
                deviceNameLab.backgroundColor = [UIColor clearColor];
                deviceNameLab.text = [m_panelData objectAtIndex:f_item1];
                cell.valueView = deviceNameLab;
                [deviceNameLab release];
            }
            else
            {
                m_customNameField.text = [m_panelData objectAtIndex:f_item1];
                cell.valueView = m_customNameField;
            }
        }
            break;
        case f_item2://type or firmware
        {
            NSString * keyTitle = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_Type_Title];
            if (f_isRouterInfo)
            {
                keyTitle = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_FirmwareVersion_Title];
            }
            cell.keyLabel.text = keyTitle;
            //_____
            if (f_isSelfDeviceInfo || f_isRouterInfo)
            {
                UILabel * typeLab = [[UILabel alloc] init];
                typeLab.font = [UIFont systemFontOfSize:genelLabFontSize];
                typeLab.textColor = [UIColor whiteColor];
                typeLab.backgroundColor = [UIColor clearColor];
                typeLab.text = [m_panelData objectAtIndex:f_item2];
                cell.valueView = typeLab;
                [typeLab release];
            }
            else
            {
                [m_customTypeBtn setTitle:[m_panelData objectAtIndex:f_item2] forState:UIControlStateNormal];
                cell.valueView = m_customTypeBtn;
            }
        }
            break;
        case f_item3://ip
        {
            cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_IpAddr_Title];
            UILabel * ipLab = [[UILabel alloc] init];
            ipLab.font = [UIFont systemFontOfSize:ipLabFontSite];
            ipLab.textColor = [UIColor whiteColor];
            ipLab.backgroundColor = [UIColor clearColor];
            ipLab.text = [m_panelData objectAtIndex:f_item3];
            cell.valueView = ipLab;
            [ipLab release];
        }
            break;
        case f_item4://network status
        {
            cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_NetworkStatus_Title];
            UILabel * networkStatusLab = [[UILabel alloc] init];
            networkStatusLab.backgroundColor = [UIColor clearColor];
            networkStatusLab.font = [UIFont systemFontOfSize:keyLabFontSize];
            networkStatusLab.text = [m_panelData objectAtIndex:f_item4];
            networkStatusLab.textColor = [UIColor greenColor];
            if ([networkStatusLab.text isEqualToString:Localization_NetworkMap_Offline_status])
            {
                networkStatusLab.textColor = [UIColor redColor];
            }
            cell.valueView = networkStatusLab;
            [networkStatusLab release];
        }
            break;
        case f_item5://signal strength
        case f_item6://link rate
        case f_item7://mac addr
        case f_item8://block switcher
        {
            NSInteger i = rowIndex;
            bool flag = false;
            for (; i < MaxItemNumberShowInPanelView; i++)
            {
                flag = g_deviceInfo_flag[i];
                if (!flag)
                {
                    continue;
                }
                else
                {
                    if (i == f_item5)
                    {
                        cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_SignalStrength_Title];
                        UILabel * signalStrengthLab = [[UILabel alloc] init];
                        signalStrengthLab.font = [UIFont systemFontOfSize:genelLabFontSize];
                        signalStrengthLab.textColor = [UIColor whiteColor];
                        signalStrengthLab.backgroundColor = [UIColor clearColor];
                        NSString * signalStr = [m_panelData objectAtIndex:f_item5];
                        if (![signalStr length])
                        {
                            signalStr = @"100";
                        }
                        signalStrengthLab.text = [signalStr stringByAppendingString:@"%"];
                        cell.valueView = signalStrengthLab;
                        [signalStrengthLab release];
                    }
                    else if (i == f_item6)
                    {
#ifdef __GENIE_IPHONE__
                        CGFloat fontsize = 10;
                        CGFloat margin_top = 0;
#else
                        CGFloat fontsize = 15;
                        CGFloat margin_top = 6.5;
#endif
                        cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_LinkSpeed_Title];
                        
                        UIWebView * webPage = [[UIWebView alloc]init];
                        NSString * cssString = [NSString stringWithFormat:@"<style>body{font-size:%.0fpx;font-family:Helvetica;color:white;text-align:left;margin-left:0px;margin-top:%.0fpx}a:link{color:#6666cc}} </style>",fontsize,margin_top];
                        NSString * speedStr = [m_panelData objectAtIndex:f_item6];
                        if (![speedStr length])
                        {
                            speedStr = @"100";
                        }
                        speedStr = [speedStr stringByAppendingString:@"Mbps"];
                        
                        NSString * hylintString = [speedStr stringByAppendingString:@"&nbsp;&nbsp;&nbsp;&nbsp;<a href=http://support.netgear.com/search/link%20rate>What is it?</a>"];
                        [webPage loadHTMLString:[cssString stringByAppendingString:hylintString] 
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
                        cell.valueView = webPage;
                        [webPage release];
                    }
                    else if (i == f_item7)
                    {
                        cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_MacAddr_Title];
                        UILabel * macLab = [[UILabel alloc] init];
                        macLab.font = [UIFont systemFontOfSize:macLabFontSize];
                        macLab.textColor = [UIColor whiteColor];
                        macLab.backgroundColor = [UIColor clearColor];
                        macLab.text = [m_panelData objectAtIndex:f_item7];
                        cell.valueView = macLab;
                        [macLab release];
                    }
                    else if (i == f_item8)
                    {
                        cell.keyLabel.text = [NSString stringWithFormat:@"%@:",Localization_NetworkMap_DeviceInfo_Block_Title];
                        m_deviceBlockSwitcher.on = YES;
                        if ([(NSString*)[m_panelData objectAtIndex:f_item8] isEqualToString:str_deviceIsAllow])
                        {
                            m_deviceBlockSwitcher.on = NO;
                        }
                        cell.valueView = m_deviceBlockSwitcher;
                    }
                    //显示完某条信息后应将该标记位置为false
                    g_deviceInfo_flag[i] = false;
                    break;
                }
            }
        }
            break;
        default:
            break;
    }
    cell.keyLabel.font = [UIFont systemFontOfSize:keyLabFontSize];
    return cell;
}


#pragma mark Guest Access xml label
static NSString * NetworkMap_NewAttachDevice = @"NewAttachDevice";
static NSString * NetworkMap_NewBlockDeviceEnable = @"NewBlockDeviceEnable";
static NSString * NetworkMap_InternetConnectionStatus = @"InternetConnectionStatus";
#pragma mark business process callback
enum DeviceMap {
	EMapDeviceIP=0,
	EMapDeviceName=1,
	EMapDeviceMacAddr=2,
	EMapDeviceConnectMode=3,
	EMapDeviceSpeed=4,
	EMapDevicesignalStrength=5,
    EMapDeviceBlocked=6,
};

- (void) analyzeOneDeviceInfo:(NSString*)string toMap:(GenieMapData*)data
{
    //1;ip;name;mac;wired;speed;strength  or
    //1;ip;name;mac;wired                 or
    //1;ip;name;mac
    //;为分隔字符
    //NSLog(@"device info :%@",string);
    GeniePrint(@"One Piece of Deviec Info String :", string);
    NSRange  range = [string rangeOfString:@";"];
    if (!range.length)
    {
        return;
    }
    NSArray * deviceInfo = [[string substringFromIndex:range.location+range.length] componentsSeparatedByString:@";"];
    if (![deviceInfo count])
    {
        return;
    }
    GenieDeviceInfo * device = [[GenieDeviceInfo alloc] init];
    NSInteger count = [deviceInfo count];
    for (NSInteger i = 0; i<count; i++)
    {
        switch (i)
        {
            case EMapDeviceIP:
                device.ip = [deviceInfo objectAtIndex:i];
                break;
            case EMapDeviceName:
                device.name = [deviceInfo objectAtIndex:i];
                break;
            case EMapDeviceMacAddr:
                device.mac = [deviceInfo objectAtIndex:i];
                break;
            case EMapDeviceConnectMode:
            {
                NSString* connModeStr = [[deviceInfo objectAtIndex:i] lowercaseString];
                if ([connModeStr isEqualToString:@"wired"])
                {
                    device.connectMode = GenieConnectWired;
                }
                else
                {
                    device.connectMode = GenieConnectWireless;
                }
            }
                break;
            case EMapDeviceSpeed:
                device.speed = [deviceInfo objectAtIndex:i];
                break;
            case EMapDevicesignalStrength:
                device.signalStrength = [deviceInfo objectAtIndex:i];
                break;
            case EMapDeviceBlocked:
            {
                NSString * blockString = [[deviceInfo objectAtIndex:i] lowercaseString];
                if ([blockString isEqualToString:[str_deviceIsBlocked lowercaseString]])//status : block  and allow
                {
                    device.blocked = YES;
                }
                else
                {
                    device.blocked = NO;
                }
            }
                break;
            default:
                break;
        }
    }
    [data addDeviceInfo:device];
    [device release];
}

- (void) analyzeNetworkMapString :(NSString*)string toMap:(GenieMapData*)data
{
    ////////////////////////
    //协议格式：
    //n@1;ip;name;mac;wired;speed;strength
    // @2;ip;name;mac;wired;stppd;strength
    // @n;.....
    ////////////////////////
    //@字符为分隔符
    NSRange  range = [string rangeOfString:@"@"];
    if (!range.length)
    {
        //add default device info
        [data addDeviceInfo:[self getLocalDeviceInfo]];
        return;
    }
    NSArray * devicesInfo = [[string substringFromIndex:range.location+range.length] componentsSeparatedByString:@"@"];
    for (NSString * device in devicesInfo)
    {
        [self analyzeOneDeviceInfo:device toMap:data];
    }
}

//**************************
//1 检查本机信息 并将其放到第一位
//2 检查设备的类型信息
//3 读取设备类型信息和自定义的设备名称信息
- (void) processDevicesList:(GenieMapData*)data
{
    if (![GenieHelper isSmartNetwork])//在非smart network情况下，将本机设备排列到第一的位置
    {
        GenieDeviceInfo * local = [self getLocalDeviceInfo];
        BOOL isExitLocalDevice = NO;
        for (GenieDeviceInfo* d in [data allDevices])
        {
            if ([d.mac isEqualToString:local.mac])
            {
                d.name = local.name;
                d.connectMode = local.connectMode;
                d.typeString = local.typeString;
                d.icon = local.icon;
                [data.allDevices exchangeObjectAtIndex:0 withObjectAtIndex:[data.allDevices indexOfObject:d]];
                isExitLocalDevice = YES;
                break;
            }
        }
        if (!isExitLocalDevice)
        {
            [data addDeviceInfo:local];
            [data.allDevices exchangeObjectAtIndex:0 withObjectAtIndex:[data.allDevices count]-1];
        }
    }
    
    //.............
    for (GenieDeviceInfo * device in [data allDevices])
    {
        for (GenieDeviceInfo * d in m_devRecordList)
        {
            if ([device.mac isEqualToString:d.mac])
            {
                device.name = d.name;
                device.typeString = d.typeString;
                break;
            }
        }
        
        if (![GenieHelper isSmartNetwork])//在非smart network情况下，需要用特定的图片来标示本机
        {
            if ([data.allDevices indexOfObject:device] == 0)
            {
                continue;
            }
        }
        //------------------
        if (!device.typeString)
        {
            device.typeString = GenieDeviceDefaultTypeStr;
        }
        device.icon = [m_devType2ImgMap objectForKey:device.typeString];
    }
}
- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"loadNetworkMapInfoCallback",dic);
    GenieMapData * data = [[GenieMapData alloc] init];
    NSString * blockEnableStr = [dic objectForKey:NetworkMap_NewBlockDeviceEnable];
    if (!blockEnableStr)
    {
        data.blockEnabled = GenieBlockNotSupport;
    }
    else if ([blockEnableStr isEqualToString:@"1"])
    {
        data.blockEnabled = GenieBlockEnable;
    }
    else
    {
        data.blockEnabled = GenieBlockDisable;
    }
    
    if ([GenieHelper isSmartNetwork])
    {
        [GenieHelper getRouterInfo].internetStatus = GenieNetWorkOnline;
    }
    else
    {
        [GenieHelper getRouterInfo].internetStatus = GenieNetWorkOnline;
        
        NSString * internetStatus = [[dic objectForKey:[NetworkMap_InternetConnectionStatus lowercaseString]] uppercaseString];//
        if ([internetStatus isEqualToString:@"DOWN"])
        {
            [GenieHelper getRouterInfo].internetStatus = GenieNetWorkOffline;
        }
    }
    
    NSString * attachDeviceString = [dic objectForKey:NetworkMap_NewAttachDevice];
    [self analyzeNetworkMapString:attachDeviceString toMap:data];
    [self processDevicesList:data];
    [GenieHelper setMapData:data];
    [data release];
}
- (void) refreshMapView
{
    [self showViewWithOritation:self.interfaceOrientation];
}
- (void) loadNetworkMapInfoCallback:(GenieCallbackObj*)obj
{
    //do something
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self refreshMapView];
    }
}

- (void) refreshNetworkMapInfoCallback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        m_pageControl.currentPage = 0;
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self refreshMapView];
    }
}

#pragma mark ---
- (void) allowOrBlockDeviceSwitchChanged
{
    [self dismissPanelView];//
    [GenieHelper configForSetProcessOrLPCProcessStart];
    NSString * mac = g_activeCustomDevice.mac;
    if (![mac length])
    {
        mac = @"";
    }
    GTAsyncOp * op = nil;
    if (m_deviceBlockSwitcher.on)
    {
        op = [[GenieHelper shareGenieBusinessHelper] startSetDeviceBlocked:mac];
    }
    else
    {
        op = [[GenieHelper shareGenieBusinessHelper] startSetDeviceAllow:mac];
    }
    [GPWaitDialog show:op withTarget:self selector:@selector(setallowOrBlockDevice_Callback:) waitMessage:Local_WaitForSetNetWorkMapInfo timeout:Genie_Set_NetworkMap_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}
- (void) setEnableBlockStatusSwitcherChanged
{
    [GenieHelper configForSetProcessOrLPCProcessStart];
    GTAsyncOp * op = nil;
    if (m_blockSwitcher.on)
    {
        op = [[GenieHelper shareGenieBusinessHelper] startSetEnableBlockStatusOn];
    }
    else
    {
        op = [[GenieHelper shareGenieBusinessHelper] startSetEnableBlockStatusOff];
    }
    [GPWaitDialog show:op withTarget:self selector:@selector(setEnableBlockStatus_Callback:) waitMessage:Local_WaitForSetNetWorkMapInfo timeout:Genie_Set_NetworkMap_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}
- (void) setEnableBlockStatus_Callback:(GenieCallbackObj*) obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self refreshMapView];
    }
    else
    {
        m_blockSwitcher.on = !m_blockSwitcher.on;//设置出错 block switcher 状态重置
    }
}

- (void) setallowOrBlockDevice_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        [self refreshMapView];
    }
}

#pragma mark -- webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![[UIApplication sharedApplication] openURL:[request URL]];
}
@end
