//
//  DashboardController.m
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

//SyncType  0:FullSync     1:PartSync      2:SendOnly

#import "DashboardController.h"
#import "SettingsViewController.h"
#import "PasscodeViewController.h"
#import "CommonHelper.h"
#import "CustomImporter.h"
#import "LLACircularProgressView.h"


@interface DashboardController (){
    NSDictionary* featureDict;
    NSDictionary* companyConfigDict;

    BOOL isSyncInProgress;
}


@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnConnectivity;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnAppointment;
@property (weak, nonatomic) IBOutlet UIButton *btnTeamTalk;
@property (weak, nonatomic) IBOutlet UIButton *btnFullSync;
@property (weak, nonatomic) IBOutlet UIButton *btnPartSync;
@property (weak, nonatomic) IBOutlet UIButton *btnSendOnly;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblBedge;

@property (weak, nonatomic) IBOutlet UILabel *lblConnectionStatus;
@property (weak, nonatomic) IBOutlet UIView *viewFullSync;
@property (weak, nonatomic) IBOutlet UIView *viewPartSync;
@property (weak, nonatomic) IBOutlet UIView *viewSendOnly;
@property (weak, nonatomic) IBOutlet UIView *viewFullSyncLabel;
@property (weak, nonatomic) IBOutlet UIView *viewPartSyncLabel;
@property (weak, nonatomic) IBOutlet UIView *viewSendOnlyLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblFullSyncStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblFullSyncDate;

@property (weak, nonatomic) IBOutlet UILabel *lblPartSyncStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblPartSyncDate;

@property (weak, nonatomic) IBOutlet UILabel *lblSendOnlyStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblSendOnlyDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constFullSyncStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constPartSyncStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constSendOnlyStatus;

@property (weak, nonatomic) IBOutlet LLACircularProgressView *viewProgressFullSync;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *viewProgressPartSync;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *viewProgressSendOnly;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UIImageView *smallLogoImage;

- (IBAction)appointmentClick:(id)sender;
-(IBAction)syncFull:(id)sender;
-(IBAction)syncPart:(id)sender;
-(IBAction)sendOnly:(id)sender;

@end

@implementation DashboardController
@synthesize backgroundImageView;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    self.title=NSLocalizedString(@"Dashboard", @"Dashboard");

    _lblVersion.text = [NSString stringWithFormat:@"%@ %@ (%@)",kAppDelegate.licenseType,appVersionString,appBuildString];

    // to load customized layout
    [self customizeLayout];
    
    //When companySwitch Notification Called
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshCompanydata:) name:kCompanySwitch object:nil];
    
    
   // self.navigationItem.rightBarButtonItem = nil;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Dashboard";
    //    [self checkBedgeVisibility];

    // to update connection status
    _lblConnectionStatus.hidden = [AFNetworkReachabilityManager sharedManager].reachable;
    
    [self loadBarButtonConnectivity:[AFNetworkReachabilityManager sharedManager].reachable];
    
    [kNSNotificationCenter addObserver:self selector:@selector(UpdateConnectionStatus:) name:kConnectionStatusCheck object:nil];

    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    
    [kUserDefaults  setInteger:2  forKey: @"PriceDisplay"];
    [kUserDefaults  setInteger:2  forKey: @"CatalogeScrolling"];
    
    //manage default values.
   /* if ([kUserDefaults  integerForKey:@"CustomerMode"]==0 && ![[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsCustomerMode"] isEqual:[NSNull null]]) {
        
        if ([[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsCustomerMode"])
            [kUserDefaults  setInteger:2  forKey: @"CustomerMode"];
        else
            [kUserDefaults  setInteger:1  forKey: @"CustomerMode"];
        
    }
    
    if ([kUserDefaults  integerForKey:@"PriceDisplay"]==0 && ![[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsPriceDisplay"] isEqual:[NSNull null]]) {
        
        if ([[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsPriceDisplay"])
            [kUserDefaults  setInteger:2  forKey: @"PriceDisplay"];
        else
            [kUserDefaults  setInteger:1  forKey: @"PriceDisplay"];
    }
    
    if ([kUserDefaults  integerForKey:@"CatalogeScrolling"]==0 && ![[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsCatalogueScrolling"] isEqual:[NSNull null]]) {
        
        if ([[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsCatalogueScrolling"])
            [kUserDefaults  setInteger:2  forKey: @"CatalogeScrolling"];
        else
            [kUserDefaults  setInteger:1  forKey: @"CatalogeScrolling"];
        
    }
    
    if ([kUserDefaults  integerForKey:@"NumericKeyboard"]==0 && ![[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsNumericKeyboard"] isEqual:[NSNull null]]) {
        
        if ([[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"IsNumericKeyboard"])
            [kUserDefaults  setInteger:2  forKey: @"NumericKeyboard"];
        else
            [kUserDefaults  setInteger:1  forKey: @"NumericKeyboard"];
    }*/
//Check default values.
    
    
    [self performSelector:@selector(checkBedgeVisibility) withObject:nil afterDelay:0.00];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    // remove observer
    [kNSNotificationCenter removeObserver:self name:kConnectionStatusCheck object:nil];
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Methods
-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];

    // code modified by Satish on 12-11-2015
    _btnAppointment.enabled = NO;
    _btnTeamTalk.enabled = NO;
    if (featureDict !=nil){
        _btnAppointment.enabled = [[featureDict valueForKey:@"calendarentryofappointmentenabled"] boolValue];
        _btnTeamTalk.enabled = ([[featureDict valueForKey:@"salesmessageenabled"] boolValue] || [[featureDict valueForKey:@"customertasksenabled"] boolValue]);
    }

    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];

    backgroundImageView.image = nil;
    _smallLogoImage.image = nil;
    if(companyConfigDict){
//        backgroundImageView.image=[UIImage imageNamed:[companyConfigDict valueForKey:@"dashboardbgimage"]];
        [self performSelector:@selector(prepareCompanyImagesToDownload) withObject:nil afterDelay:0.00];
    }
    //End


    // to set default value which is valid for selected company
    NSDictionary *pricingConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        pricingConfigDict = [dic objectForKey:@"data"];

    NSString *currencyString=@"GBP";
    BOOL isexchangerateconversionenabled = NO;
    if(pricingConfigDict){
        if (![[pricingConfigDict valueForKey:@"defaultcurrency"] isEqual:[NSNull null]]) {
           currencyString = [pricingConfigDict valueForKey:@"defaultcurrency"];
        }
        
        isexchangerateconversionenabled = [[pricingConfigDict valueForKey:@"useexchangerateconversion"] boolValue];
    }
    [kUserDefaults  setValue:currencyString forKey:@"defaultcurrency"];
    [kUserDefaults  setValue:[NSNumber numberWithBool:isexchangerateconversionenabled] forKey:@"useexchangerateconversion"];
    [kUserDefaults  synchronize];

    [self loadSyncStatus];
    
    
}

-(void)prepareCompanyImagesToDownload{
    [self showLogoImage];

    if(!companyConfigDict || [[companyConfigDict valueForKey:@"logo"] isEqual:[NSNull null]] || [companyConfigDict valueForKey:@"logo"]==nil ||  [[companyConfigDict valueForKey:@"logo"] length]==0) {
        return;
    }

    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];
    if(!dataPathString) return;

    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:APIToken forKey:@"token"];
    [params setObject:dataPathString  forKey:@"dirpath"];
    [params setObject:[companyConfigDict valueForKey:@"logo"] forKey:@"filterextensions"]; //|*.png

    [CommonHelper DownloadDataWithAPIName:(NSString *)kListFilesAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL iscompleted, NSString * _Nullable errormessage, id  _Nullable response) {
        if(iscompleted && [response objectForKey:@"data"]){
            [self performSelector:@selector(downloadCompanyImagesWithData:) withObject:[response objectForKey:@"data"] afterDelay:0.001];
        }
    }];
}

