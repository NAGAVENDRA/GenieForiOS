//
//  GPanelView.m
//  GPanelView
//
//  Created by cs Siteview on 12-3-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPanelView.h"

#define  PanelWindowColor                           [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4]
#define  DefaultCancelBtnTitle                      @"Cancel"

#define  DeviceIs_iPad                                 1
#define  DeviceIs_iPod_iPhone                          2

//////////////////////////////

@implementation GPanelView
@synthesize delegate = m_delegate;
@synthesize dataSource = m_dataSource;
@synthesize rows = m_numberOfRows;
@synthesize centerOffsetY = m_contentViewCenterOffsetY;
static NSInteger deviceType = DeviceIs_iPod_iPhone;

static NSString * panel_bg_img = nil;
static NSString * panel_btn_down_img = nil;
static NSString * panel_btn_highlight_img = nil;
static NSString * panel_btn_Normal_img = nil;
////////-------
static CGFloat  PanelContentViewHeaderHeight               = 0;//contains shadow and title height
static CGFloat  PanelContentViewFoolerHeight               = 0;//contains shadow  except btn height
static CGFloat  PanelContentViewVisibleWidth               = 0;
static CGFloat  PanelContentViewShadowX                    = 0;

static CGFloat  PanelContentViewDefaultBodyHeight          = 0;
static CGFloat  PanelDefaultRowHeight                      = 0;
static CGFloat  PanelTitleLabelHeight                      = 0;

static CGFloat  PanelBtnHeight                             = 0;
static CGFloat  PanelBtnSpaceX                             = 0;
static CGFloat  PanelBtnCenterOffsetY                      = 0;

static CGFloat  PanelTitleCenterOffSetY                    = 0;
static CGFloat  PanelTitleLabFontSize                      = 0;
static CGFloat  PanleBtnFontSize                           = 0; 

- (void) checkDeviceType
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        deviceType = DeviceIs_iPad;
        panel_bg_img = @"panel_bg_ipad";
        panel_btn_down_img = @"panel_btn_down_ipad";
        panel_btn_highlight_img = @"panel_btn_highlight_ipad";
        panel_btn_Normal_img = @"panel_btn_normal_ipad";
        
        PanelContentViewHeaderHeight               = 68;
        PanelContentViewFoolerHeight               = 29;
        PanelContentViewVisibleWidth               = 420;
        PanelContentViewShadowX                    = 18;
        PanelContentViewDefaultBodyHeight          = 65;
        PanelDefaultRowHeight                      = 60;
        PanelTitleLabelHeight                      = 46;
        PanelBtnHeight                             = 45;
        PanelBtnSpaceX                             = 14;
        PanelBtnCenterOffsetY                      = 12;
        PanelTitleCenterOffSetY                    = 10;
        PanelTitleLabFontSize                      = 30;
        PanleBtnFontSize                           = 30;
    }
    else
    {
        deviceType = DeviceIs_iPod_iPhone;
        panel_bg_img = @"panel_bg";
        panel_btn_down_img = @"panel_btn_down";
        panel_btn_highlight_img = @"panel_btn_highlight";
        panel_btn_Normal_img = @"panel_btn_normal";

        PanelContentViewHeaderHeight               = 52;
        PanelContentViewFoolerHeight               = 30;
        PanelContentViewVisibleWidth               = 284;
        PanelContentViewShadowX                    = 18;
        PanelContentViewDefaultBodyHeight          = 50;
        PanelDefaultRowHeight                      = 40;
        PanelTitleLabelHeight                      = 30;
        PanelBtnHeight                             = 30;
        PanelBtnSpaceX                             = 10;
        PanelBtnCenterOffsetY                      = 6.5;
        PanelTitleCenterOffSetY                    = 5;
        PanelTitleLabFontSize                      = 20;
        PanleBtnFontSize                           = 18;
    }
}

