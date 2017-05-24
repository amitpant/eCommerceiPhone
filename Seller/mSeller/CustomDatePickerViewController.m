//
//  CustomerDateViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomDatePickerViewController.h"
//#import "NVCalendar.h"
//#import "CustomerMonthDateShowViewController.h"
#import "CalendarCollectionViewCell.h"
#import "CalendarDataSource.h"
#import "CalendarYearlyCell.h"

//static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
//{
//    return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
//}

@interface CustomDatePickerViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,CalendarCollectionViewCellDelegate>
{
    NSString *selectedMonth;
    NSMutableArray *arrYears;
    CalendarDataSource *collectionsource;
    NSArray *arrReminders;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@end
@implementation CustomDatePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    collectionsource = [[CalendarDataSource alloc] init];
    
    dtForMonth=[self firstDateOfCurrentYear];
//    [self createCalendar];
     self.scrollView.contentSize=CGSizeMake(320, 1000);

    arrYears = [NSMutableArray array];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    kAppDelegate.store = [[EKEventStore alloc] init];
    // Initialize the events list
    _eventsList = [[NSMutableArray alloc] initWithCapacity:0];
    // The Add button is initially disabled
    //self.addButton.enabled = NO;
    _arrDate = [[NSMutableArray alloc]init];
    NSInteger currYear = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
    for(NSInteger i=(currYear-10);i<=currYear+2;i++){
        [arrYears addObject:[NSNumber numberWithInteger:i]];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Check whether we are authorized to access Calendar
    _runloop=YES;
    [self checkEventStoreAccessForCalendar];
}

#pragma mark -
#pragma mark Access Calendar

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [kAppDelegate.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             CustomDatePickerViewController * __weak weakSelf = self;
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [weakSelf accessGrantedForCalendar];
             });
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    self.defaultCalendar = kAppDelegate.store.defaultCalendarForNewEvents;
    // Enable the Add button
   // self.addButton.enabled = YES;
    // Fetch all events happening in the next 24 hours and put them into eventsList
    _eventsList = [self fetchEvents];
    DebugLog(@"self.eventsList  %@",_eventsList );
    [self refreshMarksWithArray:_eventsList];
}


#pragma mark -
#pragma mark Fetch events

// Fetch all events happening in the next 24 hours
- (NSMutableArray *)fetchEvents
{
    NSDate *startDate = [NSDate date];
    
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 1;
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
    // We will only search the default calendar for our events
    NSArray *calendarArray = @[self.defaultCalendar];
    // Create the predicate
    NSPredicate *predicate = [kAppDelegate.store predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:calendarArray];
    
    // Fetch all events that match the predicate
    NSMutableArray *events = [NSMutableArray arrayWithArray:[kAppDelegate.store eventsMatchingPredicate:predicate]];
    
    return events;
}

-(void)refreshMarksWithArray:(NSArray *)arr
{
    for (EKEvent* event in arr) {
        if (_runloop) {
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            [fmt setDateFormat: @"dd-MM-yyyy"];
            NSString *strSelectedDate=[fmt stringFromDate:event.startDate];
            if(![_arrDate containsObject:strSelectedDate]){
                // DebugLog(@"runningggggcount%@",ev.startDate);
                [_arrDate addObject:strSelectedDate];
            }
            }
        }
    DebugLog(@"_arrDate  %@",_arrDate);
}
-(void)showEventsForSelectedDate:(NSDate *)seldate{
//    NSMutableArray* arrTemp = [[NSMutableArray alloc] init];
//    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:seldate];
//    seldate=[[NSCalendar currentCalendar] dateFromComponents:comps];
//    
//    for (EKEvent *event in _eventsList){
//        comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:event.startDate];
//        NSDate* dateStart=[[NSCalendar currentCalendar] dateFromComponents:comps];
//        
//        comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:event.endDate];
//        NSDate* dateEnd=[[[NSCalendar currentCalendar] dateFromComponents:comps] dateByAddingTimeInterval:86400];
//        
//        if (IsDateBetweenInclusive(seldate, dateStart, dateEnd)){
//            [arrTemp addObject:event];
//        
//        }
//        
//    }
//    // now call ourselves back on the main thread
//    dispatch_async( dispatch_get_main_queue(), ^{
//        DebugLog(@"arrTemp Count  %lu",(unsigned long)arrTemp.count);
//
//    });
}

#pragma mark -
#pragma mark Add a new event

// Display an event edit view controller when the user taps the "+" button.
// A new event is added to Calendar when the user taps the "Done" button in the above view controller.
- (IBAction)addEvent:(id)sender
{
    // Create an instance of EKEventEditViewController
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    // Set addController's event store to the current event store
    addController.eventStore = kAppDelegate.store;
    addController.editViewDelegate = self;
    
    [self presentViewController:addController animated:YES completion:nil];
}


