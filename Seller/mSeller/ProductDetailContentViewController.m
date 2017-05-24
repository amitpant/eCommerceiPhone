//
//  ProductDetailContentViewController.m
//  mSeller
//
//  Created by Ashish Pant on 10/16/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductDetailContentViewController.h"
#import "ProductImageController.h"
#import "ProductNotesViewController.h"
#import "Numerickeypad.h"
#import "OrderHelper.h"
#import "CommonHelper.h"
#import "ProductImageViewController.h"
#import "ProductOrderPanel.h"
#import "Constants.h"


@interface ProductDetailContentViewController ()<UIPageViewControllerDelegate,UIGestureRecognizerDelegate,ProductImageControllerDelegate,NumericKeypadDelegate>{
    NSDictionary* priceConfigDict;//   fetch price Config
    NSDictionary* userConfigDic;
    NSInteger lastSelTag;
    NSString *salesPrice;
    NSString *orderType;;
    NSTimer  *timer;
    NSString *oLinePackType;
    NSString* stractualpath;
}

@property (weak, nonatomic) IBOutlet UILabel *lblProductCode;
@property (weak, nonatomic) IBOutlet UILabel *lblProductName;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblCategoryCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblSubCategoryCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblSubCategory;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblPriceCaptions;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblPriceValues;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblStockCaptions;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblStockValues;

@property (weak, nonatomic) IBOutlet UILabel *lblOnPurchaseOrderCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblOnPurchaseOrder;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *lblTopLine;
@property (weak, nonatomic) IBOutlet UIView *viewImage;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *priceView;



//for productDetailContent without history
@property (strong, nonatomic) UIPageViewController *pageViewController;


//Height LayoutConsstaint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fotterViewheightLayoutConstraint;

@property (strong, nonatomic) NSMutableArray *subItemsArray;
@property (weak, nonatomic) IBOutlet UIView *productImagesContainerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageControlHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomConstraint;

@end

@implementation ProductDetailContentViewController


-(void)reloadConfigData{
    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];

    userConfigDic = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        userConfigDic = [dic objectForKey:@"data"];

    
 //   [self loadViewWithSegmentIndex:_segmentedControlIndex];

    [self loadAllPageContent];
}

//LOAD orderPanel




-(void)load_footer{
    
    for (UIView* b in self.bottomView.subviews)
    {
        [b removeFromSuperview];
    }
    
    
     NSManagedObject *record1=_productDetail;
    
 
    ProductOrderPanel *ordPanel =  (ProductOrderPanel *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProductOrderPanel"];
    [ordPanel setRecord:record1];
    [ordPanel setCustomerInfo:self.customerInfo];
    [ordPanel setTransactionInfo:self.transactionInfo];
    
    ordPanel.view.frame = CGRectMake(0, 0, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    [self addChildViewController:ordPanel];
    [ordPanel didMoveToParentViewController:self];
    [self.bottomView addSubview:ordPanel.view];
    
    
    NSArray* arrpacks = [priceConfigDict objectForKey:@"orderpanellabels"];
    if ([arrpacks count]==3) {
        
        _fotterViewheightLayoutConstraint.constant=_fotterViewheightLayoutConstraint.constant-15;
    }else if ([arrpacks count]<=2){
        
        _fotterViewheightLayoutConstraint.constant=_fotterViewheightLayoutConstraint.constant-28;
    }
}

-(void)loadAllPageContent{
    [self load_footer];

    [self loadConfigBasedLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    lastSelTag=-1;

     stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];
    
    _lblProductCode.text=[_productDetail valueForKey:@"stock_code"];
    _lblProductName.text=[_productDetail valueForKey:@"gdescription"];

    _tvDescription.text=[_productDetail valueForKey:@"longdesc"];
    _tvDescription.textContainerInset = UIEdgeInsetsZero;
    _tvDescription.textContainer.lineFragmentPadding = 0;

    _lblCategory.text=[[_productDetail valueForKey:@"group1"] valueForKey:@"gdescription"];//[_productDetail valueForKey:@"category"];
   
    _lblSubCategory.text=[_productDetail valueForKey:@"grp2"];

    _productImagesContainerView.layer.cornerRadius = 4.0;

    _lblOnPurchaseOrder.text=[[_productDetail valueForKey:@"totbo"] stringValue];

    _subItemsArray=[[NSMutableArray alloc]init];

    self.view.alpha = 0.5;

    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(dismissKeyboard)];
    [_topView addGestureRecognizer:tap];
    
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshOrderpanelPrice:) name:kSelectedPriceRow object:nil];

    // check for App, company and user level configuration (privileges)
    //[self reloadConfigData];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self performSelector:@selector(reloadConfigData) withObject:nil afterDelay:0.00];
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {

    }];
    
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    
    
    
    
    [self loadViewWithSegmentIndex:_segmentedControlIndex];
    
    //For reload  product data when header discount added
    [kNSNotificationCenter addObserver:self  selector:@selector(reloadproductData:) name:kReloadProduct object:nil];

    if (![kUserDefaults  boolForKey:@"PriceDisplay"]) {
        [_priceView setHidden:YES];
    }
    
}

