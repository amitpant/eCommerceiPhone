//
//  CommonHelper.m
//  mSeller
//
//  Created by Satish Kr Singh on 16/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CommonHelper.h"
#import "ZipArchive/ZipUnzip.h"
#import "commonMethods.h"


@implementation CommonHelper

#pragma mark - Download Helper

+(void)DownloadDataWithAPIName:(NSString * __nonnull)apiname HTTPMethod:(HTTTPMethod)httpmethod Params:(NSDictionary * __nonnull)params VirtualSavePath:(nullable NSString *)saveToPath ProgressBlock:(nullable void(^)(long long bytesDownloaded, long long bytesToDownload)) progressblock  CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString * __nullable errormessage ,__nullable id response)) completionblock{
    __block NSString *errormsg =@"Unable to download data";
    
    __block BOOL isSuccess=NO;
    
    __block AFHTTPRequestOperation *httpoperation = nil;

    NSString *httpMethodString = @"GET";

    switch (httpmethod) {
        case HTTTPMethodPOST:
            httpMethodString = @"POST";
            break;
        case HTTTPMethodPATCH:
            httpMethodString = @"PATCH";
            break;
        case HTTTPMethodPUT:
            httpMethodString = @"PUT";
            break;
        case HTTTPMethodDELETE:
            httpMethodString = @"DELETE";
            break;
        case HTTTPMethodGET:
        default:
            httpMethodString = @"GET";
            break;
    }

    NSMutableURLRequest *request = [kAppDelegate.requestManager.requestSerializer requestWithMethod:httpMethodString URLString:[kServiceURL stringByAppendingPathComponent:apiname] parameters:params error:nil];
    [request setTimeoutInterval:10000];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    httpoperation = [kAppDelegate.requestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *op, id result) {
        if([[op response] statusCode]==200){
            if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"status"]){
                isSuccess = [[[result objectForKey:@"status"] objectForKey:@"success"] boolValue];
                errormsg = [[result objectForKey:@"status"] objectForKey:@"message"];

                if(isSuccess)
                    [self saveFileWithJSONObject:result Path:saveToPath];
            }
        }
        completionblock(isSuccess,errormsg,result);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        id result = nil;
        if([[op response] statusCode]==200){
            result =[op responseData];
            isSuccess = YES;
            errormsg = nil;

            if(saveToPath){
                NSString *actualPath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:saveToPath];
                [result writeToFile:actualPath atomically:YES];
            }
        }
        completionblock(isSuccess,errormsg,result);
    }];
    [kAppDelegate.requestManager.operationQueue addOperation:httpoperation];

    if(progressblock && httpoperation){
        [httpoperation setDownloadProgressBlock:^void(NSUInteger bytesdownloaded, long long allbytesdownloaded, long long bytestobedownloaded) {
            NSLog(@"%li\n================\n",(long)bytesdownloaded);
            progressblock(allbytesdownloaded,bytestobedownloaded);
            
        }];
    }
}

// mandatory parameters - httpmethod, filename
+(void)DownloadFilesWithAPIs:(NSArray * __nonnull)apis ParamsAndFileNames:(NSDictionary * __nullable)dicparams ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock{
    
    __block NSInteger totalCount= [apis count];
    __block NSInteger successCount= 0;
    
    NSError *error=nil;
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSString *apiname in apis) {
        NSDictionary *params = params = [dicparams objectForKey:apiname];
        if(!params || ![params objectForKey:@"filename"]) {
            completionblock(NO, @"Insufficient parameter provided",0,totalCount);
            return;
        }
        
        NSString *strmethod = [params objectForKey:@"httpmethod"];
        if(!strmethod) strmethod=@"GET";
        
        // to create request
        NSURLRequest *request = [[kAppDelegate.requestManager requestSerializer] requestWithMethod:strmethod URLString:[kServiceURL stringByAppendingPathComponent:apiname] parameters:params error:&error];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.userInfo = [NSDictionary dictionaryWithObject:[params objectForKey:@"filename"] forKey:@"filename"];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if([[operation response] statusCode]==200){
                NSData *data = (NSData *)responseObject;
                
                BOOL blSaveFile = YES;
                NSDictionary *resultdata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                if([resultdata isKindOfClass:[NSDictionary class]]){
                    if([[resultdata objectForKey:@"status"] isEqual:[NSNull null]])
                        blSaveFile = NO;
                    else{
                        if([[[[resultdata objectForKey:@"status"] objectForKey:@"message"] lowercaseString] hasPrefix:@"no new modified"])
                            blSaveFile = NO;
                        else
                            blSaveFile = [[[resultdata objectForKey:@"status"] objectForKey:@"success"] boolValue];
                    }
                }
                if(blSaveFile){
                    successCount++;
                    NSString *actualPath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[operation.userInfo objectForKey:@"filename"]];
                    [data writeToFile:actualPath atomically:YES];
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            
        }];
        
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        //        DebugLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        if(progressfilesblock){
            progressfilesblock(numberOfFinishedOperations,totalNumberOfOperations);
        }
    } completionBlock:^(NSArray *operations) {
        //        DebugLog(@"All operations in batch complete");
        if(successCount>0)
            completionblock(YES,nil,successCount,totalCount - successCount);
        else
            completionblock(NO,@"Unable to get data from server",0,totalCount);
        DebugLog(@"Config downloads - Success: %li, Failed: %li", successCount, totalCount - successCount);
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

+(void)saveFileWithJSONObject:(id)json Path:(NSString * __nullable)savepath{
    if(savepath){
        NSString *actualPath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:savepath];
        NSData *data=[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:NULL];
        [data writeToFile:actualPath atomically:YES];
    }
}

+(void)DownloadDataFiles:(NSArray * __nonnull)paths VirtualDirPath:(nullable NSString *)saveDirectory ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock{
    [self DownloadDataFiles:paths Params:nil VirtualDirPath:saveDirectory ProgressBlock:progressfilesblock CompletionBlock:completionblock];
}

/*+(void)DownloadDataFiles:(NSArray * __nonnull)paths Params:(NSDictionary * __nullable)dicparams VirtualDirPath:(nullable NSString *)saveDirectory ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock{
    
    __block NSInteger totalCount= [paths count];
    __block NSInteger successCount= 0;
    
    NSError *error=nil;
    NSMutableArray *mutableOperations = [NSMutableArray array];
    
    NSMutableDictionary *params = [dicparams mutableCopy];
    for (NSDictionary *filedic in paths) {
        [params setObject:[filedic objectForKey:@"filename"] forKey:@"filename"];
        
        NSMutableURLRequest *request = [[kAppDelegate.requestManager requestSerializer] requestWithMethod:@"POST" URLString:[kServiceURL stringByAppendingPathComponent:(NSString *)kDownloadSingleFileAPI] parameters:params error:&error];
        [request setTimeoutInterval:1000];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.userInfo = filedic;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if([[operation response] statusCode]==200){
                successCount++;
                if(saveDirectory){
                    NSString *actualPath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:saveDirectory];
                    NSString *strfilename=[[operation.userInfo objectForKey:@"filename"] lowercaseString];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:actualPath])
                        [[NSFileManager defaultManager] createDirectoryAtPath:actualPath withIntermediateDirectories:YES attributes:nil error:nil];
                    
                    [(NSData *)responseObject writeToFile:[actualPath stringByAppendingPathComponent:strfilename] atomically:YES];
                    
                    if([operation.userInfo objectForKey:@"lastmodifiedon"]){
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DOWNLOADHISTORY" inManagedObjectContext:kAppDelegate.managedObjectContext];
                        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                        [fetch setEntity:entity];
                        
                        [fetch setPredicate:[NSPredicate predicateWithFormat:@"filename==%@",strfilename]];
                        
                        NSError *err = nil;
                        NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
                        if([results count]>0){
                            [[results lastObject] setValue:[operation.userInfo objectForKey:@"lastmodifiedon"] forKey:@"lastmodifiedon"];
                            [[results lastObject] setValue:[operation.userInfo objectForKey:@"filesizeinkb"] forKey:@"filesizeinkb"];
                            
                        }
                        else{
                            NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:kAppDelegate.managedObjectContext];
                            [managedObject setValue:[operation.userInfo objectForKey:@"lastmodifiedon"] forKey:@"lastmodifiedon"];
                            [managedObject setValue:[operation.userInfo objectForKey:@"filesizeinkb"] forKey:@"filesizeinkb"];
                            [managedObject setValue:strfilename forKey:@"filename"];

                            
                        }
                    }
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            
        }];
        
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        DebugLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        if(progressfilesblock){
            progressfilesblock(numberOfFinishedOperations,totalNumberOfOperations);
        }
    } completionBlock:^(NSArray *operations) {
        //        DebugLog(@"All operations in batch complete");
        if(successCount>0){
            NSError *err = nil;
            if([kAppDelegate.managedObjectContext save:&err]){

            }

            completionblock(YES,nil,successCount,totalCount-successCount);
        }
        else
            completionblock(NO,@"Unable to get data from server",0,totalCount);
        
        DebugLog(@"File downloads - Success: %li, Failed: %i",(long)successCount, totalCount-successCount);
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}*/

