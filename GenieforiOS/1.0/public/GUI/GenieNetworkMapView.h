//
//  GenieNetworkMapView.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieNetworkMapView : UIView {
    NSArray                 * m_devices;
    NSMutableArray          * m_points;
    UIImageView             * m_touchedBackgroundView;
    id                      m_target;
    SEL                     m_selector;
}
@property (nonatomic, retain) NSArray * devices;
- (void) addTarget:(id) target selector:(SEL) selector;
- (void) getPointsForMap;
- (void) drawRouter;
- (void) drawInternetIcon;
- (void) drawDevices;
- (void) drawLineFromCenterToPoint:(CGPoint)point Color:(UIColor*) color Dottedline:(BOOL) dottedLine;
- (void) drawLabelRelativeCenter:(CGPoint)center withText:(NSString*) text;
- (void) drawWirelessIconAtCenter:(CGPoint)center signalStrength:(NSInteger) signal;
@end
