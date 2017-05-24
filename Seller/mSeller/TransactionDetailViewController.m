//
//  TransactionDetailViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/14/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

// Alert tag 4 for camcel transaction Head
// Alert tag 3 for delete single transaction line
//tag101
//tag 102 for purchaseordernumber
#import "TransactionDetailViewController.h"
#import "TransactionDetailTableViewHeaderCell.h"
#import "TransactionDetailTableViewFooterCell.h"
#import "TransactionNotesViewController.h"
#import "FilterViewController.h"
#import "CustomerNewDeliveryAddressViewController.h"
#import "ProductController.h"
#import "SignatureViewController.h"
#import "EmailHOViewController.h"
#import "MailOptionsViewController.h"
#import "TransactionDelivAddViewController.h"
#import "OrderHelper.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "commonMethods.h"
#import "TranFotterBreakDown.h"



#define bgGrayColor [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0]

@interface TransactionDetailViewController ()<UITextViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,FilterViewControllerDelegate,NotesViewControllerDelegate,CustomerNewDeliveryAddressDelegate,TDTableFooterCellDelegate,FilterViewControllerDelegate>{
    
    NSDateFormatter *dateFormat;
    NSDateFormatter *timeFormat;
    NSString *strNote,*orderType;
    NSMutableDictionary* selectedNoteDict;
    NSManagedObject* deleteObj;
    NSDictionary *featureDict;
    NSDictionary *pricingConfigDict;
    NSString* heldStatus;
    NSString* purchaseordernumber;
    NSString* employeeid;
    NSString *stractualpath;
    NSInteger selectedDateOption; // 0 - Call Back, 1 - Delivery
    NSInteger totalUnits;
    NSInteger totalCartons;
    NSInteger totalLines;
    double totalCbm;
    NSString *selectedDeliveryAddress;
    NSMutableArray *arrRows;
    NSIndexPath *selIndexPath;
    int selectedOption;
   
    BOOL pageControlBeingUsed;
    int page;
    BOOL isProfitability;
    BOOL isValTapped;

    NSDictionary *dicMain;
    
    double orderCost;
    double margin;
    double markup;
    double orderValue;
    double profitiability;
    NSArray *arrKey;
    NSArray* arrRecords;
    TranFotterBreakDown *footerbrekDown;
}
@property (weak, nonatomic) IBOutlet UIButton *btnOverlay;
@property (strong, nonatomic) UILabel *lblNavTitle;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,assign) BOOL orderTypeChangeSts;
//@property (weak, nonatomic) IBOutlet UILabel *lblTitleSplitOrderSummery;


- (IBAction)dismissKeyboard:(id)sender;
@end





@implementation TransactionDetailViewController
@synthesize orderNumber,Headrecorddata,tranDetailSearchBar,searchHeightConstraints;
@synthesize OheadCount;

-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];
    
    
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]]){
        pricingConfigDict = [dic objectForKey:@"data"];
        
    }
    
    
    //  Mahendra fetch CompanyConfig
    //    companyConfigDict = nil;
    //    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    //    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
    //        companyConfigDict = [dic objectForKey:@"data"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _lblNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _lblNavTitle.font = [UIFont boldSystemFontOfSize:13.0];
    _lblNavTitle.numberOfLines=2;
    _lblNavTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = _lblNavTitle;

    
    _orderTypeChangeSts=NO;
    // Do any additional setup after loading the view.
    kAppDelegate.transactionTabClick=NO;
    self.tblTransactionDetail.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tblTransactionDetail.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    //    self.tblTransactionDetail.backgroundColor=[UIColor lightGrayColor];
    
    //    tranDetailSearchBar.delegate = self;
    // self.segmentedControl.selectedSegmentIndex=1;
    // [self segmentBtnPressed:_segmentedControl];
    self.view.backgroundColor=bgGrayColor;
    
    _viewTransactionTotal.layer.borderColor=[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1].CGColor;
    // _viewTransactionTotal.layer.borderColor=[UIColor blackColor].CGColor;
    _viewTransactionTotal.layer.borderWidth=1.0;
    _viewTransactionTotal.layer.cornerRadius=4.0;

    if(_isEditing || _isFirstTimeTransaction)
    {
       self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
        
    }
    else
    {
        
        UIBarButtonItem *btnMail = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"envelope.png"] style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
        btnMail.imageInsets=UIEdgeInsetsMake(2, 10, 0, -10);
        btnMail.tag=0;
        
        UIBarButtonItem *btnPrint= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"print.png"] style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
        btnPrint.tag=1;
        self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:btnPrint,btnMail, nil];
        
        
  
    }
    
    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];
    
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy"];
    
    timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    
    if (((kAppDelegate.transactionInfo && ![[kAppDelegate.transactionInfo valueForKey:@"orderid"] isEqualToString:[Headrecorddata valueForKey:@"orderid"]] && _isEditing) || (!kAppDelegate.transactionInfo && _isEditing)) && [[Headrecorddata valueForKey:@"orderlinesnew"] count]==0){
        [self performSegueWithIdentifier:@"editTransactionSegue" sender:nil];
    }
    
    [self loadTransactionInfo];
    //    [self fetchedResultsController];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(dismissKeyboard)];
    [_tblTransactionDetail addGestureRecognizer:tap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(showCostMargin:)];
    [_viewTransactionTotal addGestureRecognizer:singleTap];
    
    
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshOHeaddata:) name:kOrderTypechange object:nil];
    pageControlBeingUsed=YES;
    
    [kNSNotificationCenter addObserver:self selector:@selector(load_otherView:) name:kLoadOtherTabController object:nil];
}

-(void)load_otherView:(NSNotification *) notification{
    
    _orderTypeChangeSts=NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    
   // [kNSNotificationCenter removeObserver:self name:kOrderTypechange object:nil];
    [super viewWillDisappear:animated];
}

-(void)dismissKeyboard {
    [[self view] endEditing:TRUE];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (OheadCount>1) {
        self.navigationItem.leftItemsSupplementBackButton=YES;
    }

    _lblNavTitle.text = [NSString stringWithFormat:@"%@\n%@-%@",[Headrecorddata valueForKey:@"orderid"],[[Headrecorddata valueForKey:@"customer"] valueForKey:@"acc_ref"],[[Headrecorddata valueForKey:@"customer"] valueForKey:@"name"]];
    if (!kAppDelegate.transactionInfo) {
        [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    }
    else{
        self.navigationItem.leftItemsSupplementBackButton=NO;
    }
    
    [self loadTransactionInfo];
    [_tblTransactionDetail reloadData];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (_segmentedControl.selectedSegmentIndex==1)
        self.searchHeightConstraints.constant=[[Headrecorddata valueForKey:@"orderlinesnew"] count]>10?44:0;
    else
        self.searchHeightConstraints.constant = 0;
    
    if (_segmentedControl.selectedSegmentIndex==0)
    {
        TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
       // [cell.txtCustomerAddress setContentOffset:CGPointZero animated:YES];
       // [cell.txtCustomerDeliveryAddress setContentOffset:CGPointZero animated:YES];
         [cell.txtCustomerAddress  setTextContainerInset:UIEdgeInsetsMake(0, -5, 0, 0)];
         [cell.txtCustomerDeliveryAddress  setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    else if (_segmentedControl.selectedSegmentIndex==2)
    {
        TransactionDetailTableViewFooterCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.txtViewNotes.textContainerInset = UIEdgeInsetsMake(0.0,0.0, 0.0, 0.0);
    }
}

-(IBAction)segmentBtnPressed:(UISegmentedControl*)sender{
    
    [_btnOverlay setHidden:YES];
    
    if (_segmentedControl.selectedSegmentIndex==1){
        UIButton *btnItemDetail=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        btnItemDetail.frame=CGRectMake(0, 0, 30, 22);
        [btnItemDetail addTarget:self action:@selector(showProfitability:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *btnProfitabilty=[[UIBarButtonItem alloc] initWithCustomView:btnItemDetail];
        UIBarButtonItem *btnSave=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];

        if (_isEditing || _isFirstTimeTransaction) {
            self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:btnSave,btnProfitabilty, nil];
        }else
            self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:btnProfitabilty, nil];
        
        
        
        self.searchHeightConstraints.constant = 44; //update constraints
        self.searchHeightConstraints.constant=[[Headrecorddata valueForKey:@"orderlinesnew"] count]>10?44:0;
        //        [self.view setNeedsUpdateConstraints];
    }else{
        self.searchHeightConstraints.constant = 0;//update constraints
        //        [self.view setNeedsUpdateConstraints];
        if (_segmentedControl.selectedSegmentIndex!=1)
        {
            self.navigationItem.rightBarButtonItem=nil;
           
            if (_isEditing || _isFirstTimeTransaction) {
               self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
            }else{
                UIBarButtonItem *btnMail = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"envelope.png"] style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
                btnMail.imageInsets=UIEdgeInsetsMake(2, 10, 0, -10);
                btnMail.tag=0;
                
                UIBarButtonItem *btnPrint= [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"print.png"] style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
                btnPrint.tag=1;
                self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:btnPrint,btnMail, nil];
            }
            
            
            
                
        }
        
    }
    pageControlBeingUsed=YES;
    [_tblTransactionDetail reloadData];
}

