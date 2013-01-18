//
//  GenieTrafficGraphCellView.m
//  GenieiPad
//
//  Created by cs Siteview on 12-4-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieTrafficGraphCellView.h"
#import "GGraphView.h"


@implementation GenieTrafficGraphCellView

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_grahpView = [[GGraphView alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [m_grahpView release];
    [super dealloc];
}

- (void) setGraphSubject:(NSString*)subject font:(UIFont *)font color:(UIColor *)color
{
    [m_grahpView setSubject:subject Font:font color:color];
}
- (void) setGraphUnitTitle:(NSString*)unit font:(UIFont *)font color:(UIColor *)color
{
    [m_grahpView setUnitTitle:unit Font:font color:color];
}
- (void) cleanGraph
{
    [m_grahpView cleanGraphView];
}
- (void) addGraphCategory:(NSString*)title valueList:(NSNumber*)v1,...
{
    NSMutableArray * categoryData = [[NSMutableArray alloc] init];
    NSNumber* var;
    va_list arg_list;
    if (v1)
    {
        [categoryData addObject:v1];
        va_start(arg_list, v1);
        while ((var = va_arg(arg_list, NSNumber*)))
        {
            [categoryData addObject:var];
        }
    }
    va_end(arg_list);
    [m_grahpView addCategory:title values:categoryData];
    [categoryData release];
}
- (void) setGraphCategoryTitleFont:(UIFont*)font color:(UIColor*)color
{
    [m_grahpView setCategoryTitleFont:font color:color];
}
- (void) setGraphColumnTextFont:(UIFont*)font color:(UIColor*)color
{
    [m_grahpView setColumnTextFont:font color:color];
}
- (void) setGraphCoordianteUnitTextFont:(UIFont*)font color:(UIColor*)color
{
    [m_grahpView setCoordinateUnitFont:font color:color];
}
- (void) setGraphAdditionalInfoTitles:(NSArray*)titles colors:(NSArray*)colors
{
    [m_grahpView setAdditionalInfoTitles:titles colors:colors];
}
- (void) setGraphAdditionalInfoFont:(UIFont*) font color:(UIColor*)color
{
    [m_grahpView setAdditionalInfoFont:font color:color];
}

#pragma mark --
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect r = self.backgroundView.frame;
    if (![m_grahpView.superview isEqual:self.backgroundView])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self.backgroundView addSubview:m_grahpView];
    }
    m_grahpView.frame = CGRectMake(0, 0, r.size.width*0.95, r.size.height*0.95);
    m_grahpView.center = CGPointMake(r.size.width/2, r.size.height/2);
    [m_grahpView setNeedsDisplay];
}

@end
