//
//  CustomerInvoicesViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/30/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerInvoicesViewController.h"

@interface CustomerInvoicesViewController ()<NSFetchedResultsControllerDelegate>
{
    NSManagedObject *selectedInvoice;
    NSArray *arrRows;
    double totalPriceValue;
    NSMutableArray *pickerArray;
    NSMutableArray *mainArray;
    NSInteger selIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *custInvoiceTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *customerInvoiceSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *valueHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *btnSortBy;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderNo;
@property (weak, nonatomic) IBOutlet UILabel *lblTotVal;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolBar;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerbottonConstraintLayout;
@property (weak, nonatomic) IBOutlet UILabel *lblNoRecods;


@property (nonatomic,strong) NSArray *customerInvoices;
- (IBAction)sortBy:(id)sender;
- (IBAction)pickerDoneClick:(id)sender;

@end

@implementation CustomerInvoicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _valueHeaderView.layer.cornerRadius=4.0;
    pickerArray=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Default(Date)" forKey:@"label"];
    [dict setValue:@"invoiced_date" forKey:@"Key"];
    [pickerArray addObject:dict];

    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Cust Order Ref" forKey:@"label"];
    [dict setValue:@"cust_ord_ref" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Del id" forKey:@"label"];
    [dict setValue:@"delv_add_code" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Cust Code" forKey:@"label"];
    [dict setValue:@"customer_code" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Value" forKey:@"label"];
    [dict setValue:@"invoicelines.@sum.sales_invoice_val" forKey:@"Key"];
    [pickerArray addObject:dict];
    
    [self fetchedResultsController];
    
    
    UIEdgeInsets inset = _custInvoiceTableView.separatorInset;
    inset.left = 5;
    _custInvoiceTableView.separatorInset = inset;

    if(_ProductCode){
         _pickerbottonConstraintLayout.constant=150;
        NSMutableArray *temparray = [NSMutableArray array];

        [[[[self.customerInfo valueForKeyPath:@"iheads.invoicelines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code==%@",_ProductCode]] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *oline = [[obj allObjects] lastObject];
            if(![temparray containsObject:[oline valueForKeyPath:@"invoicehead"]]){
                [temparray addObject:[oline valueForKey:@"invoicehead"]];
            }
        }];
       /* [[[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code==%@",_ProductCode]] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject *oline = [[obj allObjects] lastObject];
            if(![temparray containsObject:[oline valueForKeyPath:@"invoicehead"]]){
                [temparray addObject:[oline valueForKey:@"invoicehead"]];
            }
        }];*/

        _customerInvoices = [NSArray arrayWithArray:temparray];
    }
    else{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"invoiced_date" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        _customerInvoices = [[[self.customerInfo valueForKey:@"iheads"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
   
        _pickerbottonConstraintLayout.constant=0;
       // _customerInvoices =[_fetchedResultsController fetchedObjects];
    }
    
    
    
    
    arrRows = [NSArray arrayWithArray:_customerInvoices];
    if ([arrRows count]==0) {
        [_lblNoRecods setHidden:NO];
    }
    _searchBarTopConstraint.constant= [_customerInvoices count]>10?0:-44;
    _customerInvoiceSearchBar.hidden = [_customerInvoices count]>10?NO:YES;

    if(_customerInvoiceSearchBar.hidden){
        if([_customerInvoiceSearchBar isFirstResponder]) [_customerInvoiceSearchBar resignFirstResponder];
    }

 /*   _searchBarTopConstraint.constant= -44;
    _customerInvoiceSearchBar.hidden = YES;*/
//
//    if(_customerInvoiceSearchBar.hidden){
//        if([_customerInvoiceSearchBar isFirstResponder]) [_customerInvoiceSearchBar resignFirstResponder];
//    }
    
    
     _lblOrderNo.text=[NSString stringWithFormat:@"Tran. (%li)",(long)[arrRows count]];
    
 /*/   for (NSManagedObject *record in arrRows) {
        DebugLog(@"%i", [[_customerInvoices valueForKey:@"invoicelines"]count] );
        [[_customerInvoices valueForKey:@"invoicelines"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          //  totalPriceValue +=[[obj valueForKey:@"tot_invoiced_qty"] longValue] * [[obj valueForKey:@"price_invoiced"] floatValue];
        }];
         //totalPriceValue +=[[record valueForKey:@"invoicelines.@sum.sales_invoice_val"] doubleValue];
  ///  }*/
    
    for (NSManagedObject *record in arrRows) {
        DebugLog(@"%i", [[record valueForKey:@"invoicelines"]count] );
        [[record valueForKey:@"invoicelines"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              totalPriceValue +=[[obj valueForKey:@"tot_invoiced_qty"] longValue] * [[obj valueForKey:@"price_invoiced"] floatValue];
        }];
    }
    
    
    _lblTotVal.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value:totalPriceValue ];
    
    if ([arrRows count]==0) {
        [_headerView setHidden:YES];
    }
    
    mainArray=[[NSMutableArray alloc]initWithArray:arrRows];
    
    
    //Tap anywhere in View keyboard dismiss
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self   action:@selector(dismissKeyboard:)];
    UITapGestureRecognizer *tapOnHeaderView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    tapOnHeaderView.cancelsTouchesInView=NO;
    //[_headerView addGestureRecognizer:tap];
    //[self.parentViewController]
   // [self.navigationController.navigationBar addGestureRecognizer:tap];
    [_custInvoiceTableView addGestureRecognizer:tap];
    [_headerView addGestureRecognizer:tapOnHeaderView];

    
    _custInvoiceTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
        arrRows = [NSArray arrayWithArray:_customerInvoices];
    }
    else {
        arrRows = [_customerInvoices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(cust_ord_ref beginswith [cd] %@ || invoice_num beginswith [cd] %@)", searchText,searchText]];
    }
    [_custInvoiceTableView reloadData];
}

#pragma mark UITableView data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"CustomerInvoiceTableViewCell";
    CustomerInvoiceTableViewCell *cell=(CustomerInvoiceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];

    NSManagedObject *record = [arrRows objectAtIndex:indexPath.row];
    cell.lblTransactionRef.text=[record valueForKey:@"invoice_num"];
    cell.lblTransactionDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"invoiced_date"]];
    cell.lblTransactionValue.text=[NSString stringWithFormat:@"%@",[record valueForKey:@"invoice_val"] ];
    cell.lblCustomerRef.text=[record valueForKey:@"cust_ord_ref"];
    cell.lblDeliveryID.text=[record valueForKey:@"delv_add_code"];

    __block double invoicedVal =  0;
    [[record valueForKey:@"invoicelines"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        invoicedVal+=[[obj valueForKey:@"tot_invoiced_qty"] longValue] * [[obj valueForKey:@"price_invoiced"] floatValue];
    }];

    cell.lblTransactionValue.text = [CommonHelper getCurrencyFormatWithCurrency:[[record valueForKey:@"customer"] valueForKey:@"curr"] Value:invoicedVal];

    cell.isColorChangeRequired=_ProductCode!=nil;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedInvoice = [arrRows objectAtIndex:indexPath.row];
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
        customerDetailObj.ProductCode = _ProductCode;
        customerDetailObj.customerInfo=self.customerInfo;
        customerDetailObj.transactionInfo=self.transactionInfo;
        [customerDetailObj setHistoryItems:[[selectedInvoice valueForKey:@"invoicelines"] allObjects]];
    }
}