-(void)loadTransactionInfo{
    [self loadTransactionItems];

    totalCartons=0;
    totalCbm=0.0;


    totalUnits = [[arrRows valueForKeyPath:@"@sum.quantity"] integerValue];
    totalLines = [[arrRows valueForKeyPath:@"linetotal"] count];

    [arrRows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *record=[arrRows objectAtIndex:idx];
        NSManagedObject *mObj=[record valueForKey:@"Arrays"];
        // NSInteger ctns = [[record valueForKey:@"quantity"] integerValue]/[[record valueForKey:@"line_outer"] integerValue];
        NSInteger ctns = [[record valueForKey:@"quantity"] integerValue]/[[[mObj valueForKey:@"line_outer"] objectAtIndex:0] integerValue];
        totalCartons += ctns;
        totalCbm += ctns *[[[record valueForKey:@"product"] valueForKey:@"prd_carton_cbm"]doubleValue];
    }];


    //Add currency Symbol
    NSString *currCode=[Headrecorddata valueForKey:@"Curr"];

    dispatch_async(dispatch_get_main_queue(), ^{
    NSNumber *totalVal = [arrRows valueForKeyPath:@"@sum.linetotal"];
    _lblTransactionTotal.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value:[totalVal doubleValue]];
    });
                   
    if(kAppDelegate.transactionInfo && [[kAppDelegate.transactionInfo valueForKey:@"orderid"] isEqualToString:[Headrecorddata valueForKey:@"orderid"]]){
        
        NSString *strdefordtype = @"";
        
        if(pricingConfigDict){
            NSArray *arrtranstypes = [[pricingConfigDict objectForKey:@"orderconfigs"] objectForKey:@"transactiontypes"];
            NSArray *arrdeftranstypes = [arrtranstypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]];
            
            if(arrdeftranstypes && [arrdeftranstypes count]>0)
                strdefordtype = [[arrdeftranstypes firstObject] objectForKey:@"code"];
            else if ([arrtranstypes count]>0){
                strdefordtype = [[arrtranstypes firstObject] objectForKey:@"code"];
            }
        }
        
        BOOL isChanges  = NO;
        NSString *strordtype=strdefordtype;
        if([[[Headrecorddata valueForKey:@"ordtype"] uppercaseString] isEqualToString:@"C"] && [[Headrecorddata valueForKey:@"orderlinesnew"] count]>0){
            strordtype = strdefordtype;
            
            isChanges = YES;
        }
        else if(![[[Headrecorddata valueForKey:@"ordtype"] uppercaseString] isEqualToString:@"C"] && [[Headrecorddata valueForKey:@"orderlinesnew"] count]==0){
            //            if((featureDict && [[featureDict objectForKey:@"calllogsenabled"] boolValue]) && [[strordtype uppercaseString] isEqualToString:@"C"]){
            strordtype = @"C";
            isChanges = YES;
            //            }
        }
        
        if(isChanges){
            [Headrecorddata setValue:strordtype forKey:@"ordtype"];
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }
    }
    
    if ([orderType length]==0)//Only First time
        orderType=[Headrecorddata valueForKey:@"ordtype"];
    
    if ([strNote length]==0)//Only First time
        strNote=[Headrecorddata valueForKey:@"payment_note"];
    
    [_tblTransactionDetail reloadData];
    
   
}

-(IBAction)barBtnClick:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"Save"]) {
        [self save_currentTransaction:1];
    }
    else if ([sender.title isEqualToString:@"Cancel"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel Transaction" message:@"Are you sure you want to cancel this transaction?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil];
        [alert show];
        [alert setTag:4];
        
    }
    else
    {
        
        if (sender.tag==0)
            selectedOption=0;
        else
            selectedOption=1;
        
        [self performSegueWithIdentifier:@"toMailOptionsViewController" sender:self];
    }
}

-(void)save_currentTransaction :(NSInteger )saveSts{
    kAppDelegate.isEditTransaction=NO;
    
    if (saveSts==1) {
        
        
        
        if((strNote==nil || [strNote isEqualToString:@"(null)"] || [strNote length]==0) && _segmentedControl.selectedSegmentIndex==2){
            TransactionDetailTableViewFooterCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
            strNote=cell.txtViewNotes.text;
        }
        
        if (strNote)
            [Headrecorddata setValue:strNote forKey:@"payment_note"];
        
        if (heldStatus)
            [Headrecorddata setValue:heldStatus forKey:@"held_status"];
        
        if (_segmentedControl.selectedSegmentIndex==0) {
            TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]]; 
                purchaseordernumber=cell.txtFieldCustomerRefrence.text;
                employeeid=cell.txtFieldUserID.text;
        }
        
        
        
//        TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
//        purchaseordernumber=cell.txtFieldCustomerRefrence.text;
        //update Cust Order Ref:
        [Headrecorddata setValue:purchaseordernumber forKey:@"purchaseordernumber"];
        //update employeeid:
        [Headrecorddata setValue:employeeid forKey:@"employeeid"];
        
        if(kAppDelegate.transactionInfo){
            
            if (_isEditing) {
               
                [self saveCurrentTransaction:[Headrecorddata valueForKey:@"orderid"]];
            }else{
            
            [OrderHelper getNewOrderNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId IsCopying:NO CompletionBlock:^(NSString * _Nullable newordernumber) {
                // to reset existing order with new order number if already exist
                [self saveCurrentTransaction:newordernumber];
                
            }];
        
            }
        
        
        }
        else{
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //  Delete transaction details
       NSArray  *tempArray = [[Headrecorddata valueForKey:@"orderlinesnew"] allObjects];
        [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [kAppDelegate.managedObjectContext deleteObject:obj];
       
        }];
        
        [kAppDelegate.managedObjectContext deleteObject:kAppDelegate.transactionInfo];
        [self clearCurrentTransaction];
        
        
        [kUserDefaults removeObjectForKey:@"isEditing"];//remove edit status
    }
    
   // NSDictionary *dicSelPriceRow=@{};
   // [kUserDefaults  setObject:dicSelPriceRow forKey:@"SelPriceRow"];
    [kUserDefaults  removeObjectForKey:@"SelPriceRow"];
    [kUserDefaults  removeObjectForKey:@"StockBandArray"];
    
    [kUserDefaults  synchronize];
}


-(void)saveCurrentTransaction:(NSString*)ordNumber{
    
    if(![[Headrecorddata valueForKey:@"orderid"] isEqualToString:ordNumber]){
        [Headrecorddata setValue:ordNumber forKey:@"orderid"];
        
        
        NSArray  *tempArray = [[Headrecorddata valueForKey:@"orderlinesnew"] allObjects];
        
        [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setValue:ordNumber forKey:@"orderid"];
            if (_orderTypeChangeSts)
                [obj setValue:orderType forKey:@"orderlinetype"];
            
            [obj setValue:Headrecorddata forKey:@"orderheadnew"];
            
            if ([selectedDeliveryAddress length]>0 && ![selectedDeliveryAddress isEqualToString:@"(null)"] && selectedDeliveryAddress!=nil)
                [obj setValue:selectedDeliveryAddress forKey:@"deliveryaddresscode"];
            
            
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
        }];
        //                    [Headrecorddata setValue:[NSSet setWithArray:_fetchedResultsController.fetchedObjects] forKey:@"orderlinesnew"];
        
        
        if (orderType)
            [Headrecorddata setValue:orderType forKey:@"ordtype"];
        
        
    }else{
        
        if (orderType)
            [Headrecorddata setValue:orderType forKey:@"ordtype"];
        
    }
    
    [Headrecorddata setValue:[NSNumber numberWithBool:NO] forKey:@"isopen"];
    [Headrecorddata setValue:[NSDate date] forKey:@"end_time"];
    
    if ([selectedDeliveryAddress length]>0 && ![selectedDeliveryAddress isEqualToString:@"(null)"] && selectedDeliveryAddress!=nil){
        [Headrecorddata setValue:selectedDeliveryAddress forKey:@"deliveryaddressid"];
        
        NSManagedObject *customerData=[Headrecorddata valueForKey:@"customer"];
        NSManagedObject *custObj= [commonMethods fetch_customer:[customerData valueForKey:@"acc_ref"] deliverId:selectedDeliveryAddress];
        [Headrecorddata setValue:custObj forKey:@"customer"];
    }
    
    [self clearCurrentTransaction];
    
    
    // set next order number
    if (!_isEditing) {
        NSInteger nextordseq = [[ordNumber substringFromIndex:[kAppDelegate.repId length]] integerValue]+1;
        [OrderHelper setNextOrderNumberWithRepId:kAppDelegate.repId CompanyId:kAppDelegate.selectedCompanyId NextOrderSeqquence:nextordseq];
    }
    
    
    [kUserDefaults removeObjectForKey:@"isEditing"];
    [kUserDefaults synchronize];
}




