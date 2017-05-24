//
//  CustomerDeliveryAddressViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerDeliveryAddressViewController.h"

@interface CustomerDeliveryAddressViewController ()<CustomerNewDeliveryAddressDelegate>
{
    NSMutableArray *custDel_AddressArray;
    MultipleDeliveryIDSelection *multipleDeliveryIdSelection;
    NSString *strDeliveryID_ADD;
    NSDictionary *companyConfigDict;
    NSDictionary *featureDict;
    BOOL customerEdit;
    NSInteger editIndex;
}
@property(nonatomic,weak)IBOutlet UITableView *custDeliveryAddressTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnNewDelivery;
@property (weak, nonatomic) IBOutlet UILabel *lblNoRecords;
@end

@implementation CustomerDeliveryAddressViewController

-(void)reloadConfigData{
    companyConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];

    featureDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];

    _btnNewDelivery.enabled = NO;
    if (featureDict !=nil && [[featureDict valueForKey:@"addnewdeliveryaddressenabled"] boolValue]){//Add new Delivery Address button enable by Webconfig
        _btnNewDelivery.enabled = YES;
    }
   
    [self fetchAnEntity];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _btnNewDelivery.layer.cornerRadius = _btnNewDelivery.frame.size.width/2;
    _btnNewDelivery.layer.masksToBounds = YES;
    
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];

    // Do any additional setup after loading the view.
    if (!self.isFromProduct)
    {
       // self.navigationItem.rightBarButtonItems = self.navigationItem.leftBarButtonItems;
        self.navigationItem.leftBarButtonItems = nil;
    }else  if ( _isFromCustomer){
        self.navigationItem.rightBarButtonItems =nil;
    }

    if (self.isFromCustomer){
        self.navigationItem.rightBarButtonItems =nil;
    }

    self.title=@"Delivery Address";
    self.navigationItem.leftItemsSupplementBackButton=YES;
  
    //manual maintain swipe B/W pageviewcontroller and tableswipe.
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightRecognizer];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for (UIView *view in self.parentViewController.view.subviews ) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            scroll.scrollEnabled = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_custDeliveryAddressTableView reloadData];
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //do you left swipe stuff here.
    DebugLog(@"rightSwipe");
    [self loadLeft];
}

