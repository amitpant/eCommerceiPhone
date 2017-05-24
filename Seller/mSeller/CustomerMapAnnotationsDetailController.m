//
//  CustomerMapAnnotationsDetailController.m
//  mSeller
//
//  Created by Ashish Pant on 9/16/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerMapAnnotationsDetailController.h"

@interface CustomerMapAnnotationsDetailController (){
    NSDictionary *companyConfigDict;


    NSString *strFullImagePath;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnTransaction;
@end

@implementation CustomerMapAnnotationsDetailController
@synthesize delegate;

-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    //    featureDict = nil;
    //    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    //    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
    //        featureDict = [dic objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];

    BOOL disableTransaction = ([[_customerInfo valueForKey:@"stopflag"] boolValue] || [[[_customerInfo valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]) || kAppDelegate.customerInfo!=nil;

    // remove main account address to use as first delivery address
    if(!companyConfigDict || ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"usemainaccountasdeliveryaddresss"] boolValue]){
        if([[self.customerInfo valueForKey:@"delivery_address"] isEqualToString:@"000"]) disableTransaction = YES;
    }

    _btnTransaction.enabled = !disableTransaction;
   
   if (_customerInfo==nil) {
        _btnTransaction.enabled=NO;
        _btnDirectionsFrom.enabled=NO;
        _btnDirectionsTo.enabled=NO;
        _btnShowCustomer.enabled=NO;
        _btnAddToContact.enabled=NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _txtViewAddress.text=_strCustomerAddSubTitle;
    _lblCustomerCode_Name.text=_strFrom_toTitle;

    if(_selectedTag==101)
        _btnDirectionsFrom.enabled = NO;
    else if(_selectedTag==102)
        _btnDirectionsTo.enabled = NO;
    
    self.scrollImageView.minimumZoomScale=0.8;
    
    self.scrollImageView.maximumZoomScale=9.0;
    
    //self.scrollImageView.contentSize=CGSizeMake(1280, 960);
    
    self.scrollImageView.delegate=self;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.streetImageView;
}
-(void)loadImage
{
//    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
//    NSManagedObject *customerDetail = [fetchedData objectAtIndex:0];
    [_activityIndicatorView startAnimating];
    [self updateStreetImage:_customerInfo];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(zoomImage:)];
    
    [_scrollImageView addGestureRecognizer:tap];

}
-(void)updateStreetImage:(NSManagedObject *)selectedCustomer
{
    
    //http://maps.googleapis.com/maps/api/streetview?size=400x400&location=40.720032,%20-73.988354&fov=90&heading=235&pitch=10&sensor=false
    
    NSString* downloadpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/streetview",kAppDelegate.selectedCompanyId];
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadpath])
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadpath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    
    
    NSString *strImgPath = [NSString stringWithFormat:@"%@/%@.jpg",downloadpath,[CommonHelper getStringByRemovingSpecialChars:_strFrom_toTitle]];
    
    NSString* strpath = [strImgPath copy];
    if([[NSFileManager defaultManager] fileExistsAtPath:strImgPath]){
        _streetImageView.image = [UIImage imageWithContentsOfFile:strImgPath];
        strFullImagePath=strImgPath;
  [_activityIndicatorView stopAnimating];
    }
    else{
        if([[selectedCustomer valueForKey:@"latitude"] doubleValue]!=0.0 && [[selectedCustomer valueForKey:@"longitude"] doubleValue]!=0.0){
            NSString* strurl=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/streetview?size=640x640&location=%f,%f&fov=90&heading=235&pitch=10&sensor=false",[[selectedCustomer valueForKey:@"latitude"] doubleValue],[[selectedCustomer valueForKey:@"longitude"] doubleValue]];
            
            NSURL* apiUrl = [NSURL URLWithString:strurl];
            NSData* data = [NSData dataWithContentsOfURL:
                            apiUrl];
            [data writeToFile:strImgPath atomically:YES];
            strFullImagePath=strpath;
            _streetImageView.image = [UIImage imageWithContentsOfFile:strpath];
            [_activityIndicatorView stopAnimating];
        }
        else
        {
        _streetImageView.image = [UIImage imageNamed:@"no_preview.png"];
        [_activityIndicatorView stopAnimating];
        }
    }
  
}
//#pragma mark - fetchedResultsController
//- (NSFetchedResultsController *)fetchedResultsController
//{
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    // Edit the entity name as appropriate.
//    
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    // Set the batch size to a suitable number.
//    [fetchRequest setFetchBatchSize:1];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    
//    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"name == %@",_strFrom_toTitle];
//    [fetchRequest setPredicate:predicate];
//    
//    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
//                                                            initWithFetchRequest:fetchRequest
//                                                            managedObjectContext:kAppDelegate.managedObjectContext
//                                                            sectionNameKeyPath:nil
//                                                            cacheName:nil];
//    fetchedResultsController.delegate = self;
//    self.fetchedResultsController = fetchedResultsController;
//    
//    NSError *error = nil;
//    if (![_fetchedResultsController performFetch:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    return _fetchedResultsController;
//}

