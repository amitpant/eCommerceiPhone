//
//  CustomerOutstandingViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerOutstandingViewController.h"
#import "Constants.h"

@interface CustomerOutstandingViewController ()<NSFetchedResultsControllerDelegate>
{
    NSManagedObject *selectedOrder;
    NSArray *arrRows;
    double totalPriceValue;
    NSMutableArray *mainArray;
    NSMutableArray *pickerArray;
    NSInteger selIndex;
}
@property (weak, nonatomic)  IBOutlet UITableView *custOutstandingTableView;
@property (weak, nonatomic)  IBOutlet UISearchBar *customerOutstandingSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *valueHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *btnSortBy;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderNo;
@property (weak, nonatomic) IBOutlet UILabel *lblTotVal;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolBar;
@property (nonatomic,strong) NSArray *customerOrders;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerbottonConstraintLayout;
@property (weak, nonatomic) IBOutlet UILabel *lblNoRecods;

- (IBAction)pickerDoneClick:(id)sender;
- (IBAction)sortBy:(id)sender;
@end

@implementation CustomerOutstandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _valueHeaderView.layer.cornerRadius=4.0;
    
    pickerArray=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Default(Date)" forKey:@"label"];
    [dict setValue:@"delivery_date" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Cust Order Ref" forKey:@"label"];
    [dict setValue:@"cust_order_ref" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Del id" forKey:@"label"];
    [dict setValue:@"del_add_code" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Cust Code" forKey:@"label"];
    [dict setValue:@"customer_code" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Value" forKey:@"label"];
    [dict setValue:@"sales_ord_val_outst" forKey:@"Key"];
    [pickerArray addObject:dict];

    
    UIEdgeInsets inset = _custOutstandingTableView.separatorInset;
    inset.left = 5;
    _custOutstandingTableView.separatorInset = inset;

 //   [self fetchedResultsController];
    
    
    
    
    if(_ProductCode){
        _pickerbottonConstraintLayout.constant=150;
        NSMutableArray *temparray = [NSMutableArray array];

        [[[[self.customerInfo valueForKeyPath:@"oheads.orderlines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code==%@",_ProductCode]] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *oline = [[obj allObjects] lastObject];
            if(![temparray containsObject:[oline valueForKeyPath:@"orderhead"]]){
                [temparray addObject:[oline valueForKey:@"orderhead"]];
            }
            
        }];
       /* [[[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code==%@",_ProductCode]] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *oline = [[obj allObjects] lastObject];
            if(![temparray containsObject:[oline valueForKeyPath:@"invoicehead"]]){
                [temparray addObject:[oline valueForKey:@"invoicehead"]];
            }
        }];*/
        _customerOrders = [NSArray arrayWithArray:temparray];
    }
    else{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_date" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        _customerOrders = [[[self.customerInfo valueForKey:@"oheads"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        
        
       // _customerOrders =[_fetchedResultsController fetchedObjects];
        _pickerbottonConstraintLayout.constant=0;
    }
    
    arrRows = [NSArray arrayWithArray:_customerOrders];

    if ([arrRows count]==0) {
        [_lblNoRecods setHidden:NO];
    }
    
    _searchBarTopConstraint.constant= [_customerOrders count]>10?0:-44;
    _customerOutstandingSearchBar.hidden = [_customerOrders count]>10?NO:YES;

    if(_customerOutstandingSearchBar.hidden){
        if([_customerOutstandingSearchBar isFirstResponder]) [_customerOutstandingSearchBar resignFirstResponder];
    }

//    _searchBarTopConstraint.constant= -44;
//    _customerOutstandingSearchBar.hidden = YES;
//
//    if(_customerOutstandingSearchBar.hidden){
//        if([_customerOutstandingSearchBar isFirstResponder]) [_customerOutstandingSearchBar resignFirstResponder];
//    }
    
    _lblOrderNo.text=[NSString stringWithFormat:@"Order (%li)",(long)[arrRows count]];
    /*for (NSManagedObject *record in arrRows) {
       
        [[record valueForKey:@"orderlines"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            totalPriceValue +=[[obj valueForKey:@"outst_ord_qty"] longValue] * [[obj valueForKey:@"price_ordered"] floatValue];
        }];*/
        
    
    
  //  totalPriceValue = totalPriceValue +[[object valueForKeyPath:@"orderlines.@sum.(%f*%f)",[[object valueForKey:@"outst_ord_qty"] longValue],[[object valueForKey:@"price_ordered"] float]] doubleValue];
    DebugLog(@"_customerOrders %@",_customerOrders);
   
        
      //  [[obj valueForKey:@"outst_ord_qty"] longValue] * [[obj valueForKey:@"price_ordered"]
                                                          
  /*  }
   _lblTotVal.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:totalPriceValue ];
    */
    
    if ([arrRows count]==0) {
        [_headerView setHidden:YES];
    }
    mainArray=[[NSMutableArray alloc]initWithArray:arrRows];
   
    
    [self performSelector:@selector(totalValue) withObject:nil afterDelay:0.0];
    
    
    //Tap anywhere in View keyboard dismiss
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self   action:@selector(dismissKeyboard:)];
    UITapGestureRecognizer *tapOnHeaderView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    tapOnHeaderView.cancelsTouchesInView=NO;
   /* [_headerView addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap];*/
    [_custOutstandingTableView addGestureRecognizer:tap];
    [_custOutstandingTableView addGestureRecognizer:tapOnHeaderView];
    
     _custOutstandingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}



-(void)totalValue{
    
    double totalVal=0;
    @try {
        
        /* NSFetchRequest *request = [[NSFetchRequest alloc] init];
         NSEntityDescription *entity = [NSEntityDescription entityForName:@"OLINES" inManagedObjectContext:kAppDelegate.managedObjectContext];
         [request setEntity:entity];
         // Return dictionary
         [request setResultType:NSDictionaryResultType];
         // Set conditions
         [request setPredicate:[NSPredicate predicateWithFormat:@"order_number in %@ ",[_customerOrders valueForKey:@"order_number"]]];
         //Expration
         NSExpression *fromCurrencyPathExpression = [NSExpression expressionForKeyPath:@"price_ordered"];
         NSExpression *toCurrencyPathExpression   = [NSExpression  expressionForKeyPath:@"outst_ord_qty"];
         NSExpression *multiplyExpression = [NSExpression expressionForFunction:@"multiply:by:" arguments:@[fromCurrencyPathExpression, toCurrencyPathExpression]];
         NSString *expressionName = @"salesVal";
         NSExpressionDescription *expressionDescription =[[NSExpressionDescription alloc] init];
         expressionDescription.name = expressionName;
         expressionDescription.expression = multiplyExpression;
         expressionDescription.expressionResultType= NSDoubleAttributeType;
         
         // Add expressions to fetch
         [request setPropertiesToFetch:[NSArray arrayWithObjects: expressionDescription, nil]];
         // Execute fech
         NSError *error;
         NSArray *result = [kAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
         // DebugLog(@"result %@",result);
         [result  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         
         if ([[obj valueForKey:@"salesVal"] longValue]>0) {
         DebugLog(@"salesVal 123 %@    ",[obj valueForKey:@"salesVal"]);
         }
         
         }];*/
        
        __block double salesordValOutst =  0;
        [arrRows  enumerateObjectsUsingBlock:^(id  _Nonnull objHead, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [[objHead valueForKey:@"orderlines"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                salesordValOutst+=[[obj valueForKey:@"outst_ord_qty"] longValue] * [[obj valueForKey:@"price_ordered"] floatValue];
            }];


        }];
        
       
        
        totalVal=salesordValOutst;//[result valueForKeyPath:@"@sum.salesVal"];//@"@sum.sales_ord_val_outst"];//@"@sum.orderlines.@sum.salesVal"
        
    } @catch (NSException *exception) {
        DebugLog(@"%@",exception);
    } @finally {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _lblTotVal.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:totalVal];
    });
    
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadScrollEnable];
   
}
#pragma mark search bar delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        arrRows = [NSArray arrayWithArray:_customerOrders];
    }
    else {
        arrRows = [_customerOrders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(order_number beginswith [cd] %@ || cust_order_ref beginswith [cd] %@)", searchText,searchText]];
    }
    [_custOutstandingTableView reloadData];
    
    _lblOrderNo.text=[NSString stringWithFormat:@"Order (%li)",(long)[arrRows count]];
}


