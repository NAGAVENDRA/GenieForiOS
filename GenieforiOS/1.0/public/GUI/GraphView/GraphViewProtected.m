//
//  GraphViewProtected.m
//  GCustomCell
//
//  Created by cs Siteview on 12-4-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphViewProtected.h"


#define DefaultColor                [UIColor blackColor]
#define DashLineColor               [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f]
@implementation GraphView (GraphViewProtected)

#pragma draw diagram
- (void) drawSubject:(CGPoint)center
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, m_subject_color.CGColor);
    CGContextSelectFont(context, [m_subject_font.fontName UTF8String], m_subject_font.pointSize, kCGEncodingMacRoman);
    CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1)); 
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGSize textSize = [m_subject sizeWithFont:m_subject_font];
#if 1
    CGContextShowTextAtPoint(context, center.x - textSize.width/2, center.y + textSize.height/2, [m_subject UTF8String], [m_subject length]);
#else
    [m_subject drawAtPoint:CGPointMake(center.x - textSize.width/2, center.y - textSize.height/2) withFont:m_subject_font];
#endif
    CGContextRestoreGState(context);
}

- (void) drawUnitTitle:(CGPoint)center
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, m_unitTitle_color.CGColor);
    CGContextSelectFont(context, [m_unitTitle_font.fontName UTF8String], m_unitTitle_font.pointSize, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill); 
#if 1//纵轴单位字符 垂直显示
    CGContextSetTextMatrix(context,  CGAffineTransformRotate(CGAffineTransformScale(CGAffineTransformIdentity, 1, -1),M_PI_2));
    CGSize textSize = [m_unitTitle sizeWithFont:m_unitTitle_font];
    CGContextShowTextAtPoint(context, center.x + textSize.height/2, center.y + textSize.width/2, [m_unitTitle UTF8String], [m_unitTitle length]);
#else//纵轴单位字符 水平显示
    CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1));
    CGSize textSize = [m_unitTitle sizeWithFont:m_unitTitle_font];
    CGContextShowTextAtPoint(context, center.x - textSize.width/2,center.y + textSize.height/2, [m_unitTitle UTF8String], [m_unitTitle length]);
#endif
    CGContextRestoreGState(context);
}
- (void) drawAdditionalInfo:(CGRect)rec onOneLine:(BOOL)oneLine
{
    CGFloat lengthOfAdditionalInfoDidDrawn = 0;//记录已经绘制的附加颜色框和提示文字信息的总长度，当将所有的附加信息绘制到同一行时有用 
    CGSize colorRectSize;
    CGFloat spaceBetweenColorRectAndTitle = 0;
    CGFloat spaceBetweenLines = [@"hy" sizeWithFont:m_additional_title_font].height;//space for mutable lines
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    NSInteger additionalInfoCount = [m_additionalColors count] <= [m_additionalTitles count] ? [m_additionalColors count] : [m_additionalTitles count];
    for (NSInteger i = 0; i < additionalInfoCount; i++)
    {
        NSString * additionalText = [m_additionalTitles objectAtIndex:i];
        UIColor * additionalColor = (UIColor*)[m_additionalColors objectAtIndex:i];
        CGSize textSize = [additionalText sizeWithFont:m_additional_title_font];
        
        //draw additional color rectangle
        CGRect colorRec;
        colorRectSize = CGSizeMake(textSize.height/2, textSize.height/2);
        spaceBetweenColorRectAndTitle = colorRectSize.width;
        if (oneLine)
        {
            colorRec = CGRectMake(rec.origin.x + lengthOfAdditionalInfoDidDrawn, rec.origin.y + rec.size.height/2 - colorRectSize.height/2, colorRectSize.width, colorRectSize.height);
        }
        else
        {
            colorRec = CGRectMake(rec.origin.x, rec.origin.y + i*(textSize.height+spaceBetweenLines), colorRectSize.width, colorRectSize.height);
        }
        CGContextSetFillColorWithColor(context,  additionalColor.CGColor);
        CGContextAddRect(context, colorRec);
        CGContextFillRect(context, colorRec);
        
        //draw additional title
        CGContextSetFillColorWithColor(context, m_additional_title_color.CGColor);
        CGContextSelectFont(context, [m_additional_title_font.fontName UTF8String], m_additional_title_font.pointSize, kCGEncodingMacRoman);
        CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1));
        CGContextSetTextDrawingMode(context, kCGTextFill);