#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    CustomDatePickerViewController * __weak weakSelf = self;
    // Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (action != EKEventEditViewActionCanceled)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 // Re-fetch all events happening in the next 24 hours
                 weakSelf.eventsList = [self fetchEvents];
                 // Update the UI with the above events
             });
         }
     }];
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
    return self.defaultCalendar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}
//1
-(void) createheaderView
{
    _vwCalendar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 294)];
    _vwCalendar.tag = 1001;
    
    // _vwCalendar.backgroundColor = [UIColor greenColor];
    _btnPrevious = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPrevious.frame = CGRectMake(0, 8, 45, 30);
    // _btnPrevious.backgroundColor = [UIColor yellowColor];
    
    [_btnPrevious setImage:[UIImage imageNamed:@"arrow-left.png"] forState:UIControlStateNormal];
    [_btnPrevious addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
    [_vwCalendar addSubview:_btnPrevious];
    
    _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnNext.frame = CGRectMake(278, 8, 45, 30);
    [_btnNext setImage:[UIImage imageNamed:@"arrow-right.png"] forState:UIControlStateNormal];
    //_btnNext.backgroundColor = [UIColor yellowColor];
    
    [_btnNext addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [_vwCalendar addSubview:_btnNext];
    
    _lblMonth = [[UILabel alloc] initWithFrame:CGRectMake(45, 7, 226, 35)];
    _lblMonth.textColor = [UIColor blackColor];
    _lblMonth.textAlignment = NSTextAlignmentCenter;
    _lblMonth.text = @"Month";
    //_lblMonth.backgroundColor = [UIColor redColor];
    [_vwCalendar addSubview:_lblMonth];
    
}


//getting january from current date
- (NSDate *)firstDateOfCurrentYear
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"01-01-yyyy 00:00:00 0000"];
    NSString *dateStr = [fmt stringFromDate:[NSDate date]];
    [fmt setDateFormat: @"MM-dd-yyyy HH:mm:ss zzzz"];
    NSDate *firstDate = [fmt dateFromString:dateStr];
    return firstDate;
}

#pragma mark - Tapping Date
-(void)viewDateTapped:(UITapGestureRecognizer *)tap//called when any date will be tapped
{
    UIView *viewTap = (UIView *)[self.view viewWithTag:tap.view.tag];
    UILabel *tagLabel =  (UILabel*)[viewTap viewWithTag:1999];
    selectedMonth=tagLabel.text;
    [self performSegueWithIdentifier:@"toCustomerMonthDate" sender:self];
    
}
-(IBAction)next
{
//    [self createCalendar];
}
-(IBAction)previous
{
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setMonth:-Minus_month_for_Previous_Action];
//    dtForMonth = [gregorian dateByAddingComponents:components toDate:dtForMonth options:0];
//    [self createCalendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)finishedSelectionWithDate:(NSDate *)seldate{
    self.selectedDate=seldate;
    selectedMonth=nil;
     [self performSegueWithIdentifier:@"toCustomerMonthDate" sender:self];
}
-(void)finishedDateWithDone:(NSDate *)seldate{
    if([self.delegate respondsToSelector:@selector(finishedSelectionWithDone:)])
        [self.delegate finishedSelectionWithDone:seldate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doSelect:(UIBarButtonItem *)sender {
//    if([self.delegate respondsToSelector:@selector(finishedSelectionWithDone:)])
//        [self.delegate finishedSelectionWithDone:_selectedDate];
//    [self.navigationController popViewControllerAnimated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([[segue identifier] isEqualToString:@"toCustomerMonthDate"]) {
//        CustomerMonthDateShowViewController *customerMonthDateVC=segue.destinationViewController;
//        customerMonthDateVC.getMonth=selectedMonth;
//        customerMonthDateVC.selectedDate=self.selectedDate;
//        customerMonthDateVC.delegate=self;
//    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrYears count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CalendarYearlyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarYearlyCell"];
    cell.lblYear.text = [NSString stringWithFormat:@"%li",[[arrYears objectAtIndex:indexPath.row] integerValue]];
    cell.collectionView.bounces = NO;
    cell.collectionView.dataSource = collectionsource;
    cell.collectionView.delegate = self;
    [collectionsource setYearValue:[[arrYears objectAtIndex:indexPath.row] integerValue]];
    [cell.collectionView reloadData];
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (((self.view.bounds.size.width-22)/2) * 6)+100;
}


#pragma mark - UICollectionViewDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((collectionView.frame.size.width-15)/2, ((collectionView.frame.size.width-22)/2));
}


#pragma mark - CalendarCollectionViewCellDelegate
-(void)getSelectedCustomDate:(NSDate *)date{
    [self showEventsForSelectedDate:date];
    if([self.delegate respondsToSelector:@selector(finishedSelectionWithDone:)])
            [self.delegate finishedSelectionWithDone:date];
        [self.navigationController popViewControllerAnimated:YES];
}
@end
