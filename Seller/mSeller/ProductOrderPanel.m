//
//  ProductOrderPanel.m
//  mSeller
//
//  Created by WCT iMac on 30/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductOrderPanel.h"
#import "Numerickeypad.h"
#import "OrderHelper.h"
#import "Constants.h"



@interface ProductOrderPanel ()<NumericKeypadDelegate,UIGestureRecognizerDelegate>{
    NSDictionary* priceConfigDict;//   fetch price Config
    NSDictionary* userConfigDict;
    NSString *orderType;
    double orderPrice;
    double orderDisc;
    double grossPrice;
  //  NSManagedObject *olineObj;
    NSString *oLinePackType;
    NSDateFormatter *dateFormat;
    NSDateFormatter *timeFormat;
    NSString *deliveryAdd;
    NSDate *deliveryDate;
    NSDate *expectedDate;
    NSString *currCodeOrder;
    NSInteger  delQtyNoti;
    NSTimer *timer;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lblPriceCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceValue;
@property (weak, nonatomic) IBOutlet UIView *viewPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderPriceCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnOrderPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblQuoteCaption;
@property (weak, nonatomic) IBOutlet UIButton *btnQuoteCheck;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscountCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscountValue;
@property (weak, nonatomic) IBOutlet UIButton *btnDiscount;
@property (weak, nonatomic) IBOutlet UIView *quoteViewLeft;
@property (weak, nonatomic) IBOutlet UIView *quoteViewRight;

//*** Add outlate collections.
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *packFieldLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *packsButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *packQtyButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *totQtyButtons;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *packButtonsViews;
//height Layout Constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPackViewHLayoutConst;//For Packs ,Pack Qty, Tot qty
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *packButtonsViewsheightLayoutConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *packLabelheightLayoutConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomView1HeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomView2HeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomviewHeightLayoutConstraint;
//Discount Height
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discCaptionHLayoutConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discLabelHLayoutConst;
//QuoteView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteViewRightHLayoutConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteViewLeftHLayoutConst;


@property (weak, nonatomic) UIButton *packButtonTemp;
@property (nonatomic,strong) NSString *valueNumKeyboard;

- (IBAction)quoteClick:(id)sender;
- (IBAction)orderPriceClick:(id)sender;
- (IBAction)discountClick:(id)sender;
//UIButtons click
- (IBAction)packClick:(id)sender;
- (IBAction)packQtyClick:(id)sender;
- (IBAction)packTotClick:(id)sender;
- (IBAction)packQtyLongPress:(UILongPressGestureRecognizer *)sender;

@end

@implementation ProductOrderPanel



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy"];
    timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    
    _btnQuoteCheck.layer.cornerRadius=5.0;
    _btnQuoteCheck.layer.borderWidth=1.0;
    _btnQuoteCheck.layer.borderColor=btnBlueCornerColor.CGColor;
    
    
    
    self.lblDiscountValue.text=@"";
    orderPrice=0.0;
    orderDisc=0.0;
    orderType=@"O";//Default

    deliveryAdd=[self.customerInfo valueForKey:@"delivery_address"];
    deliveryDate=[NSDate date];
    expectedDate=[NSDate date];

    //Add Logpress gesture.
    for (UIButton *btn in _packQtyButtons) {

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]   initWithTarget:self action:@selector(packQtyLongPress:)];
    longPress.minimumPressDuration = 0.5; //seconds
    longPress.delegate = self;
    [btn addGestureRecognizer:longPress];
    
    }
    
    
    //_lblPriceValue.layer.borderColor=btnBlueCornerColor.CGColor;
    _btnOrderPrice.layer.borderColor=btnBlueCornerColor.CGColor;
    _viewPrice.layer.borderColor=btnBlueCornerColor.CGColor;
    _btnDiscount.layer.borderColor=btnBlueCornerColor.CGColor;
    
    _lblOrderPrice.layer.cornerRadius=5.0;
    [_lblOrderPrice setClipsToBounds:YES];
    
    
    [_btnOrderPrice setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
    
    

//    if(self.transactionInfo){
//        olineObj =nil;
//        NSManagedObject *tempObj=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid ==%@",[_record valueForKey:@"stock_code"]]] lastObject];
//        [tempObj setValue:[NSNumber numberWithInteger:[[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid ==%@",[_record valueForKey:@"stock_code"]]] valueForKeyPath:@"@sum.quantity"] integerValue]] forKey:@"quantity"];
//        
//        olineObj =tempObj;
//        tempObj =nil;
//
//    }
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    
    //Notification for Selectedpricerow Change.
    [kNSNotificationCenter removeObserver:self name:kSelectedPriceRow object:nil];
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshOrderpanelPrice:) name:kSelectedPriceRow     object:nil];
    //Notification for delivery Address and delivery date Change.
    [kNSNotificationCenter removeObserver:self name:kDeliverInfoChange object:nil];
    [kNSNotificationCenter addObserver:self  selector:@selector(DeliverInfoChange:) name:kDeliverInfoChange     object:nil];
    //For reload  product data when header discount added
    
    
    
    //[kNSNotificationCenter addObserver:self  selector:@selector(reloadproductData:) name:kReloadProduct object:nil];
    
   
    
    /*if ([kUserDefaults  integerForKey:@"PriceDisplay"] == 2){
        [_viewPrice setHidden:NO];
        [_lblOrderPrice setHidden:NO];
        [_btnOrderPrice setHidden:NO];
        [_lblDiscountValue setHidden:NO];
        [_btnDiscount setHidden:NO];
    }else{
        [_viewPrice setHidden:YES];
        [_lblOrderPrice setHidden:YES];
        [_btnOrderPrice setHidden:YES];
        [_lblDiscountValue setHidden:YES];
        [_btnDiscount setHidden:YES];
    }*/
    
    
    currCodeOrder=[kUserDefaults  valueForKey:@"defaultcurrency"];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
    [kNSNotificationCenter removeObserver:self name:kSelectedPriceRow object:nil];
    [kNSNotificationCenter removeObserver:self name:kDeliverInfoChange object:nil];
    //For reload  product data when header discount added
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)reloadConfigData{
    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    
    dic=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        userConfigDict = [dic objectForKey:@"data"];
    
    
    [self loadOrderPannel];
}


-(NSArray*)OlinedataArray{
    //fetch Data
    NSArray *tempLinesArr=nil;
    if (self.traitCollection) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
        NSArray *descriptor = @[sortDescriptor];
        tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid ==%@",[_record valueForKey:@"stock_code"]]] sortedArrayUsingDescriptors:descriptor] ;
    }
    
    return tempLinesArr;
}