+(void)DownloadDataFiles:(NSArray * __nonnull)paths Params:(NSDictionary * __nullable)dicparams VirtualDirPath:(nullable NSString *)saveDirectory ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock{

    __block NSInteger totalCount= [paths count];
    __block NSInteger successCount= 0;
    __block NSInteger processedCount= 0;

    NSError *error=nil;
    NSMutableArray *mutableOperations = [NSMutableArray array];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3;

    NSString *actualPath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:saveDirectory];
    if(![[NSFileManager defaultManager] fileExistsAtPath:actualPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:actualPath withIntermediateDirectories:YES attributes:nil error:nil];

    NSMutableDictionary *params = [dicparams mutableCopy];
    for (NSDictionary *filedic in paths) {
        [params setObject:[filedic objectForKey:@"filename"] forKey:@"filename"];
        NSString *strfilename=[[filedic objectForKey:@"filename"] lowercaseString];

        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:[kServiceURL stringByAppendingPathComponent:(NSString *)kDownloadSingleFileAPI] parameters:params error:&error];
        [request setTimeoutInterval:1000];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.userInfo = filedic;
        [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:[actualPath stringByAppendingPathComponent:strfilename] append:NO]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            processedCount++;
            if([[operation response] statusCode]==200){
                successCount++;
                if(saveDirectory){

                    NSString *strfilename=[[operation.userInfo objectForKey:@"filename"] lowercaseString];

//                    [(NSData *)responseObject writeToFile:[actualPath stringByAppendingPathComponent:strfilename] atomically:YES];

                    if([operation.userInfo objectForKey:@"lastmodifiedon"]){
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DOWNLOADHISTORY" inManagedObjectContext:kAppDelegate.managedObjectContext];
                        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                        [fetch setEntity:entity];

                        [fetch setPredicate:[NSPredicate predicateWithFormat:@"filename==%@",strfilename]];

                        NSError *err = nil;
                        NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
                        if([results count]>0){
                            [[results lastObject] setValue:[operation.userInfo objectForKey:@"lastmodifiedon"] forKey:@"lastmodifiedon"];
                            [[results lastObject] setValue:[operation.userInfo objectForKey:@"filesizeinkb"] forKey:@"filesizeinkb"];

                        }
                        else{
                            NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:kAppDelegate.managedObjectContext];
                            [managedObject setValue:[operation.userInfo objectForKey:@"lastmodifiedon"] forKey:@"lastmodifiedon"];
                            [managedObject setValue:[operation.userInfo objectForKey:@"filesizeinkb"] forKey:@"filesizeinkb"];
                            [managedObject setValue:strfilename forKey:@"filename"];


                        }
                    }
                }
            }
            DebugLog(@"Success = %lu of %lu complete", processedCount, totalCount);
            if(processedCount<totalCount){
                if(progressfilesblock){
                    progressfilesblock(processedCount,totalCount);
                }
            }
            else{
                if(successCount>0){
                    NSError *err = nil;
                    if([kAppDelegate.managedObjectContext save:&err]){

                    }

                    completionblock(YES,nil,successCount,totalCount-successCount);
                }
                else
                    completionblock(NO,@"Unable to get data from server",0,totalCount);

            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            processedCount++;
            DebugLog(@"failed = %lu of %lu complete, %@", processedCount, totalCount,error.description);
            if(processedCount<totalCount){
                if(progressfilesblock){
                    progressfilesblock(processedCount,totalCount);
                }
            }
            else{
                if(successCount>0){
                    NSError *err = nil;
                    if([kAppDelegate.managedObjectContext save:&err]){

                    }

                    completionblock(YES,nil,successCount,totalCount-successCount);
                }
                else
                    completionblock(NO,@"Unable to get data from server",0,totalCount);
                
            }
        }];

        [mutableOperations addObject:operation];
    }

    [queue addOperations:mutableOperations waitUntilFinished:NO];

//    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
//        DebugLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
//        if(progressfilesblock){
//            progressfilesblock(numberOfFinishedOperations,totalNumberOfOperations);
//        }
//    } completionBlock:^(NSArray *operations) {
//        //        DebugLog(@"All operations in batch complete");
//        if(successCount>0){
//            NSError *err = nil;
//            if([kAppDelegate.managedObjectContext save:&err]){
//
//            }
//
//            completionblock(YES,nil,successCount,totalCount-successCount);
//        }
//        else
//            completionblock(NO,@"Unable to get data from server",0,totalCount);
//
//        DebugLog(@"File downloads - Success: %li, Failed: %li",successCount, totalCount-successCount);
//    }];
//    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

#pragma mark - Upload Helper
+(void)UploadDataWithAPIName:(NSString * __nonnull)apiname HTTPMethod:(HTTTPMethod)httpmethod Params:(NSDictionary * __nonnull)params ProgressBlock:(nullable void(^)(long long bytesUploaded, long long bytesToUpload)) progressblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString * __nullable errormessage ,__nullable id response)) completionblock{
    __block NSString *errormsg =@"Unable to upload data";

    __block BOOL isSuccess=NO;

    __block AFHTTPRequestOperation *httpoperation = nil;

    NSString *httpMethodString = @"GET";

    switch (httpmethod) {
        case HTTTPMethodPOST:
            httpMethodString = @"POST";
            break;
        case HTTTPMethodPATCH:
            httpMethodString = @"PATCH";
            break;
        case HTTTPMethodPUT:
            httpMethodString = @"PUT";
            break;
        case HTTTPMethodDELETE:
            httpMethodString = @"DELETE";
            break;
        case HTTTPMethodGET:
        default:
            httpMethodString = @"GET";
            break;
    }

    NSMutableURLRequest *request = [kAppDelegate.requestManager.requestSerializer requestWithMethod:httpMethodString URLString:[kServiceURL stringByAppendingPathComponent:apiname] parameters:params error:nil];
    [request setTimeoutInterval:10000];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    httpoperation = [kAppDelegate.requestManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *op, id result) {
        if([[op response] statusCode]==200){
            if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"status"]){
                isSuccess = [[[result objectForKey:@"status"] objectForKey:@"success"] boolValue];
                errormsg = [[result objectForKey:@"status"] objectForKey:@"message"];
            }
        }
        completionblock(isSuccess,errormsg,result);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        id result = nil;
        if([[op response] statusCode]==200){
            result =[op responseData];
            isSuccess = YES;
            errormsg = nil;
        }
        completionblock(isSuccess,errormsg,result);
    }];
    [kAppDelegate.requestManager.operationQueue addOperation:httpoperation];

    if(progressblock && httpoperation){
        [httpoperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            progressblock(totalBytesWritten,totalBytesExpectedToWrite);
        }];
    }
}

