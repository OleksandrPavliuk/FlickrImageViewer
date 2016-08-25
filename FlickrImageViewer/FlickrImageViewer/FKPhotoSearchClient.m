//
//  FKPhotoSearchClient.m
//  FlickrImageViewer
//
//  Created by Aleksandr Pavliuk on 8/22/16.
//  Copyright © 2016 Pavliuk Oleksandr. All rights reserved.
//

#import "FKPhotoSearchClient.h"
#import "FKDataParser.h"

static NSString * const kFKflickrApiKey = @"f339bf105d58670dc05be7ba15c66747";

@interface FKPhotoSearchClient ()

@property (nonatomic, strong) NSURLSessionTask *searchByTextTask;

@end

@implementation FKPhotoSearchClient


- (void)cancelCurrentPhotoSearch
{
    [self.searchByTextTask cancel];
}

- (void)requestPhotoWithString:(NSString *)aString
                       andPage:(NSUInteger)aPageNumber
             completionHandler:(FKPhotoSearchClientCompletionHandler)aCompletionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&format=json&nojsoncallback=1&page=%@", kFKflickrApiKey, aString, @(aPageNumber)];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    self.searchByTextTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                             completionHandler:^(NSData * _Nullable data,
                                                                                 NSURLResponse * _Nullable response,
                                                                                 NSError * _Nullable error)
                              {
                                  
                                  id returnData;
                                  FKPhotoSearchDataObject *parsedData;
                                  BOOL successFlag = YES;
                                  if (error)
                                  {
                                      successFlag = NO;
                                  }
                                  
                                  if (successFlag)
                                  {
                                      if (data)
                                      {
                                          returnData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                      }
                                      if ([returnData isKindOfClass:[NSDictionary class]])
                                      {
                                          id stat = returnData[@"stat"];
                                          if ([stat isKindOfClass:[NSString class]] && [stat isEqualToString:@"ok"])
                                          {
                                              successFlag = YES;
                                             
                                              id photoData = returnData[@"photos"];
                                              parsedData = [FKDataParser parsePhotoSearchData:photoData];
                                          }
                                      }
                                      else
                                      {
                                          successFlag = NO;
                                      }
                                  }
                                  
                                  aCompletionHandler(successFlag, parsedData, error);
                              }];
    [self.searchByTextTask resume];

}

- (NSURLSessionDownloadTask *)downloadImageTaskWithData:(FKPhotoDataTransferObject *)aData
                                              isPreview:(BOOL)isAPreviewImage
                                      completionHandler:(FKPhotoSearchClientDownloadPhotoCompletionHandler)aCompletionHandler;
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:
                                  @"https://farm%@.staticflickr.com/%@/%@_%@",
                                  aData.farmId,
                                  aData.serverId,
                                  aData.photoId,
                                  aData.secret];
    if (isAPreviewImage)
    {
        [urlString appendString:@"_q"];
    }
    [urlString appendString:@".jpg"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithString:urlString]];
    
    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                   downloadTaskWithURL:url
                                                   completionHandler:^(NSURL *location,
                                                                       NSURLResponse *response,
                                                                       NSError *error)
                                                   {
                                                       aCompletionHandler(!error,
                                                                          response,
                                                                          [NSData dataWithContentsOfURL:location],
                                                                          error);
                                                   }];
    
    return downloadPhotoTask;
}

@end