-(IBAction)btnActionDirectionTo_From_ShowCustomer_AddToContact:(UIButton *)sender
{
    if (sender.tag<2) {
        if([delegate respondsToSelector:@selector(selectCustomerWithOption:Option:)])
            [delegate selectCustomerWithOption:_customerInfo Option:sender.tag];
    }
    if (sender.tag==3)
    {
        if (_strFrom_toTitle.length>0) {
            
//            NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
            NSManagedObject *customerDetail =  _customerInfo; //[fetchedData objectAtIndex:0];
            
            NSString *name=[customerDetail valueForKey:@"name"];
            NSString *address1 = [customerDetail valueForKey:@"addr1"];
            NSString *address2 = [customerDetail valueForKey:@"addr2"];
            NSString *cityName = [customerDetail valueForKey:@"addr3"];
            NSString *stateName = [customerDetail valueForKey:@"area"];
            NSString *postal = [customerDetail valueForKey:@"postcode"];
            NSString *emailString = [customerDetail valueForKey:@"emailaddress"];
            NSString *phoneNumber = [customerDetail valueForKey:@"phone"];
            
            
            ABAddressBookRef libroDirec = ABAddressBookCreate();
            
            ABRecordRef persona = ABPersonCreate();
            
            ABRecordSetValue(persona, kABPersonFirstNameProperty, (__bridge CFTypeRef)(name), nil);
            
            ABMutableMultiValueRef multiHome = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            
            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
            
            NSString *homeStreetAddress=[address1 stringByAppendingString:address2];
            
            [addressDictionary setObject:homeStreetAddress forKey:(NSString *) kABPersonAddressStreetKey];
            
            [addressDictionary setObject:cityName forKey:(NSString *)kABPersonAddressCityKey];
            
            [addressDictionary setObject:stateName forKey:(NSString *)kABPersonAddressStateKey];
            
            [addressDictionary setObject:postal forKey:(NSString *)kABPersonAddressZIPKey];
            
            bool didAddHome = ABMultiValueAddValueAndLabel(multiHome, (__bridge CFTypeRef)(addressDictionary), kABHomeLabel, NULL);
            
            if(didAddHome)
            {
                ABRecordSetValue(persona, kABPersonAddressProperty, multiHome, NULL);
                
                DebugLog(@"Address saved.....");
            }
            CFRelease(multiHome);
            
            //##############################################################################
            
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            
            bool didAddPhone = ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(phoneNumber), kABPersonPhoneMobileLabel, NULL);
            
            if(didAddPhone){
                
                ABRecordSetValue(persona, kABPersonPhoneProperty, multiPhone,nil);
                
                DebugLog(@"Phone Number saved......");
                
            }
            
            CFRelease(multiPhone);
            
            //##############################################################################
            
            ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
            
            bool didAddEmail = ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFTypeRef)(emailString), kABOtherLabel, NULL);
            
            if(didAddEmail){
                
                ABRecordSetValue(persona, kABPersonEmailProperty, emailMultiValue, nil);
                
                DebugLog(@"Email saved......");
            }
            
            CFRelease(emailMultiValue);
            
            //##############################################################################
            
            ABAddressBookAddRecord(libroDirec, persona, nil);
            
            CFRelease(persona);
            
            ABAddressBookSave(libroDirec, nil);
            
            CFRelease(libroDirec);
            
            NSString * errorString = [NSString stringWithFormat:@"Information are saved into Contact"];
            
            UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"New Contact Info" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [errorAlert show];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)isABAddressBookCreateWithOptionsAvailable
{
    return &ABAddressBookCreateWithOptions != NULL;
}
- (IBAction)doCreateTransaction:(UIBarButtonItem *)sender {
    if([self.transdelegate respondsToSelector:@selector(createTransactionWithCustomerInfo:)]){
        [self.transdelegate createTransactionWithCustomerInfo:_customerInfo];
    }
}
-(void)zoomImage:(UIGestureRecognizer *)gestureRecognizer
{
    [self performSegueWithIdentifier:@"toStreetImageViewController" sender:self];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"toStreetImageViewController"]) {
        StreetImageViewController *streetImageViewController = segue.destinationViewController;
        streetImageViewController.strImagePath=strFullImagePath;
    streetImageViewController.title=@"Full Street Image";
    }


}


@end
