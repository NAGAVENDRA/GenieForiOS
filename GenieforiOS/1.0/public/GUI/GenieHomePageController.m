//
//  GenieHomePageController.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieHomePageController.h"
#import "GPageControl.h"
#import "GenieHelper.h"
#import "GenieHelper_Statistics.h"
#import "Reachability.h"
#import "GenieLoginController.h"
#import "GenieRemoteRouterList.h"


#import "GenieWirelessInfoController.h"
#import "GenieGuestInfoController.h"
#import "GenieTrafficInfoController.h"
#import "GenieNetworkMapController.h"
#import "GenieLPCController.h"
#import "DLNAShareApi.h"
#import "ScanController.h"




#ifdef __GENIE_IPHONE__


#define LOGO_VIEW_SIZE                      CGRectMake(0, 0, 180, 30)
#define Search_Bar_Height                   37
#define FunctionBtnSize                     110
#define PageControlSpaceFromBottom          8


#else


#define LOGO_VIEW_SIZE                      CGRectMake(0, 0, 180, 30)
#define Search_Bar_Height                   37
#define FunctionBtnSize                     270
#define PageControlSpaceFromBottom          20

#endif

#define AlertView_AboutDialog_Tag                   100
#define AlertView_LoginFaceBook_Tag                 110
#define MaxIconsCountOnePage                6


#define  GENIE_SMART_NETWORK//smart net work 宏开关
@implementation GenieHomePageController
@synthesize remoteRouterList = m_remoteRouterList;

- (id) init 
{
    self = [super init];
    if (self)
    {
        m_view = nil;
        mainView = nil;
        pageControl = nil;
        searchBar = nil;
        allFuncIcons = [[NSMutableArray alloc] init];
        m_loginDialog = nil;
        m_remoteRouterList = nil;
        m_remoteRouterNaviController = nil;
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_remoteRouterNaviController release];
    [m_remoteRouterList release];
    [m_loginDialog release];
    [allFuncIcons release];
    [searchBar release];
    [pageControl release];
    [mainView release];
    [m_view release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}












#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CLLocationManager *locationManager = [[[CLLocationManager alloc] init] autorelease];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 500;
    [locationManager startUpdatingLocation];
    //
    UIView * v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = v;
    [v release];
    m_view = [[UIView alloc] init];
    m_view.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:m_view];
    self.title = Localization_Back;
    

}

#pragma mark -------------
static BOOL needAutoLoginOptionFlag = NO;
- (void) registAutoLogin
{
    needAutoLoginOptionFlag = YES;
}
- (BOOL) isNeedAutoLogin
{
    return needAutoLoginOptionFlag;
}
- (void) resignAutoLogin
{
    needAutoLoginOptionFlag = NO;
}

#pragma mark -------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUIElements];
    [GenieHelper sendStatistics_InstallationInfo];
}




