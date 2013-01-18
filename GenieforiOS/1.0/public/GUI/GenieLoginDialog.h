//
//  GenieLoginDialog.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPanelView.h"
#import "GenieGlobal.h"

@class GTAsyncOp;
@interface GenieLoginDialog : NSObject <GPanelViewDelegate,GPanelViewDataSource,UITextFieldDelegate>{
    id                              m_target;
    SEL                             m_selector;
    GTAsyncOp                       * m_loginOp;
    GPanelView                      * m_dialog;
    UITextField                     * m_passwordField;
    UISwitch                        * m_switcher;
    NSTimer                         * m_timer;
    GenieErrorType                  m_err;
    BOOL                            m_loginOpFinished;
    BOOL                            m_aborted;
    BOOL                            m_timeout;
}
- (id) init;
- (void) showForAutoLogin:(BOOL)needAutoLogin;
- (void) setCallback:(id)target selector:(SEL)selector;
- (void) startLoginOp;
@end
