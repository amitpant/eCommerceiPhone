//
//  Constants.m
//  mSeller
//
//  Created by Satish Kr Singh on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "Constants.h"

//const NSString *kServiceURL = @"http://mseller.williamscommerce.com/mSelleriPhone/mSelleriPhone/"; 


#pragma mark -Live Server
const NSString *kServiceURL = @"http://mseller.williamscommerce.com/mSelleriPhoneApp/api/";

#pragma mark -staging Server
//const NSString *kServiceURL = @"https://msellergateway02.wclprod.com/msellernew/api/";

//const NSString *kServiceURL = @"http://mseller.williamscommerce.com/mSellerNewDemoApi/api/";

/*! – 
 @brief POST (All mandatory parameters)
 @param licensekey
 @param deviceudid
 */
const NSString *kValidateLicenseAPI=@"validatelicense";
const NSString * kValidateLicenseFileName=@"licensing.json";

/*! –
 @brief GET (All mandatory parameters)
 @param token
 @param companyid
 */
const NSString *kCompanyUsersAPI=@"companyusers";
NSString * CompanyUsersFileName=@"companyuser.json";

/*! –
 @brief GET (All mandatory parameters)
 @param token
 @param companyid
 */
const NSString *kCompanyConfigAPI=@"companyconfigs";
NSString * CompanyConfigFileName=@"companyconfig.json";

/*! –
 @brief GET (All mandatory parameters)
 @param token
 @param companyid
 */
const NSString *kFeaturesConfigAPI=@"featuresconfigs";
NSString * FeaturesConfigFileName=@"featuresconfig.json";

/*! –
 @brief GET (All mandatory parameters)
 @param token
 @param companyid
 */
const NSString *kPricingConfigAPI=@"pricingconfigs";
NSString *PricingConfigFileName=@"pricingconfig.json";

/*! –
 @brief GET (All mandatory parameters)
 @param token
 @param companyid
 @param userid
 */
const NSString *kUserConfigAPI=@"userconfigs";
NSString * UserConfigFileName=@"userconfig.json";

/*! –
 @brief POST (* mandatory parameters)
 @param token *
 @param deviceudid *
 @param devicename
 @param devicetype
 @param devicemodel
 @param deviceosversion
 @param appversion
 @param companyid
 @param userid
 @param licenseid
 */
const NSString *kSaveDeviceUsesAPI=@"deviceuseslogs";

/*! –
 @brief GET or POST (All mandatory parameters)
 @param token
 @param companyid
 @param repid
 @param value (only for POST)
 */
const NSString *kNextCustomerAPI=@"nextcustomernumber";

/*! –
 @brief GET or POST (All mandatory parameters)
 @param token
 @param companyid
 @param repid
 @param value (only for POST)
 */
const NSString *kNextOrderAPI=@"nextordernumber";

/*! –
 @brief GET or POST (All mandatory parameters)
 @param token
 @param companyid
 @param repid
 @param value (only for POST)
 */
const NSString *kNextBatchAPI=@"nextbatchnumber";

/*! –
 @brief POST (* mandatory parameters)
 @param token *
 @param Dirpath *
 @param Filterextensions
 @param Filenamestartwith
 @param filenamendswith
 @param filenamecontains
 */
const NSString *kListFilesAPI=@"listfiles";

/*! –
 @brief POST (* mandatory parameters, ** any one required)
 @param token *
 @param Filepath *
 @param archivetodir
 @param isdirectory
 @param Filterextensions **
 @param Filenamestartwith **
 @param filenamendswith **
 @param filenamecontains **
 @param deletepermanently
 */
const NSString *kArchiveFilesAPI=@"archivefile";

/*! –
 @brief POST (* mandatory parameters)
 @param token *
 @param Action *
 @param Datetime *
 @param Logmessage *
 @param Tracemessage
 @param Deviceudid *
 @param Repid
 @param Userid
 @param companyid
 */
const NSString *kWriteFullLogsAPI=@"writefulllog";

/*! –
 @brief POST (* mandatory parameters)
 @param token *
 @param Pathtoupload*
 @param Filename*
 @param Base64string*
 @param Password (If file protected with password)
 */
const NSString *kUploadDataFileAPI=@"uploaddatafile";

/*! –
 @brief POST (* mandatory parameters)
 @param token *
 @param dirpath*
 @param filterextensions* e.g.- *.csv|*.pdf
 */
const NSString *kDownloadFileAPI = @"downloadfile";

/*! –
 @brief POST (* mandatory parameters)
 @param token *
 @param dirpath*
 @param filename*
 */
const NSString *kDownloadSingleFileAPI = @"DownloadRawFile";

// Global Variables
const NSString *kDemoLicenseKey=@"2d1bc616-82a3-44c0-b776-363b1a8fdc1e";
NSString *APIToken;
NSString *LicenseKey;