- (void) setNaviItemLeftBtnTitle
{
    NSString * leftBtnTitle = Localization_Login;
    if ([GenieHelper isGenieCertified])
    {
        if ([GenieHelper isSmartNetwork])
        {
            leftBtnTitle = Localization_Back;
        }
        else
        {
            leftBtnTitle = Localization_Logout;
        }
    }
    self.navigationItem.leftBarButtonItem.title = leftBtnTitle;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNaviItemLeftBtnTitle];
    
    if (![self isNeedAutoLogin])
    {
        [GenieHelper configActiveFunction:GenieFunctionHomePage];
    }
    
    [self showViewWithOritation:self.interfaceOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [m_loginDialog release];
    m_loginDialog = nil;
    
    [allFuncIcons removeAllObjects];
    
    [searchBar release];
    searchBar = nil;
    [pageControl release];
    pageControl = nil;
    [mainView release];
    mainView = nil;
    [m_view release];
    m_view = nil;
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
#pragma mark -----------------------------
#pragma mark user interface
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation
{
    //show m_view
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
    
    //show search bar
    searchBar.frame = CGRectMake(CGZero, CGZero, m_view.frame.size.width, Search_Bar_Height);
    pageControl.center = CGPointMake(m_view.frame.size.width/2, m_view.frame.size.height-PageControlSpaceFromBottom);
    //show func homepage view
//    UIButton * shareButton  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    
//    shareButton.titleLabel.text=@"Share";
//    [shareButton addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    
//    UIBarButtonItem  * shareButton = [[UIBarButtonItem alloc]
//                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
//                                   target:self 
//                                   action:@selector(share)];

    
    [self showFunctionsHomePageWith:orientation];
}

- (void) setMainPageLogoImage
{
    if ([GenieHelper isSmartNetworkAvailable])
    {
        UIImage * logoImg = [UIImage imageNamed:@"genielogo_1"];
        UIImageView * logoView = [[UIImageView alloc] initWithImage:logoImg];
        logoView.frame = LOGO_VIEW_SIZE;
        self.navigationItem.titleView = logoView;
        [logoView release];
    }
    else
    {
        UIImage * logoImg = [UIImage imageNamed:@"genielogo"];
        UIImageView * logoView = [[UIImageView alloc] initWithImage:logoImg];
        logoView.frame = LOGO_VIEW_SIZE;
        self.navigationItem.titleView = logoView;
        [logoView release];
    }
}

- (void) initUIElements
{
    //init navigation item
    UIBarButtonItem * login_outBtn = [[UIBarButtonItem alloc] initWithTitle:Localization_Login
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(leftBtnPress)];
    self.navigationItem.leftBarButtonItem = login_outBtn;
    [login_outBtn release];
    
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(aboutBtnPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * aboutBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = aboutBtn;

    [aboutBtn release];
    
    [self setMainPageLogoImage];
    
    //init search bar
    searchBar = [[UISearchBar alloc] init];
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.delegate = self;
    searchBar.placeholder = Localization_HP_SearchBar_PlaceHolder;
    [m_view addSubview:searchBar];
    
    //init function icons page
    [self initFunctionsHomePage];
    
        
}
- (void) initFunctionsHomePage
{
    [self initFunctionIcons];
    
    mainView = [[UIScrollView alloc] init];
    mainView.delegate = self;
	mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
	mainView.showsVerticalScrollIndicator = NO;
	mainView.showsHorizontalScrollIndicator = NO;
    [m_view addSubview:mainView];
    
    /////////////9.14
    pageControl = [[GPageControl alloc] init];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.userInteractionEnabled = NO;
    pageControl.hidesForSinglePage = YES;
    pageControl.currentPage = 0;
    [m_view addSubview:pageControl];
}

- (void) layoutIcons:(NSArray*)icons onView:(UIView*)view withOrientation:(UIInterfaceOrientation)orientation
{
    //设定各个icon之间以及与屏幕边缘的间距单元  
    //左右间距相同，上下间距上小，最下间距要高，以留出pagecontrol的位置   
    int xSpace = 0;
    int ySpace = 0;
    CGSize fieldSize = view.frame.size;
    if ( UIInterfaceOrientationIsPortrait(orientation))
	{
        xSpace = (fieldSize.width-FunctionBtnSize*2)/3;
        ySpace = (fieldSize.height-FunctionBtnSize*3)/9;
        for (int i=0; i < [icons count]; i++) 
		{
			UIButton *icon = (UIButton*)[icons objectAtIndex:i];
			CGRect frame = icon.frame;
			switch (i) 
			{
				case 0:
                    frame.origin.x = xSpace;
                    frame.origin.y = ySpace*2;
                    break;
                    
				case 1:
                    frame.origin.x = xSpace*2 + FunctionBtnSize;
                    frame.origin.y = ySpace*2;
                    break;
                    
				case 2:
                    frame.origin.x = xSpace;
                    frame.origin.y = ySpace*4 + FunctionBtnSize;
                    break;
                    
				case 3:
                    frame.origin.x = xSpace*2 + FunctionBtnSize;
                    frame.origin.y = ySpace*4 + FunctionBtnSize;
                    break;
                    
				case 4:
                    frame.origin.x = xSpace;
                    frame.origin.y = ySpace*6 + FunctionBtnSize*2;
                    break;
                    
				case 5:
                    frame.origin.x = xSpace*2 + FunctionBtnSize;
                    frame.origin.y = ySpace*6 + FunctionBtnSize*2;
                    break;
                    
				default:
					break;
			}
            icon.frame = frame;
            [view addSubview:icon];
		}
	}
	else if (UIInterfaceOrientationIsLandscape(orientation))
	{
        xSpace = (fieldSize.width-FunctionBtnSize*3)/4;
        ySpace = (fieldSize.height-FunctionBtnSize*2)/16;
		for (int i=0; i < [icons count]; i++) 
		{
			UIButton * icon = (UIButton*)[icons objectAtIndex:i];
			CGRect frame = icon.frame;
			switch (i) 
			{
				case 0:
                    frame.origin.x = xSpace;
                    frame.origin.y = ySpace*5;
                    break;
                    
				case 1:
                    frame.origin.x = xSpace*2 + FunctionBtnSize;
                    frame.origin.y = ySpace*5;
                    break;
                    
				case 2:
                    frame.origin.x = xSpace*3 + FunctionBtnSize*2;
                    frame.origin.y = ySpace*5;
                    break;
                    
				case 3:
                    frame.origin.x = xSpace;
                    frame.origin.y = ySpace*10 + FunctionBtnSize;
                    break;
                    
				case 4:
                    frame.origin.x = xSpace*2 + FunctionBtnSize;
                    frame.origin.y = ySpace*10 + FunctionBtnSize;
                    break;
                    
				case 5:
                    frame.origin.x = xSpace*3 + FunctionBtnSize*2;
                    frame.origin.y = ySpace*10 + FunctionBtnSize;
                    break;
                    
				default:
					break;
			}
            icon.frame = frame;
            [view addSubview:icon];
		}
    }
}
- (void) showFunctionsHomePageWith:(UIInterfaceOrientation) orientation
{
    for (UIView* view in [mainView subviews])
    {
        [view removeFromSuperview];
    }
    NSInteger pageCapacity = MaxIconsCountOnePage;
    NSInteger pageCount = 0;
    NSInteger allIconsCount = [allFuncIcons count];
    if ([allFuncIcons count]%pageCapacity != 0)
    {
        pageCount = allIconsCount/pageCapacity + 1;
    }
    else
    {
        pageCount = allIconsCount/pageCapacity;
    }
    pageControl.numberOfPages = pageCount;
    CGRect rec = m_view.frame;
    mainView.frame = CGRectMake(CGZero, Search_Bar_Height, rec.size.width, rec.size.height-Search_Bar_Height);
    mainView.contentSize = CGSizeMake(mainView.frame.size.width*pageCount, mainView.frame.size.height);
    for (NSInteger i = 0; i < pageCount; i++)
    {
        NSArray * icons = nil;
        if (allIconsCount <= (i+1)*pageCapacity)
        {
            icons = [allFuncIcons subarrayWithRange:NSMakeRange(i*pageCapacity, allIconsCount-i*pageCapacity)];
        }
        else
        {
            icons = [allFuncIcons subarrayWithRange:NSMakeRange(i*pageCapacity, pageCapacity)];
        }
        
        UIControl * v = [[UIControl alloc] init];
        v.backgroundColor = [UIColor clearColor];
        [v addTarget:self action:@selector(bgViewPress) forControlEvents:UIControlEventTouchUpInside];
        v.frame = CGRectMake(i*mainView.frame.size.width, CGZero, mainView.frame.size.width, mainView.frame.size.height);
        [self layoutIcons:icons onView:v withOrientation:orientation];
        [mainView addSubview:v];
        [v release];
    }
    [mainView scrollRectToVisible:CGRectMake(pageControl.currentPage*mainView.frame.size.width, CGZero, mainView.frame.size.width, mainView.frame.size.height) animated:YES];
}

- (void) addFunctionWithTitle:(NSString*)name logoImage:(NSString*)img type:(GenieFunctionType) type operation:(SEL) selector
{
#ifdef __GENIE_IPHONE__    
    int     space = 5;
    CGRect  titleFrame = CGRectMake(space, 2*FunctionBtnSize/3+5, FunctionBtnSize-space*2, 15);
    CGFloat titleFontSize = 10.0f;
    
#else
    int     space = 10;
    CGRect  titleFrame = CGRectMake(space, 2*FunctionBtnSize/3+20, FunctionBtnSize-space*2, 30);
    CGFloat titleFontSize = 22.0f;
#endif    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(CGZero, CGZero, FunctionBtnSize, FunctionBtnSize);
    [btn setBackgroundImage:[UIImage imageNamed:@"func_icon_bg"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"func_icon_bg_selected"] forState:UIControlStateSelected];
    btn.tag = type;//
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage imageNamed:img];
    UIImageView *icon = [[UIImageView alloc] initWithImage:image];
    icon.frame = CGRectMake(CGZero, CGZero, FunctionBtnSize, FunctionBtnSize);
    icon.center = CGPointMake(FunctionBtnSize/2, FunctionBtnSize/2);
    [btn addSubview:icon];
    [icon release];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.textAlignment = UITextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize: titleFontSize];
    lable.backgroundColor = [UIColor clearColor];
    lable.text = name;
    lable.frame = titleFrame;
    [btn addSubview:lable]; 
    [lable release];
    
    [allFuncIcons addObject:btn];
}


