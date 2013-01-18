//
//  GenieLPCChildList.m
//  GenieiPad
//
//  Created by cs Siteview on 12-8-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieLPCChildList.h"
#import "GenieHelper.h"
#import "GenieHelper_Statistics.h"


@implementation GenieLPCChildList

- (id) initWithChildList:(NSArray *)list
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        m_subAccounts = [[NSMutableArray alloc] initWithArray:list];
        m_dialog = nil;
        m_passwordField = nil;
        m_selectedAccount = nil;//assign
        m_target = nil;//assign
        m_selector = nil;//assign
    }
    return self;
}

- (void)dealloc
{
    [m_subAccounts release];
    [m_dialog release];
    [m_passwordField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) setBypassAccountLoginSuccessed:(id) target selector:(SEL) selector
{
    m_target = target;
    m_selector = selector;
}

#pragma mark - View lifecycle

#ifdef __GENIE_IPHONE__//登陆框向上偏移  避免被键盘挡住
#define Login_Dialog_offset        -30
#else
#define Login_Dialog_offset        -100
#endif
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_dialog = [[GPanelView alloc] initWithTitle:Localization_Login highLightBtn:Localization_Login anotherBtn:Localization_Cancel];
    m_dialog.centerOffsetY = Login_Dialog_offset;
    m_dialog.delegate = self;
    m_dialog.dataSource = self;
    [m_dialog addTarget:self selector:@selector(bgClicked) forEvent:UIControlEventTouchUpInside];
    
    m_passwordField = [[UITextField alloc] init];
    m_passwordField.text = @"";
    m_passwordField.delegate = self;
	m_passwordField.borderStyle = UITextBorderStyleRoundedRect;
    m_passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_passwordField.adjustsFontSizeToFitWidth = YES;
	m_passwordField.secureTextEntry=YES;
    m_passwordField.clearButtonMode=UITextFieldViewModeWhileEditing;
    m_passwordField.returnKeyType = UIReturnKeyJoin;
    
    self.title = Localization_BypassAccount_ListPageTitle;
    
#ifndef __GENIE_IPHONE__
    UIView * bg = [[UIView alloc] init];
    bg.backgroundColor = BACKGROUNDCOLOR;
    [self.tableView setBackgroundView:bg];
    [bg release];
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_subAccounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = [m_subAccounts objectAtIndex:[indexPath row]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    m_selectedAccount = [m_subAccounts objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [m_dialog show];
}


#pragma mark - login dialog

- (void) loginBypassAccount
{
    [m_dialog dismiss];//点击 键盘的 join 按钮时  需要在这里处理
    
    [GenieHelper configForSetProcessOrLPCProcessStart];
    NSString * mac = [[GenieHelper getLocalMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@""];
    if (!mac)
    {
        mac = @"";
    }
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startLoginLPCByPassAccount:[GenieHelper getCurrentRouterAdmin] 
                                                             routerPassword:[GenieHelper getCurrentRouterPassword] 
                                                                    account: m_selectedAccount
                                                                   password:m_passwordField.text 
                                                           parentalDeviceID:[GenieHelper getLPCData].deviceID 
                                                                        mac:mac];
    [GPWaitDialog show:op withTarget:self selector:@selector(loginLPCByPassAccount_callback:) waitMessage:Local_Wait timeout:Genie_NoTimeOut cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
    
    m_passwordField.text = @"";//
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self loginBypassAccount];
    [textField resignFirstResponder];
    return YES;
}

- (CGFloat)panelView:(GPanelView *)panelView heightForRowIndex:(NSInteger)index
{
#ifdef __GENIE_IPHONE__
    CGFloat heightForRow1 = 30;
    CGFloat heightForRow2 = 30;
#else
    CGFloat heightForRow1 = 50;
    CGFloat heightForRow2 = 50;
#endif
    if (index == 0)
    {
        return heightForRow1;
    }
    else
    {
        return heightForRow2;
    }
}

- (void) panelView:(GPanelView*)panelView clickBtnWithBtnIndex:(NSInteger)index
{
    if (index == 0)//highlight btn  (login)
    {
        [self loginBypassAccount];
    }
    else
    {
        [m_dialog dismiss];
    }
}

- (NSInteger) numberOfRowsInPanelView:(GPanelView*)panelView
{
    return 2;
}
- (GPanelViewCell*) panelView:(GPanelView*)panelView cellForRowAtIndex:(NSInteger)index
{
#ifdef __GENIE_IPHONE__
    CGFloat keyLabFontSize = 15;
    CGFloat adminLabFontSize = 15;
#else
    CGFloat keyLabFontSize = 23;
    CGFloat adminLabFontSize = 23;
#endif
    GPanelViewCell * cell = [[[GPanelViewCell alloc] init] autorelease];
    if (index == 0)
    {
        cell.keyLabel.text = Localization_BypassAccount_LoginAccountLabel;
        UILabel * account = [[UILabel alloc] init];
        account.font = [UIFont systemFontOfSize:adminLabFontSize];
        account.backgroundColor = [UIColor clearColor];
        account.textColor = [UIColor whiteColor];
        account.text = m_selectedAccount;
        cell.valueView = account;
        [account release];
    }
    else
    {
        cell.keyLabel.text = Localization_BypassAccount_LoginPasswordLabel;
        cell.valueView = m_passwordField;
    }

    cell.keyLabel.font = [UIFont systemFontOfSize:keyLabFontSize];
    return cell;
}


- (void) bgClicked
{
    [m_passwordField resignFirstResponder];
}
#pragma mark --

- (void) loginLPCByPassAccount_callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];//
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        if (m_target)
        {
            [m_target performSelector:m_selector withObject:m_selectedAccount];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (err == GenieError_LPC_SignInOpenDNS_PassKey_Wrong)
    {
        [GenieHelper showMsgBoxWithMsg:Local_MsgForPasswordNoMatchUsername];
    }
    else if (err != GenieErrorAsyncOpCancel)
    {
        [GenieHelper showMsgBoxWithMsg:Local_MsgForTimeout];
    }
}
@end