-(void)clearCurrentTransaction{
    NSError *error = nil;
    if(kAppDelegate.transactionInfo){
        //******* Check data
        kAppDelegate.customerInfo = nil;
        [kAppDelegate loadCustomerInfo];
        
        // refresh product controler if open
        UITabBarController *tabC = (UITabBarController *)[self.navigationController parentViewController];
        UINavigationController *prodNav = [tabC.viewControllers objectAtIndex:1];
        [prodNav popToRootViewControllerAnimated:NO];
        
        [kNSNotificationCenter postNotificationName:kRefreshTabItems object:nil];
    }
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_segmentedControl.selectedSegmentIndex==0)
        if (indexPath.row==0)
            return 260.0;
        else
            return 150.0;
        else if (_segmentedControl.selectedSegmentIndex==2)
            return 432.0;
        else if (isValTapped)
            return 44.0;
        else
            return 85.0;
    /* else
     return 85.0;*/
    //if (_segmentedControl.selectedSegmentIndex==1 && !isProfitability)
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
       // if ((_segmentedControl.selectedSegmentIndex==0)|| (_segmentedControl.selectedSegmentIndex==2))
    return 1;
       // else
       //     return [[self.fetchedResultsController sections] count];
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex==0)
        return 2;
    else if (_segmentedControl.selectedSegmentIndex==2)
        return 1;
    else if (isValTapped)
        return 5;
    else{
           //     id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        //return [sectionInfo numberOfObjects];
        return [arrRows count];//[sectionInfo numberOfObjects];
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_segmentedControl.selectedSegmentIndex==1){
    if (indexPath.row%2 ==0) {
        cell.backgroundColor=tblOddColor;
    }else
        if (!isValTapped)
        cell.backgroundColor=tblEvenColor;
        else
            cell.backgroundColor=tblOddColor;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSString *title=[NSString stringWithFormat:@"%@Cell",[_segmentedControl titleForSegmentAtIndex:_segmentedControl.selectedSegmentIndex] ];
    static NSString *simpleTableIdentifier = @"TransactionDetailTableViewHeaderCell";
    static NSString *simpleTableIdentifier1 = @"TransactionDetailTableViewItemCell";
    static NSString *simpleTableIdentifier2 = @"TransactionDetailTableViewFooterCell";
    static NSString *simpleTableIdentifier3 = @"TransactionDetailTableViewHeaderCell1";
    static NSString *simpleTableIdentifier4 = @"TransactionDetailTableViewCostAndMarginItemCell";
    static NSString *simpleTableIdentifier5 = @"CostAndMarginTableViewCell";
    
    NSArray *tempArr=nil;
    if(pricingConfigDict){
        tempArr  =  [[[pricingConfigDict objectForKey:@"orderconfigs"] objectForKey:@"transactiontypes"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.code==%@",orderType]];
    }
    
    if (_segmentedControl.selectedSegmentIndex==0) {
        if (indexPath.row==0) {
            TransactionDetailTableViewHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
//            if (cell == nil) {
//                cell = [[TransactionDetailTableViewHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//            }
//            
            
            
            if([tempArr count]>0){
                cell.lblOrderType.text=[[tempArr lastObject]valueForKey:@"label"];
            }else
                cell.lblOrderType.text=orderType;
            
            
            cell.lblCustomerCode.text=[Headrecorddata valueForKey:@"customerid"];
            cell.lblDeliveryID.text=[Headrecorddata valueForKey:@"deliveryaddressid"];
            selectedDeliveryAddress=cell.lblDeliveryID.text;
            cell.lblTransactionRefrence.text=[Headrecorddata valueForKey:@"orderid"];
            cell.txtFieldCustomerRefrence.text=[Headrecorddata valueForKey:@"purchaseordernumber"];
            cell.txtFieldUserID.text=[Headrecorddata valueForKey:@"employeeid"];
           
            [cell.txtFieldUserID setDelegate:self];
            [cell.txtFieldCustomerRefrence setDelegate:self];
            
            
            
            NSManagedObject *customerData=[Headrecorddata valueForKey:@"customer"];
            cell.lblCustomerName.text=[customerData valueForKey:@"name"];
            cell.txtCustomerAddress.text=[commonMethods returnBaseAddress:customerData];//[self retuenAddresswithoutnull:customerData];
            //[NSString stringWithFormat:@"%@ %@ %@ %@ %@",[customerData valueForKey:@"addr1"],[customerData valueForKey:@"addr2"],[customerData valueForKey:@"addr3"],[customerData valueForKey:@"addr4"],[customerData valueForKey:@"addr5"]];
            cell.txtCustomerDeliveryAddress.text=[self retuenAddresswithoutnull:customerData];//[NSString stringWithFormat:@"%@ %@ %@ %@ %@",[customerData valueForKey:@"addr1"],[customerData valueForKey:@"addr2"],[customerData valueForKey:@"addr3"],[customerData valueForKey:@"addr4"],[customerData valueForKey:@"addr5"]];

            /*        if (strSelectedDate.length>0)
             [cell.btnCallBackDate setTitle:strSelectedDate forState:UIControlStateNormal];
             else
             {
             [cell.btnCallBackDate setTitle:[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[NSDate date]] forState:UIControlStateNormal];
             }*/

            //  Mahendra fetch Feature config **ADD NEW DELIVERY ADDRESS
            [cell.btnDeliveryID setEnabled:NO];
            if (featureDict !=nil && [[featureDict valueForKey:@"addnewdeliveryaddressenabled"] boolValue] && _isEditing){
                [cell.btnDeliveryID setEnabled:YES];
            }//end
            
            // disable editing while transaction in view mode
            cell.txtFieldCustomerRefrence.userInteractionEnabled = _isEditing;
            cell.txtFieldUserID.userInteractionEnabled = _isEditing;
//            cell.txtCustomerAddress.editable = _isEditing;
//            cell.txtCustomerDeliveryAddress.editable = _isEditing;
            cell.btnDeliveryAddressSearch.enabled = _isEditing;
            
            
            if (_isEditing || _isFirstTimeTransaction){
                cell.btnOrderType.enabled = YES;
            }else
                cell.btnOrderType.enabled = NO;
            
            
            
            
            //Last statement if call log then ordertype desable
            if ([[[Headrecorddata valueForKey:@"ordtype"] uppercaseString] isEqualToString:@"C"]) {
                cell.btnOrderType.enabled=NO;
            }
            
            
            return cell;
        }
        else
        {
            TransactionDetailTableViewHeaderCell1 *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier3];

            cell.lblTransactionDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"required_bydate"]];
            NSManagedObject *customerData=[Headrecorddata valueForKey:@"customer"];
            if ([[customerData valueForKey:@"phone"] length]>0) {
                cell.lblCustomerPhone.text=[customerData valueForKey:@"phone"];
            }else//default phone no
                cell.lblCustomerPhone.text=[commonMethods returnBasePhoneNumber:customerData];
            
            
            
            cell.lblCustomerEmail.text=[customerData valueForKey:@"emailaddress"];
            
             if ([[customerData valueForKey:@"contact"]length]>0) {
                 cell.lblContact.text=[customerData valueForKey:@"contact"];
             }else
                  cell.lblContact.text=[commonMethods returnBaseContact:customerData];

            [cell.btnCallBackDate setTitle:[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"nextcall_date"]] forState:UIControlStateNormal];

            cell.btnCallBackDate.enabled = _isEditing;
            return cell;
        }
    }
    else if(_segmentedControl.selectedSegmentIndex==1  && !isProfitability)
    {
        if (isValTapped) {
            CostAndMarginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier5];
            
            [self configureCostAndMarginCell:cell atIndexPath:indexPath];
            return cell;
        }
        else
        {
        TransactionDetailTableViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier1];
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
        }
    }
    else if(_segmentedControl.selectedSegmentIndex==1  && isProfitability)
    {
        if (isValTapped) {
            CostAndMarginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier5];
            
            [self configureCostAndMarginCell:cell atIndexPath:indexPath];
            return cell;
        }
        else
        {
            
            TransactionDetailTableViewCostAndMarginItemCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier4];
            
            [self configureMarginCell:cell atIndexPath:indexPath];
            return cell;
        }
    }
    else
    {
        TransactionDetailTableViewFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier2];
        [cell setDelegate:self];
        
         [cell.switchOrderStatus setOn:[[Headrecorddata valueForKey:@"held_status"] isEqualToString:@"Y"]];
       
       
        if([strNote length]>0)
            cell.txtViewNotes.text=strNote;

        [cell.btnNotes setEnabled:NO];
        [cell.switchOrderStatus setEnabled:NO];
        [cell.switchMailOption setEnabled:NO];
        
        
        
        
        NSString *strLabeltitle=@"";
        if (cell.pageControl.currentPage==0){
            strLabeltitle=@"Total";
       //     _lblTitleSplitOrderSummery.text=@"Total";
        }
        else if (cell.pageControl.currentPage==1){
            strLabeltitle=@"Now";
        //    _lblTitleSplitOrderSummery.text=@"Now";
        }
        else if (cell.pageControl.currentPage==2){
            strLabeltitle=@"Future";
        //    _lblTitleSplitOrderSummery.text=@"Future";
        }
        
       // NSString *strValue=[NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@",strLabeltitle,[NSString stringWithFormat:@"%ld",(long)totalUnits],[NSString stringWithFormat:@"%ld",(long)totalCartons],[NSString stringWithFormat:@"%0.2f",totalCbm],[NSString stringWithFormat:@"%li",(long)totalLines],[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"required_bydate"]]];
        
        NSString *strValue=[NSString stringWithFormat:@"%@|%@|%@|%@|%@",[NSString stringWithFormat:@"%ld",(long)totalUnits],[NSString stringWithFormat:@"%ld",(long)totalCartons],[NSString stringWithFormat:@"%0.2f",totalCbm],[NSString stringWithFormat:@"%li",(long)totalLines],[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"required_bydate"]]];
        
        
        
//        NSString *strNow=[NSString stringWithFormat:@"%@|%@|%@|%@|%@",[NSString stringWithFormat:@"%ld",(long)totalUnits],[NSString stringWithFormat:@"%ld",(long)totalCartons],[NSString stringWithFormat:@"%0.2f",totalCbm],[NSString stringWithFormat:@"%li",(long)totalLines],[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"required_bydate"]]];
//
//        NSString *strFuture=[NSString stringWithFormat:@"%@|%@|%@|%@|%@",[NSString stringWithFormat:@"%ld",(long)totalUnits],[NSString stringWithFormat:@"%ld",(long)totalCartons],[NSString stringWithFormat:@"%0.2f",totalCbm],[NSString stringWithFormat:@"%li",(long)totalLines],[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"required_bydate"]]];
//        
        //  DebugLog(@"qty_free --%@",[[[Headrecorddata valueForKey:@"orderlinesnew"] valueForKey:@"product"] valueForKey:@"qty_free"]);
        
       
        
        footerbrekDown =  (TranFotterBreakDown *)[self.storyboard instantiateViewControllerWithIdentifier:@"TranFotterBreakDown"];
        [footerbrekDown setOrderNumber:orderNumber];
        [footerbrekDown setTxtsearch:self.tranDetailSearchBar.text];
        if (_isEditing || _isFirstTimeTransaction) {
            [footerbrekDown setIsEditing:YES];
        }else
            [footerbrekDown setIsEditing:NO];
        
        [footerbrekDown setHeadrecorddata:Headrecorddata];
        footerbrekDown.view.frame = CGRectMake(0, 0, cell.FotterbreakDownView.frame.size.width, cell.FotterbreakDownView.frame.size.height);
