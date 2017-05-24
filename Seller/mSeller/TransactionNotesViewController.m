//
//  TransactionNotesViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/21/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionNotesViewController.h"

@interface TransactionNotesViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSIndexPath* lastIndexPath;
    
}
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property(weak,nonatomic)IBOutlet UITableView *tblTransactionNotes;
@property(weak,nonatomic)IBOutlet UIView *viewSignature;
@property (weak, nonatomic) IBOutlet UISearchBar *noteSearchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonDone;
@property (weak, nonatomic) IBOutlet UIButton *btnOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHLayoutConstraint;
@end

@implementation TransactionNotesViewController
@synthesize returnDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=NSLocalizedString(@"Notes", @"Notes");

//    signatureView=[[SignatureView alloc] initWithFrame:_viewSignature.bounds];
//    [_viewSignature addSubview:signatureView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tblTransactionNotes.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    _tblTransactionNotes.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    
    [self filter_notes:nil];
  
    if ([[_fetchedResultsController fetchedObjects] count]<=10) {
        _searchBarHLayoutConstraint.constant=0.0;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap];

}
-(void)dismissKeyboard:(UIGestureRecognizer*)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.hidden = NO;
    NSUInteger row = [indexPath row];
    NSUInteger oldRow = [lastIndexPath row];
    cell.accessoryType = (row == oldRow && lastIndexPath != nil) ?
    UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=[record valueForKey:@"notetext"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger newRow = [indexPath row];
    NSUInteger oldRow = [lastIndexPath row];
    if (newRow != oldRow)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
      
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        lastIndexPath = indexPath;
    }
    else
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        lastIndexPath = indexPath;
        
    }
    
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    returnDictionary=[NSDictionary dictionaryWithObject:[record valueForKey:@"notetext"] forKey:@"Note"];
   // [returnDictionary setValue:[self.noteArray objectAtIndex:indexPath.row] forKey:@"Note"];
    
    [self.delegate finishedNoteSelectionWithOption:returnDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Edit the entity name as appropriate.
    NSString * entityName=@"NOTES";
    
    NSFetchRequest *fetchRequest= [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" notetype contains[cd] '%@' ",_noteType]];
    [fetchRequest setPredicate:predicate];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"notetext" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:kAppDelegate.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tblTransactionNotes beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tblTransactionNotes endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tblTransactionNotes;
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
            [self.tblTransactionNotes insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tblTransactionNotes deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)filter_notes :(NSString* )searchText{
    NSString *strPredicate = @"";
    if ([searchText length] == 0) {
        _fetchedResultsController = nil;
    }
    else {
        strPredicate = [strPredicate stringByAppendingFormat:@" notetext CONTAINS '%@'",searchText];
    }
    
    if([strPredicate length]>0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:strPredicate];
        [[_fetchedResultsController fetchRequest] setPredicate:predicate];
    }
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [_tblTransactionNotes reloadData];
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self dismissKeyboard:nil];
}
#pragma mark - UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchText length]<=0) {
        [_btnOverlay setHidden:NO];
    }else
        [_btnOverlay setHidden:YES];

    
//    if ([searchText length]>0) {
//        UITextField *tf = (UITextField *)_noteSearchBar;
//        tf.enablesReturnKeyAutomatically = YES;
//        [_noteSearchBar setReturnKeyType:UIReturnKeySearch];
//    }else{
//        UITextField *tf = (UITextField *)_noteSearchBar;
//        tf.enablesReturnKeyAutomatically = NO;
//        [_noteSearchBar setReturnKeyType:UIReturnKeyDone];
//    }
    
    
    [self filter_notes:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [_btnOverlay setHidden:NO];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_btnOverlay setHidden:YES];
}
#pragma mark -Finish


- (IBAction)done_click:(id)sender {
    [self.delegate finishedNoteSelectionWithOption:returnDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -Keyboard down anywhere click
/*- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
    [_btnOverlay setHidden:YES];
}*/
@end