-(void)downloadCompanyImagesWithData:(NSArray *)arr{
    NSMutableArray *arrImageQueue = [NSMutableArray array];

    // to validate images updated on server are different than downloaded one
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DOWNLOADHISTORY" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];

    NSError *err = nil;
    NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
    if([results count]==0){
        [arrImageQueue addObjectsFromArray:arr];
    }
    else{
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *arrfound = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"filename==%@",[[obj objectForKey:@"filename"] lowercaseString]]];
            if([arrfound count]>0 && [[[arrfound lastObject] valueForKey:@"filesizeinkb"] integerValue]==[[obj objectForKey:@"filesizeinkb"] integerValue] && [[[arrfound lastObject] valueForKey:@"lastmodifiedon"] isEqualToString:[obj objectForKey:@"lastmodifiedon"]]){}
            else{
                [arrImageQueue addObject:obj];
            }
        }];
    }

    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];
    if(!dataPathString) return;
    
    if([arrImageQueue count]==0) {
        [self showLogoImage];
        return;
    }

    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:APIToken forKey:@"token"];
    [params setObject:dataPathString  forKey:@"dirpath"];
    [CommonHelper DownloadDataFiles:arrImageQueue Params:params VirtualDirPath:[NSString stringWithFormat:@"%li",(long)kAppDelegate.selectedCompanyId] ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, NSInteger successCount, NSInteger failedCount) {

        [self showLogoImage];
    }];
}