//        [cell addChildViewController:footerbrekDown];
//        [footerbrekDown didMoveToParentViewController:self];
        [cell.FotterbreakDownView addSubview:footerbrekDown.view];

        
        
        
       /* cell.lblUnits.text=[NSString stringWithFormat:@"%ld",(long)totalUnits];
        cell.lblCartons.text=[NSString stringWithFormat:@"%ld",(long)totalCartons];
        cell.lblCBM.text=[NSString stringWithFormat:@"%0.2f",totalCbm];
        cell.lblLines.text=[NSString stringWithFormat:@"%li",(long)[[Headrecorddata valueForKey:@"orderlinesnew"] count]];*/
        //        end
        
        // Note caption
        if([tempArr count]>0){
            cell.lblNotesCaption.text=[NSString stringWithFormat:@"%@ Notes",[[tempArr lastObject]valueForKey:@"label"]];
        }
        
        // disable editing while transaction in view mode
        cell.btnDeliveryDate.enabled = _isEditing;
        cell.txtViewNotes.userInteractionEnabled = _isEditing;
        cell.btnSignature.enabled =_isEditing;
        //        cell.switchOrderStatus.enabled = _isEditing;
        //  cell.btnNotes.enabled =_isEditing; 
        //  cell.switchMailOption.enabled =_isEditing;
        
        
        //  Mahendra fetch Feature config **HELD ORDER SWITCH ENABLE
       
        if (featureDict && [[featureDict valueForKey:@"ordernotesenabled"] boolValue] && _isEditing){// **ORDER HEAD NOTES ENABLE
            [cell.btnNotes setEnabled:YES];
        }
        
        
        if (featureDict !=nil && [[featureDict valueForKey:@"heldorderenabled"] boolValue] && _isEditing){
            [cell.switchOrderStatus setEnabled:YES];
            cell.switchOrderStatus.enabled = _isEditing;
        }
        
        // if (featureDict !=nil && [[featureDict valueForKey:@"mail"] boolValue] && _isEditing){
        //[cell.switchMailOption setEnabled:YES];
        //}
        [cell.switchMailOption setEnabled:YES];
        [cell.switchMailOption setOn:[[Headrecorddata valueForKey:@"emailconfirm"] isEqualToString:@"Y"]];
        
            
            
        return cell;
    }
}



-(void)load_FotterBreakDown{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        static NSString *simpleTableIdentifier2 = @"TransactionDetailTableViewFooterCell";
        TransactionDetailTableViewFooterCell *cell = [_tblTransactionDetail dequeueReusableCellWithIdentifier:simpleTableIdentifier2];
        
        footerbrekDown =  (TranFotterBreakDown *)[self.storyboard instantiateViewControllerWithIdentifier:@"TranFotterBreakDown"];
        [cell.scrollView addSubview:footerbrekDown.view];
    });
    
}



/*- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    UITableViewCell *tableViewCell=[_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if ([tableViewCell isKindOfClass:[TransactionDetailTableViewFooterCell class]]) {
        TransactionDetailTableViewFooterCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
        if (!pageControlBeingUsed) {
            // Switch the indicator when more than 50% of the previous/next page is visible
            CGFloat pageWidth = cell.scrollView.frame.size.width;
            page = floor((cell.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            if (page<0)
                DebugLog(@"page  %d",page);
            cell.pageControl.currentPage = page;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    [self loadTransactionInfo];
}*/

