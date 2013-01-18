//
//  GenieRemoteRouterList.m
//  GenieiPad
//
//  Created by cs Siteview on 12-6-11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieRemoteRouterList.h"
#import "GenieHelper.h"
#import "GenieRemoteRouterLoginPage.h"

@implementation GenieRemoteRouterInfoCell
@synthesize friendlyNameLabel = m_friendlyNameLabel;
@synthesize modelNameLabel = m_modelNameLable;
@synthesize serialLabel = m_serialLabel;
@synthesize statusLabel = m_statusLabel;
- (id) init
{
    self = [super init];
    if (self)
    {
#ifdef __GENIE_IPHONE__
        CGFloat font_size1 = 15.0f;
        CGFloat font_size2 = 10.0f;
#else
        CGFloat font_size1 = 18.0f;
        CGFloat font_size2 = 14.0f;
#endif
        m_friendlyNameLabel = [[UILabel alloc] init];
        m_friendlyNameLabel.font = [UIFont systemFontOfSize:font_size1]; 
        m_friendlyNameLabel.backgroundColor = [UIColor clearColor];
        
        m_serialLabel = [[UILabel alloc] init];
        m_serialLabel.font = [UIFont systemFontOfSize:font_size2];
        m_serialLabel.backgroundColor = [UIColor clearColor];
        
        m_modelNameLable = [[UILabel alloc] init];
        m_modelNameLable.font = [UIFont systemFontOfSize:font_size2];
        m_modelNameLable.textAlignment = UITextAlignmentRight;
        m_modelNameLable.backgroundColor = [UIColor clearColor];
        
        m_statusLabel = [[UILabel alloc] init];
        m_statusLabel.font = [UIFont systemFontOfSize:font_size2];
        m_statusLabel.textAlignment = UITextAlignmentRight;
        m_statusLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:m_friendlyNameLabel];
        [self.contentView addSubview:m_serialLabel];
        [self.contentView addSubview:m_modelNameLable];
        [self.contentView addSubview:m_statusLabel];
    }
    return self;
}

- (void) dealloc
{
    [m_friendlyNameLabel release];
    [m_serialLabel release];
    [m_modelNameLable release];
    [m_statusLabel release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect r = self.contentView.frame;
    CGFloat w = r.size.width;
    CGFloat h = r.size.height;
    
    CGFloat imgView_w = self.imageView.frame.size.width;
    CGFloat scale = 0.9f;
    CGFloat label_w = (w - imgView_w)/2*scale;
    CGFloat label_h = h/2;
    CGRect labelFrame = CGRectMake(0, 0, label_w, label_h);
    
    m_friendlyNameLabel.frame = labelFrame;
    m_serialLabel.frame = labelFrame;
    m_modelNameLable.frame = labelFrame;
    m_statusLabel.frame = labelFrame;
    
    CGFloat space = 10.0f;
    m_friendlyNameLabel.center = CGPointMake(imgView_w + label_w/2, label_h/2);
    m_modelNameLable.center = CGPointMake(w - label_w/2 - space, label_h/2);
    m_serialLabel.center = CGPointMake(imgView_w + label_w/2, label_h + label_h/2);
    m_statusLabel.center = CGPointMake(w - label_w/2 - space, label_h + label_h/2);
}
@end


@implementation GenieRemoteRouterList

static NSString * GRouter_Model = @"model";
static NSString * GRouter_Serial = @"serial";
static NSString * GRouter_Id = @"id";
static NSString * GRouter_FriedlyName = @"friendly_name";
static NSString * GRouter_ActiveStatus = @"active";

- (id) init
{
    self = [super init];
    if (self) 
    {
        m_view = nil;
        m_tableview = nil;
        m_data = [[NSMutableArray alloc] init];
        
        m_target_routerLogin = nil;
        m_selector_routerLogin = nil;
        m_target_logout = nil;
        m_selector_logout = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_data release];
    [m_tableview release];
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
    [self.view addSubview:m_view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = Localization_Login_RemoteRouterList_PageTitle;
    UIBarButtonItem * leftBtnItem = [[UIBarButtonItem alloc] initWithTitle:Localization_Logout
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(leftBtnPressed)];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    [leftBtnItem release];

    /*
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnPress)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    [rightBtnItem release];
     */
    
    m_tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    m_tableview.delegate = self;
    m_tableview.dataSource = self;
    [m_view addSubview:m_tableview];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewWithOritation:self.interfaceOrientation];
    [m_tableview reloadData];
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
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showViewWithOritation:toInterfaceOrientation];
}

