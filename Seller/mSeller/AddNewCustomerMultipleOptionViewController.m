//
//  AddNewCustomerMultipleOptionViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/13/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "AddNewCustomerMultipleOptionViewController.h"

@interface AddNewCustomerMultipleOptionViewController ()

@end

@implementation AddNewCustomerMultipleOptionViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _fetchedResultsController=nil;
    [self fetchedResultsController];
}
#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSEntityDescription *entity;
    if (_selectedOption==1 || _selectedOption==3)
     entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    else
      entity = [NSEntityDescription entityForName:@"CONV" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
   
    if (_selectedOption==1) {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rep1" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPropertiesToFetch:@[@"rep1"]];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"rep1!=nil AND rep1!=''"];
    [fetchRequest setPredicate:predicate];

    }
    else if (_selectedOption==2)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"currencycode" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"currencycode!=nil AND currencycode!=''"];
        [fetchRequest setPredicate:predicate];

    }
    else if (_selectedOption==3)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pricegroup" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setResultType:NSDictionaryResultType];
        [fetchRequest setReturnsDistinctResults:YES];
        [fetchRequest setPropertiesToFetch:@[@"pricegroup"]];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"pricegroup!=nil AND pricegroup!=''"];
        [fetchRequest setPredicate:predicate];

    }
    
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if (_selectedOption==1)
    cell.textLabel.text=[record valueForKey:@"rep1"];
    else if (_selectedOption==2)
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",[record valueForKey:@"currencycode"],[record valueForKey:@"currdes"]];
    else if (_selectedOption==3)
        cell.textLabel.text=[record valueForKey:@"pricegroup"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell=[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *strValue =selectedCell.textLabel.text;
    if (_selectedOption==2){
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        strValue=[record valueForKey:@"currencycode"];
    }
    
    if([delegate respondsToSelector:@selector(selectedIndexValue:Option:)])
        [delegate selectedIndexValue:strValue Option:_selectedOption];

    [self.navigationController popViewControllerAnimated:YES];
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

@end
