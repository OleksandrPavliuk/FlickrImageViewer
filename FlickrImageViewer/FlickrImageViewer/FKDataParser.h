//
//  FKDataParser.h
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/22/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FKPhotoDataTransferObject;
@class FKPhotoSearchDataObject;

@interface FKDataParser : NSObject

+ (FKPhotoSearchDataObject *)parsePhotoSearchData:(id)aData;

@end

@interface FKPhotoSearchDataObject : NSObject

@property (nonatomic, assign) NSInteger perpage;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, strong) NSArray <FKPhotoDataTransferObject *> *photos;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger page;

@end

@interface FKPhotoDataTransferObject : NSObject

+ (FKPhotoDataTransferObject *)objectWithPhotoId:(NSString *)anId
                                        serverId:(NSString *)aServerId
                                          farmId:(NSString *)aFarmId
                                          secret:(NSString *)aSecret;

@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSString *serverId;
@property (nonatomic, strong) NSString *farmId;
@property (nonatomic, strong) NSString *secret;

@end
