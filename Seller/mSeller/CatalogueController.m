//
//  CatalogueController.m
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CatalogueController.h"

@interface CatalogueController ()<UIScrollViewDelegate>
{
    NSString *CurrentScreenTitle;
    NSDictionary* companyConfigDict;//   fetch CompanyConfig

    // temporary variable to maintain last state of option
    NSString *sortCategoryBy;
    NSString *stractualpath;
    CGFloat distance;
    BOOL isScrollBeginDragging;
    BOOL isViewLoaded;
}

@property(nonatomic,weak)IBOutlet UISegmentedControl *segmentControl;
@property(nonatomic,weak)IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,assign)BOOL isPromotions;
@property(nonatomic,assign)BOOL isSubCategory;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
- (IBAction)dismissKeyboard:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnOverlay;

@end

@implementation CatalogueController

- (void)viewDidLoad {
    [super viewDidLoad];
    isViewLoaded = YES;

    _isSubCategory=(_selectedGroup1!=nil);

    UIEdgeInsets inset = _mainTableView.separatorInset;
    inset.left = 10;
    _mainTableView.separatorInset = inset;

    if ([kUserDefaults  integerForKey:@"NumericKeyboard"]==2) {
        _searchBar1.keyboardType=UIKeyboardTypeNumberPad;
    }else
        _searchBar1.keyboardType=UIKeyboardTypeDefault;
        
 
    //When companySwitch Notification Called
    [kNSNotificationCenter addObserver:self  selector:@selector(refreshCompanydata:) name:kCompanySwitch object:nil];
    
}


-(void)numericKeyboardOn{
    _searchBar1.keyboardType=UIKeyboardTypeNumberPad;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    if([kUserDefaults  integerForKey:@"NumericKeyboard"]==2) {
        [self numericKeyboardOn];
    }else
        _searchBar1.keyboardType=UIKeyboardTypeDefault;
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];

    if(isViewLoaded){
        [self segmentBtnPressed:self.segmentControl];
        isViewLoaded = NO;
    }

    if(kAppDelegate.colorPool || [kAppDelegate.colorPool count]>0){
        [kAppDelegate.colorPool removeAllObjects];
        kAppDelegate.colorPool = nil;
        [kAppDelegate.colorPoolGroup removeAllObjects];
        kAppDelegate.colorPoolGroup = nil;
    }

    if (!_isSubCategory){
        self.navigationItem.title=@"Catalogues";
    }
    else{
        if(CurrentScreenTitle) self.navigationItem.title = CurrentScreenTitle;
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([kUserDefaults  integerForKey:@"NumericKeyboard"]==2) {
        [self numericKeyboardOn];
    }else
        _searchBar1.keyboardType=UIKeyboardTypeDefault;
    
    
    if([kUserDefaults  integerForKey:@"CatalogeScrolling"]==2) {
        [_mainTableView setScrollEnabled:YES];
    }else
        [_mainTableView setScrollEnabled:NO];
    
    
    if(self.navigationController.navigationBarHidden)
        self.navigationController.navigationBarHidden = NO;
    
    //Edit transaction
    if (kAppDelegate.isEditTransaction){
        [self loadEditProduct];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [kNSNotificationCenter removeObserver:self name:kRefreshConfigData object:nil];
    [super viewWillDisappear:animated];
    [_searchBar1 resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
-(void)reloadConfigData{
    //  Mahendra fetch Feature config
//    featureDict = nil;
//    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
//    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
//        featureDict = [dic objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    // code added by Satish on 12-11-2015

    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];

    _fetchedResultsController = nil;

    // code to validate App config option for product family tags
    [self performSelector:@selector(refreshStatusForPromotionalGroups) withObject:nil afterDelay:0.001];

    if(companyConfigDict && [companyConfigDict objectForKey:@"generalconfig"]){
        NSString *sortCode=@"A";
        
       if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey :@"sortcategoriesby"] isEqual:[NSNull null]])
        sortCode =[[companyConfigDict objectForKey:@"generalconfig"] objectForKey :@"sortcategoriesby"];
        
        if(![sortCode isEqualToString:sortCategoryBy]){
            sortCategoryBy = sortCode;
            [[_fetchedResultsController fetchRequest] setSortDescriptors:[self getSortDescriptors]];
        }
    }

    [self searchBar:_searchBar1 textDidChange:_searchBar1.text];
}

