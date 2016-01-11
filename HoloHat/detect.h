//
//  detect.h
//  HoloHat
//
//  Created by Benjamin Englard on 9/12/15.
//  Copyright (c) 2015 Benjamin Englard. All rights reserved.
//

#ifndef __HoloHat__detect__
#define __HoloHat__detect__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HandDetect : NSObject

- (NSMutableArray *) process: (UIImage*) image;

@end


#endif