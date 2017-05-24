//
//  CustomerFilterViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerFilterViewController.h"
#import "DatePickerViewController.h"

@interface CustomerFilterViewController ()<DatePickerViewControllerDelegate>{

}
@end

@implementation CustomerFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // self.navigationItem.hidesBackButton=YES;
    self.arrFilterRows = [[NSArray alloc] initWithObjects:@"All Customers",@"Customers On Stop",@"Customers Near Me",@"Customers Without History",@"Customers Without History Since: ", nil];

    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView1 numberOfRowsInSection:(NSInteger)section{
    
    return [self.arrFilterRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row==4)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else{
        if(_selectedOption==indexPath.row)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Configure the cell...
    cell.textLabel.text = [self.arrFilterRows objectAtIndex:indexPath.row];
    if (indexPath.row!=4)
        cell.detailTextLabel.text=nil;
    else{
        cell.detailTextLabel.text=[CommonHelper showDateWithCustomFormat:@"dd-MM-yyyy" Date:_selectedDate];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    for(NSIndexPath *ipath in [tableView indexPathsForVisibleRows]){
        if(![ipath isEqual:indexPath]){
            [tableView cellForRowAtIndexPath:ipath].accessoryType = UITableViewCellAccessoryNone;
        }
    }

    if (indexPath.row==4){
        [self performSegueWithIdentifier:@"toCustomerDateView" sender:self];
    }
    else{
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        if(cell.accessoryType==UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _selectedOption = indexPath.row;
        }
    }
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
    if([segue.identifier isEqualToString:@"toCustomerDateView"]){
        DatePickerViewController *dvc = segue.destinationViewController;
        dvc.title = @"Select";
        dvc.delegate = self;
        dvc.selectedDate = _selectedDate;
        dvc.isDateRange = NO;
    }
}

- (IBAction)doSelect:(UIBarButtonItem *)sender {
    NSArray *customerIds = nil;
    if(_selectedOption==3){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"IHEAD" inManagedObjectContext:kAppDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];

        NSAttributeDescription* custcode = [entity.attributesByName objectForKey:@"customer_code"];
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithObject:custcode];
        [fetchRequest setPropertiesToFetch:arrFetchList];

        NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        if(results && [results count]>0){
            customerIds = [results valueForKeyPath:@"customer_code"];
        }
        else{
            customerIds = results;
        }
    }
    else if(_selectedOption==4){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSAttributeDescription* custcode = [entity.attributesByName objectForKey:@"customerid"];
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithObject:custcode];
        [fetchRequest setPropertiesToFetch:arrFetchList];

        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"orderdate<=%@",_selectedDate]];
        NSArray *results = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        if(results && [results count]>0){
            customerIds = [results valueForKeyPath:@"customerid"];
        }
        else{
            customerIds = results;
        }
    }

    if([self.delegate respondsToSelector:@selector(finishedFilterSelectionWithOption:SelectedDate:ArrHistory:)]){
        [self.delegate finishedFilterSelectionWithOption:_selectedOption SelectedDate:_selectedDate ArrHistory:customerIds];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CustomDatePickerViewController Delegate
-(void)finishedSelectionWithDate:(NSDate *)seldate{
    _selectedOption = 4;
    _selectedDate=seldate;
    [_filterTableView reloadData];
}

@end
