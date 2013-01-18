//
//  GWebInfoHelper.m
//  GenieiPad
//
//  Created by cs Siteview on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GWebInfoHelper.h"


@implementation GWebInfoHelper
- (GTAsyncOp*) getcurrentSetting
{
    return [[[GWebInfoGCSetting alloc] init] autorelease];
}
@end