-(UIView *)getUnitsCartonView :(NSString *) strValue{
    //CGRect frame;
   
   
    
    
    
    
    
    
    // TransactionDetailTableViewFooterCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    double RowHeight=22;
    double yAxis=20;
    if (page == 1 || page ==2) {
        RowHeight=28;
        yAxis=26;
    }
    NSArray *arrValue=[strValue componentsSeparatedByString:@"|"];
    UIView *viewTotal=[[UIView alloc]initWithFrame:CGRectMake(0,0,310,166)];//create view
    viewTotal.tag=108;
    viewTotal.backgroundColor=[UIColor whiteColor];
    
    UILabel *lblTotal =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 18)];//create label total
    lblTotal.text = [arrValue objectAtIndex:0];
    lblTotal.textColor=[UIColor whiteColor];
    //lblTotal.backgroundColor=[UIColor blueColor];
    [lblTotal setBackgroundColor:[UIColor colorWithRed:(38/255.f) green:(46/255.f) blue:(61/255.f) alpha:1.0f]];
    // [lblTotal setFont:[UIFont fontWithName:@"System" size:16]];
    [lblTotal setFont:[UIFont boldSystemFontOfSize:16.0]];
    lblTotal.textAlignment= NSTextAlignmentCenter;
    [viewTotal addSubview:lblTotal];
    
    ///Unit Row
    
    //Units Label
    UILabel *lblUnit =  [[UILabel alloc] initWithFrame:CGRectMake(7, yAxis, 66, RowHeight)];
    lblUnit.text = @"Units:";
    lblUnit.textColor=[UIColor blackColor];
    lblUnit.backgroundColor=[UIColor clearColor];
    [lblUnit setFont:[UIFont boldSystemFontOfSize:12.0]];
    lblUnit.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblUnit];
    
    //Units Value Label
    _lblUnits =  [[UILabel alloc] initWithFrame:CGRectMake(70,yAxis, 240, RowHeight)];//create label Units value
    // lblUnitValue.text = @"Units:";
    _lblUnits.text=[arrValue objectAtIndex:1];
    _lblUnits.textColor=[UIColor blackColor];
    _lblUnits.backgroundColor=[UIColor clearColor];
    [_lblUnits setFont:[UIFont systemFontOfSize:12.0]];
    _lblUnits.textAlignment= NSTextAlignmentRight;
    _lblUnits.tag=101;
    [viewTotal addSubview:_lblUnits];
    
    yAxis=yAxis+RowHeight + 5;
    //Units saperator
    UILabel *lblUnitLine =  [[UILabel alloc] initWithFrame:CGRectMake(0, yAxis, 310, 1)];
    lblUnitLine.textColor=[UIColor blackColor];
    lblUnitLine.backgroundColor=[UIColor grayColor];
    [lblUnitLine setFont:[UIFont fontWithName:@"System" size:17]];
    lblUnitLine.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblUnitLine];
    
    //Unit Row Ended
    
    
    //Cartoon Row
    
    yAxis=yAxis + 5;
    //Carton Label
    UILabel *lblCart =  [[UILabel alloc] initWithFrame:CGRectMake(7, yAxis, 92, RowHeight)];
    lblCart.text = @"Cartons:";
    lblCart.textColor=[UIColor blackColor];
    lblCart.backgroundColor=[UIColor clearColor];
    [lblCart setFont:[UIFont boldSystemFontOfSize:12.0]];
    lblCart.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblCart];
    
    //Cartons Value
    _lblCartons =  [[UILabel alloc] initWithFrame:CGRectMake(70, yAxis, 240, RowHeight)];//create label carton value
    _lblCartons.text=[arrValue objectAtIndex:2];
    _lblCartons.textColor=[UIColor blackColor];
    _lblCartons.backgroundColor=[UIColor clearColor];
    [_lblCartons setFont:[UIFont systemFontOfSize:12.0]];
    _lblCartons.textAlignment= NSTextAlignmentRight;
    _lblCartons.tag=102;
    [viewTotal addSubview:_lblCartons];
    
    yAxis=yAxis+RowHeight + 5;
    //Cartoon Saperator
    UILabel *lblCartonLine =  [[UILabel alloc] initWithFrame:CGRectMake(0,yAxis, 310, 1)];
    lblCartonLine.textColor=[UIColor blackColor];
    lblCartonLine.backgroundColor=[UIColor grayColor];
    [lblCartonLine setFont:[UIFont fontWithName:@"System" size:17]];
    lblCartonLine.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblCartonLine];
    
    //Cartons Row Ended
    
    // CBM Row
    
    yAxis=yAxis + 5;
    // CBM Label
    
    UILabel *lblCbFOrCbm1 = [[UILabel alloc] initWithFrame:CGRectMake(7,yAxis, 56, RowHeight)];//create label CBM
    /* if([[CompanyConfigDelegate.dicOrderInfo objectForKey:@"Cube_Size_By"] isEqualToString:@"Cubic Feet (cuft)"])
     lblCbFOrCbm1.text = @"CBF";
     else*/
    lblCbFOrCbm1.text = @"CBM";
    
    lblCbFOrCbm1.textColor=[UIColor blackColor];
    lblCbFOrCbm1.backgroundColor=[UIColor clearColor];
    [lblCbFOrCbm1 setFont:[UIFont boldSystemFontOfSize:12.0]];
    lblCbFOrCbm1.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblCbFOrCbm1];
    
    //CBM Value
    _lblCBM =  [[UILabel alloc] initWithFrame:CGRectMake(70, yAxis, 240, RowHeight)];//create label carton value
    _lblCBM.text=[arrValue objectAtIndex:3];
    _lblCBM.textColor=[UIColor blackColor];
    _lblCBM.backgroundColor=[UIColor clearColor];
    [_lblCBM setFont:[UIFont systemFontOfSize:12.0]];
    _lblCBM.textAlignment= NSTextAlignmentRight;
    _lblCBM.tag=103;
    [viewTotal addSubview:_lblCBM];
    
    yAxis=yAxis+RowHeight + 5;
    //CBM Saperator
    UILabel *lblCbmLine =  [[UILabel alloc] initWithFrame:CGRectMake(0,yAxis, 310, 1)];//create label cbm below line
    lblCbmLine.textColor=[UIColor blackColor];
    lblCbmLine.backgroundColor=[UIColor grayColor];
    [lblCbmLine setFont:[UIFont fontWithName:@"System" size:17]];
    lblCbmLine.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblCbmLine];
    
    //CBM Row Ended
    
    //Lines Row
    yAxis=yAxis + 5;
    //Lines Label
    UILabel *lblLin =  [[UILabel alloc] initWithFrame:CGRectMake(7,yAxis, 92, RowHeight)];//create label lines
    lblLin.text = @"Lines:";
    lblLin.textColor=[UIColor blackColor];
    lblLin.backgroundColor=[UIColor clearColor];
    [lblLin setFont:[UIFont boldSystemFontOfSize:12.0]];
    lblLin.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblLin];
    
    //Lines Value
    _lblLines =  [[UILabel alloc] initWithFrame:CGRectMake(50,yAxis, 260, RowHeight)];
    _lblLines.text=[arrValue objectAtIndex:4];
    _lblLines.textColor=[UIColor blackColor];
    _lblLines.backgroundColor=[UIColor clearColor];
    [_lblLines setFont:[UIFont systemFontOfSize:12.0]];
    _lblLines.textAlignment= NSTextAlignmentRight;
    _lblLines.tag=104;
    [viewTotal addSubview:_lblLines];
    
    yAxis=yAxis+RowHeight + 5;
    int sheight=1;
    
    if (page == 1 || page ==2) {
        yAxis=yAxis-.8;
        sheight=2;
    }
    else
        yAxis=yAxis-2;
    
    
    
    //Lines Saperator
    UILabel *lblLinesLine =  [[UILabel alloc] initWithFrame:CGRectMake(0 ,yAxis, 310, sheight)];//create label lines below line
    lblLinesLine.textColor=[UIColor blackColor];
    lblLinesLine.backgroundColor=[UIColor grayColor];
    [lblLinesLine setFont:[UIFont fontWithName:@"System" size:17]];
    lblLinesLine.textAlignment= NSTextAlignmentLeft;
    [viewTotal addSubview:lblLinesLine];
    //Lines Row Ended
    
   // DebugLog(@"Current page  %d",cell.pageControl.currentPage);
    if (page == 0) {
        //Dilevery Row
        yAxis=yAxis + 5;
        //Dilevery Label
        UILabel *lblDeliveryDate = [[UILabel alloc] initWithFrame:CGRectMake(7, yAxis, 96, RowHeight)];//create label deliverydate
        lblDeliveryDate.text = @"Del Date";
        lblDeliveryDate.textColor=[UIColor blackColor];
        lblDeliveryDate.backgroundColor=[UIColor clearColor];
        [lblDeliveryDate setFont:[UIFont boldSystemFontOfSize:12.0]];
        lblDeliveryDate.textAlignment= NSTextAlignmentLeft;
        [viewTotal addSubview:lblDeliveryDate];
        
        //Dilevery button
        _btnDeliveryDate = [UIButton buttonWithType:UIButtonTypeRoundedRect];//del button
        [_btnDeliveryDate addTarget:self
                             action:@selector(getDate:)
                   forControlEvents:UIControlEventTouchUpInside];
        [_btnDeliveryDate setTitle:[arrValue objectAtIndex:5] forState:UIControlStateNormal];
        // _btnDeliveryDate.frame = CGRectMake(130, yAxis, 83, RowHeight);
        _btnDeliveryDate.frame = CGRectMake(50, yAxis, 260, RowHeight);
        [_btnDeliveryDate.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
        _btnDeliveryDate.titleLabel.textColor=[UIColor blueColor];
        _btnDeliveryDate.titleLabel.backgroundColor=[UIColor clearColor];
        _btnDeliveryDate.titleLabel.shadowColor=[UIColor whiteColor];
        _btnDeliveryDate.tag=2;
        [_btnDeliveryDate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [viewTotal addSubview:_btnDeliveryDate];
        
        yAxis=yAxis+RowHeight + 5;
        //Delevery Saperator
        
        UILabel *lbldelDateSepLine =  [[UILabel alloc] initWithFrame:CGRectMake(0,yAxis, 310, 1)];//create label deldate separtor below line
        lbldelDateSepLine.textColor=[UIColor blackColor];
        lbldelDateSepLine.backgroundColor=[UIColor blackColor];
        [lbldelDateSepLine setFont:[UIFont fontWithName:@"System" size:17]];
        lbldelDateSepLine.textAlignment= NSTextAlignmentLeft;
        [viewTotal addSubview:lbldelDateSepLine];
        
        //Delivery Row Ended
    }
    
    
    //Order Value View
    
    /*   self.viewOrdValue=[[UIView alloc]initWithFrame:CGRectMake(0,174,218,30)];//create view ordervalue
     self.viewOrdValue.tag=109;
     [self.viewOrdValue setBackgroundColor:[UIColor colorWithRed:(212/255.f) green:(157/255.f) blue:(115/255.f) alpha:1.0f]];
     
     self.lblTotalValue =  [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 161, 30)];//create label total value
     self.lblTotalValue.textColor=[UIColor blackColor];
     self.lblTotalValue.backgroundColor=[UIColor whiteColor];
     [self.lblTotalValue setFont:[UIFont boldSystemFontOfSize:14.0]];
     self.lblTotalValue.textAlignment= NSTextAlignmentRight;
     self.lblTotalValue.tag=105;
     self.lblTotalValue.text=[arrValue objectAtIndex:6];
     [self.viewOrdValue addSubview:self.lblTotalValue];
     
     UILabel *lblValue =  [[UILabel alloc] initWithFrame:CGRectMake(3, 1, 50, 28)];//create label value
     lblValue.text=@"Value";
     lblValue.textColor=[UIColor whiteColor];
     lblValue.backgroundColor=[UIColor clearColor];
     [lblValue setFont:[UIFont boldSystemFontOfSize:14.0]];
     lblValue.textAlignment= NSTextAlignmentCenter;
     [self.viewOrdValue addSubview:lblValue];
     
     UILabel *lblValueSeparatorLine =  [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 1, 38)];//create label value
     //lblValueSeparatorLine.text=@"Value";
     lblValueSeparatorLine.textColor=[UIColor blackColor];
     lblValueSeparatorLine.backgroundColor=[UIColor blackColor];
     [lblValueSeparatorLine setFont:[UIFont systemFontOfSize:17.0]];
     lblValueSeparatorLine.textAlignment= NSTextAlignmentLeft;
     [self.viewOrdValue addSubview:lblValueSeparatorLine];
     
     
     
     UIButton *buttonValue = [UIButton buttonWithType:UIButtonTypeRoundedRect];//del button
     [buttonValue addTarget:self
     action:@selector(showCostMargin:)
     forControlEvents:UIControlEventTouchUpInside];
     [buttonValue setTitle:@"" forState:UIControlStateNormal];
     buttonValue.frame = CGRectMake(0, -1, 220, 34);
     [buttonValue.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
     buttonValue.titleLabel.textColor=[UIColor blueColor];
     buttonValue.titleLabel.backgroundColor=[UIColor clearColor];
     buttonValue.titleLabel.shadowColor=[UIColor grayColor];
     buttonValue.tag=0;
     buttonValue.titleLabel.textAlignment=NSTextAlignmentRight;
     
     [self.viewOrdValue addSubview:buttonValue];
     [viewTotal addSubview:self.viewOrdValue];*/
    //Order Value View Ended
    
    
    //footerbrekDown=[TranFotterBreakDown ]
    footerbrekDown =  (TranFotterBreakDown *)[self.storyboard instantiateViewControllerWithIdentifier:@"TranFotterBreakDown"];
  

    return footerbrekDown.view;
}

-(void)showCostMargin:(NSString*)value
{
    if (!isValTapped)
        isValTapped=YES;
    else
        isValTapped=NO;
    profitiability=0;
    orderValue=0;

    
   /* double costPrice=[[_record valueForKey:@"cost_price"] doubleValue];
    double margin=((orderPrice-costPrice)/orderPrice)*100;
    double markup=((orderPrice-costPrice)/costPrice)*100;*/

    
   /* CostAndMarginViewController *costAndMarginViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"CostAndMarginViewController"];
    costAndMarginViewController.arrRecords=arrRows;
    costAndMarginViewController.strCurr=[Headrecorddata valueForKey:@"Curr"];
    [self.navigationController pushViewController:costAndMarginViewController animated:YES];*/

    for (NSInteger i=0; i<[arrRows count]; i++) {
        NSManagedObject *record=[arrRows objectAtIndex:i];
        double priceOrdered=[[record valueForKey:@"saleprice"] doubleValue];
        // [CommonHelper convertCurrencyFromCurrencyCode:strcurr Value:priceOrdered ToCurrencyCode:@"GBP" ExchangeRate:exchrate DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] UseExchangeRate:YES];
        
        NSInteger ordQty=[[record valueForKey:@"quantity"]integerValue];
        double costPrice=[[[record valueForKey:@"product"] valueForKey:@"cost_price"] doubleValue];
        //[CommonHelper convertCurrencyFromCurrencyCode:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] Value:costPrice ToCurrencyCode:strcurr ExchangeRate:exchrate DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] UseExchangeRate:YES];
        
        double ordval=(priceOrdered*ordQty);
        double profitability2=(priceOrdered-costPrice)*ordQty;
        double margin2=((profitability2/ordQty)/priceOrdered)*100;
        double markup2=((profitability2/ordQty)/costPrice)*100;
        profitiability+=profitability2;
        orderValue+=ordval;
        margin+=margin2;
        markup+=markup2;
    }
    
    orderCost = (orderValue-profitiability);
    margin=((orderValue-orderCost)/orderValue)*100;
    markup=((orderValue-orderCost)/orderCost)*100;
    
    //[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:orderCost DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"]];
    dicMain=[[NSDictionary alloc] initWithObjectsAndKeys:[CommonHelper getCurrencyFormatWithCurrency:[Headrecorddata valueForKey:@"Curr"] Value: orderCost],@"Order Cost:",[NSString stringWithFormat:@"%.02f %%",margin],@"Margin:",[NSString stringWithFormat:@"%.02f %%",markup],@"Mark Up:",[CommonHelper getCurrencyFormatWithCurrency:[Headrecorddata valueForKey:@"Curr"] Value: orderValue],@"Order Value:",[CommonHelper getCurrencyFormatWithCurrency:[Headrecorddata valueForKey:@"Curr"] Value: profitiability],@"Profitability:", nil];
    arrKey=[[NSArray alloc] initWithObjects:@"Order Cost:",@"Margin:",@"Mark Up:",@"Order Value:",@"Profitability:", nil];
    [_tblTransactionDetail reloadData];
}

-(IBAction)showProfitability:(UIButton*)sender
{
    BOOL isCostMargin=YES;
   //BOOL isCostMargin=[[UserConfigDelegate.dicUserInfo objectForKey:@"Show_Cost_Margin"] boolValue];
    BOOL isCustModeOn = NO;
    /*if (UserConfigDelegate.dicSettings!=nil)
        isCustModeOn=[[UserConfigDelegate.dicSettings objectForKey:@"customermode"]boolValue];*/
    if (isCostMargin && !isCustModeOn )
    {
        if (!isProfitability)
        {
            
            isProfitability=YES;
            sender.transform=CGAffineTransformMakeRotation(180.0*M_PI/180.0);
            [self loadTransactionInfo];
            //self.navigationItem.title=@"Profitability";
        }
        else if(isProfitability)
        {
            isProfitability=NO;
            sender.transform=CGAffineTransformMakeRotation(0.0*M_PI/180.0);
           [self loadTransactionInfo];
           // self.navigationItem.title=@"Transactions";
            
        }
    }
}

-(NSString*)retuenAddresswithoutnull:( NSManagedObject * )custData{
   /* NSString *Address=@"";
    if (!([[custData valueForKey:@"addr1"] isEqualToString:@""] || [[custData valueForKey:@"addr1"] length]==0)) {
        Address=[Address stringByAppendingFormat:@"%@\n",[custData valueForKey:@"addr1"]];
    }
    
    if (!([[custData valueForKey:@"addr2"] isEqualToString:@""] || [[custData valueForKey:@"addr2"] length]==0)) {
        Address=[Address stringByAppendingFormat:@"%@\n",[custData valueForKey:@"addr2"]];
    }
    if (!([[custData valueForKey:@"addr3"] isEqualToString:@""] || [[custData valueForKey:@"addr3"] length]==0)) {
        Address=[Address stringByAppendingFormat:@"%@\n",[custData valueForKey:@"addr3"]];
    }
    if (!([[custData valueForKey:@"addr4"] isEqualToString:@""] || [[custData valueForKey:@"addr4"] length]==0)) {
        Address=[Address stringByAppendingFormat:@"%@\n",[custData valueForKey:@"addr4"]];
    }
    
    if (!([[custData valueForKey:@"addr5"] isEqualToString:@""] || [[custData valueForKey:@"addr5"] length]==0)) {
        Address=[Address stringByAppendingFormat:@"%@\n",[custData valueForKey:@"addr5"]];
    }
    if (!([[custData valueForKey:@"postcode"] isEqualToString:@""] || [[custData valueForKey:@"postcode"] length]==0)) {
        Address=[Address stringByAppendingFormat:@"%@\n",[custData valueForKey:@"postcode"]];
    }*/
    
    NSString *Address = [custData valueForKey:@"addr1"];
    if([custData valueForKey:@"addr2"] && [[custData valueForKey:@"addr2"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"addr2"]];
        else
            Address = [custData valueForKey:@"addr2"];
    }
    if([custData valueForKey:@"addr3"] && [[custData valueForKey:@"addr3"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"addr3"]];
        else
            Address = [custData valueForKey:@"addr3"];
    }
    if([custData valueForKey:@"addr4"] && [[custData valueForKey:@"addr4"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"addr4"]];
        else
            Address = [custData valueForKey:@"addr4"];
    }
    if([custData valueForKey:@"postcode"] && [[custData valueForKey:@"postcode"] length]>0){
        if([Address length]>0)
            Address = [Address stringByAppendingFormat:@", %@",[custData valueForKey:@"postcode"]];
        else
            Address = [custData valueForKey:@"postcode"];
    }



  /*  NSMutableArray *arrFullAddress = [NSMutableArray array];
    NSArray *columnNames = [NSArray arrayWithObjects:[custData valueForKey:@"addr1"],[custData valueForKey:@"addr2"],[custData valueForKey:@"addr3"],[custData valueForKey:@"addr4"],[custData valueForKey:@"addr5"],nil];
    [arrFullAddress addObject:[@"\"" stringByAppendingString:[[columnNames componentsJoinedByString:@"\",\""] stringByAppendingString:@"\""]]];
    NSString *strTemp=[arrFullAddress lastObject];
    Address=[[strTemp stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@" "];*/
    return  Address;
    
    
    
//    if ([customerData valueForKey:@"addr1"] isEqualToString:@) {
//        <#statements#>
//    }
//    
//    [NSString stringWithFormat:@"%@ %@ %@ %@ %@",[customerData valueForKey:@"addr1"],[customerData valueForKey:@"addr2"],[customerData valueForKey:@"addr3"],[customerData valueForKey:@"addr4"],[customerData valueForKey:@"addr5"]];
//    
}


//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DebugLog(@"editingStyleForRowAtIndexPath");
//    if(_segmentedControl.selectedSegmentIndex==2){
//        return UITableViewCellEditingStyleNone;
//    }else
//        return UITableViewCellEditingStyleNone;
//   // return UITableViewCellEditingStyleNone;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isValTapped) {
        return NO;
    }
    
    if(_segmentedControl.selectedSegmentIndex==1 && _isEditing){
        return YES;
    }else
        return NO;
    // allow that row to swipe
}