-(void)loadOrderPannel{
     int arrIndex=0;
     NSString* str=@"";
    
    //Mahendra load product data from priceConfig
    NSArray* arrpacks = [priceConfigDict objectForKey:@"orderpanellabels"]  ;

    for (NSDictionary* packDic in arrpacks) {
        str=[packDic valueForKey:@"label"];
        if (![str isEqual:[NSNull null]] && [str length]>0 ) {
            UILabel* lblpackCap=[[_packFieldLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            
            lblpackCap.text=[NSString stringWithFormat:@"%@",str ];
            [lblpackCap setHidden:NO];
            
            
            UIView* btnView=[_packButtonsViews objectAtIndex:arrIndex];
            [btnView setHidden:NO];
            
        }
        
        UIButton* btnQtyPacks;
        str=[packDic valueForKey:@"field"];
        if (![str isEqual:[NSNull null]] && [str length]>0 ) {
             btnQtyPacks=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            if ([[str lowercaseString] isEqualToString:@"unit"] ) {
                [btnQtyPacks setTitle:@"1" forState:UIControlStateNormal];
            }else
                [btnQtyPacks setTitle:[CommonHelper getFieldValueWithFieldName:[str lowercaseString] Source:_record] forState:UIControlStateNormal];
        }
        
        
        //fetch Data
        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
        tempOLineObj=[tempLinesArr firstObject];
        //end
        
        //When Not added iten in Transaction
        if (!tempOLineObj && [[packDic valueForKey:@"defaultdenomination"]integerValue]==1) {//set defaultdenomination color if no oLine
         //Pack button
            UIButton* btnPacks=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            [btnPacks setTitle:[NSString stringWithFormat:@"1"] forState:UIControlStateNormal];
        //Total button
            UIButton* btnTot=[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)(1*[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]) ] forState:UIControlStateNormal];
        //Default color
            [self changeGreenColor:btnPacks totBtn:btnTot];
        }
        
        //When added iten in Transaction
        if (tempOLineObj && [ [str lowercaseString] isEqualToString:[[tempOLineObj valueForKey:@"orderpacktype"] lowercaseString]]) {//oLine added value
            
            UIButton* btnPacks=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            UIButton* btnTot=[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            
//           NSInteger qty= [[olineObj valueForKey:@"quantity"] integerValue] / [[_record valueForKey:[[packDic objectForKey:@"field"] lowercaseString]] integerValue];
            [btnPacks setTitle:[NSString stringWithFormat:@"%li",[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue] / [[_record valueForKey:[[packDic objectForKey:@"field"] lowercaseString]] integerValue]] forState:UIControlStateNormal];
            [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)[[tempLinesArr valueForKeyPath:@"@sum.quantity"]integerValue]] forState:UIControlStateNormal];
            [self changeBlueColor:btnPacks totBtn:btnTot];
       
            /*dispatch_async(dispatch_get_main_queue(), ^{
                [btnPacks setBackgroundColor:btnBlueColor];
                [btnTot setBackgroundColor:btnBlueColor];
                [btnPacks setTitleColor:btnWhiteColor forState:UIControlStateNormal];
                [btnTot setTitleColor:btnWhiteColor forState:UIControlStateNormal];
                // [ _lblOrderPrice setBackgroundColor:btnBlueColor];
            });*/

        }
        else if (tempOLineObj && [[tempOLineObj valueForKey:@"orderpacktype"] length]==0 && [[packDic valueForKey:@"label"] isEqualToString:@"Unit"]){ //default Case  UNITS selected
        
            UIButton* btnPacks=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            UIButton* btnQtyTot=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            UIButton* btnTot=[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            
            [btnPacks setTitle:[NSString stringWithFormat:@"%li",[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue]] forState:UIControlStateNormal];
            [btnQtyTot setTitle:[NSString stringWithFormat:@"%i",1] forState:UIControlStateNormal];
            [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)[[tempLinesArr valueForKeyPath:@"@sum.quantity"]integerValue]] forState:UIControlStateNormal];
            [self changeBlueColor:btnPacks totBtn:btnTot];

            
        }
        
        
        
        //Button desable/Enable
        if (![[packDic valueForKey:@"selectable"] boolValue]) {
            UIButton* btnPacks=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
            [btnPacks setEnabled:NO];
        }
        
        
        //View
        UIView* viewButtons=[[_packButtonsViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];
        [viewButtons setHidden:NO];
       
//        NSLayoutConstraint* heightLayout=[_packButtonsViewsheightLayoutConstraint objectAtIndex:(3-arrIndex)];
//        heightLayout.constant=0.0;
       // [[_packButtonsViewsheightLayoutConstraint filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",(4-arrIndex)]] lastObject];
       
     arrIndex++;
     }

    
    for (int i=arrIndex; i<[_packButtonsViews count]; i++) {
        NSLayoutConstraint* ViewHLayout=[_packButtonsViewsheightLayoutConstraint objectAtIndex:i];//[[_packButtonsViewsheightLayoutConstraint filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",arrIndex]] lastObject];//[_packButtonsViewsheightLayoutConstraint objectAtIndex:i];
        ViewHLayout.constant=0.0;
        
       NSLayoutConstraint* LabelHLayout=[ _packLabelheightLayoutConstraint  objectAtIndex:i];
        LabelHLayout.constant=0.0;

    }
    
    if ([arrpacks count]==4){
        _quoteViewRightHLayoutConst.constant=28.0;
        _quoteViewLeftHLayoutConst.constant=0.0;
    }else if ([arrpacks count]==3) {
        _bottomviewHeightLayoutConstraint.constant=_bottomviewHeightLayoutConstraint.constant-15;
        _quoteViewRightHLayoutConst.constant=28.0;
         _quoteViewLeftHLayoutConst.constant=0.0;
        
    }else if ([arrpacks count]<=2 ){
        
        _bottomviewHeightLayoutConstraint.constant=_bottomviewHeightLayoutConstraint.constant-28;
        _quoteViewRightHLayoutConst.constant=0.0;
        _quoteViewLeftHLayoutConst.constant=28.0;
    }
    
    if ([arrpacks count]==0) {
        _topPackViewHLayoutConst.constant=0;
        int min=0;
        for (NSLayoutConstraint* heightLayout in _packButtonsViewsheightLayoutConstraint){
            if (min<2) {
                heightLayout.constant=0.0;
                
            }
            min++;
        }
    }

    
    NSDictionary *dict= [[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]] lastObject];
    NSString *defPrice=prodDefaultPrice;
    if (dict)
        defPrice=[dict valueForKey:@"field"];
    
    //  After customer selection Change selected Price Default before Price selection selection
    if(![[priceConfigDict objectForKey:@"pricetablabels"] isEqual:[NSNull null]] && self.customerInfo ){
        
        NSString *symbol=[CommonHelper getCurrSymbolWithCurrCode:[self.customerInfo valueForKey:@"curr"]];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"label CONTAINS %@ ",symbol];
        NSArray *filterArr=[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:predicate];
        if ([filterArr count]>0) {
            defPrice=[[filterArr firstObject] valueForKey:@"field"];
        }
    }//ended
    
    
    NSArray* arrSidebar;
   
        if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_record valueForKey:@"stock_code"]];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            
            if ([filteredArr count]>0){
                NSManagedObject *obj=[filteredArr firstObject];
                arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:obj PriceConfig:priceConfigDict UserConfig:userConfigDict] objectForKey:@"orderpanel"];
            }else
                arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDict] objectForKey:@"orderpanel"];
        }else
            arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDict] objectForKey:@"orderpanel"];
    
    if ([arrSidebar count]>0) {
        grossPrice=[[[arrSidebar firstObject] valueForKey:@"value"] doubleValue];
        _lblPriceCaption.text=[[arrSidebar firstObject] valueForKey:@"caption"];
        _lblPriceValue.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:grossPrice];
    }
    
    
    
    
    if ([[[arrSidebar lastObject] valueForKey:@"CurrCode"]length]>0) {
        currCodeOrder=[[arrSidebar lastObject] valueForKey:@"CurrCode"];
    }
    //Discount Box keys showdiscountboxenabled
    if (![[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"showdiscountboxenabled"] boolValue]){
       [self hideDiscountBox:YES];
      //  _quoteViewRightHLayoutConst.constant=28.0;
      //  _quoteViewLeftHLayoutConst.constant=0.0;
    }
    //END
        
    //Default Discount Box Value
    if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"defaultdiscountpercentage"] doubleValue]>0 ){
        orderDisc=[[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"defaultdiscountpercentage"] doubleValue];
        self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
    }//END
       
    
    //Discount Box keys displaydiscountboxonlyifdiscgreaterthanzero
    if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"displaydiscountboxonlyifdiscgreaterthanzero"] boolValue] && orderDisc<=0){
        [self hideDiscountBox:YES];
        
    }
    
    
    
    //fetch Data
    NSManagedObject *tempOLineObj=nil;
    NSArray *tempLinesArr=[self OlinedataArray];
    tempOLineObj=[tempLinesArr firstObject];
    //end

    //Added Product values
    if (tempOLineObj) {
        
        orderPrice=[[tempOLineObj valueForKey:@"saleprice"] doubleValue];
        orderType=[tempOLineObj valueForKey:@"orderlinetype"];
        orderDisc=[[tempOLineObj valueForKey:@"disc"] doubleValue];
        self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
        
        //lblOrderPrice
        _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
        [_lblOrderPrice setBackgroundColor:btnBlueColor];
        [_lblOrderPrice setTextColor:btnWhiteColor];
        
        if ([orderType isEqualToString:@"Q"])
            [_btnQuoteCheck setBackgroundImage:checkImage forState:UIControlStateNormal];
        
        
        
    }else{
         //default discount
        if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"defaultdiscountpercentage"] doubleValue]>0)
            orderDisc=[[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"defaultdiscountpercentage"] doubleValue];
        
       
        
        //Discount from stockband after selection of cutomer  overwrite default discount
        NSArray *stockArr = [kUserDefaults  objectForKey:@"StockBandArray"];
        NSString *priceband=[[_record valueForKey:@"priceband"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"custband ==%@ && prodband == %@",[kAppDelegate.customerInfo valueForKey:@"acc_ref"],priceband];
        NSArray *filterArr=[stockArr filteredArrayUsingPredicate:predicate];
        if ([filterArr count]>0) {
            orderDisc=[[[filterArr lastObject] valueForKey:@"disc"] doubleValue];
        }
        
        
        
         //Discount if headerdiscountenabled enable from OHEADNEW  in case of all
        if ([[kAppDelegate.transactionInfo valueForKey:@"custdisc"] doubleValue]>0 && [[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"headerdiscountenabled" ] boolValue]){
            //Case of All
            orderDisc=[[kAppDelegate.transactionInfo valueForKey:@"custdisc"] doubleValue];
        }
       //ENDED
        
        
        
        //Leass then 0 discount discount box hidden
        if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"displaydiscountboxonlyifdiscgreaterthanzero"] boolValue] && orderDisc<=0)
            [self hideDiscountBox:YES];
            
        self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
        
        orderPrice=grossPrice-((grossPrice*orderDisc)/100);

        if(orderDisc<=0)
            orderPrice=[[[arrSidebar lastObject] valueForKey:@"value"] doubleValue];
        else if ([filterArr count]>0)//Discount from stockband after
            orderPrice=[[[arrSidebar lastObject] valueForKey:@"value"] doubleValue];
        
        _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
    }
    
    
    if ([kUserDefaults  valueForKey:@"SelPriceRow"] ==nil) {
        //Calculate discount
        orderDisc=((grossPrice-orderPrice)*100)/grossPrice;
        self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
    }else{
        _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
    }
    
   //manage margin
    double costPrice=[[_record valueForKey:@"cost_price"] doubleValue];
    double margin=((orderPrice-costPrice)/orderPrice)*100;
    double markup=((orderPrice-costPrice)/costPrice)*100;
    if (margin < 0) {
        margin=0;
    }
    
    if (markup < 0) {
        markup=0;
    }
    
    if (markup < 0) {
        markup=0;
    }
    
    NSDictionary* dictNew = @{
                              @"cost_price": [NSNumber numberWithDouble:costPrice],
                              @"margin": [NSNumber numberWithDouble:margin],
                              @"markup": [NSNumber numberWithDouble:markup]
                              };

    [kNSNotificationCenter postNotificationName:kcostmargin object:self userInfo:dictNew];
}

