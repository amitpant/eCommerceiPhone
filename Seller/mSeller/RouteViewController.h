//
//  RouteViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 11/17/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegexKitLite.h"
#import <MessageUI/MessageUI.h>
@protocol RouteViewController <NSObject>
-(void) calculateRoutesFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t ArrPoints:(NSArray *)pointsArr;
@end

@interface RouteViewController : UIViewController<NSFetchedResultsControllerDelegate,MFMailComposeViewControllerDelegate>
{
    NSMutableArray *arrPoints;
}
@property(nonatomic,strong)IBOutlet UITableView *tblRoute;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObject* customerFromInfo;
@property (nonatomic, strong) NSManagedObject* customerToInfo;
@property(nonatomic,strong)NSMutableArray *arrRoutesDirection;
@property(nonatomic,strong)NSArray *arrAcc_Ref_from_to_txtfield;
@property(nonatomic,strong)NSString *strRouteDirections;

@property(nonatomic,assign)id<RouteViewController> delegate;
-(IBAction)sendMail:(UIBarButtonItem *)sender;


@end
