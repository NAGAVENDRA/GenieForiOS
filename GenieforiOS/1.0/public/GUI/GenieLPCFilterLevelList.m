//
//  GenieLPCFilterLevelList.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieLPCFilterLevelList.h"
#import "GenieHelper.h"

@implementation GenieLPCFilterLevelList

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) 
    {
        m_data = [[NSArray alloc] initWithObjects:Genie_LPC_Bundle_None,Genie_LPC_Bundle_Minimal,Genie_LPC_Bundle_Low,Genie_LPC_Bundle_Moderate,Genie_LPC_Bundle_High, nil];
        m_selectedRow = 0;
    }
    return self;
}

- (void)dealloc
{
    [m_data release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:Localization_Save
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(rightBtnPress)];
    rightButton.enabled = NO;//只有当进行了修改之后，才将保存按钮设置为可用状态
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
    self.title = Localization_Lpc_FilterLevel_Page_Title;
#ifndef __GENIE_IPHONE__
    UIView * bg = [[UIView alloc] init];
    bg.backgroundColor = BACKGROUNDCOLOR;
    [self.tableView setBackgroundView:bg];
    [bg release];
#endif
    NSString * filter = [GenieHelper getLPCData].bundle;
    if ([m_data containsObject:filter])
    {
        m_selectedRow = [m_data indexOfObject:filter];
    }
    else
    {
        m_selectedRow = 0;
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell.textLabel setNumberOfLines:0];
#ifdef __GENIE_IPHONE__
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
#else
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
#endif
    NSString * filter = [m_data objectAtIndex:indexPath.row];
    NSString * filterTitle = nil;
    NSString * filterDescription = nil;
    if ([filter isEqualToString:Genie_LPC_Bundle_None])
    {
        filterTitle = Localization_Lpc_FilterLevel_None_Title;
        filterDescription = Localization_Lpc_FilterLevel_None_Description;
    }
    else if ([filter isEqualToString:Genie_LPC_Bundle_Minimal])
    {
        filterTitle = Localization_Lpc_FilterLevel_Minimal_Title;
        filterDescription = Localization_Lpc_FilterLevel_Minimal_Description;
    }
    else if ([filter isEqualToString:Genie_LPC_Bundle_Low])
    {
        filterTitle = Localization_Lpc_FilterLevel_Low_Title;
        filterDescription = Localization_Lpc_FilterLevel_Low_Description;
    }
    else if ([filter isEqualToString:Genie_LPC_Bundle_Moderate])
    {
        filterTitle = Localization_Lpc_FilterLevel_Moderate_Title;
        filterDescription = Localization_Lpc_FilterLevel_Moderate_Description;
    }
    else
    {
        filterTitle = Localization_Lpc_FilterLevel_High_Title;
        filterDescription = Localization_Lpc_FilterLevel_High_Description;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",filterTitle,filterDescription];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if (m_selectedRow == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:m_selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if([m_data indexOfObject:Genie_LPC_Bundle_High] == index)
	{
		return 120;
	}
	else if([m_data indexOfObject:Genie_LPC_Bundle_Moderate] == index || [m_data indexOfObject:Genie_LPC_Bundle_Low] == index)
	{
		return 80;
	}
    else
    {
        return 60;
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == m_selectedRow)
    {
        return;
    }
    
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_selectedRow inSection:0]];
	cell.accessoryType = UITableViewCellAccessoryNone;	
	cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    m_selectedRow = indexPath.row;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


- (void) rightBtnPress
{
    [GenieHelper configForSetProcessOrLPCProcessStart];
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startSetParentalControlsFilterLevel:[GenieHelper getLPCData].token deviceID:[GenieHelper getLPCData].deviceID bundel:[m_data objectAtIndex:m_selectedRow]];
    [GPWaitDialog show:op withTarget:self selector:@selector(setLPCFilter_Callback:) waitMessage:Local_WaitForSetLPCFilter timeout:Genie_Set_LPC_Filter_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

- (void) setLPCFilter_Callback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [GenieHelper getLPCData].bundle = [m_data objectAtIndex:m_selectedRow];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