-(void)hideDiscountBox :(BOOL)val{
    [_lblDiscountCaption setHidden:val];
    [_lblDiscountValue setHidden:val];
    [_btnDiscount setHidden:val];
    
    _discCaptionHLayoutConst.constant=0.0;
    _discLabelHLayoutConst.constant=0.0;
    
}

- (IBAction)packClick:(id)sender{
    
    if (!self.transactionInfo) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order Info:" message:@"Please select customer before ordering any product." delegate:nil cancelButtonTitle:alertBtnDismiss otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    //btn qty
    UIButton *btnQtyPacks=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[sender tag]]] lastObject];
    NSInteger packValue=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
    if (![[[[priceConfigDict  valueForKey: @"orderpanellabels"]objectAtIndex:[sender tag]]valueForKey:@"selectable"]boolValue] || packValue <= 0 ) {
        return;
    }

    //Open Numeric pad
    UIButton* btn=sender;
    Numerickeypad *obj=  (Numerickeypad *)[self.storyboard instantiateViewControllerWithIdentifier:@"Numerickeypad"];
    obj.clickBtn=btn;
    [obj setDelegate:self];
    obj.view.frame = self.view.bounds;
    obj.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    obj.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:obj animated:NO completion:^{

    }];
    
}

- (IBAction)packTotClick:(id)sender{
    
}

