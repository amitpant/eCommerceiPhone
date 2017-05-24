//
//  CustomerController.h
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerDetailMultipleViewController.h"
#define deg2rad(degrees) ((degrees) / 180.0*M_PI)
#define searchDistance   5.00 //float value in KM

@protocol CustomerControllerDelegate <NSObject>
-(void)finishedCustomerSelectionWithCustomerInfo:(NSManagedObject *)custinfo;
@end

@interface CustomerController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
@property (nonatomic,unsafe_unretained) BOOL isFromProductScreen;
@property (nonatomic,weak) NSManagedObject *selectedCustomerInfo;

@property(weak,nonatomic) id<CustomerControllerDelegate> delegate;
@end
