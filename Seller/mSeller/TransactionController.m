//
//  TransactionController.m
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionController.h"
#import "FilterViewController.h"
#import "TransactionDetailViewController.h"
#import "OrderHelper.h"
#import "CopyTransactionController.h"
#import "ProductController.h"
#import "DatePickerViewController.h"
#import "Constants.h"

@interface TransactionController ()<FilterViewControllerDelegate,DatePickerViewControllerDelegate>{
    NSString *orderNo;
    NSManagedObject *selectedRecord;
    NSMutableDictionary* selectedFilterDic;
    NSString *searchedTextString;
    NSInteger countRow;
    NSInteger selectedIndex;
    
//    NSDictionary* featureDict;
    NSDictionary* pricingConfigDict;
    double totalPriceValue;
    BOOL isViewWillAppearCalled;
    BOOL isEditing;
    BOOL  iswithoutEditFirstTime;
    //BOOL isEditButtonclick;
    NSDate *selectedFromDate;
    NSDate *selectedToDate;
}
@property (nonatomic,readwrite) NSInteger filterSts;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantSeachBarHeight;
@property(weak,nonatomic)IBOutlet UITableView *tblTransaction;
@property(weak,nonatomic)IBOutlet UIView *viewTransactionValue;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UISearchBar *transactionSearchbar;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionTotal;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonFilters;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonDaterange;

- (IBAction)show_filterClick:(id)sender;

@end

@implementation TransactionController
@synthesize filterSts;
@synthesize transactionSearchbar;

-(void)reloadConfigData{
    //  Mahendra fetch Feature config
   /* featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig
    //    companyConfigDict = nil;
    //    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    //    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
    //        companyConfigDict = [dic objectForKey:@"data"];
    //End

    //  Mahendra fetch Feature config
    featureDict = nil;
    if([[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName] objectForKey:@"data"])
        featureDict = [[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName]objectForKey:@"data"];
    //End
    //  Mahendra fetch Feature config **CALENDER ENTRY OF Transaction
    if (featureDict !=nil && ![[featureDict valueForKey:@"calendarentryoftransactionenabled"] boolValue])
        self.navigationItem.leftBarButtonItem.enabled=NO;*/
    //ENDED
    
    pricingConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        pricingConfigDict = [dic objectForKey:@"data"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Transactions", @"Transactions");
    self.navigationItem.hidesBackButton=YES;

    // to set default value for date range - added by Satish
    selectedFromDate = [kUserDefaults  valueForKey:@"fromSelectedDate"];
    selectedToDate = [kUserDefaults  valueForKey:@"toSelectedDate"];
//    if(!selectedFromDate){
//        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//        [dateComponents setWeekOfMonth:-2];
//        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
//        NSDate  *pastDate = [currentCalendar dateByAddingComponents:dateComponents toDate:[NSDate date]  options:0];
//        selectedFromDate = pastDate;
//    }
//
//    if(!selectedToDate) selectedToDate = [NSDate date];


    //Show only those recods which have data
    self.tblTransaction.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tblTransaction.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
   _viewTransactionValue.layer.borderColor=[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0].CGColor;
    _viewTransactionValue.layer.borderWidth=1.0;
    _viewTransactionValue.layer.cornerRadius=4.0;
   // _lblTransactionTotal.layer.cornerRadius=4.0;
    //Segments Filters
    selectedFilterDic =[[NSMutableDictionary alloc]initWithCapacity:2];
   
    // check for App, company and user level configuration (privileges)
      [self reloadConfigData];
//    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    selectedIndex=-1;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self   action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [_tblTransaction addGestureRecognizer:tap];
}

-(void)dismissKeyboard:(UIGestureRecognizer*)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    isEditing = NO;
    isViewWillAppearCalled = YES;
    [self navigateToTransDetailIfCurrentTransaction];
    
    [self loadUpdatedTitle];
    [self calculateTotal];
}