-(void)clearAllColor :(id)sender{
    UIButton* btnPack;
    UIButton* btnPackTot;
    UIButton* btnTot;
    for (int i=0; i<4; i++) {
        btnPack=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",i]] lastObject];
        btnPackTot=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",i]] lastObject];
        btnTot=[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",i]] lastObject];
        
        if ([sender tag]==i){//Selected color
            
            if (self.transactionInfo) {
                [self changeBlueColor:btnPack totBtn:btnTot];
                 [btnPackTot setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
            }else{
                [self changeGreenColor:btnPack totBtn:btnTot];
                 [btnPackTot setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
            }
            
           
        }else{
            [btnPack setBackgroundColor:[UIColor whiteColor]];
            [btnPack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnPack setTitle:@"" forState:UIControlStateNormal];
            
            [btnPackTot setBackgroundColor:[UIColor whiteColor]];
           // [btnPackTot setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           // [btnPackTot setTitle:@"" forState:UIControlStateNormal];

            [btnTot setBackgroundColor:[UIColor whiteColor]];
            [btnTot  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnTot setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)quoteClick:(id)sender{
    
    if ([orderType isEqualToString:@"Q"]) {
        [_btnQuoteCheck setBackgroundImage:nil forState:UIControlStateNormal];
        orderType=@"O";
    }else{
        [_btnQuoteCheck setBackgroundImage:checkImage forState:UIControlStateNormal];
        orderType=@"Q";
    }

    //fetch Data
//    NSManagedObject *tempOLineObj=nil;
    NSArray *tempLinesArr=[self OlinedataArray];
//    tempOLineObj=[tempLinesArr firstObject];
    //end
    if (tempLinesArr>0) {
        for (NSManagedObject *OlObject in  tempLinesArr) {
            [OlObject setValue:orderType forKey:@"orderlinetype"];
        }
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }
}

- (IBAction)orderPriceClick:(id)sender{
    UIButton *btn= sender;
    Numerickeypad *obj=  (Numerickeypad *)[self.storyboard instantiateViewControllerWithIdentifier:@"Numerickeypad"];
    obj.clickBtn=btn;
    [obj setDelegate:self];
    obj.view.frame = self.view.bounds;
    obj.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    obj.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:obj animated:NO completion:^{

    }];

}

- (IBAction)discountClick:(id)sender {
    UIButton *btn= sender;
    Numerickeypad *obj=  (Numerickeypad *)[self.storyboard instantiateViewControllerWithIdentifier:@"Numerickeypad"];
    obj.clickBtn=btn;
    [obj setDelegate:self];
    obj.view.frame = self.view.bounds;
    obj.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    obj.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:obj animated:NO completion:^{

    }];
    
}

//NumberPad Delegate method
-(void)retuenkeyClickwithOption:(NSString *)values Button:(UIButton* )btn{
    
    //buttons
    UIButton *btn2inn=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==1"]] lastObject];
    UIButton *btn3Out=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==2"]] lastObject];
    NSInteger btn2val=[[btn2inn titleForState:UIControlStateNormal] integerValue];
    NSInteger btn3val=[[btn3Out titleForState:UIControlStateNormal] integerValue];
    
    
    
    _packButtonTemp =nil;
    _packButtonTemp =(UIButton*) btn;
    _valueNumKeyboard =values;
    
    NSInteger lastValue=[[btn titleForState:UIControlStateNormal] integerValue];
    
    [btn setTitle:values forState:UIControlStateNormal];
    
    NSDictionary *orderDict=[priceConfigDict  valueForKey: @"orderconfigs"];//Web-configuration
    if ([btn tag]==3 ) {
     
        //DebugLog(@"Quantity button click Tag %@",orderDict);
        if([[orderDict valueForKey:@"prompttoroundforsplitpack"] boolValue] && [[orderDict valueForKey:@"splitpackenabledforpacks"] count]==0){
            UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Confirmation:"  message:@"Invalid qty- round up or round down."  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*/{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     devqty+=1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Down" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*/{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     if(devqty==0) devqty = 1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
                
            }]];
            
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
            return;
            
        }else {
      
        
            UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Confirmation:"  message:@"Invalid qty- round up or round down."  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              
                [btn setTitle:@"" forState:UIControlStateNormal];
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                    
                }else*/{//SingleDelivery Add
                  
                    if(quantity==0) quantity=1;
                    int devqty = (quantity/btn2val);
                    devqty+=1;
                    [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                    [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                }
                
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Down" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
               
                
                [btn setTitle:@"" forState:UIControlStateNormal];
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*/{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     if(devqty==0) devqty = 1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
                
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"accept ordered qty" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [btn setTitle:@"" forState:UIControlStateNormal];
                [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:_valueNumKeyboard];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if (lastValue==0) {
                    [btn setTitle:@"" forState:UIControlStateNormal];
                }else
                    [btn setTitle:[NSString stringWithFormat:@"%li",lastValue] forState:UIControlStateNormal];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;

            
        }
    }
    
    
    [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:values];
    
   /* [btn setTitle:values forState:UIControlStateNormal];
    
    if ([btn tag]==201) {//For price
        [_lblOrderPrice setText:@""];
        
        if ([[btn titleForState:UIControlStateNormal] doubleValue]>0) {
           orderPrice=[[btn titleForState:UIControlStateNormal] doubleValue];
        }else
            orderPrice=[[_record valueForKey:@"Price1"] doubleValue];
        //Calculate discount
       // NSArray* arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:nil SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]] objectForKey:@"sidebar"];
        
        orderDisc=((grossPrice-orderPrice)*100)/grossPrice;
        
        //Discount Box keys displaydiscountboxonlyifdiscgreaterthanzero
        if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"displaydiscountboxonlyifdiscgreaterthanzero"] boolValue]  && orderDisc<=0){
            [self hideDiscountBox:YES];
            
        }
        
        //fetch Data
//        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
//        tempOLineObj=[tempLinesArr firstObject];
        //end
        
        
        if ([tempLinesArr count]>0) {
            
           for (NSManagedObject *lineObject in tempLinesArr) {
               [lineObject setValue:[NSNumber numberWithDouble:orderDisc] forKey:@"disc"];
               [lineObject setValue:[NSNumber numberWithDouble:orderPrice] forKey:@"saleprice"];
               [lineObject setValue:[NSNumber numberWithDouble:(orderPrice*[[lineObject valueForKey:@"quantity"] integerValue] )] forKey:@"linetotal"];
           }
            
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }else{
                _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
                self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
            }
            
        }else if(orderPrice>0){
           
            [_lblOrderPrice setText:[CommonHelper getCurrencyFormatWithCurrency:nil Value:orderPrice]];
            
       //     _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:orderPrice];
            self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
        }
        
        
    }else if([btn tag]==301){ //Discount
         self.lblDiscountValue.text=@"";
        
        if ([[btn titleForState:UIControlStateNormal] doubleValue]>0) {
            orderDisc=[[btn titleForState:UIControlStateNormal] doubleValue];
        }else
            orderDisc=0.0;
        
        //Calculate price
       // NSArray* arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:nil SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]] objectForKey:@"sidebar"];
        double oPrice=grossPrice;//[[[arrSidebar lastObject] valueForKey:@"value"] doubleValue];
        orderPrice=oPrice-(oPrice*orderDisc)/100;
        
        //fetch Data
//        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
//        tempOLineObj=[tempLinesArr firstObject];
        //end
        
        if ([tempLinesArr count]>0) {
            for (NSManagedObject *lineObject in tempLinesArr) {
            [lineObject setValue:[NSNumber numberWithDouble:orderDisc] forKey:@"disc"];
            [lineObject setValue:[NSNumber numberWithDouble:orderPrice] forKey:@"saleprice"];
            [lineObject setValue:[NSNumber numberWithDouble:(orderPrice*[[lineObject valueForKey:@"quantity"] integerValue] )] forKey:@"linetotal"];
            }
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }else{
                self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
              
                 _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
            }
        }else if(orderDisc>0){
            self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
          
             _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
        }
        //***** update order price
        
    }else{//Add orderLine
        
        NSInteger tag=[btn tag];
        UIButton* btnPack=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        // NSInteger titVal= [[btnPack titleForState:UIControlStateNormal] integerValue];
        [btnPack setTitle:[NSString stringWithFormat:@"%li",(long)([values integerValue]) ] forState:UIControlStateNormal];
        
        UIButton* btnQty=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        UIButton* btnTot=[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        
        NSInteger totQty=[[btnPack titleForState:UIControlStateNormal] integerValue]*[[btnQty titleForState:UIControlStateNormal] integerValue];
        [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)totQty] forState:UIControlStateNormal];
        
        UILabel* lblpackCap=[[_packFieldLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        oLinePackType =[lblpackCap.text lowercaseString];//save lowercase string
        
        [self clearAllColor :btn];//Clear other buttons data
       
        //***** Selected pack
        
        if(self.transactionInfo){
            //fetch Data
            NSManagedObject *tempOLineObj=nil;
            NSArray *tempLinesArr=[self OlinedataArray];
            tempOLineObj=[tempLinesArr firstObject];
            //end
            
            
            
            if ([deliveryAdd length]==0)
                deliveryAdd=[tempOLineObj valueForKey:@"deliveryaddresscode"];//default alredy set delivery Address
            //if ([expectedDate length]==0)
             //   expectedDate=[olineObj valueForKey:@"expecteddate"];
            if (!deliveryDate)
                deliveryDate=[tempOLineObj valueForKey:@"requireddate"];
           
            
            if ([tempLinesArr count]==0) {//First time Add Recods
                NSString *lineno=@"1";;
                BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)totQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:lineno  TransactionInfo:self.transactionInfo];
                
                if(insert){
                    DebugLog(@"inserted");
                    [self changeBlueColor:btnPack totBtn:btnTot];
                    [ _lblOrderPrice setBackgroundColor:btnBlueColor];
                    [ _lblOrderPrice setTextColor:btnWhiteColor];
                    
                    //Call log change to order type
                    [self changeOrderType:self.transactionInfo];
                    // olineObj =nil;
                    // olineObj =[self findOlineRecod:[self.transactionInfo valueForKey:@"orderid"] StockCode:[_record valueForKey:@"stock_code"]];
                }
           
            }else{ //Update only first recods if increse order pannel
                
                NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && lineno==%@", [_record valueForKey:@"stock_code"],@"1"];
                NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                NSManagedObject *obj=[filteredArr lastObject];
                
                
                NSInteger totRowQty=[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue];
                NSInteger firstrowQty=0;
                
                /*if (totQty-totRowQty>0) {
                    NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
                    firstrowQty=totQty-remQty;
              
                
                }else{*
                    NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
                    firstrowQty=totQty-remQty;
                    
                    
                //}
                
                
                if (firstrowQty>0) {
                    deliveryAdd=[obj valueForKey:@"deliveryaddresscode"];
                    deliveryDate=[obj valueForKey:@"requireddate"];
                    BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)firstrowQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:@"1"  TransactionInfo:self.transactionInfo];
                    if(insert){
                        DebugLog(@"INSERT/Update 1 st row NEW ROW");
                        // reload bottom bar code
                        
                    }
    
                }else{
                    
                    if (totQty<=0) {//Delete all rows
                        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_record valueForKey:@"stock_code"]];
                        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                        for (NSManagedObject* oLineObj in filteredArr) {
                            [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                        }
                        
                        [self changeGreenColor:btnPack totBtn:btnTot];//Change background color
                        
                        
                    }else{// delete last object move quantity to 1 st row
                        
                      //  NSInteger firstRowUpdateval=totQty-totRowQty;
                        [obj setValue:[NSNumber numberWithInteger:totQty] forKey:@"quantity"];//update first row
                        [obj setValue:[NSNumber numberWithDouble:(orderPrice*totQty)] forKey:@"linetotal"];
                        
                        
                        NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"productid == %@ && lineno!=%@", [_record valueForKey:@"stock_code"],@"1"];
                        NSArray *RemfilteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate2];
                        for (NSManagedObject* oLineObj in RemfilteredArr) {//delete other row if any
                            [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                        }
                        
                        [self changeBlueColor:btnPack totBtn:btnTot];//Change background color
                        
                    }
                    
                    NSError *error = nil;
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }
            }
            
            [kNSNotificationCenter postNotificationName:kDeliverViewUpdate  object:nil userInfo:nil];
        }

    }
    
    
    //Add additional fields in price tab
    double costPrice=[[_record valueForKey:@"cost_price"] doubleValue];
    double margin=((orderPrice-costPrice)/orderPrice)*100;
    double markup=((orderPrice-costPrice)/costPrice)*100;
    
    NSDictionary* dict = @{
                              @"cost_price": [NSNumber numberWithDouble:costPrice],
                              @"margin": [NSNumber numberWithDouble:margin],
                              @"markup": [NSNumber numberWithDouble:markup]
                              };
    
    
        [kNSNotificationCenter postNotificationName:kcostmargin object:self userInfo:dict];*/
}
//END


-(void)submitOrderByNumericKeyboard:(UIButton *)btn NumPadvalue:values{
   
    
    [btn setTitle:values forState:UIControlStateNormal];
    
    if ([btn tag]==201) {//For price
        [_lblOrderPrice setText:@""];
        
        if ([[btn titleForState:UIControlStateNormal] doubleValue]>0) {
            orderPrice=[[btn titleForState:UIControlStateNormal] doubleValue];
        }else
            orderPrice=[[_record valueForKey:@"Price1"] doubleValue];
        //Calculate discount
        // NSArray* arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:nil SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]] objectForKey:@"sidebar"];
        
        orderDisc=((grossPrice-orderPrice)*100)/grossPrice;
        
        //Discount Box keys displaydiscountboxonlyifdiscgreaterthanzero
        if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"displaydiscountboxonlyifdiscgreaterthanzero"] boolValue]  && orderDisc<=0){
            [self hideDiscountBox:YES];
            
        }
        
        //fetch Data
        //        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
        //        tempOLineObj=[tempLinesArr firstObject];
        //end
        
        
        if ([tempLinesArr count]>0) {
            
            for (NSManagedObject *lineObject in tempLinesArr) {
                [lineObject setValue:[NSNumber numberWithDouble:orderDisc] forKey:@"disc"];
                [lineObject setValue:[NSNumber numberWithDouble:orderPrice] forKey:@"saleprice"];
                [lineObject setValue:[NSNumber numberWithDouble:(orderPrice*[[lineObject valueForKey:@"quantity"] integerValue] )] forKey:@"linetotal"];
            }
            
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }else{
                _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
                self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
            }
            
        }else if(orderPrice>0){
            
            [_lblOrderPrice setText:[CommonHelper getCurrencyFormatWithCurrency:nil Value:orderPrice]];
            
            //     _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:orderPrice];
            self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
        }
        
        
    }else if([btn tag]==301){ //Discount
        self.lblDiscountValue.text=@"";
        
        if ([[btn titleForState:UIControlStateNormal] doubleValue]>0) {
            orderDisc=[[btn titleForState:UIControlStateNormal] doubleValue];
        }else
            orderDisc=0.0;
        
        //Calculate price
        // NSArray* arrSidebar =[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:nil SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]] objectForKey:@"sidebar"];
        double oPrice=grossPrice;//[[[arrSidebar lastObject] valueForKey:@"value"] doubleValue];
        orderPrice=oPrice-(oPrice*orderDisc)/100;
        
        //fetch Data
        //        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
        //        tempOLineObj=[tempLinesArr firstObject];
        //end
        
        if ([tempLinesArr count]>0) {
            for (NSManagedObject *lineObject in tempLinesArr) {
                [lineObject setValue:[NSNumber numberWithDouble:orderDisc] forKey:@"disc"];
                [lineObject setValue:[NSNumber numberWithDouble:orderPrice] forKey:@"saleprice"];
                [lineObject setValue:[NSNumber numberWithDouble:(orderPrice*[[lineObject valueForKey:@"quantity"] integerValue] )] forKey:@"linetotal"];
            }
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }else{
                self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
                
                _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
            }
        }else if(orderDisc>0){
            self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
            
            _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
        }
        //***** update order price
        
    }else{//Add orderLine
        
        NSInteger tag=[btn tag];
        UIButton* btnPack=[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        // NSInteger titVal= [[btnPack titleForState:UIControlStateNormal] integerValue];
        [btnPack setTitle:[NSString stringWithFormat:@"%li",(long)([values integerValue]) ] forState:UIControlStateNormal];
        
        UIButton* btnQty=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        UIButton* btnTot=[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        
        NSInteger totQty=[[btnPack titleForState:UIControlStateNormal] integerValue]*[[btnQty titleForState:UIControlStateNormal] integerValue];
        [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)totQty] forState:UIControlStateNormal];
        
        UILabel* lblpackCap=[[_packFieldLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tag]] lastObject];
        oLinePackType =[lblpackCap.text lowercaseString];//save lowercase string
        if([oLinePackType hasPrefix:@"unit"]){
            oLinePackType =@"unit";
            
        }
        
        [self clearAllColor :btn];//Clear other buttons data
        
        //***** Selected pack
        
        if(self.transactionInfo){
            //fetch Data
            NSManagedObject *tempOLineObj=nil;
            NSArray *tempLinesArr=[self OlinedataArray];
            tempOLineObj=[tempLinesArr firstObject];
            //end
            
            
            
            if ([deliveryAdd length]==0)
                deliveryAdd=[tempOLineObj valueForKey:@"deliveryaddresscode"];//default alredy set delivery Address
            //if ([expectedDate length]==0)
            //   expectedDate=[olineObj valueForKey:@"expecteddate"];
            if (!deliveryDate)
                deliveryDate=[tempOLineObj valueForKey:@"requireddate"];
            
            
            if ([tempLinesArr count]==0) {//First time Add Recods
                NSString *lineno=@"1";;
                BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)totQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:lineno  TransactionInfo:self.transactionInfo];
                
                if(insert){
                    DebugLog(@"Prod ordPannel inserted");
                    [self changeBlueColor:btnPack totBtn:btnTot];
                    [ _lblOrderPrice setBackgroundColor:btnBlueColor];
                    [ _lblOrderPrice setTextColor:btnWhiteColor];
                    
                    //Call log change to order type
                    [self changeOrderType:self.transactionInfo];
                    // olineObj =nil;
                    // olineObj =[self findOlineRecod:[self.transactionInfo valueForKey:@"orderid"] StockCode:[_record valueForKey:@"stock_code"]];
                }
                
            }else{ //Update only first recods if increse order pannel
                
                NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && lineno==%@", [_record valueForKey:@"stock_code"],@"1"];
                NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                NSManagedObject *obj=[filteredArr lastObject];
                
                
                NSInteger totRowQty=[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue];
                NSInteger firstrowQty=0;
                
                /*if (totQty-totRowQty>0) {
                 NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
                 firstrowQty=totQty-remQty;
                 
                 
                 }else{*/
                NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
                firstrowQty=totQty-remQty;
                
                
                //}
                
                
                if (firstrowQty>0) {
                    deliveryAdd=[obj valueForKey:@"deliveryaddresscode"];
                    deliveryDate=[obj valueForKey:@"requireddate"];
                    BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)firstrowQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:@"1"  TransactionInfo:self.transactionInfo];
                    if(insert){
                        DebugLog(@"INSERT/Update 1 st row NEW ROW");
                        // reload bottom bar code
                        
                    }
                    
                }else{
                    
                    if (totQty<=0) {//Delete all rows
                        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_record valueForKey:@"stock_code"]];
                        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                        for (NSManagedObject* oLineObj in filteredArr) {
                            [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                        }
                        
                        [self changeGreenColor:btnPack totBtn:btnTot];//Change background color
                        
                        
                    }else{// delete last object move quantity to 1 st row
                        
                        //  NSInteger firstRowUpdateval=totQty-totRowQty;
                        [obj setValue:[NSNumber numberWithInteger:totQty] forKey:@"quantity"];//update first row
                        [obj setValue:[NSNumber numberWithDouble:(orderPrice*totQty)] forKey:@"linetotal"];
                        
                        
                        NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"productid == %@ && lineno!=%@", [_record valueForKey:@"stock_code"],@"1"];
                        NSArray *RemfilteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate2];
                        for (NSManagedObject* oLineObj in RemfilteredArr) {//delete other row if any
                            [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                        }
                        
                        [self changeBlueColor:btnPack totBtn:btnTot];//Change background color
                        
                    }
                    
                    NSError *error = nil;
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }
            }
            
            [kNSNotificationCenter postNotificationName:kDeliverViewUpdate  object:nil userInfo:nil];
        }
        
    }
    
    
    //Add additional fields in price tab
    double costPrice=[[_record valueForKey:@"cost_price"] doubleValue];
    double margin=((orderPrice-costPrice)/orderPrice)*100;
    double markup=((orderPrice-costPrice)/costPrice)*100;
    
    NSDictionary* dict = @{
                           @"cost_price": [NSNumber numberWithDouble:costPrice],
                           @"margin": [NSNumber numberWithDouble:margin],
                           @"markup": [NSNumber numberWithDouble:markup]
                           };
    
    
    [kNSNotificationCenter postNotificationName:kcostmargin object:self userInfo:dict];

    
}






