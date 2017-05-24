//
//  DatePickerViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 12/23/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "DatePickerViewController.h"
#import "commonMethods.h"


@interface DatePickerViewController ()<UIAlertViewDelegate>
{
    NSInteger selectedIndex;
}
@property(weak,nonatomic)IBOutlet UITableView *tblDatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightbarButton;
- (IBAction)clearDate:(id)sender;

@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if(_isDateRange){
        if(!_selectedDate){
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setHour:00];
            [dateComponents setMinute:00];
            [dateComponents setSecond:10];
            [dateComponents setWeekOfMonth:-2];

            NSCalendar *currentCalendar = [NSCalendar currentCalendar];
            NSDate  *startdate = [currentCalendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
            _selectedDate =startdate;
        }

        if(!_selectedToDate){
            //NSCalendar *currentCalendar = [NSCalendar currentCalendar];
            NSDate  *enddate =[commonMethods dateAtBeginningOfDayForDate:[NSDate date] Hours:23 minutes:59 Seconds:59];
            //[currentCalendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0];
            _selectedToDate =enddate;
        }

    }
    else{
        if(!_selectedDate){
            
            NSDate  *startdate =[commonMethods dateAtBeginningOfDayForDate:[NSDate date] Hours:23 minutes:59 Seconds:59];
            
            //NSCalendar *currentCalendar = [NSCalendar currentCalendar];
            //startdate =[currentCalendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0];
            _selectedDate =startdate;
        }
    }

    if(!_clearSelectionEnabled){
       self.navigationItem.rightBarButtonItems =nil;
        
//        UIBarButtonItem *btnClear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(doClearSelection:)];
//        _rightbarButton.tintColor = [UIColor redColor];
    }

    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

-(void)doClearSelection:(UIBarButtonItem *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you really want to clear selected date?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex>=0) {
        
        if (selectedIndex==indexPath.row){//[[tableView indexPathsForSelectedRows] indexOfObject:indexPath] != NSNotFound) {
            return 250.0; // Expanded height
        }
        return 44.0; // Normal height
    }
    
    return 44.0; // Normal height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isDateRange)
        return 2;
    else
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DatePickerTableViewCell";
    DatePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (indexPath.row==0)
    {
        cell.lblSelectedDate.text=@"From";
        if(!_selectedDate) _selectedDate = [NSDate date];
        [cell.btnSelectDate setTitle:[CommonHelper showDateWithCustomFormat:@"d MMM yyyy" Date:_selectedDate] forState:UIControlStateNormal];
        cell.datePicker.date = _selectedDate;
//        else
//        {
//            _selectedDate =
//            [cell.btnSelectDate setTitle:[CommonHelper showDateWithCustomFormat:@"d MMM yyyy" Date:[NSDate date]] forState:UIControlStateNormal];
//        }
        cell.datePicker.hidden=NO;
        if(!_isDateRange)
            cell.lblSelectedDate.text=@"Selected Date";

        selectedIndex = indexPath.row;
    }
    else
    {
        if (_isDateRange) {
            if(!_selectedToDate) _selectedToDate = [NSDate date];
            cell.lblSelectedDate.text=@"To";
            [cell.btnSelectDate setTitle:[CommonHelper showDateWithCustomFormat:@"d MMM yyyy" Date:_selectedToDate] forState:UIControlStateNormal];
            cell.datePicker.date = _selectedToDate;
        }
        cell.datePicker.hidden=YES;
    }
    cell.datePicker.tag = indexPath.row;
    cell.btnSelectDate.tag=indexPath.row;

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex!=indexPath.row){
        NSArray *visibleRows = [tableView indexPathsForVisibleRows];
        NSIndexPath *lastTappedCellIndexPath = [visibleRows objectAtIndex:selectedIndex];
        
        DatePickerTableViewCell *cell=[_tblDatePicker cellForRowAtIndexPath:lastTappedCellIndexPath];
        cell.datePicker.hidden=YES;
    }

    DatePickerTableViewCell *cell=[_tblDatePicker cellForRowAtIndexPath:indexPath];
    cell.datePicker.hidden=NO;
    selectedIndex=indexPath.row;
    [self updateTableView];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [self updateTableView];
}
- (void)updateTableView
{
    [_tblDatePicker beginUpdates];
    [_tblDatePicker endUpdates];
}

