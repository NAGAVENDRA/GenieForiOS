//
//  GPanelView.h
//  GPanelView
//
//  Created by cs Siteview on 12-3-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GPanelViewCell;
@class GPImageView;
@protocol GPanelViewDelegate,GPanelViewDataSource;
@interface GPanelView : NSObject {
    id<GPanelViewDelegate>          m_delegate;
    id<GPanelViewDataSource>        m_dataSource;
    UIWindow                        * m_window;
    UIControl                       * m_bgView;
    GPImageView                     * m_contentView;
    CGFloat                         m_contentViewWidth;
    CGFloat                         m_contentViewHeight;
    CGFloat                         m_contentViewCenterOffsetY;
    CGFloat                         m_heightForRow;
    NSInteger                       m_numberOfRows;
    UILabel                         * m_titleLabel;
    NSString                        * m_cancelBtnTitle;
    NSString                        * m_anotheBbtnTitle;
    NSMutableArray                  * m_buttons;
}
@property (nonatomic, assign) id<GPanelViewDataSource> dataSource;
@property (nonatomic, assign) id<GPanelViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger rows;
@property (nonatomic, assign) CGFloat centerOffsetY;//调整中心位置的纵向偏移量
- (id) initWithTitle:(NSString*) title highLightBtn:(NSString*) cancelBtn anotherBtn:(NSString*)anotherBtn;
- (void) initializationView;
- (void) show;
- (void) dismiss;
- (void) addTarget:(id) target selector:(SEL) selector forEvent:(UIControlEvents)event;
- (void) addSubView:(UIView*)view;
- (UIButton*) buttonAtIndex:(NSInteger)index;
- (NSArray*) subViews;
//- (CGPoint) center;
- (CGRect) frame;
- (void) setEnabled:(BOOL)enabled;
- (UIView*) backgroundView;
@end


@protocol GPanelViewDelegate<NSObject>
@optional
- (CGFloat)panelView:(GPanelView *)panelView heightForRowIndex:(NSInteger)index;
- (void) panelView:(GPanelView*)panelView clickBtnWithBtnIndex:(NSInteger)index;
- (void) willPresentPanelView:(GPanelView*)panelView;
 
@end

@protocol GPanelViewDataSource <NSObject>
@required
- (NSInteger) numberOfRowsInPanelView:(GPanelView*)panelView;
- (GPanelViewCell*) panelView:(GPanelView*)panelView cellForRowAtIndex:(NSInteger)index;
@end


@interface GPanelViewCell : UIView {
    UILabel                     * m_keyLabel;
    UIView                      * m_valueView;
    UIView                      * m_valueView_bg;
}
@property (nonatomic, retain) UILabel * keyLabel;
@property (nonatomic, retain) UIView * valueView;
- (void) setEnabled:(BOOL)enabled;
@end

@interface GPImageView : UIImageView {
    id                  m_target;
    SEL                 m_selector;
}
- (void) addTarget:(id) target withSelector:(SEL) selector;
@end