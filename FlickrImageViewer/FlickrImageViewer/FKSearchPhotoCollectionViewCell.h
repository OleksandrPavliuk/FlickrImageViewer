//
//  FKSearchPhotoCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/23/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKSearchPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *URLString;

@end