//Call log change to order type
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
        
        /*[transactionObj setValue:@"C" forKey:@"ordtype"];
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        [kNSNotificationCenter postNotificationName:kOrderTypechange  object:self];*/
    }
    
}

//Refresh price when user change price list fron price list tab
- (void) refreshOrderpanelPrice:(NSNotification *) notification
{
    NSDictionary *dict= [[[priceConfigDict objectForKey:@"pricetablabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isdefault==1"]] lastObject];
    NSString *defPrice=prodDefaultPrice;
    if (dict)
        defPrice=[dict valueForKey:@"field"];
    
    
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
        
        
        if (![[priceConfigDict valueForKey:@"priceperpackenabled"]boolValue]) {
            return;
        }
        
        
        NSDictionary *arrSelectedRow=notification.userInfo;
        NSArray* arrSidebar;
        
        if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_record valueForKey:@"stock_code"]];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            
            if ([filteredArr count]>0){
                NSManagedObject *obj=[filteredArr firstObject];
                arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:self.customerInfo  SelectedPriceRow:arrSelectedRow DefaultPrice:defPrice Transaction:obj PriceConfig:priceConfigDict UserConfig:userConfigDict]objectForKey:@"orderpanel"];
            }else
                arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:self.customerInfo  SelectedPriceRow:arrSelectedRow DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDict]objectForKey:@"orderpanel"];
        }else
            arrSidebar=[[CommonHelper getProductPrices:priceConfigDict Product:_record Customer:self.customerInfo  SelectedPriceRow:arrSelectedRow DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDict]objectForKey:@"orderpanel"];
        
        
        
        
        
        //Change gross price if applydiscountagainpricerowselected is selected YES
        
        //fresh product prices label
         
        //if applydiscountagainpricerowselected is Selected Price Row then first row also change by selected price.
        grossPrice=[[[arrSidebar firstObject] valueForKey:@"value"]doubleValue];
        self.lblPriceCaption.text=[[arrSidebar firstObject] valueForKey:@"caption"];
        self.lblPriceValue.text=[[arrSidebar firstObject] valueForKey:@"showPrice"];//[CommonHelper getCurrencyFormatWithCurrency:nil Value:grossPrice];
        
        
        //Change order price
        orderPrice=[[[arrSidebar lastObject] valueForKey:@"value"]doubleValue];
        self.lblOrderPriceCaption.text=[[arrSidebar lastObject] valueForKey:@"caption"];
        self.lblOrderPrice.text=[[arrSidebar lastObject] valueForKey:@"showPrice"];//[CommonHelper getCurrencyFormatWithCurrency:nil Value:orderPrice];
        if ([[[arrSidebar lastObject] valueForKey:@"CurrCode"]length]>0) {
            currCodeOrder=[[arrSidebar lastObject] valueForKey:@"CurrCode"];
        }
        
        
//        NSInteger defpack=0;
//        defpack=[[[priceConfigDict valueForKey:@"discountonselectedpackandabove"] stringByReplacingOccurrencesOfString:@"Pack" withString:@""] intValue];
//        NSInteger userPack=[[[self.selectedPack valueForKey:@"discountonselectedpackandabove"] stringByReplacingOccurrencesOfString:@"Pack" withString:@""] intValue];
        
        
        //Default Discount Box Value >0
        if ([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"defaultdiscountpercentage"] doubleValue] >0 && grossPrice>=orderPrice){
            orderDisc=[[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"defaultdiscountpercentage"] doubleValue];
            self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
            
            orderPrice=grossPrice-((grossPrice*orderDisc)/100);
             self.lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:orderPrice];
            
        }else    if (grossPrice>=orderPrice ) {
            orderDisc=((grossPrice-orderPrice)*100)/grossPrice;
            self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
           // orderPrice=grossPrice-((grossPrice*orderDisc)/100);
        }
        
        
        //fetch Data
//        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
//        tempOLineObj=[tempLinesArr firstObject];
        //end
        
        if ([tempLinesArr count]>0) {
            orderDisc=((grossPrice-orderPrice)*100)/grossPrice;
            for (NSManagedObject *lineObject in tempLinesArr) {
                [lineObject setValue:[NSNumber numberWithDouble:orderDisc] forKey:@"disc"];
                [lineObject setValue:[NSNumber numberWithDouble:orderPrice] forKey:@"saleprice"];
                [lineObject setValue:[NSNumber numberWithDouble:(orderPrice*[[lineObject valueForKey:@"quantity"] integerValue] )] forKey:@"linetotal"];
            }
            
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }else{
                _lblOrderPrice.text=[CommonHelper getCurrencyFormatWithCurrency:currCodeOrder Value:orderPrice];
                self.lblDiscountValue.text=[NSString stringWithFormat:@"%0.2f%%",orderDisc];
            }
        }
    }
}

