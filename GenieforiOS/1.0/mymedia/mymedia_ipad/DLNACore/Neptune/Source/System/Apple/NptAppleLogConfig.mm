#import <Foundation/Foundation.h>

#import "NptLogging.h"

NPT_Result
NPT_GetSystemLogConfig(NPT_String& config)
{
	NSDictionary* env_vars = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSEnvironment"];
	NSString* npt_log_config = [env_vars objectForKey:@"NEPTUNE_LOG_CONFIG"];
	if (npt_log_config) {
		NSLog(@"NEPTUNE_LOG_CONFIG in plist is: %@", npt_log_config);
		config = (const char*)[npt_log_config UTF8String];
        return NPT_SUCCESS;
	} else {
		NSLog(@"NEPTUNE_LOG_CONFIG not found in 'Info.plist'");
        return NPT_ERROR_NO_SUCH_PROPERTY;
    }
}