- (IBAction)sortBy:(id)sender{
    
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

- (IBAction)pickerDoneClick:(id)sender {
    [_pickerView setHidden:YES];
    [_pickerToolBar setHidden:YES];
    [self loadSorting:[[pickerArray objectAtIndex:selIndex] valueForKey:@"Key"]];
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
    //[self loadSorting:[[pickerArray objectAtIndex:row] valueForKey:@"Key"]];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [pickerArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[pickerArray objectAtIndex:row] valueForKey:@"label"];
}


-(void)loadSorting:(NSString*)sortType{
    [_pickerView setHidden:YES];
    [_pickerToolBar setHidden:YES];
    
    NSSortDescriptor *sortDescriptor;
    if ([sortType isEqualToString:@"invoiced_date"]) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortType   ascending:NO] ;
    }else
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortType   ascending:YES] ;
    
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [mainArray sortedArrayUsingDescriptors:sortDescriptors];
    
    arrRows=nil;
    arrRows= [NSArray arrayWithArray:sortedArray];
    [_custInvoiceTableView reloadData];
}


#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"invoiced_date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"customer_code==%@ ",[self.customerInfo valueForKey:@"acc_ref"]]];
    
   // [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"customer_code==%@ && delv_add_code==%@",[self.customerInfo valueForKey:@"acc_ref"],[self.customerInfo valueForKey:@"delivery_address"]]];
    
    // end of the code
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
     self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:kAppDelegate.managedObjectContext
                                                            sectionNameKeyPath:nil
                                                            cacheName:nil];
     self.fetchedResultsController.delegate = self;
  //  self.fetchedResultsController = fetchedResultsController;
    
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