//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}


//*******       Table View Editing style
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isValTapped) {
        return 0;
    }
    
    
    
    deleteObj=[arrRows objectAtIndex:indexPath.row];
    if(_segmentedControl.selectedSegmentIndex==1){
        UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                        {
                                            DebugLog(@"Action to perform with Button 1");
                                            
                                            [self TableCell_DeleteClicked];
                                        }];
        button.backgroundColor = [UIColor redColor]; //arbitrary color
        UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                         {
                                             DebugLog(@"Action to perform with Button2!");
                                             [self TableCell_EditClicked];
                                         }];
        button2.backgroundColor = [UIColor blackColor]; //arbitrary color
        
        
        return @[button,button2]; //array with all the buttons you want. 1,2,3, etc...
    }else
        return 0;
}

#pragma mark - editActionsForRowAtIndexPath
- (void) TableCell_EditClicked{
    DebugLog(@"TableCell_EditClicked");
    kAppDelegate.editTransactionProd=nil;
    //    [self performSegueWithIdentifier:@"editTransactionSegue" sender:nil];
    //    kAppDelegate.isEditTransaction =YES;
    //    kAppDelegate.customerInfo = [Headrecorddata valueForKey:@"customer"];
    //    kAppDelegate.transactionInfo = Headrecorddata;
    //    pvc.selectStockCode = [deleteObj valueForKey:@"productid"];
    kAppDelegate.editTransactionProd=deleteObj;
    kAppDelegate.isEditTransaction =YES;
    kAppDelegate.isEditTransactionItem =YES;
    UINavigationController * navController = (UINavigationController *) [[self.tabBarController viewControllers] objectAtIndex: 1] ;
    [navController popToRootViewControllerAnimated:NO];
    self.tabBarController.selectedIndex=1;
}

- (void) TableCell_DeleteClicked{
    DebugLog(@"TableCell_DeleteClicked");
    
    if ([arrRows count]==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"  message:@"Single Item will not delete."   delegate:self  cancelButtonTitle:@"Ok"  otherButtonTitles:nil];
        [alert setDelegate:self];
        [alert show];
    }else{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Item"  message:@"Do you want to delete this Item?"   delegate:self  cancelButtonTitle:@"Yes"  otherButtonTitles:@"No",nil];
    [alert setDelegate:self];
    [alert setTag:3];
    [alert show];
    }
}


#pragma mark - UITABLE Cell fotter Switches
-(void)Switch_click:(UISwitch *)sender{
    
    if([sender tag]  == 2)
    {
        if(sender.on){
            heldStatus=@"Y";
        }else{
            heldStatus=@"N";
        }
    }else if([sender tag]  == 1 ){
        
        if(sender.on){
            [self performSegueWithIdentifier:@"toEmailHOViewController" sender:self];
        }else{
           
            [Headrecorddata setValue:[NSNumber numberWithInteger:0] forKey:@"quotelayoutid"];
            [Headrecorddata setValue:@"N" forKey:@"emailrep"];
            [Headrecorddata setValue:@"N" forKey:@"Creditemail"];
            [Headrecorddata setValue:@"" forKey:@"emailaddress"];
            [Headrecorddata setValue:@"N" forKey:@"emailconfirm"];
        }
        
    }
    
}

#pragma mark -ENDED

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([alertView tag]==3 && buttonIndex == 0) {//Delete Transaction item
        
        if (deleteObj) {
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"productid ==%@",[deleteObj valueForKey:@"productid"]];
            NSArray  *tempArray = [[[Headrecorddata valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate];
//Delete all oLine with this product code
            [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [kAppDelegate.managedObjectContext deleteObject:obj];
            }];
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                DebugLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            deleteObj=nil;
            
            [self loadTransactionInfo];
        }
        
    }if ([alertView tag]==4 && buttonIndex==0){ // cancel transaction statement
        DebugLog(@"Cancel transcaction");
        
        [self save_currentTransaction:0];
        
    }
}

-(IBAction)btnAddNewDelAdd_SearchDelAdd_CallBack_DeliveryDateClicked:(UIButton *)sender
{
    if (sender.tag==3 || sender.tag==4) {
        DatePickerViewController *datePickerViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"DatePickerViewController"];

        if (sender.tag==3) {
            datePickerViewController.selectedDate=[Headrecorddata valueForKey:@"nextcall_date"];
            datePickerViewController.title=@"Call back date";
            datePickerViewController.clearSelectionEnabled=YES;
            datePickerViewController.isCallBack=YES;
            selectedDateOption = 0;
        }
        else
        {
            datePickerViewController.selectedDate=[Headrecorddata valueForKey:@"required_bydate"];
            datePickerViewController.title=@"Delivery date";
            datePickerViewController.isCallBack=YES;
            selectedDateOption = 1;
        }
        datePickerViewController.isDateRange=NO;
        datePickerViewController.delegate=self;
        [self.navigationController pushViewController: datePickerViewController animated:YES];
        
    }
    else if (sender.tag==1)
    {
        
        CustomerNewDeliveryAddressViewController *customerNewDeliveryAddressViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"CustomerNewDeliveryAddress"];
        customerNewDeliveryAddressViewController.delegate=self;
        customerNewDeliveryAddressViewController.customerInfo = [Headrecorddata valueForKey:@"customer"];
        customerNewDeliveryAddressViewController.editStatus=NO;
        // [customerNewDelivery currentPageProductDetail:_productDetail];
        [self.navigationController pushViewController: customerNewDeliveryAddressViewController animated:YES];
    }
    else
    {
        CustomerDeliveryAddressViewController *customerDeliveryAddressViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"CustomerDeliveryAddress"];
        customerDeliveryAddressViewController.selectedDeliveryAddress=selectedDeliveryAddress;
        customerDeliveryAddressViewController.customerInfo = [Headrecorddata valueForKey:@"customer"];
        customerDeliveryAddressViewController.isFromTransaction=YES;
        customerDeliveryAddressViewController.isFromProduct=NO;
        customerDeliveryAddressViewController.isFromCustomer=NO;
        customerDeliveryAddressViewController.delegate=self;
        [self.navigationController pushViewController: customerDeliveryAddressViewController animated:YES];
        
        
    }
}
-(IBAction)getDate:(UIButton *)sender
{
    DatePickerViewController *datePickerViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
    datePickerViewController.selectedDate=[Headrecorddata valueForKey:@"required_bydate"];
    datePickerViewController.title=@"Delivery date";
    datePickerViewController.isCallBack=YES;
    selectedDateOption = 1;
    
    datePickerViewController.isDateRange=NO;
    datePickerViewController.delegate=self;
    [self.navigationController pushViewController: datePickerViewController animated:YES];
    
    
}

