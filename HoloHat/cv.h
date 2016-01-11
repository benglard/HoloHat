//
//  cv.h
//  vrawr
//
//  Created by Benjamin Englard on 9/12/15.
//  Copyright (c) 2015 Benjamin Englard. All rights reserved.
//

#ifndef __HoloHat__cv__
#define __HoloHat__cv__

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc.hpp>

@interface UIImage (OpenCV)

- (cv::Mat) cvmat;
- (UIImage *) frommat:(const cv::Mat&)mat;

@end

#endif