-(void)calculateTotal{
    totalPriceValue=0.0;
    for (NSManagedObject *object in [self.fetchedResultsController fetchedObjects]) {
       
        //Convert all change currency price in company default currency using exchangerate.csv
        double headerFinalprice=0.0;
        double headerTotPrice=[[object valueForKeyPath:@"orderlinesnew.@sum.linetotal"] doubleValue];
        
        //Add currency Symbol
        NSString *currCode=[kUserDefaults  valueForKey:@"defaultcurrency"];
        
        
        if (![[currCode lowercaseString] isEqualToString:[object valueForKey:@"curr"]]) {
            NSDictionary *exchangeRateDict=[CommonHelper getExcangeRateArray:[object valueForKey:@"curr"]];
        
            if (exchangeRateDict) {
                headerFinalprice=headerTotPrice*[[exchangeRateDict valueForKey:@"exchangerate"] doubleValue];
            }else
                headerFinalprice=headerTotPrice;
        }else
            headerFinalprice=headerTotPrice;
        
        
        totalPriceValue = totalPriceValue +headerFinalprice;
        //[[[object valueForKey:@"orderlinesnew"] valueForKeyPath:@"@sum.linetotal"] doubleValue];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        _lblTransactionTotal.text=[CommonHelper getCurrencyFormatWithCurrency:nil Value: [[NSString stringWithFormat:@"%0.2f",totalPriceValue] doubleValue]];
    });
    [_tblTransaction selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.fetchedResultsController = nil;
    [self fetchedResultsController];
    [self filter_Transaction];

    
    if(!isViewWillAppearCalled)
        [self navigateToTransDetailIfCurrentTransaction];

    isViewWillAppearCalled = NO;

    self.constantSeachBarHeight.constant=[[self.fetchedResultsController fetchedObjects] count]>10?44:0;
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    [kUserDefaults  removeObjectForKey:@"fromSelectedDate" ];
    [kUserDefaults  removeObjectForKey:@"toSelectedDate"];
    [kUserDefaults synchronize];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
-(void)loadUpdatedTitle{
    self.navigationItem.title= [NSString stringWithFormat:@"Transactions (%lu)",[[self.fetchedResultsController fetchedObjects] count]];// NSLocalizedString(@"Transactions", @"Transactions");
}

-(void)navigateToTransDetailIfCurrentTransaction{
    if(kAppDelegate.transactionInfo){//redirect Detail screen if there is any current transaction
        isEditing = [kUserDefaults boolForKey:@"isEditing"];
        iswithoutEditFirstTime=YES;
//        if (!isEditButtonclick) {
//            isEditButtonclick=NO;
//        }
      
        orderNo=[kAppDelegate.transactionInfo valueForKey:@"orderid"];
        selectedRecord=kAppDelegate.transactionInfo;
        [self performSegueWithIdentifier:@"toTransactionDetail" sender:self];
    }else{
        
        [kUserDefaults removeObjectForKey:@"isEditing"];
        [kUserDefaults synchronize];
 
    }
}

-(void)filter_Transaction{
    NSPredicate *predicate = nil;

    NSMutableArray *andPredicatesArray = [NSMutableArray array];
    
    if (!searchedTextString || [searchedTextString length] == 0) {
    }else {
        [andPredicatesArray addObject:[NSPredicate predicateWithFormat:@"orderid CONTAINS %@",searchedTextString]];
    }
    
    if(selectedFromDate){
        [andPredicatesArray addObject:[NSPredicate predicateWithFormat:@"orderdate >= %@",selectedFromDate]];
    }
    if(selectedToDate){
        [andPredicatesArray addObject:[NSPredicate predicateWithFormat:@"orderdate <= %@",selectedToDate]];
    }

    NSMutableArray *orPredicatesTypeArray = [NSMutableArray array];
    if ([selectedFilterDic objectForKey:@"Type"]) {

        for (NSDictionary *dict in [selectedFilterDic objectForKey:@"Type"]) {

            if ([[dict valueForKey:@"status"] integerValue]==1) {
                [orPredicatesTypeArray addObject:[NSPredicate predicateWithFormat:@"ordtype == %@",[dict valueForKey:@"code"]]];
            }else if ([[dict valueForKey:@"status"] integerValue]==2){
                [andPredicatesArray addObject:[NSPredicate predicateWithFormat:@"ordtype != %@",[dict valueForKey:@"code"]]];
            }
        }
    }

    NSMutableArray *orPredicatesStatusArray = [NSMutableArray array];

    if ([selectedFilterDic objectForKey:@"Status"]) {
        for (NSDictionary *dict in [selectedFilterDic objectForKey:@"Status"]) {
            if(![[[dict valueForKey:@"label"] lowercaseString] isEqualToString:@"all"]){
                if ([[dict valueForKey:@"status"] integerValue]==1) {
                    
                    if([[[dict valueForKey:@"label"] lowercaseString] isEqualToString:@"held"]){
                       [orPredicatesStatusArray addObject:[NSPredicate predicateWithFormat:@"held_status == 'Y'"]];
                    }else
                    [orPredicatesStatusArray addObject:[NSPredicate predicateWithFormat:@"order_status==[c]%@",[[dict valueForKey:@"label"] lowercaseString]]];
                
                
                
                }else if ([[dict valueForKey:@"status"] integerValue]==2){
                   
                    if([[[dict valueForKey:@"label"] lowercaseString] isEqualToString:@"held"]){
                        [orPredicatesStatusArray addObject:[NSPredicate predicateWithFormat:@"held_status == 'N'"]];
                    }else
                    [andPredicatesArray addObject:[NSPredicate predicateWithFormat:@"order_status!=[c]%@",[[dict valueForKey:@"label"] lowercaseString]]];
                }
            }
        }
    }


    if([orPredicatesTypeArray count]>0){
        NSCompoundPredicate *compPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:orPredicatesTypeArray];
        [andPredicatesArray addObject:compPredicate];
    }

    if([orPredicatesStatusArray count]>0){
        NSCompoundPredicate *compPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:orPredicatesStatusArray];
        [andPredicatesArray addObject:compPredicate];
    }

    if([andPredicatesArray count]>0)
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:andPredicatesArray];

    [[_fetchedResultsController fetchRequest] setPredicate:predicate];

    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [[self tblTransaction] reloadData];
    [self loadUpdatedTitle];
    [self calculateTotal];
}