// mandatory parameters - httpmethod, filename
+(void)UploadFilesWithAPI:(NSString * __nonnull)apiname ParamsAndFileNames:(NSArray * __nullable)arrparams ProgressBlock:(nullable void(^)(long filesUploaded, long filesToUpload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSArray *__nullable successBatches, NSInteger failedCount)) completionblock{

    __block NSInteger totalCount= [arrparams count];
    __block NSMutableArray *successBatches= [NSMutableArray array];

    NSError *error=nil;
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSDictionary *params in arrparams) {
        NSString *strmethod = [params objectForKey:@"httpmethod"];
        if(!strmethod) strmethod=@"POST";

        // to create request
        NSURLRequest *request = [[kAppDelegate.requestManager requestSerializer] requestWithMethod:strmethod URLString:[kServiceURL stringByAppendingPathComponent:apiname] parameters:params error:&error];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer new];
        operation.userInfo = [NSDictionary dictionaryWithObject:[params objectForKey:@"filename"] forKey:@"filename"];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if([[operation response] statusCode]==200){
                [successBatches addObject:responseObject];
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

        }];

        [mutableOperations addObject:operation];
    }

    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        //        DebugLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        if(progressfilesblock){
            progressfilesblock(numberOfFinishedOperations,totalNumberOfOperations);
        }
    } completionBlock:^(NSArray *operations) {
        //        DebugLog(@"All operations in batch complete");
        if([successBatches count]>0)
            completionblock(YES,nil,successBatches,totalCount - [successBatches count]);
        else
            completionblock(NO,@"Unable to upload data to the server",0,totalCount);

        DebugLog(@"Config Uploads - Success: %li, Failed: %u", [successBatches count], totalCount - [successBatches count]);
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

#pragma mark - File Helper
+(id __nullable)loadFileDataWithVirtualFilePath:(NSString * __nonnull)fileppath{
    id resultdata = nil;
    NSString *actualPath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:fileppath];
    
    NSString *pathExtension=[[fileppath pathExtension] lowercaseString];
    
    if([pathExtension isEqualToString:@"json"]){
        if([[NSFileManager defaultManager] fileExistsAtPath:actualPath])
            resultdata = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:actualPath] options:NSJSONReadingAllowFragments error:NULL];
        else
            return nil;
    }
    else{
        //        if([pathExtension isEqualToString:@"csv"]){
        //            NSString *strdata=[NSString stringWithContentsOfFile:actualPath encoding:NSUTF8StringEncoding error:NULL];
        //        }
        //        else
        resultdata = [NSString stringWithContentsOfFile:actualPath encoding:NSUTF8StringEncoding error:NULL];
        if(!resultdata)
            resultdata = [NSString stringWithContentsOfFile:actualPath encoding:NSASCIIStringEncoding error:NULL];
    }
    return resultdata;
}

+(BOOL)UnzipFileWithVirtualFilePath:(NSString * __nonnull)fileppath DestinationPath:(NSString * __nullable)destpath{
    NSString *basePath = [[kAppDelegate applicationDocumentsDirectory] path];
    NSString *strFilePath=[basePath stringByAppendingPathComponent:fileppath];
    BOOL isSuccess = NO;
    @try {
        if(destpath)
            isSuccess = [ZipUnzip unzipFileAtPath:strFilePath toDestination:[basePath stringByAppendingPathComponent:destpath]];
        else{
            if(![[NSFileManager defaultManager] fileExistsAtPath:[strFilePath stringByDeletingPathExtension]])
                [[NSFileManager defaultManager] createDirectoryAtPath:[strFilePath stringByDeletingPathExtension] withIntermediateDirectories:NO attributes:nil error:nil];
            
            isSuccess = [ZipUnzip unzipFileAtPath:strFilePath toDestination:[strFilePath stringByDeletingPathExtension]];
        }
        if(isSuccess){
            [[NSFileManager defaultManager] removeItemAtPath:strFilePath error:nil];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
        return isSuccess;
    }
    
}

#pragma mark - Date Helper
+(NSString*)showDateWithCustomFormat:(NSString *)formatstr Date:(NSDate *)datestr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:formatstr];
    return [formatter stringFromDate:datestr];
}

+(NSString*)showDateWithCustomFormat:(NSString *)formatstr UnixTimeStamp:(long long)unixFormat{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:formatstr];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)unixFormat]];
}

+(NSString*)showDateWithCustomFormat:(NSString *)formatstr DateString:(NSString *)datestr SourceFormatOrNil:(NSString *)sourceformat{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if(sourceformat)
        [formatter setDateFormat:sourceformat];
    else{
        [formatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    NSDate *tdate = [formatter dateFromString:datestr];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:formatstr];
    
    return [formatter stringFromDate:tdate];
}

+(NSString *)dateDiffinWordsFromString:(NSString *)dateString withFormat:(NSString *)dateFormat{
    if(!dateFormat) dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSLocale *enUSPOSIXLocale;
    enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    assert(enUSPOSIXLocale != nil);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:dateFormat];
    
    NSDate *date1 = [dateFormatter dateFromString:dateString];
    
    return [self dateDiffinWordsFromDate:date1];
}

+(NSString *)dateDiffinWordsFromUnixTimeStamp:(long long)unixFormat{
    return [self dateDiffinWordsFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)unixFormat]];
}

+(NSString *)dateDiffinWordsFromDate:(NSDate *)date1{
    
    NSLocale *enUSPOSIXLocale;
    enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    assert(enUSPOSIXLocale != nil);
    
    NSDate *now = [NSDate date];
    double time = [date1 timeIntervalSinceDate:now];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setLocale:enUSPOSIXLocale];
    //[dateFormatter1 setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter1 setDateFormat:@"MMM dd, yyyy, HH:mm"];
    
    now = nil;
    time *= -1;
    if(time < 1) {
        return [NSString stringWithFormat:@"%@ IST",[dateFormatter1 stringFromDate:date1]];
    } else if (time < 60) {
        return @"now";
    } else if (time < 3600) {
        int diff = round(time / 60);
        if (diff == 1)
            return [NSString stringWithFormat:@"1 Minute ago"];
        return [NSString stringWithFormat:@"%d Minutes ago", diff];
    } else if (time < 86400) {
        int diff = round(time / 60 / 60);
        if (diff == 1)
            return [NSString stringWithFormat:@"1 Hour ago"];
        return [NSString stringWithFormat:@"%d Hours ago", diff];
    } else if (time < 604800) {
        int diff = round(time / 60 / 60 / 24);
        if (diff == 1)
            return [NSString stringWithFormat:@"Yesterday"];
        if (diff == 7)
            return [NSString stringWithFormat:@"Last week"];
        return[NSString stringWithFormat:@"%d Days ago", diff];
    } else {
        int diff = round(time / 60 / 60 / 24 / 7);
        if (diff == 1)
            return [NSString stringWithFormat:@"Last week"];
        return [NSString stringWithFormat:@"%d Weeks ago", diff];
    }
    date1 = nil;
}

