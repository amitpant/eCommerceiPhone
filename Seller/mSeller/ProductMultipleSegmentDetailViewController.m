//
//  ProductMultipleSegmentDetailViewController.m
//  mSeller
//
//  Created by Ashish Pant on 10/16/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductMultipleSegmentDetailViewController.h"

@interface ProductMultipleSegmentDetailViewController ()<UIPageViewControllerDelegate>{
    NSDictionary* featureDict;
    NSDictionary* userDict;
    NSDictionary* companyConfigDict;
    BOOL isViewLoaded;
    BOOL isViewLoaded1;
    NSInteger lastSelectSegIndex;
    UIView *view;
    UISwitch *swith;
    
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *productDetailView;

//@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *productsDetailArray;
@property(nonatomic,assign)NSInteger currentSelectedIndex;
@property(strong,nonatomic)id productDetail;
@property(strong,nonatomic) ProductHistoryViewController *productHistory;
@property(strong,nonatomic) ProductDeliveryViewController *productDelivery;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lblDataLoading;
@end



@implementation ProductMultipleSegmentDetailViewController
@synthesize  segmentedControl;

-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    userDict=nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];
    //  Mahendra fetch CompanyConfig
    NSDictionary *dic1=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic1 && ![[dic1 objectForKey:@"data"] isEqual:[NSNull null]])
        userDict = [dic1 objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig
        companyConfigDict = nil;
         dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
            companyConfigDict = [dic objectForKey:@"data"];
    //End

    // code added by Satish on 9-Dec-2015
    [self reloadSegmentTabs];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];


    isViewLoaded = YES;
    isViewLoaded1 = YES;
   
    
    
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    
    
    
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 35)];
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 41, 35)];
    lblTitle.text=@"Costs:";
    [lblTitle setFont:[UIFont boldSystemFontOfSize:13]];
    swith=[[UISwitch alloc] initWithFrame:CGRectMake(42, 0, 51, 31)];
    
    [swith setOn:YES];
    [swith addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:lblTitle];
    [view addSubview:swith];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [myQueue addOperationWithBlock:^{
        [_activityIndicator startAnimating];

        @try {
            NSSet *custIheads = [NSSet setWithArray:[self findInvoicesData:self.customerInfo]];
            NSSet *custOheads = [NSSet setWithArray:[self findOutstandingData:self.customerInfo]];
            [self.customerInfo setValue:custIheads forKey:@"iheads"];
            [self.customerInfo setValue:custOheads forKey:@"oheads"];
        } @catch (NSException *exception) {
            DebugLog(@"%@",exception);
        } @finally {
            
        }
        
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_activityIndicator stopAnimating];
            [_lblDataLoading setHidden:YES];
            
            if(isViewLoaded){
                [self loadPageContent];
            }
            isViewLoaded= NO;
            
     }];
         
    }];

    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // check for App, company and user level configuration (privileges)

     if (userDict!=nil)
         [swith setOn:[[userDict valueForKey:@"showcostmargin"] boolValue]];

    [self refreshTitle];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}



-(void)reloadSegmentTabs{
    if (lastSelectSegIndex>0) {
        segmentedControl.selectedSegmentIndex=lastSelectSegIndex;
    }else
        segmentedControl.selectedSegmentIndex=0;
   
    
    [segmentedControl setEnabled:NO forSegmentAtIndex:1]; 
    [segmentedControl setEnabled:self.customerInfo!=nil forSegmentAtIndex:3];
    [segmentedControl setEnabled:NO forSegmentAtIndex:5];
    if (featureDict !=nil) {
        [segmentedControl setEnabled:[[featureDict valueForKey:@"productsaleshistoryenabled"] boolValue] && (self.customerInfo!=nil && ([[self.customerInfo valueForKeyPath:@"oheads.orderlines"] count]>0 || [[self.customerInfo valueForKeyPath:@"iheads.invoicelines"] count]>0)) forSegmentAtIndex:1];

        if(isViewLoaded1){
            if([[featureDict valueForKey:@"productsaleshistoryenabled"] boolValue] && self.customerInfo!=nil && ([[self.customerInfo valueForKeyPath:@"oheads.orderlines"] count]>0 || [[self.customerInfo valueForKeyPath:@"iheads.invoicelines"] count]>0)){
                segmentedControl.selectedSegmentIndex=1;
                lastSelectSegIndex=1;
            }
            isViewLoaded1 = NO;
        }
        
       
        
        if (![[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"productdetaildefaulttabindex"] isEqual:[NSNull null]] && [[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"productdetaildefaulttabindex"] integerValue]<7) {
            segmentedControl.selectedSegmentIndex=[[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"productdetaildefaulttabindex"] integerValue];
            lastSelectSegIndex=[[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"productdetaildefaulttabindex"] integerValue];
        }
        
        //default webconfig set history and customer havent history   default image selected
        if(lastSelectSegIndex==1  && ([[self.customerInfo valueForKeyPath:@"oheads.orderlines"] count]==0 && [[self.customerInfo valueForKeyPath:@"iheads.invoicelines"] count]==0)){
            segmentedControl.selectedSegmentIndex=0;
            lastSelectSegIndex=0;
        }
            
        
        
        // **ORDER LINE NOTES ENABLE
        [segmentedControl setEnabled:[[featureDict valueForKey:@"orderlinenotesenabled"] boolValue] forSegmentAtIndex:5];
    }
    
}

