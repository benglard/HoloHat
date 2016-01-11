//
//  cv.mm
//  HoloHat
//
//  Created by Benjamin Englard on 9/12/15.
//  Copyright (c) 2015 Benjamin Englard. All rights reserved.
//

#import "cv.h"

@implementation UIImage (OpenCV)

//+ (cv::Mat) im2mat:(UIImage *)image
- (cv::Mat) cvmat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(
        cvMat.data,                 // Pointer to  data
        cols,                       // Width of bitmap
        rows,                       // Height of bitmap
        8,                          // Bits per component
        cvMat.step[0],              // Bytes per row
        colorSpace,                 // Colorspace
        kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault   // Bitmap info flags
    );
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (UIImage *) frommat:(const cv::Mat&)mat
{
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
    CGColorSpaceRef colorSpace;
    
    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(
        mat.cols,                                   //width
        mat.rows,                                   //height
        8,                                          //bits per component
        8 * mat.elemSize(),                         //bits per pixel
        mat.step[0],                                //bytesPerRow
        colorSpace,                                 //colorspace
        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
        provider,                                   //CGDataProviderRef
        NULL,                                       //decode
        false,                                      //should interpolate
        kCGRenderingIntentDefault                   //intent
    );
    
    // Getting UIImage from CGImage
    [self initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}

@end