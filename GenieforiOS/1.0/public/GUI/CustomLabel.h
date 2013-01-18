//
//  MyLabel.h
//  GenieiPhoneiPod
//
//  Created by siteview siteview on 12-4-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CustomLabel;
@protocol CustomLabelDelegate <NSObject>
@required
- (void)myLabel:(CustomLabel *)myLabel touchesWtihTag:(NSInteger)tag;
@end


@interface CustomLabel : UILabel {
    id <CustomLabelDelegate> delegate;
}
@property (nonatomic, assign) id <CustomLabelDelegate> delegate;
- (id)initWithFrame:(CGRect)frame;
@end