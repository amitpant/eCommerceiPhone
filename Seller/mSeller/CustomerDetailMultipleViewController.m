//
//  CustomerDetailMultipleViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/29/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerDetailMultipleViewController.h"
#import "CustomerDeliveryAddressViewController.h"
#import "CustomerController.h"
#import "BaseContentViewController.h"
#import "CustomerMapViewController.h"
#import "commonMethods.h"



@interface CustomerDetailMultipleViewController ()<BaseContentViewControllerDelegate>{
    NSDictionary* featureDict;
    NSDictionary* companyConfigDict;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCreateTransaction;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentControl;
@property(nonatomic,weak)IBOutlet UIView *mainSwitchingDataView;
@property (weak, nonatomic) IBOutlet UILabel *lblAccRef_CustomerName;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *contentPageRestorationIDs;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lblDataLoading;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation CustomerDetailMultipleViewController
@synthesize segmentControl;


#pragma mark - Setters and Getters
- (NSArray *)contentPageRestorationIDs{
    
    if (!_contentPageRestorationIDs) {
        _contentPageRestorationIDs = @[@"CustomerInfo",@"CustomerTask",@"CustomerDebt", @"CustomerInvoicesViewController",@"CustomerOutstandingViewController",@"CustomerDeliveryAddress"];
    }
    return _contentPageRestorationIDs;
}

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


    [segmentControl setEnabled:NO forSegmentAtIndex:1];
    if (featureDict !=nil && [[featureDict valueForKey:@"customertasksenabled"] boolValue]) {
        [segmentControl setEnabled:YES forSegmentAtIndex:1];
    }

    
}

-(void)load_CustomerData{
    /*dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        @try {
            // Background work
            _btnCreateTransaction.enabled=NO;
            [_activityIndicator startAnimating];
            
            NSSet *custIheads = [NSSet setWithArray:[commonMethods findInvoicesData:_customerInfo]];
            NSSet *custOheads = [NSSet setWithArray:[commonMethods findOutstandingData:_customerInfo]];
            [_customerInfo setValue:custIheads forKey:@"iheads"];
            [_customerInfo setValue:custOheads forKey:@"oheads"];
            
        } @catch (NSException *exception) {
            DebugLog(@"%@",exception);
        } @finally {
            
        }

        
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            // Main thread work (UI usually)
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            [_lblDataLoading setHidden:YES];
            
            
            
        });
    });*/
    
    _operationQueue= [[NSOperationQueue alloc] init];
    
    [_operationQueue addOperationWithBlock:^{
        // do some time consuming stuff in the background
        @try {
            // Background work
           // _btnCreateTransaction.enabled=NO;
            [_activityIndicator startAnimating];
            
            NSSet *custIheads = [NSSet setWithArray:[commonMethods findInvoicesData:_customerInfo]];
            NSSet *custOheads = [NSSet setWithArray:[commonMethods findOutstandingData:_customerInfo]];
            [_customerInfo setValue:custIheads forKey:@"iheads"];
            [_customerInfo setValue:custOheads forKey:@"oheads"];
            
        } @catch (NSException *exception) {
            DebugLog(@"%@",exception);
        } @finally {
            
        }
        
        
        
        // when done, you might update the UI in the main queue
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // update the UI here
            
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            [_lblDataLoading setHidden:YES];
            
            
            
            
            
            
        }];
    }];
}


