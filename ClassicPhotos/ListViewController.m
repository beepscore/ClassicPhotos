//
//  ListViewController.m
//  ClassicPhotos
//
//  Created by Steve Baker on 9/16/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

#pragma mark - Life cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Classic Photos";
    self.tableView.rowHeight = 80.0;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override getter
- (NSDictionary *)photos {
    if (!_photos) {
        // Lazy instantiation
        NSURL *dataSourceURL = [NSURL URLWithString:kDatasourceURLString];
        // FIXME: This blocks main thread! It is bad practice, done as part of the tutorial.
        _photos = [[NSDictionary alloc] initWithContentsOfURL:dataSourceURL];
    }
    return _photos;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // In storyboard prototype cell register cell by setting
    // cell identifier to match. i.e. Cell - no @, no quotes
    static NSString *kCellIdentifier = @"Cell";

    // iOS 6 new method dequeueReusableCellWithIdentifier:forIndexPath:
    // requires you to first register a class or nib file
    // and will then always return a valid cell - either from the queue or by creating a new cell.
    // Reference
    // http://useyourloaf.com/blog/2012/06/07/prototype-table-cells-and-storyboards.html
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                            forIndexPath:indexPath];

    // Configure the cell...
    NSString *rowKey = [[self.photos allKeys] objectAtIndex:indexPath.row];
    NSURL *imageURL = [NSURL URLWithString:[self.photos objectForKey:rowKey]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = nil;

    if (imageData) {
        UIImage *unfiltered_image = [UIImage imageWithData:imageData];
        //image = [self applySepiaFilterToImage:unfiltered_image];
    }

    cell.textLabel.text = rowKey;
    cell.imageView.image = image;

    return cell;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
