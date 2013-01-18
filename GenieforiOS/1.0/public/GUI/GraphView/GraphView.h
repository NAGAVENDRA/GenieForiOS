//
//  GenieGraphView.h
//  GCustomCell
//
//  Created by cs Siteview on 12-4-11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GraphView : UIView {
    NSString * m_subject;
    NSString * m_unitTitle;//value unit name of Y
    NSMutableArray * m_columnCategorys;//data of all categorys.  each data is an array contains info of one category.
    NSArray * m_additionalTitles;
    NSArray * m_additionalColors;
    
    UIFont * m_categoryTitle_font;
    UIFont * m_columnText_font;
    UIFont * m_subject_font;
    UIFont * m_unitTitle_font;
    UIFont * m_coordinate_unit_font;
    UIFont * m_additional_title_font;
    UIColor * m_categoryTitle_color;
    UIColor * m_columnText_color;
    UIColor * m_subject_color;
    UIColor * m_unitTitle_color;
    UIColor * m_coordinate_unit_color;
    UIColor * m_additional_title_color;
}
//interface
- (void) cleanGraphView;
- (void) setSubject:(NSString*)subject Font:(UIFont*)font color:(UIColor*)color;
- (void) setUnitTitle:(NSString*)title Font:(UIFont*)font color:(UIColor*)color;
- (void) addCategory:(NSString*)title valueList:(NSNumber*)v1,...NS_REQUIRES_NIL_TERMINATION;
- (void) addCategory:(NSString*)title values:(NSArray*)values;
- (void) setCategoryTitleFont:(UIFont*)font color:(UIColor*)color;
- (void) setColumnTextFont:(UIFont*)font color:(UIColor*)color;
- (void) setCoordinateUnitFont:(UIFont*)font color:(UIColor*)color;
- (void) setAdditionalInfoTitles:(NSArray*)titles colors:(NSArray*)colors;
- (void) setAdditionalInfoFont:(UIFont*)font color:(UIColor*)color;

//abstract
- (void) drawColumnDiagram:(CGRect)coordinateArea valueToHightScale:(CGFloat)scale;
- (CGFloat) getHighestColumnScaleValue;//坐标系Y轴的最大刻度值 根据最高柱子的高度计算  需要用户根据特定的意图来设定
@end