//Delivery tab change Notification
- (void) DeliverInfoChange:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:kDeliverInfoChange]){
        
        NSDictionary *arrdel=notification.userInfo;
        
        
        deliveryAdd=[arrdel valueForKey:@"delAdd"];
        deliveryDate=[arrdel valueForKey:@"deldate"];
        __block NSInteger  delQty=[[arrdel valueForKey:@"delQty"] integerValue];
        delQtyNoti=delQty;
        
        NSInteger linepackval=1;
        if ([oLinePackType length]==0) {
            NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
            if ([arrDefault count]>0 ) {
                oLinePackType =[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString];
            }
         //Check from added items
            if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
                NSPredicate* predicate=[NSPredicate predicateWithFormat:@" productid ==%@  && orderid=%@",[_record valueForKey:@"stock_code"],[self.transactionInfo valueForKey:@"orderid"]];
                NSArray*  tempLinesArr2=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate];
                if ([tempLinesArr2 count]>0) {
                    oLinePackType=[[[tempLinesArr2 firstObject]valueForKey:@"orderpacktype"]lowercaseString];
                    
                }

            }//ENDED
            
            
        }
        
        linepackval=[[_record valueForKey:[oLinePackType lowercaseString]] integerValue];
        NSInteger alertVal=  delQty%linepackval;
        //Alert for upper and down
        if (alertVal >0 && delQty>0) {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation:"
                                                            message:@"invalid qty- round up or round down."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Up",@"Down",@"accept ordered qty",nil];
            [alert setDelegate:self];
            [alert setTag:103];
            [alert show];

            
            
            
           /*
            
                        
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation:"
                                                                           message:@"invalid qty- round up or round down."
                                                                    preferredStyle:UIAlertControllerStyleActionSheet]; // 1
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Up"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      DebugLog(@"You pressed button one");
                                                                      
                                                                      NSInteger val=  delQty/linepackval;
                                                                      delQty =(val+1)*linepackval;
                                                                      if (self.transactionInfo)
                                                                          [self updateOrder:delQty selectpackVal:linepackval];
                                                                  }]; // 2
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Down"
                                                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                       DebugLog(@"You pressed button two");
                                                                       NSInteger val=  delQty/linepackval;
                                                                       delQty =val*linepackval;
                                                                       
                                                                       if (self.transactionInfo)
                                                                           [self updateOrder:delQty selectpackVal:linepackval];
                                                                       
                                                                   }]; // 3
            UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:@"accept ordered qty"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      DebugLog(@"You pressed button 3");
                                                                      
                                                                      if (self.transactionInfo)
                                                                          [self updateOrder:delQty selectpackVal:linepackval];
                                                                      
                                                                  }]; // 3
            
            
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            [alert addAction:firstAction]; // 4
            [alert addAction:secondAction]; // 5
            [alert addAction:thirdAction];
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:nil]; // 6
            */
            

        }else if (delQty>0){
            if (self.transactionInfo)
                [self updateOrder:delQty selectpackVal:linepackval];
            
            //[self loadOrderPannel];
        }
        
      
//        [self loadOrderPannel];
        
    }
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
   
    if ([alertView tag]==103) {
        
        NSInteger linepackval=1;
        if ([oLinePackType length]==0) {
            NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
            if ([arrDefault count]>0 )
                oLinePackType =[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString];
            
            //Check from added items
            if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
                NSPredicate* predicate=[NSPredicate predicateWithFormat:@" productid ==%@  && orderid=%@",[_record valueForKey:@"stock_code"],[self.transactionInfo valueForKey:@"orderid"]];
                NSArray*  tempLinesArr2=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate];
                if ([tempLinesArr2 count]>0)
                    oLinePackType=[[tempLinesArr2 firstObject]valueForKey:@"orderpacktype"];
                
            }//ENDED
        }
        
        linepackval=[[_record valueForKey:[oLinePackType lowercaseString]] integerValue];
        
        
        
        if (buttonIndex == 0) {
            
             [kNSNotificationCenter postNotificationName:kCancelChanges  object:nil userInfo:nil];
            // do something here...
        }else if(buttonIndex==1){
            
            NSInteger val=  delQtyNoti/linepackval;
            delQtyNoti =(val+1)*linepackval;
            if (self.transactionInfo){
                [self updateOrder:delQtyNoti selectpackVal:linepackval];
                [self loadOrderPannel];
            }
        }else if (buttonIndex==2){
            NSInteger val=  delQtyNoti/linepackval;
            delQtyNoti =val*linepackval;
            
            if (self.transactionInfo){
                [self updateOrder:delQtyNoti selectpackVal:linepackval];
                [self loadOrderPannel];
            }
            
        }else if (buttonIndex==3){
            if (self.transactionInfo){
                [self updateOrder:delQtyNoti selectpackVal:linepackval];
                [self loadOrderPannel];
            }
        }
        
        //[alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        
    }

}





-(void)updateOrder :(NSInteger)delQty selectpackVal:(NSInteger)linepackval{
    
    if (self.transactionInfo) {
        
        NSArray *filterArr=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid == %@ ",[_record valueForKey:@"stock_code"]]];
        
        if ( [filterArr    count]>0){
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && deliveryaddresscode==%@ && requireddate = %@", [_record valueForKey:@"stock_code"],deliveryAdd,deliveryDate];
           
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
            NSArray *descriptor = @[sortDescriptor];
            NSArray *filteredArr = [[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:descriptor]; //Array sort bases of line no
            
            if ([filteredArr count]==0 && delQty>0) {
                
//                
                NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_record valueForKey:@"stock_code"]];
                NSArray *filteredArrOline = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
//                NSManagedObject *obj=[filteredArr lastObject];
//                NSString *lineno=[NSString stringWithFormat:@"%li",(long)[[obj valueForKey:@"lineno"]integerValue]+1 ];
                NSNumber *maxlineno= [filteredArrOline valueForKeyPath:@"@max.lineno"];
                NSInteger line=[maxlineno integerValue];
                NSString* LineNo=[NSString stringWithFormat:@"%d",line+1];
                
                if([oLinePackType hasPrefix:@"unit"]){
                    oLinePackType =@"unit";
                }
                
                BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)delQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:LineNo   TransactionInfo:self.transactionInfo];
                if(insert){
                    DebugLog(@"INSERT NEW Delivery Address and oline ROW");
                    // reload bottom bar code
                    
                }
            }else{
                
                NSManagedObject *olineObject=[filteredArr firstObject];
                if (deliveryDate) {
                    
                  //  [olineObject setValue:deliveryDate forKey:@"datesold"];
                    [olineObject setValue:deliveryDate forKey:@"requireddate"];
                    NSError *error = nil;
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }
                if( [deliveryAdd length]>0)
                {
                    [olineObject setValue:deliveryAdd forKey:@"deliveryaddresscode"];
                    NSError *error = nil;
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }
                if( delQty >0)
                {  
                        [olineObject setValue:[NSNumber numberWithInteger:delQty ] forKey:@"quantity"];
                        [olineObject setValue:[NSNumber numberWithDouble:(orderPrice*delQty)] forKey:@"linetotal"];
                        
                        NSError *error = nil;
                        if (![kAppDelegate.managedObjectContext save:&error]) {
                            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                        }
                 
                    //Update button value
                    NSManagedObject *tempOLineObj=nil;
                    NSArray *tempLinesArr=[self OlinedataArray];
                    tempOLineObj=[tempLinesArr firstObject];
                    
                    NSArray *btnTotArr=[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.backgroundColor==%@",btnBlueColor]];
                    if ([btnTotArr count]>0) {
                        UIButton* btnTot=[btnTotArr lastObject];
                        [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue]] forState:UIControlStateNormal];
                    }
                       // olineObject=[self findOlineRecod:[self.transactionInfo valueForKey:@"orderid"] StockCode:[_record valueForKey:@"stock_code"]];
                    //Line
                    
                    linepackval=[[_record valueForKey: [[tempOLineObj valueForKey:@"orderpacktype"]lowercaseString]] integerValue];
                    
                    NSArray *btnArr=[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.backgroundColor==%@",btnBlueColor]];
                    if ([btnArr count]>0) {
                        UIButton* btnpack=[btnArr lastObject];
                        [btnpack setTitle:[NSString stringWithFormat:@"%li",(long)([[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue]/linepackval)] forState:UIControlStateNormal];
                    }
    
                }
        
            }
            
        }
        else if([deliveryAdd length]>0 && delQty>0){//Add first recods
            
            NSString *lineno=@"1";
            if([oLinePackType hasPrefix:@"unit"]){
                oLinePackType =@"unit";
            }
            
            BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)delQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber: lineno TransactionInfo:self.transactionInfo];
            if(insert){
                DebugLog(@"INSERT NEW ROW");
                
                //Update button value
                
                NSArray *btnArr=[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.backgroundColor==%@",btnGreenColor]];
                //NSArray *btnArr=[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==1"]];
                
                if ([btnArr count]>0) {
                    UIButton* btnTot=[btnArr lastObject];
                    [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)delQty] forState:UIControlStateNormal];
                    [btnTot setBackgroundColor:btnBlueColor];
                    [btnTot setTitleColor:btnWhiteColor forState:UIControlStateNormal];
                }
                
                btnArr=[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.backgroundColor==%@",btnGreenColor]];
                if ([btnArr count]>0) {
                    UIButton* btnpack=[btnArr lastObject];
                    [btnpack setTitle:[NSString stringWithFormat:@"%li",(long)(delQty/linepackval)] forState:UIControlStateNormal];
                    [btnpack setBackgroundColor:btnBlueColor];
                    [btnpack setTitleColor:btnWhiteColor forState:UIControlStateNormal];
                }
                // reload bottom bar code
                
            }
            
            
        }
        
        //update delivery tab
       // [kNSNotificationCenter postNotificationName:kDeliverViewUpdate  object:self userInfo:nil];
    }
    
    [self performSelector:@selector(loadOrderPannel) withObject:nil afterDelay:0.1 ];
}

//Find Oline data
- (NSManagedObject *)findOlineRecod :(NSString*)orderId StockCode:(NSString *)stockCode{
    
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@ && productid == %@",orderId,stockCode];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSManagedObject *LineObj=[resultsSeq lastObject];
    [LineObj setValue:[NSNumber numberWithInteger:[[resultsSeq valueForKeyPath:@"@sum.quantity"] integerValue]] forKey:@"quantity"];
    
    return LineObj;
}