- (void) TableCell_EditClicked{
    isEditing = YES;
    //isEditButtonclick=YES;
   // [self performSegueWithIdentifier:@"toTransactionDetail" sender:self];
    
    
    [kUserDefaults setBool:YES forKey:@"isEditing"];  //removeObjectForKey:@"isEditing"];
    [kUserDefaults synchronize];
    
    
    kAppDelegate.isEditTransaction =YES;
    kAppDelegate.customerInfo = [selectedRecord valueForKey:@"customer"];
    kAppDelegate.transactionInfo = selectedRecord;
    
    UINavigationController * navController = (UINavigationController *) [[self.tabBarController viewControllers] objectAtIndex: 1] ;
    [navController popToRootViewControllerAnimated:NO];
    self.tabBarController.selectedIndex=1;
}

- (void) TableCell_DeleteClicked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Transaction"  message:@"Do you want to delete this transaction?"   delegate:self  cancelButtonTitle:@"Yes"  otherButtonTitles:@"No",nil];
    [alert setDelegate:self];
    [alert setTag:3];
    [alert show];
}


- (void) TableCell_CopyClicked{
    [self load_copyCustomer];
}

-(void)load_copyCustomer{
    [self performSegueWithIdentifier:@"toCopyTransaction" sender:self];
}

- (IBAction)show_filterClick:(id)sender {
    filterSts=[sender tag];
    [self performSegueWithIdentifier:@"toFilterView" sender:self];
}



#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    countRow=[sectionInfo numberOfObjects];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TransactionTableViewCell";
    TransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 ==0) {
        cell.backgroundColor=tblOddColor;
    }else
        cell.backgroundColor=tblEvenColor;
}


