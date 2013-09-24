//
//  ImageDownloader.m
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
// change to readwrite
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end

@implementation ImageDownloader

#pragma mark - Life Cycle

- (id)initWithPhotoRecord:(PhotoRecord *)record
              atIndexPath:(NSIndexPath *)indexPath
                 delegate:(id<ImageDownloaderDelegate>)theDelegate {

    if (self = [super init]) {
        self.photoRecord = record;
        self.indexPathInTableView = indexPath;
        self.delegate = theDelegate;
    }
    return self;
}

#pragma mark - Downloading image
- (void)main {
    // Create an autorelease pool for this NSOperation object.
    // NSOperation runs on a background thread,
    // doesn't have access to the main thread's autorelease pool.
    @autoreleasepool {

        // Check isCancelled regularly, in order to stop promptly.
        if (self.isCancelled) {
            return;
        }

        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];

        if (self.isCancelled) {
            imageData = nil;
            return;
        }

        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
        }
        else {
            self.photoRecord.failed = YES;
        }

        imageData = nil;

        if (self.isCancelled) {
            return;
        }

        // Call delegate method imageDownloaderDidFinish: on main thread.
        // Cast delegate from id<ImageDownloaderDelegate> to NSObject
        // in order to call NSObject method performSelectorOnMainThread
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:)
                                                    withObject:self
                                                 waitUntilDone:NO];
    }
}

@end