-(void)load_otherView:(NSNotification *) notification{
    NSDictionary *notiDic=notification.userInfo;
    if ([[notiDic valueForKey:@"SelectedIndex"] integerValue]!=2) {
        [_operationQueue cancelAllOperations];
        [_activityIndicator stopAnimating];
        [_activityIndicator setHidden:YES];
        [_lblDataLoading setHidden:YES];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
    [kNSNotificationCenter removeObserver:self name:kLoadOtherTabController object:nil];
    //For reload  product data when header discount added
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    [kNSNotificationCenter addObserver:self selector:@selector(load_otherView:) name:kLoadOtherTabController object:nil];
    
    [_activityIndicator startAnimating];
    
  //  [self load_CustomerData];
   /* NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [myQueue addOperationWithBlock:^{
        
        
        @try {
            // Background work
            _btnCreateTransaction.enabled=NO;
            [_activityIndicator startAnimating];

            NSSet *custIheads = [NSSet setWithArray:[self findInvoicesData:_customerInfo]];
            NSSet *custOheads = [NSSet setWithArray:[self findOutstandingData:_customerInfo]];
            [_customerInfo setValue:custIheads forKey:@"iheads"];
            [_customerInfo setValue:custOheads forKey:@"oheads"];
       
        } @catch (NSException *exception) {
                DebugLog(@"%@",exception);
        } @finally {
            
        }

        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Main thread work (UI usually)
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            [_lblDataLoading setHidden:YES];
           /*/
            
            self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonPageViewController"];
            self.pageViewController.dataSource = self;
            self.pageViewController.delegate=self;
            
            
            UIViewController *startingViewController = [self viewControllerAtIndex:0];
            [self.pageViewController setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self addChildViewController:self.pageViewController];
            
            self.pageViewController.view.frame = CGRectMake(0, 0, self.mainSwitchingDataView.frame.size.width, self.mainSwitchingDataView.frame.size.height);
            [self.mainSwitchingDataView addSubview:self.pageViewController.view];
            [self.pageViewController didMoveToParentViewController:self];
            
            
            _lblAccRef_CustomerName.text=[NSString stringWithFormat:@"%@ - %@",[_customerInfo valueForKey:@"acc_ref"],[_customerInfo valueForKey:@"name"]];
            
            
            BOOL IsenableTransaction=YES;
            /*if(companyConfigDict && [[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"IsCustomeronStopDisabled"] boolValue]){
                IsenableTransaction = !([[_customerInfo valueForKey:@"stopflag"] boolValue] || [[[_customerInfo valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]) || kAppDelegate.customerInfo!=nil;
            }*/
            
            //BOOL disableTransaction = ([[_customerInfo valueForKey:@"stopflag"] boolValue] || [[[_customerInfo valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]) || kAppDelegate.customerInfo!=nil;
           // _btnCreateTransaction.enabled = !disableTransaction;// !isStopFlagTrue && kAppDelegate.customerInfo!=nil;
            
             _btnCreateTransaction.enabled=IsenableTransaction;
            
//        }];
//    }];
//    
    
    
    
    
    
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        [_activityIndicator startAnimating];
        NSSet *custIheads = [NSSet setWithArray:[self findInvoicesData:_customerInfo]];
        NSSet *custOheads = [NSSet setWithArray:[self findOutstandingData:_customerInfo]];
        [_customerInfo setValue:custIheads forKey:@"iheads"];
        [_customerInfo setValue:custOheads forKey:@"oheads"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            [_activityIndicator stopAnimating];
            [_activityIndicator setHidden:YES];
            [_lblDataLoading setHidden:YES];
            
            self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonPageViewController"];
            self.pageViewController.dataSource = self;
            self.pageViewController.delegate=self;
            
            
            UIViewController *startingViewController = [self viewControllerAtIndex:0];
            [self.pageViewController setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self addChildViewController:self.pageViewController];
            
            self.pageViewController.view.frame = CGRectMake(0, 0, self.mainSwitchingDataView.frame.size.width, self.mainSwitchingDataView.frame.size.height);
            [self.mainSwitchingDataView addSubview:self.pageViewController.view];
            [self.pageViewController didMoveToParentViewController:self];
            
            
            _lblAccRef_CustomerName.text=[NSString stringWithFormat:@"%@ - %@",[_customerInfo valueForKey:@"acc_ref"],[_customerInfo valueForKey:@"name"]];
            
            BOOL disableTransaction = ([[_customerInfo valueForKey:@"stopflag"] boolValue] || [[[_customerInfo valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]) || kAppDelegate.customerInfo!=nil;
            _btnCreateTransaction.enabled = !disableTransaction;// !isStopFlagTrue && kAppDelegate.customerInfo!=nil;
        });
    });
    //NSManagedObject *managedObject=_customerInfo;
   */
    
    
}


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index{
    // Only process a valid index request.
    if (index >= self.contentPageRestorationIDs.count || ([self.contentPageRestorationIDs count] == 0)) {
        return nil;
    }
    
   
    // Create a new view controller.
    BaseContentViewController *contentViewController = (BaseContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:_contentPageRestorationIDs[index]];
    [contentViewController setDelegate:self];
    
//    UIViewController *currentView = contentViewController;

//    if ([currentView isKindOfClass:[CustomerInfoController class]]) {
//        
//        CustomerInfoController *customerInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerInfo"];
//        
////        [customerInfoController setCustomerInfo:_customerInfo];
//    }
//    else if([currentView isKindOfClass:[CustomerTaskViewController class]]){
//        // CustomerTaskViewController *customerTaskViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CustomerInfo"];
//    }
//    else if([currentView isKindOfClass:[CustomerDebtViewController class]]){
//        CustomerDebtViewController *customerDebtViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerDebt"];
//        [customerDebtViewController setCustomerInfo:_customerInfo];
//    }
//    else if ([currentView isKindOfClass:[CustomerInvoicesViewController class]]) {
//        
//        CustomerInvoicesViewController *customerInvoicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerInvoice"];
//        [customerInvoicesViewController setCustomerCode:[_customerInfo valueForKey:@"acc_ref"]];
//    }
//    else if([currentView isKindOfClass:[CustomerOutstandingViewController class]]){
//        CustomerOutstandingViewController *customerOutstandingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerOutstandingViewController"];
//        [customerOutstandingViewController setCustomerCode:[_customerInfo valueForKey:@"acc_ref"]];
//    }
//    else if([currentView isKindOfClass:[CustomerDeliveryAddressViewController class]]){
//        CustomerDeliveryAddressViewController *customerDeliveryAddressViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerDeliveryAddress"];
//        [customerDeliveryAddressViewController setCustomerCode:[_customerInfo valueForKey:@"acc_ref"]];
//    }
    contentViewController.customerInfo = _customerInfo;
    contentViewController.transactionInfo=self.transactionInfo;
//    contentViewController.rootviewcontroller = self;

    return contentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    //Manage pageviewController Swipe
        for (UIView *view in self.view.subviews ) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *)view;
                scroll.scrollEnabled = YES;
            }
        }
    

    
    NSString *vcRestorationID = viewController.restorationIdentifier;
    NSUInteger index = [self.contentPageRestorationIDs indexOfObject:vcRestorationID];
    
    if (index == 0) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSString *vcRestorationID = viewController.restorationIdentifier;
    NSUInteger index = [self.contentPageRestorationIDs indexOfObject:vcRestorationID];
    
    if (index == self.contentPageRestorationIDs.count - 1) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index + 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.contentPageRestorationIDs.count;
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    UIViewController *currentView = [pageViewController.viewControllers objectAtIndex:0];
    NSString *vcRestorationID = currentView.restorationIdentifier;
    NSUInteger index = [self.contentPageRestorationIDs indexOfObject:vcRestorationID];
    [segmentControl setSelectedSegmentIndex:index];
    
    /*  if (completed) {
     [self.pageViewController setViewControllers:[NSArray arrayWithObject:currentView]
     direction:UIPageViewControllerNavigationDirectionForward
     animated:NO
     completion:NULL];
     }*/
    if (completed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:currentView]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:NULL];
       
        });
    }
}

