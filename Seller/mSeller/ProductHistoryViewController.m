//
//  ProductHistoryViewController.m
//  mSeller
//
//  Created by Ashish Pant on 10/21/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductHistoryViewController.h"
#import "OrderHelper.h"
@interface ProductHistoryViewController (){
    NSString *productCode;
    NSMutableArray *arrayOfindexpath;
    NSManagedObject *selectedManagedObject;
    CGFloat distance;
    
}
@property(nonatomic,strong)NSMutableArray *historyArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityindicator;
@property (weak, nonatomic) IBOutlet UILabel *lblDataLoading;
@property (weak, nonatomic) IBOutlet UITextView *txtviewtotalRecordsCount;
@end

@implementation ProductHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_activityindicator stopAnimating];
    [_lblDataLoading setHidden:YES];

    [_txtviewtotalRecordsCount.layer setMasksToBounds:YES];
    _txtviewtotalRecordsCount.layer.cornerRadius = 8;
    
    
    self.historyArray=[[NSMutableArray alloc]init];

    [self loadCustomerHistory];
    arrayOfindexpath = [[NSMutableArray alloc]init];
}

-(void)setProductDetail:(id)object{
        
    _productDetails=object;
}


-(void)loadCustomerHistory{
    NSMutableArray *tempArray = [NSMutableArray array];
    if([[self.customerInfo valueForKeyPath:@"oheads.orderlines"] count]>0){
        [[[self.customerInfo valueForKey:@"oheads"] allObjects] enumerateObjectsUsingBlock:^(id _Nonnull ohead, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *arrOlines = [[ohead valueForKey:@"orderlines"] allObjects];
            [tempArray addObjectsFromArray:arrOlines];
        }];
    }
    if([[self.customerInfo valueForKeyPath:@"iheads.invoicelines"] count]>0){
        //    [[[self.customerInfo valueForKeyPath:@"oheads.orderlines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"product_code == %@",[_productDetails valueForKey:@"stock_code"]]];
        [[[self.customerInfo valueForKey:@"iheads"] allObjects] enumerateObjectsUsingBlock:^(id _Nonnull ohead, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *arrIlines = [[ohead valueForKey:@"invoicelines"] allObjects];
            [tempArray addObjectsFromArray:arrIlines];
        }];
    }

    NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"product_code" ascending:YES]]];
    [self.historyArray removeAllObjects];
    [self.historyArray addObjectsFromArray:sortedArray];

    [self performSelector:@selector(selectMatchedRow) withObject:nil afterDelay:0.00];

}

