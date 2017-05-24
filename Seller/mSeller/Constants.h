//
//  Constants.h
//  mSeller
//
//  Created by Satish Kr Singh on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#define kAppDelegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
#import <Foundation/Foundation.h>

extern NSString * kServiceURL;

extern const NSString * kValidateLicenseAPI;
extern const NSString * kValidateLicenseFileName;

extern const NSString *kCompanyUsersAPI;
extern NSString * CompanyUsersFileName;

extern const NSString *kCompanyConfigAPI;
extern NSString * CompanyConfigFileName;

extern const NSString *kFeaturesConfigAPI;
extern NSString * FeaturesConfigFileName;

extern const NSString *kPricingConfigAPI;
extern NSString * PricingConfigFileName;

extern const NSString *kUserConfigAPI;
extern NSString * UserConfigFileName;

extern const NSString *kSaveDeviceUsesAPI;

/*! */
extern const NSString *kNextCustomerAPI;

extern const NSString *kNextOrderAPI;

extern const NSString *kNextBatchAPI;

extern const NSString *kListFilesAPI;

extern const NSString *kArchiveFilesAPI;

extern const NSString *kWriteFullLogsAPI;

extern const NSString *kUploadDataFileAPI;

extern const NSString *kDownloadFileAPI;
extern const NSString *kDownloadSingleFileAPI;

// Global Variables
extern const NSString *kDemoLicenseKey;
extern NSString *LicenseKey;
extern NSString *APIToken;

static NSInteger sForcefullValidateLicenseAfterDays=7; // s

#define kUserDefaults [NSUserDefaults standardUserDefaults]
#define kNSNotificationCenter [NSNotificationCenter defaultCenter]

#define kConnectionStatusCheck @"kConnectionStatusCheck"

#define kRefreshDashboard @"kRefreshDashboard" // called when company switched and user is still valid
#define kRedirectToRootViewController @"kRedirectToRootViewController" // called when company switched
#define kRefreshTabItems @"kRefreshTabItems" // called when sync performed
#define kRedirectToLogin @"kRedirectToLogin" // called when login failed
#define kRefreshConfigData @"kRefreshConfigData"

//Notification //Call log change to order type
#define kServerConnectivity    @"ServerConnectivity"
#define kOrderTypechange       @"refreshOrderType"
#define kSelectedPriceRow      @"selectedPriceRow"
#define kDeliverInfoChange     @"DeliverInfoChange"
#define kDeliverViewUpdate     @"DeliverViewUpdate"
#define kReloadProduct         @"kReloadProduct" //reload all product Data
#define kcostmargin            @"kcostmargin"
#define kcostSwitch            @"kcostSwitch"
#define kCompanySwitch         @"kCompanySwitch"
#define kCancelChanges         @"kCancelChanges"

#define kLoadOtherTabController         @"kLoadOtherTabController"


#define SelectedBackgroundColor [UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1]
#define SelectedTextColor [UIColor whiteColor]

#define btnGreenColor       [UIColor colorWithRed:158.0/255.0 green:234.0/255.0 blue:67.0/255.0 alpha:1.0]
#define btnBlueColor        [UIColor colorWithRed:51.0/255.0 green:30.0/255.0 blue:217.0/255.0 alpha:1.0]
#define btnBlueCornerColor  [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0]
#define btnWhiteColor   [UIColor whiteColor]
#define btnTitleBlueColor   [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0]//[UIColor blackColor]//
#define checkImage      [UIImage imageNamed:@"check.png"]
#define unCheckImg      [UIImage imageNamed:@"uncheck.png"]
#define bluecheckImg    [UIImage imageNamed:@"blue_check.png"]
#define blueUnCheckImg  [UIImage imageNamed:@"cross_Red.png"]
#define connectionGreenColor       [UIColor colorWithRed:2.0/255.0 green:140.0/255.0 blue:72.0/255.0 alpha:1.0]//#028c48



//****** Alert button
// Enum declaration for parsing Alerttype files
#define alertBtnDismiss  @"Dismiss"
#define alertBtnOk  @"Ok"
#define alertBtnCancel  @"Cancel"
#define alertBtnYes  @"Yes"
#define alertBtnNo  @"No"
//#define alertBtnYes  @"Yes"

/*struct mSellerAlertMsg {
    static NSString* alertBtnDismiss  @"Dismiss";
    NSString* alertBtnOk  @"Ok";
    NSString* alertBtnCancel  @"Cancel";
    NSString* alertBtnYes  @"Yes";
    NSString* alertBtnNo  @"No";

};*/



#define tblOddColor     [UIColor whiteColor]
#define tblEvenColor    [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0]
//Invoice/outstanding
#define tblHeaderRed       [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:46.0/255.0 alpha:1.0]
#define tblHeaderYellow    [UIColor colorWithRed:255.0/255.0 green:215.0/255.0 blue:0.0/255.0 alpha:1.0]
#define tblHeaderBlue    [UIColor colorWithRed:18.0/255.0 green:109.0/255.0 blue:0.0/187.0 alpha:1.0]
#define SelectedTextColor [UIColor whiteColor]
//Pricing
#define bluecheckImgPriceTab    [UIImage imageNamed:@"blue_check.png"]
#define prodDefaultPrice @"Price1"
//Universal App
#define kTextColor     [UIColor blackColor]
#define kTextFont      [UIFont systemFontOfSize:14]



#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


// Enum declaration for parsing CSV files
typedef enum {
    ParserTypeProd=1,
    ParserTypeCust=2,
    ParserTypeGroup=3,
    ParserTypeConv=4,
    ParserTypePrices=5,
    ParserTypeStockband=6,
    ParserTypePurchaseOrder=7,
    ParserTypeOhead=8,
    ParserTypeOlines=9,
    ParserTypeIhead=10,
    ParserTypeIlines=11,
    ParserTypeCallLogs=12,
    ParserTypeTargets=14,
    ParserTypeBar=15,
    
    ParserTypeNotes=99
} CSVParserType;

// Enum declaration for HTTP methods
typedef enum {
    HTTTPMethodGET=1,
    HTTTPMethodPOST=2,
    HTTTPMethodPATCH=3,
    HTTTPMethodPUT=4,
    HTTTPMethodDELETE=5,
    HTTTPMethodHEAD=6
} HTTTPMethod;
