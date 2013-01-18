//
//  GenieNetworkDeviceTypeListView.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenieGlobal.h"
#import "GenieHelper.h"


@interface GenieNetworkDeviceTypeListView : UIView <UITableViewDataSource,UITableViewDelegate>{
    UIImageView                             * m_bg;
    UIImageView                             * m_bg_title;//在横竖屏的情况下，背景大小会变。而title如果拉伸的话，会失真
    UITableView                             * m_listView;
    GenieDeviceInfo                         * m_device;
    NSDictionary                            * m_dataMap;
    NSArray                                 * m_types;
    NSString                                * m_selectedItem;
    NSInteger                               m_selectedItemIndex;
    
    /*
     *m_currentOrientation
     *记录当前UI的方向，当收到设备方向改变的回调后，若发现设备方向与当前UI方向一样，
     *说明UI实际上并没有发生翻转，不应该重绘UI
     */
    UIInterfaceOrientation                  m_currentOrientation;
    
    id                                      m_target;
    SEL                                     m_selector;
}
- (id) init;
- (void) showForDevice:(GenieDeviceInfo*)device selectedItem:(NSString*) selectedItem;
- (void) dismiss;
- (void) setFinishCallback:(id)target selector:(SEL)selector;
@end