-(void)showLogoImage{
    NSURL *imageurl=[[kAppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%li/%@",(long)kAppDelegate.selectedCompanyId,[companyConfigDict valueForKey:@"logo"]]];

    [_smallLogoImage.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    if([[NSFileManager defaultManager] fileExistsAtPath:[imageurl path]]){
        [_smallLogoImage setImageWithURL:imageurl];
    }
    else{
        _smallLogoImage.image = nil;
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _smallLogoImage.frame.size.width, _smallLogoImage.frame.size.height)];
        myLabel.text = [companyConfigDict objectForKey:@"tradename"];
        myLabel.textAlignment = NSTextAlignmentCenter;
        myLabel.textColor = [UIColor blackColor];
        myLabel.font=[UIFont fontWithName:@"Marker Felt" size:35];
        myLabel.numberOfLines = 2;
        [_smallLogoImage addSubview:myLabel];
    }
}

-(void)customizeLayout{

    [_viewFullSyncLabel.layer setMasksToBounds:YES];
    [_viewFullSyncLabel.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [_viewFullSyncLabel.layer setBorderWidth:1.0];
    [_viewFullSyncLabel.layer setCornerRadius:8.0];

    [_viewPartSyncLabel.layer setMasksToBounds:YES];
    [_viewPartSyncLabel.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [_viewPartSyncLabel.layer setBorderWidth:1.0];
    [_viewPartSyncLabel.layer setCornerRadius:8.0];

    [_viewSendOnlyLabel.layer setMasksToBounds:YES];
    [_viewSendOnlyLabel.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [_viewSendOnlyLabel.layer setBorderWidth:1.0];
    [_viewSendOnlyLabel.layer setCornerRadius:8.0];
}

-(void)loadSyncStatus{
    if(isSyncInProgress) return;

    NSDictionary *dicFullStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/fullsync.json",(long)kAppDelegate.selectedCompanyId]];
    if(dicFullStatus){
        _lblFullSyncStatus.text=@"Last";
        //_lblFullSyncDate.text =[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy hh:mm a" UnixTimeStamp:[[dicFullStatus objectForKey:@"lastsyncdatetime"] longValue]];
        _lblFullSyncDate.text =[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy hh:mm a" UnixTimeStamp:[[dicFullStatus objectForKey:@"lastfullsyncdate"] longValue]];
        
        _lblFullSyncDate.hidden = NO;
        _constFullSyncStatus.constant = 17;
        
        //For ideal stage stop going to sleep mode
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
    }
    else{
        _lblFullSyncStatus.text = @"Not updated yet";
        _lblFullSyncDate.hidden = YES;
        _constFullSyncStatus.constant = 51;
    }

    NSDictionary *dicPartStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/partsync.json",(long)kAppDelegate.selectedCompanyId]];
    if(dicPartStatus){
        _lblPartSyncStatus.text=@"Last";
       // _lblPartSyncDate.text =[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy hh:mm a" UnixTimeStamp:[[dicPartStatus objectForKey:@"lastsyncdatetime"] longValue]];
        _lblPartSyncDate.text =[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy hh:mm a" UnixTimeStamp:[[dicPartStatus objectForKey:@"lastpartsyncdate"] longValue]];
        
        _lblPartSyncDate.hidden = NO;
        _constPartSyncStatus.constant = 17;
        
        //For ideal stage stop going to sleep mode
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    else{
        _lblPartSyncStatus.text = @"Not updated yet";
        _lblPartSyncDate.hidden = YES;
        _constPartSyncStatus.constant = 51;
    }

    NSDictionary *dicSentStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/sendonly.json",(long)kAppDelegate.selectedCompanyId]];//NSArray *dicSentStatus
    if(dicSentStatus){
        _lblSendOnlyStatus.text=@"Last";
      //  _lblSendOnlyDate.text =[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy hh:mm a" UnixTimeStamp:[[[dicSentStatus lastObject] objectForKey:@"lastsyncdatetime"] longValue]];
        _lblSendOnlyDate.text =[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy hh:mm a" UnixTimeStamp:[[dicSentStatus objectForKey:@"lastsendonlydate"] longValue]];
        _lblSendOnlyDate.hidden = NO;
        _constSendOnlyStatus.constant = 17;
    }
    else{
        _lblSendOnlyStatus.text = @"Not updated yet";
        _lblSendOnlyDate.hidden = YES;
        _constSendOnlyStatus.constant = 51;
    }

    //    _lblFullSyncStatus.numberOfLines=3;
    //
    //    CGRect frame=_lblFullSyncStatus.frame;
    //    frame.size.height=51;
    //    _lblFullSyncStatus.frame = frame;

    //    _constFullSyncStatus.constant = 51;
    //    _constPartSyncStatus.constant =_constFullSyncStatus.constant;
    //    _constSendOnlyStatus.constant = _constFullSyncStatus.constant;

    //    [_lblFullSyncStatus sizeToFit];
    //    [_lblPartSyncStatus sizeToFit];
    //    [_lblSendOnlyStatus sizeToFit];
}

-(void)checkBedgeVisibility
{
    _lblBedge.layer.backgroundColor = [UIColor redColor].CGColor;
    _lblBedge.layer.cornerRadius = _lblBedge.bounds.size.height / 2;
    _lblBedge.textColor = [UIColor whiteColor];
    _lblBedge.layer.borderColor = [UIColor whiteColor].CGColor;
    _lblBedge.layer.borderWidth = 2.0;

    NSInteger totalcount = 0;

    if(featureDict && [[featureDict valueForKey:@"salesmessageenabled"] boolValue]){
        NSError *err;
        NSString* downloadpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/localdata",(long)kAppDelegate.selectedCompanyId];
        NSArray  *file= [[[NSFileManager defaultManager]
                         contentsOfDirectoryAtPath:downloadpath error:&err] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH [cd] 'info'"]];

        NSUserDefaults *defaults = kUserDefaults ;
        NSMutableArray *arrReadMessage = (NSMutableArray *)[defaults objectForKey:@"readSalesMessage"];


        for(NSString *str in file)
        {
            if([[[str pathExtension] lowercaseString] isEqualToString:@"txt"])
            {

                if(![arrReadMessage containsObject:str])
                {
                    totalcount++;
                }

                
            }
            
        }
    }
    if(totalcount >0)
    {
        _lblBedge.text = [NSString stringWithFormat:@"%ld",(long)totalcount];
        _lblBedge.hidden = NO;
        
    }
    else{
        _lblBedge.hidden = YES;
        
    }
    
    
}

-(void)UpdateConnectionStatus:(NSNotification *)notifier{
    _lblConnectionStatus.hidden = [AFNetworkReachabilityManager sharedManager].reachable;
    [self loadBarButtonConnectivity:[AFNetworkReachabilityManager sharedManager].reachable];
    
        
}

-(void)loadBarButtonConnectivity:(BOOL)conectionSts{
    if (conectionSts ) {
        [_barBtnConnectivity setTintColor:connectionGreenColor];
    }else
        [_barBtnConnectivity setTintColor:[UIColor redColor]];
}


- (void)showCalendarOnDate:(NSDate *)date
{
    // calc time interval since 1 January 2001, GMT
    NSInteger interval = [date timeIntervalSinceReferenceDate];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"calshow:%ld", (long)interval]];
    [[UIApplication sharedApplication] openURL:url];
    /* NSString* launchUrl = @"calshow:86400";
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];*/

}

-(void)syncDataWithSynType:(NSInteger)synctype{  // 0 - Full Sync, 1 - Part Sync, 2 - Send Only
    if(![AFNetworkReachabilityManager sharedManager].reachable)
    {
        [kAppDelegate showCustomAlertWithModule:nil Message:@"Please check internet connection."];
        return;
    }

    if(kAppDelegate.customerInfo){
        [kAppDelegate showCustomAlertWithModule:nil Message:@"complete current transaction, then try sync."];
        return;
    }

    if(!companyConfigDict){
        [kAppDelegate showCustomAlertWithModule:nil Message:@"Unable to recognise configuration."];
        return;
    }

    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];
    if(!dataPathString){
        [kAppDelegate showCustomAlertWithModule:nil Message:@"Unable to recognise configuration."];
        return;
    }

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    isSyncInProgress = YES;
    _btnSettings.enabled = NO;
    [self uploadTransactionWithSyncType:synctype];
}

-(void)refreshSyncStatusWithSyncType:(NSInteger)synctype IsStarted:(BOOL)isstarted{
        if(synctype==0){
            if(isstarted){
                // to set layout of status labels
                _lblFullSyncStatus.text=@"Last";
                _lblFullSyncDate.hidden = NO;
                _constFullSyncStatus.constant = 17;

                self.viewProgressFullSync.progress = 0;
                _lblFullSyncDate.text=@"Checking uploads...";
            }

            _btnPartSync.enabled = !isstarted;
            _btnSendOnly.enabled = !isstarted;
            self.viewProgressFullSync.hidden = !isstarted;
        }
        else if(synctype==1){
            if(isstarted){
                // to set layout of status labels
                _lblPartSyncStatus.text=@"Last";
                _lblPartSyncDate.hidden = NO;
                _constPartSyncStatus.constant = 17;
                self.viewProgressPartSync.progress = 0;
                _lblPartSyncDate.text=@"Checking uploads...";
            }

            _btnFullSync.enabled = !isstarted;
            _btnSendOnly.enabled = !isstarted;
            self.viewProgressPartSync.hidden = !isstarted;
        }
        else{
            if(isstarted){
                // to set layout of status labels
                _lblSendOnlyStatus.text=@"Last";
                _lblSendOnlyDate.hidden = NO;
                _constSendOnlyStatus.constant = 17;

                self.viewProgressSendOnly.progress = 0;
                _lblSendOnlyDate.text=@"Checking uploads...";
            }
            
            _btnPartSync.enabled = !isstarted;
            _btnFullSync.enabled = !isstarted;
            self.viewProgressSendOnly.hidden = !isstarted;
        }

    if(!isstarted) {
        _btnSettings.enabled = YES;
        isSyncInProgress = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [self loadSyncStatus];
    }
}

-(void)uploadTransactionWithSyncType:(NSInteger)synctype{
    [self refreshSyncStatusWithSyncType:synctype IsStarted:YES];
    //Create batch file
    [CustomImporter exportUnsentTransactionsToCSVForRepId:kAppDelegate.repId CompanyId:kAppDelegate.selectedCompanyId];

    __block NSError *err = nil;
    NSString *uploadPathString = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/uploads/%@",(long)kAppDelegate.selectedCompanyId,kAppDelegate.repId];

    NSMutableArray *filesToUpload = [NSMutableArray array];
    NSArray *filesInUploadDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:uploadPathString] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey,NSURLPathKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:&err];
    if(filesInUploadDirectory && [filesInUploadDirectory count]>0){
        [filesInUploadDirectory enumerateObjectsUsingBlock:^(NSURL * _Nonnull fpath, NSUInteger idx, BOOL * _Nonnull stop) {
            NSNumber *isdir = nil;
            [fpath getResourceValue:&isdir forKey:NSURLIsDirectoryKey error:&err];

            if(isdir && ![isdir boolValue]){
                [filesToUpload addObject:[fpath path]];
            }
        }];
    }

    if([filesToUpload count]>0) {
        float progressLimit = 0;
        if(synctype<=1) progressLimit = 0.2;
        NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];

        NSString *remoteUploadPath = [dataPathString stringByAppendingFormat:@"handsetimport\\ZipFiles\\"];//[dataPathString stringByAppendingFormat:@"handsetimport\\iphone\\"];


        if([filesToUpload count]==1){
            NSData *data = [NSData dataWithContentsOfFile:[filesToUpload lastObject]];
            NSString* base64String = [data base64EncodedStringWithOptions:0];
            if(base64String){
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        APIToken,@"token",
                                        remoteUploadPath,@"pathtoupload",
                                        [[filesToUpload lastObject] lastPathComponent],@"filename",
                                        base64String,@"base64string",
                                        nil];
                [CommonHelper UploadDataWithAPIName:(NSString *)kUploadDataFileAPI HTTPMethod:HTTTPMethodPOST Params:params ProgressBlock:^(long long bytesUploaded, long long bytesToUpload) {
                    CGFloat progress = (float)bytesUploaded/(float)bytesToUpload;
                    if(progressLimit>0) progress = progress * progressLimit;
                    if(synctype==0)
                        [self.viewProgressFullSync setProgress:progress animated:YES];//(progress <= 1.00f ? progress + 0.1f : 0.0f)
                    else if(synctype==1)
                        [self.viewProgressPartSync setProgress:progress animated:YES];
                    else if(synctype==2)
                        [self.viewProgressSendOnly setProgress:progress animated:YES];
                } CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
                    if([[[response objectForKey:@"status"] objectForKey:@"success"] boolValue]){
                        // write statement to update sync status for ohead,cust if data exist
                        [self updateUploadStatusWithFileName:[[response objectForKey:@"data"] objectForKey:@"filename"]];
                     
                    }
                    else{
                        [kAppDelegate showCustomAlertWithModule:nil Message:[NSString stringWithFormat:@"%@",errormessage]];
                    }

                    if(synctype==2)
                        [self refreshSyncStatusWithSyncType:synctype IsStarted:NO];
                    else
                        [self downloadDataWithSyncType:synctype];
                }];
            }
            else{
                if(synctype==2)
                    [self refreshSyncStatusWithSyncType:synctype IsStarted:NO];
                else
                    [self downloadDataWithSyncType:synctype];
            }
        }
        else{
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    APIToken,@"token",
                                    remoteUploadPath,@"pathtoupload",
                                    nil];

            NSMutableArray *allParams = [NSMutableArray array];
            [filesToUpload enumerateObjectsUsingBlock:^(NSString * _Nonnull filepath, NSUInteger idx, BOOL * _Nonnull stop) {
                NSData *data = [NSData dataWithContentsOfFile:filepath];
                NSString* base64String = [data base64EncodedStringWithOptions:0];
                if(base64String){
                    [params setObject:[filepath lastPathComponent] forKey:@"filename"];
                    [params setObject:base64String forKey:@"base64string"];
                    [allParams addObject:[params copy]];
                }
            }];

            if([allParams count]>0){
                [CommonHelper UploadFilesWithAPI:(NSString *)kUploadDataFileAPI ParamsAndFileNames:allParams ProgressBlock:^(long filesUploaded, long filesToUpload) {
                    CGFloat progress = (float)filesUploaded/(float)filesToUpload;

                    if(progressLimit>0) progress = progress * progressLimit;

                    if(synctype==0)
                        [self.viewProgressFullSync setProgress:progress animated:YES];//(progress <= 1.00f ? progress + 0.1f : 0.0f)
                    else if(synctype==1)
                        [self.viewProgressPartSync setProgress:progress animated:YES];
                    else if(synctype==2)
                        [self.viewProgressSendOnly setProgress:progress animated:YES];
                } CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, NSArray * _Nullable successBatches, NSInteger failedCount) {
                    if(successBatches && [successBatches count]>0){
                        __block NSString *errmessages = @"";
                        [successBatches enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if([[[obj objectForKey:@"status"] objectForKey:@"success"] boolValue]){
                                // write statement to update sync status for ohead,cust if data exist
                                [self updateUploadStatusWithFileName:[[obj objectForKey:@"data"] objectForKey:@"filename"]];
                                
                                
                                
                                
                            }
                            else{
                                if(errmessages.length==0)
                                    errmessages = [NSString stringWithFormat:@"%@",[[obj objectForKey:@"status"] objectForKey:@"message"]];
                                else
                                    errmessages = [errmessages stringByAppendingFormat:@"\n%@",[[obj objectForKey:@"status"] objectForKey:@"message"]];
                            }
                        }];
                        if(errmessages.length>0)
                            [kAppDelegate showCustomAlertWithModule:nil Message:[NSString stringWithFormat:@"%@",errmessages]];
                    }
                    else{
                        [kAppDelegate showCustomAlertWithModule:nil Message:[NSString stringWithFormat:@"%@",errormessage]];
                    }

                    if(synctype==2)
                        [self refreshSyncStatusWithSyncType:synctype IsStarted:NO];
                    else
                        [self downloadDataWithSyncType:synctype];
                }];
            }
            else{
                if(synctype==2)
                    [self refreshSyncStatusWithSyncType:synctype IsStarted:NO];
                else
                    [self downloadDataWithSyncType:synctype];
            }
        }
    }
    else{
        if(synctype==2){
            [self refreshSyncStatusWithSyncType:synctype IsStarted:NO];
            return;
        }

        [self downloadDataWithSyncType:synctype];
    }
}