//Change button color
-(void)changeBlueColor:(UIButton*)btnPack totBtn:(UIButton*)btnTot{
    dispatch_async(dispatch_get_main_queue(), ^{
        [btnPack setBackgroundColor:btnBlueColor];
        [btnTot setBackgroundColor:btnBlueColor];
        [btnPack setTitleColor:btnWhiteColor forState:UIControlStateNormal];
        [btnTot setTitleColor:btnWhiteColor forState:UIControlStateNormal];
        // [ _lblOrderPrice setBackgroundColor:btnBlueColor];
    });
                 
}

-(void)changeGreenColor:(UIButton*)btnPack totBtn:(UIButton*)btnTot{
    dispatch_async(dispatch_get_main_queue(), ^{
        [btnPack setBackgroundColor:btnGreenColor];
        [btnTot setBackgroundColor:btnGreenColor];
        [btnPack setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
        [btnTot setTitleColor:btnTitleBlueColor forState:UIControlStateNormal];
        // [ _lblOrderPrice setBackgroundColor:btnGreenColor];
    });
}
//END


 /*/For reload  product data when header discount added
-(void)reloadproductData :(NSNotification *) notification{
    if ([[notification name] isEqualToString:kReloadProduct]){
        [self loadOrderPannel];
    }
}*/

-(void)cancelkeyClick{
    //    if([numpadVC parentViewController])
//    [self dismissViewControllerAnimated:YES completion:^{
//
//    }];
}


- (IBAction)packQtyClick:(id)sender{
    UIButton *btn=(UIButton*) sender;
    _packButtonTemp=nil;
    _packButtonTemp=(UIButton*) sender;

    
    //buttons
    UIButton *btn2inn=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==1"]] lastObject];
    UIButton *btn3Out=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==2"]] lastObject];
    NSInteger btn2val=[[btn2inn titleForState:UIControlStateNormal] integerValue];
    NSInteger btn3val=[[btn3Out titleForState:UIControlStateNormal] integerValue];
    
    NSString *values=[btn titleForState:UIControlStateNormal] ;

    
    
    NSDictionary *orderDict=[priceConfigDict  valueForKey: @"orderconfigs"];//Web-configuration
    
    if (!self.transactionInfo) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Order Info:" message:@"Please select customer before ordering any product." delegate:nil cancelButtonTitle:alertBtnDismiss otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    if ([btn tag]==3 ) {
        
        return;
        //on unite click user cant click packQty
        
       /*
        DebugLog(@"Quantity button click Tag %@",orderDict);
        if([[orderDict valueForKey:@"prompttoroundforsplitpack"] boolValue] && [[orderDict valueForKey:@"splitpackenabledforpacks"] count]==0){
            UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Confirmation:"  message:@"Invalid qty- round up or round down."  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     devqty+=1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Down" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     if(devqty==0) devqty = 1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
                
            }]];
            
           
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
            
        }else {
            UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Confirmation:"  message:@"Invalid qty- round up or round down."  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     devqty+=1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Down" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSInteger quantity=[values integerValue];
                /*if(){multiple delivery Add
                 
                 }else*{//SingleDelivery Add
                     
                     if(quantity==0) quantity=1;
                     int devqty = (quantity/btn2val);
                     if(devqty==0) devqty = 1;
                     [btn setTitle:[NSString stringWithFormat:@"%d  ",  btn2val * devqty] forState:UIControlStateNormal];
                     [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:[NSString stringWithFormat:@"%d  ",  btn2val * devqty]];
                 }
                
                
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"accept ordered qty" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:_valueNumKeyboard];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
        }*/
    }
    
    
    
    
    
    [self submitOrder:_packButtonTemp];
    /*/btn pack
    UIButton *btnPacks  =[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[sender tag]]] lastObject];
    //btn qty
    UIButton *btnQtyPacks=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[sender tag]]] lastObject];
    //Total button
    UIButton* btnTot    =[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[sender tag]]] lastObject];
    
   // DebugLog(@"Quantity button click Tag %i",[sender tag]);
    NSInteger packValue=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
    
    if (![[[[priceConfigDict  valueForKey: @"orderpanellabels"]objectAtIndex:[sender tag]]valueForKey:@"selectable"]boolValue] || packValue <= 0 ) {
        return;
    }
    
    UILabel* lblpackCap=[[_packFieldLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[sender tag]]] lastObject];
    oLinePackType =[lblpackCap.text lowercaseString];//save lowercase string
    
    [self clearAllColor :btn];//Clear other buttons data onlu UI
    
    if(self.transactionInfo){
        
        NSInteger totQty=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
        if ([btnTot.backgroundColor  isEqual: btnBlueColor]){//Already Added in oLine
            totQty=[[btnTot titleForState:UIControlStateNormal] integerValue]+[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
        }
        
        [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)totQty] forState:UIControlStateNormal];
        //manage multiple delivery Address
        //fetch Data
        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
        tempOLineObj=[tempLinesArr firstObject];
        //end
        if ([deliveryAdd length]==0)
            deliveryAdd=[tempOLineObj valueForKey:@"deliveryaddresscode"];//default alredy set delivery Address
        
        if (!deliveryDate)
            deliveryDate=[tempOLineObj valueForKey:@"requireddate"];
        
        if ([tempLinesArr count]==0) {//First time Add Recods
            NSString *lineno=@"1";;
            BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)totQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:lineno  TransactionInfo:self.transactionInfo];
            
            if(insert){
                DebugLog(@"inserted");
                [self changeBlueColor:btnPacks totBtn:btnTot];
                [ _lblOrderPrice setBackgroundColor:btnBlueColor];
                [ _lblOrderPrice setTextColor:btnWhiteColor];
                //Call log change to order type
                [self changeOrderType:self.transactionInfo];
            }
            
        }else{ //Update only first recods if increse order pannel
            
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && lineno==%@", [_record valueForKey:@"stock_code"],@"1"];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            NSManagedObject *obj=[filteredArr lastObject];
            
            
            NSInteger totRowQty=[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue];
            NSInteger firstrowQty=0;
            
            NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
            firstrowQty=totQty-remQty;
            
            
            
            if (firstrowQty>0) {
                deliveryAdd=[obj valueForKey:@"deliveryaddresscode"];
                deliveryDate=[obj valueForKey:@"requireddate"];
                BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)firstrowQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:@"1"  TransactionInfo:self.transactionInfo];
                if(insert){
                    DebugLog(@"INSERT/Update 1 st row NEW ROW");
                    // reload bottom bar code
                    
                }
                
            }else{
                
                if (totQty<=0) {//Delete all rows
                    NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_record valueForKey:@"stock_code"]];
                    NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                    for (NSManagedObject* oLineObj in filteredArr) {
                        [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                    }
                    
                    [self changeGreenColor:btnPacks totBtn:btnTot];//Change background color
                    
                    
                }else{// delete last object move quantity to 1 st row
                    
                    //  NSInteger firstRowUpdateval=totQty-totRowQty;
                    [obj setValue:[NSNumber numberWithInteger:totQty] forKey:@"quantity"];//update first row
                    [obj setValue:[NSNumber numberWithDouble:(orderPrice*totQty)] forKey:@"linetotal"];
                    
                    
                    NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"productid == %@ && lineno!=%@", [_record valueForKey:@"stock_code"],@"1"];
                    NSArray *RemfilteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate2];
                    for (NSManagedObject* oLineObj in RemfilteredArr) {//delete other row if any
                        [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                    }
                    
                    [self changeBlueColor:btnPacks totBtn:btnTot];//Change background color
                }
                
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
            }
        }
        
        [kNSNotificationCenter postNotificationName:kDeliverViewUpdate  object:nil userInfo:nil];
        
        //ENDED
        
        
    }else{//Without cistomer selection
        
        NSString *totVal=[NSString stringWithFormat:@"%li",(long)([[btnTot titleForState:UIControlStateNormal] integerValue]+[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]) ];
        
        [btnTot setTitle:totVal forState:UIControlStateNormal];
    }
    
    //Pack values updated
    NSString *packVal=[NSString stringWithFormat:@"%li",(long)([[btnTot titleForState:UIControlStateNormal] integerValue]/[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]) ];
    [btnPacks setTitle:packVal forState:UIControlStateNormal];
   */
}