#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"CustomerOutstandingTableViewCell";
    CustomerOutstandingTableViewCell *cell=(CustomerOutstandingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    NSManagedObject *record = [arrRows objectAtIndex:indexPath.row];
    cell.lblTransactionRef.text=[record valueForKey:@"order_number"];
    cell.lblTransactionDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"order_date"]];
    cell.lblDeliveryDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"delivery_date"]];
    cell.lblCustomerRef.text=[record valueForKey:@"cust_order_ref"];
    cell.lblDeliveryID.text=[record valueForKey:@"del_add_code"];

    __block double salesordValOutst =  0;
    [[record valueForKey:@"orderlines"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        salesordValOutst+=[[obj valueForKey:@"outst_ord_qty"] longValue] * [[obj valueForKey:@"price_ordered"] floatValue];
        
//        if ([[obj valueForKey:@"outst_ord_qty"] longValue] * [[obj valueForKey:@"price_ordered"] floatValue]>0) {
//            DebugLog(@"EE 123 %@    %f",[obj valueForKey:@"order_number"],[[obj valueForKey:@"outst_ord_qty"] longValue] * [[obj valueForKey:@"price_ordered"] floatValue]);
//        }
        
    }];
    if (salesordValOutst>0) {
        DebugLog(@"EE %f",salesordValOutst);
    }
    cell.lblTransactionValue.text = [CommonHelper getCurrencyFormatWithCurrency:[[record valueForKey:@"customer"] valueForKey:@"curr"] Value:salesordValOutst];
    cell.isColorChangeRequired=_ProductCode!=nil;
    return cell;
}