- (id) initWithTitle:(NSString*) title highLightBtn:(NSString*) cancelBtn anotherBtn:(NSString*)anotherBtn
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        [self checkDeviceType];
        m_dataSource = nil;
        m_delegate = nil;
        m_window = [[UIWindow alloc] init];
        m_bgView = [[UIControl alloc] init];
        m_contentView = [[GPImageView alloc] init];
        m_contentViewWidth = PanelContentViewVisibleWidth + PanelContentViewShadowX*2;
        m_heightForRow = PanelDefaultRowHeight;
        m_contentViewCenterOffsetY = 0;
        m_numberOfRows = 0;
        m_titleLabel = nil;
        if (title)
        {
            m_titleLabel = [[UILabel alloc] init];
            m_titleLabel.text = title;
        }
        m_cancelBtnTitle = [cancelBtn retain];
        m_anotheBbtnTitle = [anotherBtn retain];
        m_buttons = [[NSMutableArray alloc] init];
        [self initializationView];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_buttons release];
    [m_anotheBbtnTitle release];
    [m_cancelBtnTitle release];
    [m_titleLabel release];
    [m_contentView release];
    [m_bgView release];
    [m_window release];
    [super dealloc];
}
- (void) adjustPanelView
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect rec;
    CGAffineTransform transform;
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(M_PI);
            rec = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            rec = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            rec = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
            break;
        default:
            transform = CGAffineTransformMakeRotation(0);
            rec = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
            break;
    }
    m_bgView.transform = transform;
    m_bgView.bounds = rec;
    m_bgView.center = m_window.center;
    m_contentView.center = CGPointMake(rec.size.width/2, rec.size.height/2+m_contentViewCenterOffsetY);
}

- (void) initializationView
{
    [m_window setFrame:[UIScreen mainScreen].bounds]; 
    [m_window setBackgroundColor:[UIColor clearColor]];
    m_window.windowLevel = UIWindowLevelNormal;
    [m_window addSubview:m_bgView];
    m_contentView.userInteractionEnabled = YES;
    m_contentView.backgroundColor = [UIColor clearColor];
    [m_bgView addSubview:m_contentView];
    if (m_titleLabel)
    {
        m_titleLabel.textColor = [UIColor whiteColor];
        m_titleLabel.font = [UIFont boldSystemFontOfSize:PanelTitleLabFontSize];
        m_titleLabel.textAlignment = UITextAlignmentCenter;
        m_titleLabel.backgroundColor = [UIColor clearColor];
    }
    UIButton * btn = nil;
    if (m_cancelBtnTitle)
    {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:DefaultCancelBtnTitle forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:PanleBtnFontSize];
        btn.tag = 0;
        [btn setTitle:m_cancelBtnTitle forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:panel_btn_highlight_img] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:panel_btn_down_img] forState:UIControlStateSelected];
        [m_buttons addObject:btn];
    }
    if (m_anotheBbtnTitle)
    {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 1;
        [btn setTitle:m_anotheBbtnTitle forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:PanleBtnFontSize];
        [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:panel_btn_Normal_img] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:panel_btn_down_img] forState:UIControlStateSelected];
        [m_buttons addObject:btn];
    }
}

