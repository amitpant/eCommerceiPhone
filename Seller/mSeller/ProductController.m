//
//  ProductController.m
//  mSeller
//
//  Created by Ashish Pant on 9/14/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductController.h"
#import "CatalogueFilterViewController.h"
#import "CustomerController.h"
#import "OrderHelper.h"
#import "quartzview.h"
#import "ScannerViewController.h"
#import "CustomerDetailMultipleViewController.h"
#import "ScannerViewController.h"
#import "ProductMultipleSegmentDetailViewController.h"
#import "Constants.h"

CGSize keyboardSize;

@interface ProductController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,CatalogueFilterViewControllerDelegate,ProductTVCellDelegate,ScannerViewControllerDelgate>
{
    NSInteger filterIndex;
    NSString* strTitle;
    NSString* strTitle2;
    NSString* strCurrentTitle;
    NSString *sortByFieldName;
    NSDictionary* featureDict;//   fetch feature
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary* priceConfigDict;//   fetch PriceConfig
    NSDictionary* userConfigDic;
    NSString *stractualpath;
    CGFloat distance;
    
    BOOL SORTDes;
//    BOOL LoadFirstTime;
    NSArray *PromotionalCodes_Filter;
    NSTimer *timer;
    
    __weak NSManagedObject *deleteObj;
    __weak NSIndexPath *delIndexPath;

    NSMutableDictionary *filterDic;

    //Filtering
    NSArray *Mytop20Array;

    NSMutableArray *compoundFilterArr;
    //    BOOL isNextBtnClicked;//added by Ashish
    NSString *oLinePackType;

    BOOL isScrollBeginDragging;

    ScannerViewController *scanViewController;
   
    BOOL isScanning;

    CGFloat packBtnContainerWidth;

    UIView *overLaySearchBar;
    BOOL blTappedForKeyBoard;
    BOOL blShowKeyboard;
    int srcTxtLen;//highlight serach bar text
    BOOL PastSts;//highlight serach bar text
    NSString *PastString;//highlight serach bar text
    
    BOOL barCodeSearchSts;
}

@property(nonatomic,weak)IBOutlet UITableView *tblProduct;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,strong)NSArray *selectedGroupFilters;
@property (nonatomic,strong)NSArray *selectedFilters;
@property (nonatomic,strong)NSMutableDictionary *selectedStockFilter;
@property (nonatomic,strong)UIButton *btnCustomer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabletopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *viewScanning;
@property (weak, nonatomic) IBOutlet UIButton *btnScanNow;
@property (weak, nonatomic) IBOutlet UIButton *btnOverlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonScanner;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonFilters;

- (IBAction)scanButtonClick:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end

@implementation ProductController

- (void)viewDidLoad {
    [super viewDidLoad];

    barCodeSearchSts=NO;
    // Do any additional setup after loading the view.
    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];
    strTitle = self.title;

    strTitle2= self.title;
    
    NSArray *stockArr = [kUserDefaults  objectForKey:@"StockBandArray"];
    if ([stockArr count]==0) {
        NSMutableArray *stockbandArr=[self loadStockbandList];
        [kUserDefaults  setObject:stockbandArr forKey:@"StockBandArray"];
        [kUserDefaults  synchronize];
    }

    
//    dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"dd/MM/yy"];
//
//    timeFormat = [[NSDateFormatter alloc] init];
//    [timeFormat setDateFormat:@"HH:mm:ss"];

    [self createFilterDic:@"filter"];
    [self createFilterDic:@"group"];

    //***asc/des
    SORTDes=YES;
   // LoadFirstTime=NO;
    //filter  array
    compoundFilterArr=[[NSMutableArray alloc]init];

    filterDic =[[NSMutableDictionary alloc]init];
    if(_Group1Codes && [_Group1Codes count]>0)
        [filterDic  setObject:_Group1Codes forKey:@"category"];
    if(_Group2Codes && [_Group2Codes count]>0)
        [filterDic  setObject:_Group2Codes forKey:@"sub-cat"];
    if(_PromotionalCodes && [_PromotionalCodes count]>0)
        [filterDic  setObject:_PromotionalCodes forKey:@"promotionalcode"];


   // _scanViewTopConstraint.constant =  0;
    _tabletopLayoutConstraint.constant = 0;
    
   [_tblProduct setScrollEnabled:YES];
    [kUserDefaults  setObject:[NSNumber numberWithBool:NO] forKey:@"isscanningactivated"];


    UIEdgeInsets inset = _tblProduct.separatorInset;
    inset.left = 5;
    _tblProduct.separatorInset = inset;



    //    [self performSelector:@selector(hideKeybord) withObject:nil afterDelay:0.0];

    //
    //   [_searchBar becomeFirstResponder];

    //    [kNSNotificationCenter addObserver:self
    //                                             selector:@selector(keyboardDidHide:)
    //                                                 name:UIKeyboardDidHideNotification
    //                                               object:nil];
    //    [kNSNotificationCenter addObserver:self
    //                                             selector:@selector(keyboardDidShow:)
    //                                                 name:UIKeyboardDidShowNotification
    //                                               object:nil];



    //   [self keyboardDidHide:nil];
    overLaySearchBar = [[UIView alloc] initWithFrame:CGRectMake(40, 9, 245, 26)];
    overLaySearchBar.backgroundColor = [UIColor clearColor];


    // to make customer selection invisible by default - code added by Satish on 26 Feb 2016
  /*  UIEdgeInsets contentInset = _tblProduct.contentInset;
    contentInset.top = 40;
    _tblProduct.contentInset = contentInset;

    _tblProduct.contentOffset = CGPointMake(0, 0);

    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
    viewHeader.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.9];
    _btnCustomer = [UIButton buttonWithType:UIButtonTypeSystem];
    _btnCustomer.frame = CGRectMake(5, 0, viewHeader.frame.size.width-10, 40);
    [_btnCustomer.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [_btnCustomer setTitle:@"[SELECT CUSTOMER]" forState:UIControlStateNormal];
    [_btnCustomer addTarget:self action:@selector(doSelectCustomer:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:_btnCustomer];
    [_tblProduct addSubview:viewHeader];*/
    // end of code by Satish
    
    //For reload  product data when header discount added
    [kNSNotificationCenter addObserver:self  selector:@selector(reloadproductData:) name:kReloadProduct object:nil];
    
    
    if ([kUserDefaults  integerForKey:@"NumericKeyboard"] == 2) {
        _searchBar.keyboardType=UIKeyboardTypeNumberPad;
    }else
        _searchBar.keyboardType=UIKeyboardTypeDefault;
    
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshCompanydata:) name:kCompanySwitch object:nil];
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     _btnScanNow.hidden = YES;
    
    if([kUserDefaults  integerForKey:@"NumericKeyboard"]==2) {
        [self numericKeyboardOn];
    }else
        _searchBar.keyboardType=UIKeyboardTypeDefault;
    
    if(self.navigationController.navigationBarHidden)
        self.navigationController.navigationBarHidden = NO;

    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];

    self.title  = strCurrentTitle;
    [self loadCustomerInfo];

    [self loadArraysData];

    [self performSelector:@selector(loadScanningView) withObject:nil afterDelay:0.5];

    [kNSNotificationCenter addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [kNSNotificationCenter addObserver:self selector:@selector(hideNotifier:) name:UIKeyboardWillHideNotification object:nil];
    
    
    UITapGestureRecognizer *oneFingerTwoTaps =   [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeKeyBoard:)];
    [oneFingerTwoTaps setNumberOfTapsRequired:1];
    [oneFingerTwoTaps setNumberOfTouchesRequired:1];
    [overLaySearchBar addGestureRecognizer:oneFingerTwoTaps];
    [self searcBecomeFirst];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //When come from edit screen selected row is top
    //if ([_selectStockCode length]>0 )
    
    if (kAppDelegate.isEditTransactionItem)
    {
        _selectStockCode=[kAppDelegate.editTransactionProd valueForKey:@"productid"];
        kAppDelegate.editTransactionProd=nil;
       
//        if (kAppDelegate.isEditTransactionItem) {
            NSArray *filteredArray=[[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"stock_code==%@",_selectStockCode]];
            NSIndexPath* selIndexPath = [_fetchedResultsController indexPathForObject:[filteredArray lastObject]];
            
            [self  loadEditIteamProduct:selIndexPath.row];
//        }
        
     /*   UIEdgeInsets contentInset = _tblProduct.contentInset;
        contentInset.top = 0;
        _tblProduct.contentInset = contentInset;

        
        NSArray *filteredArray=[[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"stock_code==%@",_selectStockCode]];
        NSIndexPath* selIndexPath = [_fetchedResultsController indexPathForObject:[filteredArray lastObject]];
        if(selIndexPath)
            [_tblProduct selectRowAtIndexPath:selIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];*/
    }
    
    if([kUserDefaults  integerForKey:@"NumericKeyboard"]==2) {
        [self numericKeyboardOn];
    }else
        _searchBar.keyboardType=UIKeyboardTypeDefault;
}

-(void)numericKeyboardOn{
    _searchBar.keyboardType=UIKeyboardTypeNumberPad;
}

-(void) searcBecomeFirst
{
    if(![_searchBar isFirstResponder])
        [_searchBar becomeFirstResponder];
    
}