-(IBAction)btnTitle:(UIDatePicker *)sender
{
    DatePickerTableViewCell *cell = [_tblDatePicker cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    [cell.btnSelectDate setTitle:[CommonHelper showDateWithCustomFormat:@"d MMM yyyy" Date:cell.datePicker.date] forState:UIControlStateNormal];
    if(sender.tag==0){
       /* NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        if (_isCallBack) {
            [dateComponents setHour:00];
            [dateComponents setMinute:00];
            [dateComponents setSecond:00];
        }else  if(_isDateRange){
            [dateComponents setHour:00];
            [dateComponents setMinute:00];
            [dateComponents setSecond:00];
        }
        else{
            [dateComponents setHour:00];
            [dateComponents setMinute:00];
            [dateComponents setSecond:00];
        }
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDate  *startdate = [currentCalendar dateByAddingComponents:dateComponents toDate:cell.datePicker.date  options:0];
       */
        NSDate  *startdate =[commonMethods dateAtBeginningOfDayForDate:cell.datePicker.date Hours:0 minutes:0 Seconds:10];
        
        _selectedDate =startdate;
    }
    else{
        /*NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:23];
        [dateComponents setMinute:59];
        [dateComponents setSecond:59];
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDate  *enddate = [currentCalendar dateByAddingComponents:dateComponents toDate:cell.datePicker.date  options:0];*/
        
        NSDate  *enddate =[commonMethods dateAtBeginningOfDayForDate:cell.datePicker.date Hours:23 minutes:59 Seconds:50];
        _selectedToDate =enddate;
    }

//    if([self.delegate respondsToSelector:@selector(finishedSelectionWithDone:)])
//        [self.delegate finishedSelectionWithDone:seldate];

}

-(IBAction)dateClicked:(UIButton *)sender
{
    if (selectedIndex!=sender.tag){
        NSArray *visibleRows = [_tblDatePicker indexPathsForVisibleRows];
        NSIndexPath *lastTappedCellIndexPath = [visibleRows objectAtIndex:selectedIndex];
        
        DatePickerTableViewCell *cell=[_tblDatePicker cellForRowAtIndexPath:lastTappedCellIndexPath];
        cell.datePicker.hidden=YES;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    DatePickerTableViewCell *cell = [_tblDatePicker cellForRowAtIndexPath:indexPath];
    cell.datePicker.hidden=NO;
    selectedIndex=sender.tag;
    [_tblDatePicker beginUpdates];
    [_tblDatePicker selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [_tblDatePicker endUpdates];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if(_isDateRange){
        if([self.delegate respondsToSelector:@selector(finishedSelectionWithFromDate:ToDate:)])
            [self.delegate finishedSelectionWithFromDate:_selectedDate ToDate:_selectedToDate];
    }
    else{
        if([self.delegate respondsToSelector:@selector(finishedSelectionWithDate:)])
            [self.delegate finishedSelectionWithDate:_selectedDate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-(BOOL) navigationShouldPopOnBackButton
//{
//    if (!_isFromTransaction) {
//        [self btnTitle:nil];
//        
//        
//            [self.navigationController popViewControllerAnimated:YES];
//        
//        return NO;
//        
//       
//  
//    }else
//        return YES;
//        
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        _selectedDate = nil;
        _selectedToDate = nil;
//        [self.navigationController popViewControllerAnimated:NO];
        if([self.delegate respondsToSelector:@selector(finishedSelectionWithDate:)])
            [self.delegate finishedSelectionWithDate:nil];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
}

- (IBAction)clearDate:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you really want to clear selected date?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
}
@end
