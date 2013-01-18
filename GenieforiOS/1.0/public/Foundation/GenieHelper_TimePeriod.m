//
//  GenieHelper_TimePeriod.m
//  GenieiPad
//
//  Created by cs Siteview on 12-4-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieHelper_TimePeriod.h"


@implementation GenieHelper (GenieHelper_TimePeriod)
#pragma mark Time Period
static  NSTimer * g_timePeriod_timer = nil;
static  NSString * key_timePeriodMode = @"key_timePeriodMode";
static  NSString * key_timePeriodStartDate = @"key_timePeriodStartDate";
static  NSString * key_routerMac = @"key_routerMac";
static  NSString * timePeriodMode_isNil = @"timePeriodMode_isNil";
static  NSString * timePeriod_routerMac_isNil = @"timePeriod_routerMac_isNil";

+ (void) resetTimePeriodMoniter
{
    if ([g_timePeriod_timer isValid])
    {
        [g_timePeriod_timer invalidate];
        g_timePeriod_timer = nil;
    }
}
+ (void) saveTimePeriod:(NSString*)timePeriod routerMac:(NSString*)mac
{
    [GenieHelper resetTimePeriodMoniter];
    if (!timePeriod) timePeriod = timePeriodMode_isNil;
    if (!mac) mac = timePeriod_routerMac_isNil;
    NSDictionary * dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:timePeriod, [NSDate date], mac, nil] forKeys:[NSArray arrayWithObjects:key_timePeriodMode, key_timePeriodStartDate, key_routerMac,nil]];
    [GenieHelper write:dic toFile:Genie_File_GuestAccess_TimePeriod_Info];
}
+ (void) resignTimePeriod
{
    [GenieHelper saveTimePeriod:nil routerMac:nil];
}
+ (NSString*) readTimePeriodMode
{
    return [[GenieHelper readFile:Genie_File_GuestAccess_TimePeriod_Info] objectForKey:key_timePeriodMode];
}
+ (NSString*) readTimePeriodRouterMac
{
    return [[GenieHelper readFile:Genie_File_GuestAccess_TimePeriod_Info] objectForKey:key_routerMac];
}
+ (NSDate*) readTimePeriodStartDate
{
    return [[GenieHelper readFile:Genie_File_GuestAccess_TimePeriod_Info] objectForKey:key_timePeriodStartDate];
}
#define Hour     (60*60)
#define Always   (0)
+ (NSTimeInterval) timePeriodTimeIntervalForTimePeriodMode:(NSString*)timePeriodMode
{
    NSTimeInterval seconds = Always;
    if ([timePeriodMode isEqualToString:Genie_Guest_TimePeriod_OneHour])
    {
        seconds = Hour;
    }
    else if ([timePeriodMode isEqualToString:Genie_Guest_TimePeriod_FiveHours])
    {
        seconds = 5*Hour;
    }
    else if ([timePeriodMode isEqualToString:Genie_Guest_TimePeriod_TenHours])
    {
        seconds = 10*Hour;
    }
    else if ([timePeriodMode isEqualToString:Genie_Guest_TimePeriod_OneDay])
    {
        seconds = 24*Hour;
    }
    else if ([timePeriodMode isEqualToString:Genie_Guest_TimePeriod_OneWeek])
    {
        seconds = 7*24*Hour;
    }
    else
    {
        seconds = Always;
    }
    return seconds;
}
+ (void) startMoniteGuestTimePeriod
{
    NSString * timePeriodMode = [GenieHelper readTimePeriodMode];
    NSString * timePeriodRouterMac = [GenieHelper readTimePeriodRouterMac];
    if (  [timePeriodMode isEqualToString:timePeriodMode_isNil]
        ||[timePeriodMode isEqualToString:Genie_Guest_TimePeriod_Always]
        ||[timePeriodRouterMac isEqualToString:timePeriod_routerMac_isNil] 
        ||![timePeriodRouterMac isEqualToString:[GenieHelper getRouterInfo].mac])
    {
        return;
    }
    if (![[GenieHelper GetInstance] isGuestAccessTimeOutdate])
    {
        [GenieHelper resetTimePeriodMoniter];
        g_timePeriod_timer = [NSTimer scheduledTimerWithTimeInterval:Hour
                                                              target:[GenieHelper GetInstance]
                                                            selector:@selector(isGuestAccessTimeOutdate) 
                                                            userInfo:nil
                                                             repeats:YES];
    }
}
- (BOOL) isGuestAccessTimeOutdate
{
    NSTimeInterval periodSeconds = [GenieHelper timePeriodTimeIntervalForTimePeriodMode:[GenieHelper readTimePeriodMode]];
    NSDate * startDate = (NSDate*)[GenieHelper readTimePeriodStartDate];
    NSDate * finishDate = [NSDate dateWithTimeInterval:periodSeconds sinceDate:startDate];
    if (NSOrderedAscending == [finishDate compare:[NSDate date]])
    {
        [[GenieHelper GetInstance] performTimePeriodOutdateAction];
        [GenieHelper resetTimePeriodMoniter];
        return YES;
    }
    return  NO;
}
- (void) performTimePeriodOutdateAction
{
    [GenieHelper showRebootRouterPrompt:Local_MsgForTimePeriodOutdatePrompt WithDelegate:[GenieHelper GetInstance]];
}


@end
