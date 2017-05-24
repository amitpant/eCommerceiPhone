//
//  CommonHelper.h
//  mSeller
//
//  Created by Satish Kr Singh on 16/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject

/*! @brief DownloadDataWithAPIName: This method will be used to download/upload data from/to the server
 
 @param  APIName The input value representing the Web API action name
 @param  HTTPMethod POST, GET, PUT etc. Default: GET
 @param  Params This accepts API's parameters in key,value combination
 @param  SaveToPath (optional) save file location can be passed
 @param  ProgressBlock - we can track download/upload progress of the data
 @param  CompletionBlock - block which can return some value to the caller once method execution completed
 
 @return void
 
 */
+(void)DownloadDataWithAPIName:(NSString * __nonnull)apiname HTTPMethod:(HTTTPMethod)httpmethod Params:(NSDictionary * __nonnull)params VirtualSavePath:(nullable NSString *)saveToPath ProgressBlock:(nullable void(^)(long long bytesDownloaded, long long bytesToDownload)) progressblock  CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString * __nullable errormessage ,__nullable id response)) completionblock;

// mandatory parameters - httpmethod, filename
/*! @brief DownloadFiles: This method will be used to download/upload files from/to the server

 @param  apis Takes array of api names

 @param  Params This accepts dictionary with API's parameters and additional mandatory parametes i.e. - filename with apiname key for e.g. - [NSDictionary setObject:Params forKey:apiname] - default httpmethod is GET
 @param  SaveToDirectory (optional) directory loaction where downloaded files can be saved
 @param  ProgressBlock - we can track download/upload progress of the data
 @param  CompletionBlock - block which can return some value to the caller once method execution completed

 @return void

 */

+(void)DownloadFilesWithAPIs:(NSArray * __nonnull)apis ParamsAndFileNames:(NSDictionary * __nullable)dicparams ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock;


/*! @brief DownloadFiles: This method will be used to download/upload files from/to the server
 
 @param  paths Takes array of file paths
 
 @param  Params This accepts API's parameters in key,value combination
 @param  SaveToDirectory (optional) directory loaction where downloaded files can be saved
 @param  ProgressBlock - we can track download/upload progress of the data
 @param  CompletionBlock - block which can return some value to the caller once method execution completed
 
 @return void
 
 */
+(void)DownloadDataFiles:(NSArray * __nonnull)paths VirtualDirPath:(nullable NSString *)saveDirectory ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock;

+(void)DownloadDataFiles:(NSArray * __nonnull)paths Params:(NSDictionary * __nullable)dicparams VirtualDirPath:(nullable NSString *)saveDirectory ProgressBlock:(nullable void(^)(long filesDownloaded, long filesToDownload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSInteger successCount, NSInteger failedCount)) completionblock;

+(void)UploadDataWithAPIName:(NSString * __nonnull)apiname HTTPMethod:(HTTTPMethod)httpmethod Params:(NSDictionary * __nonnull)params ProgressBlock:(nullable void(^)(long long bytesUploaded, long long bytesToUpload)) progressblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString * __nullable errormessage ,__nullable id response)) completionblock;

+(void)UploadFilesWithAPI:(NSString * __nonnull)apiname ParamsAndFileNames:(NSArray * __nullable)arrparams ProgressBlock:(nullable void(^)(long filesUploaded, long filesToUpload)) progressfilesblock CompletionBlock:(void(^__nonnull) (BOOL issuccess, NSString *__nullable errormessage, NSArray *__nullable successBatches, NSInteger failedCount)) completionblock;

+(id __nullable)loadFileDataWithVirtualFilePath:(NSString * __nonnull)fileppath;

+(BOOL)UnzipFileWithVirtualFilePath:(NSString * __nonnull)fileppath DestinationPath:(NSString * __nullable)destpath;


// to show customized date format
+(NSDate *__nullable) getDateFromUnixFormat:(NSTimeInterval)unixFormat;
+(NSDate*__nullable)getDateWithCustomFormat:(NSString *__nullable)sourceformat DateString:(NSString *__nullable)datestr;

