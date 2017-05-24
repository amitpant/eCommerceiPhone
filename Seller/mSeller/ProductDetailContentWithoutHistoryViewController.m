//
//  ProductDetailContentWithoutHistoryViewController.m
//  mSeller
//
//  Created by Ashish Pant on 10/26/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductDetailContentWithoutHistoryViewController.h"
#import "extraColl.h"
#import "Constants.h"
#import "globalObject.h"
#import "Numerickeypad.h"


@interface ProductDetailContentWithoutHistoryViewController ()<CustomerDeliveryAddressViewControllerDelegate,NumericKeypadDelegate>
{
    NSDictionary* priceConfigDict;//   fetch feature
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary* userConfigDict;
    NSString *selectedDeliveryAddress;
    
    NSDate *selectedDate;
    NSString *strSelectedQty;
    NSDateFormatter *dateFormat;
    NSIndexPath *selIndexPath;
    int rowCount;
    NSDictionary *dictCostAndMargin;
    BOOL isShowCostMargin;
    NSArray* tempArray;
}
@property (nonatomic,strong) NSMutableArray* arrRows;
@property (nonatomic,strong) NSString *deliveryId;
@property (nonatomic,strong) NSMutableArray *updatedDeliveryAddressArray;
@property (nonatomic,strong) NSMutableArray *customisedDelAdds;

@property (weak, nonatomic) IBOutlet UIView *viewExtraInfo;
@property (weak, nonatomic) IBOutlet UITableView *productDetailContentTable;
@property (weak, nonatomic) IBOutlet UICollectionView *extraInfoCollView;
@end

@implementation ProductDetailContentWithoutHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dic1=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic1 && ![[dic1 objectForKey:@"data"] isEqual:[NSNull null]])
        userConfigDict = [dic1 objectForKey:@"data"];
    isShowCostMargin=[[userConfigDict valueForKey:@"showcostmargin"] boolValue];
    
    [_viewExtraInfo setHidden:YES];
    [_productDetailContentTable setHidden:YES];
    
    self.productDetailContentTable.allowsMultipleSelectionDuringEditing = YES;//deleting table on swipe
    
    [self reloadConfigData];
    
    if(self.productSegmentedControlIndex==2){
        _viewExtraInfo.layer.cornerRadius=5.0;
        _viewExtraInfo.layer.borderColor=[UIColor lightGrayColor].CGColor;
        _viewExtraInfo.layer.borderWidth=1.0;
        _productDetailContentTable.delegate = nil;
        _productDetailContentTable.dataSource = nil;
    }
    else{
        //for tableview bordered color and radius
        self.productDetailContentTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.productDetailContentTable.layer setCornerRadius:5.0f];
        [self.productDetailContentTable.layer setBorderWidth:1.0];
        _extraInfoCollView.delegate = nil;
        _extraInfoCollView.dataSource = nil;
    }
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy"];
    
    _arrRows = nil;
    switch (self.productSegmentedControlIndex) {
        case 2:
            if (![[[companyConfigDict valueForKey:@"generalconfig"]valueForKey:@"generaltabextrainfo"] isEqual:[NSNull null]] )
                _arrRows =[NSMutableArray arrayWithArray:[[companyConfigDict valueForKey:@"generalconfig"]valueForKey:@"generaltabextrainfo"]];
            [_productDetailContentTable setHidden:YES];
            [_viewExtraInfo setHidden:NO];
            [_extraInfoCollView reloadData];
            break;
        case 3:
            
            [self getDeliveryData];
            [_productDetailContentTable setHidden:NO];
            [_viewExtraInfo setHidden:YES];
            [_productDetailContentTable reloadData];
            break;
        case 6:
            _arrRows = [NSMutableArray arrayWithArray:[self load_ProductOrder:_productDetail]];
            //[[_productDetail valueForKey:@"porders"] allObjects]];
            [_productDetailContentTable setHidden:NO];
            [_viewExtraInfo setHidden:YES];
            [_productDetailContentTable reloadData];
            break;
        default:
            [self performSelector:@selector(loadPricing) withObject:nil afterDelay:0.0 ];//[self loadPricing];
            break;
    }
    
    
    
    
    //Notification for delivery Address and delivery date Change.
    [kNSNotificationCenter removeObserver:self name:kDeliverViewUpdate object:nil];
    [kNSNotificationCenter addObserver:self  selector:@selector(updateDeliveryInfo:) name:kDeliverViewUpdate object:nil];
    
    //Notification for Show Cost And Margin.
    [kNSNotificationCenter removeObserver:self name:kcostSwitch object:nil];
    [kNSNotificationCenter addObserver:self  selector:@selector(switchStatus:) name:kcostSwitch     object:nil];
    
    [kNSNotificationCenter removeObserver:self name:kcostmargin object:nil];
    [kNSNotificationCenter addObserver:self  selector:@selector(costMargin:) name:kcostmargin     object:nil];
    //Notification for Show Cost And Margin.
    [kNSNotificationCenter removeObserver:self name:kCancelChanges object:nil];
    [kNSNotificationCenter addObserver:self  selector:@selector(cancelChanges:) name:kCancelChanges    object:nil];
}

-(void)switchStatus:(NSNotification *) notification{
    
    if ([[notification name] isEqualToString:kcostSwitch]) {
        NSDictionary *dict =notification.userInfo;
        if ([[dict valueForKey:@"switch"] integerValue] == 1)
        {isShowCostMargin=YES;
            [kNSNotificationCenter postNotificationName:kcostmargin object:self userInfo:dictCostAndMargin];
        }
        else
        {
            isShowCostMargin=NO;
            [kNSNotificationCenter postNotificationName:kcostmargin object:self userInfo:nil];
        }
        }
    
}

