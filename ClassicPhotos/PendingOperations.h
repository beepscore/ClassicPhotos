//
//  PendingOperations.h
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

// downloadsInProgress keys are table view indexPaths.
// storing this info is more time efficient than repeatedly iterating over downloadQueue operations
@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

// filtrationsInProgress keys are table view indexPaths.
// storing this info is more time efficient than repeatedly iterating over filtrationQueue operations
@property (nonatomic, strong) NSMutableDictionary *filtrationsInProgress;
@property (nonatomic, strong) NSOperationQueue *filtrationQueue;

@end
