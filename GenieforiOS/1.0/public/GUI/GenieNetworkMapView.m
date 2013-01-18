//
//  GenieNetworkMapView.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieNetworkMapView.h"
#import "GenieHelper.h"

#ifdef __GENIE_IPHONE__        
#define DeviceIconSize                          45
#define RouterIconSize                          65
#define LabelTextMaxLength                      72
#define LableTextFontSize                       9
#define LabelTextDistanceFromIcon               0
#define WirelessSignalIconSize                  16
#define mR_aSpace                      (LabelTextMaxLength/2 + 4.0f)
#define mR_bSpace                      (DeviceIconSize/2 + 10.0f)
#define Center_Translate_Y                      8

#else
#define DeviceIconSize                          72
#define RouterIconSize                          120
#define LabelTextMaxLength                      140
#define LableTextFontSize                       16
#define LabelTextDistanceFromIcon               0
#define WirelessSignalIconSize                  30
#define mR_aSpace                      (LabelTextMaxLength/2 + 20.0f)
#define mR_bSpace                      (DeviceIconSize/2 + 30.0f)
#define Center_Translate_Y                      20
#endif

#define InternetOnlineColor                                  [UIColor greenColor]
#define InternetOfflineColor                                 [UIColor redColor]
#define LocalDeviceConnLineColor                                     [UIColor greenColor]
#define OrdinaryDeviceConnLineColor                                  [UIColor blueColor]
#define FullSignalStrength                                   100
#define Center_X                                             self.frame.size.width/2
#define Center_Y                                             (self.frame.size.height/2 - Center_Translate_Y)
@implementation GenieNetworkMapView
@synthesize devices = m_devices;
static GenieBlockType g_enableBlock_status = GenieBlockNotSupport;
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_target = nil;
        m_selector = nil;
        m_devices = nil;
        m_points = nil;
        self.opaque = NO;
        g_enableBlock_status = [GenieHelper getMapData].blockEnabled;
        
        m_touchedBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 175, 185)];
        m_touchedBackgroundView.image = [UIImage imageNamed:@"networkmap_touched_highlight_background"];
        [self addSubview:m_touchedBackgroundView];
        m_touchedBackgroundView.hidden = YES;
    }
    return self;
}

