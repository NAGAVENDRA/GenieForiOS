//
//  GenieGraphView.m
//  GCustomCell
//
//  Created by cs Siteview on 12-4-11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "GraphViewProtected.h"


#define Default_Font                        [UIFont systemFontOfSize:10]
#define Default_Text_Color                  [UIColor blackColor]
@implementation GraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        m_columnCategorys = [[NSMutableArray alloc] init];
        m_subject = nil;
        m_unitTitle = nil;
        m_additionalTitles = nil;
        m_additionalColors = nil;
        m_categoryTitle_font = [Default_Font retain];
        m_columnText_font = [Default_Font retain];
        m_subject_font = [Default_Font retain];
        m_unitTitle_font = [Default_Font retain];
        m_coordinate_unit_font = [Default_Font retain];
        m_additional_title_font = [Default_Font retain];
        m_categoryTitle_color = [Default_Text_Color retain];
        m_columnText_color = [Default_Text_Color retain];
        m_subject_color = [Default_Text_Color retain];
        m_unitTitle_color = [Default_Text_Color retain];
        m_coordinate_unit_color = [Default_Text_Color retain];
        m_additional_title_color = [Default_Text_Color retain];
    }
    return self;
}
- (id) init
{
    return  [self initWithFrame:CGRectZero];
}

- (void)dealloc
{
    [m_columnText_color release];
    [m_additional_title_color release];
    [m_coordinate_unit_color release];
    [m_unitTitle_color release];
    [m_subject_color release];
    [m_categoryTitle_color release];
    [m_additional_title_font release];
    [m_coordinate_unit_font release];
    [m_unitTitle_font release];
    [m_subject_font release];
    [m_columnText_font release];
    [m_categoryTitle_font release];
    
    [m_additionalTitles release];
    [m_additionalColors release];
    [m_columnCategorys release];
    [m_unitTitle release];
    [m_subject release];
    [super dealloc];
}
- (void) cleanGraphView
{
    [m_columnCategorys removeAllObjects];
}
- (void) setSubject:(NSString*)subject Font:(UIFont*)font color:(UIColor*)color
{
    [m_subject release];
    m_subject = [subject retain];
    if (font)
    {
        [m_subject_font release];
        m_subject_font = [font retain];
    }
    if (color)
    {
        [m_subject_color release];
        m_subject_color = [color retain];
    }
}
- (void) setUnitTitle:(NSString*)title Font:(UIFont*)font color:(UIColor*)color
{
    [m_unitTitle release];
    m_unitTitle = [title retain];
    if (font)
    {
        [m_unitTitle_font release];
        m_unitTitle_font = [font retain];
    }
    if (color)
    {
        [m_unitTitle_color release];
        m_unitTitle_color = [color retain];
    }
}

- (void) addCategory:(NSString*)title valueList:(NSNumber*)v1,...
{
    NSMutableArray * columnData = [[NSMutableArray alloc] init];
    [columnData addObject:title];
    NSNumber* var;
    va_list arg_list;
    if (v1)
    {
        [columnData addObject:v1];
        va_start(arg_list, v1);
        while ((var = va_arg(arg_list, NSNumber*)))
        {
            [columnData addObject:var];
        }
    }
    va_end(arg_list);
    [m_columnCategorys addObject:columnData];
    [columnData release];
}
- (void) addCategory:(NSString*)title values:(NSArray*)values
{
    NSMutableArray * arr = [[NSMutableArray alloc] initWithObjects:title, nil];
    [arr addObjectsFromArray:values];
    [m_columnCategorys addObject:arr];
    [arr release];
}

- (void) setCategoryTitleFont:(UIFont*)font color:(UIColor*)color
{
    if (font)
    {
        [m_categoryTitle_font release];
        m_categoryTitle_font = [font retain];
    }
    if (color)
    {
        [m_categoryTitle_color release];
        m_categoryTitle_color = [color retain];
    }
}
- (void) setColumnTextFont:(UIFont*)font color:(UIColor*)color
{
    if (font)
    {
        [m_columnText_font release];
        m_columnText_font = [font retain];
    }
    if (color)
    {
        [m_columnText_color release];
        m_columnText_color = [color retain];
    }
}
- (void) setCoordinateUnitFont:(UIFont*)font color:(UIColor*)color
{
    if (font)
    {
        [m_coordinate_unit_font release];
        m_coordinate_unit_font = [font retain];
    }
    if (color)
    {
        [m_coordinate_unit_color release];
        m_coordinate_unit_color = [color retain];
    }
}

- (void) setAdditionalInfoTitles:(NSArray*)titles colors:(NSArray*)colors;
{
    [m_additionalTitles release];
    m_additionalTitles = [titles retain];
    [m_additionalColors release];
    m_additionalColors = [colors retain];
}

- (void) setAdditionalInfoFont:(UIFont*)font color:(UIColor *)color
{
    if (font)
    {
        [m_additional_title_font release];
        m_additional_title_font = [font retain];
    }
    if (color)
    {
        [m_additional_title_color release];
        m_additional_title_color = [color retain];
    }
}


#pragma mark ---
- (void) drawColumnDiagram:(CGRect)coordinateArea valueToHightScale:(CGFloat)scale
{
    return;
}
- (CGFloat) getHighestColumnScaleValue
{
    return 1;
}
 - (void)drawRect:(CGRect)rect
 {
     [super drawRect:rect];
     CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextSetShouldAntialias(context, YES);
     CGContextSetShouldSmoothFonts(context, YES);
     CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
     CGContextFillRect(context, rect);
     CGFloat subject_text_h = [m_subject sizeWithFont:m_subject_font].height;
     CGFloat unitTitle_text_h = [m_unitTitle sizeWithFont:m_unitTitle_font].height;
     CGFloat additional_text_h = [@"hy" sizeWithFont:m_additional_title_font].height;
     CGFloat additional_infoWidth = 0;
     NSInteger additionalInfoCount = [m_additionalTitles count];
     for (NSInteger i = 0; i < additionalInfoCount; i++)
     {
         additional_infoWidth += additional_text_h*2;//颜色框+space
         additional_infoWidth += [(NSString*)[m_additionalTitles objectAtIndex:i] sizeWithFont:m_additional_title_font].width;
     }
     [self drawSubject:CGPointMake(self.frame.size.width/2, subject_text_h/2)];
     [self drawUnitTitle:CGPointMake(unitTitle_text_h/2, self.frame.size.height/2)];
     [self drawCoordinateGraphWithRect:CGRectMake(unitTitle_text_h*3/2, subject_text_h*3/2, self.frame.size.width - unitTitle_text_h*3, self.frame.size.height - subject_text_h*3)];
     [self drawAdditionalInfo:CGRectMake(self.frame.size.width - additional_infoWidth, self.frame.size.height - additional_text_h*3/2, additional_text_h, additional_text_h) onOneLine:YES];
 }

@end