-(void)loadConfigBasedLayout{
    
    NSDictionary *dict= [[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]] lastObject];
    NSString *defPrice=prodDefaultPrice;
    if (dict) {
        defPrice=[dict valueForKey:@"field"];
    }
    //coded by Amit Pant on 20151218
    
    //  After customer selection Change selected Price Default before Price selection selection
    if(![[priceConfigDict objectForKey:@"pricetablabels"] isEqual:[NSNull null]] && self.customerInfo ){
        
        NSString *symbol=[CommonHelper getCurrSymbolWithCurrCode:[self.customerInfo valueForKey:@"curr"]];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"label CONTAINS %@ ",symbol];
        NSArray *filterArr=[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
        if ([filterArr count]>0) {
            defPrice=[[filterArr firstObject] valueForKey:@"field"];
        }
    }//ended
    
    
    //price label
    NSArray* arrSidebar;
    
    
    if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_productDetail valueForKey:@"stock_code"]];
        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        
        if ([filteredArr count]>0){
            NSManagedObject *obj=[filteredArr firstObject];
            arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:obj PriceConfig:priceConfigDict UserConfig:userConfigDic] objectForKey:@"sidebar"];
        }else
            arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDic] objectForKey:@"sidebar"];
    }else
     arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDic] objectForKey:@"sidebar"];
    
    
    
    __block NSInteger priceCounter=0;

    [arrSidebar enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (priceCounter>1) {
            return ;
        }
        
        
        UILabel *lblPriceCaption = [self.lblPriceCaptions objectAtIndex:priceCounter];
        UILabel *lblPriceValue = [self.lblPriceValues objectAtIndex:priceCounter];
        if (lblPriceCaption) {
            @try {
                lblPriceCaption.hidden=NO;
                lblPriceValue.hidden=NO;
                lblPriceCaption.text=[obj valueForKey:@"caption"];
                lblPriceValue.text = [obj valueForKey:@"showPrice"];//[CommonHelper getCurrencyFormatWithCurrency:nil Value:[[obj valueForKey:@"value"] doubleValue]];
            }
            @catch (NSException *exception) {

            }
            @finally {

            }
        }
        priceCounter++;
    }];

    // to hide unused values
    for (NSInteger i=priceCounter; i<2; i++){

        UILabel *lblPriceCaption=[self.lblPriceCaptions objectAtIndex:i];
        UILabel *lblPriceValue=[self.lblPriceValues objectAtIndex:i];
        lblPriceCaption.hidden=YES;
        lblPriceValue.hidden=YES;
    }

    // correction needed in above block comment by Amit

    // code modified by Satish
    //stock labels
    __block NSInteger stockCounter =  3;
    [[priceConfigDict objectForKey:@"stocklabels"] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        stockCounter--;
        UILabel *lblStockCaption=[self.lblStockCaptions objectAtIndex:stockCounter];
        UILabel *lblStockValue=[self.lblStockValues objectAtIndex:stockCounter];
        if(lblStockCaption){

            @try {
                lblStockCaption.hidden=NO;
                lblStockValue.hidden=NO;
                lblStockCaption.text=[obj objectForKey:@"label"];
                lblStockValue.text = [NSString stringWithFormat:@"%@",[_productDetail valueForKey:[[obj objectForKey:@"field"] lowercaseString]]];
            }
            @catch (NSException *exception) {

            }
            @finally {

            }
        }
        if(stockCounter<=0) *stop = YES;

    }];

    // to hide unused values
    for (int i=0; i<stockCounter; i++){
        UILabel *lblStockCaption=[self.lblStockCaptions objectAtIndex:i];
        UILabel *lblStockValue=[self.lblStockValues objectAtIndex:i];
        lblStockCaption.hidden=YES;
        lblStockValue.hidden=YES;
    }


    //    for (int i=0; i<3; i++) {
    //        UILabel *lblStockCaption=[self.lblStockCaptions objectAtIndex:i];
    //        UILabel *lblStockValue=[self.lblStockValues objectAtIndex:i];
    //        if (arrstocklabels.count>0) {
    //            lblStockCaption.text=[[arrstocklabels objectAtIndex:i] objectForKey:@"label"];
    //            lblStockValue.text=[_productDetail valueForKey:[[[arrstocklabels objectAtIndex:i] objectForKey:@"field"] lowercaseString]];
    //
    //            lblStockCaption.hidden=[[[arrstocklabels objectAtIndex:i] objectForKey:@"displayonimagescreen"] boolValue];
    //            lblStockValue.hidden=[[[arrstocklabels objectAtIndex:i] objectForKey:@"displayonimagescreen"] boolValue];
    //        }
    //        else{
    //            lblStockCaption.hidden=YES;
    //            lblStockValue.hidden=YES;
    //        }
    //    }
    //code ended here
}


