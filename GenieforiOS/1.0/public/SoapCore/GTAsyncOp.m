//
//  GTAsyncOp.m
//  MobDemo
//
//  Created by yiyang on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTAsyncOp.h"

@implementation GTAsyncOp

- (BOOL)aborted
{
	return NO;
}

- (BOOL)finished
{
	return NO;
}

- (BOOL)succeeded
{
	return NO;
}

- (BOOL)setFinishCallback:(id)target selector:(SEL)selector
{
	return NO;
}

- (void)abort
{
	
}

- (NSDictionary*)result
{
	return nil;
}

- (int)responseCode
{
	return -1;
}

- (NSString*)stringForKey:(NSString*)key
{
	return nil;
}

- (BOOL)containsKey:(NSString*)key
{
	return NO;
}

@end