//UIKeyboardDidShowNotification called
-(void)hideKeyboard:(NSNotification *)notification{
    
    for(UIWindow *window in [[UIApplication sharedApplication] windows])
        if([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")])
            for(UIView* subView in window.subviews)
                if([subView isKindOfClass:NSClassFromString(@"UIInputSetHostView")])
                    for(UIView* subsubView in subView.subviews)
                    {
                        if([_searchBar isFirstResponder]){
                            if(!blTappedForKeyBoard){
                                if (!blShowKeyboard) {
                                    
                                    CGRect frame = subsubView.frame;
                                    
                                    if(frame.size.height ==216)
                                        frame.origin.y = frame.origin.y + 352;
                                    
                                    subsubView.frame = frame;
                                    [_searchBar addSubview:overLaySearchBar];
                                }
                            }
                            else{
                                blTappedForKeyBoard = NO;
                            }
                            
                        }
                        
                        else
                            [self showKeyBoard];
                    }
    

}
//UIKeyboardWillHideNotification called
-(void)hideNotifier:(NSNotification *)notification {
    if([_searchBar isFirstResponder]){
        if(![overLaySearchBar superview])
            [_searchBar addSubview:overLaySearchBar];
    }
    blShowKeyboard=NO;
}

-(void)showKeyBoard{
    for(UIWindow *window in [[UIApplication sharedApplication] windows])
        if([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")])
            for(UIView* subView in window.subviews)
                if([subView isKindOfClass:NSClassFromString(@"UIInputSetHostView")])
                    for(UIView* subsubView in subView.subviews)
                    {
                        CGRect frame = subsubView.frame;
                        
                        if((frame.size.height ==216 && frame.origin.y==704)|| (frame.size.height==216 && frame.origin.y==803))
                            frame.origin.y = frame.origin.y - 352;
                        subsubView.frame = frame;
                        if(blTappedForKeyBoard)
                            if([overLaySearchBar superview])
                                [overLaySearchBar removeFromSuperview];
                    }
}

-(void) activeKeyBoard:(UITapGestureRecognizer*)tap
{
    [self searcBecomeFirst];
    blTappedForKeyBoard = YES;
    blShowKeyboard=YES;
    
    [self showKeyBoard];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
    [kNSNotificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [kNSNotificationCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    if([_searchBar isFirstResponder])
        [_searchBar resignFirstResponder];

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

    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];

    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];


    userConfigDic =nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        userConfigDic = [dic objectForKey:@"data"];
    

    //  Mahendra fetch CompanyConfig **SORT DESCRIPTER sortproductsby
    if(companyConfigDict){
        NSString *sortCode = @"A";
        
        if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortproductsby"] isEqual:[NSNull null]])
            sortCode = [[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortproductsby"];
       
        if ([sortCode length]>0 && [sortCode isEqualToString:@"A"])
        {
            sortByFieldName=@"gdescription";
        }
        else if([sortCode length]>0 && [sortCode isEqualToString:@"C"])
        {
            sortByFieldName=@"stock_code";

        }
        else
        {
            sortByFieldName=@"itemsequence,stock_code";
        }
    }
    else
        sortByFieldName=@"itemsequence,stock_code";
    //End
    [[self tblProduct] reloadData];
}

-(void)loadScanningView{
    if([[kUserDefaults  objectForKey:@"isscanningactivated"] boolValue]){
        _btnScanNow.hidden = NO;
    }
    else
        _btnScanNow.hidden = YES;

    //_scanViewTopConstraint.constant = 0;
    _tabletopLayoutConstraint.constant = 0;
    
    [_tblProduct setScrollEnabled:YES];
    if(scanViewController){
        [scanViewController.view removeFromSuperview];
        scanViewController = nil;
    }
}

- (void)createFilterDic :(NSString *)filter{

    NSArray *colorArr = [[NSArray alloc]initWithObjects:
                         [UIColor colorWithRed:66/255.0 green:192/255.0 blue:4/255.0 alpha:1.0],
                         [UIColor colorWithRed:243/255.0 green:112/255.0 blue:163/255.0 alpha:1.0],
                         [UIColor cyanColor],
                         [UIColor colorWithRed:184/255.0 green:134/255.0 blue:11/255.0 alpha:1.0],
                         [UIColor colorWithRed:255/255.0 green:20/255.0 blue:147/255.0 alpha:1.0],
                         [UIColor colorWithRed:240/255.0 green:128/255.0 blue:128/255.0 alpha:1.0],
                         [UIColor colorWithRed:218/255.0 green:112/255.0 blue:214/255.0 alpha:1.0],
                         [UIColor colorWithRed:132/255.0 green:112/255.0 blue:255/255.0 alpha:1.0],

                         [UIColor colorWithRed:111.0/255.0 green:62.0/255.0 blue:69.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:84/255.0 green:145/255.0 blue:212/255.0 alpha:1.0],
                         [UIColor colorWithRed:83/255.0 green:187/255.0 blue:50/255.0 alpha:1.0],
                         [UIColor colorWithRed:212/255.0 green:111/255.0 blue:25/255.0 alpha:1.0],
                         [UIColor colorWithRed:189/255.0 green:62/255.0 blue:57/255.0 alpha:1.0],
                         [UIColor colorWithRed:230/255.0 green:115/255.0 blue:250/255.0 alpha:1.0],
                         [UIColor colorWithRed:220/255.0 green:164/255.0 blue:21/255.0 alpha:1.0],
                         [UIColor colorWithRed:0/255.0 green:100/255.0 blue:0/255.0 alpha:1.0],
                         [UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0],
                         [UIColor colorWithRed:0/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],
                         [UIColor colorWithRed:238/255.0 green:130/255.0 blue:238/255.0 alpha:1.0],
                         [UIColor colorWithRed:0/255.0 green:255/255.0 blue:127/255.0 alpha:1.0],
                         [UIColor colorWithRed:116/255.0 green:121/255.0 blue:0/255.0 alpha:1.0],
                         [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                         [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:1.0],
                         [UIColor colorWithRed:150/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],
                         [UIColor colorWithRed:215/255.0 green:255/255.0 blue:0/255.0 alpha:1.0],
                         [UIColor colorWithRed:49/255.0 green:79/255.0 blue:79/255.0 alpha:1.0],
                         [UIColor colorWithRed:255/255.0 green:20/255.0 blue:147/255.0 alpha:1.0],
                         [UIColor colorWithRed:119/255.0 green:136/255.0 blue:153/255.0 alpha:1.0],
                         [UIColor colorWithRed:119/255.0 green:200/255.0 blue:153/255.0 alpha:1.0],
                         [UIColor colorWithRed:119/255.0 green:136/255.0 blue:200/255.0 alpha:1.0],
                         [UIColor colorWithRed:200/255.0 green:136/255.0 blue:153/255.0 alpha:1.0],
                         [UIColor colorWithRed:217/255.0 green:100/255.0 blue:0/255.0 alpha:1.0],
                         [UIColor colorWithRed:215/255.0 green:110/255.0 blue:255/255.0 alpha:1.0],
                         [UIColor colorWithRed:100/255.0 green:255/255.0 blue:120/255.0 alpha:1.0],
                         [UIColor colorWithRed:20/255.0 green:255/255.0 blue:120/255.0 alpha:1.0],
                         [UIColor colorWithRed:100/255.0 green:20/255.0 blue:255/255.0 alpha:1.0],
                         nil];

    if(!kAppDelegate.colorPool) kAppDelegate.colorPool = [NSMutableDictionary dictionary];
    if(!kAppDelegate.colorPoolGroup) kAppDelegate.colorPoolGroup = [NSMutableDictionary dictionary];
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSError *err = nil;
    NSEntityDescription *entity ;
    if ([filter isEqualToString:@"filter"]) {
        [kAppDelegate.colorPool removeAllObjects];
        entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
        NSAttributeDescription* statusname = [entity.attributesByName objectForKey:@"status"];
        NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:statusname, nil];
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];

        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entity];
        [fetch setPropertiesToFetch:arrFetchList];
        [fetch setPropertiesToGroupBy:arrGroupBy];
        [fetch setResultType:NSDictionaryResultType];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"self.status!=null && self.status!=''"]];
        NSArray *results = [context executeFetchRequest:fetch error:&err];
        __block int i=0;
        [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            if(i< [colorArr count])
                [kAppDelegate.colorPool setObject:[colorArr objectAtIndex:i] forKey:[obj valueForKey:@"status"]];
            else
                [kAppDelegate.colorPoolGroup setObject:[UIColor colorWithRed:((arc4random() % 200) + 1)/255.0 green:((arc4random() % 200) + 1)/255.0 blue:255.0/255.0 alpha:1.0]  forKey:[obj valueForKey:@"status"]];
            i++;
        }];


        [kAppDelegate.colorPool setObject:tblHeaderYellow  forKey:@"Invoiced"];
        [kAppDelegate.colorPool setObject:[UIColor blueColor] forKey:@"Current"];
        [kAppDelegate.colorPool setObject:tblHeaderRed  forKey:@"Outstanding"];
        [kAppDelegate.colorPool setObject:[UIColor brownColor] forKey:@"My Top 20"];
        [kAppDelegate.colorPool setObject:[UIColor blackColor] forKey:@"Out of Stock"];
        [kAppDelegate.colorPool setObject:[UIColor purpleColor] forKey:@"Quote"];
    }else if ([filter isEqualToString:@"group"]){
        [kAppDelegate.colorPoolGroup removeAllObjects];

        entity = [NSEntityDescription entityForName:@"EXTRAGROUPCODES" inManagedObjectContext:context];
        NSAttributeDescription* grpName1 = [entity.attributesByName objectForKey:@"extragroupcode"];

        NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:grpName1, nil];
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];

        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:entity];
        [fetch setPropertiesToFetch:arrFetchList];
        [fetch setPropertiesToGroupBy:arrGroupBy];
        [fetch setResultType:NSDictionaryResultType];

        [fetch setPredicate:[NSPredicate predicateWithFormat:@"self.extragroupcode!=null && self.extragroupcode!=''"]];
        NSArray *results = [context executeFetchRequest:fetch error:&err];
        __block int i=10;
        [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            if(i< [colorArr count]-10)
                [kAppDelegate.colorPoolGroup setObject:[colorArr objectAtIndex:i] forKey:[obj valueForKey:@"extragroupcode"]];
            else
                [kAppDelegate.colorPoolGroup setObject:[UIColor colorWithRed:((arc4random() % 200) + 1)/255.0 green:((arc4random() % 200) + 1)/255.0 blue:255.0/255.0 alpha:1.0]  forKey:[obj valueForKey:@"extragroupcode"]];

            i++;
        }];

        [kAppDelegate.colorPoolGroup setObject:[UIColor blackColor]  forKey:@"Multiple Groups"];


    }

}

-(NSArray*) findFilters :(NSString*)Str {
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSError *err = nil;
    NSEntityDescription *entity;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];


    NSAttributeDescription* grpName;
    NSMutableArray *arrGroupBy;
    NSMutableArray *arrFetchList;

    if ([Str isEqualToString:@"my top 20"]) {
        entity= [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:context];
        [fetch setEntity:entity];

        NSInteger count = [context countForFetchRequest:fetch /*the one you have above but without limit */ error:&err];
        NSUInteger size = 20;
        count -= size;
        [fetch setFetchOffset:count>0?count:0];
        [fetch setFetchLimit:size];

        grpName = [entity.attributesByName objectForKey:@"productid"];
        arrGroupBy = [NSMutableArray arrayWithObjects:grpName, nil];
        arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];

    }
    [fetch setPropertiesToFetch:arrFetchList];
    [fetch setPropertiesToGroupBy:arrGroupBy];
    [fetch setResultType:NSDictionaryResultType];

    return  [context executeFetchRequest:fetch error:&err];

}

-(void)loadArraysData{

   //*****  mahendra  if (_customerInfo)
    {
        Mytop20Array=[self findFilters:@"my top 20"];
    }
    [[self tblProduct] reloadData];

}

-(void)loadCustomerInfo{
    if(_customerInfo){
        [_btnCustomer setTitle:[_customerInfo valueForKey:@"name"] forState:UIControlStateNormal];
    }
    else{
        [_btnCustomer setTitle:@"[SELECT CUSTOMER]" forState:UIControlStateNormal];
    }
}

-(void)loadnavigationtitle{
    NSArray *sections = [self.fetchedResultsController sections];
    NSInteger iCount = 0;
    for(id<NSFetchedResultsSectionInfo> sinfo in sections){
        iCount+=[sinfo numberOfObjects];
    }

    NSInteger stripLength=[[NSString stringWithFormat:@"%@ (%li)",strTitle,(long)iCount] length] - [CommonHelper maxAllowedLenthInNavigationTitle];
    if(stripLength>0){
        strTitle = [[strTitle substringToIndex:[strTitle length]-stripLength-3] stringByAppendingString:@"..."];
    }

    self.title = [NSString stringWithFormat:@"%@ (%li)",strTitle,(long)iCount];
    strCurrentTitle = self.title;

}

-(void)doNavigateNext:(id)sender{
    [self performSegueWithIdentifier:@"toProductMultipleSegment" sender:sender];
}