#if 1
        CGContextShowTextAtPoint(context, colorRec.origin.x + colorRectSize.width + spaceBetweenColorRectAndTitle, colorRec.origin.y + colorRectSize.height, [additionalText UTF8String], [additionalText length]);
#else
        [additionalText drawAtPoint:CGPointMake(colorRec.origin.x + colorRectSize.width + spaceBetweenColorRectAndTitle, colorRec.origin.y - colorRectSize.height) withFont:m_additional_title_font];
#endif
        lengthOfAdditionalInfoDidDrawn += colorRectSize.width + spaceBetweenColorRectAndTitle + textSize.width + spaceBetweenColorRectAndTitle*2;
    }
    CGContextRestoreGState(context);
}

- (void) drawCoordinateGraphWithRect:(CGRect)rectangle//绘制坐标系
{
    const NSInteger NumberOfScaleValue = 5;//刻度数目
    CGFloat SpaceBetweenScaleValueAndLine_Y = [@"0" sizeWithFont:m_coordinate_unit_font].width;//刻度字符串与坐标系之间的间距   一个字符宽
    CGFloat maxColumnScaleValue = [self getHighestColumnScaleValue];
    if (maxColumnScaleValue <= 0)
    {
        maxColumnScaleValue = 1.0f;
    }
    unsigned int unitValue = ceil(maxColumnScaleValue/NumberOfScaleValue);//每个单元所代表的值
    CGFloat Margin_top = rectangle.size.height*0.1;
    CGFloat Margin_bottom = Margin_top/2;
    CGFloat Margin_left = [[NSString stringWithFormat:@"%d9",unitValue*NumberOfScaleValue] sizeWithFont:m_coordinate_unit_font].width+SpaceBetweenScaleValueAndLine_Y;//
    CGFloat Margin_right = 0;
    CGFloat fullHight = rectangle.size.height-Margin_top-Margin_bottom;
    CGFloat unitHight = fullHight/NumberOfScaleValue;//单元高度
    CGPoint points[3];//用rectangle初始化坐标系的三个基础点
	points[0] = CGPointMake(rectangle.origin.x+Margin_left, rectangle.origin.y) ;//纵轴终点
	points[1] = CGPointMake(points[0].x, points[0].y+rectangle.size.height-Margin_bottom);//坐标系原点
	points[2] = CGPointMake(points[1].x+rectangle.size.width-Margin_right-Margin_left, points[1].y);//横轴终点
    //____
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, DefaultColor.CGColor);
    CGContextAddLines(context, points, 3);
	CGContextStrokePath(context);
	for(NSInteger i = 0; i <= NumberOfScaleValue; i++)
    {
        NSString * scaleValueStr = [NSString stringWithFormat:@"%d",i*unitValue];
        //Y轴的各个刻度字符串
        CGFloat point_x = points[1].x;
        CGFloat point_y = points[1].y - i*(unitHight);
        CGSize scaleValueTextSize = [scaleValueStr sizeWithFont:m_coordinate_unit_font];
        CGContextSetFillColorWithColor(context, m_coordinate_unit_color.CGColor);
        CGContextSelectFont(context, [m_coordinate_unit_font.fontName UTF8String], m_coordinate_unit_font.pointSize, kCGEncodingMacRoman);
        CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1, -1));
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextShowTextAtPoint(context, point_x - SpaceBetweenScaleValueAndLine_Y - scaleValueTextSize.width, point_y, [scaleValueStr UTF8String], [scaleValueStr length]);
        if (i == 0)
        {
            continue;
        }
        else
        {
            //绘制虚线刻度
            CGPoint p1 = CGPointMake(point_x, point_y);
            CGPoint p2 = CGPointMake(points[2].x, point_y);
            CGContextSetStrokeColorWithColor(context, DashLineColor.CGColor);
            CGFloat arr[2] = {4,2};
            CGContextSetLineDash(context, 0, arr, 2);
            CGContextMoveToPoint(context, p1.x, p1.y);
            CGContextAddLineToPoint(context, p2.x, p2.y);
            CGContextStrokePath(context);
        }
	}
    [self drawColumnDiagram:CGRectMake(points[0].x, points[0].y, points[2].x - points[1].x, points[1].y - points[0].y) valueToHightScale:fullHight/maxColumnScaleValue];
    CGContextRestoreGState(context);
}
@end
