//
//  GooglePlusShare.h
//  GenieiPhoneiPod
//
//  Created by siteview on 12-8-24.
//
//

#import <UIKit/UIKit.h>
#import "GooglePlusShare.h"
@interface GooglePlus : UIView{
//id<FBDialogDelegate> _delegate;
NSMutableDictionary *_params;
NSString * _serverURL;
NSURL* _loadingURL;

UIWebView* _webView;
UIActivityIndicatorView* _spinner;
UIButton* _closeButton;
UIInterfaceOrientation _orientation;
BOOL _showingKeyboard;
BOOL _isViewInvisible;
//FBFrictionlessRequestSettings* _frictionlessSettings;

// Ensures that UI elements behind the dialog are disabled.
UIView* _modalBackgroundView;

UIView      *_gView;
UILabel     *sharePrefillLabel;
UILabel     *shareUrlLabel;
UITextView *sharePrefillText;
//UITextField *shareURLText;
UILabel     *shareURLText;
UIButton    *shareButton;
UIButton    *closeButton;
}
- (void)show;
- (void)cancel;
//- (void)load;
@end
