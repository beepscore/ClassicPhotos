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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override getter
- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (NSMutableArray *)photos {

    if (!_photos) {

        NSURL *datasourceURL = [NSURL URLWithString:kDatasourceURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:datasourceURL];

        // https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-2.0-Migration-Guide
        AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

        datasource_download_operation.responseSerializer = [AFHTTPResponseSerializer serializer];

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        // set operation success and failure blocks
        [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

            // success block
            NSData *datasource_data = (NSData *)responseObject;
            // Use toll-free bridging to convert data to CFDataRer and CFPropertyList
            CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)datasource_data, kCFPropertyListImmutable, NULL);

            NSDictionary *datasource_dictionary = (__bridge NSDictionary *)plist;

            NSMutableArray *records = [NSMutableArray array];

            for (NSString *key in datasource_dictionary) {
                PhotoRecord *record = [[PhotoRecord alloc] init];
                record.URL = [NSURL URLWithString:[datasource_dictionary objectForKey:key]];
                record.name = key;
                [records addObject:record];
                record = nil;
            }

            self.photos = records;

            // ARC compatible?
            //CFRelease(plist);

            [self.tableView reloadData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error){

            // failure block
            // Connection error message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            alert = nil;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];

        // add operation to the queue
        [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
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
    // 2
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];

    // 3
    if (aRecord.hasImage) {

        //[((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;

    }
    // 4
    else if (aRecord.isFailed) {
        //[((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";

    }
    // 5
    else {

        //[((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    return cell;
}

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {

    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
    if (!record.isFiltered) {
        [self startImageFiltrationForRecord:record atIndexPath:indexPath];
    }
}

#pragma mark - Image download
- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {

    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {

        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

#pragma mark - ImageDownloaderDelegate method
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {

    // 1
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    // 2
    //PhotoRecord *theRecord = downloader.photoRecord;
    // 3
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // 4
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - Image filtration
- (void)startImageFiltrationForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {

    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
        // Start filtration
        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];

        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if (dependency) {
            [imageFiltration addDependency:dependency];
        }

        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
    }
}

- (UIImage *)applySepiaFilterToImage:(UIImage *)image {

    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues: kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
}

#pragma mark - ImageFiltrationDelegate method
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration {
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    //PhotoRecord *theRecord = filtration.photoRecord;

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
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
