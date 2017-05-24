//
//  CustomerController.m
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Modified by Satish on 06/10/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerController.h"
#import "CustomerFilterViewController.h"
#import "OrderHelper.h"
#import "CustomerDeliveryAddressViewController.h"
#import "ProductController.h"
#import "TransactionController.h"
#import "CopyTransactionController.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomerMapViewController.h"
#import "AddNewCustomerViewController.h"

#pragma mark - NSString extented
@implementation NSString (FetchedGroupByString)
- (NSString *)stringGroupByFirstInitial {
    if (!self.length || self.length == 1)
        return self;

    NSScanner *scanner = [NSScanner scannerWithString:[self substringToIndex:1]];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    if(isNumeric)
        return @"#";

    return [self substringToIndex:1];
}
@end


@interface CustomerController ()<CLLocationManagerDelegate,CustomerFilterViewControllerDelegate,CustomerDeliveryAddressViewControllerDelegate>
{
    NSDictionary *customers;
    NSString *selectedSegmentTitle;
    NSInteger selectedFilterOption;
    NSDate *selectedFilterDate;
    NSString *searchedTextString;
    NSArray *arrSelectedHistory;
    NSString *sortByFieldName;
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary *featureDict;

    CGFloat distance;
    NSDateFormatter *dateFormat;
    NSDateFormatter *timeFormat;

    BOOL isScrollBeginDragging;
    NSString *pageTitle;
    BOOL customerEdit;
    NSIndexPath *editIndexpath;
    NSManagedObject *objNew;
}

@property (weak, nonatomic) IBOutlet UITextView *acc_ref_countMessage;
@property(nonatomic,weak)IBOutlet UISearchBar *customerSearchBar;
@property(nonatomic,weak)IBOutlet UITableView *customerTableView;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIButton *brnAddCustomer;

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (strong,nonatomic) CLLocation *deviceLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnOverlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonFilters;
- (IBAction)dismissKeyboard:(id)sender;

@end

@implementation CustomerController