-(void)fetchAnEntity{
    self.myArrayOfManagedObjects=[[NSMutableArray alloc] init];
    self.myObjectOfManagedObjects=[[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"delivery_address" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSString *filterDeliveryAddress = [NSString stringWithFormat:@"acc_ref == '%@'",[self.customerInfo valueForKey:@"acc_ref"]];

    // remove main account address to use as first delivery address
    if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"usemainaccountasdeliveryaddresss"] boolValue]){
        filterDeliveryAddress = [filterDeliveryAddress stringByAppendingFormat:@" && delivery_address!='000'"];
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterDeliveryAddress];
    
    [fetchRequest setPredicate:predicate];
    // end of the code
    
    NSError *error = nil;
    NSArray *array = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil)
    {
        // handle error
        abort(); // TEMP
    }
    
    if(!error && [array count]>0){
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.myArrayOfManagedObjects addObject:obj];//actual array
            multipleDeliveryIdSelection=[[MultipleDeliveryIDSelection alloc]initWithDeliveryValuesSign:0];
            [self.myObjectOfManagedObjects addObject:multipleDeliveryIdSelection];//array with delivery 0 default
        }];
        
    }
    
    
    if ([self.myArrayOfManagedObjects count]==0) {
        [_lblNoRecords setHidden:NO];
    }else{
        [_lblNoRecords setHidden:YES];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.myArrayOfManagedObjects count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"CustomerDeliveryAddressTableViewCell";
    CustomerDeliveryAddressTableViewCell *cell=(CustomerDeliveryAddressTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    NSManagedObject *record = [self.myArrayOfManagedObjects objectAtIndex:indexPath.row];
   // if (self.isFromTransaction)
    if ([[record valueForKey:@"delivery_address"] isEqualToString:_selectedDeliveryAddress])
        [[self.myObjectOfManagedObjects objectAtIndex:indexPath.row ]setDeliveryIDSign:1];
    if ([[self.myObjectOfManagedObjects objectAtIndex:indexPath.row]deliveryIDSign]==1) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    
    
    cell.lblDeliveryAddress.text=[record valueForKey:@"delivery_address"];
    cell.lblCustomerTown.text=[record valueForKey:@"addr5"];
    cell.lblCustomerPostCode.text=[record valueForKey:@"postcode"];
    
    NSString *strAddress = [record valueForKey:@"addr1"];
    if([record valueForKey:@"addr2"] && [[record valueForKey:@"addr2"] length]>0){
        if([strAddress length]>0)
            strAddress = [strAddress stringByAppendingFormat:@", %@",[record valueForKey:@"addr2"]];
        else
            strAddress = [record valueForKey:@"addr2"];
    }
    if([record valueForKey:@"addr3"] && [[record valueForKey:@"addr3"] length]>0){
        if([strAddress length]>0)
            strAddress = [strAddress stringByAppendingFormat:@", %@",[record valueForKey:@"addr3"]];
        else
            strAddress = [record valueForKey:@"addr3"];
    }
    if([record valueForKey:@"addr4"] && [[record valueForKey:@"addr4"] length]>0){
        if([strAddress length]>0)
            strAddress = [strAddress stringByAppendingFormat:@", %@",[record valueForKey:@"addr4"]];
        else
            strAddress = [record valueForKey:@"addr4"];
    }
    cell.lblAddress.text = strAddress;
    [cell.lblAddress sizeToFit];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedCustomerDelivery = [self.myArrayOfManagedObjects objectAtIndex:indexPath.row];
    if (self.isFromProduct){
    
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        NSManagedObject *record = [self.myArrayOfManagedObjects objectAtIndex:indexPath.row];
        [arr addObject:[record valueForKey:@"delivery_address"]];
        
        if ([self.delegate respondsToSelector:@selector(finishedDeliveryDoneSelection:)])
            [self.delegate finishedDeliveryDoneSelection:arr];
        [self.navigationController popViewControllerAnimated:YES];
        
        
        
    }else if (self.isFromProduct || self.isFromTransaction) {
        if (!self.isFromProduct)
            [self clearAllCheck];

        if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone) {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [[self.myObjectOfManagedObjects objectAtIndex:indexPath.row ]setDeliveryIDSign:1];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
            [[self.myObjectOfManagedObjects objectAtIndex:indexPath.row ]setDeliveryIDSign:0];
        }
        
    }
    else
    {
        /*/Change edit status if it associate with order
        [self.selectedCustomerDelivery setValue:[NSNumber numberWithBool:NO] forKey:@"iseditdeliveryaddress"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![kAppDelegate.managedObjectContext save:&error]) {
            DebugLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        //END*/
        
        if (![[self.selectedCustomerDelivery valueForKey:@"delivery_address"] isEqualToString:@"000"]) {
            
            if([self.customerInfo valueForKey:@"name"])
            [self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"name"]  forKey:@"name"];
            
            if([self.customerInfo valueForKey:@"cust_shortname"])
            [self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"cust_shortname"]  forKey:@"cust_shortname"];
            
            if([self.customerInfo valueForKey:@"curr"])
            [self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"curr"]  forKey:@"curr"];
           
            if([self.customerInfo valueForKey:@"cusgroup"])
            [self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"cusgroup"]  forKey:@"cusgroup"];
            /*[self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"curr"]  forKey:@"curr"];
            [self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"curr"]  forKey:@"curr"];
            [self.selectedCustomerDelivery setValue:[self.customerInfo valueForKey:@"curr"]  forKey:@"curr"];*/
        }
        
        
        
        if([self.transdelegate respondsToSelector:@selector(createTransactionWithCustomerInfo:)]){
            [self.transdelegate createTransactionWithCustomerInfo:self.selectedCustomerDelivery];
        }
    }
}

//Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *customerInfo=[self.myArrayOfManagedObjects objectAtIndex:indexPath.row];
    if ([[customerInfo valueForKey:@"isaddedondevice"]boolValue] && [[customerInfo valueForKey:@"batch_no"] integerValue]==0 && ![[customerInfo valueForKey:@"delivery_address"] isEqualToString:@"000"] && [self check_oHead:customerInfo]){//Edit delivery info if this is a new delivery add in this ipad and not associated with any order
        return YES;
    }else
       return NO;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    editIndex=indexPath.row;
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableCellEditClicked];
    }];
    button.backgroundColor = [UIColor blackColor];
    
    //If need delete button
    /*UITableViewRowAction *button1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableCellEditClicked];
    }];
    button1.backgroundColor = [UIColor redColor];
    return  @[button1,button];*/
    
    return @[button];  //array with all the buttons you want. 1,2,3, etc...
    
}