-(void)costMargin:(NSNotification *) notification{
    
    if ([[notification name] isEqualToString:kcostmargin]){
        if (self.productSegmentedControlIndex==4) {
            NSDictionary *dictNew =notification.userInfo;
            if (dictNew) {
                dictCostAndMargin=dictNew;
                NSDictionary* strItemCost = @{
                                              @"label": @"Item Cost",
                                              @"field": [NSString stringWithFormat:@"%@",[CommonHelper getCurrencyFormatWithCurrency:nil Value:[[dictNew valueForKey:@"cost_price"]doubleValue]]]
                                              };
                NSDictionary* strItemMargin = @{
                                                @"label": @"Margin%",
                                                @"field": [NSString stringWithFormat:@"%.2f",[[dictNew valueForKey:@"margin"] doubleValue]]
                                                };
                NSDictionary* strItemMarkup = @{
                                                @"label": @"Mark Up%",
                                                @"field": [NSString stringWithFormat:@"%.2f",[[dictNew valueForKey:@"markup"] doubleValue]]
                                                };
                
                
                if (_arrRows.count>rowCount && _arrRows.count<=rowCount+3 && rowCount!=0) {
                    [_arrRows removeObjectAtIndex:_arrRows.count-1];
                    [_arrRows removeObjectAtIndex:_arrRows.count-1];
                    [_arrRows removeObjectAtIndex:_arrRows.count-1];
                    
                    [_arrRows addObject:strItemCost];
                    [_arrRows addObject:strItemMargin];
                    [_arrRows addObject:strItemMarkup];
                    
                }
                else
                {
                    if (isShowCostMargin) {
                    [_arrRows addObject:strItemCost];
                    [_arrRows addObject:strItemMargin];
                    [_arrRows addObject:strItemMarkup];
                    }
                    }
                
            }
            else
            {
                if (_arrRows.count>rowCount && _arrRows.count>=rowCount-1) {
                    [_arrRows removeObjectAtIndex:_arrRows.count-1];
                    [_arrRows removeObjectAtIndex:_arrRows.count-1];
                    [_arrRows removeObjectAtIndex:_arrRows.count-1];
                }
            }
            [_productDetailContentTable reloadData];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // check for App, company and user level configuration (privileges)
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
-(void)reloadConfigData{
    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
   
    //  Mahendra fetch userConfig
    userConfigDict=nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        userConfigDict = [dic objectForKey:@"data"];
    isShowCostMargin=[[userConfigDict valueForKey:@"showcostmargin"] boolValue];

    

    if (self.productSegmentedControlIndex==4) {
        _arrRows = nil;
        [self performSelector:@selector(loadPricing) withObject:nil afterDelay:0.0 ];
    }
}

-(void)loadPricing{
    rowCount=0;
    
     DebugLog(@"loadPricing %i",self.productPricesIndex);
    
    if(self.productPricesIndex==1){
        DebugLog(@"Load 1nd index");
       
        @try {
            
            NSSortDescriptor *lastUsedSortDescription = [NSSortDescriptor sortDescriptorWithKey:@"invoicehead.invoiced_date" ascending:YES];
            NSArray *sortedArray = [[[self.customerInfo valueForKeyPath:@"invoicelines"] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:lastUsedSortDescription]];
            if([sortedArray count]){
                NSManagedObject *invinfo = [sortedArray firstObject];
               
                
                NSString *strLastPrice =@"Last Price";//@"Default Od price"
                if (![[userConfigDict objectForKey:@"lastorderpriceasdefaultorderpriceenabled"] isEqual:[NSNull null]] && [[userConfigDict valueForKey:@"lastorderpriceasdefaultorderpriceenabled"] boolValue]) {
                    strLastPrice =@"Last price paid";
                }
                
                
                NSDictionary *diclastprice = [NSDictionary dictionaryWithObjectsAndKeys:strLastPrice,@"label",
                                              [CommonHelper getCurrencyFormatWithCurrency:[invinfo valueForKeyPath:@"invoicehead.customer.curr"] Value:[[invinfo valueForKey:@"price_invoiced"] doubleValue]], @"pricedisplay",
                                              [NSNumber numberWithDouble:[[invinfo valueForKey:@"price_invoiced"] doubleValue]], @"priceval",
                                              [invinfo valueForKeyPath:@"invoicehead.invoiced_date"], @"date",
                                              [NSNumber numberWithInteger:[[invinfo valueForKey:@"tot_invoiced_qty"] integerValue]], @"qty",
                                              nil];
                _arrRows =[NSMutableArray arrayWithArray: [NSArray arrayWithObject:diclastprice]];
            }
            
        }@catch (NSException *exception) {
            DebugLog(@"Exception loadPricing 1 %@",exception);
        }
    }
    else if(self.productPricesIndex==2 ){
        //fetch StockBand value && [[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"headerdiscountenabled" ] boolValue]
        @try {
            _arrRows=[NSMutableArray arrayWithArray:[self loadheaderDiscount]];
            DebugLog(@"Load 2nd index %@",_arrRows);
        }@catch (NSException *exception) {
            DebugLog(@"Exception loadPricing 2 %@",exception);
        }
        
        
    } else{
        @try {
            DebugLog(@"Load 0nd index");
            _arrRows = [NSMutableArray arrayWithArray:[priceConfigDict objectForKey:@"pricetablabels"]];
            rowCount=(int)[_arrRows count];
        }@catch (NSException *exception) {
            DebugLog(@"Exception loadPricing 3 %@",exception);
        }
    }
    [_productDetailContentTable setHidden:NO];
    [_viewExtraInfo setHidden:YES];
    [_productDetailContentTable reloadData];
}

-(void )getDeliveryData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSString *entityName=@"CUST";
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    NSPredicate *predicate;
    
    /*if (self.updatedDeliveryAddressArray.count>0)
     predicate=[NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address  IN %@",[self.customerInfo valueForKey:@"acc_ref"],self.updatedDeliveryAddressArray];
     else{*/
    NSString *filterDeliveryAddress = [NSString stringWithFormat:@"acc_ref == '%@'",[self.customerInfo valueForKey:@"acc_ref"]];
    
    
    if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0 && [[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]]] count]>0){//delivery Address already added
        
        NSMutableArray *prearr=[[NSMutableArray alloc]init];
        
        NSPredicate *pred1=[NSPredicate predicateWithFormat:@"acc_ref==%@",[self.customerInfo valueForKey:@"acc_ref"]];
        [prearr addObject:pred1];
        
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]];
        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        if ([filteredArr count]>0) {
            NSArray *arr=[filteredArr valueForKey:@"deliveryaddresscode"];
            NSPredicate *pred2=[NSPredicate predicateWithFormat:@"delivery_address  IN %@",arr];
            [prearr addObject:pred2];
        }
        
        if([prearr count]==1){
            predicate=[prearr objectAtIndex:0];
        }else{
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:prearr];
            
        }
        
        
    }else
        // remove main account address to use as first delivery address
        if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"usemainaccountasdeliveryaddresss"] boolValue]){
            filterDeliveryAddress = [filterDeliveryAddress stringByAppendingFormat:@" && delivery_address!='000'"];
            predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
        }
        else{
           // filterDeliveryAddress = [filterDeliveryAddress stringByAppendingFormat:@" && delivery_address=='%@'",[self.customerInfo valueForKey:@"delivery_address"]];
            filterDeliveryAddress = [filterDeliveryAddress stringByAppendingFormat:@" && delivery_address=='%@'",[self.transactionInfo valueForKey:@"deliveryaddressid"]];
            predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
        }
    
    // }
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *arrayDel=[kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // _arrRows =[NSMutableArray arrayWithArray: ];
    NSMutableArray *tempArray=[[NSMutableArray alloc]init];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]];
    NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
    
    if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0 && [filteredArr count]>0){
        //        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]];
        //        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        
        
        [filteredArr enumerateObjectsUsingBlock:^(id  _Nonnull obj12, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray* CustArr=[arrayDel filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"delivery_address == %@ ", [obj12 valueForKey:@"deliveryaddresscode"]]];
            NSManagedObject *obj=[CustArr lastObject];
            
            NSMutableDictionary *TempDictionary = [[NSMutableDictionary alloc]init];
            [TempDictionary setValue:[obj12 valueForKey:@"deliveryaddresscode"] forKey:@"DelAdd"];
            [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
            [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
            [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
            [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
            [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
            [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
            [TempDictionary setValue:[NSNumber numberWithInteger:[[obj12 valueForKey:@"lineno"]integerValue]] forKey:@"lineno"];
            [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
            [TempDictionary setValue:[obj12 valueForKey:@"requireddate"] forKey:@"Deldate"];
            [TempDictionary setValue:[NSString stringWithFormat:@"%i",[[obj12 valueForKey:@"quantity"] integerValue]] forKey:@"DelQty"];
            [tempArray addObject:TempDictionary];
        }];
        
        
        
        
        /*if ([filteredArr count]>0){
         
         NSManagedObject *obj12=[filteredArr firstObject];
         
         [TempDictionary setValue:[obj12 valueForKey:@"deliveryaddresscode"] forKey:@"DelAdd"];
         [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
         [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
         [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
         [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
         [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
         [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
         [TempDictionary setValue:[NSNumber numberWithInt:[[obj12 valueForKey:@"lineno"]integerValue]] forKey:@"lineno"];
         [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
         [TempDictionary setValue:[obj12 valueForKey:@"requireddate"] forKey:@"Deldate"];
         [TempDictionary setValue:[NSString stringWithFormat:@"%i",[[obj12 valueForKey:@"quantity"] integerValue]] forKey:@"DelQty"];
         [tempArray addObject:TempDictionary];
         
         }else{
         [TempDictionary setValue:[obj valueForKey:@"delivery_address"] forKey:@"DelAdd"];
         [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
         [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
         [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
         [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
         [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
         [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
         [TempDictionary setValue:[NSNumber numberWithInt:0] forKey:@"lineno"];
         [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
         [TempDictionary setValue:[dateFormat stringFromDate:[NSDate date]] forKey:@"Deldate"];
         //Default Quantity
         NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
         if ([arrDefault count]>0 && [arrayDel count]==1){
         [TempDictionary setValue:[NSString stringWithFormat:@"%li",(long)[[_productDetail valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] forKey:@"DelQty"];
         }else
         [TempDictionary setValue:@"0" forKey:@"DelQty"];
         
         
         
         [tempArray addObject:TempDictionary];
         }*/
    }else{
        
        //WithCapacity:[_arrRows count]];
        [arrayDel enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // if (self.oLineInfo && [[self.oLineInfo valueForKey:@"deliveryaddresscode"] isEqualToString:[obj valueForKey:@"delivery_address"]] ) {
            DebugLog(@"FOUND %@",[obj valueForKey:@"delivery_address"]);
            {
                NSMutableDictionary *TempDictionary = [[NSMutableDictionary alloc]init];
                [TempDictionary setValue:[obj valueForKey:@"delivery_address"] forKey:@"DelAdd"];
                [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
                [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
                [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
                [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
                [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
                [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
                [TempDictionary setValue:[NSNumber numberWithInt:0] forKey:@"lineno"];
                [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
                [TempDictionary setValue:[NSDate date] forKey:@"Deldate"];
                //Default Quantity
                NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
                if ([arrDefault count]>0 && [arrayDel count]==1){
                    [TempDictionary setValue:[NSString stringWithFormat:@"%li",(long)[[_productDetail valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] forKey:@"DelQty"];
                }else
                    [TempDictionary setValue:@"0" forKey:@"DelQty"];
                
                
                
                [tempArray addObject:TempDictionary];
            }
        }];
    }
    if ([tempArray count]>0) {
        [_arrRows removeAllObjects];
        //_arrRows=[NSMutableArray arrayWithArray:tempArray];
        
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
        NSArray *descriptor = @[sortDescriptor];
        _arrRows =[NSMutableArray arrayWithArray: [tempArray sortedArrayUsingDescriptors:descriptor]];
        
        
    }
    [_productDetailContentTable reloadData];
    
    if (error != nil)
    {
        // handle error
        abort(); // TEMP
    }
    
}

-(void)addNewDeliveryAdd:(NSDate* )dateVal{
    NSArray *remDel=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSString *entityName=@"CUST";
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    
    
    if (self.updatedDeliveryAddressArray.count>0){
        
         NSArray *delAddArr=[_arrRows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" self.DelAdd ==%@ && self.Deldate==%@",[self.updatedDeliveryAddressArray lastObject],dateVal]];
        if ([delAddArr count]>0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"  message:@"Please change date with this delivery address."   delegate:self  cancelButtonTitle:@"Ok"otherButtonTitles: nil];
            [alert setDelegate:self];
            [alert show];
            return;
        }
        
        /*if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
         NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && deliveryaddresscode  IN %@", [_productDetail valueForKey:@"stock_code"],self.updatedDeliveryAddressArray];
         NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
         remDel=[self.updatedDeliveryAddressArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Not self IN %@",[filteredArr valueForKey:@"deliveryaddresscode"]]];
         }else*/
        remDel=self.updatedDeliveryAddressArray;
        
        if([remDel count]>0){
            
        NSString *filterDeliveryAddress = [NSString stringWithFormat:@"acc_ref=='%@' && delivery_address =='%@'",[self.customerInfo valueForKey:@"acc_ref"],[remDel lastObject]];
       NSPredicate* predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *arrayDel=[kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSMutableDictionary *TempDictionary = [[NSMutableDictionary alloc]init];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"delivery_address"] forKey:@"DelAdd"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"postcode"] forKey:@"postcode"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr1"] forKey:@"addr1"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr2"] forKey:@"addr2"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr3"] forKey:@"addr3"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr4"] forKey:@"addr4"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr5"] forKey:@"addr5"];
        [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"acc_ref"] forKey:@"acc_ref"];
        [TempDictionary setValue:dateVal forKey:@"Deldate"];
        //Default Quantity
        [TempDictionary setValue:@"0" forKey:@"DelQty"];
        
        [_arrRows addObject:TempDictionary];
        
        [globalObjectDelegate.deliveryAddArray addObject:TempDictionary];
        }
    }
    
}

-(NSString *)getValueWithFieldName:(NSString *)field Table:(NSString *)table{
    if([[table uppercaseString] hasPrefix:@"PROD"]){
        return [CommonHelper getFieldValueWithFieldName:field Source:_productDetail];
    }
    else{
        return @"";
    }
}


-(void)deliveryAddress:(UIButton*)sender{
    self.title=@"";
    CustomerDeliveryAddressViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerDeliveryAddress"];
    controller.delegate=self;
    controller.isFromProduct=YES;
    controller.isFromCustomer=NO;
    controller.customerInfo = self.customerInfo;
    // controller.selectedDeliveryAddress=selectedDeliveryAddress;
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)btnDate_btnQty_clicked:(UIButton *)sender{
    
    selIndexPath=[NSIndexPath indexPathForRow:[sender tag] inSection:0];

    NSDictionary *dic = [_arrRows objectAtIndex:sender.tag];
    
    DatePickerViewController *datePickerViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
    datePickerViewController.title=@"Select";
    datePickerViewController.isDateRange=NO;
    datePickerViewController.selectedDate=[dic valueForKey:@"Deldate"];
    datePickerViewController.delegate=self;
    datePickerViewController.isCallBack=NO;
    [self.navigationController pushViewController: datePickerViewController animated:YES];
    
}

-(IBAction)btnQtyclicked:(UIButton *)sender{
    selIndexPath=[NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
    Numerickeypad *obj=  (Numerickeypad *)[self.storyboard instantiateViewControllerWithIdentifier:@"Numerickeypad"];
    obj.clickBtn=sender;
    [obj setDelegate:self];
    obj.view.frame = self.view.bounds;
    obj.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    obj.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:obj animated:NO completion:^{
        
    }];
}

-(void)cancelkeyClick{
    //    if([numpadVC parentViewController])
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark -  UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    //for showing product delivery
    if (self.productSegmentedControlIndex==3){
        
        static NSString* identifier=@"ProductDetailContentDeliveryTableViewCell";
        ProductDetailContentDeliveryTableViewCell *cellDelivery=(ProductDetailContentDeliveryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSDictionary *record = [_arrRows objectAtIndex:indexPath.row];
        cellDelivery.delIdValue.text=[record valueForKey:@"DelAdd"];
        selectedDeliveryAddress=cellDelivery.delIdValue.text;
        cellDelivery.townValue.text=[record valueForKey:@"addr4"];

        [cellDelivery.btnDate setTitle:[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"Deldate"]] forState:UIControlStateNormal];
        [cellDelivery.btnQuantity setTitle:[record valueForKey:@"DelQty"] forState:UIControlStateNormal];
        
        [cellDelivery.btnDate setTag:indexPath.row];
        [cellDelivery.btnQuantity setTag:indexPath.row];
        
        cell=cellDelivery;
    }
    //for showing product different prices
    else if (self.productSegmentedControlIndex==4){
        //for showing product  price
        
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
        
        
        
        //Check last paid price
       /* BOOL lastpaidPrice=NO;
        double lastPrcpaid=0;
        if (![[userConfigDict objectForKey:@"lastorderpriceasdefaultorderpriceenabled"] isEqual:[NSNull null]] && [[userConfigDict valueForKey:@"lastorderpriceasdefaultorderpriceenabled"] boolValue]) {
            lastpaidPrice=YES;
            NSSortDescriptor *lastUsedSortDescription = [NSSortDescriptor sortDescriptorWithKey:@"invoicehead.invoiced_date" ascending:YES];
            NSArray *sortedArray = [[[_productDetail valueForKeyPath:@"invoicelines"] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:lastUsedSortDescription]];
            if([sortedArray count]){
                NSManagedObject *invinfo = [sortedArray firstObject];
                lastPrcpaid=[[invinfo valueForKey:@"price_invoiced"] doubleValue];
            }
            
        }*/

        
        if (self.productPricesIndex==0) {
            static NSString* identifier=@"ProductDetailContentPricesTableViewCell";
            ProductDetailContentPricesTableViewCell *cellPrices=(ProductDetailContentPricesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            
            
            //Mahendra load product data from priceConfig
            NSDictionary* packDic = [_arrRows objectAtIndex:indexPath.row];
            
            if (indexPath.row <[[priceConfigDict objectForKey:@"pricetablabels"] count]) {
                
                NSString *strprclabel=@"";
                if (![[packDic valueForKey:@"label"] isEqual:[NSNull null]])
                    strprclabel = [packDic valueForKey:@"label"];
                cellPrices.lblPriceCaption.text=strprclabel;
                
                NSString *strqty=[CommonHelper getFieldValueWithFieldName:[packDic valueForKey:@"qtyfield"] Source:_productDetail];
                if([strqty integerValue]==0) strqty=nil;
                cellPrices.lblQty.text = strqty;
                
                NSString *strprcfield=@"";
                if (![[packDic valueForKey:@"field"] isEqual:[NSNull null]])
                    strprcfield = [packDic valueForKey:@"field"];
                NSString *strprice=[CommonHelper getFieldValueWithFieldName:strprcfield Source:_productDetail];
                
                // to find if currency code exist in label
                NSString *currCodeFound=[kAppDelegate.dicCurrencies objectForKey:[[[strprclabel componentsSeparatedByString:@" "] lastObject] uppercaseString]];
                
                cellPrices.lblPrice.text = [CommonHelper getCurrencyFormatWithCurrency:currCodeFound Value:[strprice doubleValue]];
                
                
                NSDictionary *SelectedPriceRow;
                
                if ( self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
                    NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_productDetail valueForKey:@"stock_code"]];
                    NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
                    
                    if ([filteredArr count]>0){
                        NSManagedObject *obj=[filteredArr firstObject];
                        SelectedPriceRow= [[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:obj PriceConfig:priceConfigDict UserConfig:userConfigDict] objectForKey:@"selectedpricerow"];
                    }else
                        SelectedPriceRow= [[CommonHelper getProductPrices:priceConfigDict Product:self.productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDict] objectForKey:@"selectedpricerow"];
                }else
                    SelectedPriceRow=[[CommonHelper getProductPrices:priceConfigDict Product:_productDetail Customer:self.customerInfo SelectedPriceRow:[kUserDefaults  valueForKey:@"SelPriceRow"]  DefaultPrice:defPrice Transaction:nil PriceConfig:priceConfigDict UserConfig:userConfigDict] objectForKey:@"selectedpricerow"];
                
                cellPrices.checkImg.image=nil;
                
               
                if ( [[[SelectedPriceRow valueForKey:@"selectedpriceLabel"] lowercaseString]length]>0 && [[strprcfield lowercaseString] isEqualToString:[[SelectedPriceRow valueForKey:@"selectedpricerow"] lowercaseString]] && [[strprclabel lowercaseString] isEqual:[[SelectedPriceRow valueForKey:@"selectedpriceLabel"] lowercaseString]]) {//(!lastpaidPrice || lastPrcpaid==0) &&
                    cellPrices.checkImg.image=bluecheckImgPriceTab;
                }else if( [[strprcfield lowercaseString] isEqualToString:[[SelectedPriceRow valueForKey:@"selectedpricerow"] lowercaseString]] && [[kUserDefaults  valueForKey:@"SelPriceRow"] count]==0) //without selection default case// (!lastpaidPrice || lastPrcpaid==0 ) &&
                    cellPrices.checkImg.image=bluecheckImgPriceTab;
                
            }else{
                cellPrices.lblPriceCaption.text=[[_arrRows objectAtIndex:indexPath.row] valueForKey:@"label"];
                cellPrices.lblPrice.text=[[_arrRows objectAtIndex:indexPath.row] valueForKey:@"field"];
                cellPrices.checkImg.image=nil;
                cellPrices.lblQty.text=@"";
            }
            
            cell=cellPrices;
            
        }
        //for showing product last  price
        else if (self.productPricesIndex==1){
            static NSString* identifier=@"ProductDetailContentLastPriceCustSpecialPriceTableViewCell";
            ProductDetailContentLastPriceCustSpecialPriceTableViewCell *cellLastPrices=(ProductDetailContentLastPriceCustSpecialPriceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            
            NSDictionary* invinfo = [_arrRows objectAtIndex:indexPath.row];
            cellLastPrices.lblPriceCaption.text = [invinfo valueForKey:@"label"];
            cellLastPrices.lblPrice.text = [invinfo valueForKey:@"pricedisplay"];
            cellLastPrices.lblDate.text =[dateFormat stringFromDate:[invinfo valueForKey:@"date"]];
            cellLastPrices.lblQty.text = [NSString stringWithFormat:@"%li",(long)[[invinfo valueForKey:@"qty"] integerValue]];
            cell=cellLastPrices;
       
        
            if ( [kUserDefaults  valueForKey:@"SelPriceRow"]==nil && [[kUserDefaults  valueForKey:@"SelPriceRow"] count]==0) {  //(lastpaidPrice || lastPrcpaid>0) &&
                cellLastPrices.btnCheck.image=bluecheckImgPriceTab;
            }else
                cellLastPrices.btnCheck.image=nil;
        
        
        }
        //for showing product discount price
        else if (self.productPricesIndex==2 ){
            static NSString* identifier=@"ProductDetailContentDiscountPriceTableViewCell";
            ProductDetailContentDiscountPriceTableViewCell *cellDiscountPrices=(ProductDetailContentDiscountPriceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            NSDictionary* hederDiscinfo = [_arrRows objectAtIndex:indexPath.row];
            //            NSDictionary* discinfo = [_arrRows objectAtIndex:indexPath.row];
            //            if([[[priceConfigDict valueForKey:@"orderconfigs"] valueForKey:@"headerdiscountenabled" ] boolValue])
            [cellDiscountPrices.btnDiscount setEnabled:YES];
            //            else
            //                [cellDiscountPrices.btnDiscount setEnabled:NO];
            [cellDiscountPrices.btnDiscount setTag:indexPath.row];
            
            double totalPriceValue=0.0;
            for (NSManagedObject *object in [self.transactionInfo valueForKey:@"orderlinesnew" ] ) {
                totalPriceValue = totalPriceValue +[[object valueForKey:@"linetotal"] doubleValue];
                
            }
            
            cellDiscountPrices.lblBand.text=[hederDiscinfo valueForKey:@"prodband"];
            cellDiscountPrices.lblDisc.text=[NSString stringWithFormat:@"%0.2f",[[hederDiscinfo valueForKey:@"disc"] doubleValue]];
            cellDiscountPrices.lblOnOrder.text=[NSString stringWithFormat:@"%0.2f",totalPriceValue];
            cellDiscountPrices.lblThisYear.text=@"";
            cellDiscountPrices.lblLastYear.text=@"";
            
            cell=cellDiscountPrices;
        }
    }
    //for showing product purchases
    else if (self.productSegmentedControlIndex==6){
        static NSString* identifier=@"ProductDetailContentPurchasesTableViewCell";
        ProductDetailContentPurchasesTableViewCell *cellPurchases=(ProductDetailContentPurchasesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSManagedObject *record = [_arrRows objectAtIndex:indexPath.row];
        cellPurchases.purOrderRefValue.text=[record valueForKey:@"po_no"];
        cellPurchases.expectedDateValue.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy" Date:[record valueForKey:@"due_date"]];
        cellPurchases.quantityValue.text=[[record valueForKey:@"due_qty"] stringValue];
        if ([[record valueForKey:@"shipped"] isEqualToString:@"N"])
            cellPurchases.shippedValue.text=@"NO";
        else  if ([[record valueForKey:@"shipped"] isEqualToString:@"Y"])
            cellPurchases.shippedValue.text=@"YES";
        else
            cellPurchases.shippedValue.text=[record valueForKey:@"shipped"];
        
        cell=cellPurchases;
        
    }
    return cell;
}

#pragma mark -  UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.productSegmentedControlIndex==4){
        if (self.productPricesIndex==0) {
            ProductDetailContentPricesTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            
            
            //Customer Price diff then selected price
            NSDictionary* packDic = [_arrRows objectAtIndex:indexPath.row];
            NSString *strprclabel=@"";
            if (![[packDic valueForKey:@"label"] isEqual:[NSNull null]])
                strprclabel = [packDic valueForKey:@"label"];
            
            NSString *currCodeFound=[kAppDelegate.dicCurrencies objectForKey:[[[strprclabel componentsSeparatedByString:@" "] lastObject] uppercaseString]];
            
            if ([currCodeFound length]==0) {//if No currency code found change this by defaultcompany currency code
                currCodeFound=[kUserDefaults  valueForKey:@"defaultcurrency"];
            }
            
            
            NSString *defaultCompCurrSymbol=[CommonHelper getCurrSymbolWithCurrCode:[priceConfigDict valueForKey:@"defaultcurrency"]];
            
            if (![[packDic valueForKey:@"selectable"] boolValue]){ //|| ![defaultCompCurrSymbol isEqual:[CommonHelper getCurrSymbolWithCurrCode:currCodeFound]] ) {
                return;
            }else  if ((currCodeFound !=nil && self.customerInfo && ![[[self.customerInfo valueForKey:@"curr"] lowercaseString] isEqual:[currCodeFound lowercaseString]])) {
                return;
            }else if (self.customerInfo ==nil && ![defaultCompCurrSymbol isEqual:[CommonHelper getCurrSymbolWithCurrCode:currCodeFound]])
                return;
            
            
            cell.checkImg.image=bluecheckImgPriceTab;
            
            for(NSIndexPath *ipath in [tableView indexPathsForVisibleRows]){
                if(![ipath isEqual:indexPath]){
                    ProductDetailContentPricesTableViewCell *Tempcel= [tableView cellForRowAtIndexPath:ipath];
                    Tempcel.checkImg.image=nil;
                }
            }
            
            NSDictionary* dicSelPriceRow = [[priceConfigDict objectForKey:@"pricetablabels"] objectAtIndex:indexPath.row];
            
            if (dicSelPriceRow != nil && dicSelPriceRow.count>0) {
                //  [self.delegate refreshOrdPnlPrice:dicSelPriceRow];
                
                /* if (self.transactionInfo ) {
                 
                 NSMutableData *data = [[NSMutableData alloc] init];
                 NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                 [archiver encodeObject:dicSelPriceRow forKey:@"selpricerow"];
                 [archiver finishEncoding];
                 
                 
                 [self.transactionInfo setValue:data forKey:@"selpricerow"];
                 NSError *error = nil;
                 if (![kAppDelegate.managedObjectContext save:&error]) {
                 NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                 }
                 }*/
                
                [kUserDefaults  setObject:dicSelPriceRow forKey:@"SelPriceRow"];
                [kUserDefaults  synchronize];
                
                [kNSNotificationCenter postNotificationName:kSelectedPriceRow  object:self userInfo:dicSelPriceRow];
            }
        }
        else if (self.productPricesIndex==1){
            ProductDetailContentLastPriceCustSpecialPriceTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
            DebugLog(@"didSelectRowAtIndexPath 2");
            cell.btnCheck.image=bluecheckImgPriceTab;
            
        } else if (self.productPricesIndex==2){
          
            
            
        }else if (self.productPricesIndex==3){
          
              DebugLog(@"didSelectRowAtIndexPath 3");
            
        }
        
        
    }
    else if (self.productSegmentedControlIndex==3){
        
        //        NSManagedObject *record = [_arrRows objectAtIndex:indexPath.row];
        //        selectedDeliveryAddress =[record valueForKey:@"delivery_address"];
        //
        //        //Notification update data in ProductOrderPanel
        //        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[selectedDeliveryAddress, [NSNumber numberWithInt:1]]  forKeys:@[@"title", @"dateval"]];
        //        [kNSNotificationCenter postNotificationName:kDeliverInfoChange  object:self userInfo:dict];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString* identifier= nil;
    UITableViewCell *cellHeader = nil;
    //for  product  delivery
    if (self.productSegmentedControlIndex==3) {
        identifier=@"ProductDetailContentDeliveryTableViewHeaderCell";
        ProductDetailContentDeliveryTableViewCell *cellHeadertmp=[tableView dequeueReusableCellWithIdentifier:identifier];
        
        UIButton *btndelivery =(UIButton *)  [cellHeader.contentView viewWithTag:111];
        if(!btndelivery){
            btndelivery = [UIButton buttonWithType:UIButtonTypeContactAdd];
            btndelivery.tag = 111;
            btndelivery.frame = CGRectMake(50, 3, 20, 20);
            [btndelivery setTitle:@"" forState:UIControlStateNormal];
            [btndelivery addTarget:self action:@selector(deliveryAddress:) forControlEvents:UIControlEventTouchUpInside];
            
            [cellHeadertmp.contentView addSubview:btndelivery];
        }
        cellHeader = cellHeadertmp;
    }
    //for showing product different price
    else if (self.productSegmentedControlIndex==4)
    {
        //for showing product  price
        if (self.productPricesIndex==0)
        {
            identifier=@"ProductDetailContentPricesTableViewHeaderCell";
        }
        //for showing product last price
        else if (self.productPricesIndex==1){
            
            identifier=@"ProductDetailContentLastPriceCustSpecialPriceTableViewHeaderCell";
        }
        //for showing product discounted price
        else if (self.productPricesIndex==2){
            identifier=@"ProductDetailContentDiscountPriceTableViewHeaderCell";
        }
        
        cellHeader =[tableView dequeueReusableCellWithIdentifier:identifier];
        
    }// for showing product purchases
    else if (self.productSegmentedControlIndex==6){
        identifier=@"ProductDetailContentPurchasesTableViewHeaderCell";
        cellHeader =[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    return  cellHeader;;
}

#pragma mark - UITableViewDataSource
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   // DebugLog(@"%i",indexPath.row);
    if (indexPath.row >0 && self.productSegmentedControlIndex==3)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >0 && self.productSegmentedControlIndex==3){
        UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self TableCell_DeleteClicked:indexPath];
        }];
        button.backgroundColor = [UIColor redColor];
        return @[button];
    }else{
        return nil;
    }
  
}

- (void) TableCell_DeleteClicked :(NSIndexPath *)indexPath{
    DebugLog(@"delevery deleted");
   // ProductDetailContentDeliveryTableViewCell *cell = (ProductDetailContentDeliveryTableViewCell *) [_productDetailContentTable cellForRowAtIndexPath:indexPath];
    
    NSDictionary *deleteDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:indexPath.row]];
    
    
    NSInteger Quantity=[[deleteDict valueForKey:@"DelQty"] integerValue];//Deleted row quantity
    
    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:0]];
    Quantity=Quantity+[[tempDict valueForKey:@"DelQty"]integerValue];//Add deleted quantity in first row
    [tempDict setValue:[NSString stringWithFormat:@"%li",(long)Quantity]  forKey:@"DelQty"];
    [_arrRows replaceObjectAtIndex:0 withObject:tempDict];

    
    //update first row db
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
    NSArray *descriptor = @[sortDescriptor];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]];
    NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate]sortedArrayUsingDescriptors:descriptor];
    NSManagedObject *lineObject=[tempLinesArr firstObject];
    
    [lineObject setValue:[NSNumber numberWithInteger:Quantity ] forKey:@"quantity"];
    [lineObject setValue:[NSNumber numberWithDouble:([[lineObject valueForKey:@"saleprice"] doubleValue]*Quantity)] forKey:@"linetotal"];
    
     //delete   row db
    predicate=nil;
    predicate=[NSPredicate predicateWithFormat:@" productid ==%@ && requireddate==%@ && deliveryaddresscode ==%@",[_productDetail valueForKey:@"stock_code"],[deleteDict valueForKey:@"Deldate"],[deleteDict valueForKey:@"DelAdd"]];
    NSArray*  tempLinesArr2=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate];
    if ([tempLinesArr2 count]>0) {
        [kAppDelegate.managedObjectContext deleteObject:[tempLinesArr2 lastObject]];
        
    }
    
    [_arrRows removeObjectAtIndex:indexPath.row];
  //
    NSError *error = nil;
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
    
  //Reload new data rows
    [_productDetailContentTable reloadData];
}