#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex=indexPath.row;
    isEditing = NO;
    iswithoutEditFirstTime=NO;
    
    [kUserDefaults removeObjectForKey:@"isEditing"];
    [kUserDefaults synchronize];
    
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    orderNo=[record valueForKey:@"orderid"];
    selectedRecord=record;//For transaction detail
    [self performSegueWithIdentifier:@"toTransactionDetail" sender:self];
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return YES;
}
//*******       Table View Editing style
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    selectedRecord=[self.fetchedResultsController objectAtIndexPath:indexPath];//For transaction delete/Copy/Edit

    NSMutableArray *arrBtns = [NSMutableArray array];

    if(selectedRecord && [[selectedRecord valueForKey:@"batch_no"] integerValue]==0){
        UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                        {
                                            DebugLog(@"Action to perform with Button 1");

                                            [self TableCell_DeleteClicked];
                                        }];
        button.backgroundColor = [UIColor redColor]; //arbitrary color
        [arrBtns addObject:button];


        UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                         {
                                             DebugLog(@"Action to perform with Button2!");
                                             [self TableCell_EditClicked];
                                         }];
        button2.backgroundColor = [UIColor blackColor]; //arbitrary color
        [arrBtns addObject:button2];
    }
    
    UITableViewRowAction *button3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Copy" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         DebugLog(@"Action to perform with Button3!");
                                         [self TableCell_CopyClicked];
                                     }];
    button3.backgroundColor = [UIColor colorWithRed:51.0/255.0       green:153.0/255.0       blue:255.0/255.0       alpha:1.0]; //arbitrary color
    [arrBtns addObject:button3];
    return [NSArray arrayWithArray:arrBtns]; //array with all the buttons you want. 1,2,3, etc...
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([alertView tag]==3 && buttonIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Transaction"  message:@"Are you sure want to delete this transaction?"   delegate:self  cancelButtonTitle:@"Yes"  otherButtonTitles:@"No",nil];
        [alert setDelegate:self];
        [alert setTag:4];
        [alert show];
        
    }
    else if ([alertView tag]==4 && buttonIndex == 0)
    {
        //Delete Transaction
        [kAppDelegate.managedObjectContext deleteObject:selectedRecord];
        NSError *error = nil;
        if (![kAppDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
        
        [self loadUpdatedTitle];
        [self calculateTotal];//Calculate new total values.
        if([[self.fetchedResultsController fetchedObjects] count]==0){
            // refresh product controler if open
            //            UITabBarController *tabC = (UITabBarController *)[self.navigationController parentViewController];
            //            UINavigationController *prodNav = [tabC.viewControllers objectAtIndex:1];
            //            [prodNav popToRootViewControllerAnimated:NO];
            
            [kNSNotificationCenter postNotificationName:kRefreshTabItems object:nil];
        }
    }
}


#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Edit the entity name as appropriate.
    NSString * entityName=@"OHEADNEW";
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
//    [fetchRequest setReturnsObjectsAsFaults:NO];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderdate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
        // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:kAppDelegate.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self loadUpdatedTitle];
    return _fetchedResultsController;
}