//Change sent status if data Sent
-(void)updateUploadStatusWithFileName:(NSString *)filename{
    if(![filename isEqual:[NSNull null]] && filename){
        NSArray *fileNameIndexes = [[filename stringByDeletingPathExtension] componentsSeparatedByString:@"_"];
        if([fileNameIndexes count]>2){
            NSInteger batchnum = [[fileNameIndexes lastObject] integerValue];

            NSError *err = nil;
            NSFetchRequest *fetch = [[NSFetchRequest alloc] init];

            // update sync status to OHEADNEW table
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
            [fetch setEntity:entity];
            [fetch setPredicate:[NSPredicate predicateWithFormat:@"batch_no==%li",batchnum]];
            NSArray *results =[kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
            if(!err){
                [results enumerateObjectsUsingBlock:^(NSManagedObjectContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj setValue:@"Sent" forKey:@"order_status"];
                }];

                if([results count]>0){
                    NSString *uploadPathString = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/uploads/%@",(long)kAppDelegate.selectedCompanyId,kAppDelegate.repId];
                    if ([kAppDelegate.managedObjectContext save:&err])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:[uploadPathString stringByAppendingPathComponent:filename] error:&err];
                    }
                }
            }
        }
    }
    
    //Create  upload.json
    NSString *stractualpath=[[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li",(long)kAppDelegate.selectedCompanyId]] ;
    [self createUploadFileName:stractualpath];
    //ENDED
}

-(void)createUploadFileName :(NSString*)stractualpath{
  
    NSString *syncfilenameString=@"sendonly.json";
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
     NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    [dict setObject:[NSNumber numberWithLong:timestamp] forKey:@"lastsendonlydate"];
    
    NSString* fileAtPath = [stractualpath stringByAppendingPathComponent:syncfilenameString];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    [[jsonString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];

}


-(void)downloadDataWithSyncType:(NSInteger)synctype{
    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];

    NSString *strdownloadpath = [dataPathString stringByAppendingFormat:@"handsetexport\\ipad\\Iphone\\%@",kAppDelegate.repId];
   
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:APIToken forKey:@"token"];
    [params setObject:strdownloadpath  forKey:@"dirpath"];

    float progressLimit = 0.8;
    float lastProgressCount = 0;
    if(synctype==0){
        lastProgressCount = self.viewProgressFullSync.progress;
        NSDictionary *dicFullStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/fullsync.json",(long)kAppDelegate.selectedCompanyId]];
        if(dicFullStatus){
           // DebugLog(@"TT %@",[NSNumber numberWithLong:[[[dicFullStatus objectForKey:@"datadownload" ] valueForKey:  @"lastsyncdatetime"] longValue]]);
            
          [params setObject:[NSNumber numberWithLong:[[[dicFullStatus objectForKey:@"datadownload" ] valueForKey:  @"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];
            
        //Mahendra    [params setObject:[NSNumber numberWithLong:[[dicFullStatus objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];
        }

        //[params setObject:@"*.csv|*.txt" forKey:@"filterextensions"];
        [params setObject:@"*.csv" forKey:@"filterextensions"];
        [params setObject:@"*_upd.csv" forKey:@"excludefilter"];

        _lblFullSyncDate.text=@"Downloading data...";
        
        //For ideal stage stop going to sleep mode
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else{
        lastProgressCount = self.viewProgressPartSync.progress;
        NSDictionary *dicPartStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/partsync.json",(long)kAppDelegate.selectedCompanyId]];
        if(dicPartStatus){
            [params setObject:[NSNumber numberWithLong:[[dicPartStatus objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];
        }

        [params setObject:@"*_upd.csv" forKey:@"filterextensions"];
        _lblPartSyncDate.text=@"Downloading data...";
        //For ideal stage stop going to sleep mode
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    if(lastProgressCount>0) progressLimit = 0.6;

    [CommonHelper DownloadDataWithAPIName:(NSString *)kDownloadFileAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:[NSString stringWithFormat:@"%li/tempdata.zip",(long)kAppDelegate.selectedCompanyId] ProgressBlock:^(long long bytesDownloaded, long long bytesToDownload) {
        CGFloat progress = (float)bytesDownloaded/(float)bytesToDownload;
        if(progressLimit>0) progress = lastProgressCount+ (progress * progressLimit);

        if(synctype==0)
            [self.viewProgressFullSync setProgress:progress animated:YES];//(progress <= 1.00f ? progress + 0.1f : 0.0f)
        else
            [self.viewProgressPartSync setProgress:progress animated:YES];

    } CompletionBlock:^(BOOL iscompleted, NSString * _Nullable errormessage, id  _Nullable response) {
        [self downloadNotesFile:synctype==0];
    }];
}

-(void)downloadNotesFile:(BOOL)isfullsync{
    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];
    if(!dataPathString){
        return;
    }

    NSString *strdownloadpath = [dataPathString stringByAppendingString:@"handsetexport\\ipad\\files"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:APIToken forKey:@"token"];
    [params setObject:strdownloadpath  forKey:@"dirpath"];

    float progressLimit = 0;
    float lastProgressCount = 0;

    if(isfullsync){
        lastProgressCount = self.viewProgressFullSync.progress;

        NSDictionary *dicFullStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/fullsync.json",(long)kAppDelegate.selectedCompanyId]];
        if(dicFullStatus){
            [params setObject:[NSNumber numberWithLong:[[dicFullStatus objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];
        }
    }
    else{
        lastProgressCount = self.viewProgressPartSync.progress;

        NSDictionary *dicPartStatus = [CommonHelper loadFileDataWithVirtualFilePath:[NSString stringWithFormat:@"%li/partsync.json",(long)kAppDelegate.selectedCompanyId]];
        if(dicPartStatus){
            [params setObject:[NSNumber numberWithLong:[[dicPartStatus objectForKey:@"lastsyncdatetime"] longValue]] forKey:@"lastsyncdatetime"];
        }
    }
    //[params setObject:@"*notes.txt" forKey:@"filterextensions"];
    [params setObject:@"*notes.txt|*.txt" forKey:@"filterextensions"];

    if(lastProgressCount>0) progressLimit = 0.2;

    [CommonHelper DownloadDataWithAPIName:(NSString *)kDownloadFileAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:[NSString stringWithFormat:@"%li/tempdata_notes.zip",(long)kAppDelegate.selectedCompanyId] ProgressBlock:^(long long bytesDownloaded, long long bytesToDownload) {
        CGFloat progress = (float)bytesDownloaded/(float)bytesToDownload;
        if(progressLimit>0) progress = lastProgressCount+ (progress * progressLimit);

        if(isfullsync)
            [self.viewProgressFullSync setProgress:progress animated:YES];//(progress <= 1.00f ? progress + 0.1f : 0.0f)
        else
            [self.viewProgressPartSync setProgress:progress animated:YES];

    } CompletionBlock:^(BOOL iscompleted, NSString * _Nullable errormessage, id  _Nullable response) {

        if(isfullsync)
            _lblFullSyncDate.text=@"Loading data...";
        else
            _lblPartSyncDate.text=@"Loading data...";

        [self performSelector:@selector(finalizingDataDownloads:) withObject:[NSNumber numberWithBool:isfullsync] afterDelay:0.001];
    }];
}

-(void)finalizingDataDownloads:(NSNumber *)isfullsync{
    NSString *zipfilenamenotesString=[NSString stringWithFormat:@"%li/tempdata_notes.zip",(long)kAppDelegate.selectedCompanyId] ;
    NSString *zipfilenameString=[NSString stringWithFormat:@"%li/tempdata.zip",(long)kAppDelegate.selectedCompanyId] ;
    NSString *unzippath=[NSString stringWithFormat:@"%li/localdata",(long)kAppDelegate.selectedCompanyId] ;

    // to unzip notes files & merge their contents
    if([CommonHelper UnzipFileWithVirtualFilePath:zipfilenamenotesString DestinationPath:nil]){
        [self fillDataToDatabaseWithVirtualFilePath:[zipfilenamenotesString stringByDeletingPathExtension]];
    }

    NSString *stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[zipfilenameString stringByDeletingLastPathComponent]];
    
    if([CommonHelper UnzipFileWithVirtualFilePath:zipfilenameString DestinationPath:unzippath]){
        NSString *syncfilenameString=@"partsync.json";
        if([isfullsync boolValue])
            syncfilenameString = @"fullsync.json";


        NSString *stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[zipfilenameString stringByDeletingLastPathComponent]];
       
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[stractualpath stringByAppendingPathComponent:syncfilenameString]])
            [[NSFileManager defaultManager] removeItemAtPath:[stractualpath stringByAppendingPathComponent:syncfilenameString] error:NULL];

//        // copy download information file for full/part sync
//        [[NSFileManager defaultManager] moveItemAtPath:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"] toPath:[stractualpath stringByAppendingPathComponent:syncfilenameString] error:NULL];
//
       
        
        [self fillDataToDatabaseWithVirtualFilePath:unzippath];

        [self performSelector:@selector(updateRelationships) withObject:nil];
       
        
        // [self checkBedgeVisibility];
    }

    //Merge partSync/FullSync Downloadreport.json files Update when click FullSync / partSync
     [self mergeDownloadFiles:isfullsync dirPath:stractualpath];
    [self checkBedgeVisibility];
    
    if([isfullsync boolValue]){
        self.viewProgressFullSync.progress = 0;
        _lblFullSyncDate.text=@"Checking images...";
    }
    else{
        self.viewProgressPartSync.progress = 0;
        _lblPartSyncDate.text=@"Checking images...";
    }

    [kAppDelegate reloadConfigurationData];

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [self prepareDownloadImagesWithFullSync:[isfullsync boolValue]];
}


//Merge partSync/FullSync Downloadreport.json files
-(void)mergeDownloadFiles:(NSNumber *)isfullsync dirPath:(NSString *)stractualpath{
    
    NSString *syncfilenameString=@"partsync.json";
    if([isfullsync boolValue])
        syncfilenameString = @"fullsync.json";
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"]]) {
        NSDictionary *Dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"]] options:NSJSONReadingAllowFragments error:NULL];
        if (Dict!=nil)
            [dict setObject:Dict forKey:@"datadownload"];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"]])
            [[NSFileManager defaultManager] removeItemAtPath:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"] error:NULL];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[stractualpath stringByAppendingPathComponent:@"tempdata_notes/downloadreport.json"]]) {
        NSDictionary *Dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[stractualpath stringByAppendingPathComponent:@"tempdata_notes/downloadreport.json"]] options:NSJSONReadingAllowFragments error:NULL];
        if (Dict!=nil)
            [dict setObject:Dict forKey:@"notedownload"];
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[stractualpath stringByAppendingPathComponent:@"tempdata_notes/downloadreport.json"]])
            [[NSFileManager defaultManager] removeItemAtPath:[stractualpath stringByAppendingPathComponent:@"tempdata_notes/downloadreport.json"] error:NULL];
        
    }
    
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    if([isfullsync boolValue])
        [dict setObject:[NSNumber numberWithLong:timestamp] forKey:@"lastfullsyncdate"];
    else
        [dict setObject:[NSNumber numberWithLong:timestamp] forKey:@"lastpartsyncdate"];
        
  //  NSDictionary *dict=@{  @"datadownload": [CommonHelper loadFileDataWithVirtualFilePath:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"]],    @"notedownload": [CommonHelper loadFileDataWithVirtualFilePath:[stractualpath stringByAppendingPathComponent:@"tempdata_notes/downloadreport.json"]] ,  };
    
    
    
    NSString* fileAtPath = [stractualpath stringByAppendingPathComponent:syncfilenameString];
    
    
    
    NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        }
    
        [[jsonString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];

    
    // copy download information file for full/part sync
   // [[NSFileManager defaultManager] moveItemAtPath:[stractualpath stringByAppendingPathComponent:@"localdata/downloadreport.json"] toPath:[stractualpath stringByAppendingPathComponent:syncfilenameString] error:NULL];
  
    NSArray  *file= [[[NSFileManager defaultManager]
                      contentsOfDirectoryAtPath:[stractualpath stringByAppendingPathComponent:@"tempdata_notes"] error:&err] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH [cd] 'info'"]];
    for (NSInteger i =0; i<file.count; i++) {

        NSString *destPath=[stractualpath stringByAppendingFormat:@"/localdata/%@",[file objectAtIndex:i]];
        NSString *sourcePath=[stractualpath stringByAppendingFormat:@"/tempdata_notes/%@",[file objectAtIndex:i]];
   [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destPath error:NULL];
    }
}


-(void)prepareDownloadImagesWithFullSync:(BOOL)isfullsync{
    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];
    if(!dataPathString) return;

    NSString *strdownloadpath = [dataPathString stringByAppendingFormat:@"handsetexport\\ipad\\FILES"];//[dataPathString stringByAppendingFormat:@"handsetexport\\ipad\\%@\\FILES",kAppDelegate.repId];//


    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:APIToken forKey:@"token"];
    [params setObject:strdownloadpath  forKey:@"dirpath"];
    [params setObject:@"*.jpg" forKey:@"filterextensions"]; //|*.png

    [CommonHelper DownloadDataWithAPIName:(NSString *)kListFilesAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL iscompleted, NSString * _Nullable errormessage, id  _Nullable response) {
        if(iscompleted){
            [self performSelector:@selector(downloadImagesWithFullSync:) withObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:isfullsync],[response objectForKey:@"data"],nil] afterDelay:0.001];        }
        else
            [self performSelector:@selector(finalizingImageDownloads:) withObject:[NSNumber numberWithBool:isfullsync] afterDelay:0.001];
    }];
}

