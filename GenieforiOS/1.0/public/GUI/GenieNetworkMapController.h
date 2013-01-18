//
//  GenieNetworkMapController.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-3-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPanelView.h"

@class GPageControl;
@class GenieNetworkDeviceTypeListView;
@interface GenieNetworkMapController : UIViewController <UIScrollViewDelegate,GPanelViewDelegate,GPanelViewDataSource,UITextFieldDelegate,UIWebViewDelegate>{
    UIView                          * m_view;
    UIScrollView                    * m_scrollView;
    GPageControl                    * m_pageControl;
    NSMutableArray                  * m_alldevices;
    NSMutableArray                  * m_devRecordList;//记录了用户自定义信息的设备的列表
    NSDictionary                    * m_devType2ImgMap;
    //________________
    NSMutableArray                  * m_panelData;
    UITextField                     * m_customNameField;
    UIButton                        * m_customTypeBtn;
    GenieNetworkDeviceTypeListView  * m_listView;
    UISwitch                        * m_blockSwitcher;
    UILabel                         * m_blockSwitcherTitleLabel;
    UISwitch                        * m_deviceBlockSwitcher;
}
- (void) showViewWithOritation:(UIInterfaceOrientation) orientation;
- (void) drawNetworkMap;
- (void) saveUserCustomInfo;
- (NSMutableArray*) getUserCustomInfo;
@end
