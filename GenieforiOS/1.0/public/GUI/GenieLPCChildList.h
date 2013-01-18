//
//  GenieLPCChildList.h
//  GenieiPad
//
//  Created by cs Siteview on 12-8-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPanelView.h"

@interface GenieLPCChildList : UITableViewController <GPanelViewDelegate,GPanelViewDataSource,UITextFieldDelegate>{
    NSMutableArray                      * m_subAccounts;
    NSString                            * m_selectedAccount;
    id                                  m_target;
    SEL                                 m_selector;
    
    GPanelView                          * m_dialog;
    UITextField                         * m_passwordField;
}
- (id) initWithChildList:(NSArray*) list;
- (void) setBypassAccountLoginSuccessed:(id) target selector:(SEL) selector;

@end

