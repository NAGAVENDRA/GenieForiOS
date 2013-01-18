//
//  GenieQRCodeTableCellView.h
//  GenieiPad
//
//  Created by cs Siteview on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenieQRCodeTableCellView : UITableViewCell 
{
    NSString                    * m_ssid;
    NSString                    * m_password;
}
- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier ssid:(NSString*)ssid password:(NSString*)password;
@end