-(NSArray *)getSortDescriptors{
    NSSortDescriptor *sortDescriptor;
    //  Mahendra fetch CompanyConfig **SORT DESCRIPTER sortcategoriesby
    NSString *sortCode=@"A";
    if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortcategoriesby"] isEqual:[NSNull null]])
        sortCode =[[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortcategoriesby"];

    if ([sortCode length]>0 && [sortCode isEqualToString:@"A"])
    {
        sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"gdescription" ascending:YES];
    }
    else if([sortCode length]>0 && [sortCode isEqualToString:@"C"])
    {
        if (_isPromotions)
            sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"gdescription" ascending:YES];
        else if (_isSubCategory)
            sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"group2code" ascending:YES];
        else
            sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"group1code" ascending:YES];
    }
    else
    {
        sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"group_seq" ascending:YES];
    }

    NSArray *sortDescriptors = @[sortDescriptor];
    return sortDescriptors;
}

-(void)refreshStatusForPromotionalGroups{
    NSDictionary *featureDict = [[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName]objectForKey:@"data"];
    if(featureDict){
        if([[featureDict objectForKey:@"productfamilitagsenabled"] boolValue]){
            _segmentControl.hidden = NO;
            _segmentTopConstraint.constant=6;
        }
        else{
            _segmentControl.hidden = YES;
            _segmentTopConstraint.constant=-34;
            return;
        }
    }

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EXTRAGROUPCODES" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];

    NSAttributeDescription* extragrpcode = [entity.attributesByName objectForKey:@"extragroupcode"];
    //NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:statusname, nil];

    NSMutableArray *arrFetchList = [NSMutableArray arrayWithObject:extragrpcode];
    [fetch setPropertiesToFetch:arrFetchList];

    NSError *err = nil;
    NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetch error:&err];
    if([results count]<=0){
        _segmentControl.hidden = YES;
        _segmentTopConstraint.constant=-34;
    }
    else{
        _segmentControl.hidden = NO;
        _segmentTopConstraint.constant=6;
    }
}

-(NSString *)getDefaultPredicateString{
    if (!_isPromotions && _isSubCategory){
        return [NSString stringWithFormat:@"group1.group1code== '%@'",[_selectedGroup1 valueForKey:@"group1code"]];
    }
    return @"";
}

-(NSString *)getCategoryImageNameWithCategory:(NSString *) category CategoryCode:(NSString *)catcode{
    NSString *strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:category] lowercaseString]] stringByAppendingString:@".jpg"];

    if([[NSFileManager defaultManager] fileExistsAtPath:strfinalimage])
        return strfinalimage;


    strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:catcode] lowercaseString]] stringByAppendingString:@".jpg"];

    if([[NSFileManager defaultManager] fileExistsAtPath:strfinalimage])
        return strfinalimage;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchLimit:1];


    NSString *sortByFieldName = nil;
    if(companyConfigDict){
        NSString *sortCode = @"A";
        if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortproductsby"] isEqual:[NSNull null]])
            sortCode = [[companyConfigDict objectForKey:@"generalconfig" ]valueForKey :@"sortproductsby"];
        
        if ([sortCode length]>0 && [sortCode isEqualToString:@"A"])
        {
            sortByFieldName=@"gdescription";
        }
        else if([sortCode length]>0 && [sortCode isEqualToString:@"C"])
        {
            sortByFieldName=@"stock_code";

        }
        else
        {
            sortByFieldName=@"itemsequence,stock_code";
        }
    }
    else
        sortByFieldName=@"itemsequence,stock_code";

    if(sortByFieldName){
        NSMutableArray *arrSort = [NSMutableArray array];
        [[sortByFieldName componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc] initWithKey:obj ascending:YES];
            [arrSort addObject:sortDescriptor];
        }];

        [fetchRequest setSortDescriptors:arrSort];
    }
    
    // Edit the sort key as appropriate.

    NSPredicate *predicate = nil;
    if (_isPromotions){
        predicate = [NSPredicate predicateWithFormat:@"isimageavailable==1 && (extracode1==%@ || extracode2==%@ || extracode3==%@)",catcode,catcode,catcode];
    }
    else{
        if (_isSubCategory)
            predicate = [NSPredicate predicateWithFormat:@"isimageavailable==1 && grp2== %@",catcode];
        else
            predicate = [NSPredicate predicateWithFormat:@"isimageavailable==1 && category== %@",catcode];
    }
    [fetchRequest setPredicate:predicate];

    NSError *err = nil;
    NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    if(!err && [results count]>0)
    {
        strfinalimage = [stractualpath stringByAppendingPathComponent:
                         [[[CommonHelper getStringByRemovingSpecialChars:[[results lastObject] valueForKey:@"stock_code"]] lowercaseString] stringByAppendingString:@".jpg"]];

        if([[NSFileManager defaultManager] fileExistsAtPath:strfinalimage])
            return strfinalimage;
    }
    return nil;
}

