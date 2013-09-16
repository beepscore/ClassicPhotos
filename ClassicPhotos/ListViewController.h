//
//  ListViewController.h
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"

@interface ListViewController : UITableViewController

// main data source of controller
@property (nonatomic, strong) NSDictionary *photos;

@end
