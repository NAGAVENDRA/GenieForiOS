//
//  GenieItemListController.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

//
/*
 选择列表控制器，
 【in】(nsarray *) 需要显示的列表项目
 【in】(nsstring **) 当前选中的项目
 */
#import <UIKit/UIKit.h>


@interface GenieItemListController : UITableViewController {
    NSArray                 * m_items;
    NSString                * m_selectedItem;//assign
    NSInteger               m_selectedRow;
    //
    id                      m_target;
    SEL                     m_selector;
}

- (id) initWithItmeList:(NSArray*)list andSelectedItem:(NSString*) item;
- (void) setModifyCallback:(id) target callback:(SEL) selector;
@end
