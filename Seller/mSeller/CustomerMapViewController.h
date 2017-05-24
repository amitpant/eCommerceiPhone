//
//  CustomerMapViewController.h
//  mSeller
//
//  Created by Ashish Pant on 9/16/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "PlaceMark.h"
#import "CustomerDeliveryAddressViewController.h"
#import "CustomerMapAnnotationsDetailController.h"
#import "CreateTransactionDelegate.h"

@interface CustomerMapViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate,NSFetchedResultsControllerDelegate,CustomerMapAnnotationsDetailController>{
    // the rect that bounds the loaded points
    MKMapRect _routeRect;
    NSArray* routes;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actviewRoute;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblHeightConstraints;
@property (weak, nonatomic) IBOutlet UITableView *tblRoute;
@property(nonatomic,weak)IBOutlet UITextField *fromText;
@property(nonatomic,weak)IBOutlet UITextField *toText;
@property(nonatomic,weak)IBOutlet UIButton *routeButton;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPolyline *routeLine;
@property (nonatomic, strong) MKPolylineRenderer *routeLineView;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) IBOutlet UISlider *sliderRadiusMap;

@property (strong,nonatomic) CLLocation *deviceLocation;

@property(strong,nonatomic) NSManagedObject *customerInfo;
@property(weak,nonatomic) id transdelegate;

@property (nonatomic, weak) NSManagedObject *fromCustomerAddress;
@property (nonatomic, weak) NSManagedObject *toCustomerAddress;
@property (weak, nonatomic) IBOutlet UITextView *distanceMessage;
-(IBAction)routeBtnClick:(id)sender;
-(IBAction)dragExitSlider:(UISlider *)sender;
-(IBAction)touchup:(id)sender;
-(IBAction)changeDistance:(UISlider *)sender;
@property(nonatomic,assign)BOOL isFromCustDetail;
// use the computed _routeRect to zoom in on the route.
//-(void) zoomInOnRoute;


@end