-(NSArray *)downloadProductCategoryImages{
    NSMutableArray *ProdCatIds = [NSMutableArray array];

    NSError *err = nil;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetch setEntity:entity];

    NSAttributeDescription* prodcode = [entity.attributesByName objectForKey:@"stock_code"];
    NSMutableArray *arrFetchList = [NSMutableArray arrayWithObject:prodcode];

    [fetch setPropertiesToFetch:arrFetchList];
    NSArray *results =[kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
    if(!err)
    {
        [ProdCatIds addObjectsFromArray:[results valueForKeyPath:@"stock_code"]];
    }

    // to load group1 description to download image name
    entity = [NSEntityDescription entityForName:@"GROUP1CODES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetch setEntity:entity];

    NSAttributeDescription* gdesc = [entity.attributesByName objectForKey:@"gdescription"];
    arrFetchList = [NSMutableArray arrayWithObject:gdesc];

    [fetch setPropertiesToFetch:arrFetchList];
    results =[kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
    if(!err)
    {
        [ProdCatIds addObjectsFromArray:[results valueForKeyPath:@"gdescription"]];
    }

    if(companyConfigDict && [[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"categorylevels"] integerValue]>1){
        // to load group1 description to download image name
        entity = [NSEntityDescription entityForName:@"GROUP2CODES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        [fetch setEntity:entity];

        NSAttributeDescription* gdesc = [entity.attributesByName objectForKey:@"gdescription"];
        arrFetchList = [NSMutableArray arrayWithObject:gdesc];

        [fetch setPropertiesToFetch:arrFetchList];
        results =[kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
        if(!err)
        {
            [ProdCatIds addObjectsFromArray:[results valueForKeyPath:@"gdescription"]];
        }
    }

    if(featureDict && [[featureDict objectForKey:@"productfamilitagsenabled"] boolValue]){
        // to load group1 description to download image name
        entity = [NSEntityDescription entityForName:@"EXTRAGROUPCODES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        [fetch setEntity:entity];

        NSAttributeDescription* gdesc = [entity.attributesByName objectForKey:@"gdescription"];
        arrFetchList = [NSMutableArray arrayWithObject:gdesc];

        [fetch setPropertiesToFetch:arrFetchList];
        results =[kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
        if(!err)
        {
            [ProdCatIds addObjectsFromArray:[results valueForKeyPath:@"gdescription"]];
        }
    }

    return [NSArray arrayWithArray:ProdCatIds];
}

-(void)downloadImagesWithFullSync:(NSArray *)arrVals{
    NSNumber *isfullsync = [arrVals firstObject];
    NSArray *arrFetchedFiles = [arrVals lastObject];

    NSMutableArray *arrFiles = [NSMutableArray array];

    // to get product codes & category names
    NSArray *ProductCatIds = [self downloadProductCategoryImages];
    [ProductCatIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileNameString = [[CommonHelper getStringByRemovingSpecialChars:obj] lowercaseString];
        NSArray *filteredArray = [arrFetchedFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.filename beginswith [cd] %@",fileNameString]];
        if([filteredArray count]>0){
            [arrFiles addObjectsFromArray:filteredArray];
        }
    }];

    NSMutableArray *arrImageQueue = [NSMutableArray array];

    // to validate images updated on server are different than downloaded one
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DOWNLOADHISTORY" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];

    NSError *err = nil;
    NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
    if([results count]==0){
        [arrImageQueue addObjectsFromArray:arrFiles];
    }
    else{
        [arrFiles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *arrfound = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"filename==%@",[[obj objectForKey:@"filename"] lowercaseString]]];
            if([arrfound count]>0 && [[[arrfound lastObject] valueForKey:@"filesizeinkb"] integerValue]==[[obj objectForKey:@"filesizeinkb"] integerValue] && [[[arrfound lastObject] valueForKey:@"lastmodifiedon"] isEqualToString:[obj objectForKey:@"lastmodifiedon"]]){}
            else{
                [arrImageQueue addObject:obj];
            }
        }];
    }

    if([arrImageQueue count]==0) {
        [self performSelector:@selector(finalizingImageDownloads:) withObject:isfullsync afterDelay:0.001];
        return;
    }

    if([isfullsync boolValue]){
        _lblFullSyncDate.text=@"Downloading images...";
        //For ideal stage stop going to sleep mode
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else{
        _lblPartSyncDate.text=@"Downloading images...";
        //For ideal stage stop going to sleep mode
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }


    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];

    NSString *strdownloadpath = [dataPathString stringByAppendingFormat:@"handsetexport\\ipad\\FILES\\"];//[dataPathString stringByAppendingFormat:@"handsetexport\\ipad\\%@\\FILES",kAppDelegate.repId];//


    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:APIToken forKey:@"token"];
    [params setObject:strdownloadpath  forKey:@"dirpath"];
    [CommonHelper DownloadDataFiles:arrImageQueue Params:params VirtualDirPath:[NSString stringWithFormat:@"%li/images",kAppDelegate.selectedCompanyId] ProgressBlock:^(long filesDownloaded, long filesToDownload) {

        CGFloat progress = (float)filesDownloaded/(float)filesToDownload;
        if(isfullsync)
            [self.viewProgressFullSync setProgress:progress animated:YES];//(progress <= 1.00f ? progress + 0.1f : 0.0f)
        else
            [self.viewProgressPartSync setProgress:progress animated:YES];

        if(filesDownloaded % 10==0) [self performSelector:@selector(updateProductImageStatus) withObject:nil afterDelay:0.001];

    } CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, NSInteger successCount, NSInteger failedCount) {
        [self performSelector:@selector(finalizingImageDownloads:) withObject:isfullsync afterDelay:0.001];
    }];
}

-(void)finalizingImageDownloads:(NSNumber *)isfullsync{
    NSString *zipfilenameString=[NSString stringWithFormat:@"%li/images.zip",(long)kAppDelegate.selectedCompanyId] ;
    if([CommonHelper UnzipFileWithVirtualFilePath:zipfilenameString DestinationPath:nil]){
        NSString *syncfilenameString=@"partsync_img.json";
        if([isfullsync boolValue])
            syncfilenameString = @"fullsync_img.json";


        NSString *stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[zipfilenameString stringByDeletingLastPathComponent]];
        if([[NSFileManager defaultManager] fileExistsAtPath:[stractualpath stringByAppendingPathComponent:syncfilenameString]])
            [[NSFileManager defaultManager] removeItemAtPath:[stractualpath stringByAppendingPathComponent:syncfilenameString] error:NULL];

        // copy download information file for full/part sync
        [[NSFileManager defaultManager] moveItemAtPath:[stractualpath stringByAppendingPathComponent:@"images/downloadreport.json"] toPath:[stractualpath stringByAppendingPathComponent:syncfilenameString] error:NULL];
    }
    [self performSelector:@selector(updateProductImageStatus) withObject:nil afterDelay:0.001];

    [self refreshSyncStatusWithSyncType:[isfullsync boolValue]?0:1 IsStarted:NO];
}

