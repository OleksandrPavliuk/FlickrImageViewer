//
//  FKSearchViewController.m
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/20/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import "FKSearchViewController.h"
#import "FKPhotoSearchClient.h"
#import "FKDataParser.h"
#import "FKSearchPhotoCollectionViewCell.h"

static NSString * const kFKSearchPhotoCellReuseIdentifier = @"kFKSearchPhotoCellReuseIdentifier";
static NSString * const kFKPushGallerySegueIdentifier = @"kFKPushGallerySegueIdentifier";

@interface FKSearchViewController () <UISearchBarDelegate, UICollectionViewDataSource,
                                      UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
                                      UIGestureRecognizerDelegate>

@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic) CGFloat searchBarBoundsY;
@property (nonatomic, strong) FKPhotoSearchDataObject *dataSourceObject;
@property (nonatomic, strong) FKPhotoSearchClient *photoSearchClient;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, assign) NSIndexPath *selectedPath;
@property (nonatomic, assign) BOOL scaled;

@end

@implementation FKSearchViewController

#pragma mark - Properties

#pragma mark - Overwrite methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addSearchBar];
    self.photoSearchClient = [[FKPhotoSearchClient alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)cancelSearching
{
    self.scaled = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
}

- (void)addSearchBar
{
    if (!self.searchBar)
    {
        self.searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                                       self.searchBarBoundsY,
                                                                       [UIScreen mainScreen].bounds.size.width,
                                                                       44)];
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.tintColor = [UIColor whiteColor];
        self.searchBar.barTintColor  = [UIColor whiteColor];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"search here";
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    if (![self.searchBar isDescendantOfView:self.view])
    {
        [self.view addSubview:self.searchBar];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.scaled)
    {
        return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    }
    else
    {
        return CGSizeMake(150, 150);
    }
}

#pragma mark - <UICollectionViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    __weak typeof(self) weakSelf = self;
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height)
    {
        if (self.searchText.length > 0 && self.dataSourceObject.page + 1 <= self.dataSourceObject.pages)
        {
            [self.photoSearchClient cancelCurrentPhotoSearch];
            [self.photoSearchClient requestPhotoWithString:self.searchText
                                                   andPage:self.dataSourceObject.page + 1
                                         completionHandler:^(BOOL success,
                                                             FKPhotoSearchDataObject *photoData,
                                                             NSError *error)
             {
                 if (success)
                 {
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         weakSelf.dataSourceObject.total = photoData.total;
                         weakSelf.dataSourceObject.page = photoData.page;
                         weakSelf.dataSourceObject.perpage = photoData.perpage;
                         weakSelf.dataSourceObject.pages = photoData.pages;
                         
                         NSMutableArray *unionArray = [NSMutableArray arrayWithArray:weakSelf.dataSourceObject.photos];
                         [unionArray addObjectsFromArray:photoData.photos];
                         weakSelf.dataSourceObject.photos = [[NSArray arrayWithArray:unionArray] copy];
                         [weakSelf.collectionView reloadData];

                     });
                 }
                 
             }];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    self.selectedPath = indexPath;
    
    if (self.searchBar.isFirstResponder)
    {
        [self.searchBar resignFirstResponder];
    }
    
    self.scaled = !self.scaled;
    
    __weak typeof(self) weakSelf = self;
    UICollectionViewFlowLayout *newLayout = [[UICollectionViewFlowLayout alloc] init];
    newLayout.scrollDirection =
    self.scaled ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    
    [self.collectionView setCollectionViewLayout:newLayout animated:YES completion:^(BOOL finished) {
        [weakSelf.collectionView reloadItemsAtIndexPaths:@[weakSelf.selectedPath]];
    }];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.dataSourceObject.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    FKSearchPhotoCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kFKSearchPhotoCellReuseIdentifier
                                              forIndexPath:indexPath];
    
    if (indexPath.row < self.dataSourceObject.photos.count)
    {
        FKPhotoDataTransferObject *photoData = self.dataSourceObject.photos[indexPath.row];
        
        BOOL galleryMode = self.scaled;
        NSURLSessionDownloadTask *downloadTask =
        [self.photoSearchClient downloadImageTaskWithData:photoData
                                                isPreview:!galleryMode
                                        completionHandler:^(BOOL success,
                                                            NSURLResponse *response,
                                                            NSData *anImageData,
                                                            NSError *error)
         {
             if (success)
             {
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     
                     cell.URLString = [[response URL] absoluteString];
                     
                     UIImage *image = [UIImage imageWithData:anImageData];
                     [cell.imageView setImage:image];
                     cell.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                     [cell.imageView sizeThatFits:cell.contentView.frame.size];
                     cell.imageView.center = CGPointMake(cell.contentView.frame.size.width / 2,
                                                         cell.contentView.frame.size.height / 2);
                     
                     [cell.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj,
                                                                           NSUInteger idx,
                                                                           BOOL * _Nonnull stop)
                      {
                          [cell removeGestureRecognizer:obj];
                      }];
                     
                     if (galleryMode)
                     {
                         UIRotationGestureRecognizer *rotationGR =
                         [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(rotationGestureRecognizerCallback:)];
                         rotationGR.delegate = self;
                         [cell addGestureRecognizer:rotationGR];
                         
                         UIPinchGestureRecognizer *pinchGR =
                         [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(pinchGestureRecognizerCallback:)];
                         pinchGR.delegate = self;
                         [cell addGestureRecognizer:pinchGR];
                     }
                 });
             }
         }];
        
        if (![cell.URLString isEqualToString:[[[downloadTask currentRequest] URL] absoluteString]])
        {
            if (![[[[downloadTask currentRequest] URL] absoluteString] isEqualToString:
                  [[[cell.task currentRequest] URL] absoluteString]])
            {
                cell.imageView.image = nil;
                cell.URLString = nil;
                [cell.task cancel];
                cell.task = nil;
                
                cell.task = downloadTask;
                [cell.task resume];
            }
            
        }
        else
        {
            if (cell.task.state == NSURLSessionTaskStateRunning)
            {
                [cell.task cancel];
                cell.task = nil;
            }
        }
    }
    
    return cell;
}