+(NSInteger )dateDiffFromUnixTimeStamp:(long long)unixFormat{
    NSDate *date1=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)unixFormat];
    NSLocale *enUSPOSIXLocale;
    enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    assert(enUSPOSIXLocale != nil);
    
    NSDate *now = [NSDate date];
    return [now timeIntervalSinceDate:date1];
    
    //    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    //    [dateFormatter1 setLocale:enUSPOSIXLocale];
    //    //[dateFormatter1 setFormatterBehavior:NSDateFormatterBehavior10_4];
    //    [dateFormatter1 setDateFormat:@"MMM dd, yyyy, HH:mm"];
    //
    //    now = nil;
    //    time *= -1;
    //    if(time < 1) {
    //        return [NSString stringWithFormat:@"%@ IST",[dateFormatter1 stringFromDate:date1]];
    //    } else if (time < 60) {
    //        return @"now";
    //    } else if (time < 3600) {
    //        int diff = round(time / 60);
    //        if (diff == 1)
    //            return [NSString stringWithFormat:@"1 Minute ago"];
    //        return [NSString stringWithFormat:@"%d Minutes ago", diff];
    //    } else if (time < 86400) {
    //        int diff = round(time / 60 / 60);
    //        if (diff == 1)
    //            return [NSString stringWithFormat:@"1 Hour ago"];
    //        return [NSString stringWithFormat:@"%d Hours ago", diff];
    //    } else if (time < 604800) {
    //        int diff = round(time / 60 / 60 / 24);
    //        if (diff == 1)
    //            return [NSString stringWithFormat:@"Yesterday"];
    //        if (diff == 7)
    //            return [NSString stringWithFormat:@"Last week"];
    //        return[NSString stringWithFormat:@"%d Days ago", diff];
    //    } else {
    //        int diff = round(time / 60 / 60 / 24 / 7);
    //        if (diff == 1)
    //            return [NSString stringWithFormat:@"Last week"];
    //        return [NSString stringWithFormat:@"%d Weeks ago", diff];
    //    }
    //    date1 = nil;
}

+(NSDate *) getDateFromUnixFormat:(NSTimeInterval)unixFormat
{
    return [NSDate dateWithTimeIntervalSince1970:unixFormat];
}

+(NSDate*)getDateWithCustomFormat:(NSString *)sourceformat DateString:(NSString *)datestr{
//    NSTimeZone [NSTimeZone localTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if(sourceformat){
        if([datestr length]<=10) datestr = [datestr stringByAppendingString:@" +0000"];
        [formatter setDateFormat:sourceformat];
    }
    else{
        [formatter setDateStyle:NSDateFormatterLongStyle];
    }

    return [formatter dateFromString:datestr];
}

#pragma mark - Others Helper

+(NSString *) getStringByRemovingSpecialChars:(NSString *)str{//   [\\*/?:<>|\"]
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[\\*?:<>|\"]"
                                                                                options:0
                                                                                  error:NULL];
    NSString *cleanedString = [expression stringByReplacingMatchesInString:str
                                                                   options:0
                                                                     range:NSMakeRange(0, str.length)
                                                              withTemplate:@""];
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    return cleanedString;
}

+(BOOL)isNumeric:(NSString* __nullable)inputString{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}

+(NSInteger)maxAllowedLenthInNavigationTitle{
    // for iphone only
//    if([[UIScreen mainScreen] bounds].size.width>414){ // landscape - 736
    if([[UIScreen mainScreen] bounds].size.width>375){ // landscape - 667 - iPhone 6/6S plus
        return 23.0;
    }
    else if([[UIScreen mainScreen] bounds].size.width>320){ // landscape -  568 or 480 - iPhone 6/6S
        return 20.0;
    }
    else { // below iPhone 6
        return 15.0;
    }
}

#pragma mark - Currency helper
+(NSString *)getCurrSymbolWithCurrCode:(NSString *)currcode{
    if(currcode==nil || [currcode length]==0 || [currcode isEqualToString:@"(null)"]) currcode = @"GBP";
    
    NSString *strcurrsymbol = currcode;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setCurrencyCode:currcode];
    //[currencyFormatter setNegativeFormat:@"¤#,##0.00"];
    NSString* strval = [currencyFormatter stringFromNumber:[NSNumber numberWithInt:0]];
    strcurrsymbol  = [[[strval stringByReplacingOccurrencesOfString:@"0.00" withString:@""] stringByReplacingOccurrencesOfString:@"0" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return strcurrsymbol;
}


+(void)getLocaleCurrencies{
    
    if(kAppDelegate.dicCurrencies)
        [kAppDelegate.dicCurrencies removeAllObjects];
    
    kAppDelegate.dicCurrencies = [[NSMutableDictionary alloc] init];
    for(NSString* strcode in [NSLocale ISOCurrencyCodes]){
        [kAppDelegate.dicCurrencies setObject:strcode forKey:[strcode uppercaseString]];
        [kAppDelegate.dicCurrencies setObject:strcode forKey:[[self getCurrSymbolWithCurrCode:strcode] uppercaseString]];
    }
}

+(NSString *__nullable)getCurrencyFormatWithCurrency:(NSString * __nullable) selcurr
                                               Value:(double)val
{
    
    
    
    
    if(selcurr && [selcurr length]==0)
        selcurr=nil;
    
    
    return [self getCurrencyFormatWithCurrency:selcurr Value:val MaxFractionDigit:2];
}

+(NSString *__nullable)getCurrencyFormatWithCurrency:(NSString * __nullable) selcurr
                                               Value:(double)val
                                    MaxFractionDigit:(NSInteger)maxdigit
{
    if(!selcurr || [selcurr length]==0)
        selcurr = [kUserDefaults  valueForKey:@"defaultcurrency"];
    if(!selcurr || [selcurr length]==0) selcurr=@"GBP";
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setCurrencyCode:selcurr];
    
    [currencyFormatter setMaximumFractionDigits:maxdigit];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
    
    return [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:val]];
}