-(void)loadPageContent{
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    ProductDetailBaseController *startingViewController = [self viewControllerAtIndex:_currentSelectedIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Change the size of page view controller
   // CGRect fram=self.productDetailView.frame;
   // fram.size.height=fram.size.height+40;
    self.pageViewController.view.frame = CGRectMake(0, 0, self.productDetailView.bounds.size.width, self.productDetailView.bounds.size.height );

    [self addChildViewController:_pageViewController];
    [self.productDetailView addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

-(void)refreshTitle{
    // code added by Satish to display current item postion of total items
    self.title = [NSString stringWithFormat:@"%li of %li",(long)(_currentSelectedIndex+1),(long)[_productsDetailArray count]];
    // end of code by Satish
    if (segmentedControl.selectedSegmentIndex==1)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(doCopy:)];
    
}


- (IBAction)segmentChanged:(id)sender {
//    // changed by Satish
//    [self.productDetailView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj removeFromSuperview];
//    }];
//
//    switch (self.segmentedControl.selectedSegmentIndex) {
//        case 1:
//        {
//            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            ProductHistoryViewController *productHistory = [storyboard instantiateViewControllerWithIdentifier:@"toProductHistory"];
//            [productHistory setProductDetail:_productDetail];
//            [self.productDetailView addSubview:productHistory.view];
//            [self addChildViewController:productHistory];
//            [productHistory didMoveToParentViewController:self];
//
//        }
//            break;
//        default:
//            [self loadPageContent];
//            break;
//    }

    if (segmentedControl.selectedSegmentIndex==1)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(doCopy:)];
    else if (segmentedControl.selectedSegmentIndex==4)
    {
        self.navigationItem.rightBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    }
    else
        self.navigationItem.rightBarButtonItem=nil;

    ProductDetailBaseController *startingViewController = [self viewControllerAtIndex:_currentSelectedIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    lastSelectSegIndex=[sender tag];
}

-(void)setSelectectIndex:(NSInteger)indexValue totalProductsFetched:(NSArray*)totalProductsArray
{
    _currentSelectedIndex=indexValue;// fetching current cell clicked
    _productDetail =[totalProductsArray objectAtIndex:_currentSelectedIndex];
    _productsDetailArray=totalProductsArray;//all fetched data for showing total pages

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCopy:(id)sender {
    DebugLog(@"Do copy Clicked.");
    if (_productHistory && [segmentedControl selectedSegmentIndex]==1) {
        [_productHistory copyDone];
    }
   
}

-(IBAction)valueChange:(UISwitch *)sender
{
    if ([sender isOn]) {
     
        DebugLog(@"On");
        NSDictionary* dictNew = @{
                                  @"switch": [NSNumber numberWithBool:YES] };
        [kNSNotificationCenter postNotificationName:kcostSwitch object:self userInfo:dictNew];
    }
    else
    {
        NSDictionary* dictNew = @{
                                  @"switch": [NSNumber numberWithBool:NO] };
   [kNSNotificationCenter postNotificationName:kcostSwitch object:self userInfo:dictNew];
    }
    
}

- (IBAction)startWalkthrough:(id)sender {
    ProductDetailBaseController *startingViewController = [self viewControllerAtIndex:_currentSelectedIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (ProductDetailBaseController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.productsDetailArray count] == 0) || (index >= [self.productsDetailArray count])) {
        return nil;
    }

    ProductDetailBaseController *pvc = nil;
    if(segmentedControl.selectedSegmentIndex==1){
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        if(!_productHistory)
        _productHistory = [storyboard instantiateViewControllerWithIdentifier:@"toProductHistory"];
        _productHistory.pageIndex = index;
        _productHistory.customerInfo = self.customerInfo;
        [_productHistory setProductDetail:[_productsDetailArray objectAtIndex:index]];
        _productHistory.transactionInfo = self.transactionInfo;
        pvc =  _productHistory;
    }/*else if (segmentedControl.selectedSegmentIndex==3){
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _productDelivery = [storyboard instantiateViewControllerWithIdentifier:@"toProductDelivery"];
        _productDelivery.pageIndex = index;
        _productDelivery.customerInfo = self.customerInfo;
        
        [_productDelivery currentPageProductDetail:[_productsDetailArray objectAtIndex:index]];
        [_productDelivery setProductsDetailArray:_productsDetailArray];
        _productDelivery.customerInfo = self.customerInfo;
        _productDelivery.transactionInfo = self.transactionInfo;
        pvc =  _productDelivery;
    
    }*/
    else{
        // Create a new view controller and pass suitable data.
        ProductDetailContentViewController *productDetailContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"toProductDetailContent"];
        productDetailContentViewController.pageIndex = index;
        productDetailContentViewController.segmentedControlIndex=self.segmentedControl.selectedSegmentIndex;
        [productDetailContentViewController currentPageProductDetail:[_productsDetailArray objectAtIndex:index]];
        [productDetailContentViewController setProductsDetailArray:_productsDetailArray];
        productDetailContentViewController.customerInfo = self.customerInfo;
        productDetailContentViewController.transactionInfo = self.transactionInfo;
        pvc =  productDetailContentViewController;
    }

    return pvc;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProductDetailBaseController*) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProductDetailBaseController*) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;
    if (index == [self.productsDetailArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
//{
//    return [self.productsDetailArray count];
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return 0;
//}


#pragma mark - UIPageViewController Delegate
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if(completed){
        _currentSelectedIndex =  ((ProductDetailContentViewController*) [pageViewController.viewControllers lastObject]).pageIndex;
        [self refreshTitle];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    self.title = @"";
//    if ([[segue identifier] isEqualToString:@"tofullImageView"]) {
//        ProductImageViewController* fullImage = segue.destinationViewController;
//        [fullImage setProductArray:(NSMutableArray* )self.productsDetailArray];
//        fullImage.currentSelectedIndex = _currentSelectedIndex;
//    }

}


//***** mahendra    Featch invoice/outstanding data

-(NSArray*)findInvoicesData :(NSManagedObject*)customer{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"invoiced_date" ascending:NO];
    NSArray *descriptor = @[sortDescriptor];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setSortDescriptors:descriptor];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];//&& delv_add_code==%@ ,[customer valueForKey:@"delivery_address"]
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
    
    /*for (NSManagedObject *object in iHeadArr) {
        
        double headerFinalprice=0.0;
        double quantity=[[object valueForKeyPath:@"invoicelines.@sum.tot_invoiced_qty"] doubleValue];
        
        //Add currency Symbol
        NSString *currCode=[kUserDefaults  valueForKey:@"defaultcurrency"];
        
        
       /* if (![[currCode lowercaseString] isEqualToString:[object valueForKey:@"curr"]]) {
            NSDictionary *exchangeRateDict=[CommonHelper getExcangeRateArray:[object valueForKey:@"curr"]];
            
            if (exchangeRateDict) {
                headerFinalprice=headerTotPrice*[[exchangeRateDict valueForKey:@"exchangerate"] doubleValue];
            }else
                headerFinalprice=headerTotPrice;
        }else*
           // headerFinalprice=headerTotPrice;
        
        
        
    }*/
    
    
    
    
    
    
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
        //NSSet *custILines = [NSSet setWithArray:[self findproduct:[obj valueForKey:@"product_code"]]];
        if ([[obj valueForKey:@"product_code"] length]>0)
            [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
        [iLineArr addObject:objectnew];
    }];
    
    
    return iLineArr;
}


-(NSManagedObject*)findproduct:(NSString*)stockCode{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stock_code==%@",stockCode];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSSet *productSET = [NSSet setWithArray:[kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
   // NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSArray *myArray = [productSET allObjects];
    if ([myArray count]==0) {
        return nil;
    }else
        return [myArray lastObject];
}

//***** mahendra    Find Outstanding data

-(NSArray*)findOutstandingData:(NSManagedObject*)customer{
    
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_date" ascending:NO];
    NSArray *descriptor = @[sortDescriptor];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setSortDescriptors:descriptor];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customer_code==%@ ",[customer valueForKey:@"acc_ref"]];//&& del_add_code==%@ [customer valueForKey:@"delivery_address"]
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
        //NSSet *custILines = [NSSet setWithArray:[self findproduct:[obj valueForKey:@"product_code"]]];
        if ([[obj valueForKey:@"product_code"] length]>0)
            [objectnew setValue:[self findproduct:[obj valueForKey:@"product_code"]] forKey:@"product"];
       
        [OLineArr addObject:objectnew];
    }];
    return OLineArr;
}

@end
