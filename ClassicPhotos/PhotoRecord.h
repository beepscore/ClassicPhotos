//
//  PhotoRecord.h
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> // because we need UIImage

@interface PhotoRecord : NSObject

// To store the name of image
@property (nonatomic, strong) NSString *name;
// To store the actual image
@property (nonatomic, strong) UIImage *image;
// To store the URL of the image
@property (nonatomic, strong) NSURL *URL;

// Return YES if image is downloaded.
@property (nonatomic, readonly) BOOL hasImage;
// Return Yes if image failed to be downloaded
@property (nonatomic, getter = isFailed) BOOL failed;
// Return YES if image is sepia-filtered
@property (nonatomic, getter = isFiltered) BOOL filtered;

@end