#pragma mark - convert Currency From CurrencyCode
+(double)convertCurrencyFromCurrencyCode:(NSString *) fromCurr  Value:(double)val  ToCurrencyCode:(NSString *)toCurr ExchangeRate:(double)exchangerate  DefaultCurrency:(NSString *)defcurr{
    
    if(fromCurr==nil || [fromCurr length]==0) fromCurr = defcurr;
    if(toCurr==nil || [toCurr length]==0) toCurr = defcurr;
    
    double resValues = val;
    @try {
        
        if([fromCurr length]>0 && [toCurr length]>0 && ![fromCurr isEqualToString:@"(null)"] && ![toCurr isEqualToString:@"(null)"])
        {
            
            if(![[fromCurr uppercaseString] isEqualToString:[toCurr uppercaseString]])
            {
                if(exchangerate>0){
                    if([[fromCurr uppercaseString] isEqualToString:defcurr])
                    {
                        resValues = val * exchangerate;
                        // CGFloat nearest = floorf(resValues * 100 + 0.5) / 100;
                        //resValues =nearest;
                        resValues =  round (resValues * 100.0) / 100.0;
                        //resValues = ceilf(resValues * 100) / 100; //by faizan on 9 may
                        
                    }
                    else{
                        double revexchangerate = 1.0 / exchangerate;
                        resValues = val * revexchangerate;
                    }
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        //[self writeErrorLogWithNo:0 Description:[exception description] Method:[NSString stringWithUTF8String:__func__]];
    }
    return resValues;
}






#pragma mark - Customer Helper
+ (void)getNewCustomerNumberWithRepId:(NSString *)repid Company:(NSInteger)compid CompletionBlock:(void(^__nonnull) (NSString * __nullable newcustomernumber)) completionblock{
    
    __block NSInteger numCustomer = 1;
    
    NSString *strrepid = repid;
    if([CommonHelper isNumeric:repid])
        strrepid = [NSString stringWithFormat:@"%02li",(long)[repid integerValue]];
    
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *customerInfo = [[NSFetchRequest alloc] init];
    [customerInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [customerInfo setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:customerInfo error:&error];
    if([resultsSeq count]>0){
        numCustomer = [[[resultsSeq lastObject] valueForKey:@"next_customer_no"] integerValue];
        if(numCustomer==0) numCustomer++;
    }
    __block NSString *customerNumberString =[NSString stringWithFormat:@"%@T%04li",strrepid,(long)numCustomer];
    
    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",kAppDelegate.repId,@"repid",[NSNumber numberWithInteger:0],@"value", nil];
        [self DownloadDataWithAPIName:(NSString *)kNextCustomerAPI HTTPMethod:HTTTPMethodGET Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){
                if([[[response objectForKey:@"status"] objectForKey:@"success"] boolValue]){
                    NSInteger servercustmoerseq = [[[response objectForKey:@"data"] objectForKey:@"id"] integerValue];
                    if(numCustomer<servercustmoerseq){
                        numCustomer = servercustmoerseq;
                        customerNumberString =[NSString stringWithFormat:@"%@T%04li",strrepid,(long)numCustomer];
                    }
                }
            }
            if([self checkIfCustomerNoAlreadyExistWithCustomerNo:customerNumberString]){
                [self setNextCustomerNumberWithRepId:repid CompanyId:compid NextCustomerSequence:numCustomer+1];
                [self getNewCustomerNumberWithRepId:repid Company:compid CompletionBlock:completionblock];
            }
            else{
                completionblock(customerNumberString);
            }
        }];
    }
    else{
        if([self checkIfCustomerNoAlreadyExistWithCustomerNo:customerNumberString]){
            [self setNextCustomerNumberWithRepId:repid CompanyId:compid NextCustomerSequence:numCustomer+1];
            [self getNewCustomerNumberWithRepId:repid Company:compid CompletionBlock:completionblock];
        }
        else{
            completionblock(customerNumberString);
        }
    }
}

+(BOOL)checkIfCustomerNoAlreadyExistWithCustomerNo:(NSString *)customerno{
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *customerInfo = [[NSFetchRequest alloc] init];
    [customerInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref==%@",customerno];
    [customerInfo setPredicate:predicate];
    
    [customerInfo setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:customerInfo error:&error];
    
    return [resultsSeq count]>0;
}

+(void)setNextCustomerNumberWithRepId:(NSString *)repid CompanyId:(NSInteger)compid NextCustomerSequence:(NSInteger)nextcustomerno{
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [transactionInfo setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];
    
    NSManagedObject* sequence = nil;
    if([resultsSeq count]>0){
        sequence=[resultsSeq lastObject];
        [sequence setValue:[NSNumber numberWithInteger:nextcustomerno] forKey:@"next_customer_no"];
        
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
    
    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",kAppDelegate.repId,@"repid",[NSNumber numberWithInteger:nextcustomerno],@"value", nil];
        [self DownloadDataWithAPIName:(NSString *)kNextCustomerAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){
                
            }
        }];
    }
}


#pragma mark - Batch Helper
+ (void)getNewBatchNumberWithRepId:(NSString *)repid Company:(NSInteger)compid CompletionBlock:(void(^__nonnull) (NSInteger newbatchnumber)) completionblock{
    
    __block NSInteger numBatch = 1;
    
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *customerInfo = [[NSFetchRequest alloc] init];
    [customerInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [customerInfo setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:customerInfo error:&error];
    
    if([resultsSeq count]>0){
        numBatch = [[[resultsSeq lastObject] valueForKey:@"next_batch_no"] integerValue];
        if(numBatch==0) numBatch++;
    }
    
    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",kAppDelegate.repId,@"repid",[NSNumber numberWithInteger:0],@"value", nil]; //nil];
        [self DownloadDataWithAPIName:(NSString *)kNextBatchAPI HTTPMethod:HTTTPMethodGET Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){
                if([[[response objectForKey:@"status"] objectForKey:@"success"] boolValue]){
                    NSInteger serverbatchseq = [[[response objectForKey:@"data"] objectForKey:@"id"] integerValue];
                    if(numBatch<serverbatchseq){
                        numBatch = serverbatchseq;
                    }
                }
            }
            if([self checkIfBatchNoAlreadyExistWithBatchNo:numBatch]){
                [self setNextBatchNumberWithRepId:repid CompanyId:compid NextBatchSequence:numBatch+1];
                [self getNewBatchNumberWithRepId:repid Company:compid CompletionBlock:completionblock];
            }
            else{
                completionblock(numBatch);
            }
        }];
    }
    else{
        if([self checkIfBatchNoAlreadyExistWithBatchNo:numBatch]){
            [self setNextBatchNumberWithRepId:repid CompanyId:compid NextBatchSequence:numBatch+1];
            [self getNewBatchNumberWithRepId:repid Company:compid CompletionBlock:completionblock];
        }
        else{
            completionblock(numBatch);
        }
    }
}

+(BOOL)checkIfBatchNoAlreadyExistWithBatchNo:(NSInteger)batchno{
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *customerInfo = [[NSFetchRequest alloc] init];
    [customerInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"batch_no==%li",batchno];
    [customerInfo setPredicate:predicate];
    
    [customerInfo setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:customerInfo error:&error];
    
    if([resultsSeq count]==0){
        NSEntityDescription *entitySquence1 = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSFetchRequest *transInfo = [[NSFetchRequest alloc] init];
        [transInfo setEntity:entitySquence1];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"batch_no==%li",batchno];
        [transInfo setPredicate:predicate];
        
        [transInfo setFetchLimit:1];
        
        NSArray *resultsSeq1 = [kAppDelegate.managedObjectContext executeFetchRequest:transInfo error:&error];
        
        return [resultsSeq1 count]>0;
    }
    
    return [resultsSeq count]>0;
}

+(void)setNextBatchNumberWithRepId:(NSString *)repid CompanyId:(NSInteger)compid NextBatchSequence:(NSInteger)nextbatchno{
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [transactionInfo setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];
    
    NSManagedObject* sequence = nil;
    if([resultsSeq count]>0){
        sequence=[resultsSeq lastObject];
        [sequence setValue:[NSNumber numberWithInteger:nextbatchno] forKey:@"next_batch_no"];
        
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
    
    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",kAppDelegate.repId,@"repid",[NSNumber numberWithInteger:nextbatchno],@"value", nil];
        [self DownloadDataWithAPIName:(NSString *)kNextBatchAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){
                
                
            }
        }];
    }
}

#pragma mark - Batch Helper ENDED







#pragma mark - Delivery Address Helper
+ (NSString *)getNewDeliveryNumberWithRepId:(NSString *)repid CustomerId:(NSString *)customerid{
    
    __block NSInteger numDelId = 1;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString *entityName=@"CUST";
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:10];
    
    NSString *strrepid=kAppDelegate.repId ;
    
    NSString *prefixstr = [NSString stringWithFormat:@"%@T",strrepid];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address BEGINSWITH [cd]%@",customerid,prefixstr];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(resultsSeq){
        [resultsSeq enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger latestVal = [[[obj valueForKey:@"delivery_address"] substringFromIndex:prefixstr.length] integerValue];
            latestVal++;
            if(latestVal> numDelId) numDelId = latestVal;
        }];
    }
    return [NSString stringWithFormat:@"%@%03li",prefixstr,(long)numDelId];
}


