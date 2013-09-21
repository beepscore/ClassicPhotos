//
//  ListViewController.h
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"
#import "AFNetworking/AFNetworking.h"

// Note: Both URLs appear to contain the same info.
//#define kDatasourceURLString @"https://sites.google.com/site/soheilsstudio/tutorials/nsoperationsampleproject/ClassicPhotosDictionary.plist"
#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"


@interface ListViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate>

// main data source of controller
@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
