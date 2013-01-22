//
//  GenieTrafficInfoController.m
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
/***
 **
 ***/
@interface NSString(GTraffic)
- (NSString*) stringByTrimmingCharactersInCharaccterSet:(NSCharacterSet*)string;
@end
@implementation NSString(GTraffic)
- (NSString*) stringByTrimmingCharactersInCharaccterSet:(NSCharacterSet*)set
{
    if (!set || ![self length])
    {
        return self;
    }
    else
    {
        NSMutableString * str = [[NSMutableString alloc] init];
        [str setString:@""];
        for (NSInteger i = 0; i < [self length]; i++)
        {
            char ch = [self characterAtIndex:i];
            if ([set characterIsMember:ch])
            {
                continue;
            }
            [str appendFormat:@"%c",ch];
        }
        return [str autorelease];
    }
}
@end

#import "GenieTrafficInfoController.h"
#import "GenieHelper.h"
#import "GenieTrafficModifyController.h"
#import "GenieTrafficGraphCellView.h"


#define SectionNumberForStatistics                      4
#define SectionNumberForNoStatisticsData                1

#define SectionForSwitcher                              0
#define SectionForControlInfo                           1
#define SectionForTotalStatisticsGraph                  2
#define SectionForAvgStatisticsGraph                    3


#define RowNumberForControlInfo                         4
#define RowForMonthlyLimit                              0
#define RowForRestartDay                                1
#define RowForRestartTime                               2
#define RowForLimitMode                                 3

#define RowNumberForStatisticsGraph                     1
#define HeightScaleOfStatisticsGraph                    0.8f//相对于整个tableview的高度的比例   

@implementation GenieTrafficInfoController