-(NSPredicate *)getPredicateString :(NSInteger )FilterSts{
    NSMutableArray *predicates=[[NSMutableArray alloc] init];
    if (FilterSts==0){
        if ([_searchBar.text length] > 0) {
            
            NSArray * portions = [_searchBar.text componentsSeparatedByString:@","];
            NSUInteger prodCount = [portions count] - 1;
            NSString *serchStr=_searchBar.text;
            if (prodCount==1) {//if search product code by scanning for Fulham Brass code 128
                serchStr=[_searchBar.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
            
            
            NSPredicate * searchPredicate = [NSPredicate predicateWithFormat:@"(gdescription contains[cd] %@ || stock_code contains[cd] %@)",serchStr,serchStr];
            [predicates addObject:searchPredicate];
        }
        if(_Group2Codes && [_Group2Codes count]>0){
            NSArray *grp2Arr=[[_Group2Codes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state=1"]] valueForKey:@"identifier"];
            if( [grp2Arr count]>0){
                NSPredicate * group2Predicate = [NSPredicate predicateWithFormat:@"grp2 in %@",grp2Arr];
                [predicates addObject:group2Predicate];
            }
        }

        if(_Group1Codes && [_Group1Codes count]>0){
            NSArray *grp1Arr=[[_Group1Codes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state=1"]]valueForKey:@"identifier"];
            if( [grp1Arr count]>0){
                NSPredicate * group1Predicate = [NSPredicate predicateWithFormat:@"category in %@",grp1Arr];
                [predicates addObject:group1Predicate];
            }
        }
    }

    NSPredicate * extraGroupPredicate = nil;
    if (FilterSts==1) {
        if (PromotionalCodes_Filter && [PromotionalCodes_Filter count]>0) {

            NSMutableArray *predicatesArr=[[NSMutableArray alloc] init];
            NSMutableArray *compPredArry1=[[NSMutableArray alloc]init];
            NSMutableArray *compPredArry2=[[NSMutableArray alloc]init];
            NSPredicate *compPredicate1;
            NSPredicate *compPredicate2;

            for(NSString *groupID in [[PromotionalCodes_Filter filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                NSPredicate *predicateExt=nil;

                if ([groupID isEqualToString:@"Multiple Groups"]) {

                    predicateExt=[NSPredicate predicateWithFormat:@"((extracode1!='' and extracode2!='' and extracode3!='' and (extracode1!=extracode2 and extracode1!=extracode3))  or (extracode1!='' and extracode2!=''  and extracode1!=extracode2) or (extracode1!=''  and extracode3!='' and extracode1!=extracode3)  or (extracode2!='' and extracode3!='' and extracode2!=extracode3))"];
                }else
                    predicateExt=[NSPredicate predicateWithFormat:@"extracode1 = %@ or extracode2 = %@ or extracode3 = %@",groupID,groupID,groupID];

                [compPredArry1 addObject:predicateExt];

            }

            if ([compPredArry1 count]>0){
                compPredicate1 =[NSCompoundPredicate orPredicateWithSubpredicates:compPredArry1];
                [predicatesArr addObject:compPredicate1];
            }


            //NOT IN
            for(NSString *groupID in [[PromotionalCodes_Filter filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){

                NSPredicate *predicateExt=nil;
                if ([groupID isEqualToString:@"Multiple Groups"]) {
                    predicateExt=[NSPredicate predicateWithFormat:@"((extracode1!='' && extracode2!='' && extracode3!='' and (extracode1=extracode2 and extracode1=extracode3)) or (extracode1!='' and extracode2!=''  and extracode1=extracode2) or (extracode1!=''  and extracode3!='' and extracode1=extracode3) or (extracode2!='' and extracode3!='' and extracode2=extracode3) or (extracode1='' and extracode2='') or (extracode2='' and extracode3='') or (extracode1='' and extracode3=''))"];
                }else
                    predicateExt=[NSPredicate predicateWithFormat:@"extracode1 != %@ && extracode2 != %@ && extracode3 != %@ ",groupID,groupID,groupID];

                if (predicateExt)
                    [compPredArry2 addObject:predicateExt];
            }

            if ([compPredArry2 count]>0){
                compPredicate2 =[NSCompoundPredicate andPredicateWithSubpredicates:compPredArry2];
                [predicatesArr addObject:compPredicate2];
            }

            //Create Compound predicate
            NSPredicate *compoundPredicate = nil;
            if([predicatesArr count]==1)
                compoundPredicate = [predicatesArr lastObject];
            else if ([predicatesArr count]>1)
                compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArr];

            if(compoundPredicate)
                [predicates addObject:compoundPredicate];
        }

    }else{
        if(_PromotionalCodes && [_PromotionalCodes count]>0){
            NSArray *extGrpArr=[[_PromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state=1"]]valueForKey:@"identifier"];

            extraGroupPredicate = [NSPredicate predicateWithFormat:@"(extracode1 in %@ || extracode2 in %@ || extracode3 in %@)",extGrpArr,extGrpArr,extGrpArr];
            [predicates addObject:extraGroupPredicate];
        }
    }

    NSMutableArray* barCodeArry =[[_searchBar.text componentsSeparatedByString:@","] mutableCopy];
    [barCodeArry removeObject:@""];
    
    if([_searchBar.text containsString:@","] && ((([[_searchBar.text componentsSeparatedByString:@","] lastObject].length>0 && ([[_searchBar.text componentsSeparatedByString:@","] lastObject].length==10 || [[_searchBar.text componentsSeparatedByString:@","] lastObject].length==13)) || ([[_searchBar.text componentsSeparatedByString:@","] firstObject].length>0 && ([[_searchBar.text componentsSeparatedByString:@","] firstObject].length==10 || [[_searchBar.text componentsSeparatedByString:@","] firstObject].length==13)))  || [barCodeArry count]>1)){
       
    //if([_searchBar.text containsString:@","]  ){
        
        [predicates removeAllObjects];
        
       
        
        barCodeSearchSts=YES;
        
       // NSArray* reversed =[[_searchBar.text componentsSeparatedByString:@","] mutableCopy];
       // NSMutableArray *barCodes =(NSMutableArray *)[[reversed reverseObjectEnumerator] allObjects];
       NSMutableArray* barCodes =[[_searchBar.text componentsSeparatedByString:@","] mutableCopy];
        if([[barCodes lastObject] length]==0)
            [barCodes removeObject:[barCodes lastObject]];
        
        if ([barCodes count]>0)
            [self insertDateandTime:barCodes];
        
        
        NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barcode in %@ || innerbarcode in %@ || outerbarcode in %@ || stock_code in %@",barCodes,barCodes,barCodes,barCodes];
        [predicates addObject:barcodePredicate];

        strTitle =@"Results";
        
        return barcodePredicate;
    }
    else{
        strTitle = strTitle2;
        barCodeSearchSts=NO;
    }

    // Add predicates to array
    NSPredicate *compoundPredicate = nil;
    if([predicates count]==1)
        compoundPredicate = [predicates lastObject];
    else if ([predicates count]>1)
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    return compoundPredicate;
}

-(void)insertDateandTime:(NSArray*)searchArr{
   
    
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSError *err = nil;
    NSEntityDescription *entity;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    entity= [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
    NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barcode == %@ || innerbarcode == %@ || outerbarcode == %@",[searchArr lastObject],[searchArr lastObject],[searchArr lastObject]];
    [fetch setPredicate:barcodePredicate];
    [fetch setEntity:entity];
    NSInteger count = [context countForFetchRequest:fetch /*the one you have above but without limit */ error:&err];
    if (count<=0)
        return;
    
    NSArray *arr=[context executeFetchRequest:fetch error:&err];
    if ([arr count]>0) {
         NSManagedObject *prodObj=[arr firstObject];
        NSError *error = nil;
        [prodObj setValue:[NSDate date] forKey:@"searchdateandtime"];
        if (![context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }else
        return;
    
    
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSString *entityName=@"PROD";

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:10];

    // Edit the sort key as appropriate.
    if(sortByFieldName && [sortByFieldName length]>0){
        NSMutableArray *arrSort = [NSMutableArray array];
        [[sortByFieldName componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc] initWithKey:obj ascending:SORTDes];
            [arrSort addObject:sortDescriptor];
        }];

       /* if (barCodeSearchSts) {
            NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"searchdateandtime" ascending:NO selector:nil];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSort, nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
        }else*/
            [fetchRequest setSortDescriptors:arrSort];
        
    }

    [fetchRequest setPredicate:[self getPredicateString:0]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:kAppDelegate.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else{
        [self loadnavigationtitle];
    }

    _searchBarTopConstraint.constant= [[self.fetchedResultsController fetchedObjects] count]>10?0:-44;
    _searchBar.hidden = [[self.fetchedResultsController fetchedObjects] count]>10?NO:YES;

    return _fetchedResultsController;
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tblProduct beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tblProduct endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tblProduct;
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
            [self.tblProduct insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tblProduct deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)configureCell:(ProductTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
   
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.hidden = NO;
    cell.lblProductCode.text = [record valueForKey:@"stock_code"];
    cell.lblProductName.text = [record valueForKey:@"gdescription"];
    cell.btnNext.tag = indexPath.row;

    if(![cell.btnNext targetForAction:@selector(doNavigateNext:) withSender:self]){
        [cell.btnNext addTarget:self action:@selector(doNavigateNext:) forControlEvents:UIControlEventTouchUpInside];
    }

    NSString *strfinalimage=nil;
    if ([[[companyConfigDict valueForKey:@"tradename"] lowercaseString] hasPrefix:@"henbrandt"]) {
        strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[[record valueForKey:@"stock_code"] stringByReplacingOccurrencesOfString:@" " withString:@""]] lowercaseString]] stringByAppendingString:@".jpg"];
    }else
        strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[record valueForKey:@"stock_code"]] lowercaseString]] stringByAppendingString:@".jpg"];
  
    [cell.imgViewProduct setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    //Mahendra load product data from priceConfig
    NSArray* arrpacks = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];


    //  group image
    [cell.groupColorImgView setHidden:YES];
    quartzview *q=[[quartzview alloc]init];
    q.frame=CGRectMake(0, 0, 30.0, 30.0);
    [q setSelColor:[UIColor whiteColor]];

    if ([[record valueForKey:@"extracode1"] length]>0) {
        [q setSelColor:[kAppDelegate.colorPoolGroup valueForKey:[record valueForKey:@"extracode1"]]];
        [cell.groupColorImgView setHidden:NO];
    }else if ([[record valueForKey:@"extracode2"] length]>0) {
        [q setSelColor:[kAppDelegate.colorPoolGroup valueForKey:[record valueForKey:@"extracode2"]]];
        [cell.groupColorImgView setHidden:NO];
    }else if ([[record valueForKey:@"extracode3"] length]>0) {
        [q setSelColor:[kAppDelegate.colorPoolGroup valueForKey:[record valueForKey:@"extracode3"]]];
        [cell.groupColorImgView setHidden:NO];
    }
    //Multiple group
    if (([[record valueForKey:@"extracode1"] length]>0 && [[record valueForKey:@"extracode2"]length]>0)||([[record valueForKey:@"extracode2"] length]>0 && [[record valueForKey:@"extracode3"]length]>0) ||([[record valueForKey:@"extracode3"] length]>0 && [[record valueForKey:@"extracode1"]length]>0)) {
        [q setSelColor:[kAppDelegate.colorPoolGroup valueForKey:@"Multiple Groups"]];
        [cell.groupColorImgView setHidden:NO];
    }

    [cell.groupColorImgView addSubview:q];
    //ended


    //For filter color
    for (UILabel *lblFilter in cell.lblfilters) {
        [lblFilter setHidden:YES];
    }

    int valcount=0;
    // blueColor        Current already show button blue button
  /*  if (_transactionInfo &&  [[[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid ==%@",[record valueForKey:@"stock_code"]]] count]>0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:@"Current"];
        lblFilter.hidden=NO;
        valcount++;
    }*/

    //BlackColor       Dynamic Filter status
    if ([[record valueForKey:@"status"] length]>0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:[record valueForKey:@"status"]];
        lblFilter.hidden=NO;
        valcount++;
    }
    //BlackColor       Additional Filter/Out of Stock
    if (![[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] isEqual:[NSNull null]] && [[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] length]>0 && [[record valueForKey:[[[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString]] integerValue] <=0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:@"Out of Stock"];
        lblFilter.hidden=NO;
        valcount++;
    }
    //BrownColor       My Top 20
    if ([[Mytop20Array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid ==%@",[record valueForKey:@"stock_code"]]] count]>0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:@"My Top 20"];
        lblFilter.hidden=NO;
        valcount++;
    }
    //red      Invoiced
    if ([[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"showinvoiceoutstandingninfilter"] boolValue] && _customerInfo && [[[[_customerInfo valueForKeyPath:@"iheads.invoicelines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code ==%@",[record valueForKey:@"stock_code"]]] count]>0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:@"Invoiced"];
        lblFilter.hidden=NO;
        valcount++;
    }

    // config added by Satish on 20th Jan 16
    //yellow         Outstanding
    if ([[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"showinvoiceoutstandingninfilter"] boolValue] && _customerInfo && [[[[_customerInfo valueForKeyPath:@"oheads.orderlines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code == %@",[record valueForKey:@"stock_code"]]] count]>0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:@"Outstanding"];
        lblFilter.hidden=NO;
        valcount++;
    }
    // end of config by Satish

    // purpleColor        quote
    if (_transactionInfo && [[[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid ==%@ and orderlinetype=='Q'",[record valueForKey:@"stock_code"]]] count]>0) {
        UILabel* lblFilter = [[cell.lblfilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",valcount]] lastObject];
        lblFilter.backgroundColor=[kAppDelegate.colorPool valueForKey:@"quote"];
        lblFilter.hidden=NO;
        valcount++;
    }



    int icounter=0;
    for (NSDictionary* packDic in arrpacks) {
        if(icounter>=3) break;
        
        UILabel* lblpack = [[cell.PackLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];
        UIButton* btnpack = [[cell.PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];
        
        //Set Layout Constraints
        NSLayoutConstraint *btnwithlayout=[cell.packBtnWidthLayoutConstraint objectAtIndex: icounter];
        NSLayoutConstraint *lblwithlayout=[cell.packLblWidthLayoutConstraint objectAtIndex: icounter];
        
        if ([arrpacks count]<3) {
            btnwithlayout.constant=47.0;
            lblwithlayout.constant=47.0;
        }//END
        
        
        
        
        
        [btnpack setBackgroundColor:[UIColor whiteColor]];
        [btnpack setTitleColor:SelectedBackgroundColor forState:UIControlStateNormal];
        
        if(![[packDic objectForKey:@"label"] isEqual:[NSNull null]])
            lblpack.text = [packDic objectForKey:@"label"];
        
        NSString *packqty = [CommonHelper getFieldValueWithFieldName:[packDic objectForKey:@"field"] Source:record];
        [btnpack setTitle:packqty forState:UIControlStateNormal];
        
        lblpack.hidden = NO;
        btnpack.hidden = NO;
        
        //Button desable/Enable  WebConfig
        if (![[packDic valueForKey:@"selectable"] boolValue])
            [btnpack setEnabled:NO];
        
        
        
        icounter++;
    }

    // to hide additional field
    if(icounter<3){
        NSInteger icount = icounter+1;
        if(icounter==0) icount = icounter;
        for(NSInteger k=icount;k<=3;k++){
            UILabel* lblpack = [[cell.PackLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",k]] lastObject];
            UIButton* btnpack = [[cell.PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",k]] lastObject];
            lblpack.hidden = YES;
            btnpack.hidden = YES;
        }
    }

    // to set value in total
   // packBtnWidthLayoutConstraint
    if ([arrpacks count]>0)
    {
        [cell.viewPackBtns setHidden:NO];
        UILabel* lblpack = [[cell.PackLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];
        UIButton* btnpack = [[cell.PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];
        lblpack.text = @"Total";
        lblpack.hidden = NO;
        btnpack.hidden = NO;
      
        
        //Set Layout Constraints
        NSLayoutConstraint *btnwithlayout=[cell.packBtnWidthLayoutConstraint objectAtIndex: icounter];
        NSLayoutConstraint *lblwithlayout=[cell.packLblWidthLayoutConstraint objectAtIndex: icounter];
        if ([arrpacks count]<3) {
            btnwithlayout.constant=48.0;
            lblwithlayout.constant=48.0;
            NSLayoutConstraint *lblwithlayout2=[cell.packLblWidthLayoutConstraint objectAtIndex: 3];
            lblwithlayout2.constant=0.0;
        }//END
        
        
       /* Commented by mahendra for Ellis changes
        if(indexPath.row==0 && packBtnContainerWidth==0)
            packBtnContainerWidth = cell.viewPackBtnLayoutWidthConstraints.constant;


        if(icounter<=2){
            if(icounter==2){
                cell.viewPackBtnLayoutWidthConstraints.constant= packBtnContainerWidth - 35;
            }
            else
                cell.viewPackBtnLayoutWidthConstraints.constant= packBtnContainerWidth - (35 * 2);
        }
        else if(cell.viewPackBtnLayoutWidthConstraints.constant!=packBtnContainerWidth)
            cell.viewPackBtnLayoutWidthConstraints.constant = packBtnContainerWidth;

        */
        
        
        
        
        //    if (icounter==1) {
        //       cell.btnWidthLayoutConstrain2.constant=32;
        //    }else if (icounter==2){
        //        cell.btnWidthLayoutConstrain3.constant=35;
        //    }

        [btnpack setBackgroundColor:btnGreenColor];
        [btnpack setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
        [btnpack setUserInteractionEnabled:NO];


        NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
        if ([arrDefault count]>0) {
            [btnpack setTitle:[NSString stringWithFormat:@"%li",(long)[[record valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] forState:UIControlStateNormal];
        }
        //[btnpack setTitle:@"12" forState:UIControlStateNormal];

        //Check Added product in oline
        if (_transactionInfo && [[_transactionInfo valueForKey:@"orderlinesnew"] count]>0) {
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [record valueForKey:@"stock_code"]];
            NSArray *filteredArr = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            if ([filteredArr count]>0) {
               // NSManagedObject *obj=[filteredArr objectAtIndex:0];
                
                [btnpack setTitle:[NSString stringWithFormat:@"%li",(long)[[filteredArr valueForKeyPath:@"@sum.quantity"] integerValue]] forState:UIControlStateNormal];
              //  [btnpack setTitle:[NSString stringWithFormat:@"%li",(long)[[obj valueForKey:@"quantity"] integerValue]] forState:UIControlStateNormal];
                [btnpack setBackgroundColor:btnBlueColor];
                [btnpack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [btnpack setBackgroundColor:btnGreenColor];
                [btnpack setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
            }
        }//End

    }
    else
        [cell.viewPackBtns setHidden:YES];

    //***Price field
    //code added by Amit Pant on 20151218


    NSDictionary *dict= [[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]] lastObject];
    
    NSString *defPrice=prodDefaultPrice;
    NSArray *array=[priceConfigDict objectForKey:@"pricetablabels"];
    
   /* if ([array count]>1) {
        dict=[array objectAtIndex:1];
        defPrice=[dict valueForKey:@"field"];
    }else{
        if (dict) {
            defPrice=[dict valueForKey:@"field"];
        }
    }*/
    if (dict) {
        defPrice=[dict valueForKey:@"field"];
    }
    
    NSString *currCode=nil;
    
    //  After customer selection Change selected Price Default before Price selection selection
    if(![[priceConfigDict objectForKey:@"pricetablabels"] isEqual:[NSNull null]] && self.customerInfo ){
        
        NSString *symbol=[CommonHelper getCurrSymbolWithCurrCode:[self.customerInfo valueForKey:@"curr"]];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"label CONTAINS %@ ",symbol];
        NSArray *filterArr=[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
        if ([filterArr count]>0) {
            defPrice=[[filterArr firstObject] valueForKey:@"field"];
           // currCode=[self.customerInfo valueForKey:@"curr"];
        }
    }//ended
        
    
    
    
    
//    icounter=0;
    NSArray* arrSidebar;
    
        if (_transactionInfo && [[_transactionInfo valueForKey:@"orderlinesnew"] count]>0){
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [record valueForKey:@"stock_code"]];
            NSArray *filteredArr = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            
            if ([filteredArr count]>0){
                NSManagedObject *obj=[filteredArr firstObject];
                arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:record Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:obj PriceConfig:priceConfigDict UserConfig:userConfigDic] objectForKey:@"sidebar"];
            }else
                arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:record Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:nil  PriceConfig:priceConfigDict UserConfig:userConfigDic] objectForKey:@"sidebar"];
        }else
            arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:record Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDic] objectForKey:@"sidebar"];
    
    
    cell.orderPrice=[[[arrSidebar lastObject] valueForKey:@"value"] doubleValue];
    __block NSInteger priceCounter=0;
    [arrSidebar enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        UILabel* lblpricecap = [[cell.priceFiledLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",priceCounter]] lastObject];
        UILabel* lblpriceval = [[cell.priceLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",priceCounter]] lastObject];

        lblpricecap.text =[obj valueForKey:@"caption"];;
       // double priceValue=[[obj valueForKey:@"value"] doubleValue];
       /* if ([priceConfigDict valueForKey:@"useexchangerateconversion"]) {//webconfig option
            NSString *currCode=[self.customerInfo valueForKey:@"curr"];
            
            
            NSArray *filterExrateArr=[_excangeRateArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"currencycode=%@",currCode]];
        //    priceValue=[CommonHelper convertCurrencyFromCurrencyCode:<#(NSString * _Nonnull)#> Value:priceValue ToCurrencyCode:<#(NSString * _Nonnull)#> ExchangeRate:<#(double)#> DefaultCurrency:<#(NSString * _Nonnull)#>
        }*/
        
        lblpriceval.text = [obj valueForKey:@"showPrice"];//[CommonHelper getCurrencyFormatWithCurrency:currCode Value:priceValue];
        [lblpricecap setHidden:NO];
        [lblpriceval setHidden:NO];

        priceCounter++;
    }];
    //code ended here

}

#pragma mark UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

/*-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 ==0) {
        cell.backgroundColor=tblOddColor;
    }else
        cell.backgroundColor=tblEvenColor;
    
}*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"ProductTableViewCell";
    ProductTableViewCell *cell=(ProductTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    [cell setDelegate:self];
    [self configureCell:cell atIndexPath:indexPath];
    // cell.priceConfigDict=priceConfigDict;
    return cell;
}

#pragma mark - UITableView Delegate
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//
//    return 40.0;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//
//    [self loadCustomerInfo];
//
//    return viewHeader;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //code added by Ashish
    //    isNextBtnClicked=NO;
    //    [self performSegueWithIdentifier:@"toProductMultipleSegment" sender:self];
    //end of code added
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *deltfilteredArr=nil;
    if ([[_transactionInfo valueForKey:@"orderlinesnew"] count]>0) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"stock_code"]];
        deltfilteredArr = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
    }

    if ([deltfilteredArr count]==0 ){//&& ![[featureDict valueForKey:@"productsaleshistoryenabled"] boolValue]) {
        return NO;
    }else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    deleteObj=[self.fetchedResultsController objectAtIndexPath:indexPath];
    delIndexPath= indexPath;
    NSArray *deltfilteredArr=nil;
    if ([[_transactionInfo valueForKey:@"orderlinesnew"] count]>0) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [deleteObj valueForKey:@"stock_code"]];
        deltfilteredArr = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
    }


    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self TableCell_DeleteClicked];
    }];
    button.backgroundColor = [UIColor redColor]; //arbitrary color

    //  Mahendra fetch Feature config **PRODUCT SALES HISTORY ENABLE
    /*if (featureDict !=nil && [[featureDict valueForKey:@"productsaleshistoryenabled"] boolValue]) {
     UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"History" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)     {
     [self TableCell_HistoryClicked];
     }];
     button2.backgroundColor = [UIColor colorWithRed:51.0/255.0       green:153.0/255.0       blue:255.0/255.0       alpha:1.0]; //arbitrary color

     if ([deltfilteredArr count]>0)
     return @[button,button2];
     else
     return @[button2];

     }else*/
    if ([deltfilteredArr count]>0) {
        return @[button]; //array with all the buttons you want. 1,2,3, etc...
    }else
        return nil;

}

- (void) TableCell_DeleteClicked{
    if (_transactionInfo) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [deleteObj valueForKey:@"stock_code"]];
        NSArray *filteredArr = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        if ([filteredArr count]>0) {
            for (NSManagedObject* oLineObj in filteredArr) {
                [kAppDelegate.managedObjectContext deleteObject:oLineObj];
            }
            
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }else{
                ProductTableViewCell *cell = [self.tblProduct cellForRowAtIndexPath:delIndexPath];
                
                NSArray* arrpacks = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];
                NSInteger icounter=[arrpacks count];

                UIButton* btnpack = [[cell.PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];

                NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
                if ([arrDefault count]>0) {
                    [btnpack setTitle:[NSString stringWithFormat:@"%li",(long)[[deleteObj valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] forState:UIControlStateNormal];
                }else
                    [btnpack setTitle:@"0" forState:UIControlStateNormal];

                [btnpack setBackgroundColor:btnGreenColor];
                [btnpack setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
            }
        }
        [_tblProduct reloadData];
        
        //Check order type
        if(_transactionInfo)
            [self changeOrderType:_transactionInfo];
    }
}

- (void) TableCell_HistoryClicked{
    DebugLog(@"TableCell_HistoryClicked");
}

#pragma mark search bar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    if (LoadFirstTime) {
//        [_btnOverlay setHidden:NO];
//    }else
//        LoadFirstTime=YES;
    
    
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    //*******       Search copy/past by web config
    if ([[priceConfigDict objectForKey:@"HighlightSearchBar"]boolValue]) {
        [self highlightText:[NSString stringWithFormat:@"%@",_searchBar.text]];
    }
    
    [searchBar resignFirstResponder];
    [_btnOverlay setHidden:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
//    if ([searchText length]<=0) {
//        [_btnOverlay setHidden:NO];
//    }else
//        [_btnOverlay setHidden:YES];

    [[_fetchedResultsController fetchRequest] setPredicate:[self getPredicateString:0]];
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"searchdateandtime" ascending:NO selector:nil];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSort, nil];
    [[_fetchedResultsController fetchRequest] setSortDescriptors:sortDescriptors];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self loadnavigationtitle];
    [[self tblProduct] reloadData];
    
    
  /*  NSRange range=[searchBar.text rangeOfString:@","];
    if (range.location !=NSNotFound && [[priceConfigDict objectForKey:@"IsBarcodeScanning"] boolValue])
    {
        NSString *strsrctext = _searchBar.text;
        UIView *subviews = [_searchBar.subviews lastObject];
        UITextField *searchBarTextField =(id)[subviews.subviews objectAtIndex:1];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:searchBarTextField.attributedText];
        [attr addAttribute:NSBackgroundColorAttributeName value:[UIColor  whiteColor] range:NSMakeRange(0,  strsrctext.length)];
        searchBarTextField.attributedText=attr;
        
    }*/
    if(![[_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] hasSuffix:@","]) {
        
        
        
        
        if (srcTxtLen !=0 && [[priceConfigDict objectForKey:@"HighlightSearchBar"]boolValue]) {
            
            NSMutableArray *characters = [NSMutableArray array];
            
            if([searchBar.text length]>0){
                
                [searchBar.text enumerateSubstringsInRange:[searchBar.text rangeOfString:searchBar.text]
                                                   options:NSStringEnumerationByComposedCharacterSequences
                                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                    [characters addObject:substring] ;
                                                }] ;
                
            }
            
            //  NSString *stringSearch=searchText;
            int sts=srcTxtLen;
            if([characters count]>0)
                searchText=[searchBar.text substringFromIndex:[characters count]-1];
            
            srcTxtLen=(int)searchText.length;
            int idx=0;
            
            UIView *subviews = [_searchBar.subviews lastObject];
            UITextField *searchBarTextField =(id)[subviews.subviews objectAtIndex:1];
            while (idx<=(searchBarTextField.attributedText.length-srcTxtLen)){
                NSRange srcRange = NSMakeRange(idx, srcTxtLen);
                if ([[searchBarTextField.attributedText.string substringWithRange:srcRange] isEqualToString:searchText]) {
                    NSMutableAttributedString *tmpAttrTxt = [[NSMutableAttributedString alloc] initWithAttributedString:searchBarTextField.attributedText];
                    [tmpAttrTxt addAttribute:NSBackgroundColorAttributeName value:[UIColor whiteColor]  range:srcRange];
                    searchBarTextField.attributedText = tmpAttrTxt;
                    if([characters count]>0)
                        searchBar.text =[searchBar.text substringFromIndex:[characters count]-1];
                    else{
                        searchBar.text =@"";
                        break;
                    }
                    //*******  insert 2nd last digit after remove search text highlight search  15 JUN 2015
                    if (sts !=1 && sts>=[characters count] && [characters count]>1)
                        [self performSelector:@selector(delete_lastChar) withObject:nil afterDelay:0.001];
                    
                    idx+=srcTxtLen;
                    
                }
                else {
                    idx++;
                }
            }
            
            if (PastSts) {
                searchText= PastString;
                _searchBar.text=PastString;
            }
            
            srcTxtLen=0;
        }
        return;
    }
    
    [self searchBarSearchButtonClicked:searchBar];
    return;
   
    if([searchText length]==0)
    {
    } else{
        [self searchBarSearchButtonClicked:searchBar];
        
    }
}

-(void)delete_lastChar{
    _searchBar.text=@"";
    
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    strCurrentTitle = self.title;
    self.title = @"";
    if ([segue.identifier isEqualToString:@"showProductFilterSegue"]) {
        CatalogueFilterViewController *filterObj= segue.destinationViewController;

        filterObj.selectedPromotionalCodes=_selectedGroupFilters;
        [filterObj setDelegate:self];
        filterObj.customerInfo=self.customerInfo;
        filterObj.selectedFilters=_selectedFilters;
        filterObj.predicateApplied=[self getPredicateString:0];
        filterObj.returnDictionary=(NSMutableDictionary* )filterDic;
    }
    else if ([segue.identifier isEqualToString:@"toProductMultipleSegment"]) {
        ProductMultipleSegmentDetailViewController *productMSDVC = segue.destinationViewController;
        [productMSDVC setSelectectIndex:[(UIButton *)sender tag] totalProductsFetched:_fetchedResultsController.fetchedObjects];
        productMSDVC.customerInfo = _customerInfo;
        productMSDVC.transactionInfo = _transactionInfo;
        productMSDVC.priceConfigDict=priceConfigDict;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([sender tag]) inSection:0];
        productMSDVC.oLineInfo=[_fetchedResultsController objectAtIndexPath:indexPath];

    }
    else if ([segue.identifier isEqualToString:@"showCustomerFromProdSegue"]){
        CustomerController *cvc = segue.destinationViewController;
        cvc.isFromProductScreen = YES;
    }
    else if ([segue.identifier isEqualToString:@"toScannerViewController"]){

        ScannerViewController *svc = segue.destinationViewController;
        svc.delegate=self;
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    isScrollBeginDragging = YES;
    [self dismissKeyboard:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!isScrollBeginDragging || [[self.fetchedResultsController fetchedObjects] count]<=10 || scrollView.contentSize.height<=_tblProduct.frame.size.height) return;

    if(scrollView.contentOffset.y<=distance){
        if(self.navigationController.navigationBarHidden){
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
    else{
        if(!self.navigationController.navigationBarHidden)
            [self navigationHide];
    }
}

-(void)navigationHide{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    distance = scrollView.contentOffset.y;
    if(distance<0) distance = 0;
    isScrollBeginDragging = NO;
}

#pragma mark - CatalogueFilterDelegate
-(void)finishedFilterSelectionWithValues:(NSDictionary *)values{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [compoundFilterArr removeAllObjects];

    if (!compoundFilterArr) {
        compoundFilterArr=[[NSMutableArray alloc]init];
    }

    [filterDic removeAllObjects];
    filterDic=(NSMutableDictionary*)values;

    NSString *strPredicate=@"";
    if ([values valueForKey:@"promotionalcode"]) {
        PromotionalCodes_Filter=[values valueForKey:@"promotionalcode"];

        NSPredicate *predicateFilter=[self getPredicateString:1];
        if(predicateFilter)
            [compoundFilterArr addObject:predicateFilter];
    }

    


    NSArray *CheckCatArr=[[values valueForKey:@"category"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state ==1"]];
    NSArray *CheckSubArr=[[values valueForKey:@"sub-cat"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state ==1"]];
    NSArray *CheckExtArr=[[values valueForKey:@"promotionalcode"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state ==1"]];
    if ([CheckCatArr count]==0 && [CheckSubArr count]==0 && [CheckExtArr count]==1) {
        strTitle=[[CheckExtArr lastObject] valueForKey:@"label"];
    }else if ([CheckSubArr count]==1 && [CheckExtArr count]==0) {
        strTitle=[[CheckSubArr lastObject] valueForKey:@"label"];
    }
    else if ([CheckCatArr count]==1 && [CheckExtArr count]==0) {
        strTitle=[[CheckCatArr lastObject] valueForKey:@"label"];
    }else
        strTitle =@"Results";

    NSArray *CheckArr=[[values valueForKey:@"category"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 || state =2"]];
    if([CheckArr count]==0)
        CheckArr=[[values valueForKey:@"sub-cat"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 || state =2"]];
    if([CheckArr count]==0)
        CheckArr=[[values valueForKey:@"promotionalcode"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 || state =2"]];
    if([CheckArr count]==0)
        CheckArr=[[values valueForKey:@"filter"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 || state =2"]];
    if([CheckArr count]==0)
        strTitle =strTitle2;

                        
    //Check for filter Status
    [_barButtonFilters setImage:[UIImage imageNamed:@"filter"]];//setTintColor: btnTitleBlueColor];
    BOOL filterSelSts=NO;
    //Checking in Array
    if ([CheckArr count]>0)
        filterSelSts=YES;
    
    if (filterSelSts)
    {
        [_barButtonFilters setImage:[UIImage imageNamed:@"filterSelected"]];//setTintColor: [UIColor greenColor]];
    }
    //Ended
                  
    

    NSString* addprefix=@"";
    NSInteger count=0;
    NSInteger indexCount=0;
    //***       status Working
    if ([strPredicate length]>0)
        addprefix=@" and";

    if ([values valueForKey:@"filter"]) {
        count=0;
        indexCount=0;

        for (NSDictionary* dic in  [values valueForKey:@"filter"]) {
            indexCount++;
            if ([[[dic valueForKey:@"identifier"] lowercaseString] isEqualToString:@"my top 20"] && [[dic valueForKey:@"state"] integerValue]> 0) {
                NSPredicate *predicateTop20;
                if([[dic valueForKey:@"state"] integerValue]==1 && [Mytop20Array count]>0){
                    predicateTop20 = [NSPredicate predicateWithFormat:@" stock_code in %@",[Mytop20Array valueForKey:@"productid"]];
                    [compoundFilterArr addObject:predicateTop20];

                }else if([[dic valueForKey:@"state"] integerValue]==2 && [Mytop20Array count]>0){
                    predicateTop20 = [NSPredicate predicateWithFormat:@" NOT (stock_code in %@)",[Mytop20Array valueForKey:@"productid"]];
                    [compoundFilterArr addObject:predicateTop20];
                }

                continue;
            }
            else  if ([[[dic valueForKey:@"identifier"] lowercaseString] isEqualToString:@"invoiced"] && [[dic valueForKey:@"state"] integerValue]>0){
                NSPredicate *predicateInvoice;
                NSMutableArray *arrproducts = [NSMutableArray array];
                [[[[_customerInfo valueForKeyPath:@"iheads.invoicelines"] allObjects] valueForKey:@"product_code"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [arrproducts addObjectsFromArray:obj];
                }];

                if([[dic valueForKey:@"state"] integerValue]==1 && [arrproducts count]>0){
                    predicateInvoice = [NSPredicate predicateWithFormat:@" stock_code in %@",arrproducts];
                    [compoundFilterArr addObject:predicateInvoice];
                }else if([[dic valueForKey:@"state"] integerValue]==2 && [arrproducts count]>0){
                    predicateInvoice = [NSPredicate predicateWithFormat:@" NOT (stock_code in %@)",arrproducts];
                    [compoundFilterArr addObject:predicateInvoice];
                }
                continue;
            }
            else if ([[[dic valueForKey:@"identifier"] lowercaseString] isEqualToString:@"outstanding"] && [[dic valueForKey:@"state"] integerValue]>0){
                NSPredicate *predicateOutstanding;
                NSMutableArray *arrproducts = [NSMutableArray array];
                [[[[_customerInfo valueForKeyPath:@"oheads.orderlines"] allObjects] valueForKey:@"product_code"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [arrproducts addObjectsFromArray:obj];
                }];
                if([[dic valueForKey:@"state"] integerValue]==1 && [arrproducts count]>0){
                    predicateOutstanding = [NSPredicate predicateWithFormat:@" stock_code in %@",arrproducts];
                    [compoundFilterArr addObject:predicateOutstanding];
                }else if([[dic valueForKey:@"state"] integerValue]==2 && [arrproducts count]>0){
                    predicateOutstanding = [NSPredicate predicateWithFormat:@" NOT (stock_code in %@)",arrproducts];
                    [compoundFilterArr addObject:predicateOutstanding];
                }
                continue;
            }
            else if ( [[[dic valueForKey:@"identifier"] lowercaseString] isEqualToString:@"out of stock"] && [[dic valueForKey:@"state"] integerValue]>0){
                NSPredicate *predicateOutOfStock;
                
                //*****
                //NSArray *filterArr=[[values valueForKey:@"filter"]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==1 || state==2"]];
                
                if([[dic valueForKey:@"state"] integerValue]==1 && ![[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] isEqual:[NSNull null]]  && [[[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] stringByTrimmingCharactersInSet:   [NSCharacterSet whitespaceCharacterSet]] length]>0){
                    
                    predicateOutOfStock=[NSPredicate predicateWithFormat:@"%K <= 0",[[[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString] ];//<=
                    [compoundFilterArr addObject:predicateOutOfStock];
                }else if([[dic valueForKey:@"state"] integerValue]==2 && ![[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] isEqual:[NSNull null]] && [[[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] stringByTrimmingCharactersInSet:
                                                                           [NSCharacterSet whitespaceCharacterSet] ] length]>0){
                    predicateOutOfStock=[NSPredicate predicateWithFormat:@"%K > 0",[[[priceConfigDict valueForKey:@"usefieldtodefineoutofstock"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString]];
                    [compoundFilterArr addObject:predicateOutOfStock];
                }
                /*else if([filterArr count]==1 && [[[filterArr firstObject] valueForKey:@"label"] isEqualToString:@"out of stock"] ){
                    predicateOutOfStock = [NSPredicate predicateWithFormat:@" stock_code =''"];
                    [compoundFilterArr addObject:predicateOutOfStock];
                }*/
                
                
                continue;
            }
            else if ([[[dic valueForKey:@"identifier"] lowercaseString] isEqualToString:@"current"] && _transactionInfo && [[dic valueForKey:@"state"] integerValue]>0) {
                NSPredicate *predicateCurrent;
                //*****
                //NSArray *filterArr=[[values valueForKey:@"filter"]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==1 || state==2"]];
                
                if([[dic valueForKey:@"state"] integerValue]==1 ){//&& [[_transactionInfo valueForKey:@"orderlinesnew"] count]>0){
                    predicateCurrent = [NSPredicate predicateWithFormat:@" stock_code in %@",[_transactionInfo valueForKeyPath:@"orderlinesnew.productid"]];
                    [compoundFilterArr addObject:predicateCurrent];

                }else if([[dic valueForKey:@"state"] integerValue]==2){// && [[_transactionInfo valueForKey:@"orderlinesnew"] count]>0){
                    predicateCurrent = [NSPredicate predicateWithFormat:@" NOT (stock_code in %@)",[_transactionInfo valueForKeyPath:@"orderlinesnew.productid"]];
                    [compoundFilterArr addObject:predicateCurrent];
                }
                /*else if([filterArr count]==1 && [[[filterArr firstObject] valueForKey:@"label"] isEqualToString:@"current"] ){
                    predicateCurrent = [NSPredicate predicateWithFormat:@" stock_code =''"];
                    [compoundFilterArr addObject:predicateCurrent];
                }*/

                continue;
            }
            else if ([[[dic valueForKey:@"identifier"] lowercaseString] isEqualToString:@"quote"] && _transactionInfo && [[dic valueForKey:@"state"] integerValue]>0) {

                NSArray *array=[[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderlinetype=='Q'"]];

                //*****
                NSArray *filterArr=[[values valueForKey:@"filter"]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state==1 || state==2"]];
                
                
                NSPredicate *predicateCurrent;
                if([[dic valueForKey:@"state"] integerValue]==1 && [array count]>0 ){
                    predicateCurrent = [NSPredicate predicateWithFormat:@" stock_code in %@",[array valueForKey:@"productid"]];
                    [compoundFilterArr addObject:predicateCurrent];

                }else if([[dic valueForKey:@"state"] integerValue]==2 && [array count]>0){
                    predicateCurrent = [NSPredicate predicateWithFormat:@" NOT (stock_code in %@)",[array valueForKey:@"productid"]];
                    [compoundFilterArr addObject:predicateCurrent];
                }else if([filterArr count]==1 && [[[filterArr firstObject] valueForKey:@"label"] isEqualToString:@"Quote"] ){
                    predicateCurrent = [NSPredicate predicateWithFormat:@" stock_code =''"];
                    [compoundFilterArr addObject:predicateCurrent];
                }

                continue;
            }
            else {
                NSArray *components = [strPredicate componentsSeparatedByCharactersInSet:charSet];
                NSString *lastWord = components.lastObject;
                if([[dic valueForKey:@"state"] integerValue]==1){
                    if ([strPredicate length]>0 && count!=0){
                        if ([lastWord isEqualToString:@"and"] || [lastWord isEqualToString:@"||"])
                            [strPredicate substringToIndex:[strPredicate length]-1];

                        addprefix=@" ||";
                    }
                    if (count==0)
                        strPredicate = [strPredicate stringByAppendingFormat:@"%@ status contains[cd] '%@' ",addprefix,[dic valueForKey:@"identifier"]];
                    else
                        strPredicate = [strPredicate stringByAppendingFormat:@"%@ status contains[cd] '%@' ",addprefix,[dic valueForKey:@"identifier"]];
                    count=1;
                }else if ([[dic valueForKey:@"state"] integerValue]==2){


                    if ([strPredicate length]>0  && count!=0){
                        if ([lastWord isEqualToString:@"and"] || [lastWord isEqualToString:@"||"])
                            [strPredicate substringToIndex:[strPredicate length]-1];

                        addprefix=@" and";
                    }

                    if (count==0)
                        strPredicate = [strPredicate stringByAppendingFormat:@"%@ NOT status contains[cd] '%@' ",addprefix,[dic valueForKey:@"identifier"]];
                    else
                        strPredicate = [strPredicate stringByAppendingFormat:@"%@ NOT status contains[cd] '%@' ",addprefix,[dic valueForKey:@"identifier"]];
                    count=1;
                }


               // if ([strPredicate length]>0 && [[values valueForKey:@"filter"] count]==indexCount && ![[strPredicate substringFromIndex:[strPredicate length] - 1] isEqualToString:@")"])
                 //   strPredicate = [strPredicate stringByAppendingFormat:@")"];
            }
        }
    }

    //***       Category Working
    // if ([strPredicate length]>0)  addprefix=@" and";
    if ([values valueForKey:@"category"]) {
//        count=0;
//        indexCount=0;
        //for (NSDictionary* dic in  [values valueForKey:@"category"]) {
        if ([[values valueForKey:@"category"] count]>0) {

            //Category
            NSMutableArray *predicatesArr=[[NSMutableArray alloc] init];

            NSPredicate * PredicateconStr1;
            NSString *conStr1=@"";
            for(NSString *catID in [[[values valueForKey:@"category"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                conStr1= [conStr1 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }

            if([conStr1 length]>0){
                conStr1 = [conStr1 substringToIndex:[conStr1 length] - 1];//remove last ,
                NSArray *tempArray=[conStr1 componentsSeparatedByString:@","];
                PredicateconStr1 =[NSPredicate predicateWithFormat:@" category in %@",tempArray];
                [predicatesArr addObject:PredicateconStr1];

            }

            //NOT
            NSString *conStr2=@"";
            NSPredicate * PredicateconStr2;
            for(NSString *catID in [[[values valueForKey:@"category"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                conStr2= [conStr2 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }

            if([conStr2 length]>0){
                conStr2 = [conStr2 substringToIndex:[conStr2 length] - 1];//remove last ,
                NSArray *tempArray=[conStr2 componentsSeparatedByString:@","];
                PredicateconStr2 =[NSPredicate predicateWithFormat:@" NOT (category in %@)",tempArray];
                [predicatesArr addObject:PredicateconStr2];
            }


            // Add predicates to array
            NSPredicate *compoundPredicate = nil;
            if([predicatesArr count]==1)
                compoundPredicate = [predicatesArr lastObject];
            else if ([predicatesArr count]>1)
                compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArr];

            if (compoundPredicate)
                [compoundFilterArr addObject:compoundPredicate];
        }
    }//END

    //***       Sub-Cat Working
    //if ([strPredicate length]>0)   addprefix=@" and";
    if ([values valueForKey:@"sub-cat"]) {

        //Sub Category
        NSMutableArray *predicatesArr=[[NSMutableArray alloc] init];
        NSPredicate * PredicateconStr1;
        NSString *conStr1=@"";
        for(NSString *catID in [[[values valueForKey:@"sub-cat"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
            conStr1= [conStr1 stringByAppendingString:[NSString stringWithFormat:@"%@,",catID]];
        }

        if([conStr1 length]>0){
            conStr1 = [conStr1 substringToIndex:[conStr1 length] - 1];//remove last ,
            NSArray *tempArray=[conStr1 componentsSeparatedByString:@","];
            PredicateconStr1 =[NSPredicate predicateWithFormat:@" grp2 in %@",tempArray];
            [predicatesArr addObject:PredicateconStr1];
        }

        //NOT
        NSString *conStr2=@"";
        NSPredicate * PredicateconStr2;
        for(NSString *catID in [[[values valueForKey:@"sub-cat"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
            conStr2= [conStr2 stringByAppendingString:[NSString stringWithFormat:@"%@,",catID]];
        }

        if([conStr2 length]>0){
            conStr2 = [conStr2 substringToIndex:[conStr2 length] - 1];//remove last ,
            NSArray *tempArray=[conStr2 componentsSeparatedByString:@","];
            PredicateconStr2 =[NSPredicate predicateWithFormat:@" NOT (grp2 in %@)",tempArray];
            [predicatesArr addObject:PredicateconStr2];
        }

        // Add predicates to array
        NSPredicate *compoundPredicate = nil;
        if([predicatesArr count]==1)
            compoundPredicate = [predicatesArr lastObject];
        else if ([predicatesArr count]>1)
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArr];

        if (compoundPredicate)
            [compoundFilterArr addObject:compoundPredicate];
    }//END

    //extra Color filter
    if ([values valueForKey:@"stock"]) {
        for (int i=0; i<3; i++) {
            NSString* str=[[[values valueForKey:@"stock"] objectAtIndex:i] lowercaseString];

            switch (i) {
                case 0:
                    if(![str isEqualToString:@"select"] ){

                        NSString* retStr;
                        if ([str isEqualToString:@"physical"]) {
                            retStr=@"qty_onhand";
                        }else if ([str isEqualToString:@"free"]){
                            retStr=@"qty_free";
                        }else if ([str isEqualToString:@"available"]){
                            retStr=@"stockavailability";
                        }else if ([str isEqualToString:@"all"])
                            continue;

                        //MIN limit From
                        addprefix=@"";
                        if ([strPredicate length]>0)addprefix=@" and";//Check predicate

                        if ([[values valueForKey:@"stock"] count]>=5) {
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ > %0.2f ",addprefix,retStr,[[[values valueForKey:@"stock"] objectAtIndex:4]doubleValue]];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }else{
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ > 0 ",addprefix,retStr];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }

                        //Max limit  TO
                        addprefix=@"";
                        if ([strPredicate length]>0)addprefix=@" and";//Check predicate

                        if ([[values valueForKey:@"stock"] count]>=6) {
                            NSString *strNew;
                            strNew=[NSString stringWithFormat:@"%@ %@ < %0.2f ",addprefix,retStr,[[[values valueForKey:@"stock"] objectAtIndex:5]doubleValue]];

                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }


                    }
                    break;

                case 1:{        //Check Acending/Descending
                    SORTDes=YES;
                    if(![str isEqualToString:@"select"] ){

                        if ([str isEqualToString:@"descending"])
                            SORTDes=NO;
                    }
                }
                    break;

                case 2://Check Price Range
                    if(![str isEqualToString:@"select"] ){

                        //MIN limit From  Price range
                        addprefix=@"";
                        if ([strPredicate length]>0)addprefix=@" and";//Check predicate

                        if ([[values valueForKey:@"stock"] count]>=7 && ![[[values valueForKey:@"stock"] objectAtIndex:6] isEqualToString:@""]) {
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ > %0.2f ",addprefix,str,[[[values valueForKey:@"stock"] objectAtIndex:6]doubleValue]];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }else{
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ > 0 ",addprefix,str];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }

                        //Max limit  TO  Price range
                        addprefix=@"";
                        if ([strPredicate length]>0)addprefix=@" and";//Check predicate

                        if ([[values valueForKey:@"stock"] count]>=8 && ![[[values valueForKey:@"stock"] objectAtIndex:7] isEqualToString:@""]) {
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ < %0.2f ",addprefix,str,[[[values valueForKey:@"stock"] objectAtIndex:7]doubleValue]];

                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }

                    }
                    break;


                case 3://EXtra Filter
                    if(![str isEqualToString:@"select"] ){

                        //MIN limit From  Price range
                        addprefix=@"";
                        if ([strPredicate length]>0)addprefix=@" and";//Check predicate

                        if ([[values valueForKey:@"stock"] count]>=9 && ![[[values valueForKey:@"stock"] objectAtIndex:8] isEqualToString:@""]) {
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ > %0.2f ",addprefix,str,[[[values valueForKey:@"stock"] objectAtIndex:8]doubleValue]];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }else{
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ > 0 ",addprefix,str];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }

                        //Max limit  TO  Price range
                        addprefix=@"";
                        if ([strPredicate length]>0)addprefix=@" and";//Check predicate

                        if ([[values valueForKey:@"stock"] count]>=10 && ![[[values valueForKey:@"stock"] objectAtIndex:9] isEqualToString:@""]) {
                            NSString *strNew=[NSString stringWithFormat:@"%@ %@ < %0.2f ",addprefix,str,[[[values valueForKey:@"stock"] objectAtIndex:9]doubleValue]];
                            strPredicate = [strPredicate stringByAppendingString:strNew];
                        }

                    }
                    break;


                default:
                    break;
            }


        }

    }//ENDED


    if ([compoundFilterArr count]>0) {
        if ([strPredicate length]>0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:strPredicate];
            [compoundFilterArr addObject:predicate];
        }

    }else if ([strPredicate length]>0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:strPredicate];
        [compoundFilterArr addObject:predicate];
        //[[_fetchedResultsController fetchRequest] setPredicate:predicate];
    }

    //Added all Filters in compoundArr

    NSMutableArray *arrSort = [NSMutableArray array];
    [[sortByFieldName componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc] initWithKey:obj ascending:SORTDes];
        [arrSort addObject:sortDescriptor];
    }];




    if ([compoundFilterArr count]>0){
        NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:compoundFilterArr];

        /*if (barCodeSearchSts) {
            NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"searchdateandtime" ascending:NO selector:nil];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSort, nil];
            [[_fetchedResultsController fetchRequest] setSortDescriptors:sortDescriptors];
        }else*/
            [[_fetchedResultsController fetchRequest] setSortDescriptors:arrSort];
        [[_fetchedResultsController fetchRequest] setPredicate:andPredicate];
    }else {
        /*if (barCodeSearchSts) {
            NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"searchdateandtime" ascending:NO selector:nil];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSort, nil];
            [[_fetchedResultsController fetchRequest] setSortDescriptors:sortDescriptors];
        }else*/
            [[_fetchedResultsController fetchRequest] setSortDescriptors:arrSort];
        [[_fetchedResultsController fetchRequest] setPredicate:[self getPredicateString:0]];
    }


    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    else{
        [self loadnavigationtitle];
    }

    [[self tblProduct] reloadData];
}


#pragma mark - ProductTVCellDelegate
-(IBAction)btnQuantityClicked:(UIButton*)sender Cell:(ProductTableViewCell *)cell{
    
    UIButton *btnPack=sender;
    NSArray* arrpacks = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];
    NSInteger icounter=[arrpacks count];
    UIButton* btnpackTotal = [[cell.PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];
    
    if (!_transactionInfo) {
        
        [btnpackTotal setTitle:[NSString stringWithFormat:@"%li",(long)[[btnPack titleForState:UIControlStateNormal] integerValue]] forState:UIControlStateNormal];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order Info:" message:@"Please select customer before ordering any product!" delegate:nil cancelButtonTitle:alertBtnDismiss otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    DebugLog(@"%i    %i",[[btnpackTotal titleForState:UIControlStateNormal] integerValue],[[btnPack titleForState:UIControlStateNormal] integerValue]);
    
    NSInteger total=0;
    if ([btnpackTotal.backgroundColor isEqual:btnGreenColor]) {
         total=[[btnPack titleForState:UIControlStateNormal] integerValue];
    }else
        total=[[btnpackTotal titleForState:UIControlStateNormal] integerValue]+[[btnPack titleForState:UIControlStateNormal] integerValue];
   
    
    [btnpackTotal setTitle:[NSString stringWithFormat:@"%li",(long)total] forState:UIControlStateNormal];

    
    if (sender.tag==[arrpacks count])
    {
        total=[[btnPack titleForState:UIControlStateNormal] integerValue];
    }


    UILabel* lblpack = [[cell.PackLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btnPack tag]]] lastObject];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"label==%@",lblpack.text];//@"label=='%@'",lblpack.text];field
  //  NSArray *filterArr=[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
    NSArray *filterArr=[[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:predicate];
    if ([filterArr count]>0) 
        oLinePackType=[[[filterArr lastObject] valueForKey:@"field"]lowercaseString];//@"qtyfield"];//[lblpack.text lowercaseString];
    else
        oLinePackType=[lblpack.text lowercaseString];
        

    
    NSString *deliveryAdd=[_customerInfo valueForKey:@"delivery_address"];
    double orderDisc  =0;
    NSDate *deliveryDate= nil;
    NSDate *expectedDate= nil;
    
    if(_transactionInfo){
        
        deliveryAdd=[_transactionInfo valueForKey:@"deliveryaddressid"];//update delivery Add
        NSIndexPath *indexPath = [_tblProduct indexPathForCell:cell];
        NSManagedObject *proRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];

        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [proRecord valueForKey:@"stock_code"]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
        NSArray *descriptor = @[sortDescriptor];
        NSArray *oLineArr = [[[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred]sortedArrayUsingDescriptors:descriptor]; //Array sort bases of line no;

        NSString *orderType=@"O";
        double orderPrice=[[proRecord valueForKey:@"Price1"] doubleValue];
        //        if ([arrSidebar count]>0) {
        //            orderPrice=[[[arrSidebar firstObject] valueForKey:@"value"] doubleValue];
        //        }

        if (cell.orderPrice >0) {
            orderPrice=cell.orderPrice;
        }

        BOOL insert=NO;
        if ([oLineArr count]>0) {
            
            if (![[oLinePackType lowercaseString] isEqualToString:[[[oLineArr firstObject] valueForKey:@"orderpacktype"] lowercaseString]]){
                total=[[btnPack titleForState:UIControlStateNormal] integerValue];
                [btnpackTotal setTitle:[NSString stringWithFormat:@"%li",(long)total] forState:UIControlStateNormal];
            }//END
            
           /* orderType   =[[oLineArr firstObject] valueForKey:@"orderlinetype"];
            orderPrice  =[[[oLineArr firstObject] valueForKey:@"saleprice"]doubleValue];
            deliveryAdd =[[oLineArr firstObject] valueForKey:@"deliveryaddresscode"];//default alredy set delivery Address
            orderDisc   =[[[oLineArr firstObject] valueForKey:@"disc"] doubleValue];
            expectedDate=[[oLineArr firstObject] valueForKey:@"expecteddate"];
            deliveryDate=[[oLineArr firstObject] valueForKey:@"requireddate"];
            
            
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [proRecord valueForKey:@"stock_code"]];
            NSArray *filteredArrOline = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            
            NSNumber *maxlineno= [filteredArrOline valueForKeyPath:@"@max.lineno"];
            NSInteger line=[maxlineno integerValue];
            NSString* LineNo=[NSString stringWithFormat:@"%d",line+1];
            
            insert= [OrderHelper addOLinewithorderNumber:[_transactionInfo valueForKey:@"orderid"] productInfo:proRecord orderQty:[NSString stringWithFormat:@"%li",(long)total] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:expectedDate oLineType:orderType oLinePackType:oLinePackType LineNumber:LineNo TransactionInfo:_transactionInfo];
            */
       
           //Updated Code
            NSInteger totQty=total;
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && lineno==%@", [proRecord valueForKey:@"stock_code"],@"1"];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            NSManagedObject *obj=[filteredArr lastObject];
            
            
            NSInteger totRowQty=[[oLineArr valueForKeyPath:@"@sum.quantity"] integerValue];
            NSInteger firstrowQty=0;
           
            NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
            firstrowQty=totQty-remQty;
            
            
            
            
            if (firstrowQty>0) {
                deliveryAdd=[obj valueForKey:@"deliveryaddresscode"];
                deliveryDate=[obj valueForKey:@"requireddate"];
                BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:proRecord  orderQty:[NSString stringWithFormat:@"%li",(long)firstrowQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:@"1"  TransactionInfo:self.transactionInfo];
                if(insert){
                    DebugLog(@"INSERT/Update 1 st row NEW ROW");
                    // reload bottom bar code
                    
                }
                
            }else{
                
                if (totQty<=0) {//Delete all rows
                    NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [proRecord valueForKey:@"stock_code"]];
                    NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                    for (NSManagedObject* oLineObj in filteredArr) {
                        [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                    }
                    
                    //[self changeGreenColor:btnPack totBtn:btnTot];//Change background color
                    
                    
                }else{// delete last object move quantity to 1 st row
                    
                    //  NSInteger firstRowUpdateval=totQty-totRowQty;
                    [obj setValue:[NSNumber numberWithInteger:totQty] forKey:@"quantity"];//update first row
                    [obj setValue:[NSNumber numberWithDouble:(orderPrice*totQty)] forKey:@"linetotal"];
                    
                    
                    NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"productid == %@ && lineno!=%@", [proRecord valueForKey:@"stock_code"],@"1"];
                    NSArray *RemfilteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate2];
                    for (NSManagedObject* oLineObj in RemfilteredArr) {//delete other row if any
                        [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                    }
                    
                   // [self changeBlueColor:btnPack totBtn:btnTot];//Change background color
                    
                }
                
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
            }
            //Update Ended
            
            
            
            
            
            
        
        
        }else{//First time Add Recods
             NSString* LineNo=@"1";
            insert= [OrderHelper addOLinewithorderNumber:[_transactionInfo valueForKey:@"orderid"] productInfo:proRecord  orderQty:[NSString stringWithFormat:@"%li",(long)total] orderPrice:orderPrice deliveryAdd:deliveryAdd deliveryDate:[NSDate date] oLineType:orderType oLinePackType:oLinePackType LineNumber:LineNo TransactionInfo:_transactionInfo ];
        }
        if(insert){
            DebugLog(@"Product controlerinserted %li",total);
            [btnpackTotal setBackgroundColor:btnBlueColor];
            [btnpackTotal setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

            [self loadArraysData];//Load current and My Top 20
            
            //Check order type
            if(_transactionInfo)
                [self changeOrderType:_transactionInfo];
        }
    }
}

-(void)btnQuantity_longPress:(UIButton* )btnsender Cell:(ProductTableViewCell *)cell{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:btnsender forKey:@"btnsender"];
    [dict setObject:cell forKey:@"Cell"];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeQuantity:) userInfo:dict repeats:YES];
}

-(void)btnQuantity_longPressEnd:(UIButton*)btnsender  Cell:(UITableViewCell*)cell{
    [timer invalidate];
    timer=nil;
}


//Remove button quantity from quick Order panel
-(void)removeQuantity:(NSTimer *)timerObj{

    NSDictionary *dict=timerObj.userInfo;

    UIButton *btnPack=[dict objectForKey:@"btnsender"];
    ProductTableViewCell *cell=[dict objectForKey:@"Cell"];

    NSArray* arrpacks = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];
    NSInteger icounter=[arrpacks count];

    //Check oLine Pack type
    UILabel* lblpack = [[cell.PackLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btnPack tag]]] lastObject];
    NSString *PackType=[lblpack.text lowercaseString];

    UIButton* btnpackTotal = [[cell.PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",icounter]] lastObject];

    NSInteger remianQty=([[btnpackTotal titleForState:UIControlStateNormal] integerValue]-[[btnPack titleForState:UIControlStateNormal] integerValue]);
    NSInteger packQty=[[btnPack titleForState:UIControlStateNormal] integerValue];
    if (remianQty < packQty)//if remaingqty less then pack qty
        return;


    if(_transactionInfo){

        NSIndexPath *indexPath = [_tblProduct indexPathForCell:cell];
        NSManagedObject *proRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];

        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [proRecord valueForKey:@"stock_code"]];
        NSArray *oLineArr = [[[_transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];

        if ([oLineArr count]>0) {
            NSInteger packQ=[[btnPack titleForState:UIControlStateNormal] integerValue];
            
            if ([[PackType lowercaseString] isEqualToString:[[[oLineArr firstObject] valueForKey:@"orderpacktype"] lowercaseString]] && remianQty >= packQ){

                [[oLineArr firstObject] setValue:[NSNumber numberWithInteger:remianQty ] forKey:@"quantity"];

                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }else
                    [btnpackTotal setTitle:[NSString stringWithFormat:@"%li",(long)remianQty] forState:UIControlStateNormal];
            }

        }

    }else{
        [btnpackTotal setTitle:[NSString stringWithFormat:@"%li",(long)remianQty] forState:UIControlStateNormal];

    }
    
    //Check order type
    if(_transactionInfo)
        [self changeOrderType:_transactionInfo];
}

#pragma mark -  Control Generated Events
-(void)doSelectCustomer:(UIButton *)sender{
    if (_customerInfo) {
        CustomerDetailMultipleViewController *customerDetailMultipleController = [self.storyboard  instantiateViewControllerWithIdentifier:@"toCustomerDetailMultipleViewController"];
        [customerDetailMultipleController setCustomerInfo:_customerInfo];
        customerDetailMultipleController.HideCreateTransactions=YES;
        [self.navigationController pushViewController: customerDetailMultipleController animated:YES];
    }
    else
        [self performSegueWithIdentifier:@"showCustomerFromProdSegue" sender:sender];
}

- (IBAction)scanNow:(UIButton *)sender {
    
    [self checkCameraPermission];
    
    
}

- (void)checkCameraPermission{
    // *** check for hardware availability ***
    BOOL isCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(!isCamera)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"mSeller" message:@"Camera not detected Please go to settings and on camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
   BOOL cameraOpenStatus=YES;
    
    // *** Store camera authorization status ***
    AVAuthorizationStatus _cameraAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (_cameraAuthorizationStatus)
    {
        case AVAuthorizationStatusAuthorized:
        {
            _cameraAuthorizationStatus = AVAuthorizationStatusAuthorized;
            // *** Camera is accessible, perform any action with camera ***
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            DebugLog(@"%@", @"Camera access not determined. Ask for permission.");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 if(granted)
                 {
                     DebugLog(@"Granted access to %@", AVMediaTypeVideo);
                     // *** Camera access granted by user, perform any action with camera ***
                 }
                 else
                 {
                     DebugLog(@"Not granted access to %@", AVMediaTypeVideo);
                     // *** Camera access rejected by user, perform respective action ***
                 }
             }];
            
            cameraOpenStatus=NO;
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            // Prompt for not authorized message & provide option to navigate to settings of app.
            dispatch_async( dispatch_get_main_queue(), ^{
                NSString *message = NSLocalizedString( @"My App doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"mSeller" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                   
//                    if(scanViewController){
//                        _btnScanNow.hidden = YES;
//                        _scanViewTopConstraint.constant = 0;
//                        [scanViewController.view removeFromSuperview];
//                        scanViewController = nil;
//                    }
                    
                }];
//UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                
                // Provide quick access to Settings.
                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alertController addAction:settingsAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            
            cameraOpenStatus=NO;
            
        }
            break;
        default:
            break;
    }
    
    
    if (cameraOpenStatus) {
        if(!isScanning){
            scanViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
            scanViewController.delegate = self;
            DebugLog(@" AAA--   %f  %f",scanViewController.view.frame.size.height,scanViewController.view.frame.size.width);
            [_viewScanning addSubview:scanViewController.view];
            
            _btnScanNow.hidden = YES;
           // _scanViewTopConstraint.constant = 206;
            _tabletopLayoutConstraint.constant =206;
            
            isScanning = YES;
            [_tblProduct setScrollEnabled:NO];
            
            
            return;
        }
        isScanning = NO;
        
        [self loadScanningView];
    }
    
}

- (IBAction)scanButtonClick:(id)sender{
    
    if([[kUserDefaults  objectForKey:@"isscanningactivated"] boolValue])
    {
        [kUserDefaults  setObject:[NSNumber numberWithBool:NO] forKey:@"isscanningactivated"];
    }
    else{
        [kUserDefaults  setObject:[NSNumber numberWithBool:YES] forKey:@"isscanningactivated"];
    }
    [kUserDefaults  synchronize];
    [self loadScanningView];
}

- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
    [_btnOverlay setHidden:YES];
}

#pragma mark - ScannerViewControllerDelegate
-(void)getScannedBarCodes:(NSMutableArray*)scannedArray{
    if ([scannedArray count]>0) {
        NSArray *barCodes = [_searchBar.text componentsSeparatedByString:@","];
       
       /* if ([_searchBar.text length]==0 && ![barCodes containsObject:[scannedArray lastObject]]) {
           _searchBar.text = [NSString stringWithFormat:@"%@%@",_searchBar.text,[scannedArray lastObject]];
        }else*/
        
        if(![barCodes containsObject:[scannedArray lastObject]]){
           
            
            NSString *newString = [NSString stringWithFormat:@",%@%@,",_searchBar.text,[scannedArray lastObject]];
            if ( [newString hasPrefix:@","]){//[[newString characterAtIndex:0] isEqualToString:@","] ) {
                newString  = [newString substringFromIndex:1];;
            }
            
            
            _searchBar.text = newString;//[NSString stringWithFormat:@",%@%@,",_searchBar.text,[scannedArray lastObject]];
        }
        [self searchBar:_searchBar textDidChange:_searchBar.text];
    }
    isScanning = NO;
    [self loadScanningView];
    
}

-(void)changeOrderType :(NSManagedObject *)transactionObj{
    
    //Call log change to order type
    if ([[transactionObj valueForKey:@"ordtype"] isEqualToString:@"C"] && [[transactionObj valueForKey:@"orderlinesnew"] count]>0 ) {
        [transactionObj setValue:@"O" forKey:@"ordtype"];
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        [kNSNotificationCenter postNotificationName:kOrderTypechange  object:self];
    }else if ( [[transactionObj valueForKey:@"orderlinesnew"] count]==0){
        
       /* [transactionObj setValue:@"C" forKey:@"ordtype"];
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        [kNSNotificationCenter postNotificationName:kOrderTypechange  object:self];*/
    }
}


 //For reload  product data when header discount added
-(void)reloadproductData :(NSNotification *) notification{
    if ([[notification name] isEqualToString:kReloadProduct]){
        [self fetchedResultsController];
    }
}


//For load Stockband table
- (NSMutableArray*)loadStockbandList{
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"STOCKBAND" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSError *error = nil;
    NSMutableArray *resultsSeq =[[NSMutableArray alloc]initWithArray: [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    return resultsSeq;
}

//Searching highlightText
-(void) highlightText:(NSString *)srcTxt {
    srcTxtLen =(int) srcTxt.length;
    int idx = 0;
    
    UIView *subviews = [_searchBar.subviews lastObject];
    UITextField *searchBarTextField =(id)[subviews.subviews objectAtIndex:1];
    while (idx<=(searchBarTextField.attributedText.length-srcTxtLen)) {
        NSRange srcRange = NSMakeRange(idx, srcTxtLen);
        if ([[searchBarTextField.attributedText.string substringWithRange:srcRange] isEqualToString:srcTxt]) {
            NSMutableAttributedString *tmpAttrTxt = [[NSMutableAttributedString alloc] initWithAttributedString:searchBarTextField.attributedText];
            [tmpAttrTxt addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:118/255.f green:168/255.f blue:244/255.f alpha:1.0] range:srcRange];
            searchBarTextField.attributedText = tmpAttrTxt;
            idx += srcTxtLen;
        } else {
            idx++;
        }
    }
    [_searchBar resignFirstResponder];
}

//Edit Product
-(void)loadEditIteamProduct:(NSInteger)indexNo{
    kAppDelegate.isEditTransactionItem=NO;
    UIButton *btn=[[UIButton alloc]init];
    btn.tag=indexNo;
    [self performSegueWithIdentifier:@"toProductMultipleSegment" sender:btn];
}


- (void) refreshCompanydata:(NSNotification *) notification{
    
    [_searchBar setText:@""];
}

@end