- (IBAction)segmentChanged:(id)sender {
    UIViewController *startingViewController = [self viewControllerAtIndex:self.segmentControl.selectedSegmentIndex];
    [self.pageViewController setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
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
    self.title=@"";
    if([segue.identifier isEqualToString:@"showDeliverySegue"]){
        CustomerController *cvc = nil;
        for(id vc in self.navigationController.viewControllers){
            if([vc isKindOfClass:[CustomerController class]]){
                cvc = vc;
                break;
            }
        }
        if(cvc){
            CustomerDeliveryAddressViewController *cdvc = segue.destinationViewController;
            cdvc.isFromCustomer=YES;//remove done button
            cdvc.transdelegate = cvc;
            [cdvc setCustomerInfo:_customerInfo];
        }
    }
    else if([segue.identifier isEqualToString:@"toMapViewController"]){
        CustomerMapViewController *cdvc = segue.destinationViewController;
        [cdvc setCustomerInfo:_customerInfo];
        cdvc.isFromCustDetail=YES;
    }

}

- (IBAction)doCreateTransaction:(UIBarButtonItem *)sender {
    
    
    if(companyConfigDict && [[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"IsCustomeronStopDisabled"] boolValue] && (([[_customerInfo valueForKey:@"stopflag"] boolValue] || [[[_customerInfo valueForKey:@"stopflag"] lowercaseString] hasPrefix:@"y"]) || kAppDelegate.customerInfo!=nil)){
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Warning:" message:@"Customer on Stop" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        return;

    }
    
    if(companyConfigDict && [[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"IsperformaAlertIsEabled"] boolValue] &&self.transactionInfo && [[[_customerInfo valueForKey:@"area"] lowercaseString] hasPrefix:@"pro-"]){
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Warning:" message:@"Account status is PROFORMA" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        
        [alert show];
        return;
    }
    
    
    
    if(self.segmentControl.selectedSegmentIndex==5){
        CustomerDeliveryAddressViewController *currentViewC = [self.pageViewController.viewControllers firstObject];
        currentViewC.isFromCustomer=NO;
        if(currentViewC.selectedCustomerDelivery){
            if([self.transdelegate respondsToSelector:@selector(createTransactionWithCustomerInfo:)]){
                [self.transdelegate createTransactionWithCustomerInfo:currentViewC.selectedCustomerDelivery];
            }
        }
        else{
            [kAppDelegate showCustomAlertWithModule:nil Message:@"Please select delivery address"];
        }
        return;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@", [_customerInfo valueForKey:@"acc_ref"]];

    // remove main account address to use as first delivery address
    if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"usemainaccountasdeliveryaddresss"] boolValue]){
        if([[self.customerInfo valueForKey:@"delivery_address"] isEqualToString:@"000"])
            predicate = [NSPredicate predicateWithFormat:@"acc_ref == %@ && delivery_address!='000'", [_customerInfo valueForKey:@"acc_ref"]];
    }
    [fetchRequest setPredicate:predicate];
    // end of the code

    NSManagedObject *selCustInfo = _customerInfo;
    BOOL isMultipleDelAddsAvailable = NO;
    NSError *err=nil;
    NSArray *arrDelAdds = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    if(!err){
        // apply mainaccountasdelivery address eqation here
        if([arrDelAdds count]>1 || [arrDelAdds count]==0){
            isMultipleDelAddsAvailable = YES;
            [self performSegueWithIdentifier:@"showDeliverySegue" sender:sender];
        }
        else if([arrDelAdds count]==1 && ![[[arrDelAdds lastObject] valueForKey:@"delivery_address"] isEqualToString:@"000"]){
                selCustInfo = [arrDelAdds lastObject];
        }
    }

    if(!isMultipleDelAddsAvailable){
        if([self.transdelegate respondsToSelector:@selector(createTransactionWithCustomerInfo:)]){
            [self.transdelegate createTransactionWithCustomerInfo:selCustInfo];
        }
    }
}

