//
//  LandingViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/10/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "LandingViewController.h"
#import "CommonHelper.h"
#import "SwitchCompanyDelagate.h"

@interface LandingViewController ()<UIAlertViewDelegate,SwitchCompanyDelagate>{
    BOOL isNavigatedToNextPage;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actView;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    @try {
        [_actView startAnimating];
        _lblMessage.hidden = NO;

        kAppDelegate.companyDelegate = self;

        __block BOOL isFirstLoad = YES;

        // To enable reachability check of AFNetworking
//        kAppDelegate.requestManager.operationQueue.maxConcurrentOperationCount = 5;
        NSOperationQueue *operationQueue = kAppDelegate.requestManager.operationQueue;

        [kAppDelegate.requestManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [kNSNotificationCenter postNotificationName:kConnectionStatusCheck object:nil];

            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [operationQueue setSuspended:NO];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }

            if(isFirstLoad){
                isFirstLoad = NO;

                _lblMessage.text = @"Validating License...";
                [self validateLicenseWithKey:LicenseKey];
            }
        }];
        [kAppDelegate.requestManager.reachabilityManager startMonitoring];
        //    [self validateLicenseWithKey:LicenseKey];
    }
    @catch (NSException *exception) {
        [CommonHelper WriteErrorLogWithMessage:[NSString stringWithFormat:@"%s",__func__] TraceMessage:[exception.name stringByAppendingFormat:@", %@",exception.reason] IsWarning:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void)cleanConfigDataIfCompaniesNotFound{
    __block NSError *err = nil;
    NSArray *arrFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[kAppDelegate applicationDocumentsDirectory] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey,NSURLPathKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:&err];
    if(!err){
        [arrFiles enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSNumber *isdir = nil;
            if([obj getResourceValue:&isdir forKey:NSURLIsDirectoryKey error:&err]){
            }
            if(isdir && [isdir boolValue]){
                NSArray *arrSubFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:obj includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLPathKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:&err];
                [arrSubFiles enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([[[obj1 pathExtension] lowercaseString] hasPrefix:@"json"])
                        [[NSFileManager defaultManager] removeItemAtURL:obj1 error:&err];
                }];
            }
            else if(![isdir boolValue] && [[[obj pathExtension] lowercaseString] hasPrefix:@"json"]){
                [[NSFileManager defaultManager] removeItemAtURL:obj error:&err];
            }
//            DebugLog(@"sss");
        }];
    }
}

#pragma mark - Validate License
-(void)validateLicenseWithKey:(NSString *)strlicensekey
{
    @try {
        __block NSDictionary *dicresult = [CommonHelper loadFileDataWithVirtualFilePath:(NSString *)kValidateLicenseFileName];
        if ([AFNetworkReachabilityManager sharedManager].reachable){
            NSString *deviceTypeString = [[UIDevice currentDevice] model];
            if([[deviceTypeString lowercaseString] hasPrefix:@"ipad"])
                deviceTypeString = @"iPad";
            else
                deviceTypeString = @"iPhone";

            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:LicenseKey,@"licensekey" ,[kAppDelegate identifierForAdvertising], @"deviceudid",deviceTypeString,@"devicetype",nil];

            if(dicresult){
                if([kUserDefaults  objectForKey:@"lastvalidatedlicensekey"] && [[kUserDefaults  objectForKey:@"lastvalidatedlicensekey"] isEqualToString:strlicensekey]){

                    [params setObject:[NSNumber numberWithLong:[[[dicresult objectForKey:@"data"] objectForKey:@"lastsyncdatetime"] longValue]]forKey:@"lastsyncdatetime"];

                    [self loadCompaniesWithLicenseData:dicresult];
                }
                else
                    [self cleanConfigDataIfCompaniesNotFound];
            }

            [CommonHelper DownloadDataWithAPIName:(NSString *)kValidateLicenseAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:(NSString *)kValidateLicenseFileName ProgressBlock:nil CompletionBlock:^(BOOL iscompleted, NSString * _Nullable errormessage, id  _Nullable response) {
                if(iscompleted){
                    [kUserDefaults  setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"lastvalidatedlicenseon"];
                    [kUserDefaults  setObject:strlicensekey forKey:@"lastvalidatedlicensekey"];
                    [kUserDefaults  synchronize];

                    [self loadCompaniesWithLicenseData:response];
                }
                else{
                    if(![[errormessage lowercaseString] hasPrefix:@"no new modified"]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errormessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry",@"Demo Mode",nil];
                        alert.tag = 1;
                        [alert show];
                    }
                    else{
                        if(dicresult)
                            [self loadCompaniesWithLicenseData:dicresult];
                    }
                }
            }];
        }
        else{
            if(dicresult){
                BOOL isShowAlert = NO;
                if([kUserDefaults  objectForKey:@"lastvalidatedlicenseon"])
                {
                    if([CommonHelper dateDiffFromUnixTimeStamp:[[kUserDefaults  objectForKey:@"lastvalidatedlicenseon"] longValue]]/86400 >= sForcefullValidateLicenseAfterDays){
                        isShowAlert = YES;
                    }
                }
                if(isShowAlert){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"You have been using app since more than %li days without internet connectivity. Please connect to internet then try again?",(long)sForcefullValidateLicenseAfterDays] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry",@"Demo Mode",nil];
                    alert.tag = 1;
                    [alert show];
                }
                else
                    [self loadCompaniesWithLicenseData:dicresult];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You need internet connectivity for the first time. Please try again?" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry",@"Demo Mode",nil];
                alert.tag = 1;
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        [CommonHelper WriteErrorLogWithMessage:[NSString stringWithFormat:@"%s",__func__] TraceMessage:[exception.name stringByAppendingFormat:@", %@",exception.reason] IsWarning:NO];
    }
}

