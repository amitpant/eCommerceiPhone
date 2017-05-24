//
//  CustomerOutstandingViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerOutstandingTableViewCell.h"
#import "BaseContentViewController.h"
#import "CustomerDetailInvoiceOutstandingViewController.h"
@interface CustomerOutstandingViewController : BaseContentViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
}

@property(nonatomic,weak)NSString *ProductCode;
@end
