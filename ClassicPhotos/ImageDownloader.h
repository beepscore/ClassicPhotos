//
//  ImageDownloader.h
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"
@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation

@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

// designated initializer
- (id)initWithPhotoRecord:(PhotoRecord *)record
              atIndexPath:(NSIndexPath *)indexPath
                 delegate:(id<ImageDownloaderDelegate>) theDelegate;
@end

@protocol ImageDownloaderDelegate <NSObject>

// ImageDownloader calls delegate method imageDownloaderDidFinish: on main thread.
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;

@end
