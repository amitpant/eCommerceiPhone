//
//  CustomerMapViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/16/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerMapViewController.h"
#import "CustomerController.h"
#import "RouteViewController.h"
#import "SearchResultsTableViewController.h"

@interface ConstantWidthPolylineRenderer : MKPolylineRenderer
@end

@implementation ConstantWidthPolylineRenderer

- (void)applyStrokePropertiesToContext:(CGContextRef)context
                           atZoomScale:(MKZoomScale)zoomScale
{
    [super applyStrokePropertiesToContext:context atZoomScale:zoomScale];
    CGContextSetLineWidth(context, self.lineWidth);
}

@end

@interface CustomerMapViewController ()<UISearchResultsUpdating,UISearchControllerDelegate,SearchResultDelegate>
{
    NSString *strFrom_toTitle;
    NSString *strCustomerAddSubTitle;
    NSMutableArray *arrRouteDstnce_AccRef;
    NSInteger selTag;
    double totalDistance;
    NSString *selectedCustomer;
    NSMutableArray *arrRouteDirection;

    NSArray *routesDrawn;
    SearchResultsTableViewController *searchResults;
    NSString *strSelectedCustomer;
}

@property (nonatomic, assign) CLLocationCoordinate2D selectedLocationCoordinate2D;
@property (weak, nonatomic) IBOutlet UIView *viewFromTo;

@property (strong, nonatomic) NSMutableArray *data;
@property (nonatomic, strong) UISearchController *controller;
@property (strong, nonatomic) NSArray *results;
@end

@implementation CustomerMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fetchedResultsController=nil;
    self.mapView.delegate=self;

    _viewFromTo.layer.cornerRadius = 6.0;
    _viewFromTo.layer.masksToBounds = YES;

    //code to show a dummy pin locations
   selTag = 0;
    /*  NSArray *name=[[NSArray alloc]initWithObjects:
                   @"VelaCherry",
                   @"Perungudi",
                   @"Tharamani", nil];
  
    NSMutableArray *annotation=[[NSMutableArray alloc]initWithCapacity:[name count]];
    
    MKPointAnnotation *mappin;
    
    CLLocationCoordinate2D location;
    
    location = CLLocationCoordinate2DMake(12.970760345459,80.2190093994141);
    mappin = [[MKPointAnnotation alloc]init];
    mappin.coordinate=location;
    mappin.title=[name objectAtIndex:0];
    [annotation addObject:mappin];
    
    mappin = [[MKPointAnnotation alloc]init];
    location = CLLocationCoordinate2DMake(12.9752297537231,80.2313079833984);
    mappin.coordinate=location;
    mappin.title=[name objectAtIndex:1];
    [annotation addObject:mappin];
    
    mappin = [[MKPointAnnotation alloc]init];
    location = CLLocationCoordinate2DMake(12.9788103103638,80.2412414550781);
    mappin.coordinate=location;
    mappin.title=[name objectAtIndex:2];
    [annotation addObject:mappin];
    
    [self.mapView addAnnotations:annotation];*/
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;    // Do any additional setup after loading the view.
    arrRouteDstnce_AccRef=[[NSMutableArray alloc] init];
    //end of code changes
    [self dropAllpins:0];
    _routeButton.enabled=NO;
    [_distanceMessage.layer setMasksToBounds:YES];
    _distanceMessage.layer.cornerRadius = 8;
    [_actviewRoute stopAnimating];

    
    if (_isFromCustDetail) {
        strSelectedCustomer=[NSString stringWithFormat:@"%@-%@",[_customerInfo valueForKey:@"acc_ref"],[_customerInfo valueForKey:@"name"]];
        [self data];
        [self showSearchCustomerPin:strSelectedCustomer];
    }
    
    
}
- (NSMutableArray *)data {
    
    if (!_data) {
        _data = [[NSMutableArray alloc]init];
        NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
        for (int i = 0; i < fetchedData.count; i++) {
             NSManagedObject *customerDetail = [fetchedData objectAtIndex:i];
            [_data addObject:[NSString stringWithFormat:@"%@-%@",[customerDetail valueForKey:@"acc_ref"],[customerDetail valueForKey:@"name"]]];
        }
    }
    return _data;
}
- (UISearchController *)controller {
    
    if (!_controller) {
        
        // instantiate search results table view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchResultsTableViewController *resultsController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResultsTableViewController"];
        resultsController.delegate=self;
        // create search controller
        _controller = [[UISearchController alloc]initWithSearchResultsController:resultsController];
        _controller.searchResultsUpdater = self;
        _controller.hidesNavigationBarDuringPresentation=NO;
        
        self.controller.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        // optional: set the search controller delegate
        _controller.delegate = self;
       
        self.navigationItem.titleView=_controller.searchBar;
        
        self.definesPresentationContext = YES;
    }
    return _controller;
}

