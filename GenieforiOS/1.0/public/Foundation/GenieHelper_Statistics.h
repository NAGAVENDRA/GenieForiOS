//
//  GenieHelper_Statistics.h
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenieHelper.h"

@interface GenieHelper (GenieHelper_netinfo)
+ (NSString*) getLocalMacAddress;
+ (NSString*) getLocalIpAddress;
+ (NSString*) getRouterIpAddress;
@end

@interface GenieHelper (GenieHelper_Statistics)
+ (void) sendStatistics_RouterInfo;
+ (void) sendStatistics_InstallationInfo;
@end