#pragma mark - Delivery Address Delegate Methods
-(void)finishedDeliveryDoneSelection:(NSMutableArray*)selAcc_Ref{
    self.updatedDeliveryAddressArray =[[NSMutableArray alloc]init];
    [self.updatedDeliveryAddressArray addObjectsFromArray:selAcc_Ref];
    if (self.updatedDeliveryAddressArray.count>0) {
        // [self getDeliveryData];
        NSDate *date=[self upadateDate:[self.updatedDeliveryAddressArray lastObject]];
        
        [self addNewDeliveryAdd:date];
        [self.productDetailContentTable reloadData];
        
        /* NSString *delAdd=selectedDeliveryAddress;
         NSString *deldate=[dateFormat stringFromDate:date];
         NSString *delQty;
         NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
         if ([arrDefault count]>0 && [self.updatedDeliveryAddressArray count]==0){
         delQty=[NSString stringWithFormat:@"%li",(long)[[_productDetail valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] ;
         }else
         delQty=@"0" ;
         
         
         //  NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[delAdd,deldate,delQty ]  forKeys:@[@"delAdd", @"deldate",@"delQty"]];
         //  [kNSNotificationCenter postNotificationName:kDeliverInfoChange  object:self userInfo:dict];*/
    }
}

-(NSDate*)upadateDate:(NSString *)delAdd{
    NSDate *date=[NSDate date];
    NSArray *delAddArr=[_arrRows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" self.DelAdd ==%@ && self.Deldate==%@",delAdd,[dateFormat stringFromDate:date]]];
    if ([delAddArr count]>0) {
        int daysToAdd = 1;
        date=[[NSDate date] dateByAddingTimeInterval:60*60*24*daysToAdd];
    }
    return date;
}

