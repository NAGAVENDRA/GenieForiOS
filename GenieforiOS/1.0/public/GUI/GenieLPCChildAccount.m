//
//  GenieLPCChildAccount.m
//  GenieiPad
//
//  Created by cs Siteview on 12-8-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieLPCChildAccount.h"
#import "GenieHelper.h"
#import "GenieHelper_Statistics.h"


@implementation GenieLPCChildAccount

- (id) initWithChilidAccount:(NSString*)account
{
    self = [super init];
    if (self)
    {
        m_bypassAccount = [account retain];
        m_target = nil;
        m_selector = nil;
        
        m_view = nil;
        m_label = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_bypassAccount release];
    [m_label release];
    [m_view release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) setBypassAccountLogoutSuccessed:(id) target selector:(SEL) selector
{
    m_target = target;
    m_selector = selector;
}

#pragma mark - View lifecycle
- (void) loadView
{
    UIView* v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = v;
    [v release];
    m_view = [[UIControl alloc] init];
    m_view.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:m_view];
    
    m_label = [[UILabel alloc] init];
    m_label.frame = CGRectMake(0, 0, 260, 40);
    m_label.textAlignment = UITextAlignmentCenter;
    m_label.backgroundColor = [UIColor clearColor];
    m_label.text = [Localization_BypassAccount_PromptOfLoggedIn stringByAppendingFormat:@" %@", m_bypassAccount];
    [m_view addSubview:m_label];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:Localization_Logout
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(logoutBypassAccount)];

	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
    
    self.title = Localization_BypassAccount_LogoutPageTitle;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    m_label.center = m_view.center;
}
#pragma mark - Table view data source
#pragma mark - Table view delegate

- (void) logoutBypassAccount
{
    [GenieHelper configForSetProcessOrLPCProcessStart];
    NSString * mac = [[GenieHelper getLocalMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@""];
    if (!mac)
    {
        mac = @"";
    }
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startLogoutLPCByPassAccount:[GenieHelper getCurrentRouterAdmin] 
                                                                                password:[GenieHelper getCurrentRouterPassword]
                                                                                     mac:mac];
    [GPWaitDialog show:op withTarget:self selector:@selector(logoutLPCByPassAccount_callback:) waitMessage:Local_Wait timeout:Genie_NoTimeOut cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}


- (void) logoutLPCByPassAccount_callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];

    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        if (m_target)
        {
            [m_target performSelector:m_selector withObject:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (err != GenieErrorAsyncOpCancel)
    {
        [GenieHelper showMsgBoxWithMsg:Local_MsgForTimeout];
    }
}
@end