- (UIImage*) creatImageWithFrame:(CGRect)frame
{
    CGFloat scale = 0;
    if (deviceType == DeviceIs_iPod_iPhone)
    {
        scale = 2.0;
    }
    else
    {
        scale = 1.0;
    }
    UIImage * resultImg = nil;
    UIImage * img = [UIImage imageNamed:panel_bg_img];
    CGSize contentSize = CGSizeMake(frame.size.width*scale, frame.size.height*scale);
    UIGraphicsBeginImageContext(contentSize);
    CGFloat header_height = PanelContentViewHeaderHeight*scale;
    CGFloat footer_height = PanelContentViewFoolerHeight*scale;
    CGFloat body_height_rec = contentSize.height - header_height - footer_height;//绘图上下文的矩形框中 绘制body的高度
    CGFloat body_height_img = img.size.height - header_height - footer_height;//图片body部分的高度
    
    CGImageRef resourceImg = img.CGImage;
    CGImageRef headerImg = CGImageCreateWithImageInRect(resourceImg, CGRectMake(0, 0, contentSize.width, header_height));
    CGImageRef bodyImg = CGImageCreateWithImageInRect(resourceImg, CGRectMake(0, header_height , contentSize.width, body_height_img));
    CGImageRef footerImg = CGImageCreateWithImageInRect(resourceImg, CGRectMake(0, header_height+body_height_img, contentSize.width, footer_height));
    [[UIImage imageWithCGImage:headerImg] drawInRect:CGRectMake(0, 0, contentSize.width, header_height)];
    [[UIImage imageWithCGImage:bodyImg] drawInRect:CGRectMake(0, header_height, contentSize.width, body_height_rec)];
    [[UIImage imageWithCGImage:footerImg] drawInRect:CGRectMake(0, contentSize.height-footer_height, contentSize.width, footer_height)];
    CGImageRelease(footerImg);
    CGImageRelease(bodyImg);
    CGImageRelease(headerImg);
    resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImg;
}
- (void) layoutView
{
    CGFloat y = PanelContentViewHeaderHeight;
    if (m_titleLabel) 
    {
        [m_titleLabel setFrame:CGRectMake(0, 0, PanelContentViewVisibleWidth, PanelTitleLabelHeight)];
        m_titleLabel.center = CGPointMake(m_contentViewWidth/2, y-PanelTitleLabelHeight/2+PanelTitleCenterOffSetY);
        [m_contentView addSubview:m_titleLabel];
        y += PanelTitleCenterOffSetY;
    }
    else
    {
        //当没有title时，将cell向上移
        y -= PanelTitleLabelHeight;
        y += PanelTitleCenterOffSetY;
    }
    GPanelViewCell* cell = nil;
    m_numberOfRows = [m_dataSource numberOfRowsInPanelView:self];
    for (NSInteger i = 0; i < m_numberOfRows; i++)
    {
        cell = [m_dataSource panelView:self cellForRowAtIndex:i];
        if ([m_delegate respondsToSelector:@selector(panelView:heightForRowIndex:)])
        {
            m_heightForRow = [m_delegate panelView:self heightForRowIndex:i];
        }
        cell.frame = CGRectMake(0, PanelContentViewShadowX, PanelContentViewVisibleWidth, m_heightForRow);
        cell.center = CGPointMake(m_contentViewWidth/2, y+m_heightForRow/2);
        cell.backgroundColor = [UIColor clearColor];
        [m_contentView addSubview:cell];
        y += m_heightForRow;
    }
    NSInteger btnNumber = [m_buttons count];
    if (btnNumber != 0)
    {
        CGFloat btnWidth = (PanelContentViewVisibleWidth - (btnNumber+1)*PanelBtnSpaceX)/btnNumber;
        for (NSInteger i = 0; i < btnNumber; i++)
        {
            UIButton * btn = (UIButton*)[m_buttons objectAtIndex:i];
            btn.frame = CGRectMake(0, 0, btnWidth, PanelBtnHeight);
            btn.center = CGPointMake( PanelContentViewShadowX+(btnNumber-i)*PanelBtnSpaceX+(btnNumber-i-1+0.5)*btnWidth, y+PanelBtnHeight/2+PanelBtnCenterOffsetY);
            [m_contentView addSubview:btn];
        }
        y += PanelBtnHeight+PanelContentViewFoolerHeight;
    }
    else
    {
        y += PanelContentViewFoolerHeight;
    }
    if (y - PanelContentViewFoolerHeight - PanelContentViewHeaderHeight <= 0)
    {
        y += PanelContentViewDefaultBodyHeight;
    }
    m_contentViewHeight = y;
    [m_contentView setFrame:CGRectMake(0, 0, m_contentViewWidth, m_contentViewHeight)];
    m_contentView.image = [self creatImageWithFrame:m_contentView.frame];
    [self adjustPanelView];
}

- (void) show
{
    if ([m_delegate respondsToSelector:@selector(willPresentPanelView:)])
    {
        [m_delegate willPresentPanelView:self];
    }
    [self layoutView];
    [self setEnabled:YES];
    [m_window makeKeyAndVisible];
    //animation
    m_contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    m_window.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2 animations:^
    {
        m_contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        m_window.backgroundColor = PanelWindowColor;
    } completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.1 animations:^
        {
            m_contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished)
        {
            [UIView animateWithDuration:0.05 animations:^
            {
                m_contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            }];
        }];
    }];
}
- (void) dismiss
{
    [m_window setHidden:YES];
    for (UIView * v in [m_contentView subviews])
    {
        [v removeFromSuperview];
    }
}