#pragma mark - CustomDatePickerViewController Delegate
-(void)finishedSelectionWithDate:(NSDate *)seldate{
    selectedDate = seldate;
    [_productDetailContentTable reloadData];

    //Notification update data in ProductOrderPanel
    NSString *delAdd=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"DelAdd"];
    NSString *delQty=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"];

    //update Row
    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
    NSDate *lastDate=[tempDict valueForKey:@"Deldate"];
    
    [tempDict setValue:seldate forKey:@"Deldate"];
    [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
    [_productDetailContentTable reloadData];
    //ended


    NSArray *filterArr=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid == %@ ",[_productDetail valueForKey:@"stock_code"]]];
    
    if ( [filterArr    count]>0){
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && deliveryaddresscode==%@ && requireddate = %@", [_productDetail valueForKey:@"stock_code"],delAdd,lastDate];
        NSArray *filteredProdArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        if ([filteredProdArr count]>0){
            
            NSManagedObject *olineObject=[filteredProdArr firstObject];
            [olineObject setValue:seldate forKey:@"requireddate"];
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }
    }
    
    
    
    
    
    /*if (delQty >0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[delAdd,seldate,delQty ]  forKeys:@[@"delAdd", @"deldate",@"delQty"]];
        [kNSNotificationCenter postNotificationName:kDeliverInfoChange  object:self userInfo:dict];
    }*/
}

