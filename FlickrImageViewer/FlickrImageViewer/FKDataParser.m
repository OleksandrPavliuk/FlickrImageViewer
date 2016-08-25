//
//  FKDataParser.m
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/22/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import "FKDataParser.h"

@implementation FKDataParser

+ (FKPhotoSearchDataObject *)parsePhotoSearchData:(id)aData;
{
    FKPhotoSearchDataObject *photoSearchDataObject = [[FKPhotoSearchDataObject alloc] init];
    
    if ([aData isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dataDictionary = (NSDictionary *)aData;
        photoSearchDataObject.perpage = [dataDictionary[@"perpage"] integerValue];
        photoSearchDataObject.pages = [dataDictionary[@"pages"] integerValue];
        photoSearchDataObject.total = [dataDictionary[@"total"] integerValue];
        photoSearchDataObject.page = [dataDictionary[@"page"] integerValue];
        
        
        NSMutableArray *photos = [NSMutableArray new];
        
        for (NSDictionary *dict in dataDictionary[@"photo"])
        {
            FKPhotoDataTransferObject *photoDataObject = [FKPhotoDataTransferObject objectWithPhotoId:dict[@"id"]
                                                                                             serverId:dict[@"server"]
                                                                                               farmId:dict[@"farm"]
                                                                                               secret:dict[@"secret"]];
            if (photoDataObject)
            {
                [photos addObject:photoDataObject];
            }
        }
        
        photoSearchDataObject.photos = [NSArray arrayWithArray:photos];
    }
    
    return photoSearchDataObject;
}

@end

@implementation FKPhotoSearchDataObject

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.photos = [NSArray new];
    }
    
    return self;
}

@end

@implementation FKPhotoDataTransferObject

+ (FKPhotoDataTransferObject *)objectWithPhotoId:(id)anId
                                        serverId:(id)aServerId
                                          farmId:(id)aFarmId
                                          secret:(id)aSecret;

{
    FKPhotoDataTransferObject *object = [[[self class] alloc] init];
    
    if (object)
    {
        object.photoId = (NSString *)anId;
        object.serverId = (NSString *)aServerId;
        object.farmId = (NSString *)aFarmId;
        object.secret = (NSString *)aSecret;
    }
    
    return object;
}

@end