- (NSManagedObject *)find_OrderObject{
    
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
   
    NSPredicate *predicate;
    if ([[self.transactionInfo valueForKey:@"orderid"] length]==0) {
        predicate = [NSPredicate predicateWithFormat:@"productid == %@",[_productDetail valueForKey:@"stock_code"]];
    }else
        predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && productid == %@",[self.transactionInfo valueForKey:@"orderid"],[_productDetail valueForKey:@"stock_code"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return [resultsSeq lastObject];
    
    
}


-(void)loadViewWithSegmentIndex:(NSInteger)index{
    [_subItemsArray removeAllObjects];

    // Create page view controller
    BOOL isNewCreated = NO;
    if(!_pageViewController){
        isNewCreated = YES;
        _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonPageViewController"];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
    }
    
    if(index==0){
        
        
        NSString* tstr = [NSString stringWithFormat:@"%@~",[[CommonHelper getStringByRemovingSpecialChars:[_productDetail valueForKey:@"stock_code"]] lowercaseString]];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@",tstr];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:stractualpath error:nil];
        NSArray *moreArr=[dirContents filteredArrayUsingPredicate:fltr];
        
        if ([moreArr count]>1) {
            NSString* tstr1 = [NSString stringWithFormat:@"%@",[[CommonHelper getStringByRemovingSpecialChars:[_productDetail valueForKey:@"stock_code"]] lowercaseString]];
            fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@ || self BEGINSWITH %@",tstr1,tstr];
            _subItemsArray=[NSMutableArray arrayWithArray:[dirContents filteredArrayUsingPredicate:fltr]];
            _pageControl.numberOfPages=[_subItemsArray count];
        
        }
        
        
    }

    if(index==4){
        [_subItemsArray addObject:@"Price"];
        [_subItemsArray addObject:@"PriceCustom"];
       
        if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"headerdiscountenabled" ] boolValue]){//manage by webconfig key headerdiscountenabled
        //if (self.customerInfo) {
            [_subItemsArray addObject:@"PriceDiscount"];
        }
        
        
        _pageControl.numberOfPages = [_subItemsArray count];//2;
        
    }else if(index==0 && [_subItemsArray count]>0){
        
    }else{
        [_subItemsArray addObject:@"General Info"];
        _pageControl.numberOfPages = 1;
    }

    _pageViewController.view.frame = CGRectMake(0, 0, _productImagesContainerView.bounds.size.width, _productImagesContainerView.bounds.size.height);

    if(_pageControl.numberOfPages>1){
        _pageControl.hidden = NO;
        _containerBottomConstraint.constant=20.0;
    }
    else{
        _pageControl.hidden = YES;
        _containerBottomConstraint.constant=5.0;
    }

    if([_pageViewController.view superview] && ![[_pageViewController.view superview] isEqual:_productImagesContainerView]){
        [_productImagesContainerView addSubview:_pageViewController.view];
    }

    if(isNewCreated){
        [self addChildViewController:_pageViewController];
        [_productImagesContainerView addSubview:_pageViewController.view];
        [_pageViewController didMoveToParentViewController:self];
    }

    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [_pageControl bringSubviewToFront:_productImagesContainerView];
    
    if (_segmentedControlIndex==3){
        _pageViewController.dataSource = nil;
        _pageViewController.delegate = nil;
        
        for (UIScrollView *view in self.parentViewController.view.subviews) {//stop page controller swipe for working tableview swipe delete
          //  UIView *view2=[view.subviews objectAtIndex:1];
            
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = NO;
            }
        }//end
    }else{
        for (UIScrollView *view in self.parentViewController.view.subviews) {//start page controller swipe for working tableview swipe delete
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = YES;
            }
        }//end

    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([kUserDefaults  integerForKey:@"PriceDisplay"] == 2){
        [_priceView setHidden:NO];
    }else{
        [_priceView setHidden:YES];
        
    }
    
    //[kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
}

