//
//  GPageControl.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPageControl : UIPageControl {
    UIImage                * m_normalDot;
    UIImage                * m_highLightedDot;
}

- (void) setNormalDotIcon:(UIImage*)normalDot;
- (void) setHighLightedDot:(UIImage*)highLightedDot;
@end
