//
//  GenieLPCChildAccount.h
//  GenieiPad
//
//  Created by cs Siteview on 12-8-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieLPCChildAccount : UIViewController {
    NSString                            * m_bypassAccount;
    id                                  m_target;
    SEL                                 m_selector;
    
    UIView                              * m_view;
    UILabel                             * m_label;
}
- (id) initWithChilidAccount:(NSString*)account;
- (void) setBypassAccountLogoutSuccessed:(id) target selector:(SEL) selector;
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;

@end