-(void)loadCompaniesWithLicenseData:(NSDictionary *)dic{
    @try {
        if([[[dic objectForKey:@"status"] objectForKey:@"success"] boolValue]){
            NSDictionary *dicData=[dic objectForKey:@"data"];
            NSArray *companyListArr=[dicData objectForKey:@"companies"];
            if(!companyListArr || [companyListArr count]==0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No any company associated with license" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry",@"Demo Mode",nil];
                alert.tag = 1;
                [alert show];
                [_actView stopAnimating];
                [_lblMessage setHidden:YES];
                return;
            }

            // To check if user already selected any company so that we can load that comapany again
            NSArray *companyFound = nil;
            if(kAppDelegate.selectedCompanyId)
                companyFound = [companyListArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.companyid==%i",kAppDelegate.selectedCompanyId]]; // To validate if that comapany still associated with current license

            NSDictionary *dicCompany = nil;

            if(companyFound==nil || [companyFound count]==0){
                NSArray *defaultCompany = [companyListArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]];
                if ([defaultCompany count]>0)
                    dicCompany=[defaultCompany firstObject];
                else
                    dicCompany = [companyListArr firstObject];
            }
            else
                dicCompany = [companyFound firstObject];

            APIToken = [dicData objectForKey:@"tokenstring"];
            kAppDelegate.licenseType = [dicData objectForKey:@"licensetype"];
            kAppDelegate.licenseId = [[dicData objectForKey:@"licenseId"] integerValue];
            [kUserDefaults  setObject:APIToken forKey:@"APIToken"];

            [kUserDefaults  setObject:LicenseKey forKey:@"lastusedlicensekey"];

            [kAppDelegate loadSelectedCompanyWithData:dicCompany];
        }
        else{
            // show alert with 3 option i.e. - Close, Retry and Demo mode
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[dic objectForKey:@"status"] objectForKey:@"message"] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Try Again",@"Demo Mode",nil];
            alert.tag = 1;
            [alert show];
            [_actView stopAnimating];
            [_lblMessage setHidden:YES];
        }
    }

    @catch (NSException *exception) {
        [CommonHelper WriteErrorLogWithMessage:[NSString stringWithFormat:@"%s",__func__] TraceMessage:[exception.name stringByAppendingFormat:@", %@",exception.reason] IsWarning:NO];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag==1){ // if license validation failed
        if (buttonIndex == 0) {
            exit(0);
        }
        else{
            if (buttonIndex == 2)
                LicenseKey = [NSString stringWithFormat:@"%@",kDemoLicenseKey];
            else
                [self cleanConfigDataIfCompaniesNotFound];

            if(![self.navigationController.visibleViewController isKindOfClass:[LandingViewController class]]){
                [self.navigationController popToRootViewControllerAnimated:NO];
                kAppDelegate.companyDelegate = self;
                isNavigatedToNextPage = NO;
            }

            [_actView startAnimating];
            [_lblMessage setHidden:NO];
            [self validateLicenseWithKey:LicenseKey];
        }
    }
    else if(alertView.tag==2){ // if user download failed
        if (buttonIndex == 0) {
            exit(0);
        }
        else if (buttonIndex == 1){
            [_actView startAnimating];
            [kAppDelegate downloadCompanyUsersWithCompanyId:[NSString stringWithFormat:@"%li",(long)kAppDelegate.selectedCompanyId]];
        }
    }

}

#pragma mark - SwitchCompanyDelagate
-(void)loadingOfCompanyUsersFinishedSuccessfully:(BOOL)issuccessful Error:(nullable NSString *)error{
    if(issuccessful){
        if(!isNavigatedToNextPage && [self.navigationController.visibleViewController isKindOfClass:[LandingViewController class]]){
            isNavigatedToNextPage = YES;
            [self performSegueWithIdentifier:@"showlogin" sender:self];
        }
    }
    else{
        if(!error){
            error = @"Unable to load configuration data. Please try again.";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry",nil];
        alert.tag = 2;
        [alert show];
    }
    [_actView stopAnimating];
    [_lblMessage setHidden:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
