//
//  FKSearchPhotoCollectionViewCell.m
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/23/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import "FKSearchPhotoCollectionViewCell.h"

@implementation FKSearchPhotoCollectionViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor redColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.imageView];
}

@end