#pragma mark - UITableView Delegate
/*-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    viewHeader.backgroundColor = tblHeaderRed;
    UIButton *btnSortBy= [UIButton buttonWithType:UIButtonTypeCustom];
    btnSortBy.frame = CGRectMake(5, 0, 60, 40);
    [btnSortBy.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [btnSortBy setTitle:@"Sort By" forState:UIControlStateNormal];
    [btnSortBy addTarget:self action:@selector(SortBy:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnSortBy];

    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 100, 40)];
    lbl.textColor=[UIColor whiteColor];
    lbl.font=[UIFont systemFontOfSize:15.0];
    [viewHeader addSubview:lbl];
    
    
    UILabel *lbl1=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 100, 30)];
    lbl1.textColor=[UIColor lightGrayColor];
    lbl1.font=[UIFont systemFontOfSize:15.0];
    [viewHeader addSubview:lbl1];
    
    UILabel *lbl2=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 80, 30)];
    lbl2.textColor=[UIColor blackColor];
    lbl2.backgroundColor=[UIColor whiteColor];
    lbl2.font=[UIFont systemFontOfSize:15.0];
    [viewHeader addSubview:lbl2];
    
    
    //    _btnCustomer = [UIButton buttonWithType:UIButtonTypeSystem];
//    _btnCustomer.frame = CGRectMake(5, 0, viewHeader.frame.size.width-10, 40);
//    [_btnCustomer.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
//    [_btnCustomer setTitle:@"[SELECT CUSTOMER]" forState:UIControlStateNormal];
//    [_btnCustomer addTarget:self action:@selector(doSelectCustomer:) forControlEvents:UIControlEventTouchUpInside];
//    [viewHeader addSubview:_btnCustomer];
//    
    
    return viewHeader;
}*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedOrder=[arrRows objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toCustomerDetailInvoiceOutstandingViewController" sender:self];
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
    if ([segue.identifier isEqualToString:@"toCustomerDetailInvoiceOutstandingViewController"]) {
        CustomerDetailInvoiceOutstandingViewController *customerDetailObj = segue.destinationViewController;
        [customerDetailObj setHistoryItems:[[selectedOrder valueForKey:@"orderlines"] allObjects]];
        customerDetailObj.ProductCode = _ProductCode;
        customerDetailObj.customerInfo=self.customerInfo;
        customerDetailObj.transactionInfo=self.transactionInfo;
        customerDetailObj.isFromOutstandingScreen=YES;
    }
}





- (IBAction)sortBy:(id)sender {
    if ([_pickerView isHidden]) {
        if(_ProductCode)
            _pickerbottonConstraintLayout.constant=150;
        
        [_pickerView setHidden:NO];
        [_pickerToolBar setHidden:NO];
        [_pickerView reloadAllComponents];
        [_pickerView selectRow:selIndex inComponent:0 animated:YES];
    }else{
        [_pickerView setHidden:YES];
        [_pickerToolBar setHidden:YES];
    }
}

#pragma mark -
#pragma mark picker view methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selIndex=row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [pickerArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[pickerArray objectAtIndex:row] valueForKey:@"label"];
}

- (IBAction)pickerDoneClick:(id)sender {
    [self loadSorting:[[pickerArray objectAtIndex:selIndex] valueForKey:@"Key"]];
}

-(void)loadSorting:(NSString*)sortType{
    [_pickerView setHidden:YES];
    [_pickerToolBar setHidden:YES];
    
    NSArray *sortedArray;
    /*if ([sortType isEqualToString:@"sales_ord_val_outst"]) {
       // "invoicelines.@sum.sales_invoice_val
        sortedArray  = [mainArray sortedArrayUsingComparator:^(NSManagedObject *obj1, NSManagedObject *obj2) {
           
            if (([[obj1 valueForKey:@"outst_ord_qty"] longValue]*[[obj1 valueForKey:@"price_ordered"] doubleValue]) < ([[obj2 valueForKey:@"outst_ord_qty"] longValue]*[[obj2 valueForKey:@"price_ordered"] doubleValue])) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
            return NSOrderedDescending;
            
        }];

    }else{*/
    
    
    NSSortDescriptor *sortDescriptor;
    if ([sortType isEqualToString:@"delivery_date"]) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortType   ascending:NO] ;
    }else
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortType   ascending:YES] ;
    

    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedArray = [mainArray sortedArrayUsingDescriptors:sortDescriptors];
   // }
    arrRows=nil;
    arrRows= [NSArray arrayWithArray:sortedArray];
    [_custOutstandingTableView reloadData];
}




#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"customer_code" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"customer_code==%@",[self.customerInfo valueForKey:@"acc_ref"]]];
  //  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"customer_code==%@ && del_add_code==%@",[self.customerInfo valueForKey:@"acc_ref"],[self.customerInfo valueForKey:@"delivery_address"]]];
    
    // end of the code
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:kAppDelegate.managedObjectContext
                                                            sectionNameKeyPath:nil
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

-(void)dismissKeyboard:(UIGestureRecognizer*)tapGestureRecognizer {
    [[self view] endEditing:TRUE];
}

@end