# pragma mark - Search Results Updater
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    // filter the search results
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", self.controller.searchBar.text];
    self.results = [self.data filteredArrayUsingPredicate:predicate];
    
    // DebugLog(@"Search Results are: %@", [self.results description]);
}

-(void)showSearchCustomerPin:(NSString *)selectedString
{
    strSelectedCustomer=selectedString;
    NSInteger index = [_data indexOfObject:strSelectedCustomer];
    [self dropAllpins:index];
    _controller.active=false;
}
# pragma mark - Search Controller Delegate (optional)

- (void)didDismissSearchController:(UISearchController *)searchController {
    
    // called when the search controller has been dismissed
    strSelectedCustomer=@"";
}
- (void)willDismissSearchController:(UISearchController *)searchController {
    
    // called just before the search controller is dismissed
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    searchResults = (SearchResultsTableViewController *)self.controller.searchResultsController;
    [self addObserver:searchResults forKeyPath:@"results" options:NSKeyValueObservingOptionNew context:nil];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserver:searchResults forKeyPath:@"results"];
}
#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(stopflag!=1 && stopflag !='y' && stopflag !='Y')"]];
    
    // end of the code
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
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
-(void)dropAllpins:(NSInteger)index
{
    [_mapView removeOverlays:_mapView.overlays];
    [self fetchedResultsController];
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    
    NSManagedObject *customerDetail = [fetchedData objectAtIndex:index];
    if(_deviceLocation){
        double devicelatitude=_deviceLocation.coordinate.latitude;
        double devicelongitude=_deviceLocation.coordinate.longitude;
        [customerDetail setValue:[NSNumber numberWithDouble:devicelatitude] forKey:@"latitude"];
        [customerDetail setValue:[NSNumber numberWithDouble:devicelongitude] forKey:@"longitude"];
    }
    
    if([[customerDetail valueForKey:@"latitude"] doubleValue] !=0.0 && [[customerDetail valueForKey:@"longitude"] doubleValue]!=0)
    {
        
        _selectedLocationCoordinate2D = CLLocationCoordinate2DMake([[customerDetail valueForKey:@"latitude"] doubleValue], [[customerDetail valueForKey:@"longitude"] doubleValue]);
        double convVal = 25.4*12*3*1760/1000000;
        double pi80 = M_PI / 180;
        double lat1 =   [[customerDetail valueForKey:@"latitude"] doubleValue] * pi80;
        double lon1 =   [[customerDetail valueForKey:@"longitude"] doubleValue] * pi80;
        
        double R = 6372.797; // km default 6371
        
        for (NSManagedObject *customerDetail in fetchedData) {
            if([[customerDetail valueForKey:@"latitude"] integerValue]!=0.0 && [[customerDetail valueForKey:@"longitude"] integerValue]!=0){
                double lat2 = [[customerDetail valueForKey:@"latitude"] doubleValue] * pi80;
                double lon2 = [[customerDetail valueForKey:@"longitude"] doubleValue] * pi80;
                
                double dLat = lat2-lat1;
                double dLon = lon2-lon1;
                
                double a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
                double c = 2 * atan2(sqrt(a), sqrt(1-a));
                int d = R * c;
                
                if((d* convVal) <=_sliderRadiusMap.value){
                    if (!_deviceLocation) {
                        CLLocationCoordinate2D coordnate = CLLocationCoordinate2DMake([[customerDetail valueForKey:@"latitude"] doubleValue], [[customerDetail valueForKey:@"longitude"] doubleValue]);
                        
                        PlaceMark *placemark=[[PlaceMark alloc] initWithCoordinate:coordnate Title:[customerDetail valueForKey:@"name"] Subtitle:[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@-%@ (%@)",[customerDetail valueForKey:@"addr1"],[customerDetail valueForKey:@"addr2"],[customerDetail valueForKey:@"addr3"],[customerDetail valueForKey:@"addr4"],[customerDetail valueForKey:@"addr5"],[customerDetail valueForKey:@"postcode"],[customerDetail valueForKey:@"delivery_address"]] ManagedObject:customerDetail Selectedbtn:selTag];
                        [_mapView addAnnotation:placemark];
                    }
                }
            }
        }
        
        _sliderRadiusMap.value=700.02;//4.25;
        double sliderValue=_sliderRadiusMap.value/100;
        [_mapView setCenterCoordinate:_selectedLocationCoordinate2D zoomLevel:sliderValue animated:NO];
        if (!_isFromCustDetail)
            [self performSelector:@selector(customerOnRadiusValue) withObject:nil afterDelay:1.0];
        else
        {
            _sliderRadiusMap.value=7.02;
            [_mapView setCenterCoordinate:_selectedLocationCoordinate2D zoomLevel:_sliderRadiusMap.value animated:NO];
        }
    }
}
- (void)mapView:(MKMapView *)_mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    view.rightCalloutAccessoryView = rightButton;
    strFrom_toTitle=view.annotation.title;
    strCustomerAddSubTitle=view.annotation.subtitle;
    if([view.annotation isKindOfClass:[PlaceMark class]]){
        PlaceMark *placeMark = (PlaceMark *)view.annotation;
        rightButton.accessibilityIdentifier = [NSString stringWithFormat:@"%@|||%@",[placeMark.customerInfo valueForKey:@"acc_ref"],[placeMark.customerInfo valueForKey:@"delivery_address"]];
        if (_fromText.text.length==0 && _toText.text.length==0) {
            if([placeMark.T_Title isEqualToString:strFrom_toTitle])
                selTag=101;
        }
        else
        {
            if([placeMark.T_Title isEqualToString:strFrom_toTitle])
                selTag=102;
        }
    }

}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
   if (_isFromCustDetail)
   {
    id myAnnotation = [mapView.annotations objectAtIndex:0];
    [mapView selectAnnotation:myAnnotation animated:YES];
   }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
//id <MKAnnotation> annotation = [view annotation];
}
//-(MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    if(overlay == _routeLine)
//    {
//        if(nil == _routeLineView)
//        {
//            _routeLineView = [[MKPolylineRenderer alloc] initWithPolyline:_routeLine];
//            _routeLineView.fillColor = [UIColor blueColor];
//            _routeLineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
//            _routeLineView.lineWidth = 10;
//            
//        }
//        
//        return _routeLineView;
//    }
//    
//    return nil;
//}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *annotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView
                                                            dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    
    NSArray* arrStr = [strSelectedCustomer componentsSeparatedByString: @"-"];
    NSString* custName;
    if (arrStr.count>1)
    custName = [arrStr objectAtIndex: 1];
    

    if(pinView == nil)
    {
        
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
       // DebugLog(@"Annotation title %@",[annotation title]);
        pinView.canShowCallout=YES;
    }
    if([[annotation title] isEqualToString:@"Current Location"])
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueDot.png"]];
        pinView.centerOffset= CGPointMake(0, 0);
        [pinView addSubview:imageView];
        //[pinView setPinColor:MKPinAnnotationColorGreen];
    }
    else if ([[annotation title]isEqualToString:custName])
    {
            [pinView setPinColor:MKPinAnnotationColorGreen];
    }
    else
    {
        if([[annotation title] hasSuffix:@"-DELVADD"])
            [pinView setPinColor:MKPinAnnotationColorPurple];
        else
          [pinView setPinColor:MKPinAnnotationColorRed];
        
    }
    return pinView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];

        if([[(MKRoute *)[routesDrawn objectAtIndex:0] polyline] isEqual:route])
            routeRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.9];
        else
            routeRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        return routeRenderer;
    }
    else return nil;
}
- (void)buttonAction:(UIButton *)sender
{
   /* CustomerDeliveryAddressViewController *customerDeliveryAddressViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerDeliveryAddress"];
    customerDeliveryAddressViewController.title=@"";
    customerDeliveryAddressViewController.isFromMap=YES;
    customerDeliveryAddressViewController.strAcc_Ref=strFrom_toTitle;
    [self.navigationController pushViewController:customerDeliveryAddressViewController animated:YES];*/
    selectedCustomer = sender.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"toCustomerMapAnnotations" sender:self];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==_fromText)
        _fromCustomerAddress=nil;
        else
            _toCustomerAddress=nil;
    return NO;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)routeBtnClick:(id)sender{
    [_mapView removeOverlays:_mapView.overlays];
    if (_toText.text.length>0 && _fromText.text.length>0)
    {
        [_actviewRoute startAnimating];
        MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[_fromCustomerAddress valueForKey:@"latitude"] doubleValue], [[_fromCustomerAddress valueForKey:@"longitude"] doubleValue]) addressDictionary:nil];
        MKPlacemark *destPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([[_toCustomerAddress valueForKey:@"latitude"] doubleValue], [[_toCustomerAddress valueForKey:@"longitude"] doubleValue]) addressDictionary:nil];