- (void) tableCellEditClicked{

    DebugLog(@"Edit click");
    customerEdit=YES;
    [self performSegueWithIdentifier:@"toCustomerNewDeliveryAddress" sender:self];
}

-(void)clearAllCheck
{
    for (int i=0; i<self.myArrayOfManagedObjects.count; i++) {
    for(NSIndexPath *indxpath in [_custDeliveryAddressTableView indexPathsForVisibleRows]){
        [[_custDeliveryAddressTableView cellForRowAtIndexPath:indxpath] setAccessoryType:UITableViewCellAccessoryNone];
    }
        [[self.myObjectOfManagedObjects objectAtIndex:i ]setDeliveryIDSign:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(IBAction)addDeliveryAddress:(id)sender{
//    [self performSegueWithIdentifier:@"toCustomerNewDeliveryAddress" sender:self];
//}

-(IBAction)btnAddDeliveryAddress_DoneClick:(UIBarButtonItem*)sender{
    if (sender.tag==0) {

    }
    else
    {
        custDel_AddressArray=[[NSMutableArray alloc]init];
        for (int i=0; i<self.myObjectOfManagedObjects.count; i++) {
            if ([[self.myObjectOfManagedObjects objectAtIndex:i]deliveryIDSign]==1)
            {
                
                NSManagedObject *record = [self.myArrayOfManagedObjects objectAtIndex:i];
                if (!self.isFromTransaction)
                    [custDel_AddressArray addObject:[record valueForKey:@"delivery_address"]];
                else
                {
                    
                    NSString *strAddress = [record valueForKey:@"addr1"];
                    if([record valueForKey:@"addr2"] && [[record valueForKey:@"addr2"] length]>0){
                        if([strAddress length]>0)
                            strAddress = [strAddress stringByAppendingFormat:@", %@",[record valueForKey:@"addr2"]];
                        else
                            strAddress = [record valueForKey:@"addr2"];
                    }
                    if([record valueForKey:@"addr3"] && [[record valueForKey:@"addr3"] length]>0){
                        if([strAddress length]>0)
                            strAddress = [strAddress stringByAppendingFormat:@", %@",[record valueForKey:@"addr3"]];
                        else
                            strAddress = [record valueForKey:@"addr3"];
                    }
                    if([record valueForKey:@"addr4"] && [[record valueForKey:@"addr4"] length]>0){
                        if([strAddress length]>0)
                            strAddress = [strAddress stringByAppendingFormat:@", %@",[record valueForKey:@"addr4"]];
                        else
                            strAddress = [record valueForKey:@"addr4"];
                    }
                    
                    strDeliveryID_ADD=[NSString stringWithFormat:@"%@_%@",[record valueForKey:@"delivery_address"],strAddress];
                    
                    [custDel_AddressArray addObject:strDeliveryID_ADD];
                }
            }
        }
        if ([self.delegate respondsToSelector:@selector(finishedDeliveryDoneSelection:)])
            [self.delegate finishedDeliveryDoneSelection:custDel_AddressArray];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)addNewDeliveryAddress:(UIButton *)sender {
    customerEdit=NO;
    [self performSegueWithIdentifier:@"toCustomerNewDeliveryAddress" sender:self];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([segue.identifier isEqualToString:@"toCustomerNewDeliveryAddress"]) {
        CustomerNewDeliveryAddressViewController *customerNewDelivery = segue.destinationViewController;
        customerNewDelivery.delegate=self;
        [customerNewDelivery setCustomerInfo:self.customerInfo];
        if (customerEdit) {
            customerNewDelivery.editStatus=YES;
             NSManagedObject *customer=[self.myArrayOfManagedObjects objectAtIndex:editIndex];
            [customerNewDelivery setCustomerDelivery:customer];
        }else
            customerNewDelivery.editStatus=NO;
       //customerNewDelivery.editStatus=customerEdit;
    }
}

-(void)finishNewDeliverySaveDone{
    [self fetchAnEntity];
    [self.custDeliveryAddressTableView reloadData];
}
-(BOOL)check_oHead:(NSManagedObject*)customer{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerid==%@ && deliveryaddressid==%@",[customer valueForKey:@"acc_ref"],[customer valueForKey:@"delivery_address"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([resultsSeq count]==0) {
        return YES;
    }else
        return NO;
    
}

@end
