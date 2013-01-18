//
//  GenieTrafficModifyController.m
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieTrafficModifyController.h"
#import "GenieHelper.h"
#import "GenieItemListController.h"

#ifdef __GENIE_IPHONE__
#define MonthlyLimitTextFieldFrame          CGRectMake(0,0,140,31)
#define TimeTextFieldFrame                  CGRectMake(0,0,60,31)
#define TimeInputViewFrame                  CGRectMake(0,0,220+5,40)
#define TimeInputView_Lab_Frame             CGRectMake(0,0,50,40)//约定：两个lab的长度加上两个field的长度等于inputView的长度-Margin，以便刚好放到inputView上布局
#else
#define MonthlyLimitTextFieldFrame          CGRectMake(0,0,320,31)
#define TimeTextFieldFrame                  CGRectMake(0,0,130,31)
#define TimeInputViewFrame                  CGRectMake(0,0,460+5,40)
#define TimeInputView_Lab_Frame             CGRectMake(0,0,100,40)
#endif



@implementation GenieTrafficModifyController
- (id) init
{
    self = [super init];
    if (self)
    {
        m_tableview = nil;
        m_monthLimitTextField = nil;
        m_hourTextField = nil;
        m_minuteTextField = nil;
        m_isInfoChanged = NO;
        //
        m_dayInfo = [[GenieHelper getTrafficData].day retain];
        m_trafficLimitModeInfo = [[GenieHelper getTrafficData].limitMode retain];
        m_target = nil;
        m_selector = nil;
    }
    return  self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_target release];
    [m_dayInfo release];
    [m_trafficLimitModeInfo release];
    [m_minuteTextField release];
    [m_hourTextField release];
    [m_monthLimitTextField release];
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
    self.title = Localization_Traffic_SetPage_Title;
    /////
#ifdef __GENIE_IPHONE__
    CGFloat fieldForTimeFontSize = 12;
#else
    CGFloat fieldForTimeFontSize = 16;
#endif
    m_monthLimitTextField = [[UITextField alloc] initWithFrame:MonthlyLimitTextFieldFrame];
    m_monthLimitTextField.text = [GenieHelper getTrafficData].monthlyMeter;
    m_monthLimitTextField.delegate = self;
    m_monthLimitTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_monthLimitTextField.keyboardType = UIKeyboardTypeNumberPad;
    m_monthLimitTextField.returnKeyType = UIReturnKeyDone;
    m_monthLimitTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_monthLimitTextField.backgroundColor = [UIColor clearColor];
    m_monthLimitTextField.textAlignment = UITextAlignmentCenter;
    m_monthLimitTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_monthLimitTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    m_hourTextField = [[UITextField alloc] initWithFrame:TimeTextFieldFrame];
    m_hourTextField.text = [GenieHelper getTrafficData].hour;
    m_hourTextField.delegate = self;
    m_hourTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_hourTextField.keyboardType = UIKeyboardTypeNumberPad;
    m_hourTextField.returnKeyType = UIReturnKeyDone;
    m_hourTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_hourTextField.backgroundColor = [UIColor clearColor];
    m_hourTextField.textAlignment = UITextAlignmentCenter;
    m_hourTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_hourTextField.font = [UIFont systemFontOfSize:fieldForTimeFontSize];
    m_hourTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    m_minuteTextField = [[UITextField alloc] initWithFrame:TimeTextFieldFrame ];
    m_minuteTextField.text = [GenieHelper getTrafficData].minute;
    m_minuteTextField.delegate = self;
    m_minuteTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    m_minuteTextField.keyboardType = UIKeyboardTypeNumberPad;
    m_minuteTextField.returnKeyType = UIReturnKeyDone;
    m_minuteTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_minuteTextField.backgroundColor = [UIColor clearColor];
    m_minuteTextField.textAlignment = UITextAlignmentCenter;
    m_minuteTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_minuteTextField.font = [UIFont systemFontOfSize:fieldForTimeFontSize];
    m_minuteTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
    [self showViewWithOrientation:self.interfaceOrientation];
    
    BOOL enable = YES;
    if (![m_monthLimitTextField.text length])
    {
        enable = NO;
        [m_monthLimitTextField becomeFirstResponder];
    }
    else if (![m_hourTextField.text length])
    {
        enable = NO;
        [m_hourTextField becomeFirstResponder];
    }
    else if (![m_minuteTextField.text length])
    {
        enable = NO;
        [m_minuteTextField becomeFirstResponder];
    }
    else if (!m_isInfoChanged)
    {
        enable = NO;
    }
    self.navigationItem.rightBarButtonItem.enabled = enable;
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
    [m_target release];
    m_target = [target retain];
    m_selector = selector;
}
- (void) doRightBtnTouchedUpInsideFunction
{
    [GenieHelper configForSetProcessOrLPCProcessStart];
    NSString * controlMode = Genie_Traffic_Option_NoLimit;
    if ([m_trafficLimitModeInfo isEqualToString:Localization_Traffic_DownloadLimit])
    {
        controlMode = Genie_Traffic_Option_DownloadLimit;
    }
    else if ([m_trafficLimitModeInfo isEqualToString:Localization_Traffic_BothLimit])
    {
        controlMode = Genie_Traffic_Option_BothLimit;
    }
    GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startSetTrafficMeterOptionWithControlMode:controlMode monthlyLimit:m_monthLimitTextField.text counterRestartDay:m_dayInfo hour:m_hourTextField.text minute:m_minuteTextField.text];
    [GPWaitDialog show:op withTarget:self selector:@selector(setTrafficMeterCallback:) waitMessage:Local_WaitForSetTrafficInfo timeout:Genie_Set_Traffic_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.navigationItem.rightBarButtonItem.enabled)
    {
        [self doRightBtnTouchedUpInsideFunction];
    }
	[textField resignFirstResponder];
	return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if(![string length])
	{
		return YES;
	}
    /////////////控制输入字符的有效性（都是有效的数字）
    char ch = [string characterAtIndex:0];/////
    if (ch < L'0' || ch > L'9')
    {
        return NO;
    }
	if(textField == m_monthLimitTextField)//月流量的最大值为1000000
	{
        if ([textField.text isEqualToString:@"0"])
        {
            return NO;
        }
        if ([textField.text length] >= 7)
        {
            return NO;
        }
		if([textField.text length] == 6)
		{
            if ([textField.text characterAtIndex:0] == L'1'&&
                [textField.text characterAtIndex:1] == L'0'&&
                [textField.text characterAtIndex:2] == L'0'&&
                [textField.text characterAtIndex:3] == L'0'&&
                [textField.text characterAtIndex:4] == L'0'&&
                [textField.text characterAtIndex:5] == L'0'&&
                [string characterAtIndex:0] == L'0')
            {
                return YES;
            }
			return NO;
		}
		return YES;
	}
    else//输入时间 24小时制  最大为23:59  最小为00:00
    {
        if([textField.text length] >= 2)
        {
            return NO;
        }
        if([textField.text length] == 1)
        {
            if(textField == m_hourTextField)//hour
            {
                if([textField.text characterAtIndex:0] > L'2' || ([textField.text characterAtIndex:0] == L'2' && [string characterAtIndex:0] > L'3'))
                {
                    return NO;
                }
            }
            else if(textField == m_minuteTextField)//minute
            {
                if([textField.text characterAtIndex:0] > L'5')
                {
                    return NO;
                }
            }
        }
        return YES;    
    }
}