#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tblTransaction beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tblTransaction endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tblTransaction;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            [self.tblTransaction insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tblTransaction deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)configureCell:(TransactionTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.hidden = NO;
    cell.contentView.hidden  =NO;
   // DebugLog(@"Order Date %@",[record valueForKey:@"order_date"]);
    cell.lblCustomerRefrence.text=[record valueForKey:@"customerid"];
    cell.lblTransactionRefrence.text=[record valueForKey:@"orderid"];
    cell.lblDelivaryDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"required_bydate"]];
    cell.lblOrderDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"orderdate"]];
    cell.lblOrderType.text=[record valueForKey:@"ordtype"];
    cell.lblCustomerName.text=[record valueForKey:@"custname"];
    
    //Add currency Symbol
    NSString *currCode=[record valueForKey:@"Curr"];
    cell.lblCustomerCode.text=[[record valueForKey:@"customer"] valueForKey:@"acc_ref"];
    //OlineInformation
    cell.lblitemQuantity.text=[NSString stringWithFormat:@"%lu",(long)[[record valueForKey:@"orderlinesnew"] count]];
    cell.lblTransactionValue.text=[CommonHelper getCurrencyFormatWithCurrency:currCode Value:[[NSString stringWithFormat:@"%0.2f",[[[record valueForKey:@"orderlinesnew"] valueForKeyPath:@"@sum.linetotal"] doubleValue]] doubleValue]];
    
    if([[[record valueForKey:@"held_status"] lowercaseString] hasPrefix:@"y"])
        [cell.imgTransactionStatus  setImage:[UIImage imageNamed:@"held"]];
    else if([[[record valueForKey:@"order_status"] lowercaseString] hasPrefix:@"sent"])
        [cell.imgTransactionStatus  setImage:[UIImage imageNamed:@"sent"]];
    else if([[record valueForKey:@"batch_no"] integerValue]!=0)
        [cell.imgTransactionStatus  setImage:[UIImage imageNamed:@"pending"]];
    else
        [cell.imgTransactionStatus  setImage:[UIImage imageNamed:@"unsent"]];

    //Change fornt color bases on order type
    NSArray *colorArr= [[[pricingConfigDict objectForKey:@"orderconfigs"] objectForKey:@"transactiontypes"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.code==%@",[record valueForKey:@"ordtype"]]];
    if ([colorArr count]>0) {
         dispatch_async(dispatch_get_main_queue(), ^{
        [cell changeFontColor:[CommonHelper colorwithHexString:[[colorArr lastObject] valueForKey:@"colorcode"] alpha:1.0]];
             });
    }else
         [cell changeFontColor:[UIColor blackColor]];
   
}


#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchedTextString = searchText;
    [self filter_Transaction];
   
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
   [searchBar resignFirstResponder];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    self.navigationItem.title = @"";
    if ([segue.identifier isEqualToString:@"toFilterView"]) {
        FilterViewController *filterObj = segue.destinationViewController;
        [filterObj setDelegate:self];
        [filterObj setReturnDictionary:selectedFilterDic];
    
        
    }else if ([segue.identifier isEqualToString:@"toTransactionDetail"] || [segue.identifier isEqualToString:@"toTransactionDetailwithoutAnimation"]) {
        TransactionDetailViewController *tranObj = segue.destinationViewController;
        [tranObj setOrderNumber:orderNo];
        [tranObj setOheadCount:countRow];
        tranObj.Headrecorddata=selectedRecord;
        tranObj.isEditing=isEditing;
        tranObj.isFirstTimeTransaction=iswithoutEditFirstTime;
//        if (isEditButtonclick) {//Changes according to iPad
//            self.tabBarController.selectedIndex=1;
//        }
        
        [self performSelector:@selector(setViewAppearFlagToFalse) withObject:nil afterDelay:1.0];
        
    }else if ([segue.identifier isEqualToString:@"toCopyTransaction"]) {
        CopyTransactionController* copyTran = segue.destinationViewController;
        [copyTran setTransactionObj:selectedRecord];
    }
    else if([segue.identifier isEqualToString:@"toDatePickerViewController"]){
        DatePickerViewController *datePickerViewController = segue.destinationViewController;
        datePickerViewController.title=@"Date Range";
        datePickerViewController.isDateRange=YES;
        datePickerViewController.selectedDate = selectedFromDate;
        datePickerViewController.selectedToDate = selectedToDate;
        datePickerViewController.clearSelectionEnabled=YES;
        datePickerViewController.delegate = self;
    }

}

-(void)setViewAppearFlagToFalse{
    isViewWillAppearCalled = NO;
}

#pragma mark - TransactionFilter Delegate
-(void)finishedTransactionFilterSelectionWithOption:(NSDictionary*)selDictionary{
    selectedFilterDic=(NSMutableDictionary* )selDictionary;
    
    
    //Check for filter Status
    [_barButtonFilters setImage:[UIImage imageNamed:@"filter"]];//setTintColor: btnTitleBlueColor];
    BOOL filterSelSts=NO;
    //Checking in Array
    NSArray *filterArr=[[selDictionary valueForKey:@"Type"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status =1 || status =2"]];
    if ([filterArr count]==0) {
        filterArr=[[selDictionary valueForKey:@"Status"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status =1 || status =2"]];
    }
    
    if ([filterArr count]>0)
        filterSelSts=YES;
    
    if (filterSelSts)
    {
        [_barButtonFilters setImage:[UIImage imageNamed:@"filterSelected"]];//setTintColor: [UIColor greenColor]];
    }
    //Ended
    
    
    [self filter_Transaction];
}

#pragma mark - DatePickerViewControllerDelegate
-(void)finishedSelectionWithFromDate:(NSDate *)fromdate ToDate:(NSDate *)todate{
   
    selectedFromDate = fromdate;
    selectedToDate = todate;

    if (selectedFromDate !=nil && selectedToDate !=nil ) {
        [_barButtonDaterange setTintColor:[UIColor redColor]];
        [kUserDefaults  setValue:fromdate forKey:@"fromSelectedDate"];
        [kUserDefaults  setValue:todate forKey:@"toSelectedDate"];
    }else  {
        [_barButtonDaterange setTintColor:btnTitleBlueColor];
        [kUserDefaults  removeObjectForKey:@"fromSelectedDate" ];
        [kUserDefaults  removeObjectForKey:@"toSelectedDate"];
       
    }
    
     [kUserDefaults  synchronize];
//    [self filter_Transaction];
}

@end