- (void) setRemoteRouterLoginFinish:(id)target callback:(SEL)selector
{
    m_target_routerLogin = target;
    m_selector_routerLogin = selector;
}
- (void) setSmartNetworkLogout:(id) target callback:(SEL) selector
{
    m_target_logout = target;
    m_selector_logout = selector;
}
#pragma mark --view
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
    m_tableview.frame = m_view.frame;
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cellID%d%d",indexPath.row, indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[GenieRemoteRouterInfoCell alloc] init] autorelease];
    }
    
    GenieRemoteRouterInfoCell* routerCell = (GenieRemoteRouterInfoCell*)cell;
    
    GenieRemoteRouterInfo * snRouter = (GenieRemoteRouterInfo*)[m_data objectAtIndex:indexPath.row];
    routerCell.modelNameLabel.text = [snRouter.modelName stringByAppendingString:@" "];//空格，居右显示时，让文本与右边有间距
    routerCell.serialLabel.text = [NSString stringWithFormat:@"%@:%@",Localization_Login_RemoteRouterList_Serial_Title, snRouter.serial];
    routerCell.friendlyNameLabel.text = snRouter.friendlyName;
    
    NSString * networkStrting = nil;
    
    if (snRouter.activityStatus == GenieRouterInactivity)
    {
        networkStrting = Localization_Login_RemoteRouter_offline_status;
        routerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        routerCell.imageView.alpha = 0.5;
        routerCell.friendlyNameLabel.textColor = [UIColor grayColor];
        routerCell.modelNameLabel.textColor = [UIColor grayColor];
        routerCell.statusLabel.textColor = [UIColor grayColor];
        routerCell.serialLabel.textColor = [UIColor grayColor];
    }
    else
    {
        networkStrting = Localization_Login_RemoteRouter_online_status;
        routerCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        routerCell.imageView.alpha = 1.0;
        routerCell.friendlyNameLabel.textColor = [UIColor blackColor];
        routerCell.modelNameLabel.textColor = [UIColor blackColor];
        routerCell.statusLabel.textColor = [UIColor blackColor];
        routerCell.serialLabel.textColor = [UIColor blackColor];
    }

    routerCell.statusLabel.text = [networkStrting stringByAppendingString:@" "];
    
    NSString * routerIcon = snRouter.icon;
    if (!routerIcon)
    {
        routerIcon = @"router_default_icon";
    }
    routerCell.imageView.image = [UIImage imageNamed:routerIcon];
    
    return routerCell;
}


- (void) showRemoteRouterLoginPage:(GenieRemoteRouterInfo*) router;
{
    GenieRemoteRouterLoginPage * page = [[GenieRemoteRouterLoginPage alloc] initwithRouterInfo:router];
    [page setRouterLoginFinish:self callback:@selector(routerLoginCallback:)];
    [self.navigationController pushViewController:page animated:YES];
    [page release];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GenieRemoteRouterInfo * router = [m_data objectAtIndex:indexPath.row];
    
    if (router.activityStatus != GenieRouterActivity) 
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;//
    }
    
    [self showRemoteRouterLoginPage:router];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark btn press
- (void) logoutSmartNetwork
{
    [m_target_logout performSelector:m_selector_logout];
}

- (void) refreshBtnPress
{
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startGetSmartNetworkList];
    [GPWaitDialog show:op withTarget:self selector:@selector(refreshSNRouterList_callback:) waitMessage:Local_Wait timeout:Genie_NoTimeOut cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) leftBtnPressed
{
    //关闭session
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper].soapHelper closeSession];
    if (!op)
    {
        [self logoutSmartNetwork];
    }
    else
    {
        [GPWaitDialog show:op withTarget:self selector:@selector(closeSession_Callback) waitMessage:Local_Wait timeout:Genie_NoTimeOut cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
    }
}

- (void) closeSession_Callback
{
    [self logoutSmartNetwork];
}

- (void) refreshSNRouterList_callback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self getRemoteRouters:obj];
        [m_tableview reloadData];
        if ([self noRemoteDevicesFound])
        {
            [GenieHelper showMsgBoxWithMsg:Local_MsgForSmartNetworkNoDeviceFound];
        }
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
#pragma mark callback
- (void) routerLoginCallback:(GenieCallbackObj*)obj
{
    [self.navigationController popViewControllerAnimated:NO];
    [m_target_routerLogin performSelector:m_selector_routerLogin withObject:obj];
}


static NSString * router_list_flag = @"list";
static NSString * active_flag_true = @"true";

static NSString * storageDevice_RND = @"rnd";

- (void) sortRemoteRouters
{
    NSUInteger routersCount = [m_data count];
    if (!routersCount) return;
    
    [m_data sortUsingSelector:@selector(compare:)];
}

- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"sn router list:",dic);
    // do something parser data
    [m_data removeAllObjects];
    for (NSDictionary* router in (NSArray*)[dic objectForKey:router_list_flag])
    {
        GenieRemoteRouterInfo * info = [[GenieRemoteRouterInfo alloc] init];
        info.modelName = [router objectForKey:GRouter_Model];
        
        //filter out storage of rnd
        NSLog(@"\ndevice model:%@\n",[info.modelName lowercaseString]);
        if ([[[info.modelName lowercaseString] substringWithRange:NSMakeRange(0, [storageDevice_RND length])] isEqualToString:storageDevice_RND])
        {
            [info release];
            continue;
        }
        
        info.friendlyName = [router objectForKey:GRouter_FriedlyName];
        info.serial = [router objectForKey:GRouter_Serial];
        info.controlId = [router objectForKey:GRouter_Id];
        info.icon = [GenieHelper readRouterIconFromXMLWithModelName:info.modelName];
        
        if ([active_flag_true isEqualToString:[router objectForKey:GRouter_ActiveStatus]])
        {
            info.activityStatus = GenieRouterActivity;
        }
        else
        {
            info.activityStatus = GenieRouterInactivity;
        }
        
        [m_data addObject:info];
        [info release];
    }
    
    [self sortRemoteRouters];
}
- (void) getRemoteRouters:(GenieCallbackObj*) obj
{
    [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
}
- (BOOL) noRemoteDevicesFound
{
    if ([m_data count])
    {
        return NO;
    }
    return YES;
}

@end
