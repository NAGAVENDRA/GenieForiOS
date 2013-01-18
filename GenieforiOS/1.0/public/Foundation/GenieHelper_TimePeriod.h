//
//  GenieHelper_TimePeriod.h
//  GenieiPad
//
//  Created by cs Siteview on 12-4-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenieHelper.h"


@interface GenieHelper (GenieHelper_TimePeriod)
//time period
+ (void) saveTimePeriod:(NSString*)timePeriod routerMac:(NSString*)mac;
+ (void) resignTimePeriod;
+ (NSString*) readTimePeriodMode;
+ (NSString*) readTimePeriodRouterMac;
+ (NSDate*) readTimePeriodStartDate;
+ (NSTimeInterval) timePeriodTimeIntervalForTimePeriodMode:(NSString*)timePeriodMode;
+ (void) startMoniteGuestTimePeriod;
+ (void) resetTimePeriodMoniter;

- (BOOL) isGuestAccessTimeOutdate;
- (void) performTimePeriodOutdateAction;
@end