-(void)currentPageProductDetail:(id)object{
    _productDetail=object;
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// method modified by Satish
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    UIViewController *vc = nil;
    switch (_segmentedControlIndex) {
        case 0:{
            ProductImageController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductImageController"];
            pvc.pageIndex = index;
            pvc.productDetail = _productDetail;
   //         pvc.transactionInfo = self.transactionInfo;
            pvc.delegate = self;
            vc = pvc;
            break;
        }
        case 5:{
            ProductNotesViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductNotesViewController"];
            pvc.pageIndex = index;
            pvc.productDetail = _productDetail;
            pvc.transactionInfo = self.transactionInfo;
            vc = pvc;
            break;
        }
        default:{
            ProductDetailContentWithoutHistoryViewController *pdcv = [self.storyboard instantiateViewControllerWithIdentifier:@"toProductDetailContentWithoutHistory"];
            pdcv.pageIndex = index;
 //           pdcv.delegate=self;
            pdcv.productSegmentedControlIndex=_segmentedControlIndex;
            if (_segmentedControlIndex==4) {
                pdcv.productPricesIndex=index;
            }
            pdcv.productDetail = _productDetail;
            pdcv.customerInfo = self.customerInfo;
            pdcv.transactionInfo = self.transactionInfo;
            vc = pdcv;
            break;
        }
    }
    return vc;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
     //For delivery tab swipe delete
    if (_segmentedControlIndex==3)
        return  nil;
    //END
    
    NSUInteger index = [[((UIViewController*) viewController) valueForKeyPath:@"pageIndex"] integerValue];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    //For delivery tab swipe delete
    if (_segmentedControlIndex==3)
        return  nil;
    //END

    
    NSUInteger index = [[((UIViewController*) viewController) valueForKeyPath:@"pageIndex"] integerValue];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [_subItemsArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


#pragma mark - Page View Controller delegate
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if(completed){
        _pageControl.currentPage =  [[[pageViewController.viewControllers lastObject] valueForKeyPath:@"pageIndex"] integerValue];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"FullImageViewSegue"]) {
        ProductImageViewController* fullImage = segue.destinationViewController;
        [fullImage setProductArray:self.productsDetailArray];
        fullImage.currentSelectedIndex = self.pageIndex;
    }
}


-(void)cancelkeyClick{

}

