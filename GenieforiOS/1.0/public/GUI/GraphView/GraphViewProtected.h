//
//  GraphViewProtected.h
//  GCustomCell
//
//  Created by cs Siteview on 12-4-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphView.h"

@interface GraphView (GraphViewProtected)
//protect
- (void) drawSubject:(CGPoint)center;
- (void) drawUnitTitle:(CGPoint)center;
- (void) drawAdditionalInfo:(CGRect)rec onOneLine:(BOOL)oneLine;
- (void) drawCoordinateGraphWithRect:(CGRect)rectangle;//绘制坐标系
@end
