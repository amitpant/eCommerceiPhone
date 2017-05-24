//
//  CustomerDetailInvoiceOutstandingViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 11/9/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerDetailInvoiceOutstandingTableViewCell.h"
@interface CustomerDetailInvoiceOutstandingViewController : UIViewController<NSFetchedResultsControllerDelegate>
{
}

@property(nonatomic,strong)NSString *ProductCode;
@property (strong, nonatomic) NSArray *historyItems;
@property (nonatomic,unsafe_unretained) BOOL isFromOutstandingScreen;
@property(nonatomic,weak)NSManagedObject *customerInfo;
@property(nonatomic,weak)NSManagedObject *transactionInfo;
@end
