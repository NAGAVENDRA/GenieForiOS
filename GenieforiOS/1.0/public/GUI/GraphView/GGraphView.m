//
//  GenieGraphView.m
//  GCustomCell
//
//  Created by cs Siteview on 12-4-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GGraphView.h"


@implementation GGraphView

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (CGFloat) getHighestColumnScaleValue
{
    CGFloat height = 0;
    CGFloat value = 10.0f;
    NSInteger count = [m_columnCategorys count];
    for (NSInteger i = 0; i < count; i++)
    {
        CGFloat v = 0.0f;
        NSArray * category = [m_columnCategorys objectAtIndex:i];
        for (NSNumber* number in category)
        {
            //此段算法根据特定的需要而改变
            CGFloat x = [number floatValue];
            if (x < 0)
            {
                x = 0;
            }
            v += x;
        }
        height = height < v ? v : height;
    }
    if(height < 10.0f)
    {
        value = 10.0f;
    }
    else if(height < 50.0f)
    {
        value = 50.0f;
    }
    else if(height < 100.0f)
    {
        value = 100.0f;
    }
    else
    {
        int temp3 = (int)height;
        int temp4 = 0;
        int n = 0;
        bool flag = false;
        while(true)
        {
            temp4 = temp3%10;
            if(temp4 > 0)
            {
                flag = true;
            }
            temp3 = temp3/10;					
            n++;
            if(temp3 >= 10 && temp3 < 100)
            {
                break;
            }
        }
        if(flag)
        {
            value = (temp3+1)*(int)(pow(10, n));
        }
        else
        {
            value = temp3*((int)(pow(10, n)));
        }
    }
    return value;
}
- (void) drawColumnDiagram:(CGRect)coordinateArea valueToHightScale:(CGFloat)scale
{
    NSInteger categoryCount = [m_columnCategorys count];
    NSInteger colorsCount = [m_additionalColors count];//颜色数目与每个column的cagegory的个数不一定相同   每个column的category的数目也可以不一样
    CGFloat unitWidth = coordinateArea.size.width/(2*categoryCount + 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsFontSmoothing(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    for (NSInteger i = 0; i < categoryCount; i++)
    {
        NSArray * categoryData = [m_columnCategorys objectAtIndex:i];
        NSInteger columnSectionCount = [categoryData count];
        CGFloat columnRelativeHight_didDrown = 0;//column已绘制部分的高度
        NSString * categoryTitle  = nil;
        for (NSInteger j = 0; j < columnSectionCount; j++)
        {
            if (j == 0)//数组的第一个元素存储的是category的Title
            {
                categoryTitle = [categoryData objectAtIndex:0];
                continue;
            }
            //draw rectangle
            NSInteger colorIndex = j-1 < colorsCount ? j-1 : (j-1)%colorsCount;
            float value = [[categoryData objectAtIndex:j] floatValue]; 
            if (value < 0) value = 0;//对负数进行处理
            CGFloat relativeHight = value * scale;//column当前需要绘制的部分的高度
            CGContextSetFillColorWithColor(context, [(UIColor*)[m_additionalColors objectAtIndex:colorIndex] CGColor]);
            CGRect rect = CGRectMake(coordinateArea.origin.x + (2*i+1)*unitWidth, coordinateArea.origin.y + coordinateArea.size.height - columnRelativeHight_didDrown - relativeHight, unitWidth, relativeHight);
            CGContextAddRect(context, rect);
            CGContextFillRect(context, rect);
            //draw text
            NSString * text = [NSString stringWithFormat:@"%.2f",value];
            while([text characterAtIndex:[text length] - 1] == '0')
            {
                text = [text substringToIndex:[text length] - 1];
                if ([text characterAtIndex:[text length] - 1] == '.')
                {
                    text = [text substringToIndex:[text length] - 1];
                    break;
                }
            }
            CGSize textSize = [text sizeWithFont:m_columnText_font];
            CGContextSetFillColorWithColor(context, m_columnText_color.CGColor);
            CGContextSelectFont(context, [m_columnText_font.fontName UTF8String], m_columnText_font.pointSize, kCGEncodingMacRoman);
            CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1)); 
            CGContextSetTextDrawingMode(context, kCGTextFill);
            CGFloat textOffset = 2;
            CGFloat h = rect.origin.y + rect.size.height/2 - textOffset;
            if (j == columnSectionCount-1)
            {
                h = rect.origin.y - textSize.height*3/4 - textOffset;
            }
            CGContextShowTextAtPoint(context, rect.origin.x + rect.size.width/2 - textSize.width/2, h, [text UTF8String], [text length]);
            //
            columnRelativeHight_didDrown += relativeHight;
        }
        //draw category title
        CGContextSetFillColorWithColor(context, m_categoryTitle_color.CGColor);
        CGContextSelectFont(context, [m_categoryTitle_font.fontName UTF8String], m_categoryTitle_font.pointSize, kCGEncodingMacRoman);
        CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1)); 
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGSize textSize = [categoryTitle sizeWithFont:m_categoryTitle_font];
        //当title的文本太长时，根据空格分行
        BOOL flag = textSize.width - 2*unitWidth >= 0;
        NSRange range = [categoryTitle rangeOfString:@" "];//根据空格换行
        if (flag && range.length)
        {
            NSString * text1 = [categoryTitle substringWithRange:NSMakeRange(0, range.location)];
            NSString * text2 = [categoryTitle substringWithRange:NSMakeRange(range.location + range.length, [categoryTitle length]- range.length - range.location)];
            CGSize size1 = [text1 sizeWithFont:m_categoryTitle_font];
            CGSize size2 = [text2 sizeWithFont:m_categoryTitle_font];
            CGContextShowTextAtPoint(context, coordinateArea.origin.x + (2*i+1.5)*unitWidth - size1.width/2, coordinateArea.origin.y + coordinateArea.size.height + size1.height, [text1 UTF8String], [text1 length]);
            CGContextShowTextAtPoint(context, coordinateArea.origin.x + (2*i+1.5)*unitWidth - size2.width/2, coordinateArea.origin.y + coordinateArea.size.height + size1.height*2/3 + size2.height, [text2 UTF8String], [text2 length]);
        }
        else
        {
            CGContextShowTextAtPoint(context, coordinateArea.origin.x + (2*i+1.5)*unitWidth - textSize.width/2, coordinateArea.origin.y + coordinateArea.size.height + textSize.height, [categoryTitle UTF8String], [categoryTitle length]);//
        }
    }
    CGContextRestoreGState(context);
}

@end
