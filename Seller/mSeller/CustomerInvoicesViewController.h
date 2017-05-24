//
//  CustomerInvoicesViewController.h
//  mSeller
//
//  Created by Ashish Pant on 9/30/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerInvoiceTableViewCell.h"
#import "BaseContentViewController.h"
#import "CustomerDetailInvoiceOutstandingViewController.h"
@interface CustomerInvoicesViewController : BaseContentViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
}

@property(nonatomic,weak)NSString *ProductCode;

@end