#pragma mark - Control generated events
- (IBAction)showAllProducts:(id)sender {
    [self performSegueWithIdentifier:@"toProductScreen" sender:sender];
}

-(IBAction)segmentBtnPressed:(UISegmentedControl*)sender{
    if(sender.selectedSegmentIndex==0){
        _isPromotions = NO;
        _isSubCategory=(_selectedGroup1!=nil);
    }
    else{
        _isPromotions = YES;
    }
    self.fetchedResultsController=nil;
    [self.mainTableView reloadData];

//    switch(self.segmentControl.selectedSegmentIndex){
//        case 0:{
//            self.isPromotions=NO;
//            self.fetchedResultsController=nil;
//            [self.mainTableView reloadData];
//        }
//            break;
//        case 1:{
//            self.isPromotions=YES;
//            self.fetchedResultsController=nil;
//            [self.mainTableView reloadData];
//        }
//            break;
//        default:
//            break;
//    }
}

#pragma mark search bar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [_btnOverlay setHidden:NO];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_btnOverlay setHidden:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]<=0) {
        [_btnOverlay setHidden:NO];
    }else
        [_btnOverlay setHidden:YES];
    
    NSString *strPredicates = [self getDefaultPredicateString];

    NSPredicate *predicate=nil;

    if ([searchText length] > 0){
        if (!_isPromotions && _isSubCategory)
        {
            strPredicates = [strPredicates stringByAppendingFormat:@" && gdescription contains[cd] '%@'", searchText];
        }
        else{
            if([strPredicates length]>0)
                strPredicates = [strPredicates stringByAppendingFormat:@" && gdescription contains[cd] '%@'", searchText];
            else
                strPredicates = [strPredicates stringByAppendingFormat:@"gdescription contains[cd] '%@'", searchText];
        }
    }
    if([strPredicates length]>0)
        predicate = [NSPredicate predicateWithFormat:strPredicates];

    [[_fetchedResultsController fetchRequest] setPredicate:predicate];

    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [[self mainTableView] reloadData];
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSString *entityName;

    if (_isSubCategory)
    {
        if (self.isPromotions)
            entityName=@"EXTRAGROUPCODES";
        else
            entityName=@"GROUP2CODES";
    }
    else
    {
        if (self.isPromotions)
            entityName=@"EXTRAGROUPCODES";
        else
            entityName=@"GROUP1CODES";
    }

    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.

    [fetchRequest setSortDescriptors:[self getSortDescriptors]];

    NSString *strpred = [self getDefaultPredicateString];
    if([strpred length]>0)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:strpred]];

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
        DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    _searchBarTopConstraint.constant= [[self.fetchedResultsController fetchedObjects] count]>10?0:-44;
    _searchBar1.hidden = [[self.fetchedResultsController fetchedObjects] count]>10?NO:YES;

    if(_searchBar1.hidden){
        if([_searchBar1 isFirstResponder]) [_searchBar1 resignFirstResponder];
    }

    return _fetchedResultsController;
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.mainTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.mainTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.mainTableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            [self.mainTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.mainTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)configureCell:(CategoryGroupTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *groupInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.lblCategoryName.text=[groupInfo valueForKey:@"gdescription"];
    cell.hidden = NO;
    NSString *strimgname = nil;
    if(_isPromotions)
    {
        strimgname = [self getCategoryImageNameWithCategory:[groupInfo valueForKey:@"gdescription"] CategoryCode:[groupInfo valueForKey:@"extragroupcode"]];
    }
    else{

        if (_isSubCategory){
            strimgname = [self getCategoryImageNameWithCategory:[groupInfo valueForKey:@"gdescription"] CategoryCode:[groupInfo valueForKey:@"group2code"]];
        }
        else{
            strimgname = [self getCategoryImageNameWithCategory:[groupInfo valueForKey:@"gdescription"] CategoryCode:[groupInfo valueForKey:@"group1code"]];
        }
    }
    cell.lblCategoryItemQuantity.text=[NSString stringWithFormat:@"%lu",[[groupInfo valueForKey:@"products"] count]];
    [cell.imgViewCategoryGroup setImageWithURL:strimgname?[NSURL fileURLWithPath:strimgname]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"CategoryGroupTableViewCell";
    CategoryGroupTableViewCell *cell=(CategoryGroupTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView Delegates
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBar1 resignFirstResponder];

    NSInteger categoryLevels = 1;
    if(companyConfigDict && [companyConfigDict objectForKey:@"generalconfig"]){
        categoryLevels =[[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"categorylevels"] integerValue];
    }

    if (_isSubCategory || categoryLevels<=1)
        [self performSegueWithIdentifier:@"toProductScreen" sender:tableView];
    else
    {
        if (self.isPromotions){
            [self performSegueWithIdentifier:@"toProductScreen" sender:tableView];
           // kAppDelegate.ftSelExgroup=[record valueForKey:@"extragroupcode"];
        }else
        {
            CatalogueController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"toCatalogue"];
            
            NSInteger iCounter = 0;
            controller.selectedGroup1Array=[[NSMutableArray alloc]init];
            for(NSManagedObject *record in [self.fetchedResultsController fetchedObjects]){
                if(![controller.selectedGroup1Array containsObject:[record valueForKeyPath:@"group1code"]]){
                    NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:[record valueForKey:@"group1code"] forKey:@"identifier"];
                    [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                    if (iCounter==indexPath.row) {
                        [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                    }else
                        [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                    [controller.selectedGroup1Array addObject:dicinfo];
                    
                }
                iCounter++;
            
            }
            self.navigationItem.title=@"";
            
            NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
            controller.title=[[record valueForKey:@"gdescription"] stringByAppendingFormat:@" (%li)",(long)[[record valueForKey:@"group2"] count]];
            controller.selectedGroup1 = record;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toProductScreen"]) {
        NSMutableArray *arrGroup1 = [NSMutableArray array];
        NSMutableArray *arrGroup2 = [NSMutableArray array];
        NSMutableArray *arrPromotions = [NSMutableArray array];

        if (_isSubCategory){
            arrGroup1=_selectedGroup1Array;
        }
        
        
        for(NSManagedObject *record in [self.fetchedResultsController fetchedObjects]){
            if(_isPromotions){
                NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:[record valueForKey:@"extragroupcode"] forKey:@"identifier"];
                [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                [arrPromotions addObject: dicinfo];
                //[arrPromotions addObject:[record valueForKey:@"extragroupcode"]];
            }else{
                if (_isSubCategory){
                    
                    NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:[record valueForKey:@"group2code"] forKey:@"identifier"];
                    [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                    [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                    [arrGroup2 addObject:dicinfo];
                }else{
                    if(![sender isKindOfClass:[UIBarButtonItem class]]){
                        NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                        [dicinfo setObject:[record valueForKey:@"group1code"] forKey:@"identifier"];
                        [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                        [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                        [arrGroup1 addObject:dicinfo];
                    }
                }
            }
        }
   
        NSString *nextScreenTitle = @"";

        NSInteger iCounter = 1;
        for(NSIndexPath *ipath in [self.mainTableView indexPathsForSelectedRows]){
            NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:ipath];
            if(_isPromotions){
               
                NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:[record valueForKey:@"extragroupcode"] forKey:@"identifier"];
                [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                [arrPromotions replaceObjectAtIndex:ipath.row withObject:dicinfo];
              //  [arrPromotions addObject:[record valueForKey:@"extragroupcode"]];
            }else{
                if (_isSubCategory){
                   // if(![arrGroup1 containsObject:[record valueForKeyPath:@"group1.group1code"]])
                     //   [arrGroup1 addObject:[record valueForKeyPath:@"group1.group1code"]];

                    if(![sender isKindOfClass:[UIBarButtonItem class]]){ // add group2 for filter only if all product option not checked
                        
                        NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                        [dicinfo setObject:[record valueForKey:@"group2code"] forKey:@"identifier"];
                        [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                        [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                        [arrGroup2 replaceObjectAtIndex:ipath.row withObject:dicinfo];//[record valueForKey:@"group2code"]];
                        
                        
                    }
                }
                else{
                    if(![sender isKindOfClass:[UIBarButtonItem class]]){
                        NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                        [dicinfo setObject:[record valueForKey:@"group1code"] forKey:@"identifier"];
                        [dicinfo setObject:[record valueForKey:@"gdescription"] forKey:@"label"];
                        [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                        [arrGroup1 replaceObjectAtIndex:ipath.row withObject:dicinfo];
                       // [arrGroup2 replaceObjectAtIndex:ipath.row withObject:dicinfo];
                        //[arrGroup1 addObject:[record valueForKey:@"group1code"]];
                        
                    }
                }
            }
            if(iCounter<=3){
                if([nextScreenTitle length]>0)
                    nextScreenTitle=[nextScreenTitle stringByAppendingFormat:@", %@",[record valueForKey:@"gdescription"]];
                else
                    nextScreenTitle = [record valueForKey:@"gdescription"];
            }
            iCounter++;
        }
      
        
        
        
        
        CurrentScreenTitle = self.navigationItem.title;
        self.navigationItem.title = @"";

        // Set next screen title if all products button tapped on main category screen
        if([sender isKindOfClass:[UIBarButtonItem class]] && !_isSubCategory){
            iCounter = 1;
            nextScreenTitle = @"All Products";
            if(_isPromotions){
                [arrPromotions removeAllObjects];
            }
        }
        else if([sender isKindOfClass:[UIBarButtonItem class]] && _isSubCategory){
            iCounter = 1;
            if(_isPromotions){
                [arrPromotions removeAllObjects];
            }
            else{
                arrGroup1=_selectedGroup1Array;
               //[arrGroup1 addObject:[_selectedGroup1 valueForKey:@"group1code"]];
            }
            nextScreenTitle = [self.title substringToIndex:[self.title rangeOfString:@" ("].location];
        }


        ProductController *productController = segue.destinationViewController;
        productController.Group1Codes = [NSArray arrayWithArray:arrGroup1];
        productController.Group2Codes = [NSArray arrayWithArray:arrGroup2];
        productController.PromotionalCodes = [NSArray arrayWithArray:arrPromotions];

        productController.customerInfo = kAppDelegate.customerInfo;
        productController.transactionInfo = kAppDelegate.transactionInfo;
        //Edited product
        if (kAppDelegate.isEditTransaction) {
            productController.selectStockCode=[kAppDelegate.editTransactionProd valueForKey:@"productid"];
          //  kAppDelegate.editTransactionProd=nil;
        }
        //end

        

        if(iCounter>3)
            nextScreenTitle = [nextScreenTitle stringByAppendingFormat:@"+%li",(long)(iCounter-3)];
        
        productController.title = nextScreenTitle;

    }
    
    
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    isScrollBeginDragging = YES;
    [self dismissKeyboard:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!isScrollBeginDragging || [[self.fetchedResultsController fetchedObjects] count]<=10 || scrollView.contentSize.height<=_mainTableView.frame.size.height){
        if([[self.fetchedResultsController fetchedObjects] count]<=10 && self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        return;
    }

    if(scrollView.contentOffset.y<=distance){
        if(self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else{
        if(!self.navigationController.navigationBarHidden)
            [self navigationHide];//[self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    
}

-(void)navigationHide{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    distance = scrollView.contentOffset.y;
    if(distance<0) distance = 0;
    isScrollBeginDragging = NO;
    
}

- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
    [_btnOverlay setHidden:YES];
}


//Edit Product
-(void)loadEditProduct{
    kAppDelegate.isEditTransaction=NO;
    [self performSegueWithIdentifier:@"toProductScreen" sender:nil];

}

//When companySwitch Notification Called
- (void) refreshCompanydata:(NSNotification *) notification{
    [_searchBar1 setText:@""];
}

@end
