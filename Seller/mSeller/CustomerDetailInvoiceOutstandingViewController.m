//
//  CustomerDetailInvoiceOutstandingViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 11/9/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerDetailInvoiceOutstandingViewController.h"
#import "OrderHelper.h"
@interface CustomerDetailInvoiceOutstandingViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    NSString *stractualpath;
    NSArray *arrRows;
    NSMutableArray *pickerArray;
    NSMutableArray *mainArray;
    NSInteger selIndex;
    NSMutableArray *arrayOfindexpath;
}
@property (weak, nonatomic) IBOutlet UITableView *invoice_outstanding_detail_Tableview;
@property (weak, nonatomic) IBOutlet UISearchBar *customerDetailSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lblNoRecords;

- (IBAction)sortBy:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolBar;
@end

@implementation CustomerDetailInvoiceOutstandingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    pickerArray=[[NSMutableArray alloc]init];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Default" forKey:@"label"];
    if(_isFromOutstandingScreen)
        [dict setValue:@"line_no" forKey:@"Key"];
    else
    [dict setValue:@"invoice_num" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Prod Code" forKey:@"label"];
    [dict setValue:@"product_code" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Description" forKey:@"label"];
    [dict setValue:@"product.gdescription" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Quantity" forKey:@"label"];
    if(_isFromOutstandingScreen)
    [dict setValue:@"outst_ord_qty" forKey:@"Key"];
    else
        [dict setValue:@"tot_invoiced_qty" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Price" forKey:@"label"];
    if(_isFromOutstandingScreen)
       [dict setValue:@"price_ordered" forKey:@"Key"];
    else
    [dict setValue:@"price_invoiced" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Value" forKey:@"label"];
    if(_isFromOutstandingScreen)
        [dict setValue:@"Test" forKey:@"Key"];
    else
        [dict setValue:@"sales_invoice_val" forKey:@"Key"];
        
    [pickerArray addObject:dict];
    
    
    UIEdgeInsets inset = _invoice_outstanding_detail_Tableview.separatorInset;
    inset.left = 5;
    _invoice_outstanding_detail_Tableview.separatorInset = inset;

    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];

    if(_ProductCode){
        _historyItems = [NSArray arrayWithArray:[_historyItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"product_code==%@",_ProductCode]]];
        
    }

    arrRows =  [NSArray arrayWithArray:_historyItems];

    _searchBarTopConstraint.constant= [_historyItems count]>10?0:-44;
    _customerDetailSearchBar.hidden = [_historyItems count]>10?NO:YES;

    if(_customerDetailSearchBar.hidden){
        if([_customerDetailSearchBar isFirstResponder]) [_customerDetailSearchBar resignFirstResponder];
    }

    self.navigationItem.title = [NSString stringWithFormat:@"Items (%li)",(long)[arrRows count]];
    
    mainArray=[[NSMutableArray alloc]initWithArray:arrRows];
    arrayOfindexpath=[[NSMutableArray alloc] init];

    if ([mainArray count]==0) {
        [_lblNoRecords setHidden:NO];
    }else
         [_lblNoRecords setHidden:YES];
    
    
    _invoice_outstanding_detail_Tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([arrRows count]>2)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Sort By" style:UIBarButtonItemStylePlain target:self action:@selector(sortBy:)];
     else
        self.navigationItem.rightBarButtonItem=nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrRows count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CustomerDetailInvoiceOutstandingTableViewCell";
    CustomerDetailInvoiceOutstandingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    NSManagedObject *record = [arrRows objectAtIndex:indexPath.row];
    cell.productCode.text=[record valueForKey:@"product_code"];

    if([record valueForKey:@"product"])
        cell.productDescription.text=[[record valueForKey:@"product"] valueForKey:@"gdescription"];

    if(_isFromOutstandingScreen){
        NSUInteger totoutstdqty = [[record valueForKey:@"outst_ord_qty"] longValue]; //[[record valueForKey:@"tot_ord_qty"] longValue]-
        cell.productQuantity.text=[NSString stringWithFormat:@"%li",(unsigned long)totoutstdqty];

        NSString *strcurr = [[record valueForKeyPath:@"orderhead.customer"] valueForKey:@"curr"];
        cell.productPrice.text = [CommonHelper getCurrencyFormatWithCurrency:strcurr Value:[[record valueForKey:@"price_ordered"] doubleValue]];
        cell.productValue.text = [CommonHelper getCurrencyFormatWithCurrency:strcurr Value:[[record valueForKey:@"price_ordered"] doubleValue] * totoutstdqty];
    }
    else{
        cell.productQuantity.text=[NSString stringWithFormat:@"%@",[record valueForKey:@"tot_invoiced_qty"] ];
        NSString *strcurr = [[record valueForKeyPath:@"invoicehead.customer"] valueForKey:@"curr"];
        cell.productPrice.text = [CommonHelper getCurrencyFormatWithCurrency:strcurr Value:[[record valueForKey:@"price_invoiced"] doubleValue]];
        cell.productValue.text=[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:[[record valueForKey:@"sales_invoice_val"] doubleValue]];
    }

    cell.isColorChangeRequired=_ProductCode!=nil;
    cell.isInvoiced = !_isFromOutstandingScreen;

    NSString *strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[record valueForKey:@"product_code"]] lowercaseString]] stringByAppendingString:@".jpg"];
    [cell.productImage setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
   
    if(indexPath.row == [arrayOfindexpath count])
    {
        cell.btnCheck.hidden = YES;
    }
    else
    {
        
        if(arrayOfindexpath!=nil && [arrayOfindexpath indexOfObject:indexPath]!=NSNotFound && [arrayOfindexpath indexOfObject:indexPath]<[arrRows count])
            cell.btnCheck.hidden = NO;
        else
            cell.btnCheck.hidden = YES;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    CustomerDetailInvoiceOutstandingTableViewCell* cell = (CustomerDetailInvoiceOutstandingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.btnCheck.hidden){
        [arrayOfindexpath addObject:indexPath];
        cell.btnCheck.hidden=NO;
    }
    else
    {
        [arrayOfindexpath removeObject:indexPath];
        cell.btnCheck.hidden=YES;
    }
    
    if (arrayOfindexpath.count>0)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(doCopy:)];
    else if([arrRows count]>2)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Sort By" style:UIBarButtonItemStylePlain target:self action:@selector(sortBy:)];
    else
        self.navigationItem.rightBarButtonItem=nil;
        

}
#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    if ([searchText length] == 0) {
        arrRows = [NSArray arrayWithArray:_historyItems];
    }
    else{
        arrRows = [_historyItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"product.gdescription contains[cd] %@ || product_code beginswith[cd] %@",searchText, searchText]];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"Items (%li)",(long)[arrRows count]];
    [[self invoice_outstanding_detail_Tableview] reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    [searchBar resignFirstResponder];
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


- (IBAction)sortBy:(id)sender {
    if ([_pickerView isHidden]) {
        [_pickerView setHidden:NO];
        [_pickerToolBar setHidden:NO];
        
        [_pickerView reloadAllComponents];
        [_pickerView selectRow:selIndex inComponent:0 animated:YES];
    }else{
        
        [_pickerView setHidden:YES];
        [_pickerToolBar setHidden:YES];
    }
}



-(IBAction)doCopy:(id)sender{
    
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

                NSManagedObject *record = [arrRows objectAtIndex:indexpath.row];
                NSManagedObject * productInfo=[record valueForKey:@"product"];
                
                if ([oLinePackType length]>0)
                    total = [[productInfo valueForKey:oLinePackType] integerValue];
                
                NSString *orderType=@"O";
                double orderPrice=[[productInfo valueForKey:@"Price1"] doubleValue];
                
                BOOL insert=NO;
                NSString* LineNo=@"1";
                insert= [OrderHelper addOLinewithorderNumber:[self.transactionInfo valueForKey:@"orderid"] productInfo:productInfo  orderQty:[NSString stringWithFormat:@"%li",(long)total] orderPrice:orderPrice deliveryAdd:deliveryAdd deliveryDate:[NSDate date] oLineType:orderType oLinePackType:oLinePackType LineNumber:LineNo TransactionInfo:self.transactionInfo ];
                
                if(insert){
                    DebugLog(@"Customer detail inserted");
                    if(self.transactionInfo)
                        [self changeOrderType:self.transactionInfo];
                    
                }
            }
            [kAppDelegate showCustomAlertWithModule:nil Message:[NSString stringWithFormat:@" %lu items added successfully.",(unsigned long)arrayOfindexpath.count]];
            [arrayOfindexpath removeAllObjects];
        }
    }
    [_invoice_outstanding_detail_Tableview reloadData];
    if (arrayOfindexpath.count>0)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(doCopy:)];
    else if([arrRows count]>2)
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Sort By" style:UIBarButtonItemStylePlain target:self action:@selector(sortBy:)];
    else
        self.navigationItem.rightBarButtonItem=nil;
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
    }/*else if ( [[transactionObj valueForKey:@"orderlinesnew"] count]==0){
        
         [transactionObj setValue:@"C" forKey:@"ordtype"];
         NSError *error = nil;
         if (![kAppDelegate.managedObjectContext save:&error]) {
         NSLog(@"Failed to save - error: %@", [error localizedDescription]);
         }
         
         [kNSNotificationCenter postNotificationName:kOrderTypechange  object:self];
    }*/
}