#pragma mark - ProductImageControllerDelegate
-(void)showFullScreenOnImageZoom{
    [self performSegueWithIdentifier:@"FullImageViewSegue" sender:nil];
}

#pragma mark - ProductDetailContentWithoutHistoryViewControllerDelegate
//-(void)refreshOrdPnlPrice:(NSDictionary *)arrSelectedRow{

- (void) refreshOrderpanelPrice:(NSNotification *) notification
{
    NSDictionary *dict= [[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]] lastObject];
    NSString *defPrice=prodDefaultPrice;
    if (dict) {
        defPrice=[dict valueForKey:@"field"];
    }
    
    //  After customer selection Change selected Price Default before Price selection selection
    if(![[priceConfigDict objectForKey:@"pricetablabels"] isEqual:[NSNull null]] && self.customerInfo ){
        
        NSString *symbol=[CommonHelper getCurrSymbolWithCurrCode:[self.customerInfo valueForKey:@"curr"]];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"label CONTAINS %@ ",symbol];
        NSArray *filterArr=[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
        if ([filterArr count]>0) {
            defPrice=[[filterArr firstObject] valueForKey:@"field"];
        }
    }//ended
    
    
    if ([[notification name] isEqualToString:kSelectedPriceRow]){
        NSDictionary *arrSelectedRow=notification.userInfo;
   
        NSArray* arrSidebar;
            
            if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
                NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_productDetail valueForKey:@"stock_code"]];
                NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                
                if ([filteredArr count]>0){
                    NSManagedObject *obj=[filteredArr firstObject];
                    arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:obj PriceConfig:priceConfigDict UserConfig:userConfigDic]objectForKey:@"sidebar"];
                }else
                    arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"] DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDic]objectForKey:@"sidebar"] ;
            }else
                arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:arrSelectedRow DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDic]objectForKey:@"sidebar"] ;
        
        
    // need to integrate in new order panel
    //refresh product order panel
   // NSArray* arrOrderPanel =[dicProductddetails objectForKey:@"orderpanel"];
    
//    if (arrSelectedRow.count>0) {
//        _lblPriceValue.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:[[[arrOrderPanel objectAtIndex:0] valueForKey:@"value"] doubleValue]];
//    }
//    if (arrOrderPanel.count>1) {
//        [_btnOrderPriceQty setTitle:[CommonHelper getCurrencyFormatWithCurrency:nil Value:[[[arrOrderPanel objectAtIndex:1] valueForKey:@"value"] doubleValue]] forState:UIControlStateNormal];
//    }

    //fresh product prices label
    //NSArray* arrSidebar =[dicProductddetails objectForKey:@"sidebar"];
    
    __block NSInteger priceCounter=0;
    
    [arrSidebar enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *lblPriceCaption = [self.lblPriceCaptions objectAtIndex:priceCounter];
        UILabel *lblPriceValue = [self.lblPriceValues objectAtIndex:priceCounter];
        if (lblPriceCaption) {
            @try {
                lblPriceCaption.hidden=NO;
                lblPriceValue.hidden=NO;
                lblPriceCaption.text=[obj valueForKey:@"caption"];
                
                
                
                lblPriceValue.text =[obj valueForKey:@"showPrice"]; //[CommonHelper getCurrencyFormatWithCurrency:nil Value:[[obj valueForKey:@"value"] doubleValue]];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        priceCounter++;
    }];
    
    // to hide unused values
    for (NSInteger i=priceCounter; i<2; i++){
        UILabel *lblPriceCaption=[self.lblPriceCaptions objectAtIndex:i];
        UILabel *lblPriceValue=[self.lblPriceValues objectAtIndex:i];
        lblPriceCaption.hidden=YES;
        lblPriceValue.hidden=YES;
    }
    }
}


-(void)dismissKeyboard {
    [[self view] endEditing:TRUE];
}



//For reload  product data when header discount added
-(void)reloadproductData :(NSNotification *) notification{
    if ([[notification name] isEqualToString:kReloadProduct]){
        [self loadAllPageContent];
    }
}
@end