-(void)selectMatchedRow{

    NSIndexSet *indexset = [self.historyArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[obj valueForKey:@"product_code"] isEqualToString:[_productDetails valueForKey:@"stock_code"]];

    }];

    __block BOOL isTop = YES;
    [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [_historyTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:isTop?UITableViewScrollPositionTop:UITableViewScrollPositionNone];
        if(isTop) isTop = NO;
    }];
    DebugLog(@"selectMatchedRow sdsdsd = ");
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
        return [self.historyArray count];
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"toProductHistory";
    ProductHistoryTableViewCell *cell=(ProductHistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    NSManagedObject *record = [self.historyArray objectAtIndex:indexPath.row];
    NSManagedObject * product=[record valueForKey:@"product"];
    if ([record.entity.name isEqualToString:@"OLINES"])
     {
        NSManagedObject *ohead=[record valueForKey:@"orderhead"];

        cell.productCode.text=[record valueForKey:@"product_code"];
        cell.productDescription.text=[product valueForKey:@"gdescription"];
        cell.qtyValue.text=[[record valueForKey:@"tot_ord_qty"] stringValue];
        cell.freeValue.text=[[product valueForKey:@"qty_free"] stringValue];
        cell.priceValue.text=[[record valueForKey:@"price_ordered"] stringValue];
        cell.lastValue.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy" Date:[ohead valueForKey:@"order_date"]];

        cell.isInvoiced = NO;
    }
    else
    {
        NSManagedObject *ihead=[record valueForKey:@"invoicehead"];

        cell.productCode.text=[record valueForKey:@"product_code"];
        cell.productDescription.text=[product valueForKey:@"gdescription"];
        cell.qtyValue.text=[[record valueForKey:@"tot_invoiced_qty"] stringValue];
        cell.freeValue.text=[[product valueForKey:@"qty_free"] stringValue];
        cell.priceValue.text=[[record valueForKey:@"price_invoiced"] stringValue];
        cell.lastValue.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yyyy" Date:[ihead valueForKey:@"invoiced_date"]];
        cell.isInvoiced = YES;
    }
    
    if(indexPath.row == [arrayOfindexpath count])
    {
    cell.btnCheck.hidden = YES;
    }
    else
    {

    if(arrayOfindexpath!=nil && [arrayOfindexpath indexOfObject:indexPath]!=NSNotFound && [arrayOfindexpath indexOfObject:indexPath]<[self.historyArray count])
        cell.btnCheck.hidden = NO;
    else
        cell.btnCheck.hidden = YES;
    }
    
    [cell.btnNext setTag:indexPath.row];
    
    if(![cell.btnNext targetForAction:@selector(doNavigateNext:) withSender:self]){
        [cell.btnNext addTarget:self action:@selector(doNavigateNext:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductHistoryTableViewCell* cell = (ProductHistoryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if(cell.btnCheck.hidden){
            [arrayOfindexpath addObject:indexPath];
        cell.btnCheck.hidden=NO;
        }
    else
    {
        [arrayOfindexpath removeObject:indexPath];
        cell.btnCheck.hidden=YES;
    }

}
-(void)doNavigateNext:(UIButton *)sender{
    ProductHistoryTableViewCell *cell = [self.historyTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    productCode=cell.productCode.text;
    [self performSegueWithIdentifier:@"toProductHistoryClicked" sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)copyDone{
    
    if (arrayOfindexpath.count>0) {
        NSDictionary* priceConfigDict;
        priceConfigDict = nil;
        NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
            priceConfigDict = [dic objectForKey:@"data"];
        
        NSString *deliveryAdd=[self.customerInfo valueForKey:@"delivery_address"];
        
        NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
        
        if ([arrDefault count]==0) {
            arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];
        }
        
        NSString *oLinePackType;
        if ([arrDefault count]>0)
            oLinePackType= [[[arrDefault lastObject] objectForKey:@"field"] lowercaseString];
        
        
        NSInteger total=0;
        
        if(self.transactionInfo){
            
            deliveryAdd=[self.transactionInfo valueForKey:@"deliveryaddressid"];//update delivery Add
            
            for (NSIndexPath *indexpath in arrayOfindexpath) {
                
                
                NSManagedObject *record = [self.historyArray objectAtIndex:indexpath.row];
                NSManagedObject * productInfo=[record valueForKey:@"product"];
                
                if ([oLinePackType length]>0)
                    total = [[productInfo valueForKey:oLinePackType] integerValue];
                
                NSString *orderType=@"O";
                double orderPrice=[[productInfo valueForKey:@"Price1"] doubleValue];
                
                BOOL insert=NO;
                NSString* LineNo=@"1";
                insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:productInfo  orderQty:[NSString stringWithFormat:@"%li",(long)total] orderPrice:orderPrice deliveryAdd:deliveryAdd deliveryDate:[NSDate date] oLineType:orderType oLinePackType:oLinePackType LineNumber:LineNo TransactionInfo:self.transactionInfo ];
                
                if(insert){
                    DebugLog(@"ProdHistory inserted");
                    if(self.transactionInfo)
                        [self changeOrderType:self.transactionInfo];
                    
                }
            }
            [kAppDelegate showCustomAlertWithModule:nil Message:[NSString stringWithFormat:@" %lu items added successfully.",(unsigned long)arrayOfindexpath.count]];
            [arrayOfindexpath removeAllObjects];
        }
        deliveryAdd=nil;
    }
    [_historyTableView reloadData];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toProductHistoryClicked"]) {
        ProductHistoryClickedViewController *productHistoryClickedVC = segue.destinationViewController;
        [productHistoryClickedVC setProductHistoryDetail:productCode];
        productHistoryClickedVC.customerInfo = self.customerInfo;
        productHistoryClickedVC.transactionInfo = self.transactionInfo;

       }
}



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    distance = scrollView.contentOffset.y;
    [self fadeInAndOut];
    if(distance<0) distance = 0;
    
}

-(void) fadeInAndOut{
    
    _txtviewtotalRecordsCount.hidden=NO;
    _txtviewtotalRecordsCount.text=[NSString stringWithFormat:@"Total: %lu",(unsigned long)[self.historyArray count]];
    // Fade out the view right away
    [UIView animateWithDuration:0.0
     
                          delay: 0.0
     
                        options: UIViewAnimationOptionCurveEaseOut
     
                     animations:^{
                         
                         _txtviewtotalRecordsCount.alpha = 0.85;
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         // Wait one second and then fade in the view
                         
                         [UIView animateWithDuration:1.0
                          
                                               delay: 1.0
                          
                                             options:UIViewAnimationOptionCurveEaseIn
                          
                                          animations:^{
                                              
                                              _txtviewtotalRecordsCount.alpha = 0.0;
                                              
                                          }
                          
                                          completion:nil];
                         
                     }];
}

@end