#pragma mark - Packs Helper
+(NSString * __nullable)getFieldValueWithFieldName:(NSString *__nullable)fieldName Source:(NSManagedObject * __nonnull)sourcObject{
    if([fieldName isEqual:[NSNull null]] || !fieldName || [fieldName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0)
        return @"";
    else{
        return [NSString stringWithFormat:@"%@",[sourcObject valueForKey:fieldName.lowercaseString]];
    }
}





#pragma mark - Pricing Helper
+(NSDictionary *) getProductPrices:(NSDictionary *)prcConfigDic Product:(NSManagedObject *)product Customer:(NSManagedObject *)customer SelectedPriceRow:(NSDictionary *) selPrcRow DefaultPrice:(NSString*)defultPrice Transaction:(NSManagedObject * __nullable) transactioninfo  PriceConfig:(NSDictionary*)priceConfig UserConfig:(NSDictionary * _Nullable)userConfig{
    
    if ([defultPrice length]==0) {
        defultPrice= @"price1";
    }
    
    //Add Company currency Symbol
    NSString *currCode=[kUserDefaults  valueForKey:@"defaultcurrency"];
    //  UserConfigDelegate.CustInfo.ExchangeRate
 //   NSDictionary *currencyDict= [self getExcangeRateArray:[customer valueForKey:@"curr"]];
    
    __block NSMutableDictionary *dicSelPrcRow=[selPrcRow mutableCopy];
    //getting sidebar prclbl & prcfld
   // NSDictionary *dicSidebar=[prcConfigDic objectForKey:@"sidebarlabels"];//no longer used
    
    NSArray *orderpanellabelsArry=[prcConfigDic objectForKey:@"orderpanellabels"];
    
    
    
    //code by Amit Pant for customer pricelist
    //on 20160107
    NSString *strCustPriceList=@"";
    
    if (customer!=nil && [customer valueForKey:@"pricegroup"]!=nil && [[customer valueForKey:@"pricegroup"] length]>0 && [CommonHelper isNumeric:[customer valueForKey:@"pricegroup"]]  ){
        strCustPriceList=[NSString stringWithFormat:@"%ld",(long)[[customer valueForKey:@"pricegroup"] integerValue]];
        
    }
    //for testing for puspose
    else{
        if(customer!=nil)
            strCustPriceList=@"2";
    }
    if (strCustPriceList.length>0 && dicSelPrcRow!=nil && dicSelPrcRow.count==0){
        NSString *custdefPrcRow=[NSString stringWithFormat:@"price%@",strCustPriceList];
        
        NSArray *dicPrcRows = [prcConfigDic objectForKey:@"pricetablabels"] ;
        if (dicPrcRows !=nil) {
            [dicPrcRows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *strField=[obj valueForKey:@"field"];
                if (strField !=nil && strField.length>0 && [[strField lowercaseString] isEqualToString:custdefPrcRow]) {
                    dicSelPrcRow=[obj mutableCopy];
                }
            }];
            
        }
    }
    //code ended here
    
   // if ([orderpanellabelsArry count]>0) {
        
    if ([prcConfigDic objectForKey:@"pricetablabels"] !=nil) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"includeinsidebar==1"];
        
        NSArray *arrSidebarPrices=[[prcConfigDic objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
        
        NSMutableArray *arrSidebar=[[NSMutableArray alloc] init];
        NSMutableArray *arrOrderPanel=[[NSMutableArray alloc] init];
        //for getting SelectedPriceRow
        
        __block NSString *selectedpricerow=@"";
        __block NSString *selectedpriceLabel=@"";
        
        if (dicSelPrcRow!=nil && dicSelPrcRow.count>0) {
            selectedpricerow=[[dicSelPrcRow valueForKey:@"field"] lowercaseString];
            selectedpriceLabel=[dicSelPrcRow valueForKey:@"label"] ;
        }
        
        
        if (selectedpricerow==nil || [selectedpricerow length]==0) {
           /* NSArray *arrPricetablabels=[prcConfigDic objectForKey:@"pricetablabels"];
            if (arrPricetablabels!=nil) {
                [arrPricetablabels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[obj objectForKey:@"isdefault"] boolValue]) {
                        selectedpricerow =[obj objectForKey:@"field"];
                    }
                }];
            }*/
            if (selectedpricerow==nil || [selectedpricerow length]==0){
                NSDictionary *dicSelPriceRow=[kUserDefaults  objectForKey:@"SelPriceRow"];
                
                if (dicSelPriceRow!=nil && dicSelPrcRow.count>0){
                    selectedpricerow=[dicSelPriceRow valueForKey:@"field"];
                    selectedpriceLabel=[dicSelPrcRow valueForKey:@"label"] ;
                } else{
                    selectedpricerow=[defultPrice lowercaseString];
                    selectedpriceLabel =[[arrSidebarPrices lastObject]valueForKey:@"label"];//[[orderpanellabelsArry lastObject]valueForKey:@"label"];//[[arrSidebarPrices lastObject]valueForKey:@"label"];
                }
            }
        }
        
        
        [arrSidebarPrices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
       // [orderpanellabelsArry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *prclbl=[obj objectForKey:@"label"];
            NSString *prcfld=[[obj objectForKey:@"field"] lowercaseString];
            double priceValue=[[product valueForKey:prcfld] doubleValue];
        
            double prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound ) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/

            
            [arrSidebar addObject:@{@"caption":prclbl, @"field":prcfld, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:nil Value:prcval], @"CurrCode" :currCode}];
            // [arrSidebar addObject:@{@"caption":prclbl,  @"value" : [NSNumber numberWithDouble:prcval]}];
        }];
        
        if (arrSidebar.count==1 && dicSelPrcRow!=nil && dicSelPrcRow.count>0 ) {
            NSString *prclbl;//=[dicSelPrcRow valueForKey:@"label"];//Comment for remove leakes
            NSString *prcfld;//=[dicSelPrcRow valueForKey:@"field"];//Comment for remove leakes
            
            double priceValue=[[product valueForKey:selectedpricerow] doubleValue];
            double prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound ) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
            //if applydiscountagainpricerowselected is Selected Price Row then first row also change by selected price.
            if(prcConfigDic && ![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqual:[NSNull null]] && [[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] length]>0  ){
                if(prcConfigDic && ![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqual:[NSNull null]] && [[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] length]>0  ){
                    if (![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqualToString:@"Selected Price Row"]) {
                        prclbl=[[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] valueForKey:@"label"];
                        
                        
                        double priceValue=[[product valueForKey:[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"]] doubleValue];
                        
                        double prcval=priceValue;
                        /*if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound ) {//For when exchange rate Apply
                            prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
                        }*/
                    }
                }
            }//end
            
            
            prclbl=[dicSelPrcRow valueForKey:@"label"];
           // prcfld=[dicSelPrcRow valueForKey:@"field"];//Comment for remove leakes
            
             priceValue=[[product valueForKey:selectedpricerow] doubleValue];
            
             prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound ) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
           
            
            //If transaction have Price
            if (transactioninfo ) {
                
                priceValue=[[transactioninfo valueForKey:@"saleprice"] doubleValue];
                
                prcval=priceValue;
               /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]) {//For when exchange rate Apply
                    prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
                }*/
                
                
                prclbl=@"Nett";
            }//end
            
           
            
            
            
            [arrSidebar addObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:nil Value:prcval], @"CurrCode" :currCode}];
            
        }else if (arrSidebar.count>1 && dicSelPrcRow!=nil && dicSelPrcRow.count>0){
            
            NSString *prclbl=[dicSelPrcRow valueForKey:@"label"];
            NSString *prcfld=[dicSelPrcRow valueForKey:@"field"];
            
            double priceValue=[[product valueForKey:selectedpricerow] doubleValue];
            
            double prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound ) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
            
            //if applydiscountagainpricerowselected is Selected Price Row then first row also change by selected price.
            if(prcConfigDic && ![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqual:[NSNull null]] && [[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] length]>0  ){
                
                if (![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqualToString:@"Selected Price Row"]) {
                    prclbl=[[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] valueForKey:@"label"];
                   
//                    prcfld=[dicSelPrcRow valueForKey:@"field"];
                    
                     priceValue=[[product valueForKey:[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"]] doubleValue];
                     prcval=priceValue;
                   /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound) {//For when exchange rate Apply
                        prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
                    }*/
                    
                    
                    
                }
                if ([arrSidebar count]>0)
                [arrSidebar replaceObjectAtIndex:0 withObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:nil Value:prcval], @"CurrCode" :currCode}];
            }
            
            
            
            
            
            prclbl=[dicSelPrcRow valueForKey:@"label"];
            prcfld=[dicSelPrcRow valueForKey:@"field"];
            
            priceValue=[[product valueForKey:selectedpricerow] doubleValue];
            prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
            
            //If transaction have Price
            if (transactioninfo ) {
                
                priceValue=[[transactioninfo valueForKey:@"saleprice"] doubleValue];
                prcval=priceValue;
//                if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]) {//For when exchange rate Apply
//                    prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
//                }
                
                
                prclbl=@"Nett";
            }//end
            
            if ([arrSidebar count]>1)
            [arrSidebar replaceObjectAtIndex:1 withObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:nil Value:prcval], @"CurrCode" :currCode}];
        }
        
        
        
        //Very first time if default then show default price from web config otherwise show price1.
        if (arrSidebar.count>0 )//&& dicSelPrcRow.count==0) {
        {
           
            //if no selected Row default customer select
            NSDictionary *dictSelPriceRow;
            if ([kUserDefaults  objectForKey:@"SelPriceRow"] ) {
                 dictSelPriceRow=[kUserDefaults  objectForKey:@"SelPriceRow"];
                
            }else{
                dictSelPriceRow=[[[priceConfig objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"field==%@",selectedpricerow]] lastObject];
            }
            NSString *prcfld=[dictSelPriceRow valueForKey:@"label"];
            
            double priceValue=[[product valueForKey:selectedpricerow] doubleValue];;
            double prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue] && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
            
            NSString *prclbl=[dicSelPrcRow valueForKey:@"label"];
            //If transaction have Price
            if (transactioninfo ) {
                
                priceValue=[[transactioninfo valueForKey:@"saleprice"] doubleValue];
                prcval=priceValue;
//                if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]) {//For when exchange rate Apply
//                    prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
//                }
                
                prclbl=@"Nett";
            }//end
            
            
            //if applydiscountagainpricerowselected is Selected Price Row then first row also change by selected price.
            if(prcConfigDic && ![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqual:[NSNull null]] && [[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] length]>0  ){
                
                if (![[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] isEqualToString:@"Selected Price Row"]) {
                    prclbl=[[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] valueForKey:@"label"];
                    
                    priceValue=[[product valueForKey:[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"]] doubleValue];
                    prcval=priceValue;
                  /*  if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]  && customer && ![prcfld rangeOfString:[self getCurrSymbolWithCurrCode:[customer valueForKey:@"curr"]]].location == NSNotFound) {//For when exchange rate Apply
                        prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
                    }*/
                    
                }
                
                if(prclbl && ([arrSidebar count]>0))
                    [arrSidebar replaceObjectAtIndex:0 withObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:nil Value:prcval], @"CurrCode" :currCode}];
            }
            
            
            
            
            
            NSString *strSymbol=nil;;
            if(![[priceConfig objectForKey:@"pricetablabels"] isEqual:[NSNull null]] ){
                
                NSPredicate *predicate=nil;
                if ([selectedpriceLabel length]>0) {
                    predicate =[NSPredicate predicateWithFormat:@"field ==[c] %@ && label ==[c] %@",selectedpricerow,selectedpriceLabel];
                }else
                    predicate =[NSPredicate predicateWithFormat:@"field ==[c] %@ ",selectedpricerow];
                
                NSArray *filterArr=[[priceConfig objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
                if ([filterArr count]>0) {
                    prclbl=[[filterArr firstObject] valueForKey:@"label"];
                    strSymbol= [[[[filterArr firstObject] valueForKey:@"label"] componentsSeparatedByString:@" "] lastObject];
                }
            }//ended
            

            
            
            priceValue=[[product valueForKey:selectedpricerow] doubleValue];
            prcval=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]  && customer ) {//For when exchange rate Apply
                prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
            
            if ([selPrcRow count]==0) {
                prclbl= selectedpriceLabel;
            }else
                prclbl=selectedpricerow;
            
            
            
            
            //If transaction have Price
            if (transactioninfo ) {
                priceValue=[[transactioninfo valueForKey:@"saleprice"] doubleValue];
                prcval=priceValue;
               /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]) {//For when exchange rate Apply
                    prcval = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
                }*/
                
                prclbl=@"Nett";
            }//end
            
            if ([kAppDelegate.dicCurrencies valueForKey:strSymbol]) {
                currCode=[kAppDelegate.dicCurrencies valueForKey:strSymbol];
            }
            
            
            if ([arrSidebar count]>1) {
                [arrSidebar replaceObjectAtIndex:1 withObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:currCode Value:prcval], @"CurrCode" :currCode}];
            }else{
                
                [arrSidebar addObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:currCode Value:prcval], @"CurrCode" :currCode}];
            }
            
            
        }//end
        
        
        
       /* __block NSString *listPrclbl=@"";
        __block double listprcval=0;
        [arrSidebarPrices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            listPrclbl=[obj objectForKey:@"label"];
            NSString *listPrcfld=[[obj objectForKey:@"field"] lowercaseString];
            listprcval=[[product valueForKey:listPrcfld] doubleValue];;
            
            [arrOrderPanel addObject:@{@"caption":listPrclbl, @"value" : [NSNumber numberWithDouble:listprcval]}];
            
            /*if (idx==0 && arrSidebarPrices.count==1)
             [arrOrderPanel addObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval]}];*
        }];
        
        
        if (arrOrderPanel.count==1 ) {
            if ( dicSelPrcRow!=nil && dicSelPrcRow.count>0) {
                NSString *prclbl=[dicSelPrcRow valueForKey:@"label"];
                
                double prcval=[[product valueForKey:selectedpricerow] doubleValue];
                [arrOrderPanel addObject:@{@"caption":prclbl, @"value" : [NSNumber numberWithDouble:prcval]}];
            }else
            {
                [arrOrderPanel addObject:@{@"caption":listPrclbl, @"value" : [NSNumber numberWithDouble:listprcval]}];
            }
            
        }*/
        
        //Add Header Discount
        
        NSArray *stockArr = [kUserDefaults  objectForKey:@"StockBandArray"];
        if ([[kAppDelegate.transactionInfo valueForKey:@"custdisc"] doubleValue]>0 && [arrSidebar count]>0 && [[[priceConfig valueForKey:@"orderconfigs"] valueForKey:@"headerdiscountenabled" ] boolValue]){//&& [[[_priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"headerdiscountenabled" ] boolValue]) {
            //Case of All
            NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]initWithDictionary:[arrSidebar lastObject]];
            double ordprice=[[tempDic valueForKey:@"value"] doubleValue];
            
            double priceValue=ordprice-((ordprice*[[kAppDelegate.transactionInfo valueForKey:@"custdisc"] doubleValue])/100);
            double saveprice=priceValue;
           /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]) {//For when exchange rate Apply
                saveprice = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
            }*/
            
            
            [tempDic setValue:[NSNumber numberWithDouble:saveprice] forKey:@"value"];
           
            if ([arrSidebar count]>0) {
                [arrSidebar replaceObjectAtIndex:([arrSidebar count]-1) withObject:tempDic];
            }
            
       
        }else if([arrSidebar count]>0 && [stockArr count]>0){
            
            NSString *priceband=[[product valueForKey:@"priceband"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"custband ==%@ && prodband == %@",[customer valueForKey:@"acc_ref"],priceband];
            NSArray *filterArr=[stockArr filteredArrayUsingPredicate:predicate];
            //   DebugLog(@"filterArr %@",filterArr);11
            if ([filterArr count]>0) {
                NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]initWithDictionary:[arrSidebar lastObject]];
                double ordprice=[[tempDic valueForKey:@"value"] doubleValue];
                
                double priceValue=ordprice-((ordprice*[[[filterArr lastObject] valueForKey:@"disc"] doubleValue])/100);
                double saveprice=priceValue;
               /* if ([[prcConfigDic valueForKey:@"useexchangerateconversion"] boolValue]) {//For when exchange rate Apply
                    saveprice = [self convertCurrencyFromCurrencyCode:nil Value:priceValue ToCurrencyCode:[customer valueForKey:@"curr"] ExchangeRate:[[currencyDict valueForKey:@"exchangerate"] doubleValue] DefaultCurrency:currCode];
                }*/
                
                [tempDic setValue:[NSNumber numberWithDouble:saveprice] forKey:@"value"];
                if ([arrSidebar count]>0)
                [arrSidebar replaceObjectAtIndex:([arrSidebar count]-1) withObject:tempDic];
            }
            
        }
        
       /*/Last price selected
        if ( dicSelPrcRow==nil && dicSelPrcRow.count==0 && [[prcConfigDic objectForKey:@"applydiscountagainpricerowselected"] length] ==0 && ![[userConfig objectForKey:@"lastorderpriceasdefaultorderpriceenabled"] isEqual:[NSNull null]] && [[userConfig valueForKey:@"lastorderpriceasdefaultorderpriceenabled"] boolValue] && customer !=nil) {
            
            NSSortDescriptor *lastUsedSortDescription = [NSSortDescriptor sortDescriptorWithKey:@"invoicehead.invoiced_date" ascending:YES];
            NSArray *sortedArray = [[[product valueForKeyPath:@"invoicelines"] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:lastUsedSortDescription]];
            
            
       //  NSManagedObject   *obj=[commonMethods findLastPaid:product Cust:customer];
            
            if([sortedArray count]){
                
                
                
                NSManagedObject *invinfo = [sortedArray firstObject];
                double prcval= [[invinfo valueForKey:@"price_invoiced"] doubleValue];
                if ([arrSidebar count]>1 && prcval>0)
                    [arrSidebar replaceObjectAtIndex:1 withObject:@{@"caption":@"Last", @"value" : [NSNumber numberWithDouble:prcval],@"showPrice":[self getCurrencyFormatWithCurrency:nil Value:prcval], @"CurrCode" :currCode}];
            }
        }
//**********/
        
        
        
        [arrSidebar enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
           // listPrclbl=[obj objectForKey:@"label"];
           // NSString *listPrcfld=[[obj objectForKey:@"field"] lowercaseString];
           // listprcval=[[product valueForKey:listPrcfld] doubleValue];;
            
            NSString * listPrclbl=[obj objectForKey:@"caption"];
            NSString * showPrclbl=[obj objectForKey:@"showPrice"];
            NSString * curr=[obj objectForKey:@"CurrCode"];
            double listprcval=[[obj valueForKey:@"value"] doubleValue];
            
            [arrOrderPanel addObject:@{@"caption":listPrclbl, @"value" : [NSNumber numberWithDouble:listprcval],@"showPrice":showPrclbl, @"CurrCode" :curr}];
            
           
        }];
        
        
        
        if([selectedpriceLabel length]==0 || [selectedpriceLabel isEqualToString:@"(null)"])
            selectedpriceLabel=@"";
            
        
        NSDictionary *dict = @{ @"selectedpricerow" : selectedpricerow, @"selectedpriceLabel" : selectedpriceLabel };
        
        return @{@"sidebar":arrSidebar,@"orderpanel":arrOrderPanel,@"selectedpricerow":dict};
    }
    
    return nil;
}




