//
//  GPWaitDialog.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenieGlobal.h"


@class GTAsyncOp;
@interface GPWaitDialog : NSObject <UIAlertViewDelegate>{
    id                              m_target;
    SEL                             m_selector;
    GTAsyncOp                       * m_op;
    GenieErrorType                  m_error;
    BOOL                            m_finished;
    BOOL                            m_aborted;
    BOOL                            m_timeout;
    
    UIAlertView                     * m_alert;
    NSString                        * m_alertMsg;
    NSString                        * m_cancelBtn;
    BOOL                            m_needCountDown;
    BOOL                            m_needWaitTillTimeout;
    NSInteger                       m_countDownTi;
    NSInteger                       m_timeoutTi;
    NSTimer                         * m_timer;
}
@property (nonatomic, assign) GenieErrorType error;
@property (nonatomic, retain) GTAsyncOp * asyncOp;

+ (void) show:(GTAsyncOp*)op withTarget:(id)targer selector:(SEL)selector waitMessage:(NSString*)msg timeout:(NSInteger)ti cancelBtn:(NSString*)cancelBtn needCountDown:(BOOL) needCountDown waitTillTimeout:(BOOL) needWait;

@end