/*
 *只有当Genie开启了smart network功能,才在Genie的功主菜单中显示MarketPlace功能按钮
 *在当前设计中，该按钮必须放到所有功能按钮的最后面
 */
- (void) addGenieMarketPlaceFunctionBtn
{
    NSUInteger n = [allFuncIcons count]; 
    if (!n) return;//功能btn数目为0
    
    UIButton * btn = (UIButton*)[allFuncIcons objectAtIndex:n-1];//在当前设计中，该按钮必须放到所有功能按钮的最后面
    if (btn.tag == GenieFunctionAppStore)//如果已经存在MarketPlace功能按钮，怎不再添加该按钮
    {
        return;
    }
    
    [self addFunctionWithTitle:Localization_HP_AppStore_Function_Btn_Title logoImage:@"logo_appstore" type:GenieFunctionAppStore operation:@selector(functionBtnPress:)];
}

- (void) initFunctionIcons
{
    [self addFunctionWithTitle:Localization_HP_Wireless_Function_Btn_Title logoImage:@"logo_wireless_setting" type:GenieFunctionWireless operation:@selector(functionBtnPress:)];
    [self addFunctionWithTitle:Localization_HP_Guest_Function_Btn_Title logoImage:@"logo_guest_access" type:GenieFunctionGuest operation:@selector(functionBtnPress:)];
    [self addFunctionWithTitle:Localization_HP_Map_Function_Btn_Title logoImage:@"logo_network_map" type:GenieFunctionMap operation:@selector(functionBtnPress:)];
    [self addFunctionWithTitle:Localization_HP_LPC_Function_Btn_Title logoImage:@"logo_parental_controls" type:GenieFunctionParentalControls operation:@selector(functionBtnPress:)];
    [self addFunctionWithTitle:Localization_HP_Traffic_Function_Btn_Title logoImage:@"logo_traffic_meter" type:GenieFunctionTraffic operation:@selector(functionBtnPress:)];
    [self addFunctionWithTitle:Localization_HP_MyMedia_Function_Btn_Title logoImage:@"logo_mymedia" type:GenieFunctionMyMedia operation:@selector(functionBtnPress:)];
    
    [self addFunctionWithTitle:Localization_HP_QR_Code_Function_Btn_Title logoImage:@"logo_qrcode" type:GenieFunctionQRCode operation:@selector(functionBtnPress:)];
    //add general function btn here
    
    
    //
    //addGenieMarketPlaceFunctionBtn 在当前设计中，该按钮必须放到所有功能按钮的最后面
    if ([GenieHelper isSmartNetworkAvailable])
    {
        [self addGenieMarketPlaceFunctionBtn];
    }
}

