//
//  AppDelegate.m
//  mSeller
//
//  Created by Amit Pant on 9/9/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "globalObject.h"
#import <AdSupport/ASIdentifierManager.h>

@interface AppDelegate (){
//    NSMutableDictionary *dicEntities;
}

@property(nonnull,strong)NSMutableString *str1;
@property(nonnull,assign)NSMutableString *str2;
@end

@implementation AppDelegate
//@synthesize sessionManager = _sessionManager;
@synthesize requestManager = _requestManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    /*NSMutableString *str =[[NSMutableString alloc]initWithString:@"AA"];
    NSMutableArray *arr12=[[NSMutableArray alloc]init];
    [arr12 addObject:str];
    
    [arr12 removeAllObjects];
    str = nil;
    
    NSLog(@"Retain count isYY %ld", CFGetRetainCount((__bridge CFTypeRef)str));
    */
    
    NSArray *arr=@[@"5", @"10", @"2", @"5", @"50", @"5", @"10", @"1", @"2", @"2"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    
    for(id obj in arr){
        
        if ([dic count]==0) {
            [dic setObject:[NSNumber numberWithInt:1] forKey:obj];
        }else{
            if ([dic objectForKey:obj]) {
                int val =[[dic objectForKey:obj] intValue];
                val++;
                [dic setObject:[NSNumber numberWithInt:val] forKey:obj];
            }else
                [dic setObject:[NSNumber numberWithInt:1] forKey:obj];
        }
    }
    
    
    NSLog(@"dic %@",dic);
    
    
    
    
    
    
    
    
    /*_str1 =[[NSMutableString alloc]initWithString: @"Test"];
    _str2 = @"Test";
    
    NSLog(@"%@  %@",_str1,_str2);
    
    [_str1 appendString:@" helo"];
    @try {
        
         [_str2 appendString:@" helo"];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception %@",exception.description);
    } @finally {
        
    }
    
    
     NSLog(@"12 %@  %@",_str1,_str2);
    */
    
    NSArray *products12=@[@"199",@"255",@"543"];
    NSLog(@"WWW===  %@",[products12 valueForKeyPath:@"@max.self"]);
 //   NSArray *arr=[products12 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@""]
    
    // Override point for customization after application launch.
    [kUserDefaults removeObjectForKey:@"fromSelectedDate"];
    [kUserDefaults removeObjectForKey:@"toSelectedDate"];
    [kUserDefaults synchronize];

    _isEditTransaction=NO;
    _editTransactionProd=nil;
    //globalObjectDelegate.deliveryAddArray=[[NSMutableArray alloc]init];
    // customize title font of UINavigationBar
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIFont boldSystemFontOfSize:16.0],
                                               NSFontAttributeName,
                                               nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    // end of customization

    // To enable Network Activity Indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    // To check core data functionality
    _selectedCompanyId = [[kUserDefaults  objectForKey:@"selectedCompanyId"] integerValue];
    _lastSelectedCompanyId = _selectedCompanyId;

    // to set license from preferences
    LicenseKey = [kUserDefaults  objectForKey:@"licensekey_preference"];
    if(!LicenseKey || [[LicenseKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        LicenseKey = (NSString *)kDemoLicenseKey;

    // to set user info if defined in settings bundle
    NSString *tmpUserName = [kUserDefaults  objectForKey:@"username_preference"];
    if(tmpUserName && [[tmpUserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        tmpUserName = nil;

    NSString *tmpPassword = [kUserDefaults  objectForKey:@"password_preference"];
    if(tmpPassword && [[tmpPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        tmpPassword = nil;

    if(tmpUserName && ![tmpUserName isEqualToString:[kUserDefaults  objectForKey:@"username"]]){
        [kUserDefaults  setObject:tmpUserName forKey:@"username"];
        [kUserDefaults  synchronize];
    }

    if(tmpPassword && ![tmpPassword isEqualToString:[kUserDefaults  objectForKey:@"password"]]){
        [kUserDefaults  setObject:tmpPassword forKey:@"password"];
        [kUserDefaults  synchronize];
    }


    // to set app current version & build information
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    if(![appVersionString isEqualToString:[kUserDefaults  objectForKey:@"version_preference"]] || ![appBuildString isEqualToString:[kUserDefaults  objectForKey:@"build_preference"]]){

        if(![appVersionString isEqualToString:[kUserDefaults  objectForKey:@"version_preference"]])
            [kUserDefaults  setObject:appVersionString forKey:@"version_preference"];

        if(![appVersionString isEqualToString:[kUserDefaults  objectForKey:@"build_preference"]])
            [kUserDefaults  setObject:appBuildString forKey:@"build_preference"];
        [kUserDefaults  synchronize];
    }


    DebugLog(@"%@",[self applicationDocumentsDirectory]);


    [CommonHelper getLocaleCurrencies];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    NSString *tmpLicenseKey = [kUserDefaults  objectForKey:@"licensekey_preference"];
    if(tmpLicenseKey && [[tmpLicenseKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        tmpLicenseKey = nil;

    NSString *tmpUserName = [kUserDefaults  objectForKey:@"username_preference"];
    if(tmpUserName && [[tmpUserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        tmpUserName = nil;

    NSString *tmpPassword = [kUserDefaults  objectForKey:@"password_preference"];
    if(tmpPassword && [[tmpPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        tmpPassword = nil;

    if(tmpLicenseKey && ![tmpLicenseKey isEqualToString:LicenseKey]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"License key has been modified. Application will close, please reopen the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if((tmpUserName && ![tmpUserName isEqualToString:[kUserDefaults  objectForKey:@"username"]]) || (tmpPassword && ![tmpPassword isEqualToString:[kUserDefaults  objectForKey:@"password"]])){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"User details modified. Application will close, please reopen the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        exit(0);
    }
}


//#pragma mark - AFHTTPSessionManager
//-(AFHTTPSessionManager *)sessionManager{
//    if(!_sessionManager){
//        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kServiceURL] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    }
//    return _sessionManager;
//}

#pragma mark - AFHTTPRequestOperationManager
-(AFHTTPRequestOperationManager *)requestManager{
    if(!_requestManager){
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kServiceURL]];
    }
    return _requestManager;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.williamscommerce.mSeller" in the application's documents directory.
    
    NSURL *url=[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"downloads"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        [[NSFileManager defaultManager] createDirectoryAtPath:[url path] withIntermediateDirectories:NO attributes:nil error:nil];
        [self addSkipBackupAttributeToItemAtPath:[url path]];
    }
    return url;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mSeller" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    
    if (_persistentStoreCoordinator != nil) {
        if(_lastSelectedCompanyId !=_selectedCompanyId){
            NSURL *lastStoreURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%li",_lastSelectedCompanyId]] URLByAppendingPathComponent:@"mSeller.sqlite"];
            
//            NSPersistentStore* tmpStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:lastStoreURL options:nil error:nil];
            // And remove it !
            NSError *err = nil;
            [_persistentStoreCoordinator removePersistentStore:[_persistentStoreCoordinator persistentStoreForURL:lastStoreURL] error:&err];

            // to remove current store if already added
            NSURL *dirURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%li",_selectedCompanyId]];
            NSURL *storeURL = [dirURL URLByAppendingPathComponent:@"mSeller.sqlite"];
            [_persistentStoreCoordinator removePersistentStore:[_persistentStoreCoordinator persistentStoreForURL:storeURL] error:&err];
            
            [self addSeedDataToCoordinator:_persistentStoreCoordinator];
        }
        
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [self addSeedDataToCoordinator:_persistentStoreCoordinator];

    return _persistentStoreCoordinator;
}

- (void) addSeedDataToCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator{
    // Our destination url, writtable. Make sure this is in Library/Cache if you don't want iCloud to backup this.
    NSURL *dirURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%li",_selectedCompanyId]];
    NSURL *storeURL = [dirURL URLByAppendingPathComponent:@"mSeller.sqlite"];
    
    // If we don't have our migrated store, prepare it
    if (![[NSFileManager defaultManager] fileExistsAtPath:[dirURL path]])
    {
        [[NSFileManager defaultManager] createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES],[NSNumber numberWithBool:YES]] forKeys:@[NSMigratePersistentStoresAutomaticallyOption,NSInferMappingModelAutomaticallyOption]];
    if (![storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if(_lastSelectedCompanyId !=_selectedCompanyId)
        _managedObjectContext = nil;

    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Skip directory from backup in iCloud
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        DebugLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Custom Methods
//get IDFA from add support framework apple by Ashish
- (NSString *)identifierForAdvertising
{
    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled])
    {
        NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];

        return [IDFA UUIDString];//36 digit long unique number
    }

    return nil;
}

-(void)showCustomAlertWithModule:(NSString *)module Message:(NSString *)message{
    CGRect frame = [[UIScreen mainScreen] bounds];

    CGRect framelbl = frame;
    framelbl.size.height = 50;
    framelbl.origin.y=frame.size.height-framelbl.size.height;

    __block UILabel *lblMessage = [[UILabel alloc] initWithFrame:framelbl];
    lblMessage.textAlignment = NSTextAlignmentCenter;
    lblMessage.backgroundColor = [UIColor darkGrayColor];
    lblMessage.textColor = [UIColor whiteColor];
    lblMessage.font = [UIFont systemFontOfSize:16.0];
    lblMessage.numberOfLines=2;
    lblMessage.alpha=1.0;
    lblMessage.text = message;
    [self.window addSubview:lblMessage];

//    CGSize stringSize =   [message boundingRectWithSize:CGSizeMake(lblMessage.frame.size.width-20, 9999)
//                                     options:NSStringDrawingUsesLineFragmentOrigin
//                                  attributes:@{
//                                               NSFontAttributeName : lblMessage.font
//                                               }
//                                     context:nil].size;
//    if(stringSize.height>25){
//        CGRect framelbl =lblMessage.frame;
//        framelbl.size.height = 44;
//        framelbl.origin.y=frame.size.height-framelbl.size.height;
//        lblMessage.frame = frame;
//    }

    [UIView animateWithDuration:0.5 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        lblMessage.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished){
            [lblMessage removeFromSuperview];
            lblMessage = nil;
        }
    }];
}


#pragma mark - Switch Company

-(void)loadSelectedCompanyWithData:(NSDictionary *)dicCompany{
    kAppDelegate.selectedCompanyId = [[dicCompany objectForKey:@"companyid"] integerValue];

    [kUserDefaults  setObject:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"selectedCompanyId"];
    
    //added by Amit Pant on 20151223
//    NSDictionary *dicSelPriceRow=@{};
//    [kUserDefaults  setObject:dicSelPriceRow forKey:@"SelPriceRow"];
//    [kUserDefaults  synchronize];

    [kAppDelegate managedObjectContext];

    kAppDelegate.lastSelectedCompanyId = kAppDelegate.selectedCompanyId;

    CompanyUsersFileName = [NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[CompanyUsersFileName lastPathComponent]];
    CompanyConfigFileName = [NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[CompanyConfigFileName lastPathComponent]];
    FeaturesConfigFileName = [NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[FeaturesConfigFileName lastPathComponent]];
    PricingConfigFileName = [NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[PricingConfigFileName lastPathComponent]];

    [self downloadCompanyUsersWithCompanyId:[NSString stringWithFormat:@"%li",(long)kAppDelegate.selectedCompanyId]];
}

-(void)downloadCompanyUsersWithCompanyId:(NSString *)compid{
    __block NSDictionary *dicresult = [CommonHelper loadFileDataWithVirtualFilePath:CompanyUsersFileName];
    if ([AFNetworkReachabilityManager sharedManager].reachable){
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:APIToken,@"token" ,compid, @"companyid",nil];

        if(dicresult)
            [params setObject:[NSNumber numberWithLong:[[[dicresult objectForKey:@"data"] objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];

        [CommonHelper DownloadDataWithAPIName:(NSString *)kCompanyUsersAPI HTTPMethod:HTTTPMethodGET Params:params VirtualSavePath:CompanyUsersFileName  ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
            if(issuccess){
                [self loadCompanyUsersWithData:response];
            }
            else{
                if(![[errormessage lowercaseString] hasPrefix:@"no new modified"])
                    [self.companyDelegate loadingOfCompanyUsersFinishedSuccessfully:NO Error:errormessage];
                else{
                    if(dicresult)
                        [self loadCompanyUsersWithData:dicresult];
                }
            }
        }];
    }
    else{
        if(dicresult)
            [self loadCompanyUsersWithData:dicresult];
        else
            [self.companyDelegate loadingOfCompanyUsersFinishedSuccessfully:NO Error:nil];
    }
}

-(void)loadCompanyUsersWithData:(NSDictionary *)dic{
    if([self.companyDelegate respondsToSelector:@selector(loadingOfCompanyUsersFinishedSuccessfully:Error:)]){
        [self.companyDelegate loadingOfCompanyUsersFinishedSuccessfully:YES Error:nil];
    }
}

#pragma mark - Common Methods
-(void)reloadConfigurationData{
    // load customer info if any order created and still active
    [self loadCustomerInfo];
    
    if(![AFNetworkReachabilityManager sharedManager].reachable)
        return;
    
    NSArray *arrApis = [NSArray arrayWithObjects:kCompanyConfigAPI,kFeaturesConfigAPI,kPricingConfigAPI,kUserConfigAPI, nil];

    NSMutableDictionary *AllApisParams = [NSMutableDictionary dictionary];

    // kCompanyConfigAPI
    NSMutableDictionary *dicCompanyParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:APIToken, @"token",nil];
    [dicCompanyParams setObject:CompanyConfigFileName forKey:@"filename"];
    [dicCompanyParams setObject:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"companyid"];
    // pass only if file exist on device
    NSDictionary *dicresult = [CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dicresult)
        [dicCompanyParams setObject:[NSNumber numberWithLong:[[[dicresult objectForKey:@"data"] objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];

    [AllApisParams setObject:dicCompanyParams forKey:kCompanyConfigAPI];

    // kFeaturesConfigAPI
    NSMutableDictionary *dicFeaturesParam = [dicCompanyParams mutableCopy];
    [dicFeaturesParam setObject:FeaturesConfigFileName forKey:@"filename"];
    [dicFeaturesParam setObject:kAppDelegate.licenseType forKey:@"licensetype"];
    // pass only if file exist on device
    dicresult = [CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dicresult)
        [dicFeaturesParam setObject:[NSNumber numberWithLong:[[[dicresult objectForKey:@"data"] objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];

    [AllApisParams setObject:dicFeaturesParam forKey:kFeaturesConfigAPI];

    // kPricingConfigAPI
    NSMutableDictionary *dicPriceParam = [dicCompanyParams mutableCopy];
    [dicPriceParam setObject:PricingConfigFileName forKey:@"filename"];

    // pass only if file exist on device
    dicresult = [CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dicresult)
        [dicPriceParam setObject:[NSNumber numberWithLong:[[[dicresult objectForKey:@"data"] objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];

    [AllApisParams setObject:dicPriceParam forKey:kPricingConfigAPI];

    // kUserConfigAPI
    NSMutableDictionary *dicUserParam = [dicCompanyParams mutableCopy];
    [dicUserParam setObject:UserConfigFileName forKey:@"filename"];
    [dicUserParam setObject:[NSNumber numberWithInteger:kAppDelegate.loginUserId]  forKey:@"userid"];

    // pass only if file exist on device
    dicresult = [CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dicresult)
        [dicPriceParam setObject:[NSNumber numberWithLong:[[[dicresult objectForKey:@"data"] objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];
    [AllApisParams setObject:dicUserParam forKey:kUserConfigAPI];


    [CommonHelper DownloadFilesWithAPIs:arrApis ParamsAndFileNames:AllApisParams ProgressBlock:^(long filesDownloaded, long filesToDownload) {

    } CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, NSInteger successCount, NSInteger failedCount) {
        if([self.companyDelegate respondsToSelector:@selector(ConfigDownloadFinishedSuccessfully:Error:)]){
            [self.companyDelegate ConfigDownloadFinishedSuccessfully:issuccess Error:errormessage];
        }

        if(issuccess && successCount>0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [kNSNotificationCenter postNotificationName:kRefreshConfigData object:nil];
            });
        }
    }];
}

// to load ongoing transaction detail
-(void)loadCustomerInfo{
    if(kAppDelegate.customerInfo) return;

    kAppDelegate.customerInfo = nil;
    kAppDelegate.transactionInfo = nil;

    // for the first time when application loaded or company switched
    // load open order info
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isopen==1"];
    [transactionInfo setPredicate:predicate];

    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];
    NSString *strcustid = nil;
//    NSString *strdeladd = nil;
    if([resultsSeq count]>0){
        kAppDelegate.transactionInfo = [resultsSeq lastObject];
        strcustid = [kAppDelegate.transactionInfo valueForKey:@"customerid"];
//        strdeladd = [kAppDelegate.transactionInfo valueForKey:@"deliveryaddressid"];
    }

    if(strcustid && [strcustid length]>0)
    {
        // load order info
        entitySquence = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
        transactionInfo = [[NSFetchRequest alloc] init];
        [transactionInfo setEntity:entitySquence];

        predicate = [NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address=='000'",strcustid];
        [transactionInfo setPredicate:predicate];

        resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];
        if([resultsSeq count]>0)
            kAppDelegate.customerInfo = [resultsSeq lastObject];
    }

}

// to insert default value supplied in the sqlite when user logged in
-(void)loadPrequisitesDataIntoSQLDB{
    if(!kAppDelegate.repId || [kAppDelegate.repId length]==0) return;

    // update/insert NEWSEQUENCES for based on rep id
    NSEntityDescription *entitySquence = [NSEntityDescription entityForName:@"NEWSEQUENCES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *transactionInfo = [[NSFetchRequest alloc] init];
    [transactionInfo setEntity:entitySquence];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rep_id==%@",kAppDelegate.repId];
    [transactionInfo setPredicate:predicate];

    NSManagedObject *managedObject = nil;
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:transactionInfo error:&error];
    if([resultsSeq count]==0){
        managedObject = [[NSManagedObject alloc]  initWithEntity:entitySquence insertIntoManagedObjectContext:kAppDelegate.managedObjectContext];

        [managedObject setValue:kAppDelegate.repId forKey:@"rep_id"];

        if (![kAppDelegate.managedObjectContext save:&error])
        {
            printf("Error while inserting new sequnces\n%s",
                   [[error localizedDescription] ?
                    [error localizedDescription] : [error description] UTF8String]);
        }
    }

}

// to validate if all required config file downloaded
-(BOOL)isAllConfigFileDownloaded{
    NSString *basePath = [[kAppDelegate applicationDocumentsDirectory] path];
    return ([[NSFileManager defaultManager] fileExistsAtPath:[basePath stringByAppendingPathComponent:CompanyConfigFileName]] &&
            [[NSFileManager defaultManager] fileExistsAtPath:[basePath stringByAppendingPathComponent:FeaturesConfigFileName]] &&
            [[NSFileManager defaultManager] fileExistsAtPath:[basePath stringByAppendingPathComponent:PricingConfigFileName]] &&
            [[NSFileManager defaultManager] fileExistsAtPath:[basePath stringByAppendingPathComponent:UserConfigFileName]]);
}


// to save last used configuration on device
-(void)saveDeviceUsesLogs{
    NSString *deviceTypeString = [[UIDevice currentDevice] model];
    NSString *deviceNameString = [[UIDevice currentDevice] name];
    NSString *deviceModelString = [[UIDevice currentDevice] localizedModel];
    NSString *deviceOSString = [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];

    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:APIToken,@"token" ,
                                   [kAppDelegate identifierForAdvertising], @"deviceudid",
                                   deviceNameString,@"devicename",
                                   deviceTypeString,@"devicetype",
                                   deviceModelString,@"devicemodel",
                                   deviceOSString,@"deviceosversion",
                                   [NSString stringWithFormat:@"%@ (%@)",appVersionString,appBuildString],@"appversion",
                                   [NSNumber numberWithInteger:kAppDelegate.selectedCompanyId],@"companyid",
                                   [NSNumber numberWithInteger:kAppDelegate.loginUserId],@"userid",
                                   [NSNumber numberWithInteger:kAppDelegate.licenseId],@"licenseid",
                                   nil];

    [CommonHelper DownloadDataWithAPIName:(NSString *)kSaveDeviceUsesAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL iscompleted, NSString * _Nullable errormessage, id  _Nullable response) {
        if(iscompleted){
            DebugLog(@"Device logs saved successfully");
        }
    }];
}






// Push NSNotificationCenter

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
}


#ifdef __IPHONE_8_0
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}

#endif

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    DebugLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
        
    }];
    //    [kNSNotificationCenter postNotificationName:kMenuSelection object:nil userInfo:[NSDictionary dictionaryWithObject:@"Notification" forKey:@"mname"]];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    NSString *DeviceToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    DebugLog(@"My token is: %@", DeviceToken);
    
}


@end