#pragma mark - CustomDatePickerViewController Delegate
-(void)finishedSelectionWithDate:(NSDate *)seldate{
    if(selectedDateOption==0)
        [Headrecorddata setValue:seldate forKey:@"nextcall_date"];
    else
        [Headrecorddata setValue:seldate forKey:@"required_bydate"];
    
    NSError *error;
    if (![kAppDelegate.managedObjectContext save:&error]) {
        DebugLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
    [_tblTransactionDetail reloadData];
}

#pragma mark - CustomerDeliveryAddressViewController Delegate
-(void)finishedDeliveryDoneSelection:(NSMutableArray*)selAcc_Ref{
    TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if (selAcc_Ref.count>0) {
      /*  dispatch_async(dispatch_get_main_queue(), ^{
            NSString *strDelID_Add=[selAcc_Ref objectAtIndex:0];
            NSArray *arrDelID_Add=[strDelID_Add componentsSeparatedByString:@"_"];
            cell.lblDeliveryID.text=[NSString stringWithFormat:@"%@",[arrDelID_Add objectAtIndex:0]];
            selectedDeliveryAddress=cell.lblDeliveryID.text;
            cell.txtCustomerDeliveryAddress.text=[NSString stringWithFormat:@"%@",[arrDelID_Add objectAtIndex:1]];
        });*/
    
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            NSString *strDelID_Add=[selAcc_Ref objectAtIndex:0];
            NSArray *arrDelID_Add=[strDelID_Add componentsSeparatedByString:@"_"];

            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                cell.lblDeliveryID.text=[NSString stringWithFormat:@"%@",[arrDelID_Add objectAtIndex:0]];
                selectedDeliveryAddress=cell.lblDeliveryID.text;
                cell.txtCustomerDeliveryAddress.text=[NSString stringWithFormat:@"%@",[arrDelID_Add objectAtIndex:1]];
            });
        });
    }
}
#pragma mark - AddNewDeliveryAddressViewController Delegate
-(void)finishNewDeliverySaveDone{
    
    // [self fetchAnEntity];
    // [self.custDeliveryAddressTableView reloadData];
}
-(void)finishedDeliverySaveDone:(NSMutableArray *)selAcc_Ref
{
    TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if (selAcc_Ref.count>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *strDelID_Add=[selAcc_Ref objectAtIndex:0];
            NSArray *arrDelID_Add=[strDelID_Add componentsSeparatedByString:@"_"];
            cell.lblDeliveryID.text=[NSString stringWithFormat:@"%@",[arrDelID_Add objectAtIndex:0]];
            selectedDeliveryAddress=cell.lblDeliveryID.text;
            cell.txtCustomerDeliveryAddress.text=[NSString stringWithFormat:@"%@",[arrDelID_Add objectAtIndex:1]];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(TransactionDetailTableViewItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *record = [arrRows objectAtIndex:indexPath.row];
   // NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.hidden = NO;
    NSString *strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[record valueForKey:@"productid"]] lowercaseString]] stringByAppendingString:@".jpg"];
    [cell.imgProductImage setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    cell.lblDeliveryDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"requireddate"]];
    
    //Add currency Symbol
    NSString *currCode=[Headrecorddata valueForKey:@"Curr"];
    
    cell.lblPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value: [[NSString stringWithFormat:@"%0.2f",[[record valueForKey:@"saleprice"] doubleValue]] doubleValue]];
    cell.lblProductCode.text=[record valueForKey:@"productid"];//Stock_code
    cell.lblItemQuantity.text=[NSString stringWithFormat:@"%@",[record valueForKey:@"quantity"]];
    
   /* if ([[record valueForKey:@"count"] integerValue]>1) {
        cell.lblDeliveryID.text=@"Multiple";
    }else*/
        cell.lblDeliveryID.text=[record valueForKey:@"deliveryaddresscode"];

    if ([[record valueForKey:@"Count"] integerValue]>1){
        cell.arrowWithLayoutConstraint.constant=17.0;
        [cell.arrowImageView setHidden:NO];
    }else{
        cell.arrowWithLayoutConstraint.constant=0.0;
        [cell.arrowImageView setHidden:YES];
    }
    
    cell.lblOrderType.text=[record valueForKey:@"orderlinetype"];
    //[cell.lblItemQuantity sizeToFit];
    cell.lblItemValue.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value: [[NSString stringWithFormat:@"%0.2f",[[record valueForKey:@"linetotal"] doubleValue]] doubleValue]];
    //***** productInfo
    if ([record valueForKey:@"product"]) {
        cell.lblProductCDescription.text=[[record valueForKey:@"product"] valueForKey:@"gdescription"] ;
    }
    else
        cell.lblProductCDescription.text = nil;
}


- (void)configureMarginCell:(TransactionDetailTableViewCostAndMarginItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *record = [arrRows objectAtIndex:indexPath.row];
    // NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.hidden = NO;
    NSString *strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[record valueForKey:@"productid"]] lowercaseString]] stringByAppendingString:@".jpg"];
    [cell.imgProductImage setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    //Add currency Symbol
    NSString *currCode=[Headrecorddata valueForKey:@"Curr"];

    double priceOrdered=[[record valueForKey:@"saleprice"] doubleValue];
    // [CommonHelper convertCurrencyFromCurrencyCode:strcurr Value:priceOrdered ToCurrencyCode:@"GBP" ExchangeRate:exchrate DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] UseExchangeRate:YES];
    
    NSInteger ordQty=[[record valueForKey:@"quantity"]integerValue];
    double costPrice=[[[record valueForKey:@"product"] valueForKey:@"cost_price"] doubleValue];
    //[CommonHelper convertCurrencyFromCurrencyCode:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] Value:costPrice ToCurrencyCode:strcurr ExchangeRate:exchrate DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] UseExchangeRate:YES];
    
    
    //double ordval=(priceOrdered*ordQty);
    double profitability2=(priceOrdered-costPrice)*ordQty;
    double margin2=((profitability2/ordQty)/priceOrdered)*100;
    double markup2=((profitability2/ordQty)/costPrice)*100;

    
    
    cell.lblItemCost.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value: [[NSString stringWithFormat:@"%.02f",costPrice] doubleValue]];
    cell.lblMargin.text=[NSString stringWithFormat:@"%.02f",margin2];
    cell.lblMarkUp.text=[NSString stringWithFormat:@"%.02f",markup2 ];
    cell.lblProfitabilty.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value: [[NSString stringWithFormat:@"%.02f",profitability2] doubleValue]];
    
    
    cell.lblPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value: [[NSString stringWithFormat:@"%0.2f",[[record valueForKey:@"saleprice"] doubleValue]] doubleValue]];
    cell.lblProductCode.text=[record valueForKey:@"productid"];//Stock_code
    cell.lblItemQuantity.text=[NSString stringWithFormat:@"%@",[record valueForKey:@"quantity"]];
    
    /* if ([[record valueForKey:@"count"] integerValue]>1) {
     cell.lblDeliveryID.text=@"Multiple";
     }else*/
    
    
    if ([[record valueForKey:@"Count"] integerValue]>1){
        cell.arrowWithLayoutConstraint.constant=17.0;
        [cell.arrowImageView setHidden:NO];
    }else{
        cell.arrowWithLayoutConstraint.constant=0.0;
        [cell.arrowImageView setHidden:YES];
    }
    
    cell.lblOrderType.text=[record valueForKey:@"orderlinetype"];
    //[cell.lblItemQuantity sizeToFit];
    cell.lblItemValue.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value: [[NSString stringWithFormat:@"%0.2f",[[record valueForKey:@"linetotal"] doubleValue]] doubleValue]];
    //***** productInfo
    if ([record valueForKey:@"product"]) {
        cell.lblProductCDescription.text=[[record valueForKey:@"product"] valueForKey:@"gdescription"] ;
    }
    else
        cell.lblProductCDescription.text = nil;
}
- (void)configureCostAndMarginCell:(CostAndMarginTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.lblCaption.text=[arrKey objectAtIndex:indexPath.row] ;
    cell.lblValue.text=[dicMain valueForKey:[arrKey objectAtIndex:indexPath.row]];
}


#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[[arrRows objectAtIndex:indexPath.row] objectForKey:@"Count"] integerValue]>1) {
        selIndexPath=indexPath;
        [self performSegueWithIdentifier:@"toMultipleDelAdd" sender:self];
    }else if (_segmentedControl.selectedSegmentIndex==2 && featureDict && [[featureDict valueForKey:@"ordernotesenabled"] boolValue] && _isEditing && indexPath.row==0){
       
        [self performSegueWithIdentifier:@"toTransactionNote" sender:self];
    }
}





//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [_tblTransactionDetail setContentOffset:CGPointMake(0.0, 0.0)];
//}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self loadTransactionItems];
}

