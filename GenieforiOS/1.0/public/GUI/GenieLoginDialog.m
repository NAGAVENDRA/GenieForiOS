//
//  GenieLoginDialog.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieLoginDialog.h"
#import "GenieHelper.h"


@implementation GenieLoginDialog
- (void) initializateView
{
    m_dialog.delegate = self;
    m_dialog.dataSource = self;
    [m_dialog addTarget:self selector:@selector(bgClicked) forEvent:UIControlEventTouchUpInside];
    
    m_passwordField.delegate = self;
	m_passwordField.borderStyle = UITextBorderStyleRoundedRect;
    m_passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_passwordField.adjustsFontSizeToFitWidth = YES;
	m_passwordField.secureTextEntry=YES;
    m_passwordField.clearButtonMode=UITextFieldViewModeWhileEditing;
    m_passwordField.returnKeyType = UIReturnKeyJoin;
    
    m_switcher = [[UISwitch alloc] init];
    [m_switcher addTarget:self action:@selector(switcherValueDidChanged) forControlEvents:UIControlEventValueChanged];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        m_dialog = [[GPanelView alloc] initWithTitle:Localization_HP_LoginDialog_Title highLightBtn:Localization_Login anotherBtn:Localization_Cancel];
        m_passwordField = [[UITextField alloc] init];
        m_switcher = [[UISwitch alloc] init];
        m_target = nil;
        m_selector = nil;
        m_loginOp = nil;
        m_timer = nil;
        [self initializateView];
    }
    return self;
}

- (void) dealloc
{
    [m_target release];
    [m_loginOp release];
    [m_switcher release];
    [m_passwordField release];
    [m_dialog release];
    [super dealloc];
}


- (void) bgClicked
{
    [m_passwordField resignFirstResponder];
}

- (void) initializateStatus
{
    m_err = GenieErrorUnknown;
    m_loginOpFinished = NO;
    m_aborted = NO;
    m_timeout = NO;
    m_switcher.on = YES;
    m_passwordField.text = @"";
    if (![GenieHelper getRouterLoginRememberMeFlag])
    {
        m_switcher.on = NO;
    }
    if (m_switcher.on)
    {
        NSString * key = [GenieHelper getRouterPassword];
        if ([key length])
        {
            m_passwordField.text = key;
        }
    }
}
- (void) showForAutoLogin:(BOOL)needAutoLogin;{
    [self initializateStatus];
    //[m_passwordField setBackgroundColor:[UIColor clearColor]];
    [m_dialog show];
    if (needAutoLogin)
    {
        [self startLoginOp];
    }
}
- (void) switcherValueDidChanged
{
    [GenieHelper setRouterLoginRememberMeFlag:m_switcher.on];
    
    if (!m_switcher.on)
    {
        [GenieHelper saveRouterPassword:@""];//清空密码记录
    }
}

- (void) setCallback:(id)target selector:(SEL)selector
{
    [m_target release];
    m_target = [target retain];
    m_selector = selector;
}

- (void) notifyFinished
{
    if (!m_loginOpFinished)
    {
        m_loginOpFinished = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [m_dialog dismiss];
        if ([m_timer isValid])
        {
            [m_timer invalidate];
        }
        [m_timer release];
        m_timer = nil;
        [m_target performSelector:m_selector withObject:[GenieCallbackObj callbackObjWithResponseCode:m_err userInfo:m_loginOp]];
    }
}
#pragma mark -------------op
- (void) aborbLoginOp
{
    if (m_loginOpFinished)
    {
        return;
    }
    m_aborted = YES;
    m_err = GenieErrorAsyncOpCancel;
    if (m_timeout)
    {
        m_err = GenieErrorAsyncOpTimeout;
    }
    [m_loginOp abort];
    [m_loginOp release];
    m_loginOp = nil;
    [self notifyFinished];
}

- (void) timeout
{
    if (m_loginOpFinished)
    {
        return;
    }
    m_timeout = YES;
    [self aborbLoginOp];
}
- (void) loginOpCallback
{
    if (m_aborted)
    {
        return;
    }
    m_err = GenieErrorNoError;
    [self notifyFinished];
}

- (void) disableDialogExceptCancelBtn
{
    [m_dialog setEnabled:NO];
    [m_dialog buttonAtIndex:1].enabled = YES;
    //m_passwordField.backgroundColor = [UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1.0];
}