-(void)fillDataToDatabaseWithVirtualFilePath:(NSString *)strvirtualpath{
    NSDictionary *dic = [CommonHelper loadFileDataWithVirtualFilePath:(NSString *)kValidateLicenseFileName];
    if(dic && [[[dic objectForKey:@"status"] objectForKey:@"success"] boolValue]){
        NSString *stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:strvirtualpath];

        // to set processing index - it will help while creating relationship
        NSDictionary *processingIndexesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithInteger:2],@"ohead",
                                               [NSNumber numberWithInteger:2],@"oheads", // for importing batches
                                               [NSNumber numberWithInteger:1],@"olines",
                                               [NSNumber numberWithInteger:4],@"ilines",
                                               [NSNumber numberWithInteger:3],@"ihead",
                                               [NSNumber numberWithInteger:5],@"purchaseorders",
                                               [NSNumber numberWithInteger:6],@"prod",
                                               [NSNumber numberWithInteger:7],@"cust",
                                               nil];

        NSArray *allfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stractualpath error:nil];
        NSMutableArray *tmpfiles = [NSMutableArray array];
        [allfiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *strkey=[[[[obj lowercaseString] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] firstObject];
            NSInteger processindex = [processingIndexesDict valueForKey:strkey]?[[processingIndexesDict valueForKey:strkey] integerValue]:0;

            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 obj,@"filename",
                                 [NSNumber numberWithInteger:processindex],@"index",
                                 nil];
            [tmpfiles addObject:dic];
        }];

        NSArray *sortedFilesArray = [tmpfiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];

        [sortedFilesArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull filedic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *fname = [filedic objectForKey:@"filename"];

            //[[fname lowercaseString] hasPrefix:@"ihead"] || [[fname lowercaseString] hasPrefix:@"iline"] || [[fname lowercaseString] hasPrefix:@"ohead"] || [[fname lowercaseString] hasPrefix:@"oline"] ||
            //if( [[fname lowercaseString] containsString:@"_upd"] || [[fname lowercaseString] hasPrefix:@"iline"]) continue;

            NSString *strfilenameforparserindex = [[[[[fname lowercaseString] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] firstObject] stringByAppendingPathExtension:[[fname lowercaseString] pathExtension]];
            NSArray *arrfiles = [[[dic objectForKey:@"data"] objectForKey:@"prerequisites"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.filename==%@",strfilenameforparserindex]];
            if([arrfiles count]>0){
                [CustomImporter initWithFileName:[strvirtualpath stringByAppendingPathComponent:fname] ParserType:(CSVParserType)[[[arrfiles firstObject] objectForKey:@"parsertype"] integerValue]];

                [[NSFileManager defaultManager] removeItemAtPath:[stractualpath stringByAppendingPathComponent:fname] error:NULL];
            }
            else{
                if([[fname lowercaseString] hasSuffix:@"notes.txt"]){
                    [CustomImporter initWithFileName:[strvirtualpath stringByAppendingPathComponent:fname] ParserType:ParserTypeNotes];

                    [[NSFileManager defaultManager] removeItemAtPath:[stractualpath stringByAppendingPathComponent:fname] error:NULL];
                }
                
            }
        }];

        [self clearPartUpdateFilesFromServer];
        [kNSNotificationCenter postNotificationName:kRefreshTabItems object:nil];
    }
}

