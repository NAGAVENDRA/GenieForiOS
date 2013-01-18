//
//  GenieTrafficGraphCellView.h
//  GenieiPad
//
//  Created by cs Siteview on 12-4-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GGraphView;
@interface GenieTrafficGraphCellView : UITableViewCell {
    GGraphView * m_grahpView;
}
- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void) setGraphSubject:(NSString*)subject font:(UIFont*)font color:(UIColor*)color;
- (void) setGraphUnitTitle:(NSString*)unit font:(UIFont*)font color:(UIColor*)color;
- (void) cleanGraph;//if you want to re draw but just add,you should do this function first.
- (void) addGraphCategory:(NSString*)title valueList:(NSNumber*)v1,...NS_REQUIRES_NIL_TERMINATION;
- (void) setGraphCategoryTitleFont:(UIFont*)font color:(UIColor*)color;
- (void) setGraphColumnTextFont:(UIFont*)font color:(UIColor*)color;
- (void) setGraphCoordianteUnitTextFont:(UIFont*)font color:(UIColor*)color;
- (void) setGraphAdditionalInfoTitles:(NSArray*)titles colors:(NSArray*)colors;
- (void) setGraphAdditionalInfoFont:(UIFont*) font color:(UIColor*)color;
@end
