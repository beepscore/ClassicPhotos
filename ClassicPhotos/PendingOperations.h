//
//  PendingOperations.h
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (nonatomic, strong) NSMutableDictionary *filtrationsInProgress;
@property (nonatomic, strong) NSOperationQueue *filtrationQueue;

@end
