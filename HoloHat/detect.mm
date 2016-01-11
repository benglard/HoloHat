//
//  detect.cpp
//  HoloHat
//
//  Created by Benjamin Englard on 9/12/15.
//  Copyright (c) 2015 Benjamin Englard. All rights reserved.
//

#include "detect.h"
#include "cv.h"
#include <iostream>

@implementation HandDetect

- (NSMutableArray *) process: (UIImage*) image
{
    cv::Mat mat = [image cvmat];
    /*cv::Mat rotated(mat.rows, mat.cols, CV_8UC4);
    cv::Point center(mat.rows / 2, mat.cols / 2);
    cv::Mat rotmat = cv::getRotationMatrix2D(center, 180, 1);
    cv::warpAffine(mat, rotated, rotmat, mat.size());*/
    
    cv::Mat gray(mat.rows, mat.cols, CV_8UC1);
    cv::Mat blur(mat.rows, mat.cols, CV_8UC1);
    cv::Mat thresh(mat.rows, mat.cols, CV_8UC1);
    
    cv::cvtColor(mat, gray, CV_RGB2GRAY);
    cv::GaussianBlur(gray, blur, cv::Size(5, 5), 0);
    cv::threshold(blur, thresh, 100, 255, cv::THRESH_BINARY_INV + cv::THRESH_OTSU);
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    
    cv::findContours(thresh, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    unsigned long cs = contours.size();
    
    //cv::Mat output;
    NSMutableArray* output = [NSMutableArray arrayWithCapacity: 2];
    
    if (cs > 0) {
        double maxArea = -9999;
        int maxi = -1;
        
        for(int i=0; i < cs; i++) {
            double area = cv::contourArea(contours[i]);
            if (area > maxArea) {
                maxArea = area;
                maxi = i;
            }
        }
        
        auto maxc = cv::Mat(contours[maxi]);
        std::vector<std::vector<cv::Point>> hull(1);
        cv::convexHull(maxc, hull[0]);
        
        cv::Scalar mean = cv::mean(maxc);
        output[0] = [NSNumber numberWithDouble: mean[0]];
        output[1] = [NSNumber numberWithDouble: mean[1]];
        
        //output = mat.clone();
        //output = cv::Mat::zeros(thresh.rows, thresh.cols, CV_8UC3);
        //cv::circle(output, cv::Point(mean[0], mean[1]), 10, cv::Scalar(0, 0, 255));
        //cv::drawContours(output, contours, maxi, cv::Scalar(0, 255, 0));
        //cv::drawContours(output, hull, 0, cv::Scalar(0, 0, 255));
    } else {
        //output = thresh.clone();
        output[0] = [NSNumber numberWithDouble: -1];
        output[1] = [NSNumber numberWithDouble: -1];
    }
    
    /*UIImage * rv = [UIImage alloc];
    [rv frommat:output];
    return rv;*/
    
    return output;
}

@end