-(void)loadTransactionItems{
   
    arrRows =[[NSMutableArray alloc]init];
    NSArray *tempArray=nil;
    NSPredicate *filterPredicate;
    NSString *stockQty=@"";
    if(![[pricingConfigDict objectForKey:@"usefieldtodefineoutofstock"] isEqual:[NSNull null]])
        stockQty=[pricingConfigDict objectForKey:@"usefieldtodefineoutofstock"];
    
    if ([self.tranDetailSearchBar.text length] == 0){
        
         if (page==1 && [stockQty length]>0)
            filterPredicate = [NSPredicate predicateWithFormat:@"(product.%@ > %i) and (orderid = %@)",stockQty,0,orderNumber];
        else if (page==2 && [stockQty length]>0)
            filterPredicate = [NSPredicate predicateWithFormat:@"(product.%@ <= %i) and (orderid = %@)",stockQty,0,orderNumber];
        else
            filterPredicate = [NSPredicate predicateWithFormat:@"(orderid = %@)",orderNumber];
        
        
        tempArray = [[[Headrecorddata valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:filterPredicate];
    }else
    {
        if (page==0)
            filterPredicate = [NSPredicate predicateWithFormat:@"(productid CONTAINS %@ || product.gdescription CONTAINS %@) and (orderid = %@)",self.tranDetailSearchBar.text, self.tranDetailSearchBar.text,orderNumber];
        else if (page==1)
            filterPredicate = [NSPredicate predicateWithFormat:@"(productid CONTAINS %@ || product.gdescription CONTAINS %@) and (product.%@ > %i)and (orderid = %@)",self.tranDetailSearchBar.text, self.tranDetailSearchBar.text,stockQty,0,orderNumber];
        else if (page==2)
            filterPredicate = [NSPredicate predicateWithFormat:@"(productid CONTAINS %@ || product.gdescription CONTAINS %@)and (product.%@ <= %i) and (orderid = %@)",self.tranDetailSearchBar.text, self.tranDetailSearchBar.text,stockQty,0,orderNumber];
        
        tempArray = [[[Headrecorddata valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:filterPredicate];
    }
    
    
    
    NSMutableArray *iLineArray=[[NSMutableArray alloc]init];
    
    NSArray *distinctOlines = [tempArray valueForKeyPath:@"@distinctUnionOfObjects.productid"];
    for(NSString *pIdAsString in distinctOlines)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(productid == %@)", pIdAsString];
        NSArray *arrayofPid = [tempArray  filteredArrayUsingPredicate: predicate];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"productid"] forKey:@"productid"];
        if ([arrayofPid count]>1) {
            [dict setValue:@"Multiple" forKey:@"deliveryaddresscode"];
        }else
            [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"deliveryaddresscode"] forKey:@"deliveryaddresscode"];
        
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"saleprice"] forKey:@"saleprice"];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"orderlinetype"] forKey:@"orderlinetype"];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"requireddate"] forKey:@"requireddate"];
       // [dict setValue:@"" forKey:@"productid"];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"product"] forKey:@"product"];
       
        [dict setValue:[arrayofPid valueForKeyPath:@"@sum.quantity"] forKey:@"quantity"];
        [dict setValue:[arrayofPid valueForKeyPath:@"@sum.linetotal"] forKey:@"linetotal"];

        
        [dict setObject:[NSNumber numberWithInteger:[arrayofPid count]] forKey:@"Count"];
        [dict setObject:arrayofPid forKey:@"Arrays"];
        
        
        [ iLineArray addObject:dict];
    }
    
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"requireddate"   ascending:NO] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    arrRows =[NSMutableArray arrayWithArray: [iLineArray sortedArrayUsingDescriptors:sortDescriptors]];
    
   
    
    [[self tblTransactionDetail] reloadData];
    
   // id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    
    [_segmentedControl setTitle:[NSString stringWithFormat:@"Items(%li)",(long)[arrRows count]] forSegmentAtIndex:1];
   // [_segmentedControl setTitle:[NSString stringWithFormat:@"Items(%li)",(long)[sectionInfo numberOfObjects]] forSegmentAtIndex:1];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toTransactionNote"]) {
        TransactionNotesViewController *noteObj = segue.destinationViewController;
        [noteObj setDelegate:self];
        if([orderType isEqualToString:@"C"])
            [noteObj setNoteType:orderType];
        else
            [noteObj setNoteType:@"O"];
        
        
        
    }else if ([segue.identifier isEqualToString:@"toOrderTypeView"]) {
        FilterViewController *ordObj = segue.destinationViewController;
        [ordObj setDelegate:self];
        [ordObj setFilterStatus:1];
        if ([[Headrecorddata valueForKey:@"orderlinesnew"] count]>0) {
            [ordObj setCallLogStatus:YES];
        }else
            [ordObj setCallLogStatus:NO];
        
        [ordObj setRetval:orderType];
        
    }else if ([segue.identifier isEqualToString:@"toNewDeliverAdd"]) {
        CustomerNewDeliveryAddressViewController *customerNewDelivery = segue.destinationViewController;
        customerNewDelivery.delegate=self;
        customerNewDelivery.editStatus=NO;
        // [customerNewDelivery setTransactionStatus:1];
        
    }else if ([segue.identifier isEqualToString:@"toAddSignature"]) {
        SignatureViewController *signObj = segue.destinationViewController;
        signObj.ordnumber=orderNumber;
    }else if ([segue.identifier isEqualToString:@"toEmailHOViewController"]){
        EmailHOViewController *obj=segue.destinationViewController;
        [obj setOHeadInfo:Headrecorddata];
    }
    else if([segue.identifier isEqualToString:@"editTransactionSegue"]){
        ProductController *pvc = segue.destinationViewController;
        pvc.title=@"All Products";
        pvc.customerInfo = [Headrecorddata valueForKey:@"customer"];
        pvc.transactionInfo = Headrecorddata;
        pvc.selectStockCode = [deleteObj valueForKey:@"productid"];
    }else if([segue.identifier isEqualToString:@"toMultipleDelAdd"])
    {
       // NSManagedObject *record = [arrRows objectAtIndex:selIndexPath.row];
        TransactionDelivAddViewController *obj = segue.destinationViewController;
        obj.productId=[[arrRows objectAtIndex:selIndexPath.row] objectForKey:@"productid"];
       // obj.orderId=orderNumber;
        obj.multiDeliveryAddArray=[[arrRows objectAtIndex:selIndexPath.row] objectForKey:@"Arrays"];
    }
    else if ([segue.identifier isEqualToString:@"toMailOptionsViewController"]){
        MailOptionsViewController *mvc=segue.destinationViewController;
        mvc.Headrecorddata=self.Headrecorddata;
        mvc.selectedOption=selectedOption;
    }
    
}



-(void )refreshOHeaddata:(NSNotification *) notification{
    Headrecorddata=nil;
    Headrecorddata=[self reloadHeaderNew:orderNumber];
    
    orderType=[Headrecorddata valueForKey:@"ordtype"];
    [_tblTransactionDetail reloadData];
}

-(NSManagedObject*)reloadHeaderNew :(NSString*) orderId{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@ ",orderId];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return [resultsSeq lastObject];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
   // [_btnOverlay setHidden:NO];
//    if (textField) {
//        <#statements#>
//    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if ([textField isEqual:cell.txtFieldCustomerRefrence]){
        purchaseordernumber=cell.txtFieldCustomerRefrence.text;
    }else if ([textField isEqual:cell.txtFieldUserID])
        employeeid=cell.txtFieldUserID.text;
    
}


/*- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if ([textField isEqual:cell.txtFieldCustomerRefrence]){
        purchaseordernumber=cell.txtFieldCustomerRefrence.text;
    }else if ([textField isEqual:cell.txtFieldUserID])
        employeeid=cell.txtFieldUserID.text;

    
    return YES;
}*/




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //[_btnOverlay setHidden:YES];
    return NO;
}




-(void)textViewDidBeginEditing:(UITextView *)textView{
    [_btnOverlay setHidden:NO];
}

- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
    [_btnOverlay setHidden:YES];
}


//EmailToHeadOffice Delegate
-(void)saveClickWithOption:(NSDictionary*)selDictionary{
    
     DebugLog(@"saveClickWithOption EmailToHeadOffice");
}

-(void)cancelClickWithOption{
    
    DebugLog(@"cancelClickWithOption EmailToHeadOffice");
}


//navigation back button click
-(BOOL) navigationShouldPopOnBackButton
{
    if (kAppDelegate.isEditTransaction) {
        kAppDelegate.isEditTransaction =NO;
        kAppDelegate.customerInfo = nil;
        kAppDelegate.transactionInfo = nil;
        kAppDelegate.editTransactionProd=nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
}



#pragma  mark -TransactionNotesViewControllerDelegate
-(void)finishedNoteSelectionWithOption:(NSDictionary*)selDictionary{
    selectedNoteDict=(NSMutableDictionary* )selDictionary ;
    
    TransactionDetailTableViewFooterCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if (selDictionary){
        if ([strNote length]==0) {
            strNote=[NSString stringWithFormat:@"%@",[selDictionary valueForKey:@"Note"]];
        }else
            strNote=[strNote stringByAppendingString:[NSString stringWithFormat:@"\n%@",[selDictionary valueForKey:@"Note"]]];
    }
    cell.txtViewNotes.text=strNote;
}

#pragma mark - TransactionFilter
-(void)finishedTransactionFilterSelectionWithSingleOption:(NSDictionary*)selDic{
    //selectedFilterDic=(NSMutableDictionary* )selDictionary;
    TransactionDetailTableViewHeaderCell *cell = [_tblTransactionDetail cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:0 inSection:0]];
    if (selDic){
        cell.lblOrderType.text=[selDic valueForKey:@"label"];//[NSString stringWithFormat:@"%@",selstr];
        orderType=[selDic valueForKey:@"code"];
        _orderTypeChangeSts=YES;
        
        
        NSArray  *tempArray = [[Headrecorddata valueForKey:@"orderlinesnew"] allObjects];
        [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (_orderTypeChangeSts)
                [obj setValue:orderType forKey:@"orderlinetype"];
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }];
        
        
        
    }
    
}

@end
