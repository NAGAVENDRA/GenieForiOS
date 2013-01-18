//
//  GenieNetworkDeviceTypeListView.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieNetworkDeviceTypeListView.h"

#define SectionForList       0
#define StatusBarHight       20.0f

@implementation NSString (Me)
- (NSString*)xorNSString 
{
    NSMutableString * tstr = [[[NSMutableString alloc] init] autorelease];
    for(int i = 0; i < [self length]; i++)
    {
        NSString * s = [self substringWithRange:NSMakeRange(i, 1)];
        if (NSOrderedDescending == [s compare:@"Z"])
        {//小写
            [tstr appendString:[s uppercaseString]];
        }
        else
        {//大写
            [tstr appendString:[s lowercaseString]];
        }
    }
    return tstr;
}
- (NSComparisonResult)compareByMe:(NSString*)str 
{
    return [[self xorNSString] compare:[str xorNSString]];
}
@end



@implementation GenieNetworkDeviceTypeListView

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        m_bg = [[UIImageView alloc] init];
        m_bg.userInteractionEnabled = YES;
        m_bg_title = [[UIImageView alloc] init];
        [m_bg addSubview:m_bg_title];
        [self addSubview:m_bg];
        m_listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        m_listView.delegate = self;
        m_listView.dataSource = self;
        [m_bg addSubview:m_listView];
        m_device = nil;
        m_dataMap = [[GenieHelper readDeviceTypeString2DeviceIconMapFromXML] retain];
        m_types = [[[m_dataMap allKeys] sortedArrayUsingSelector:@selector(compareByMe:)] retain];
        m_selectedItem = nil;
        //__________
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        m_selectedItemIndex = 0;
        m_currentOrientation = UIInterfaceOrientationPortrait;
    }
    return  self;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_selectedItem release];
    [m_types release];
    [m_dataMap release];
    [m_device release];
    [m_listView release];
    [m_bg_title release];
    [m_bg release];
    [super dealloc];
}

- (void) adjustview
{
    m_currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
#ifdef __GENIE_IPHONE__
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect rec;
    CGFloat bg_title_height = 25;
    CGFloat bg_footer_height = 5;
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            rec = CGRectMake(0, 0, 270, 340);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rec = CGRectMake(0, 0, 270, 240);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rec = CGRectMake(0, 0, 270, 240);
            break;
        default:
            rec = CGRectMake(0, 0, 270, 340);
            break;
    }
#else
    CGRect rec;
    CGFloat bg_title_height = 50;
    CGFloat bg_footer_height = 10;
    rec = CGRectMake(0, 0, 500, 620);
#endif
    CGFloat viewCenterOffsetY = 10.0f;//listview 中心位置略向下偏移，以免遮挡住导航条
    if (self.superview)
    {
        CGRect superBounds = self.superview.bounds;
        self.bounds = rec;
        self.center = CGPointMake(superBounds.size.width/2, superBounds.size.height/2+StatusBarHight/2+viewCenterOffsetY);
        m_bg.frame = self.frame;
        m_bg.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        UIImage * bgImg = [UIImage imageNamed:@"network_devicetypeview_bg"];
        m_bg.image = bgImg;
        m_bg_title.image = [UIImage imageNamed:@"network_devicetypeview_bg_title"];
        m_bg_title.frame = CGRectMake(0, 0, rec.size.width, bg_title_height);
        m_listView.frame = CGRectMake(0, 0, m_bg.frame.size.width, m_bg.frame.size.height-bg_title_height-bg_footer_height);
        m_listView.center = CGPointMake(m_bg.frame.size.width/2, m_bg.frame.size.height/2+bg_title_height/2-bg_footer_height/2);
        [m_listView reloadData];
        [m_listView selectRowAtIndexPath:[NSIndexPath indexPathForRow:m_selectedItemIndex inSection:SectionForList] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }

}

- (void) showForDevice:(GenieDeviceInfo*)device selectedItem:(NSString*) selectedItem
{
    [m_device release];
    m_device = [device retain];
    [m_selectedItem release];
    m_selectedItem = [selectedItem retain];
    m_selectedItemIndex = [m_types indexOfObject:m_selectedItem];
    [self adjustview];
    [self setNeedsDisplay];
    self.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [UIView animateWithDuration:0.2f animations:^
     {
         [self setHidden:NO]; 
         self.transform = CGAffineTransformIdentity;
     }];
}
- (void) dismiss
{
    if (self.hidden)
    {
        return;
    }
    [self setHidden:YES];
    [m_listView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionForList] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void) setFinishCallback:(id)target selector:(SEL)selector
{
    m_target = target;
    m_selector = selector;
}

- (void) deviceOrientationChanged
{
    UIInterfaceOrientation stausBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (stausBarOrientation == m_currentOrientation)//
    {
        return;
    }
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (stausBarOrientation == deviceOrientation)
    {
        [self adjustview];
        [self setNeedsDisplay];
    }
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_types count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSInteger index = [indexPath row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if(m_selectedItemIndex == index)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [m_types objectAtIndex:index];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    NSString * imgStr = cell.textLabel.text;
    UIImage * img = [UIImage imageNamed:[m_dataMap objectForKey:imgStr]];
    UIImage * icon = nil;
    UIGraphicsBeginImageContext(CGSizeMake(35.0f, 35.0f));
    CGRect rec = CGRectMake(0, 0, 35.0f, 35.0f);
    [img drawInRect:rec];
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#ifdef  __GENIE_IPHONE__
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
#endif
    cell.imageView.image = icon;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath row];
    NSString * typeStr = [m_types objectAtIndex:index];
    m_device.typeString = typeStr;
    m_device.icon = [m_dataMap objectForKey:typeStr];
    [m_target performSelector:m_selector withObject:typeStr];
    [self dismiss];
}
@end