#pragma mark - <UISearchBarDelegate>

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearching];
    self.dataSourceObject.photos = nil;
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if (searchText.length > 0)
    {
        __weak typeof(self) weakSelf = self;
        self.searchText = searchText;
        
        [self.photoSearchClient cancelCurrentPhotoSearch];
        [self.photoSearchClient requestPhotoWithString:self.searchText
                                               andPage:0
                                     completionHandler:^(BOOL success,
                                                         FKPhotoSearchDataObject *photoData,
                                                         NSError *error)
         {
             if (success)
             {
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     weakSelf.dataSourceObject = photoData;
                     [weakSelf.collectionView reloadData];
                 });
             }
         }];
    }
    else
    {
        self.dataSourceObject = nil;
        [self.collectionView reloadData];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Gesture recognizers actions

- (void)rotationGestureRecognizerCallback:(UIGestureRecognizer *)gestureRecognizer
{
    UIRotationGestureRecognizer *rotationGR = (UIRotationGestureRecognizer *)gestureRecognizer;
    
    FKSearchPhotoCollectionViewCell *cell = (FKSearchPhotoCollectionViewCell *)rotationGR.view;
    if (rotationGR.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (rotationGR.state == UIGestureRecognizerStateChanged)
    {
        cell.imageView.transform = CGAffineTransformRotate(cell.imageView.transform, rotationGR.rotation);
        rotationGR.rotation = 0;
    }
}

- (void)pinchGestureRecognizerCallback:(UIGestureRecognizer *)gestureRecognizer
{
    UIPinchGestureRecognizer *pinchGR = (UIPinchGestureRecognizer *)gestureRecognizer;
    
    FKSearchPhotoCollectionViewCell *cell = (FKSearchPhotoCollectionViewCell *)pinchGR.view;
    if (pinchGR.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (pinchGR.state == UIGestureRecognizerStateChanged)
    {
        cell.imageView.transform = CGAffineTransformScale(cell.imageView.transform, pinchGR.scale, pinchGR.scale);
        pinchGR.scale = 1;
    }
}

@end