#pragma  mark btn action
- (void) beginWirelessSetting
{
    GenieWirelessInfoController * wirelessController = [[GenieWirelessInfoController alloc] init];
    [self.navigationController pushViewController:wirelessController animated:YES];
    [wirelessController release];
}

- (void) beginGuestAccess
{
    GenieGuestInfoController * guestController = [[GenieGuestInfoController alloc] init];
    [self.navigationController pushViewController:guestController animated:YES];
    [guestController release];
}

- (void) beginNetworkMap
{
    GenieNetworkMapController * networkMapController = [[GenieNetworkMapController alloc] init];
    [self.navigationController pushViewController:networkMapController animated:YES];
    [networkMapController release];
}

- (void) beginParentalControls
{
    GenieLPCController * lpcController = [[GenieLPCController alloc] init];
    [self.navigationController pushViewController:lpcController animated:YES];
    [lpcController release];
}

-(void) beginTrafficMeter
{
    GenieTrafficInfoController * trafficController = [[GenieTrafficInfoController alloc] init];
    [self.navigationController pushViewController:trafficController animated:YES];
    [trafficController release];
}

- (void) beginMyMedia
{
    beginDLNAService(self);
}

-(void) beginQRCode{
    ScanController * qrCodeController = [[ScanController alloc] init];
    [self.navigationController pushViewController:qrCodeController animated:YES];
    [qrCodeController release];
}

