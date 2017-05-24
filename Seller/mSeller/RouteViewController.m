//
//  RouteViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 11/17/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "RouteViewController.h"

@interface RouteViewController ()
{
    CLLocationCoordinate2D locationCoordinate2D_From;
    CLLocationCoordinate2D locationCoordinate2D_To;
}
@end

@implementation RouteViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arrRoutesDirection=[[NSMutableArray alloc] init];
    arrPoints=[[NSMutableArray alloc] init];
    _fetchedResultsController=nil;
[self performSelector:@selector(getRouteDirections) withObject:nil afterDelay:0.001];
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
  
    
     NSPredicate *predicate=[NSPredicate predicateWithFormat:@"name IN %@",_arrAcc_Ref_from_to_txtfield];
    [fetchRequest setPredicate:predicate];
    
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
-(void) getRouteDirections
{
    [self fetchedResultsController];
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    DebugLog(@"Fetched Data %@",fetchedData);
    _customerFromInfo=[fetchedData objectAtIndex:0];
    _customerToInfo=[fetchedData objectAtIndex:1];
    
    locationCoordinate2D_From=CLLocationCoordinate2DMake([[_customerFromInfo valueForKey:@"latitude"] doubleValue], [[_customerFromInfo valueForKey:@"longitude"] doubleValue]);
    locationCoordinate2D_To=CLLocationCoordinate2DMake([[_customerToInfo valueForKey:@"latitude"] doubleValue], [[_customerToInfo valueForKey:@"longitude"] doubleValue]);

    NSString *apiUrlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%1.6f,%1.6f&destination=%1.6f,%1.6f&sensor=true", [[_customerFromInfo valueForKey:@"latitude"] doubleValue],[[_customerFromInfo valueForKey:@"longitude"] doubleValue],[[_customerToInfo valueForKey:@"latitude"] doubleValue],[[_customerToInfo valueForKey:@"longitude"] doubleValue]];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSData* data = [NSData dataWithContentsOfURL:
                    apiUrl];
    [_activityIndicatorView startAnimating];
    [self performSelectorOnMainThread:@selector(fetchedData:)
                           withObject:data waitUntilDone:YES];
}


- (void)fetchedData:(NSData *)responseData {
    [_arrRoutesDirection removeAllObjects];
    _strRouteDirections = @"";
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray *routesArray=[json objectForKey:@"routes"];
    
    if ([routesArray count]>0)
    {
        _strRouteDirections = [_strRouteDirections stringByAppendingFormat:@"<p><b>%@</b></p>",[_customerFromInfo valueForKey:@"name"]];
        NSDictionary *routeDict=[routesArray objectAtIndex:0];
        NSArray *legsarray=[routeDict objectForKey:@"legs"];
        NSDictionary *legsdict=[legsarray objectAtIndex:0];
        NSArray *stepsarray=[legsdict objectForKey:@"steps"];
        
        for (int i=0; i<[stepsarray count]; i++)
        {
            
            NSDictionary *stepsdict=[stepsarray objectAtIndex:i];
            NSDictionary *startLocation=[stepsdict objectForKey:@"start_location"];
            NSString *stringPoints=[NSString stringWithFormat:@"%@,",[startLocation objectForKey:@"lat"]];
            NSString *stringPoints1=[NSString stringWithFormat:@"%@",[startLocation objectForKey:@"lng"]];
            stringPoints=[stringPoints stringByAppendingString:stringPoints1];
            [arrPoints addObject:stringPoints];
            NSDictionary *distance = [stepsdict objectForKey:@"distance"];
            NSString *instStr =[stepsdict objectForKey:@"html_instructions"];
            NSString *myregex = @"<[^>]*>"; //regex to remove any html tag
            NSString *stringWithoutHTML = [instStr stringByReplacingOccurrencesOfRegex:myregex withString:@""];
            CGFloat dist = [[distance objectForKey:@"text"] floatValue];
            
            NSString *finaledistance = nil;
            NSString *startpoint=@"startpoint";
            if([[distance objectForKey:@"text"] rangeOfString:@"k"].location != NSNotFound)
            {
                dist = dist*0.621371;
                finaledistance = [NSString stringWithFormat:@"%.2f miles",dist];
                
            }
            else{
                
                dist = dist*3.28084;
                finaledistance = [NSString stringWithFormat:@"%.2f ft",dist];
                
            }
            [_arrRoutesDirection addObject:[NSDictionary dictionaryWithObjectsAndKeys:stringWithoutHTML,@"directions",finaledistance,@"distance",startLocation,startpoint,nil]];
            
           _strRouteDirections = [_strRouteDirections stringByAppendingFormat:@"<p>%@<br /%@</p>",finaledistance,instStr];
        }
        _strRouteDirections = [_strRouteDirections stringByAppendingFormat:@"<p><b>%@</b></p>",[_customerToInfo valueForKey:@"name"]];
    }
    [_activityIndicatorView stopAnimating];
    [_tblRoute reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrRoutesDirection.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dic = [_arrRoutesDirection objectAtIndex:indexPath.row];
    if(indexPath.row==0)
    {
        
        cell.textLabel.text = nil;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    else{
        cell.textLabel.text =[NSString stringWithFormat:@"Drive %@ then",[dic objectForKey:@"distance"]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
    }
    
    cell.detailTextLabel.text = [dic objectForKey:@"directions"];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.detailTextLabel.numberOfLines = 3; // set the numberOfLines
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;//UILineBreakModeTailTruncation;
    cell.detailTextLabel.textColor = [UIColor blackColor];
    return cell;
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if([delegate respondsToSelector:@selector(calculateRoutesFrom:to:ArrPoints:)])
        [delegate calculateRoutesFrom:locationCoordinate2D_From to:locationCoordinate2D_To ArrPoints:arrPoints];
}
-(IBAction)sendMail:(UIBarButtonItem *)sender;
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    
    mailComposer.mailComposeDelegate = self;
    
    [mailComposer setToRecipients:[NSArray arrayWithObjects: @"satish.singh@williamscommerce.com",nil]];
    
    [mailComposer setSubject:[NSString stringWithFormat: @"Route."]];
    
    NSString *supportText = [NSString stringWithFormat:@"Dear Customer,\n"];
    
    supportText = [supportText stringByAppendingString: @"Please find attached a copy of route.\n"];
    supportText=[supportText stringByAppendingString:_strRouteDirections];
    
    [mailComposer setMessageBody:supportText isHTML:NO];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
    
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