- (void)dealloc
{
    [m_devices release];
    [m_points release];
    [m_touchedBackgroundView release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    [self getPointsForMap];
    [self drawInternetIcon];
    [self drawDevices];
    [self drawRouter];
}
#pragma mark---------
- (void) addTarget:(id) target selector:(SEL) selector
{
    m_target = target;
    m_selector = selector;
}

- (void) getPointsForMap
{
    m_points = [[NSMutableArray alloc] init];
    NSInteger deviceCount = [m_devices count];
    float xPoint = 0.0f;
    float yPoint = 0.0f;
    //点的偏移量
    float x_offset = Center_X;
    float y_offset = Center_Y;
    //长短轴
    float mR_a = self.frame.size.width/2 - mR_aSpace;
    float mR_b = self.frame.size.height/2 - mR_bSpace;

    NSInteger pointCount = deviceCount + 1;
    double radian = 2*M_PI/pointCount;//为Internet Icon生成绘图点
    for (int p = 0; p < pointCount; p++)
    {
        xPoint = mR_a * cos(-radian*p);
        yPoint = mR_b * sin(-radian*p);
        [m_points addObject:NSStringFromCGPoint(CGPointMake(xPoint+x_offset, yPoint+y_offset))];
    }
}
- (void) drawInternetIcon
{
    UIImage * img = nil; 
    GenieNetWorkStatus internetStatus = [GenieHelper getRouterInfo].internetStatus;
    UIColor * color = nil;
    if (internetStatus == GenieNetWorkOffline)
    {
        img = [UIImage imageNamed:@"internet_offline_icon"];
        color = InternetOfflineColor;
    }
    else
    {
        img = [UIImage imageNamed:@"internet_online_icon"];
        color = InternetOnlineColor;
    }
    CGPoint point = CGPointFromString([m_points objectAtIndex:0]);
    [self drawLineFromCenterToPoint:point Color:color Dottedline:NO];
    CGRect rec = CGRectMake(point.x-DeviceIconSize/2, point.y-DeviceIconSize/2, DeviceIconSize, DeviceIconSize);
    [img drawInRect:rec];
    [self drawLabelRelativeCenter:CGPointMake(point.x, point.y+DeviceIconSize/2) withText:Localization_NetworkMap_Internet_Lable_Text];
}
- (void) drawBlockIconInRect:(CGRect)rec
{
    UIImage * icon = [UIImage imageNamed:@"block_icon"];
    [icon drawInRect:rec];
}
- (void) drawDevices
{
    NSInteger deviceCount = [m_devices count];
    GenieDeviceInfo * device = nil;
    for (NSInteger i = 0; i < deviceCount; i ++)
    {
        device = [m_devices objectAtIndex:i];
        UIImage * img = [UIImage imageNamed:device.icon];
        CGPoint point = CGPointFromString([m_points objectAtIndex:i+1]);
        UIColor * color = nil;
        
        //对于smart network 第一个设备没有特殊的意义，不需要使用特别的颜色来绘制
        if (i == 0 && ![GenieHelper isSmartNetwork]) //本机设备
        {
            color = LocalDeviceConnLineColor;
        }
        else
        {
            color = OrdinaryDeviceConnLineColor;
        }
        BOOL needDottedLine = YES;
        if (device.connectMode == GenieConnectWired)
        {
            needDottedLine = NO;
        }
        [self drawLineFromCenterToPoint:point Color:color Dottedline:needDottedLine];
        if (needDottedLine) 
        {
            NSInteger signal = FullSignalStrength;
            if (device.signalStrength)
            {
                signal = [device.signalStrength integerValue];
            }
            [self drawWirelessIconAtCenter:CGPointMake((point.x+Center_X)/2, (point.y+Center_Y)/2) signalStrength:signal];
        }
        CGRect rec = CGRectMake(point.x-DeviceIconSize/2, point.y-DeviceIconSize/2, DeviceIconSize, DeviceIconSize);
        [img drawInRect:rec];
        if (g_enableBlock_status == GenieBlockEnable && device.blocked)
        {
            [self drawBlockIconInRect:rec];
        }
        [self drawLabelRelativeCenter:CGPointMake(point.x, point.y+DeviceIconSize/2) withText:device.name];
    }
}

- (void) drawRouter
{
    NSString * routerName = [GenieHelper getRouterInfo].modelName;
    NSString * routerIcon = [GenieHelper getRouterInfo].icon;
    if (!routerIcon)
    {
        routerIcon = @"router_default_icon";
    }
    UIImage * image = [UIImage imageNamed:routerIcon];
    CGPoint point = CGPointMake(Center_X, Center_Y);
    CGRect rec = CGRectMake(point.x-RouterIconSize/2, point.y-RouterIconSize/2, RouterIconSize, RouterIconSize);
    [image drawInRect:rec];
	[self drawLabelRelativeCenter:CGPointMake(point.x, point.y+RouterIconSize/2) withText:routerName];
}

- (void) drawWirelessIconAtCenter:(CGPoint)center signalStrength:(NSInteger) signal
{
    UIImage * img = nil;
    if (signal < 20)
    {
        img = [UIImage imageNamed:@"signal_level_1"];
    }
    else if (signal >= 20 && signal < 50)
    {
        img = [UIImage imageNamed:@"signal_level_2"];
    }
    else if (signal >= 50 && signal < 70)
    {
        img = [UIImage imageNamed:@"signal_level_3"];
    }
    else
    {
        img = [UIImage imageNamed:@"signal_level_4"];
    }
    [img drawInRect:CGRectMake(center.x-WirelessSignalIconSize/2, center.y-WirelessSignalIconSize/2, WirelessSignalIconSize, WirelessSignalIconSize)];
}
- (void) drawLineFromCenterToPoint:(CGPoint)point Color:(UIColor*) color Dottedline:(BOOL) dottedLine
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    if (!dottedLine)
    {
        CGContextSetLineDash(context, 0, NULL, 0);
    }
    else
    {
#ifdef __GENIE_IPHONE__
        float arr[2] = {2,2};
#else
        float arr[2] = {5,5};
#endif
        CGContextSetLineDash(context, 0, arr, 2);
    }
    CGContextMoveToPoint(context, Center_X, Center_Y);//draw line from this point
    CGContextAddLineToPoint(context, point.x, point.y);
    CGContextStrokePath(context);
}
- (void) drawLabelRelativeCenter:(CGPoint)center withText:(NSString*) text;
{
    CGSize s = [text sizeWithFont:[UIFont systemFontOfSize:LableTextFontSize]];
    while (s.width > LabelTextMaxLength)
    {
        text = [NSString stringWithFormat:@"%@...",[text substringToIndex:[text length]-4]];
        s = [text sizeWithFont:[UIFont systemFontOfSize:LableTextFontSize]];
    }
    [text drawInRect:CGRectMake(center.x-s.width/2, center.y+LabelTextDistanceFromIcon, s.width, s.height) withFont:[UIFont systemFontOfSize:LableTextFontSize]];
}

#define mark touch events
- (void) showHighlightBackground:(CGPoint)point
{
    m_touchedBackgroundView.center = point;
    m_touchedBackgroundView.hidden = NO;
}

- (void) hideHighlightBackground
{
    m_touchedBackgroundView.hidden = YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGPoint point;
    CGFloat squareSize = 0.0f;
    id device = nil;
    for (int p = 0; p<[m_points count]; p++)
    {
        if (p == 0)
        {
            point = CGPointMake(Center_X, Center_Y);
            squareSize = RouterIconSize;
            device = [GenieHelper getRouterInfo];
        }
        else
        {
            point= CGPointFromString([m_points objectAtIndex:p]);
            squareSize = DeviceIconSize;
            device = [m_devices objectAtIndex:p-1];
        }
        if (pt.x >= point.x-squareSize/2 && pt.x <= point.x+squareSize/2 &&
            pt.y >= point.y-squareSize/2 && pt.y <= point.y+squareSize/2)
        {
            if (p == 0 && [GenieHelper isSmartNetwork])
            {
                return;//在smart network 条件下，不需要显示路由器的信息
            }
            [self showHighlightBackground:point];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(hideHighlightBackground) userInfo:nil repeats:NO];
            [m_target performSelector:m_selector withObject:device];//2011.10.18
            return ;
        }
    }
}

@end