-(void)submitOrder :(UIButton *)btnPack{
    
    //btn pack
    UIButton *btnPacks  =[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btnPack tag]]] lastObject];
    //btn qty
    UIButton *btnQtyPacks=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btnPack tag]]] lastObject];
    //Total button
    UIButton* btnTot    =[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btnPack tag]]] lastObject];
    
    // DebugLog(@"Quantity button click Tag %i",[sender tag]);
    NSInteger packValue=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
    
    if (![[[[priceConfigDict  valueForKey: @"orderpanellabels"]objectAtIndex:[btnPack tag]]valueForKey:@"selectable"]boolValue] || packValue <= 0 ) {
        return;
    }
    
    UILabel* lblpackCap=[[_packFieldLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btnPack tag]]] lastObject];
    oLinePackType =[lblpackCap.text lowercaseString];//save lowercase string
    if([oLinePackType hasPrefix:@"unit"]){
        oLinePackType =@"unit";
    }
    
    
    [self clearAllColor :btnPack];//Clear other buttons data onlu UI
    
    if(self.transactionInfo){
        
        NSInteger totQty=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
        if ([btnTot.backgroundColor  isEqual: btnBlueColor]){//Already Added in oLine
            totQty=[[btnTot titleForState:UIControlStateNormal] integerValue]+[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
        }
        
        [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)totQty] forState:UIControlStateNormal];
        //manage multiple delivery Address
        //fetch Data
        NSManagedObject *tempOLineObj=nil;
        NSArray *tempLinesArr=[self OlinedataArray];
        tempOLineObj=[tempLinesArr firstObject];
        //end
        if ([deliveryAdd length]==0)
            deliveryAdd=[tempOLineObj valueForKey:@"deliveryaddresscode"];//default alredy set delivery Address
        
        if (!deliveryDate)
            deliveryDate=[tempOLineObj valueForKey:@"requireddate"];
        
        if ([tempLinesArr count]==0) {//First time Add Recods
            NSString *lineno=@"1";;
            BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)totQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:lineno  TransactionInfo:self.transactionInfo];
            
            if(insert){
                DebugLog(@"ProdOrdPannel inserted");
                [self changeBlueColor:btnPacks totBtn:btnTot];
                [ _lblOrderPrice setBackgroundColor:btnBlueColor];
                [ _lblOrderPrice setTextColor:btnWhiteColor];
                //Call log change to order type
                [self changeOrderType:self.transactionInfo];
            }
            
        }else{ //Update only first recods if increse order pannel
            
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && lineno==%@", [_record valueForKey:@"stock_code"],@"1"];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            NSManagedObject *obj=[filteredArr lastObject];
            
            
            NSInteger totRowQty=[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue];
            NSInteger firstrowQty=0;
            
            NSInteger remQty=(totRowQty-[[obj valueForKey:@"quantity"]integerValue]);
            firstrowQty=totQty-remQty;
            
            
            
            if (firstrowQty>0) {
                deliveryAdd=[obj valueForKey:@"deliveryaddresscode"];
                deliveryDate=[obj valueForKey:@"requireddate"];
                BOOL insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:_record  orderQty:[NSString stringWithFormat:@"%li",(long)firstrowQty] orderPrice:orderPrice discount:orderDisc deliveryAdd:deliveryAdd deliveryDate:deliveryDate expectedDate:deliveryDate  oLineType:orderType oLinePackType:oLinePackType LineNumber:@"1"  TransactionInfo:self.transactionInfo];
                if(insert){
                    DebugLog(@"INSERT/Update 1 st row NEW ROW");
                    // reload bottom bar code
                    
                }
                
            }else{
                
                if (totQty<=0) {//Delete all rows
                    NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_record valueForKey:@"stock_code"]];
                    NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                    for (NSManagedObject* oLineObj in filteredArr) {
                        [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                    }
                    
                    [self changeGreenColor:btnPacks totBtn:btnTot];//Change background color
                    
                    
                }else{// delete last object move quantity to 1 st row
                    
                    //  NSInteger firstRowUpdateval=totQty-totRowQty;
                    [obj setValue:[NSNumber numberWithInteger:totQty] forKey:@"quantity"];//update first row
                    [obj setValue:[NSNumber numberWithDouble:(orderPrice*totQty)] forKey:@"linetotal"];
                    
                    
                    NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"productid == %@ && lineno!=%@", [_record valueForKey:@"stock_code"],@"1"];
                    NSArray *RemfilteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate2];
                    for (NSManagedObject* oLineObj in RemfilteredArr) {//delete other row if any
                        [kAppDelegate.managedObjectContext deleteObject:oLineObj];
                    }
                    
                    [self changeBlueColor:btnPacks totBtn:btnTot];//Change background color
                }
                
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
            }
        }
        
        [kNSNotificationCenter postNotificationName:kDeliverViewUpdate  object:nil userInfo:nil];
        
        //ENDED
        
        
    }else{//Without cistomer selection
        
        NSString *totVal=[NSString stringWithFormat:@"%li",(long)([[btnTot titleForState:UIControlStateNormal] integerValue]+[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]) ];
        
        [btnTot setTitle:totVal forState:UIControlStateNormal];
    }
    
    //Pack values updated
    NSString *packVal=[NSString stringWithFormat:@"%li",(long)([[btnTot titleForState:UIControlStateNormal] integerValue]/[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]) ];
    [btnPacks setTitle:packVal forState:UIControlStateNormal];
    
}





//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}

- (IBAction)packQtyLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    DebugLog(@"packQtyLongPress");
    UIButton *btn = (id)gestureRecognizer.view;

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        [self btnQtuantityLongPressBegin:btn];
    }else
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateCancelled
            || gestureRecognizer.state == UIGestureRecognizerStateFailed
            || gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            // Long press ended, stop the timer
            [self btnQuantity_longPressEnd:btn];
        }
    }

}



-(void)btnQtuantityLongPressBegin:(UIButton*)btn{
    
  //Comment for remove leakes  UIButton *btnPacks  =[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btn tag]]] lastObject];
    //btn qty
    UIButton *btnQtyPacks=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btn tag]]] lastObject];
    //Total button
//    UIButton* btnTot    =[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[btn tag]]] lastObject];
    
    DebugLog(@"Quantity button click Tag %i",[btn tag]);
    NSInteger packValue=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
    
    if (![[[[priceConfigDict  valueForKey: @"orderpanellabels"]objectAtIndex:[btn tag]]valueForKey:@"selectable"]boolValue] || packValue <= 0 ) {
        return;
    }
    
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:btn forKey:@"btnsender"];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeQuantity:) userInfo:dict repeats:YES];
}



-(void)btnQuantity_longPressEnd:(UIButton*)btnsender{
    [timer invalidate];
    timer=nil;
}

//Remove button quantity from quick Order panel
-(void)removeQuantity:(NSTimer *)timerObj{
    NSDictionary *dict=timerObj.userInfo;
    
     DebugLog(@"removeQuantity ");
    
    UIButton *btnPack=[dict objectForKey:@"btnsender"];
    NSInteger tagVal=[btnPack tag];
    
    
    //Check oLine Pack type
    UILabel* lblpack = [[_packFieldLabels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tagVal]] lastObject];
    NSString *PackType=[lblpack.text lowercaseString];
    
    UIButton *btnPacks  =[[_packsButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tagVal]] lastObject]; //btn pack
    UIButton *btnQtyPacks=[[_packQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tagVal]] lastObject];//btn qty
    UIButton* btnTot    =[[_totQtyButtons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",tagVal]] lastObject];//Total button

    
    NSInteger remianQty=([[btnTot titleForState:UIControlStateNormal] integerValue]-[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]);
    NSInteger packQty=[[btnQtyPacks titleForState:UIControlStateNormal] integerValue];
    
    if (remianQty < packQty)//if remaingqty less then pack qty
        return;
    
    
  if(self.transactionInfo){
        
       
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_record valueForKey:@"stock_code"]];
        NSArray *oLineArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        
        if ([oLineArr count]>0) {
            NSInteger packQ=[[btnPack titleForState:UIControlStateNormal] integerValue];
            
            if ([[PackType lowercaseString] isEqualToString:[[[oLineArr firstObject] valueForKey:@"orderpacktype"] lowercaseString]] && remianQty >= packQ){
                
                [[oLineArr firstObject] setValue:[NSNumber numberWithInteger:remianQty ] forKey:@"quantity"];
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }else
                    [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)remianQty] forState:UIControlStateNormal];
            }
            else if (remianQty >= packQ && [[[oLineArr firstObject] valueForKey:@"orderpacktype"] length]==0 && [PackType isEqualToString:@"unit"]){ //default Case  UNITS selected
                
                
                [[oLineArr firstObject] setValue:[NSNumber numberWithInteger:remianQty ] forKey:@"quantity"];
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }else
                    [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)remianQty] forState:UIControlStateNormal];
                
                
            }
        }
        
    }else{
        [btnTot setTitle:[NSString stringWithFormat:@"%li",(long)remianQty] forState:UIControlStateNormal];
        
    }
    
    
    //Pack values updated
    NSString *packVal=[NSString stringWithFormat:@"%li",(long)([[btnTot titleForState:UIControlStateNormal] integerValue]/[[btnQtyPacks titleForState:UIControlStateNormal] integerValue]) ];
    [btnPacks setTitle:packVal forState:UIControlStateNormal];
    
    //Check order type
    if(self.transactionInfo)
        [self changeOrderType:self.transactionInfo];
    
}

//Alert view
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if ([alertView tag]==222) {
        
        
        if (buttonIndex==0 ) {
            DebugLog(@"CancelClick ");
        }else if (buttonIndex==1) {
            DebugLog(@"up Click ");
        } else if (buttonIndex==2) {
           DebugLog(@"Down Click");
        } else if (buttonIndex==3){
            DebugLog(@"buttonIndex 0");
        }

        
        
    }else if ([alertView tag]==223) {
        
        if (buttonIndex==0 ) {
            DebugLog(@"CancelClick ");
        }else if (buttonIndex==1) {
            DebugLog(@"up Click ");
        } else if (buttonIndex==2) {
            DebugLog(@"Down Click");
        } else if (buttonIndex==3){
            DebugLog(@"Doaccept Click");
            [self submitOrder:_packButtonTemp];;
        }
        
    } else if ([alertView tag]==224) {
        
        if (buttonIndex==0 ) {
            DebugLog(@"CancelClick ");
        }else if (buttonIndex==1) {
            DebugLog(@"up Click ");
        } else if (buttonIndex==2) {
            DebugLog(@"Down Click");
        } else if (buttonIndex==3){
            DebugLog(@"Doaccept Click");
           [self submitOrderByNumericKeyboard:_packButtonTemp NumPadvalue:_valueNumKeyboard];
        }
        
        
        
    }
    
}



@end