#pragma mark - NumPad Delegate
-(void)retuenkeyClickwithOption:(NSString *)values Button:(UIButton* )btn{
    NSInteger qtyvalues=[values integerValue];
   
    tempArray=nil;
    tempArray=[NSArray arrayWithArray:_arrRows ];
    
    if (self.productSegmentedControlIndex==4){
        if (self.productPricesIndex==0)
        {
            
        } else if (self.productPricesIndex==1){
            
            
        } else if (self.productPricesIndex==2){
            ProductDetailContentDiscountPriceTableViewCell *Cell = (ProductDetailContentDiscountPriceTableViewCell *)btn.superview.superview;
            Cell.lblDisc.text=[NSString stringWithFormat:@"%0.2f",[values doubleValue]];
            
            if([[Cell.lblBand.text lowercaseString] isEqual:@"all"]){
                [self.transactionInfo  setValue:[NSNumber numberWithFloat:[values doubleValue]] forKey:@"custdisc"];
            }else{
                
                // NSMutableDictionary *dict=[NSMutableDictionary alloc]initWithDictionary:<#(nonnull NSDictionary *)#>
                
                NSMutableArray *stockArr = [NSMutableArray arrayWithArray: [kUserDefaults  objectForKey:@"StockBandArray"]];
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"prodband ==%@ && custband==%@",Cell.lblBand.text,[kAppDelegate.customerInfo valueForKey:@"acc_ref"]];
                NSDictionary *dict=[[stockArr filteredArrayUsingPredicate:predicate] lastObject];
                NSUInteger index = [stockArr indexOfObject:dict];
                
                NSMutableDictionary *dictCopy =[NSMutableDictionary dictionaryWithDictionary:[[stockArr filteredArrayUsingPredicate:predicate] lastObject]];
                [dictCopy setValue:[NSString stringWithFormat:@"%0.2f",[values doubleValue] ] forKey:@"disc"];
                
                [stockArr replaceObjectAtIndex:index withObject:dictCopy];
                
                [kUserDefaults  setObject:stockArr forKey:@"StockBandArray"];
                [kUserDefaults  synchronize];
               
            }
            
            NSError *error = nil;
            if (![kAppDelegate.managedObjectContext save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
            
            //For reload  product data when header discount added
            [kNSNotificationCenter postNotificationName:kReloadProduct object:nil userInfo:nil ];
        }
        
        
        
        
    }else{
      
    [_productDetailContentTable reloadData];
    
    //Notification update data in ProductOrderPanel
    NSString *delAdd=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"DelAdd"];
    NSDate *deldate=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"Deldate"];;
    
    //  NSString *delQty=values;
    
    if (self.traitCollection) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
        NSArray *descriptor = @[sortDescriptor];
        NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]]]sortedArrayUsingDescriptors:descriptor];
        //       NSInteger totVal=[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue];
        NSManagedObject *lineObject=[tempLinesArr firstObject];
        
        if ([tempLinesArr count]>0 && selIndexPath.row>0){
            
            
            NSInteger FirstPrevRowQty=[[lineObject valueForKey:@"quantity"] integerValue];
            NSInteger firstrowQty=0;
            if ([[[_arrRows  objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"]integerValue]>qtyvalues) {
                
                NSInteger currentQty= [[[_arrRows  objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"]integerValue]-qtyvalues;
                
                firstrowQty=FirstPrevRowQty+currentQty;
                
            }else{
                NSInteger currentQty= [[[_arrRows  objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"]integerValue]-qtyvalues;
                
                if (currentQty>0) {
                    firstrowQty=  FirstPrevRowQty-currentQty;
                }else
                    firstrowQty=  FirstPrevRowQty+currentQty ;
                
            }
            
            
            
            NSInteger FQty=0;
            /* if (FirstPrevRowQty==0){
             
             FQty=(FirstPrevRowQty+qtyvalues);
             
             NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
             [tempDict setValue:@"0" forKey:@"DelQty"];
             [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
             
             }else*/{
                 FQty= firstrowQty;
                 
                 
                 NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
                 [tempDict setValue:[NSString stringWithFormat:@"%li",(long)qtyvalues]  forKey:@"DelQty"];
                 [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
                 
             }
            
            //Remove quantity from previous first row
            if (FQty>0) {
                [lineObject setValue:[NSNumber numberWithInteger:FQty ] forKey:@"quantity"];
                [lineObject setValue:[NSNumber numberWithDouble:([[lineObject valueForKey:@"saleprice"] doubleValue]*FQty)] forKey:@"linetotal"];
                
                if (qtyvalues<=0) {//delete Selected row if quantity equal to 0
                  //OLD  NSArray*  tempLinesArr=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ &&requireddate==%@ && deliveryaddresscode ==%@",[_productDetail valueForKey:@"stock_code"],deldate,delAdd]];
                   NSArray*  tempLinesArr=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ && requireddate==%@ && deliveryaddresscode ==%@",[_productDetail valueForKey:@"stock_code"],deldate,delAdd]];
                    if ([tempLinesArr count]>0) {
                        [kAppDelegate.managedObjectContext deleteObject:[tempLinesArr lastObject]];
                    }
                }
                
                //update table Row
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:0]];
                [tempDict setValue:[NSString stringWithFormat:@"%li",(long)FQty]  forKey:@"DelQty"];
                [_arrRows replaceObjectAtIndex:0 withObject:tempDict];
                
            }else{
                //less then 0 then delete 1 st object object
                [kAppDelegate.managedObjectContext deleteObject:lineObject];
                [_arrRows removeObjectAtIndex:0];
                
                //Manage lineno
                NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]]]sortedArrayUsingDescriptors:descriptor];
                for (NSManagedObject *obj in  tempLinesArr) {
                    NSString* lineno=[obj valueForKey:@"lineno"];
                    [obj setValue:[NSString stringWithFormat:@"%li",(long)([lineno integerValue]-1)] forKey:@"lineno"];
                }
                
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
                
            }
            
        }else{
            
            NSInteger firstrowQty = [[[_arrRows  objectAtIndex:0]valueForKey:@"DelQty"]integerValue];
            if (firstrowQty==0 && selIndexPath.row>0) {
                
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:0]];
                [tempDict setValue:values  forKey:@"DelQty"];
                [_arrRows replaceObjectAtIndex:0 withObject:tempDict];
                
                delAdd=[tempDict valueForKey:@"DelAdd"];
                deldate=[tempDict valueForKey:@"Deldate"];
//                del =[dateFormat dateFromString:[tempDict valueForKey:@"Deldate"]];
                tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
                [tempDict setValue:@"0" forKey:@"DelQty"];
                [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
                
            } else {
                //Add value in first row
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
                [tempDict setValue:values forKey:@"DelQty"];
                [_arrRows removeObjectAtIndex:selIndexPath.row];
                [_arrRows insertObject:tempDict atIndex:0];
                
                if (qtyvalues<=0) {//delete first row
                    
                    [_arrRows removeObjectAtIndex:selIndexPath.row];
                    
                    [kAppDelegate.managedObjectContext deleteObject:lineObject];
                    //Manage lineno
                    NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]]]sortedArrayUsingDescriptors:descriptor];
                    for (NSManagedObject *obj in  tempLinesArr) {
                        NSString* lineno=[obj valueForKey:@"lineno"];
                        [obj setValue:[NSString stringWithFormat:@"%li",(long)([lineno integerValue]-1)] forKey:@"lineno"];
                    }
                    NSError *error = nil;
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }
                
                
            }
            
        }
        
        [_productDetailContentTable reloadData];
        
    }
    
   //update order panel
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[delAdd,deldate,[NSString stringWithFormat:@"%li",(long)qtyvalues] ]  forKeys:@[@"delAdd", @"deldate",@"delQty"]];
    [kNSNotificationCenter postNotificationName:kDeliverInfoChange  object:self userInfo:dict];
}



}