//        DebugLog(@"coordiante : locationIniziale %f", sourcePlacemark.coordinate.latitude);
        MKMapItem *fromPosition = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
        MKMapItem *toPosition = [[MKMapItem alloc] initWithPlacemark:destPlacemark];

        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = fromPosition;
        request.destination = toPosition;
        request.requestsAlternateRoutes = YES;

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                DebugLog(@"Error : %@", error);
            }
            else {
                [self showDirections:response]; //response is provided by the CompletionHandler
                _tblRoute.hidden=NO;
                [_tblRoute reloadData];
                [_actviewRoute stopAnimating];
            }
        }];


//        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
//        [arrRouteDstnce_AccRef addObject:_fromText.text];
//        [arrRouteDstnce_AccRef addObject:_toText.text];
//        [self performSegueWithIdentifier:@"toRouteViewController" sender:self];
    }
    
}

- (void)showDirections:(MKDirectionsResponse *)response
{
    arrRouteDirection=[[NSMutableArray alloc] init];
    routesDrawn = response.routes;

    [routesDrawn enumerateObjectsUsingBlock:^(MKRoute * _Nonnull route, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *arrRouteInfo=[[NSMutableArray alloc] init];
        [route.steps enumerateObjectsUsingBlock:^(MKRouteStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DebugLog(@"%@ %@ %f \n",obj.instructions,obj.notice,obj.distance);
            [arrRouteInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:[obj valueForKey:@"instructions"],@"address",[obj valueForKey:@"distance"],@"distnc",nil]];
        }];
        [arrRouteDirection addObject:arrRouteInfo];
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrTemp=[arrRouteDirection objectAtIndex:0];
    return arrTemp.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSArray *arrTemp=[arrRouteDirection objectAtIndex:0];
    totalDistance=0.0;
    [arrTemp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict=[arrTemp objectAtIndex:idx];
        totalDistance +=[[dict valueForKey:@"distnc"] doubleValue];
    }];
    totalDistance=totalDistance*0.000621371;
    NSDictionary *dic = [arrTemp objectAtIndex:indexPath.row];
    if(indexPath.row==0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%.1f Miles Distance.",totalDistance];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor redColor];
    }
    else{
        double dist=[[dic objectForKey:@"distnc"] doubleValue]*0.000621371;
        cell.textLabel.text =[NSString stringWithFormat:@"Drive %.1f Miles then",dist];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
    }
    
    cell.detailTextLabel.text = [dic objectForKey:@"address"];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
    cell.detailTextLabel.numberOfLines = 3; // set the numberOfLines
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;//UILineBreakModeTailTruncation;
    cell.detailTextLabel.textColor = [UIColor blackColor];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tblHeightConstraints.constant= (_tblHeightConstraints.constant==(self.view.bounds.size.height/2)?44:self.view.bounds.size.height/2);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[_fromCustomerAddress valueForKey:@"latitude"] doubleValue], [[_fromCustomerAddress valueForKey:@"longitude"] doubleValue]);
    if (_tblHeightConstraints.constant==44)
    center.latitude -= self.mapView.region.span.latitudeDelta * 0.0;
    else
       center.latitude -= self.mapView.region.span.latitudeDelta * 0.30;
    [self.mapView setCenterCoordinate:center animated:YES];
}
-(IBAction)dragExitSlider:(UISlider *)sender
{
    [self touchup:sender];
}
-(IBAction)touchup:(id)sender
{
    [self customerOnRadiusValue];
}
-(IBAction)changeDistance:(UISlider *)sender
{
    
    _distanceMessage.alpha = 0.85;

    if([timer isValid])
    {
        [timer invalidate];
        timer = nil;
        
    }
   [self mapZoom:sender];
    CGRect frame = [_distanceMessage frame];
    
    if(frame.origin.y == 372)
        frame.origin.x = [sender value]*.12;
    else
        frame.origin.x = [sender value]*.4;
    
    if( [sender value] == 0.00)
        frame.origin.x = [sender value]+8 ;
    _distanceMessage.frame = frame;
    _distanceMessage.hidden = NO;
    _distanceMessage.text=[NSString stringWithFormat:@"%.0f Miles",[sender value]*0.621371];
    timer=  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeMessage) userInfo:nil repeats:YES];

}
-(void)mapZoom:(UISlider *)sender
{
    double sliderValue=sender.value/100;
    [_mapView setCenterCoordinate:_selectedLocationCoordinate2D zoomLevel:sliderValue animated:NO];
}
-(void)removeMessage
{
    _distanceMessage.hidden = YES;
}
-(void) customerOnRadiusValue
{
    [_mapView removeOverlays:_mapView.overlays];
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    
    NSManagedObject *selectedCustomerDetail = [fetchedData objectAtIndex:0];
    
    if([[selectedCustomerDetail valueForKey:@"latitude"] doubleValue] !=0.0 && [[selectedCustomerDetail valueForKey:@"longitude"] doubleValue]!=0)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSMutableArray *arrKeys = [[NSMutableArray alloc]init];
            int add = 0;
            double convVal = 25.4*12*3*1760/1000000;
            double pi80 = M_PI / 180;
            double lat1 =   [[selectedCustomerDetail valueForKey:@"latitude"] doubleValue] * pi80;
            double lon1 =   [[selectedCustomerDetail valueForKey:@"longitude"] doubleValue] * pi80;
            double R = 6372.797; // km default 6371
            
            for(NSManagedObject *customerDetail in fetchedData){
                if([[customerDetail valueForKey:@"latitude"] doubleValue]!=0.0 && [[customerDetail valueForKey:@"longitude"] doubleValue]!=0){
                    double lat2 = [[customerDetail valueForKey:@"latitude"] doubleValue] * pi80;
                    double lon2 = [[customerDetail valueForKey:@"longitude"] doubleValue] * pi80;
                    
                    double dLat = lat2-lat1;
                    double dLon = lon2-lon1;
                    
                    double a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
                    double c = 2 * atan2(sqrt(a), sqrt(1-a));
                    int d = R * c;
                   // DebugLog(@"dcon%f",(d* convVal));
                   // DebugLog(@"SlderVal %f",_sliderRadiusMap.value);
                    if((d* convVal) <=_sliderRadiusMap.value){
                      if (!_deviceLocation) {
                        CGFloat keyValue = (d* convVal);
                        
                        if([arrKeys containsObject:[NSString stringWithFormat:@"%f",(d* convVal)]])
                        {
                            add++;
                            keyValue = keyValue + add;
                        }
                        
                        if(keyValue == 0.0 && [[selectedCustomerDetail valueForKey:@"latitude"] doubleValue] ==[[customerDetail valueForKey:@"latitude"] doubleValue] && [[selectedCustomerDetail valueForKey:@"longitude"] doubleValue]==[[customerDetail valueForKey:@"longitude"] doubleValue] && [[selectedCustomerDetail valueForKey:@"name"] isEqualToString:[customerDetail valueForKey:@"name"]])
                        {
                            [arrKeys addObject:[NSString stringWithFormat:@"%f",(d* convVal)]];
                            [dict setObject:customerDetail forKey:[NSString stringWithFormat:@"%f",keyValue]];
                        }
                        else if(keyValue != 0.0){
                            [arrKeys addObject:[NSString stringWithFormat:@"%f",(d* convVal)]];
                            [dict setObject:customerDetail forKey:[NSString stringWithFormat:@"%f",keyValue]];
                        }
                    }
                    }
                }
            }
            
            NSArray *keys = [dict allKeys];
            
            
            NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
                return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
            }];
            for(NSString *key in sortedArray)
            {
                 NSManagedObject *customerDetail = [dict objectForKey:key];
                
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[customerDetail valueForKey:@"latitude"] doubleValue], [[customerDetail valueForKey:@"longitude"] doubleValue]);;
                PlaceMark *placemark=[[PlaceMark alloc] initWithCoordinate:coord Title:[customerDetail valueForKey:@"name"] Subtitle:[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@-%@ (%@)",[customerDetail valueForKey:@"addr1"],[customerDetail valueForKey:@"addr2"],[customerDetail valueForKey:@"addr3"],[customerDetail valueForKey:@"addr4"],[customerDetail valueForKey:@"addr5"],[customerDetail valueForKey:@"postcode"],[customerDetail valueForKey:@"delivery_address"]] ManagedObject:customerDetail Selectedbtn:selTag];
                [_mapView addAnnotation:placemark];
                
            }

               // [self dropAllpins:0];
        }
}
#pragma mark - CustomerMapAnnotationsDetailController Delegate
-(void)selectCustomerWithOption:(NSManagedObject *)custinfo Option:(NSInteger)option{
    if(option == 0)
    {
        _fromCustomerAddress = custinfo;
        _fromText.text =[_fromCustomerAddress valueForKey:@"name"];
    }
    else{
        _toCustomerAddress = custinfo;
        _toText.text = [_toCustomerAddress valueForKey:@"name"];
    }
    _routeButton.enabled=(_toText.text.length>0 && _fromText.text.length>0);
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
    if ([segue.identifier isEqualToString:@"toCustomerMapAnnotations"]) {

        CustomerMapAnnotationsDetailController *customerMapAnnotationsDetailController = segue.destinationViewController;
        customerMapAnnotationsDetailController.strFrom_toTitle=strFrom_toTitle;
        customerMapAnnotationsDetailController.strCustomerAddSubTitle=strCustomerAddSubTitle;
        customerMapAnnotationsDetailController.selectedTag=selTag;
        customerMapAnnotationsDetailController.delegate=self;
        if(selectedCustomer){
            NSArray *splittedArray = [selectedCustomer componentsSeparatedByString:@"|||"];
            if([splittedArray count]>1){
                NSArray *arrfiltered =  [[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address==%@",[splittedArray firstObject],[splittedArray lastObject]]];
                if([arrfiltered count]>0){
                    customerMapAnnotationsDetailController.customerInfo = [arrfiltered lastObject];
                    CustomerController *cvc = nil;
                    for(id vc in self.navigationController.viewControllers){
                        if([vc isKindOfClass:[CustomerController class]]){
                            cvc = vc;
                            break;
                        }
                    }
                    if(cvc)
                        customerMapAnnotationsDetailController.transdelegate = cvc;
                }
            }
        }
        [customerMapAnnotationsDetailController  performSelector:@selector(loadImage) withObject:nil afterDelay:0.0001];
    }
   else if ([segue.identifier isEqualToString:@"toRouteViewController"]) {
       RouteViewController *routeViewController= segue.destinationViewController;
       routeViewController.arrAcc_Ref_from_to_txtfield=arrRouteDstnce_AccRef;
       routeViewController.delegate=self;
   }
}

- (IBAction)swapCustomer:(id)sender {
    NSManagedObject *tempObject = _toCustomerAddress;
    _toCustomerAddress = _fromCustomerAddress;
    if(_toCustomerAddress)
        _toText.text =[_toCustomerAddress valueForKey:@"name"];
    else
        _toText.text = nil;

    _fromCustomerAddress = tempObject;
    if(_fromCustomerAddress)
        _fromText.text =[_fromCustomerAddress valueForKey:@"name"];
    else
        _fromText.text = nil;

    tempObject = nil;
}

@end
