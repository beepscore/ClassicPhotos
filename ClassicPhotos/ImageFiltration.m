//
//  ImageFiltration.m
//  ClassicPhotos
//
//  Created by Steve Baker on 9/17/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "ImageFiltration.h"

@interface ImageFiltration ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end

@implementation ImageFiltration

#pragma mark - Life cycle

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate {

    if (self = [super init]) {
        self.photoRecord = record;
        self.indexPathInTableView = indexPath;
        self.delegate = theDelegate;
    }
    return self;
}

#pragma mark - Main operation

- (void)main {
    // Create an autorelease pool for this NSOperation object.
    // NSOperation runs on a background thread,
    // doesn't have access to the main thread's autorelease pool.
    @autoreleasepool {

        // check isCancelled before and after call to "expensive" method
        if (self.isCancelled) {
            return;
        }

        if (!self.photoRecord.hasImage) {
            return;
        }

        UIImage *rawImage = self.photoRecord.image;
        UIImage *processedImage = [self applySepiaFilterToImage:rawImage];

        // check isCancelled before and after call to "expensive" method
        // this is after applySepiaFilterToImage
        if (self.isCancelled) {
            return;
        }

        if (processedImage) {
            self.photoRecord.image = processedImage;
            self.photoRecord.filtered = YES;

            // Call delegate method imageFiltrationDidFinish: on main thread.
            // Cast delegate from id<ImageFiltrationDelegate> to NSObject
            // in order to call NSObject method performSelectorOnMainThread
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageFiltrationDidFinish:)
                                                        withObject:self
                                                     waitUntilDone:NO];
        }
    }
}

#pragma mark - Filter image

- (UIImage *)applySepiaFilterToImage:(UIImage *)image {

    // This is expensive + time consuming
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];

    if (self.isCancelled) {
        return nil;
    }

    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues: kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];

    if (self.isCancelled) {
        return nil;
    }

    // Create a CGImageRef from the context
    // This is an expensive + time consuming
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];

    if (self.isCancelled) {
        CGImageRelease(outputImageRef);
        return nil;
    }

    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
}

@end