+(NSString *__nullable)dateDiffinWordsFromDate:(NSDate *__nonnull)date1;
+(NSString *__nullable)dateDiffinWordsFromUnixTimeStamp:(long long)unixFormat;
+(NSInteger )dateDiffFromUnixTimeStamp:(long long)unixFormat;
+(NSString *__nullable)dateDiffinWordsFromString:(NSString *__nonnull)dateString withFormat:(NSString *__nullable)dateFormat;
+(NSString*__nullable)showDateWithCustomFormat:(NSString *__nonnull)formatstr DateString:(NSString *__nonnull)datestr SourceFormatOrNil:(NSString *__nullable)sourceformat;
+(NSString*__nullable)showDateWithCustomFormat:(NSString *__nonnull)formatstr Date:(NSDate *__nullable)datestr;
+(NSString*__nullable)showDateWithCustomFormat:(NSString *__nonnull)formatstr UnixTimeStamp:(long long)unixFormat;

+(NSString *__nullable) getStringByRemovingSpecialChars:(NSString *__nullable)str;
+(BOOL)isNumeric:(NSString* __nullable)inputString;

+(void)getLocaleCurrencies;

+(NSString *__nullable)getCurrencyFormatWithCurrency:(NSString * __nullable) selcurr
                                     Value:(double)val;

+(NSString *__nullable)getCurrencyFormatWithCurrency:(NSString * __nullable) selcurr
                                     Value:(double)val
                          MaxFractionDigit:(NSInteger)maxdigit;



#pragma mark - NextCustomerNumber
+ (void)getNewCustomerNumberWithRepId:(NSString * __nullable)repid Company:(NSInteger)compid CompletionBlock:(void(^__nonnull) (NSString * __nullable newcustomernumber)) completionblock;
+(BOOL)checkIfCustomerNoAlreadyExistWithCustomerNo:(NSString *__nullable)customerno;
+(void)setNextCustomerNumberWithRepId:(NSString *__nullable)repid CompanyId:(NSInteger)compid NextCustomerSequence:(NSInteger)nextcustomerno;


#pragma mark - NextBatchNumber
+ (void)getNewBatchNumberWithRepId:(NSString *__nullable)repid Company:(NSInteger)compid CompletionBlock:(void(^__nonnull) (NSInteger newbatchnumber)) completionblock;
+(BOOL)checkIfBatchNoAlreadyExistWithBatchNo:(NSInteger)batchno;
+(void)setNextBatchNumberWithRepId:(NSString *__nullable)repid CompanyId:(NSInteger)compid NextBatchSequence:(NSInteger)nextbatchno;



+ (NSString *__nullable)getNewDeliveryNumberWithRepId:(NSString * __nullable)repid CustomerId:(NSString * __nullable)customerid;


+(NSString * __nullable)getFieldValueWithFieldName:(NSString *__nullable)fieldName Source:(NSManagedObject * __nonnull)sourcObject;




+(NSDictionary *__nullable)getProductPrices:(NSDictionary *__nonnull)prcConfigDic Product:(NSManagedObject *__nonnull)product Customer:( NSManagedObject * __nullable)customer SelectedPriceRow:(NSDictionary * __nullable) dicSelPrcRow  DefaultPrice:(NSString*__nullable)defultPrice Transaction:(NSManagedObject * __nullable) transactioninfo PriceConfig:(NSDictionary*__nullable)priceConfig  UserConfig:(NSDictionary*__nullable)userConfig;

+(NSInteger)maxAllowedLenthInNavigationTitle;

+(void)WriteErrorLogWithMessage:(NSString *__nonnull)msg TraceMessage:(NSString *__nonnull)tracemsg IsWarning:(BOOL)iswarning;

+(void)WriteLogWithMessage:(NSString *__nonnull)msg Description:(NSString *__nonnull)desc;
// convert Currency From CurrencyCode
+(double)convertCurrencyFromCurrencyCode:(NSString *__nonnull) fromCurr  Value:(double)val  ToCurrencyCode:(NSString *__nonnull)toCurr ExchangeRate:(double)exchangerate  DefaultCurrency:(NSString *__nonnull)defcurr;
+(NSString *__nonnull)getCurrSymbolWithCurrCode:(NSString *__nonnull)currcode;


+ (UIColor *__nullable)colorwithHexString:(NSString *__nullable)hexStr alpha:(CGFloat)alpha;
+ (NSDictionary *__nullable)getExcangeRateArray :(NSString* __nullable)currencyCode;
+(BOOL) IsValidEmail:(NSString *)checkString;
@end