-(void)clearPartUpdateFilesFromServer{
    NSString  *dataPathString = [[companyConfigDict objectForKey:@"associatedpathinfo"] objectForKey:@"physicaldatapath"];
    NSString *strdownloadpath = [dataPathString stringByAppendingFormat:@"handsetexport\\ipad\\%@",kAppDelegate.repId];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:APIToken,@"token",
                            strdownloadpath,@"Filepath",
                            @"*_UPD.csv",@"Filterextensions",
                            [NSNumber numberWithBool:YES],@"deletepermanently",
                            nil];
    [CommonHelper DownloadDataWithAPIName:(NSString *)kArchiveFilesAPI HTTPMethod:HTTTPMethodPOST Params:params VirtualSavePath:nil ProgressBlock:nil CompletionBlock:^(BOOL issuccess, NSString * _Nullable errormessage, id  _Nullable response) {
//        BOOL isss = issuccess;
        DebugLog(@"clearPartUpdateFilesFromServer dsdsd");
    }];
}

-(void)updateRelationships{
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];

    __block BOOL isModified = NO;
    // To get group1 codes
    __block NSEntityDescription *entity = [NSEntityDescription entityForName:@"GROUP1CODES" inManagedObjectContext:context];

    __block NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSError *err = nil;
    NSArray *group1results = [context executeFetchRequest:fetch error:&err];

    // to get all products
    entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allproducts = [context executeFetchRequest:fetch error:&err];

    if(!err){
        [group1results enumerateObjectsUsingBlock:^(NSManagedObject *_Nonnull grp1, NSUInteger idx, BOOL * _Nonnull stop) {
            // to set relationship with products
            __block NSArray *productresults = [allproducts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category==%@",[grp1 valueForKey:@"group1code"]]];

            // setting products which belongs to group1/category
            NSSet *group1products = [NSSet setWithArray:productresults];
            if(![group1products isEqual:[grp1 valueForKey:@"products"]]){
                [grp1 setValue:group1products forKey:@"products"];
                if(!isModified) isModified = YES;
            }

            // to get group2 codes relationships if config enabled
            if(companyConfigDict && [[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"categorylevels"] integerValue]>1){
                entity = [NSEntityDescription entityForName:@"GROUP2CODES" inManagedObjectContext:context];
                fetch = [[NSFetchRequest alloc] init];
                [fetch setEntity:entity];
                [fetch setPredicate:[NSPredicate predicateWithFormat:@"group2code IN %@",[productresults valueForKeyPath:@"grp2"]]];

                NSArray *group2results = [context executeFetchRequest:fetch error:&err];
                if(!err){
                    [group2results enumerateObjectsUsingBlock:^(NSManagedObject *_Nonnull grp2, NSUInteger idx, BOOL * _Nonnull stop) {
                        // setting products which belongs to group2/grp2
                        NSArray *arrgroup2products = [productresults filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"grp2==%@",[grp2 valueForKey:@"group2code"]]];
                        NSSet *group2products = [NSSet setWithArray:arrgroup2products];
                        if(![group2products isEqual:[grp2 valueForKey:@"products"]]){
                            [grp2 setValue:group2products forKey:@"products"];
                            if(!isModified) isModified = YES;
                        }
                    }];

                    NSSet *group2s = [NSSet setWithArray:group2results];
                    if(![group2s isEqual:[grp1 valueForKey:@"group2"]]){
                        [grp1 setValue:group2s forKey:@"group2"];
                        if(!isModified) isModified = YES;
                    }
                }
            }
        }];
    }

    // update relationship of extra group/promotional group codes
    if(featureDict && [[featureDict objectForKey:@"productfamilitagsenabled"] boolValue]){
        entity = [NSEntityDescription entityForName:@"EXTRAGROUPCODES" inManagedObjectContext:context];

        fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entity];
        NSArray *extragroupresults = [context executeFetchRequest:fetch error:&err];
        if(!err){
            [extragroupresults enumerateObjectsUsingBlock:^(NSManagedObject *_Nonnull extra, NSUInteger idx, BOOL * _Nonnull stop) {
                // to set relationship with products
                NSArray *productresults = [allproducts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"extracode1==%@ || extracode2==%@ || extracode3==%@",[extra valueForKey:@"extragroupcode"],[extra valueForKey:@"extragroupcode"],[extra valueForKey:@"extragroupcode"]]];

                // setting products which belongs to group1/category
                NSSet *extragroupproducts = [NSSet setWithArray:productresults];
                if(![extragroupproducts isEqual:[extra valueForKey:@"products"]]){
                    [extra setValue:extragroupproducts forKey:@"products"];
                    if(!isModified) isModified = YES;
                }
            }];
        }
    }

    // to set relationship of product with olines/ilines/olinesnew
    // to get all products

    BOOL isError = NO;
    // block comment added by Satish on 24th feb 2016

    // block comment  by Mahendra du to data loading issue on 30th May 2016
   /* entity = [NSEntityDescription entityForName:@"OLINES" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allOlines = [context executeFetchRequest:fetch error:&err];
    isError = err!=nil;

    entity = [NSEntityDescription entityForName:@"ILINES" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allIlines = [context executeFetchRequest:fetch error:&err];

    if(!isError) isError = err!=nil;

    entity = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allOlinesNew = [context executeFetchRequest:fetch error:&err];
    if(!isError) isError = err!=nil;*/

    entity = [NSEntityDescription entityForName:@"PURCHASEORDERS" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allPOs = [context executeFetchRequest:fetch error:&err];
    if(!isError) isError = err!=nil;

    /*if(!isError){
        if([allOlines count]>0 || [allIlines count]>0 || [allOlinesNew count]>0){
            [allproducts enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull prod, NSUInteger idx, BOOL * _Nonnull stop) {
                // to set olines belong to product
                NSArray *productOlines = [allOlines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"product_code == %@",[prod valueForKey:@"stock_code"]]];

                NSSet *prodOlines = [NSSet setWithArray:productOlines];
                if(![prodOlines isEqual:[prod valueForKey:@"orderlines"]]){
                    [prod setValue:prodOlines forKey:@"orderlines"];
                    if(!isModified) isModified = YES;
                }

                // to set Ilines belong to product
                NSArray *productIlines = [allIlines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"product_code == %@",[prod valueForKey:@"stock_code"]]];

                NSSet *prodIlines = [NSSet setWithArray:productIlines];
                if(![prodIlines isEqual:[prod valueForKey:@"invoicelines"]]){
                    [prod setValue:prodIlines forKey:@"invoicelines"];
                    if(!isModified) isModified = YES;
                }

                // to set Olinesnew belong to project
//                NSArray *productOlinesnew = [allOlinesNew filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid == %@",[prod valueForKey:@"stock_code"]]];
//
//                NSSet *prodOlinesnew = [NSSet setWithArray:productOlinesnew];
//                if(![prodOlinesnew isEqual:[prod valueForKey:@"orderlinesnew"]]){
//                    [prod setValue:prodOlinesnew forKey:@"orderlinesnew"];
//                    if(!isModified) isModified = YES;
//                }

                // to set PO belongs to product
                NSArray *productPOs = [allPOs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productcode == %@",[prod valueForKey:@"stock_code"]]];// [context executeFetchRequest:fetch error:&err];

                NSSet *prodPOs = [NSSet setWithArray:productPOs];
                if(![prodPOs isEqual:[prod valueForKey:@"porders"]]){
                    [prod setValue:prodPOs forKey:@"porders"];
                    if(!isModified) isModified = YES;
                }

            }];
        }
    }*/

    // to get customers & update relation with orders/invoices/created transaction from device

   /* isError = NO;
    entity = [NSEntityDescription entityForName:@"OHEAD" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allOHeads = [context executeFetchRequest:fetch error:&err];
    isError = err!=nil;

    entity = [NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    __block NSArray *allIHeads = [context executeFetchRequest:fetch error:&err];

    if(!isError) isError = err!=nil;8/

//    entity = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:context];
//    fetch = [[NSFetchRequest alloc] init];
//    [fetch setEntity:entity];
//    __block NSArray *allOHeadsNew = [context executeFetchRequest:fetch error:&err];
   
    
    
    
    //  Mahendra Commited iHead and iLine relationship updation
    
 /*   if(!isError) isError = err!=nil;
    if(!isError){
        if([allOHeads count]>0 || [allIHeads count]>0 ){ //|| [allOHeadsNew count]>0
            entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:context];
            fetch = [[NSFetchRequest alloc] init];
            [fetch setEntity:entity];
            [fetch setPredicate:[NSPredicate predicateWithFormat:@"delivery_address=='000'"]];
            NSArray *allCustomers = [context executeFetchRequest:fetch error:&err];
            [allCustomers enumerateObjectsUsingBlock:^(NSManagedObject * _Nonnull cust, NSUInteger idx, BOOL * _Nonnull stop) {
                // to set oheads for customer
                NSArray *customerOheads = [allOHeads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer_code == %@ ",[cust valueForKey:@"acc_ref"]]];
                //NSArray *customerOheads = [allOHeads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer_code == %@ && del_add_code==%@",[cust valueForKey:@"acc_ref"],[cust valueForKey:@"delivery_address"]]];
                NSSet *custOheads = [NSSet setWithArray:customerOheads];
//                if(![custOheads isEqual:[cust valueForKey:@"oheads"]]){
                    [cust setValue:custOheads forKey:@"oheads"];
                    if(!isModified) isModified = YES;

                    // olines
                    [customerOheads enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray *mainOlines = [allOlines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"order_number == %@",[obj valueForKey:@"order_number"]]];

                        NSSet *olines = [NSSet setWithArray:mainOlines];
                        if(![olines isEqual:[obj valueForKey:@"orderlines"]]){
                            [obj setValue:olines forKey:@"orderlines"];
                            if(!isModified) isModified = YES;
                        }
                    }];
//                }

                // to set iheads for customer
                NSArray *customerIheads = [allIHeads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer_code == %@",[cust valueForKey:@"acc_ref"]]];
                //NSArray *customerIheads = [allIHeads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer_code == %@ && delv_add_code==%@",[cust valueForKey:@"acc_ref"],[cust valueForKey:@"delivery_address"]]];
                NSSet *custIheads = [NSSet setWithArray:customerIheads];
//                if(![custIheads isEqual:[cust valueForKey:@"iheads"]]){
                    [cust setValue:custIheads forKey:@"iheads"];
                    if(!isModified) isModified = YES;

                    // ilines
                    [customerIheads enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray *mainIlines = [allIlines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"invoice_num == %@",[obj valueForKey:@"invoice_num"]]];

                        NSSet *ilines = [NSSet setWithArray:mainIlines];
                        if(![ilines isEqual:[obj valueForKey:@"invoicelines"]]){
                            [obj setValue:ilines forKey:@"invoicelines"];
                            if(!isModified) isModified = YES;
                        }
                    }];
//                }

                
            //Restore and Supervisor update relationship
                
                // to set oheadsnew for customer
//                NSArray *customerOheadsNew = [allOHeadsNew filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customerid == %@",[cust valueForKey:@"acc_ref"]]];
//                //NSArray *customerOheadsNew = [allOHeadsNew filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customerid == %@ && deliveryaddressid==%@",[cust valueForKey:@"acc_ref"],[cust valueForKey:@"delivery_address"]]];
//                NSSet *custOheadsNew = [NSSet setWithArray:customerOheadsNew];
//                if(![custOheadsNew isEqual:[cust valueForKey:@"oheadsnew"]]){
//                    [cust setValue:custOheadsNew forKey:@"oheadsnew"];
//                    if(!isModified) isModified = YES;
//
//                    // olinesnew
//                    [customerOheadsNew enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        NSArray *mainOlinesnew = [allOlinesNew filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderid == %@",[obj valueForKey:@"orderid"]]];
//
//                        NSSet *olinesNew = [NSSet setWithArray:mainOlinesnew];
//                        if(![olinesNew isEqual:[obj valueForKey:@"orderlinesnew"]]){
//                            [obj setValue:olinesNew forKey:@"orderlinesnew"];
//                            if(!isModified) isModified = YES;
//                        }
//                    }];
//                }
            }];
        }
    }*/
    
    
    
    
    

    if(isModified){
        if (![context save:&err])
        {
            printf("Error while deleting\n%s",
                   [[err localizedDescription] ?
                    [err localizedDescription] : [err description] UTF8String]);
        }
    }
    if(isError){
        
    }
}

