//
//  CustomerDeliveryAddressViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerDeliveryAddressTableViewCell.h"
#import "BaseContentViewController.h"
#import "MultipleDeliveryIDSelection.h"
#import "CustomerNewDeliveryAddressViewController.h"
#import "CreateTransactionDelegate.h"

@protocol CustomerDeliveryAddressViewControllerDelegate <NSObject>

@optional
-(void)finishedDeliveryDoneSelection:(NSMutableArray*)selAcc_Ref ;
@end

@interface CustomerDeliveryAddressViewController : BaseContentViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UISearchBarDelegate>
{
}
@property (nonatomic,weak) id<CustomerDeliveryAddressViewControllerDelegate> delegate;
@property (nonatomic,weak) id transdelegate;

@property(nonatomic,assign)BOOL isFromProduct;
@property(nonatomic,assign)BOOL isFromCustomer;
@property(nonatomic,assign)BOOL isFromTransaction;
@property(nonatomic,strong)NSMutableArray *myObjectOfManagedObjects;
@property(nonatomic,strong)NSMutableArray *myArrayOfManagedObjects;
@property(nonatomic,strong)NSString *selectedDeliveryAddress;


@property(nonatomic,strong)NSManagedObject *selectedCustomerDelivery;

@end