- (id) init
{
    self = [super init];
    if (self)
    {
        m_tableview = nil;
        m_switcher = nil;
        m_controlData = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_tableview release];
    [m_switcher release];
    [m_controlData release];
    [[GenieHelper getTrafficData] clear];
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
    self.title = Localization_Traffic_InfoPage_Title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    [rightBtnItem release];
    
    m_switcher = [[UISwitch alloc] init];
    [m_switcher addTarget:self action:@selector(switcherChanged) forControlEvents:UIControlEventValueChanged];
    m_controlData = [[NSMutableArray alloc] init];
    
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetTrafficInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(loadTrafficMeterInfoCallback:) waitMessage:Local_WaitForLoadTrafficInfo timeout:Genie_Get_Traffic_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
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
    if (indexPath.section == SectionForControlInfo)
    {
        GenieTrafficModifyController * modifyer = [[GenieTrafficModifyController alloc] init];
        [modifyer setModifyFinished:self callback:@selector(modifyFinished_Callback)];
        [self.navigationController pushViewController:modifyer animated:YES];
        [modifyer release];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([m_controlData count] == 0)
    {
        return 0;
    }
    else if ([m_controlData count] == 1)
    {
        return SectionNumberForNoStatisticsData;
    }
    return SectionNumberForStatistics;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > SectionForControlInfo)
    {
        return m_tableview.frame.size.height*HeightScaleOfStatisticsGraph;
    }
    return 44;//standart height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SectionForSwitcher)
    {
        return 1;
    }
    if (section == SectionForControlInfo)
    {
        return RowNumberForControlInfo;
    }
    return RowNumberForStatisticsGraph;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = [NSString stringWithFormat:@"cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        if (indexPath.section > SectionForControlInfo)
        {
            GenieTrafficGraphCellView * cellView = nil;
            UIColor * graphTextColor = [UIColor blackColor];
            UIColor * colorForUpload = [UIColor grayColor];
            UIColor * colorForDownload = [UIColor colorWithRed:154/255.0f green:153/255.0f blue:255/255.0f alpha:1.0f];
            NSString * graphViewSubject = nil;
#ifdef __GENIE_IPHONE__
            CGFloat subject_font_size = 18;
            CGFloat unitTitle_font_size = 12;
            CGFloat colorPromptText_font_size = 12;
            CGFloat categoryTitle_font_size = 8;
            CGFloat columnText_font_size = 8;
            CGFloat coordinateUnitText_font_size = 9;
#else
            CGFloat subject_font_size = 18;
            CGFloat unitTitle_font_size = 14;
            CGFloat colorPromptText_font_size = 13;
            CGFloat categoryTitle_font_size = 12;
            CGFloat columnText_font_size = 11;
            CGFloat coordinateUnitText_font_size = 11;
#endif
            if (indexPath.section == SectionForTotalStatisticsGraph)
            {
                graphViewSubject = Localization_Traffic_TotalInfoDiagram_Subject;
            }
            else if (indexPath.section == SectionForAvgStatisticsGraph)
            {
                graphViewSubject = Localization_Traffic_AverageInfoDiagram_Subject;
            }
            cell = [[[GenieTrafficGraphCellView alloc] initWithReuseIdentifier:cellID] autorelease];
            cellView = (GenieTrafficGraphCellView*)cell;
            [cellView setGraphSubject:graphViewSubject font:[UIFont boldSystemFontOfSize:subject_font_size] color:[UIColor blackColor]];
            [cellView setGraphUnitTitle:Localization_Traffic_DiagramUnitTitle font:[UIFont systemFontOfSize:unitTitle_font_size] color:[UIColor blackColor]];
            [cellView setGraphAdditionalInfoTitles:[NSArray arrayWithObjects:Localization_Traffic_Prompt_Download, Localization_Traffic_Prompt_Upload, nil] colors:[NSArray arrayWithObjects:colorForDownload, colorForUpload, nil]];
            [cellView setGraphAdditionalInfoFont:[UIFont systemFontOfSize:colorPromptText_font_size] color:graphTextColor];
            [cellView setGraphCategoryTitleFont:[UIFont systemFontOfSize:categoryTitle_font_size] color:graphTextColor];
            [cellView setGraphColumnTextFont:[UIFont systemFontOfSize:columnText_font_size] color:graphTextColor];
            [cellView setGraphCoordianteUnitTextFont:[UIFont systemFontOfSize:coordinateUnitText_font_size] color:graphTextColor];
        }
        else
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
        }
    }
    [self customCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark -----
- (void) showViewWithOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        self.view.backgroundColor = BACKGROUNDCOLOR;
        m_tableview.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenWidth, iOSDeviceScreenHeight-iOSStatusBarHeight-Navi_Bar_Height_Portrait);
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        self.view.backgroundColor = BACKGROUNDCOLOR;
        m_tableview.frame = CGRectMake(CGZero, CGZero, iOSDeviceScreenHeight, iOSDeviceScreenWidth-iOSStatusBarHeight-Navi_Bar_Height_Landscape);
    }
}

typedef enum 
{
    ParseTotalData = 0,
    ParseAvgData
}ParseType;
- (NSNumber*) parseTrafficMeterStatistics:(NSString*)meter type:(ParseType)type
{
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@","];
    if (![meter rangeOfString:@"/"].length)
    {
        return [NSNumber numberWithFloat:[[meter stringByTrimmingCharactersInCharaccterSet:set] floatValue]];
    }
    else
    {
        NSInteger index = 0;
        if (type == ParseAvgData)
        {
            index = 1;
        }
        NSArray * arr = [meter componentsSeparatedByString:@"/"];
        NSString * totalInfo = [(NSString*)[arr objectAtIndex:index] stringByTrimmingCharactersInCharaccterSet:set]; 
        return [NSNumber numberWithFloat:[totalInfo floatValue]];
    }
}


