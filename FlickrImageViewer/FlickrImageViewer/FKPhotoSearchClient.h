//
//  FKPhotoSearchClient.h
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/22/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FKPhotoSearchDataObject;
@class FKPhotoDataTransferObject;

typedef void (^FKPhotoSearchClientCompletionHandler)(BOOL success, FKPhotoSearchDataObject *photoData, NSError *error);
typedef void (^FKPhotoSearchClientDownloadPhotoCompletionHandler)(BOOL success, NSURLResponse *response, NSData *anImageData, NSError *error);

@interface FKPhotoSearchClient : NSObject

- (void)requestPhotoWithString:(NSString *)aString
                       andPage:(NSUInteger)aPageNumber
             completionHandler:(FKPhotoSearchClientCompletionHandler)aCompletionHandler;
- (void)cancelCurrentPhotoSearch;

- (NSURLSessionDownloadTask *)downloadImageTaskWithData:(FKPhotoDataTransferObject *)aData
                                              isPreview:(BOOL)isAPreviewImage
                                      completionHandler:(FKPhotoSearchClientDownloadPhotoCompletionHandler)aCompletionHandler;

@end
