//
//  CopyTransactionController.m
//  mSeller
//
//  Created by WCT iMac on 18/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CopyTransactionController.h"
#import "OrderHelper.h"
#import "CustomerController.h"

@interface CopyTransactionController ()<CustomerControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    NSManagedObject* CustObject;
    NSString* orderNo;
}

@end

@implementation CopyTransactionController
@synthesize TransactionObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // self.view.backgroundColor=[UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];

    
//    _custNameView.layer.cornerRadius=5.0;
//    _custNameView.layer.borderColor=[UIColor darkGrayColor].CGColor;
//    _custNameView.layer.borderWidth=2.0;
    
//    _custDetailView.layer.cornerRadius=5.0;
//    _custDetailView.layer.borderColor=[UIColor darkGrayColor].CGColor;
//    _custDetailView.layer.borderWidth=2.0;
    
    [OrderHelper getNewOrderNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId IsCopying:YES CompletionBlock:^(NSString * _Nullable newordernumber) {
        orderNo = newordernumber;
     //   _lblOrderNo.text=orderNo;
        CopyTransactionTableViewCell *cell = [_tblCopyTransaction cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        cell.lblValue.text=orderNo;
    }];

    CustObject=[self fetch_customer:[TransactionObj valueForKey:@"customerid"] deliverId:[TransactionObj valueForKey:@"deliveryaddressid"]];//[self fetch_customer:[TransactionObj valueForKey:@"customerid"] deliverId:@"000"];
    [self load_data:CustObject];

    
//    _tblCopyTransaction.layer.borderColor=[UIColor darkGrayColor].CGColor;
//    _tblCopyTransaction.layer.borderWidth=2.0;
//    _tblCopyTransaction.layer.cornerRadius=4.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title=NSLocalizedString(@"Copy Transaction", @"Copy Transaction");
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 138;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CopyTransactionCell";
    
        CopyTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//        if (cell == nil) {
//            cell = [[CopyTransactionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//        }
    cell.selectionStyle = NO;
    if (indexPath.section==0 && indexPath.row==0) {
        cell.lblTitle.text=@"Customer:";
        cell.lblValue.text= [CustObject valueForKey:@"name"];
        cell.lblValue.textColor=[UIColor blackColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
    }else if (indexPath.section==1 && indexPath.row==0){
        cell.lblTitle.text=@"Cust Code:";
        cell.lblValue.text= [CustObject valueForKey:@"acc_ref"];
        cell.accessoryType=UITableViewCellAccessoryNone;
    }else if (indexPath.section==1 && indexPath.row==1){
        cell.lblTitle.text=@"Order Num:";
       // cell.lblValue.text= [CustObject valueForKey:@"name"];
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    
    
//    cell.lblcustName.text= [CustObject valueForKey:@"name"];
//    cell.lblCustCode.text= [CustObject valueForKey:@"acc_ref"];
        return cell;
}


#pragma mark - TableView delegate methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0 && indexPath.row==0)
        [self performSegueWithIdentifier:@"showCustomer" sender:self];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - fetch customer obj
- (NSManagedObject* )fetch_customer :(NSString*)acc_ref deliverId:(NSString*)delId
{
    NSManagedObject*custData;
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address==%@",acc_ref,delId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([resultsSeq count]>0)
        custData = [resultsSeq lastObject];
    
    return custData;
}


-(void)load_data:(NSManagedObject*)CustObj{
  /*  _lblcustName.text=[CustObj valueForKey:@"name"];
    _lblCustCode.text=[CustObj valueForKey:@"acc_ref"];*/
    CopyTransactionTableViewCell *cell = [_tblCopyTransaction cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CopyTransactionTableViewCell *cell1 = [_tblCopyTransaction cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    if ([CustObj valueForKey:@"name"])
        cell.lblValue.text=[CustObj valueForKey:@"name"];
    if ([CustObj valueForKey:@"acc_ref"])
        cell1.lblValue.text=[CustObj valueForKey:@"acc_ref"];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.title = @"";
    if ([segue.identifier isEqualToString:@"showCustomer"]) {
        CustomerController *tranCust= segue.destinationViewController;
        [tranCust setDelegate:self];
        [tranCust setSelectedCustomerInfo:CustObject];
    }

}


- (IBAction)Done_clicked:(id)sender{
    //[self.delegate returnsCopyCust:CustObject];
    [OrderHelper getNewOrderNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId IsCopying:YES CompletionBlock:^(NSString * _Nullable newordernumber) {
        if (([CustObject valueForKey:@"acc_ref"]==[TransactionObj valueForKey:@"customerid"])|| CustObject==nil) {
            [self copy_Transaction:newordernumber transactionObject:TransactionObj CustomerChange:0 Customer:nil];
        }else
            [self copy_Transaction:newordernumber transactionObject:TransactionObj CustomerChange:1 Customer:CustObject];
    }];
}

- (IBAction)Cancel_clicked:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)select_Customer:(id)sender{
    [self performSegueWithIdentifier:@"showCustomer" sender:self];
}

#pragma mark - CustomerController Delegate
//-(void)returnsCustomer:(NSManagedObject*)returnObj{
//    CustObject=returnObj;
//    [OrderHelper getNewOrderNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId IsCopying:YES CompletionBlock:^(NSString * _Nullable newordernumber) {
//        orderNo = newordernumber;
//    }];
//
//    [self load_data:CustObject];
//}

-(void)finishedCustomerSelectionWithCustomerInfo:(NSManagedObject *)custinfo{
    CustObject=custinfo;
    [self load_data:CustObject];
}

-(void)copy_Transaction:(NSString* )orderNO transactionObject:(NSManagedObject* )copyobj CustomerChange:(NSInteger)newSts Customer:(NSManagedObject*)custObj{
    
    NSString * entityName=@"OHEADNEW";
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    
    NSMutableDictionary *cache=[NSMutableDictionary new];
    NSManagedObject *copy;
    
//    copy = cache[copyobj.objectID];

    copy = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:kAppDelegate.managedObjectContext];
    cache[copyobj.objectID] = copy;
    
    // Attributes
    NSArray *keys = [[entity attributesByName] allKeys];
    NSDictionary *attributes = [copyobj dictionaryWithValuesForKeys:keys];
    [copy setValuesForKeysWithDictionary:attributes];
    if (newSts==1) {
        [copy setValue:[custObj valueForKey:@"acc_ref"] forKey:@"customerid"];
        [copy setValue:[custObj valueForKey:@"name"] forKey:@"custname"];
//        if ([custObj valueForKey:@"curr"]) {
//            [copy setValue:[custObj valueForKey:@"curr"] forKey:@"curr"];
//        }else
//            [copy setValue:[kUserDefaults  valueForKey:@"defaultcurrency"] forKey:@"curr"];
        
        [copy setValue:[custObj valueForKey:@"delivery_address"] forKey:@"deliveryaddressid"];
        [copy setValue:[NSNumber numberWithInteger:kAppDelegate.selectedCompanyId] forKey:@"company"];//PENDING
        [copy setValue:[custObj valueForKey:@"emailaddress"] forKey:@"emailaddress"];
        
        [copy setValue:custObj forKey:@"customer"];//Add customer Obj
        
        
    }else
        [copy setValue:[copyobj valueForKey:@"customer"] forKey:@"customer"];
    
    //Change copy transaction date
    NSDate *currDate=[NSDate date];
    [copy setValue:orderNO forKey:@"orderid"];
    [copy setValue:currDate forKey:@"orderdate"];
    [copy setValue:currDate forKey:@"required_bydate"];
    [copy setValue:currDate forKey:@"start_date"];
    [copy setValue:currDate forKey:@"start_time"];
    [copy setValue:currDate forKey:@"ordtime"];
    [copy setValue:[NSNumber numberWithInteger:0] forKey:@"batch_no"];
   //**** Copy OLinenew
    
    entity = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid==%@",[copyobj valueForKey:@"orderid"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([resultsSeq count]>0){
        NSMutableArray *olinesObjects = [NSMutableArray array];
        for (NSManagedObject *mObj in resultsSeq) {
            NSManagedObject *copyOline;
            cache=[NSMutableDictionary new];
            
//            copyOline = cache[mObj.objectID];
            copyOline = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:kAppDelegate.managedObjectContext];
            cache[mObj.objectID] = copyOline;
            
            // Attributes
            NSArray *keys = [[entity attributesByName] allKeys];
            NSDictionary *attributes = [mObj dictionaryWithValuesForKeys:keys];
            [copyOline setValuesForKeysWithDictionary:attributes];
            [copyOline setValue:orderNO forKey:@"orderid"];
            [copyOline setValue:copy forKey:@"orderheadnew"];

            //Change copy transaction date
            [copyOline setValue:[NSDate date] forKey:@"expecteddate"];
            [copyOline setValue:[NSDate date] forKey:@"requireddate"];
            //********
            // code added by Satish
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            [fetchRequest setReturnsObjectsAsFaults:NO];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stock_code==%@",[copyOline valueForKey:@"productid"]];
            [fetchRequest setPredicate:predicate];

            NSArray *resultsProd = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if(!error && [resultsProd count]>0){
                [copyOline setValue:[resultsProd lastObject] forKey:@"product"];
            }
            //********
            [olinesObjects addObject:copyOline];
        }
        if([olinesObjects count]>0)
            [copy setValue:[NSSet setWithArray:olinesObjects] forKey:@"orderlinesnew"];
    }

    //Copy Signature
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }else{
        NSInteger nextordseq = [[orderNO substringFromIndex:[kAppDelegate.repId length]] integerValue]+1;
        [OrderHelper setNextOrderNumberWithRepId:kAppDelegate.repId CompanyId:kAppDelegate.selectedCompanyId NextOrderSeqquence:nextordseq];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information:"  message:[NSString stringWithFormat:@"Transaction No.(%@) copied successfully.",orderNO] delegate:self  cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [alert show];
    }
   
//    [self.delegate update_Transactiontable];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