static NSString * appStoreUrl = @"https://genie.netgear.com/UserProfile/#AppStorePlace:";
- (void) beginAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreUrl]];
}
- (void) beginGenieFunction:(GenieFunctionType)function
{
    switch (function)
    {
        case GenieFunctionWireless:
            [self beginWirelessSetting];
            break;
        case GenieFunctionGuest:
            [self beginGuestAccess];
            break;
        case GenieFunctionMap:
            [self beginNetworkMap];
            break;
        case GenieFunctionTraffic:
            [self beginTrafficMeter];
            break;
        case GenieFunctionParentalControls:
            [self beginParentalControls];
            break;
        case GenieFunctionMyMedia:
            [self beginMyMedia];
            break;
        case GenieFunctionQRCode:
            [self beginQRCode];
            break;
        case GenieFunctionAppStore:
            [self beginAppStore];
            break;

        default:
            break;
    }
}

- (void) showLoginPage
{
    if (!m_remoteRouterNaviController)
    {
        m_remoteRouterList = [[GenieRemoteRouterList alloc] init];
        m_remoteRouterNaviController = [[UINavigationController alloc] initWithRootViewController:m_remoteRouterList];
        m_remoteRouterNaviController.navigationBar.barStyle = UIBarStyleBlack;
        [m_remoteRouterList setRemoteRouterLoginFinish:self callback:@selector(remoteRouterLoginOpCallback:)];
        [m_remoteRouterList setSmartNetworkLogout:self callback:@selector(logoutSmartNetworkCallback)];
    }
    
    GenieLoginController * loginController = [[GenieLoginController alloc] init];
    [loginController setLocalRouterLoginFinish:self callback:@selector(localRouterLoginOpCallback:)];
    [loginController setSmartNetworkLoginFinish:self callback:@selector(loginSmartNetworkCallback)];
    [loginController setNoRemoteRouter:self callback:@selector(noRemoteRouterCallback)];
    [self.navigationController pushViewController:loginController animated:YES];
    [loginController release];
}

- (void) showRemoteRouterList
{
    m_remoteRouterNaviController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:m_remoteRouterNaviController animated:YES];
}

- (void) functionBtnPress:(UIButton*)functionBtn
{
    [searchBar resignFirstResponder];
    [GenieHelper configActiveFunction:functionBtn.tag];
    
    if ([GenieHelper getActiveFuncton] == GenieFunctionMyMedia||
        [GenieHelper getActiveFuncton] == GenieFunctionQRCode ||
        [GenieHelper getActiveFuncton] == GenieFunctionAppStore )
    {
        [self beginGenieFunction:functionBtn.tag];  
    }
    else
    {
        if (![GenieHelper isGenieCertified])
        {
            [self registAutoLogin];
            [self showLoginPage];
        }
        else
        {
            [self beginGenieFunction:functionBtn.tag];
        }
    }
}

- (void) leftBtnPress
{
    [searchBar resignFirstResponder];
    [self resignAutoLogin];
    [GenieHelper configActiveFunction:GenieFunctionHomePage];
    
    if ([GenieHelper isGenieCertified])
    {
        if ([GenieHelper isSmartNetwork])
        {
            [self showRemoteRouterList];
        }
        else
        {
            [GenieHelper logoutGenie];
        }
    }
    else
    {
        [self showLoginPage];
    }
}



- (void) aboutBtnPress
{
    
    [searchBar resignFirstResponder];
    [self showSpecialAlertViewForShowAboutInfo];
}

- (void) bgViewPress
{
    [searchBar resignFirstResponder];
}


#pragma mark smart network
- (void) noRemoteRouterCallback
{
    [GenieHelper logoutSmartNetwork];
    [GenieHelper logoutGenie];
}
- (void) loginSmartNetworkCallback
{
    [self.navigationController popViewControllerAnimated:NO];
    [self showRemoteRouterList];
}

- (void) logoutSmartNetworkCallback
{
    [GenieHelper logoutSmartNetwork];
    [GenieHelper logoutGenie];
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark delegate function
//scrollview
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControl.currentPage = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
}
//search bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)scanBar                     // called when keyboard search button presse
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://support.netgear.com/search/%@",scanBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	scanBar.text = @"";
	[scanBar resignFirstResponder];
}


#pragma mark ---------XML-----------Router Login  label
static NSString * WLANConfiguration_NewWLANMACAddress = @"NewWLANMACAddress";
static NSString * DeviceInfo_ModelName = @"ModelName";
static NSString * DeviceInfo_Firmwareversion = @"Firmwareversion";