- (void) customGraphCell:(GenieTrafficGraphCellView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    [cell cleanGraph];//
    GenieTrafficData * data = [GenieHelper getTrafficData];
    if (section == SectionForTotalStatisticsGraph)
    {
        ParseType type = ParseTotalData;
        [cell addGraphCategory:Localization_Traffic_Category_Today valueList:[self parseTrafficMeterStatistics:data.todayStatistics.download type:type],    [self parseTrafficMeterStatistics:data.todayStatistics.upload type:type],nil];
        [cell addGraphCategory:Localization_Traffic_Category_Yesterday valueList:[self parseTrafficMeterStatistics:data.yesterdayStatistics.download type:type],[self parseTrafficMeterStatistics:data.yesterdayStatistics.upload type:type], nil];
        [cell addGraphCategory:Localization_Traffic_Category_ThisWeek valueList:[self parseTrafficMeterStatistics:data.weekStatistics.download type:type],[self parseTrafficMeterStatistics:data.weekStatistics.upload type:type], nil];
        [cell addGraphCategory:Localization_Traffic_Category_ThisMonth valueList:[self parseTrafficMeterStatistics:data.monthStatistics.download type:type],[self parseTrafficMeterStatistics:data.monthStatistics.upload type:type], nil];
        [cell addGraphCategory:Localization_Traffic_Category_LastMonth valueList:[self parseTrafficMeterStatistics:data.lastMonthStatistics.download type:type],[self parseTrafficMeterStatistics:data.lastMonthStatistics.upload type:type], nil];
    }
    else if (section == SectionForAvgStatisticsGraph)
    {
        ParseType type = ParseAvgData;
        [cell addGraphCategory:Localization_Traffic_Category_ThisWeek valueList:[self parseTrafficMeterStatistics:data.weekStatistics.download type:type],[self parseTrafficMeterStatistics:data.weekStatistics.upload type:type], nil];
        [cell addGraphCategory:Localization_Traffic_Category_ThisMonth valueList:[self parseTrafficMeterStatistics:data.monthStatistics.download type:type],[self parseTrafficMeterStatistics:data.monthStatistics.upload type:type], nil];
        [cell addGraphCategory:Localization_Traffic_Category_LastMonth valueList:[self parseTrafficMeterStatistics:data.lastMonthStatistics.download type:type],[self parseTrafficMeterStatistics:data.lastMonthStatistics.upload type:type], nil];
    }
    [cell setNeedsDisplay];
    cell.selectionStyle = UITableViewCellEditingStyleNone;
}
- (void) customCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > SectionForControlInfo)
    {
        [self customGraphCell:(GenieTrafficGraphCellView*)cell atIndexPath:indexPath];
        return;
    }
    NSInteger sec = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    NSString * keyString = nil;
    NSString * valueString = nil;
    NSInteger elemsNumInFirstSection = 1;
    if (sec == SectionForSwitcher)
    {
        keyString = Localization_Traffic_Switcher_Title;
        valueString = nil;
        GenieFunctionEnableStatus s = [[m_controlData objectAtIndex:0] intValue];
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
    else if(sec == SectionForControlInfo)
    {
        valueString = [m_controlData objectAtIndex:rowIndex+elemsNumInFirstSection];
        switch (rowIndex)
        {
            case 0:
                keyString = Localization_Traffic_MonthlyLimit_Title_InfoPage;
                break;
            case 1:
                keyString = Localization_Traffic_Day_Title_InfoPage;
                break;
            case 2:
                keyString = Localization_Traffic_Time_Title_InfoPage;
                break;
            case 3:
                keyString = Localization_Traffic_LimitMode_Title_InfoPage;
                break;
            default:
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = keyString;
    cell.detailTextLabel.text = valueString;
    cell.selectionStyle = (sec == SectionForControlInfo) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
}

- (void) switcherChanged
{
    if (m_switcher.on)
    {
        //open
        [GenieHelper configForSetProcessOrLPCProcessStart];
        GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startOpenTrafficMeter];
        [GPWaitDialog show:op withTarget:self selector:@selector(openTrafficMeterCallback:) waitMessage:Local_WaitForSetTrafficInfo timeout:Genie_Set_Traffic_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
    }
    else
    {
        //close
        [GenieHelper configForSetProcessOrLPCProcessStart];
        GTAsyncOp* op = [[GenieHelper shareGenieBusinessHelper] startCloseTrafficMeter];
        [GPWaitDialog show:op withTarget:self selector:@selector(clossTrafficMeterCallback:) waitMessage:Local_WaitForSetTrafficInfo timeout:Genie_Set_Traffic_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
    }
}

- (void) refresh
{
    GTAsyncOp * op = [[GenieHelper shareGenieBusinessHelper] startGetTrafficInfo];
    [GPWaitDialog show:op withTarget:self selector:@selector(refreshTrafficMeterInfoCallback:) waitMessage:Local_WaitForRefreshTrafficInfo timeout:Genie_Get_Traffic_Process_Timeout cancelBtn:Localization_Cancel needCountDown:NO waitTillTimeout:NO];
}

#pragma mark reload GUI
- (NSString*) stringForRestartHour:(NSInteger) hour minute:(NSInteger) min
{
    return [NSString stringWithFormat:@"%d:%d",hour,min];
}

- (void) reloadGUI:(GenieFunctionEnableStatus) status
{
    [m_controlData removeAllObjects];
    GenieTrafficData * data = [GenieHelper getTrafficData];
    if (status == GenieFunctionNotSupport)
    {
        return;
    }
    if (status == GenieFunctionNotEnbaled)
    {
        [m_controlData addObject:[NSNumber numberWithInt:data.enable]];
    }
    else
    {
        [m_controlData addObject:[NSNumber numberWithInt:data.enable]];
        if (data.monthlyMeter)
        {
            [m_controlData addObject:data.monthlyMeter];
        }
        else
        {
            [m_controlData addObject:Genie_N_A];
        }
        if (data.day)
        {
            [m_controlData addObject:data.day];
        }
        else
        {
            [m_controlData addObject:Genie_N_A];
        }
        if (data.minute && data.hour)
        {
            [m_controlData addObject:[NSString stringWithFormat:@"%@:%@",data.hour,data.minute]];
        }
        else
        {
            [m_controlData addObject:Genie_N_A];
        }
        if (data.limitMode)
        {
            [m_controlData addObject:data.limitMode];
        }
        else
        {
            [m_controlData addObject:Genie_N_A];
        }
    }
    [m_tableview reloadData];
}

#pragma mark ----Modify Traffic Callback
- (void) modifyFinished_Callback
{
    [self reloadGUI:GenieFunctionEnabled];//
}
#pragma mark Traffic Meter xml label
static NSString * Traffic_NewTrafficMeterEnable = @"NewTrafficMeterEnable";
static NSString * Traffic_NewControlOption = @"NewControlOption";
static NSString * Traffic_NewMonthlyLimit = @"NewMonthlyLimit";
static NSString * Traffic_RestartHour = @"RestartHour";
static NSString * Traffic_RestartMinute = @"RestartMinute";
static NSString * Traffic_RestartDay = @"RestartDay";

static NSString * Traffic_NewTodayConnectionTime = @"NewTodayConnectionTime";
static NSString * Traffic_NewTodayUpload = @"NewTodayUpload";
static NSString * Traffic_NewTodayDownload = @"NewTodayDownload";

static NSString * Traffic_NewYesterdayConnectionTime = @"NewYesterdayConnectionTime";
static NSString * Traffic_NewYesterdayUpload = @"NewYesterdayUpload";
static NSString * Traffic_NewYesterdayDownload = @"NewYesterdayDownload";

static NSString * Traffic_NewWeekConnectionTime = @"NewWeekConnectionTime";
static NSString * Traffic_NewWeekUpload = @"NewWeekUpload";
static NSString * Traffic_NewWeekDownload = @"NewWeekDownload";

static NSString * Traffic_NewMonthConnectionTime = @"NewMonthConnectionTime";
static NSString * Traffic_NewMonthUpload = @"NewMonthUpload";
static NSString * Traffic_NewMonthDownload = @"NewMonthDownload";

static NSString * Traffic_NewLastMonthConnectionTime = @"NewLastMonthConnectionTime";
static NSString * Traffic_NewLastMonthUpload = @"NewLastMonthUpload";
static NSString * Traffic_NewLastMonthDownload = @"NewLastMonthDownload";
#pragma mark business process callback
- (void) processAsyncOpResult:(NSDictionary*)dic
{
    GeniePrint(@"getTrafficMeterInfoProcess",dic);
    GenieTrafficData * data = [[GenieTrafficData alloc] init];
    NSString * enableStatus = [dic valueForKey:Traffic_NewTrafficMeterEnable];
    if ([enableStatus isEqualToString:@"0"])
    {
        data.enable = GenieFunctionNotEnbaled;
    }
    else if ([enableStatus isEqualToString:@"1"])
    {
        data.enable = GenieFunctionEnabled;
        
        data.todayStatistics.connTime = [dic valueForKey:Traffic_NewTodayConnectionTime];
        data.todayStatistics.upload = [dic valueForKey:Traffic_NewTodayUpload];
        data.todayStatistics.download = [dic valueForKey:Traffic_NewTodayDownload];
        
        data.yesterdayStatistics.connTime = [dic valueForKey:Traffic_NewYesterdayConnectionTime];
        data.yesterdayStatistics.upload = [dic valueForKey:Traffic_NewYesterdayUpload];
        data.yesterdayStatistics.download = [dic valueForKey:Traffic_NewYesterdayDownload];
        
        data.weekStatistics.connTime = [dic valueForKey:Traffic_NewWeekConnectionTime];
        data.weekStatistics.upload = [dic valueForKey:Traffic_NewWeekUpload];
        data.weekStatistics.download = [dic valueForKey:Traffic_NewWeekDownload];
        
        data.monthStatistics.connTime = [dic valueForKey:Traffic_NewMonthConnectionTime];
        data.monthStatistics.upload = [dic valueForKey:Traffic_NewMonthUpload];
        data.monthStatistics.download = [dic valueForKey:Traffic_NewMonthDownload];
        
        data.lastMonthStatistics.connTime = [dic valueForKey:Traffic_NewLastMonthConnectionTime];
        data.lastMonthStatistics.upload = [dic valueForKey:Traffic_NewLastMonthUpload];
        data.lastMonthStatistics.download = [dic valueForKey:Traffic_NewLastMonthDownload];
        
        NSString * tmpStr = [dic valueForKey:Traffic_NewControlOption];
        if ([[tmpStr lowercaseString] isEqualToString:[Genie_Traffic_Option_NoLimit lowercaseString]])
        {
            data.limitMode = Localization_Traffic_NoLimit;
        }
        else if ([[tmpStr lowercaseString] isEqualToString:[Genie_Traffic_Option_DownloadLimit lowercaseString]])
        {
            data.limitMode = Localization_Traffic_DownloadLimit;
        }
        else
        {
            data.limitMode = Localization_Traffic_BothLimit;
        }
        
        data.monthlyMeter = [dic valueForKey:Traffic_NewMonthlyLimit];
        data.day = [dic valueForKey:Traffic_RestartDay];
        data.hour = [dic valueForKey:Traffic_RestartHour];
        data.minute = [dic valueForKey:Traffic_RestartMinute];
    }
    else//== @"2"
    {
        data.enable = GenieFunctionNotSupport;
    }
    [GenieHelper setTrafficData:data];
    [data release];
}
- (void) loadTrafficMeterInfoCallback:(GenieCallbackObj*) obj
{
    //do something
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        GenieFunctionEnableStatus s = [GenieHelper getTrafficData].enable;
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
            [GenieHelper generalProcessGenieError:err];;
        }
    }
}

- (void) refreshTrafficMeterInfoCallback:(GenieCallbackObj*)obj
{
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        GenieFunctionEnableStatus s = [GenieHelper getTrafficData].enable;
        if (s != GenieFunctionNotSupport)
        {
            [self reloadGUI:s];
        }
    }
}

- (void) clossTrafficMeterCallback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        GenieTrafficData * data = [[GenieTrafficData alloc] init];
        data.enable = GenieFunctionNotEnbaled;
        [GenieHelper setTrafficData:data];
        [self reloadGUI:data.enable];
        [data release];
    }
    else
    {
        m_switcher.on = !m_switcher.on;
    }
}
- (void) openTrafficMeterCallback:(GenieCallbackObj*)obj
{
    [GenieHelper resetConfigForSetProcessOrLPCProcessFinish];
    GenieErrorType err = GenieErrorNoError;
    [GenieHelper generalProcessAsyncOpCallback:obj withErrorCode:&err];
    if (err == GenieErrorNoError)
    {
        [self processAsyncOpResult:[(GTAsyncOp*)obj.userInfo result]];
        GenieFunctionEnableStatus s = [GenieHelper getTrafficData].enable;
        if (s != GenieFunctionNotSupport)
        {
            [self reloadGUI:s];
        }
        else
        {
            m_switcher.on = !m_switcher.on;
        }
    }
    else
    {
        m_switcher.on = !m_switcher.on;
    }
}

@end