- (void) textFieldTextDidChange :(NSNotification*)notify
{
    if (![m_monthLimitTextField.text length] || ![m_minuteTextField.text length] || ![m_hourTextField.text length])
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    m_isInfoChanged = YES;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2)
    {
        return 1;
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
#ifdef __GENIE_IPHONE__
    return 13;
#else
    return 20;
#endif    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)//section for set traffic counter
    {
#ifdef __GENIE_IPHONE__
        CGFloat promptSize = 10.0f;
        CGFloat space = 10;
#else
        CGFloat promptSize = 15.0f;
        CGFloat space = 45;
#endif
        UIView * headerView = [[[UIView alloc] init] autorelease];
        NSString * promptText = Localization_Traffic_Conter_Start_Prompt;
        UIFont * promptTextFont = [UIFont systemFontOfSize: promptSize];
        CGSize textSize = [promptText sizeWithFont:promptTextFont];
        UILabel * tip = [[UILabel alloc] initWithFrame:CGRectMake(space, CGZero, textSize.width, textSize.height)];
        tip.font = promptTextFont;
        tip.text = promptText;
        tip.backgroundColor = [UIColor clearColor];
        [headerView addSubview:tip];
        [tip release];
        return headerView;
    }
    return nil;
}


- (UIView*) createTimeInputView
{
#ifdef __GENIE_IPHONE__
    CGFloat fontSize = 12;
#else
    CGFloat fontSize = 16;
#endif
    CGRect inputViewFrame = TimeInputViewFrame;
    UIView * timeInputView = [[UIView alloc] initWithFrame:inputViewFrame];
    timeInputView.backgroundColor = [UIColor clearColor];
    //hour label
    CGRect labFrame = TimeInputView_Lab_Frame;
    UILabel * hourLab = [[UILabel alloc] initWithFrame:labFrame];
    hourLab.backgroundColor = [UIColor clearColor];
    hourLab.textAlignment = UITextAlignmentRight;
    hourLab.font = [UIFont systemFontOfSize:fontSize];
    hourLab.text = [NSString stringWithFormat:@"%@ ",Localization_Traffic_Time_Hour_Label_Title];
    hourLab.center = CGPointMake(labFrame.size.width/2, inputViewFrame.size.height/2);
    [timeInputView addSubview:hourLab];
    [hourLab release];
    m_hourTextField.center = CGPointMake(labFrame.size.width+m_hourTextField.frame.size.width/2, inputViewFrame.size.height/2);
    [timeInputView addSubview:m_hourTextField];
    //minute label
    UILabel * minuteLab = [[UILabel alloc] initWithFrame:labFrame];
    minuteLab.backgroundColor = [UIColor clearColor];
    minuteLab.textAlignment = UITextAlignmentRight;
    minuteLab.font = [UIFont systemFontOfSize:fontSize];
    minuteLab.text = [NSString stringWithFormat:@"%@ ",Localization_Traffic_Time_Minute_Label_Title];
    minuteLab.center = CGPointMake(labFrame.size.width+m_hourTextField.frame.size.width+labFrame.size.width/2, inputViewFrame.size.height/2);
    [timeInputView addSubview:minuteLab];
    [minuteLab release];
    m_minuteTextField.center = CGPointMake(labFrame.size.width*2+m_hourTextField.frame.size.width+m_minuteTextField.frame.size.width/2, inputViewFrame.size.height/2);
    [timeInputView addSubview:m_minuteTextField];
    return [timeInputView autorelease];
}

- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath row];
    if (indexPath.section == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = Localization_Traffic_MonthlyLimit_Title_ModifyPage;
#ifdef __GENIE_IPHONE__
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
#endif
        cell.accessoryView = m_monthLimitTextField;
    }
    else if (indexPath.section == 1)
    {
        
        if (index == 0)//counter start time
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = Localization_Traffic_Time_Title_ModifyPage;
            cell.accessoryView = [self createTimeInputView];
        }
        else//counter start day
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = Localization_Traffic_Day_Title_ModifyPage;
            cell.detailTextLabel.text = m_dayInfo;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = Localization_Traffic_LimitMode_Title_ModifyPage;
        cell.detailTextLabel.text = m_trafficLimitModeInfo;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void) showItemListForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    //__________
    NSString * selectedItem = nil;
    NSString * itemListTitle = nil;
    SEL selector = nil;
    NSMutableArray * items = [[NSMutableArray alloc] init];
    if (section == 1)
    {
        for (NSInteger i = 1; i <= 28; i++)
        {
            [items addObject:[NSString stringWithFormat:@"%d",i]];
        }
        itemListTitle = Localization_Traffic_Day_Title_ModifyPage;
        selectedItem = m_dayInfo;
        selector = @selector(restartChanged_Callback:);
    }
    else
    {
        [items addObject:Localization_Traffic_NoLimit];
        [items addObject:Localization_Traffic_DownloadLimit];
        [items addObject:Localization_Traffic_BothLimit];
        itemListTitle = Localization_Traffic_LimitMode_Title_ForSelectItemPage;
        selectedItem = m_trafficLimitModeInfo;
        selector = @selector(limitModeChanged_Callback:);
    }
    GenieItemListController * itemlist = [[GenieItemListController alloc] initWithItmeList:items andSelectedItem:selectedItem];
    [itemlist setModifyCallback:self callback:selector];
    itemlist.title = itemListTitle;
    [items release];
    [self.navigationController pushViewController:itemlist animated:YES];
    [itemlist release];
}

- (void) restartChanged_Callback:(NSString*) day
{
    [m_dayInfo release];
    m_dayInfo = [day retain];
    m_isInfoChanged = YES;
}

- (void) limitModeChanged_Callback:(NSString*) limitMode
{
    [m_trafficLimitModeInfo release];
    m_trafficLimitModeInfo = [limitMode retain];
    m_isInfoChanged = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(backgroundTouchUpInside)];
    if( (indexPath.section == 1 && indexPath.row == 1) || indexPath.section == 2)
    {
        [self showItemListForIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark  control event action
- (void) callbackKeyBoard
{
    [m_minuteTextField resignFirstResponder];
    [m_hourTextField resignFirstResponder];
    [m_monthLimitTextField resignFirstResponder];
}
- (void) backgroundTouchUpInside
{
    [self callbackKeyBoard];
}

- (void) saveBtnPress
{
    [self callbackKeyBoard];
    [self doRightBtnTouchedUpInsideFunction];
}

- (void) setTrafficMeterCallback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        GenieTrafficData * data = [GenieHelper getTrafficData];
        data.limitMode = m_trafficLimitModeInfo;
        data.monthlyMeter = m_monthLimitTextField.text;
        data.day = m_dayInfo;
        data.hour = m_hourTextField.text;
        data.minute = m_minuteTextField.text;
        if (m_target)//设置成功后，修改上级的GUI
        {
            [m_target performSelector:m_selector];
            [m_target release];
            m_target = nil;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