-(void)loadSorting:(NSString*)sortType{
    [_pickerView setHidden:YES];
    [_pickerToolBar setHidden:YES];
    NSArray *sortedArray;
    if ([sortType isEqualToString:@"Test"]) {
        
        sortedArray  = [mainArray sortedArrayUsingComparator:^(NSManagedObject *obj1, NSManagedObject *obj2) {
            
//            if (([[obj1 valueForKey:@"outst_ord_qty"] longValue]*[[obj1 valueForKey:@"price_ordered"] doubleValue]) > ([[obj2 valueForKey:@"outst_ord_qty"] longValue]*[[obj2 valueForKey:@"price_ordered"] doubleValue])) {
//                return NSOrderedDescending;
//            }
            if (([[obj1 valueForKey:@"outst_ord_qty"] longValue]*[[obj1 valueForKey:@"price_ordered"] doubleValue]) < ([[obj2 valueForKey:@"outst_ord_qty"] longValue]*[[obj2 valueForKey:@"price_ordered"] doubleValue])) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
           // return NSOrderedSame;
            
            
//            if ((obj1.boolProp && obj2.boolProp) || (!obj1.boolProp && !obj2.boolProp)) {
//                // Both bools are either YES or both are NO so sort by the string property
//                return [obj1.stringProp compare:obj2.stringProp];
//            } else if (obj1.boolProp) {
//                // first is YES, second is NO
//                return NSOrderedAscending;
//            } else {
//                // second is YES, first is NO
//                return NSOrderedDescending;
            
        }];
        

            
//        NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outst_ord_qty" ascending:NO comparator:^(id obj1, id obj2) {
//            
//            if (([[obj1 valueForKey:@"outst_ord_qty"] longValue]*[[obj1 valueForKey:@"price_ordered"] doubleValue]) > ([[obj2 valueForKey:@"outst_ord_qty"] longValue]*[[obj2 valueForKey:@"price_ordered"] doubleValue])) {
//                return (NSComparisonResult)NSOrderedDescending;
//            }
//            if (([[obj1 valueForKey:@"outst_ord_qty"] longValue]*[[obj1 valueForKey:@"price_ordered"] doubleValue]) < ([[obj2 valueForKey:@"outst_ord_qty"] longValue]*[[obj2 valueForKey:@"price_ordered"] doubleValue])) {
//                return (NSComparisonResult)NSOrderedAscending;
//            }
//            return (NSComparisonResult)NSOrderedSame;
//        }];
//        sortedArray = [mainArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
//
        
    }else{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortType   ascending:YES] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedArray = [mainArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    
    
    arrRows=nil;
    arrRows= [NSArray arrayWithArray:sortedArray];
    [_invoice_outstanding_detail_Tableview reloadData];
}

@end