- (void) showAnsycIndicator
{
    UIActivityIndicatorView * actV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect rec = [m_dialog frame];
    actV.center = CGPointMake(rec.size.width/2, rec.size.height/2);
    [m_dialog addSubView:actV];
    [actV startAnimating];
    [actV release];
} 

- (void) startLoginOp
{
    if ([GenieHelper getRouterLoginRememberMeFlag])
    {
        [GenieHelper saveRouterPassword:m_passwordField.text];
    }
    
    [self disableDialogExceptCancelBtn];
    [self showAnsycIndicator];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSTimeInterval ti = Genie_Login_ProcessTimeout;
    if (ti > 0)
    {
        m_timer = [[NSTimer scheduledTimerWithTimeInterval:Genie_Login_ProcessTimeout target:self selector:@selector(timeout) userInfo:nil repeats:NO] retain];
    }
    
    m_loginOp = [[[GenieHelper shareGenieBusinessHelper] startRouterLoginWithAdmin:[GenieHelper getRouterAdmin] password:m_passwordField.text] retain];
    [m_loginOp setFinishCallback:self selector:@selector(loginOpCallback)];
}

#pragma mark delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self startLoginOp];
    return YES;
}

- (CGFloat)panelView:(GPanelView *)panelView heightForRowIndex:(NSInteger)index
{
#ifdef __GENIE_IPHONE__
    CGFloat heightForRow1 = 30;
    CGFloat heightForRow2 = 30;
    CGFloat heightForRow3 = 15;
    CGFloat heightForRow4 = 40;
#else
    CGFloat heightForRow1 = 50;
    CGFloat heightForRow2 = 40;
    CGFloat heightForRow3 = 20;
    CGFloat heightForRow4 = 40;
#endif
    if (index == 0)
    {
        return heightForRow1;
    }
    else if (index == 1)
    {
        return heightForRow2;
    }
    else if (index == 2)
    {
        return heightForRow3;
    }
    else
    {
        return heightForRow4;
    }
}

- (void) panelView:(GPanelView*)panelView clickBtnWithBtnIndex:(NSInteger)index
{
    if (index == 0)//highlight btn
    {
        [self startLoginOp];
    }
    else
    {
        [self aborbLoginOp];
    }
}

- (NSInteger) numberOfRowsInPanelView:(GPanelView*)panelView
{
    return 4;
}
- (GPanelViewCell*) panelView:(GPanelView*)panelView cellForRowAtIndex:(NSInteger)index
{
#ifdef __GENIE_IPHONE__
    CGFloat keyLabFontSize = 15;
    CGFloat promptLabFontSize = 11;
    CGFloat adminLabFontSize = 15;
#else
    CGFloat keyLabFontSize = 23;
    CGFloat promptLabFontSize = 17;
    CGFloat adminLabFontSize = 23;
#endif
    GPanelViewCell * cell = [[[GPanelViewCell alloc] init] autorelease];
    if (index == 0)
    {
        cell.keyLabel.text = Localization_HP_LoginDialog_Admin_Lab_Title;
        UILabel * adminLab = [[UILabel alloc] init];
        adminLab.font = [UIFont systemFontOfSize:adminLabFontSize];
        adminLab.backgroundColor = [UIColor clearColor];
        adminLab.textColor = [UIColor whiteColor];
        adminLab.text = [GenieHelper getRouterAdmin];
        cell.valueView = adminLab;
        [adminLab release];
    }
    else if (index == 1)
    {
        cell.keyLabel.text = Localization_HP_LoginDialog_Password_Lab_Title;
        cell.valueView = m_passwordField;
    }
    else if (index == 2)
    {
        cell.keyLabel.text = nil;
        UILabel * promptLab = [[UILabel alloc] init];
        promptLab.font = [UIFont systemFontOfSize:promptLabFontSize];
        promptLab.backgroundColor = [UIColor clearColor];
        promptLab.textColor = [UIColor whiteColor];
        promptLab.text = Localization_HP_LoginDialog_DefaultPasswordPrompt;
        cell.valueView = promptLab;
        [promptLab release];
    }
    else 
    {
        cell.keyLabel.text = Localization_HP_LoginDialog_Switcher_Title;
        cell.valueView = m_switcher;
    }
    cell.keyLabel.font = [UIFont systemFontOfSize:keyLabFontSize];
    return cell;
}
@end