static NSString * CurrentSetting_ParentalControlSupported = @"ParentalControlSupported";
static NSString * CurrentSetting_Model = @"Model";
static NSString * CurrentSetting_Firmware = @"Firmware";
static NSString * CurrentSetting_SmartNetworkSupported = @"SmartNetworkSupported";
#pragma mark ----login Op callback
- (NSString*)parseMACAddr:(NSString*)mac
{
    NSInteger len = [mac length];
    if (len != 12)//MAC地址的为12个字符的十六进制数
    {
        return nil;
    }
    NSMutableString * retMacStr = [[[NSMutableString alloc] init] autorelease];
    NSInteger i = 0;
    for (; i<5; i ++)
    {
        [retMacStr appendString:[mac substringWithRange:NSMakeRange(i*2, 2)]];
        [retMacStr appendString:@":"];
    }
    [retMacStr appendString:[mac substringWithRange:NSMakeRange(i*2, 2)]];
    return retMacStr;
}

- (NSString*) setRouterIconImageWithModelName:(NSString*)model
{
    return [GenieHelper readRouterIconFromXMLWithModelName:model];
}
- (NSString*) getRouterIp
{
    NSString * ip = [GenieHelper getRouterIpAddress];
    return ip;
}


- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"Router login:",dic);
    
    NSString * sn_string = [dic valueForKey:[CurrentSetting_SmartNetworkSupported lowercaseString]];
    if ([sn_string isEqualToString:@"1"])
    {
        [GenieHelper setSmartNetworkAvailable];
        [self setMainPageLogoImage];
        [self addGenieMarketPlaceFunctionBtn];//
    }
    
    // do something parser data
    GenieRouterInfo* data = [[GenieRouterInfo alloc] init];
    NSString * lpcSupportString = [dic valueForKey:[CurrentSetting_ParentalControlSupported lowercaseString]];
    if ([lpcSupportString isEqualToString:@"1"])
    {
        data.notSupportLPC = NO;
    }
    else
    {
        data.notSupportLPC = YES;
    }
    
    data.modelName = [dic valueForKey:[CurrentSetting_Model lowercaseString]];
    if ([GenieHelper isSmartNetwork])//
    {
        data.modelName = [dic valueForKey:DeviceInfo_ModelName];
    }
    data.icon = [self setRouterIconImageWithModelName:data.modelName];
    
    NSString * originFirmStr = [dic valueForKey:[CurrentSetting_Firmware lowercaseString]];
    if ([GenieHelper isSmartNetwork])
    {
        originFirmStr = [dic valueForKey:DeviceInfo_Firmwareversion];
    }
    NSRange range = [originFirmStr rangeOfString:@"_"];
    if (range.length > 0)
    {
        data.firmware = [originFirmStr substringToIndex:range.location];
    }
    else
    {
        data.firmware = originFirmStr;
    }
    
    data.ip = [self getRouterIp];
    data.mac = [self parseMACAddr:[dic valueForKey:WLANConfiguration_NewWLANMACAddress]];
    [GenieHelper setRouterInfo:data];
    [data release];
}

- (void) remoteRouterLoginOpCallback:(GenieCallbackObj*) obj
{
    [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
    [GenieHelper configGenieLogin_outStatus:GenieLogin];
    [self setNaviItemLeftBtnTitle];
    
    [self dismissModalViewControllerAnimated:NO];
    if ([self isNeedAutoLogin])
    {
        [self beginGenieFunction:[GenieHelper getActiveFuncton]];
    }
    
    [self resignAutoLogin];
    [GenieHelper sendStatistics_RouterInfo];
}

- (void) localRouterLoginOpCallback:(GenieCallbackObj*) obj
{
    //do something
    [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
    [GenieHelper configGenieLogin_outStatus:GenieLogin];
    [self setNaviItemLeftBtnTitle];
    
    [self.navigationController popViewControllerAnimated:NO];
    if ([self isNeedAutoLogin])
    {
        [self beginGenieFunction:[GenieHelper getActiveFuncton]];
    }
    
    [self resignAutoLogin];
    [GenieHelper sendStatistics_RouterInfo];
}

#pragma mark special alert view and delegate



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
										   otherButtonTitles:Localization_HP_AboutDialog_License_Title ,@"Privacy Policy",nil];
	aboutDialog.tag = AlertView_AboutDialog_Tag;
	[msg release];
	[aboutDialog show];
	[aboutDialog release];
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
        if (buttonIndex == 2)
        {
            NSString* linkpath = @"http://www.netgear.com/about/privacypolicy/";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkpath]];
        }
    }
}


@end
