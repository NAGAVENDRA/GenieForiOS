//
//  GenieQRCode.m
//  GenieiPad
//
//  Created by cs Siteview on 12-9-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieQRCode.h"
#import "qrencode.h"

enum {
	qr_margin = 3
};

@implementation GenieQRcode

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
	unsigned char *data = 0;
	int width;
	data = code->data;
	width = code->width;
	float zoom = (double)size / (code->width + 2.0 * qr_margin);
	CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
	
	// draw
	CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
	for(int i = 0; i < width; ++i) {
		for(int j = 0; j < width; ++j) {
			if(*data & 1) {
				rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
				CGContextAddRect(ctx, rectDraw);
			}
			++data;
		}
	}
	CGContextFillPath(ctx);
}


+ (UIImage*) GetQRcodeImageWithSSID:(NSString*)ssid password:(NSString*) password imageSize:(CGFloat)size 
{
    NSString * s1 = @"";
    NSString * s2 = @"";
    if (ssid)
    {
        s1 = ssid;
    }
    if (password)
    {
        s2 = password;
    }
    NSString * encodeString = [NSString stringWithFormat:@"WIRELESS:%@;PASSWORD:%@",s1,s2];
    
    if (![encodeString length]) {
		return nil;
	}
	
	QRcode *code = QRcode_encodeString([encodeString UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
	if (!code) {
		return nil;
	}
	
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
	// draw QR on this context
	[GenieQRcode drawQRCode:code context:ctx size:size];
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);
	QRcode_free(code);
	
	return qrImage;
}
@end
