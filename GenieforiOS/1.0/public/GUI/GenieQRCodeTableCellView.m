//
//  GenieQRCodeTableCellView.m
//  GenieiPad
//
//  Created by cs Siteview on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieQRCodeTableCellView.h"
#import "GenieQRCode.h"


@implementation GenieQRCodeTableCellView

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier ssid:(NSString*)ssid password:(NSString*)password
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_ssid = [ssid retain];
        m_password = [password retain];
    }
    return self;
}

- (void) dealloc
{
    [m_ssid release];
    [m_password release];
    [super dealloc];
}

#ifdef __GENIE_IPHONE__
#define QRCODEIMGWIDTH 180
#define PROMPTLABELHEIGHT  28
#else
#define QRCODEIMGWIDTH 300
#define PROMPTLABELHEIGHT  30
#endif
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect r = self.backgroundView.frame;
    UIView * v = [[UIView alloc] initWithFrame:r];
    v.backgroundColor = [UIColor clearColor];
    self.backgroundView = v;
    [v release];
    
    UIImageView * qrcodeImg = [[UIImageView alloc] initWithImage:[GenieQRcode GetQRcodeImageWithSSID:m_ssid password:m_password imageSize:QRCODEIMGWIDTH]];
    qrcodeImg.frame = CGRectMake(0, 0, QRCODEIMGWIDTH, QRCODEIMGWIDTH);
    
    UILabel * promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, r.size.width, PROMPTLABELHEIGHT)];
#ifdef __GENIE_IPHONE__
    promptLabel.font = [UIFont systemFontOfSize:12];
#endif
    promptLabel.text = @"Scan this with mobile NETGEAR genie to join the network.";
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textAlignment = UITextAlignmentCenter;
    promptLabel.numberOfLines = 0;
    
    for (UIView * v in [self.backgroundView subviews])
    {
        [v removeFromSuperview];
    }
    
    [self.backgroundView addSubview:promptLabel];
    promptLabel.center = CGPointMake(r.size.width/2, PROMPTLABELHEIGHT/2);
    [promptLabel release];
    
    [self.backgroundView addSubview:qrcodeImg];
    qrcodeImg.center = CGPointMake(r.size.width/2, r.size.height/2+PROMPTLABELHEIGHT/2);
    [qrcodeImg release];
}

@end
