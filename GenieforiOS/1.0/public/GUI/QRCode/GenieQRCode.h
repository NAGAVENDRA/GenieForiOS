//
//  GenieQRCode.h
//  GenieiPad
//
//  Created by cs Siteview on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GenieQRcode : NSObject


+ (UIImage*) GetQRcodeImageWithSSID:(NSString*)ssid password:(NSString*) password imageSize:(CGFloat)size ;

@end