-(void)updateProductImageStatus{
    NSString *stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",kAppDelegate.selectedCompanyId];

    NSError *err = nil;
    NSArray *arrFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:stractualpath error:&err];
    if(err || [arrFiles count]==0)
        return;

    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];

    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];


    NSArray *results = [context executeFetchRequest:fetch error:&err];
    if(!err && [results count]>0){
        [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *strimgname=[[[CommonHelper getStringByRemovingSpecialChars:[obj valueForKey:@"stock_code"]] lowercaseString] stringByAppendingString:@".jpg"];
            NSArray *arrFound = [arrFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH [cd] %@",strimgname]];
            if(arrFound && [arrFound count]>0){
                [obj setValue:[NSNumber numberWithBool:YES] forKey:@"isimageavailable"];
            }
            else
                [obj setValue:[NSNumber numberWithBool:NO] forKey:@"isimageavailable"];
        }];
        if (![context save:&err])
        {
            printf("Error while deleting\n%s",
                   [[err localizedDescription] ?
                    [err localizedDescription] : [err description] UTF8String]);
        }
    }
}

#pragma mark - Control generated events
- (IBAction)appointmentClick:(id)sender{
 /*   CustomDatePickerViewController *customDatePickerViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"CustomDatePickerViewController"];
    //customDatePickerViewController.delegate=self;
    [self.navigationController pushViewController: customDatePickerViewController animated:YES];*/

    NSDateComponents *comptemp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];

//    NSDateComponents *comps = [[NSDateComponents alloc] init];
//    [comps setDay:4];
//    [comps setMonth:7];
//    [comps setYear:2010];

//    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    [self showCalendarOnDate:[[NSCalendar currentCalendar] dateFromComponents:comptemp]];

    [self showCalendarOnDate:[NSDate date]];
}

-(IBAction)syncFull:(id)sender
{
    [self syncDataWithSynType:0];
}

-(IBAction)syncPart:(id)sender
{
    [self syncDataWithSynType:1];
}

-(IBAction)sendOnly:(id)sender
{
    [self syncDataWithSynType:2];
}

//******* Navigation buttons action
- (IBAction)showSettings:(id)sender{
    
    [self performSegueWithIdentifier:@"toPasscode" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.navigationItem.title=@"";
}


//When companySwitch Notification Called
- (void) refreshCompanydata:(NSNotification *) notification{
    [kUserDefaults  setInteger:0  forKey: @"CustomerMode"];
    [kUserDefaults  setInteger:0  forKey: @"PriceDisplay"];
    [kUserDefaults  setInteger:0  forKey: @"CatalogeScrolling"];
    [kUserDefaults  setInteger:0  forKey: @"NumericKeyboard"];
    //Check default values.
}


@end
