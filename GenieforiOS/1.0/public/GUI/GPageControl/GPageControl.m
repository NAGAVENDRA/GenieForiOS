//
//  GPageControl.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPageControl.h"


#define Default_Normal_Dot  @"normal_dot_icon"
#define Default_Highlighted_Dot  @"highlighted_dot_icon"
@implementation GPageControl

- (id) init
{
    self = [super init];
    if (self)
    {
        m_normalDot = [[UIImage imageNamed:Default_Normal_Dot] retain];
        m_highLightedDot = [[UIImage imageNamed:Default_Highlighted_Dot] retain];
        [self addObserver:self forKeyPath:@"self.currentPage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"self.numberOfPages" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"self.numberOfPages"];
    [self removeObserver:self forKeyPath:@"self.currentPage"];
    [m_normalDot release];
    [m_highLightedDot release];
    [super dealloc];
}

- (void) setNormalDotIcon:(UIImage*)normalDot
{
    if (normalDot)
    {
        [m_normalDot release];
        m_normalDot = [normalDot retain];
    }
}
- (void) setHighLightedDot:(UIImage*)highLightedDot
{
    if (highLightedDot)
    {
        [m_highLightedDot release];
        m_highLightedDot = [highLightedDot retain];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    for (NSInteger i = 0; i < [self.subviews count]; i++)
    {
        UIImageView * dot = [self.subviews objectAtIndex:i];
        dot.image = (self.currentPage ==i) ? m_highLightedDot : m_normalDot;
    }
}
@end