#pragma mark - Log Helpers
+(void)WriteErrorLogWithMessage:(NSString *)msg TraceMessage:(NSString *)tracemsg IsWarning:(BOOL)iswarning {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   APIToken,@"token",
                                   [[NSDate date] description],@"datetime",
                                   [kAppDelegate identifierForAdvertising],@"deviceudid",
                                   msg,@"logmessage",
                                   tracemsg,@"tracemessage",
                                   nil];

    if(iswarning) [params setObject:@"Warning" forKey:@"action"];
    else [params setObject:@"Error" forKey:@"action"];

    if(kAppDelegate.selectedCompanyId!=0) [params setObject:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"companyid"];
    if(kAppDelegate.loginUserId!=0) [params setObject:[NSNumber numberWithInteger:kAppDelegate.loginUserId] forKey:@"userid"];
    if(kAppDelegate.repId) [params setObject:kAppDelegate.repId forKey:@"repid"];

    [self DownloadDataWithAPIName:(NSString *)kWriteFullLogsAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
        DebugLog(@"Error logs submitted");
    }];
}

+(void)WriteLogWithMessage:(NSString *)msg Description:(NSString *)desc {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   APIToken,@"token",
                                   @"Information",@"action",
                                   [[NSDate date] description],@"datetime",
                                   [kAppDelegate identifierForAdvertising],@"deviceudid",
                                   msg,@"logmessage",
                                   desc,@"tracemessage",
                                   nil];

    if(kAppDelegate.selectedCompanyId!=0) [params setObject:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"companyid"];
    if(kAppDelegate.loginUserId!=0) [params setObject:[NSNumber numberWithInteger:kAppDelegate.loginUserId] forKey:@"userid"];
    if(kAppDelegate.repId) [params setObject:kAppDelegate.repId forKey:@"repid"];

    [self DownloadDataWithAPIName:(NSString *)kWriteFullLogsAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
        DebugLog(@"Error logs submitted");
    }];
}

#pragma mark - colorwithHexString for ordertype color
+ (UIColor *__nullable)colorwithHexString:(NSString *__nullable)hexStr alpha:(CGFloat)alpha;
{
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}
#pragma mark - getExcangeRateArray for Exchange rate array
+ (NSDictionary *__nullable)getExcangeRateArray:(NSString* __nullable)currencyCode
{
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"CONV" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"currencycode==%@",currencyCode];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSError *error = nil;
    NSMutableArray *resultsSeq =[[NSMutableArray alloc]initWithArray: [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    return [resultsSeq firstObject];
    
}

+(BOOL) IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