- (void)viewDidLoad {
    [super viewDidLoad];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;

    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    

    //brnAddCustomer
    _brnAddCustomer.layer.cornerRadius = _brnAddCustomer.frame.size.width/2;
    _brnAddCustomer.layer.masksToBounds = YES;

    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy"];
    
    timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
 //   [_customerSearchBar setReturnKeyType:UIReturnKeyDone];

    _segmentedControl = [[UISegmentedControl alloc] initWithItems:   [NSArray arrayWithObjects:@"ABC",@"123",   nil]];
    [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.frame = CGRectMake(0, 0, 90, 35);

//    UIBarButtonItem *addNewCustomerBarItem= [self.navigationItem.leftBarButtonItems firstObject];//
    UIBarButtonItem *segmentCustomerSortBarItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];

    if(_isFromProductScreen || self.delegate){
        self.title = NSLocalizedString(@"Select Customer", @"Select Customer");
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.rightBarButtonItems =  nil;//[NSArray arrayWithObjects:addNewCustomerBarItem, nil];
        self.navigationItem.leftBarButtonItems = nil;
//        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addNewCustomerBarItem, nil];
//        NSMutableArray *arrRightBtns = [self.navigationItem.rightBarButtonItems mutableCopy];
//        [arrRightBtns removeObjectAtIndex:1];
//
//        UIBarButtonItem *btnTransaction = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_to_cart.png"] style:UIBarButtonItemStyleDone target:self action:@selector(doCreateTransaction:)];
//        [arrRightBtns insertObject:btnTransaction atIndex:0];
//        self.navigationItem.rightBarButtonItems = arrRightBtns;
    }
    else
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:segmentCustomerSortBarItem, nil];

    [_acc_ref_countMessage.layer setMasksToBounds:YES];
    _acc_ref_countMessage.layer.cornerRadius = 8;

    pageTitle = self.title;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [_customerTableView.tableHeaderView addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap];
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshCompanydata:) name:kCompanySwitch object:nil];
    
    
}
-(void)dismissKeyboard:(UIGestureRecognizer*)tapGestureRecognizer
{
        [self.view endEditing:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationItem.title = pageTitle;

    [_locationManager startUpdatingLocation];
    [self filterCustomers];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //  Selected customer cell selected and move to top if there is a transaction
    if(kAppDelegate.customerInfo || _selectedCustomerInfo){
        NSManagedObject *cusinfo = kAppDelegate.customerInfo;
        if(_selectedCustomerInfo)
            cusinfo = _selectedCustomerInfo;

        NSArray *filteredArray =  [[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address==%@",[cusinfo valueForKey:@"acc_ref"],[cusinfo valueForKey:@"delivery_address"]]];
        if([filteredArray count]==0){
            filteredArray =  [[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"acc_ref==%@",[cusinfo valueForKey:@"acc_ref"]]];
        }
        if([filteredArray count]>0){
            NSIndexPath* selIndexPath = [_fetchedResultsController indexPathForObject:[filteredArray lastObject]];
            if(selIndexPath)
                [self.customerTableView selectRowAtIndexPath:selIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }

    NSIndexPath *indexPath=[self.fetchedResultsController indexPathForObject:objNew];
    if (indexPath!=nil)    
    [self.customerTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
}

#pragma mark - Custom Methods
-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig **SORT DESCRIPTER sortcustomersby
    NSString *sortCode=@"A";
    
   if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortcustomersby"] isEqual:[NSNull null]])
    sortCode = [[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortcustomersby"];
   
    if ([sortCode length]>0 && [sortCode isEqualToString:@"A"]){
        sortByFieldName =@"name";
        _segmentedControl.selectedSegmentIndex=0;
        [self segmentAction:_segmentedControl];
    }else{
        sortByFieldName=@"acc_ref";
        _segmentedControl.selectedSegmentIndex=1;
        [self segmentAction:_segmentedControl];
    }
    //End

    // code added by Satish on 25-11-2015
    if(_isFromProductScreen || _delegate) {
        sortByFieldName =@"name";
        _segmentedControl.selectedSegmentIndex=0;
        [self segmentAction:_segmentedControl];
    }
    // end of code
}

-(void)segmentAction:(UISegmentedControl *)sender
{
    
    sortByFieldName =@"name";
    if (_segmentedControl.selectedSegmentIndex==1)
        sortByFieldName=@"acc_ref";
    
    _fetchedResultsController=nil;
    [self fetchedResultsController];
    [self filterCustomers];
}

-(void)doCreateTransaction:(id)sender{
   
    if(![_customerTableView indexPathForSelectedRow]){
        [kAppDelegate showCustomAlertWithModule:nil Message:@"Please select customer."];
        return;
    }

    NSManagedObject *cusInfo = [self.fetchedResultsController objectAtIndexPath:[_customerTableView indexPathForSelectedRow]];
    if([[cusInfo valueForKey:@"stopflag"] boolValue] || [[[cusInfo valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]){
        [kAppDelegate showCustomAlertWithModule:nil Message:@"Please select valid customer"];
        return;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@", [cusInfo valueForKey:@"acc_ref"]];

    // remove main account address to use as first delivery address
    if(!companyConfigDict || ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"usemainaccountasdeliveryaddresss"] boolValue]){
        predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@ && delivery_address!='000'", [cusInfo valueForKey:@"acc_ref"]];
    }

    [fetchRequest setPredicate:predicate];
    // end of the code

    BOOL isMultipleDelAddsAvailable = NO;

    NSManagedObject *selCustInfo = cusInfo;
    NSError *err=nil;
    NSArray *arrDelAdds = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    if(!err){
        // apply mainaccountasdelivery address eqation here
        if([arrDelAdds count]>1 || [arrDelAdds count]==0){
            isMultipleDelAddsAvailable = YES;
            [self performSegueWithIdentifier:@"showDeliverySegue" sender:sender];
        }
        else if([arrDelAdds count]==1 && ![[[arrDelAdds lastObject] valueForKey:@"delivery_address"] isEqualToString:@"000"])
            selCustInfo = [arrDelAdds lastObject];
    }

    if(!isMultipleDelAddsAvailable){

        // to get selected customer with delivery address for copy transaction
        if(_delegate){
            [self copyTransactionCustomer:selCustInfo];
        }
        // end of copy transaction
        else
            [self createTransactionWithCustomerInfo:selCustInfo];
    }
}

-(void)copyTransactionCustomer:(NSManagedObject *) cusinfo{
    if([_delegate respondsToSelector:@selector(finishedCustomerSelectionWithCustomerInfo:)]){
        [_delegate finishedCustomerSelectionWithCustomerInfo:cusinfo];
        CopyTransactionController *ctvc = nil;
        for(id vc in self.navigationController.viewControllers){
            if([vc isKindOfClass:[CopyTransactionController class]]){
                ctvc = vc;
                break;
            }
        }
        if(ctvc) [self.navigationController popToViewController:ctvc animated:NO];
    }
}

-(void)navigateToProductController{
    ProductController *pvc = nil;
    for(id vc in self.navigationController.viewControllers){
        if([vc isKindOfClass:[ProductController class]]){
            pvc = vc;
            pvc.transactionInfo = kAppDelegate.transactionInfo;
            pvc.customerInfo = kAppDelegate.customerInfo;
            break;
        }
    }

    UITabBarController *tabC = (UITabBarController *)[self.navigationController parentViewController];
    if(pvc)
        [self.navigationController popToViewController:pvc animated:NO];
    else{
        [self.navigationController popToRootViewControllerAnimated:NO];
        UINavigationController *prodNav = [tabC.viewControllers objectAtIndex:1];
        if([prodNav.visibleViewController isKindOfClass:[ProductController class]]){
            pvc= (ProductController *)prodNav.visibleViewController;
            pvc.transactionInfo = kAppDelegate.transactionInfo;
            pvc.customerInfo = kAppDelegate.customerInfo;
        }
        else{
            [prodNav popToRootViewControllerAnimated:NO];
        }

        [tabC setSelectedIndex:1];
    }

    UINavigationController *transNav = [tabC.viewControllers objectAtIndex:3];
    if(transNav){
        if(![transNav.visibleViewController isKindOfClass:[TransactionController class]])
            [transNav popToRootViewControllerAnimated:NO];
    }
}

- (IBAction)addNewCustomer:(UIButton *)sender {
    customerEdit=NO;
    [self performSegueWithIdentifier:@"toAddNewCustomerViewController" sender:self];
}

// code added by Satish on 29-10-2015
-(void)filterCustomers{
    NSPredicate *predicate = nil;
    NSMutableArray *compPredicateArray=[NSMutableArray array];
    [compPredicateArray addObject:[NSPredicate predicateWithFormat:@"delivery_address=='000'"]];

    if (!searchedTextString || [searchedTextString length] == 0) {
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS [cd] %@ || acc_ref CONTAINS [cd] %@ || addr1 CONTAINS [cd] %@ || addr2 CONTAINS [cd] %@ || addr3 CONTAINS [cd] %@ || addr4 CONTAINS [cd] %@ || contact CONTAINS [cd] %@)", searchedTextString,searchedTextString,searchedTextString,searchedTextString,searchedTextString,searchedTextString,searchedTextString];

        [compPredicateArray addObject:predicate];
    }

    switch (selectedFilterOption) {
        case 1: // to show Customers On Stop (stopflag=true)
            predicate = [NSPredicate predicateWithFormat:@"(stopflag==1 || stopflag BEGINSWITH [cd] 'y')"];
            [compPredicateArray addObject:predicate];
            break;
        case 2:{ // to show Customers Near Me
            CLLocation *targetLocation  = _deviceLocation;
            float minLat = targetLocation.coordinate.latitude - (searchDistance / 69);
            float maxLat = targetLocation.coordinate.latitude + (searchDistance / 69);
            float minLon = targetLocation.coordinate.longitude - searchDistance / fabs(cos(deg2rad(targetLocation.coordinate.latitude))*69);
            float maxLon = targetLocation.coordinate.longitude + searchDistance / fabs(cos(deg2rad(targetLocation.coordinate.latitude))*69);

            predicate = [NSPredicate predicateWithFormat:@"(latitude <= %f AND latitude >= %f AND longitude <= %f AND longitude >= %f)", maxLat, minLat, maxLon, minLon];
            [compPredicateArray addObject:predicate];
            break;
        }
        case 3:
        case 4:{// to show Customers Without History or Customers Without History Since:selected date
            if (selectedFilterOption==3)
                predicate = [NSPredicate predicateWithFormat:@"NOT acc_ref IN %@",arrSelectedHistory];
            else
                predicate = [NSPredicate predicateWithFormat:@"acc_ref IN %@",arrSelectedHistory];

            [compPredicateArray addObject:predicate];

        }
        default:// to Show All Customers
            break;
    }

    if(compPredicateArray && [compPredicateArray count]>0){
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:compPredicateArray];
    }
    
    [[_fetchedResultsController fetchRequest] setPredicate:predicate];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [_customerTableView reloadData];
}
// end of code
#pragma mark - Add TransactionHead
- (int)addOrder_HeadWithOrderNumber:(NSString*)orderId CompanyId:(NSInteger)compid Long:(double)longitude Lat:(double)latitude StartDate:(NSDate *)dateValue Ordertype:(NSString *)ordtype CustomerInfo:(NSManagedObject* )custinfo{
    
    
    int returnVal=0;
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"OHEADNEW"   inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    NSString *discPerString =  @"";//[custinfo valueForKey:@"acc_ref"];
    
    // code below copied from iPad app
    //    if ([[CompanyConfigDelegate.CompInfo.CoName lowercaseString] hasPrefix:@"swift"]) {
    //        discper=UserConfigDelegate.CustInfo.Price_Group;
    //    }
    //    if ([[CompanyConfigDelegate.CompInfo.CoName lowercaseString] hasPrefix:@"ryder"]) {
    //        discper=UserConfigDelegate.CustInfo.Cust_Group;//[NSString stringWithFormat:@"%f",UserConfigDelegate.CustInfo.Set_Disc];
    //    }
    //
    //    //*******RE	ADD	Associate Customer Discount  17 JUN 2015
    //    if ([CompanyConfigDelegate.dicPacksInfo objectForKey:@"AssociateCustomerDiscount"] !=nil) {
    //        discper=[SQLHelper getValueWithQuery:[NSString stringWithFormat:@"Select DISTINCT(%@) FROM T_Cust WHERE ACC_REF='%@' And ifnull(%@,'')",[CompanyConfigDelegate.dicPacksInfo objectForKey:@"AssociateCustomerDiscount"],UserConfigDelegate.CustInfo.Customer_Code,[CompanyConfigDelegate.dicPacksInfo objectForKey:@"AssociateCustomerDiscount"]] Database:CompanyConfigDelegate.database] ;
    //    }//ENDED
    
    // [object setValue:[NSNumber numberWithInteger:batchNo] forKey:@"batch_no"];
    
    [object setValue:[NSNumber numberWithInteger:2] forKey:@"ordsource"];
    [object setValue:ordtype forKey:@"ordtype"];
    [object setValue:[NSNumber numberWithInteger:compid] forKey:@"company"];
    [object setValue:[custinfo valueForKey:@"name"] forKey:@"custname"];
    [object setValue:[custinfo valueForKey:@"curr"] forKey:@"curr"];
    [object setValue:[NSNumber numberWithFloat:[[custinfo valueForKey:@"setdis"] floatValue]] forKey:@"custdisc"];
    [object setValue:[custinfo valueForKey:@"acc_ref"] forKey:@"customerid"];
    [object setValue:[custinfo valueForKey:@"delivery_address"] forKey:@"deliveryaddressid"];
    [object setValue:discPerString forKey:@"discper"];
    [object setValue:[custinfo valueForKey:@"emailaddress"] forKey:@"emailaddress"];
    
    [object setValue:@"N" forKey:@"emailconfirm"];
    [object setValue:@"N" forKey:@"emailrep"];
    [object setValue:@"N" forKey:@"Creditemail"];
    [object setValue:kAppDelegate.repId forKey:@"employeeid"];
    [object setValue:@"N" forKey:@"held_status"];
    
    [object setValue:[custinfo valueForKey:@"isnew"] && ([[[custinfo valueForKey:@"isnew"] lowercaseString] hasPrefix:@"y"] || [[custinfo valueForKey:@"isnew"] isEqualToString:@"1"])?@"Y":@"N"
              forKey:@"hold_newcust"];
    [object setValue:[[ordtype uppercaseString] isEqualToString:@"P"]?@"Y":@"N"
              forKey:@"hold_proforma"];

    [object setValue:[NSNumber numberWithDouble:latitude]  forKey:@"latitude"];
    [object setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [object setValue:@"Unsent" forKey:@"order_status"];//Default Transaction unsent
    [object setValue:dateValue forKey:@"orderdate"];
    [object setValue:orderId forKey:@"orderid"];
  //  [object setValue:kAppDelegate.repId forKey:@"orderrep"];
    [object setValue:dateValue forKey:@"ordtime"];
    
    [object setValue:@"0" forKey:@"payment"];
//    [object setValue:[dateFormat stringFromDate:strtDate] forKey:@"payment_date"];
    [object setValue:@"N" forKey:@"printed"];
    [object setValue:@"N" forKey:@"processed"];
    
    [object setValue:[NSNumber numberWithInteger:1] forKey:@"quotelayoutid"];
    [object setValue:@"0" forKey:@"scannerid"];
    //[object setValue:kAppDelegate.identifierForAdvertising forKey:@"scannerid"];
    
    [object setValue:dateValue forKey:@"required_bydate"];
    [object setValue:dateValue forKey:@"start_date"];
    [object setValue:dateValue forKey:@"start_time"];
    
    [object setValue:[NSNumber numberWithBool:YES] forKey:@"isopen"];
    [object setValue:custinfo forKey:@"customer"];//Add customer Obj
    
    NSError *error;
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }else
        returnVal=YES;
    
    return returnVal;
}

-(void) fadeInAndOut
{
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    _acc_ref_countMessage.hidden=NO;
    _acc_ref_countMessage.text=[NSString stringWithFormat:@"Total: %lu",(unsigned long)fetchedData.count];
    // Fade out the view right away
    [UIView animateWithDuration:0.0

                          delay: 0.0

                        options: UIViewAnimationOptionCurveEaseOut

                     animations:^{

                         _acc_ref_countMessage.alpha = 0.85;

                     }

                     completion:^(BOOL finished){

                         // Wait one second and then fade in the view

                         [UIView animateWithDuration:1.0

                                               delay: 1.0

                                             options:UIViewAnimationOptionCurveEaseIn

                                          animations:^{

                                              _acc_ref_countMessage.alpha = 0.0;

                                          }

                                          completion:nil];

                     }];
}

#pragma mark - CustomerDeliveryAddressViewController Delegate
-(void)createTransactionWithCustomerInfo:(NSManagedObject *)custinfo{

    // to get selected customer with delivery address for copy transaction
    if(_delegate){
        [self copyTransactionCustomer:custinfo];
        return;
    }
    // end of copy transaction

    if(kAppDelegate.customerInfo || !custinfo){
        if(!custinfo){
            [kAppDelegate showCustomAlertWithModule:nil Message:@"Please select valid customer"];
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [OrderHelper getNewOrderNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId IsCopying:NO CompletionBlock:^(NSString * _Nullable newordernumber) {

        CGFloat longitude = 0;
        CGFloat latitude = 0;

        if(_deviceLocation){
            longitude = _deviceLocation.coordinate.longitude;
            latitude = _deviceLocation.coordinate.latitude;
        }

        NSString *strdefordertype = @"C";//Default order type Call logs

//        NSDictionary *pricingConfigDict = nil;
//        NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
//        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]]){
//            pricingConfigDict = [dic objectForKey:@"data"];
//
//            if(pricingConfigDict){
//                NSArray *arrtranstypes = [[pricingConfigDict objectForKey:@"orderconfigs"] objectForKey:@"transactiontypes"];
//                NSArray *arrdeftranstypes = [arrtranstypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]];
//
//                if(arrdeftranstypes && [arrdeftranstypes count]>0)
//                    strdefordertype = [[arrdeftranstypes firstObject] objectForKey:@"code"];
//                else if ([arrtranstypes count]>0){
//                    strdefordertype = [[arrtranstypes firstObject] objectForKey:@"code"];
//                }
//            }
//        }

        NSString *strordtype = strdefordertype;
//        if((!featureDict || ![[featureDict objectForKey:@"calllogsenabled"] boolValue]) && [[strordtype uppercaseString] isEqualToString:@"C"])
//            strordtype = @"";
//        else
//            strordtype = @"O";

        //Transaction create with current date
        int insrt=  [self addOrder_HeadWithOrderNumber:newordernumber CompanyId:kAppDelegate.selectedCompanyId Long:longitude Lat:latitude StartDate:[NSDate date] Ordertype:strordtype CustomerInfo:custinfo];

        if(insrt){
            [kAppDelegate loadCustomerInfo];//performSelector:@selector(loadCustomerInfo) withObject:nil afterDelay:0.1];

            //remove old selection when add new transaction
            [kUserDefaults  removeObjectForKey:@"SelPriceRow"];
            [kUserDefaults  synchronize];
            // Enable transaction tab
            [kNSNotificationCenter postNotificationName:kRefreshTabItems object:nil];
        }

        [self performSelector:@selector(navigateToProductController) withObject:nil afterDelay:0.0];
    }];
}

#pragma mark search bar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [_btnOverlay setHidden:NO];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_btnOverlay setHidden:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]<=0) {
        [_btnOverlay setHidden:NO];
    }else
        [_btnOverlay setHidden:YES];

    
    searchedTextString = searchText;

    // code modified by Satish on 29-10-2015
    [self filterCustomers];
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortByFieldName ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"delivery_address=='000'"]];

    // end of the code

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:kAppDelegate.managedObjectContext
                                                    sectionNameKeyPath:[NSString stringWithFormat:@"%@.stringGroupByFirstInitial",sortByFieldName]
                                                            cacheName:nil];
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;

    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}
#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_customerTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_customerTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    objNew=anObject;
    UITableView *tableView = self.customerTableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.customerTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.customerTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    if(_isFromProductScreen)
//        cell.accessoryType = UITableViewCellAccessoryDetailButton;
//    else
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.hidden = NO;    // Configure the cell...
   
    NSManagedObject *customerDetail = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (_segmentedControl.selectedSegmentIndex==0)
        cell.textLabel.text=[NSString stringWithFormat:@"%@ - %@",[customerDetail valueForKey:@"name"],[customerDetail valueForKey:@"acc_ref"]];
    else
        cell.textLabel.text=[NSString stringWithFormat:@"%@ - %@",[customerDetail valueForKey:@"acc_ref"],[customerDetail valueForKey:@"name"]];

    if([[customerDetail valueForKey:@"stopflag"] boolValue] || [[[customerDetail valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]){
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    else{
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{

    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(_isFromProductScreen) return;

    if(_delegate){// to get selected customer with delivery address for copy transaction
        [self doCreateTransaction:nil];
    }
    else
       [self performSegueWithIdentifier:@"toCustomerDetailMultipleVC" sender:self];


}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
//    if(!_isFromProductScreen) return;

    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    [self performSegueWithIdentifier:@"toCustomerDetailMultipleVC" sender:self];
}


//Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     NSManagedObject *customerInfo=[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([[customerInfo valueForKey:@"isaddedondevice"]boolValue] && [[customerInfo valueForKey:@"batch_no"] integerValue]==0 && [self check_olines:customerInfo]){//update Customer info if this is a new delivery add in this ipad and not associated with any order
        return YES;
    }else
        return NO;
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSManagedObject *customerInfo=[self.fetchedResultsController objectAtIndexPath:indexPath];
//    if ([[customerInfo valueForKey:@"isnew"]boolValue]) {
        editIndexpath=indexPath;
        UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self tableCellEditClicked];
        }];
        button.backgroundColor = [UIColor blackColor];
        
        //If need delete button
        /*UITableViewRowAction *button1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         [self tableCellEditClicked];
         }];
         button1.backgroundColor = [UIColor redColor];
         return  @[button1,button];*/
        
        return @[button];  //array with all the buttons you want. 1,2,3, etc...
        
 
//    }else
//        return nil;
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableCellEditClicked{
    
    DebugLog(@"Edit click");
    customerEdit=YES;
    [self performSegueWithIdentifier:@"toAddNewCustomerViewController" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.navigationItem.title = @"";
    
    if ([[segue identifier] isEqualToString:@"toCustomerDetailMultipleVC"]) {
        NSIndexPath *indexPath = [_customerTableView indexPathForSelectedRow];
        
        NSManagedObject *managedObject=[self.fetchedResultsController objectAtIndexPath:indexPath];
//        NSManagedObject *managedObject=[self.fetchedResultsController objectAtIndexPath:indexPath];
//         NSSet *custIheads = [NSSet setWithArray:[self findInvoicesData:[self.fetchedResultsController objectAtIndexPath:indexPath]]];
//        NSSet *custOheads = [NSSet setWithArray:[self findOutstandingData:[self.fetchedResultsController objectAtIndexPath:indexPath]]];
//        [managedObject setValue:custIheads forKey:@"iheads"];
//        [managedObject setValue:custOheads forKey:@"oheads"];
        
        CustomerDetailMultipleViewController *customerDetailMultipleViewController = segue.destinationViewController;
        customerDetailMultipleViewController.transactionInfo=kAppDelegate.transactionInfo;
        [customerDetailMultipleViewController setCustomerInfo:managedObject];
        customerDetailMultipleViewController.transdelegate = self;
   
    } else if([segue.identifier isEqualToString:@"toCustomerFilterView"]){
        CustomerFilterViewController *cfvc = segue.destinationViewController;
        cfvc.delegate = self;
        cfvc.selectedOption=selectedFilterOption;
        cfvc.selectedDate = selectedFilterDate;
    } else if([segue.identifier isEqualToString:@"showDeliverySegue"]){
        CustomerDeliveryAddressViewController *cdvc = segue.destinationViewController;
        cdvc.transdelegate = self;
        cdvc.isFromCustomer=NO;
        [cdvc setCustomerInfo:[self.fetchedResultsController objectAtIndexPath:[_customerTableView indexPathForSelectedRow]]];
    } else if([segue.identifier isEqualToString:@"toMapViewController"]){
        CustomerMapViewController *cdvc = segue.destinationViewController;
        [cdvc setDeviceLocation:_deviceLocation];
    }else if([segue.identifier isEqualToString:@"toAddNewCustomerViewController"] && customerEdit){
        NSManagedObject *managedObject=[self.fetchedResultsController objectAtIndexPath:editIndexpath];
        AddNewCustomerViewController *obj = segue.destinationViewController;
        [obj setEditStatus:YES];
        [obj setCustomerInfo:managedObject];
    }

    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - CustomerFilterViewController Delegate
-(void)finishedFilterSelectionWithOption:(NSInteger)seloption SelectedDate:(NSDate *)seldate ArrHistory:(NSArray *)arrHistory{
    selectedFilterOption = seloption; // 0 - All Customers, 1 - Customers On Stop, 2 - Customers Near Me, 3 - Customers Without History, 4 - Customers Without History Since:
    selectedFilterDate = seldate;
    arrSelectedHistory=arrHistory;
   
    
    //Check for filter Status
    [_barButtonFilters setImage:[UIImage imageNamed:@"filter"]];//setTintColor: btnTitleBlueColor];
    BOOL filterSelSts=NO;
    //Checking in Array
    
    if (seloption > 0 || [arrHistory count]>0 )
        filterSelSts=YES;
    
    if (filterSelSts)
    {
        [_barButtonFilters setImage:[UIImage imageNamed:@"filterSelected"]];//setTintColor: [UIColor greenColor]];
    }
    //Ended
    
    
    
    [self filterCustomers];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    isScrollBeginDragging = YES;
    [self dismissKeyboard:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!isScrollBeginDragging) return;

    if(scrollView.contentSize.height<=_customerTableView.frame.size.height) return;

    if(scrollView.contentOffset.y<=distance){
        if(self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else{
        if(!self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:YES animated:YES];
    }

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    distance = scrollView.contentOffset.y;
    [self fadeInAndOut];
    if(distance<0) distance = 0;
    isScrollBeginDragging = NO;
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status==kCLAuthorizationStatusAuthorizedWhenInUse){

    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    DebugLog(@"%@",locations);
    if(!_deviceLocation || ![_deviceLocation isEqual:[locations lastObject]]){
        _deviceLocation = [locations lastObject];
    }

    [_locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    
}

/*- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
    [_btnOverlay setHidden:YES];
}*/

-(BOOL)check_olines:(NSManagedObject*)customer{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerid==%@ && deliveryaddressid==%@",[customer valueForKey:@"acc_ref"],[customer valueForKey:@"delivery_address"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([resultsSeq count]==0) {
        return YES;
    }else
        return NO;
    
}

//Featch invoice/outstanding data

-(NSArray*)findInvoicesData :(NSManagedObject*)customer{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"invoiced_date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsiHead = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
   
    NSMutableArray *iHeadArr=[[NSMutableArray alloc]init];
    
    [resultsiHead enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *objectnew=obj;
        NSSet *custILines = [NSSet setWithArray:[self findiLines:obj]];
        [objectnew setValue:custILines forKey:@"invoicelines"];
        [iHeadArr addObject:objectnew];
    }];
    
    return iHeadArr;
}


-(NSArray*)findiLines:(NSManagedObject*)iheadObj{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"ILINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"invoice_num==%@",[iheadObj valueForKey:@"invoice_num"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsiLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
   
    NSMutableArray *iLineArr=[[NSMutableArray alloc]init];
    [resultsiLine enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *objectnew=obj;
        [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
        [iLineArr addObject:objectnew];
    }];
    
    return iLineArr;
}




//Find Outstanding data

-(NSArray*)findOutstandingData:(NSManagedObject*)customer{
    
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsOHead = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *OHeadArr=[[NSMutableArray alloc]init];
    [resultsOHead enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *objectnew=obj;
        NSSet *custILines = [NSSet setWithArray:[self findOLines:obj]];
        [objectnew setValue:custILines forKey:@"orderlines"];
        [OHeadArr addObject:objectnew];
    }];
    
    return OHeadArr;
}

-(NSArray*)findOLines:(NSManagedObject*)OheadObj{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_number==%@",[OheadObj valueForKey:@"order_number"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsOLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *OLineArr=[[NSMutableArray alloc]init];
    [resultsOLine enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *objectnew=obj;
        [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
        [OLineArr addObject:objectnew];
    }];
    return OLineArr;
}


-(NSManagedObject*)findproduct:(NSString*)stockCode{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stock_code==%@",stockCode];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return [resultsSeq lastObject];
}




//When companySwitch Notification Called
- (void) refreshCompanydata:(NSNotification *) notification{

    [_customerSearchBar setText:@""];
}

@end