- (void) btnPress:(UIButton*)btn
{
    if ([m_delegate respondsToSelector:@selector(panelView:clickBtnWithBtnIndex:)])
    {
        [m_delegate panelView:self clickBtnWithBtnIndex:btn.tag];
    }
    //[self dismiss]; 需要从外部主动dismiss
}
- (void)deviceOrientationChanged
{
    UIInterfaceOrientation stausBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (stausBarOrientation == deviceOrientation)
    {
        [UIView animateWithDuration:0.4 animations:^
         {
             [self adjustPanelView];
         }];
    }
}
- (void) addTarget:(id) target selector:(SEL) selector forEvent:(UIControlEvents)event
{
    [m_contentView addTarget:target withSelector:selector];
    [m_bgView addTarget:target action:selector forControlEvents:event];
}
/*- (CGPoint) center
{
    return m_contentView.center;
}*/
- (CGRect) frame
{
    return CGRectMake(0, 0, m_contentViewWidth, m_contentViewHeight);
}
- (void) setEnabled:(BOOL)enabled
{
    for (id v in [self subViews])
    {
        if ([v respondsToSelector:@selector(setEnabled:)])
        {
            [v setEnabled:enabled];
        }
    }
}
- (UIView*) backgroundView
{
    return m_bgView;
}
- (UIButton*) buttonAtIndex:(NSInteger)index
{
    return [m_buttons objectAtIndex:index];
}
- (NSArray*) subViews
{
    return [m_contentView subviews];
}
- (void) addSubView:(UIView*)view
{
    [m_contentView addSubview:view];
}
@end


@implementation GPanelViewCell
@synthesize keyLabel = m_keyLabel;
@synthesize valueView = m_valueView;
- (id) init
{
    self = [super init];
    if (self)
    {
        m_keyLabel = [[UILabel alloc] init];
        m_keyLabel.backgroundColor = [UIColor clearColor];
        m_keyLabel.textColor = [UIColor whiteColor];
        m_keyLabel.numberOfLines = 1;
        m_keyLabel.textAlignment = UITextAlignmentRight;
        m_valueView_bg = [[UIView alloc] init];
        m_valueView_bg.backgroundColor = [UIColor clearColor];
        [self addSubview:m_keyLabel];
        [self addSubview:m_valueView_bg];
        m_valueView = nil;
    }
    return self;
}

- (void)dealloc
{
    [m_valueView_bg release];
    [m_valueView release];
    [m_keyLabel release];
    [super dealloc];
}

#define scale_w    0.9
#define scale_h    0.8
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    m_keyLabel.frame = CGRectMake(0, 0, width/2*scale_w, height*scale_h);
    m_keyLabel.center = CGPointMake(width/4, height/2);
    m_valueView_bg.frame = CGRectMake(0, 0, width/2*scale_w, height*scale_h);
    m_valueView_bg.center = CGPointMake(width*3/4, height/2);
    CGFloat w = m_valueView_bg.frame.size.width;
    CGFloat h = m_valueView_bg.frame.size.height;
    m_valueView .frame = CGRectMake(0, 0, w, h);
    m_valueView.center = CGPointMake(m_valueView.center.x, h/2);//有些控件的尺寸是固定的。所以X坐标不能用w/2代替
    [m_valueView_bg addSubview:m_valueView];
}

- (void) setEnabled:(BOOL)enabled
{
    [m_keyLabel setEnabled:enabled];
    if ([m_valueView respondsToSelector:@selector(setEnabled:)])
    {
        [(id)m_valueView setEnabled:enabled];
    }
}
@end

@implementation GPImageView
- (id) init
{
    self = [super init];
    if (self)
    {
        m_target = nil;
        m_selector = nil;
    }
    return self;
}

- (void) addTarget:(id)target withSelector:(SEL)selector
{
    m_target = target;
    m_selector = selector;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_target performSelector:m_selector];
}

@end


