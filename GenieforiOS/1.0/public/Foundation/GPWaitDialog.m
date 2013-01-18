//
//  GPWaitDialog.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GPWaitDialog.h"
#import "GenieHelper.h"
#import "GPBusinessHelper.h"

@implementation GPWaitDialog
@synthesize error = m_error;
@synthesize asyncOp = m_op;

- (id) initWithOp:(GTAsyncOp*)op target:(id)targer selector:(SEL)selector waitMessage:(NSString*)msg timeout:(NSInteger)ti cancelBtn:(NSString*)cancelBtn needCountDown:(BOOL) needCountDown waitTillTimeout:(BOOL)needWait
{
    self = [super init];
    if (self)
    {
        m_op = [op retain];
        [m_op setFinishCallback:self selector:@selector(asyncOpCallback)];
        m_target = [targer retain];
        m_selector = selector;
        m_error = GenieErrorUnknown;
        m_finished = NO;
        m_aborted = NO;
        m_timeout = NO;
        m_needCountDown = needCountDown;
        m_needWaitTillTimeout = needWait;
        m_cancelBtn = [cancelBtn retain];
        m_countDownTi = 0;
        m_timeoutTi = 0;
        if (m_cancelBtn && !m_needCountDown)//当有取消按钮时，调整alertview   [m_alertMsg 在倒计时时， 用来保存提示语言的不变的部分]
        {
            m_alertMsg = [[NSString stringWithFormat:@"%@\n\n",msg] retain];
        }
        else
        {
            m_alertMsg = [msg retain];
        }
        NSString * message = nil;
        
        if (ti <= 0)//不设置超时
        {
            m_timer = nil;
            message = m_alertMsg;
        }
        else
        {
            if (m_needCountDown)
            {
                m_countDownTi = ti;
                m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
                if (m_cancelBtn)
                {
                    message = [m_alertMsg stringByAppendingFormat:@"\n%d\n\n",m_countDownTi];
                }
                else
                {
                    message = [m_alertMsg stringByAppendingFormat:@"\n%d",m_countDownTi];
                }
            }
            else
            {
                m_timeoutTi = ti;
                m_timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(asyncOpTimeout) userInfo:nil repeats:NO];
                message = m_alertMsg;
            }
            
            [m_timer retain];    
        }

        m_alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:cancelBtn otherButtonTitles:nil];
        [m_alert show];
        [self retain];//
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    return self;
}

+ (void) show:(GTAsyncOp*)op withTarget:(id)targer selector:(SEL)selector waitMessage:(NSString*)msg timeout:(NSInteger)ti cancelBtn:(NSString*)cancelBtn needCountDown:(BOOL)needCountDown waitTillTimeout:(BOOL)needWait
{
    [[[GPWaitDialog alloc] initWithOp:op target:targer selector:selector waitMessage:msg timeout:ti cancelBtn:cancelBtn needCountDown:needCountDown waitTillTimeout:needWait] release];
}

- (void) dealloc
{
    self.asyncOp = nil;
    [m_alert release];
    [m_alertMsg release];
    [m_timer invalidate];
    [m_timer release];
    [m_cancelBtn release];
    [m_target release];
    [super dealloc];
}
#pragma mark --

- (void) notifyFinished
{   
    if (!m_finished)
    {
        m_finished = YES;
        if ([m_timer isValid])
        {
            [m_timer invalidate];
            [m_timer release];
            m_timer = nil;
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [m_alert dismissWithClickedButtonIndex:0 animated:YES];
        [m_alert release];
        m_alert = nil;
        [m_target performSelector:m_selector withObject:[GenieCallbackObj callbackObjWithResponseCode:self.error userInfo:self.asyncOp]];
        [m_target release];
        m_target = nil;
    
        [self release];//
    }
}

/*
 - (void) asyncOpCallback;
 只要business process正常返回，就认为流程成功.将具体的responseCode转交到GUI层去特殊处理
 否则 认为流程出错，直接将错误信息抛给GUI处理  如当发生 超时，abort时。
*/
- (void) asyncOpCallback
{
    if (m_aborted)
    {
        return;
    }
    if (!m_needWaitTillTimeout)
    {
        self.error = GenieErrorNoError;
        [self notifyFinished];
    }
    else
    {
        return;
    }
}
- (void) abort
{
    if (m_finished)
    {
        return;
    }
    m_aborted = YES;
    self.error = GenieErrorAsyncOpCancel;
    if (m_timeout)
    {
        self.error = GenieErrorAsyncOpTimeout;
    }
    [self.asyncOp abort];
    self.asyncOp = nil;
    [self notifyFinished];
}

- (void) asyncOpTimeout
{
    //立即停止timer
    if ([m_timer isValid])
    {
        [m_timer invalidate];
    }
    [m_timer release];
    m_timer = nil;
    if (m_finished)
    {
        return;
    }
    m_timeout = YES;
    [self abort];
}

- (void) countDown
{
    if(m_countDownTi == 0)
	{
        [self asyncOpTimeout];
	}
	else
	{
		m_countDownTi--;
        if (m_countDownTi == 0)
        {
            return;
        }
		NSString * message = nil;
        if (m_cancelBtn)
        {
            message = [NSString stringWithFormat:@"%@\n%d\n\n",m_alertMsg,m_countDownTi];
        }
        else
        {
            message = [NSString stringWithFormat:@"%@\n%d",m_alertMsg,m_countDownTi];
        }
        //PrintObj(message);
        [m_alert setMessage:message];
	}
}

#pragma mark alert delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self abort];
}
- (void) willPresentAlertView:(UIAlertView *)alertView
{
    UIActivityIndicatorView * aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat aivOffset_Y = 0;
    if (!m_cancelBtn)
    {
        aivOffset_Y = 40;
    }
    else
    {
        aivOffset_Y = 78;
    }
    aiv.center = CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-aivOffset_Y);
    [aiv startAnimating];
    [alertView addSubview:aiv];
    [aiv release];
}
@end