//Called BaseContentViewControllerDelegate
-(void)loadSegment{
    self.segmentControl.selectedSegmentIndex=4;
    UIViewController *startingViewController = [self viewControllerAtIndex:4];
    [self.pageViewController setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}



/*/Featch invoice/outstanding data

-(NSArray*)findInvoicesData :(NSManagedObject*)customer{
  
    NSMutableArray *iHeadArr=[[NSMutableArray alloc]init];
    @try {
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"invoiced_date" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsiHead = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        
        [resultsiHead enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *objectnew=obj;
            if ([self findiLines:obj]) {
                NSSet *custILines = [NSSet setWithArray:[self findiLines:obj]];
                [objectnew setValue:custILines forKey:@"invoicelines"];
                [iHeadArr addObject:objectnew];
            }
            
        }];

    } @catch (NSException *exception) {
        DebugLog(@"findInvoicesData Exception %@",exception);
    } @finally {
        
    }
    
    return iHeadArr;
}

-(NSArray*)findiLines:(NSManagedObject*)iheadObj{
    NSMutableArray *iLineArr=[[NSMutableArray alloc]init];
    @try {
        
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"ILINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"invoice_num==%@",[iheadObj valueForKey:@"invoice_num"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsiLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        
        [resultsiLine enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSManagedObject *objectnew=obj;
            DebugLog(@"product_code--  %@",[obj valueForKey:@"product_code"]);
            if ([self findproduct:[obj valueForKey:@"product_code"]]) {
                [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
                [iLineArr addObject:objectnew];
            }
            
        }];
        
    } @catch (NSException *exception) {
        DebugLog(@"findiLines Exception %@",exception);
    } @finally {
        
    }
    
    
    return iLineArr;
}


//Find Outstanding data

-(NSArray*)findOutstandingData:(NSManagedObject*)customer{
  
    NSMutableArray *OHeadArr=[[NSMutableArray alloc]init];
    @try {
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_date" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsOHead = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [resultsOHead enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *objectnew=obj;
           
            if ([self findOLines:obj]) {
                NSSet *custILines = [NSSet setWithArray:[self findOLines:obj]];
                [objectnew setValue:custILines forKey:@"orderlines"];
                [OHeadArr addObject:objectnew];
            }
            
        }];
 
    } @catch (NSException *exception) {
        DebugLog(@"findOutstandingData Exception %@",exception);
    } @finally {
        
    }
    
    return OHeadArr;
}

-(NSArray*)findOLines:(NSManagedObject*)OheadObj{
    NSMutableArray *OLineArr=[[NSMutableArray alloc]init];
    @try {
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order_number==%@",[OheadObj valueForKey:@"order_number"]];
        [fetchRequest setPredicate:predicate];
        
        
       /* NSExpression *fromCurrencyPathExpression = [NSExpression expressionForKeyPath:@"orderlines.price_ordered"];
        NSExpression *toCurrencyPathExpression   = [NSExpression  expressionForKeyPath:@"orderlines.outst_ord_qty"];
        NSExpression *multiplyExpression = [NSExpression expressionForFunction:@"multiply:by:" arguments:@[fromCurrencyPathExpression, toCurrencyPathExpression]];
        NSString *expressionName = @"salesVal";
        NSExpressionDescription *expressionDescription =[[NSExpressionDescription alloc] init];
        expressionDescription.name = expressionName;
        expressionDescription.expression = multiplyExpression;
        expressionDescription.expressionResultType= NSDoubleAttributeType;
        
        fetchRequest.propertiesToFetch = @[expressionDescription];*
        
        
        
        
        
        NSError *error = nil;
        NSArray *resultsOLine = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [resultsOLine enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *objectnew=obj;
            if ([self findproduct:[obj valueForKey:@"product_code"]]) {
                [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
                [OLineArr addObject:objectnew];
            }
        }];
    } @catch (NSException *exception) {
        DebugLog(@"findOLines NSException %@",exception);
    } @finally {
        
    }
   
    return OLineArr;
}


-(NSManagedObject*)findproduct:(NSString*)stockCode{
  
    @try {
       
        NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entitySquence];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stock_code==%@",stockCode];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        return [resultsSeq lastObject];
    
    } @catch (NSException *exception) {
        DebugLog(@"findproduct NSException %@",exception);
    } @finally {
        
    }
    
    return nil;//[[NSManagedObject alloc]init];
}
*/


@end