-(void)cancelChanges:(NSNotification *) notification{
    
    if ([[notification name] isEqualToString:kCancelChanges]){
        [_arrRows removeAllObjects];
        _arrRows=[NSMutableArray arrayWithArray:tempArray];
        [_productDetailContentTable reloadData];
    }
}





#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_arrRows count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"extraColl";
    extraColl* collCell = (extraColl *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dicinfo=[_arrRows objectAtIndex:indexPath.row];
    collCell.lblQtyCaption.text= [NSString stringWithFormat:@"%@:",[dicinfo objectForKey:@"label"]];
    collCell.lblCaptionValue.text=[self getValueWithFieldName:[dicinfo objectForKey:@"field"] Table:[dicinfo objectForKey:@"table"]];
    return collCell;
}

#pragma mark - Collection View Delegate
//******************************     Collection view for grid
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(((_extraInfoCollView.bounds.size.width-5)/2), 25);
    // A total of 4 views displayed at a time,  we divide width / 4,
    // and cell will automatically adjust its size.
}


#pragma mark - deliveryTable reload
- (void) updateDeliveryInfo:(NSNotification *) notification
{
    if (self.productSegmentedControlIndex==3) {
         [self getDeliveryData];
    }
   
}

- (IBAction)headerDiscountClick:(id)sender {
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

//Load product order
-(NSArray *)load_ProductOrder:(NSManagedObject*)prod{
    NSError *err = nil;
    BOOL isError = NO;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PURCHASEORDERS" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    NSArray *allPOs = [kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
    if(!isError) isError = err!=nil;
    
    if(!isError){
        NSArray *productPOs = [allPOs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productcode == %@",[prod valueForKey:@"stock_code"]]];// [context executeFetchRequest:fetch error:&err];
        NSSet *prodPOs = [NSSet setWithArray:productPOs];
        NSArray *retArr  = [prodPOs allObjects];
        return retArr;
    }
    return  nil;
}
//ENDED


@end
