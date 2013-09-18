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

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {

    if (self = [super init]) {
        // 2
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark - Downloading image
- (void)main {

    @autoreleasepool {

        // Check isCancelled regularly, in order to stop promptly.
        if (self.isCancelled)
            return;

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

        if (self.isCancelled)
            return;

        // Cast delegate from id<ImageDownloaderDelegate> to NSObject in order to call method performSelectorOnMainThread
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:)
                                                    withObject:self waitUntilDone:NO];
    }
}

@end
