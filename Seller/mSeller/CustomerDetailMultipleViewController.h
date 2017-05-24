//
//  CustomerDetailMultipleViewController.h
//  mSeller
//
//  Created by Ashish Pant on 9/29/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateTransactionDelegate.h"
@interface CustomerDetailMultipleViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property(strong,nonatomic)id customerInfo;
@property(strong,nonatomic)id transactionInfo;
@property(nonatomic,assign)BOOL HideCreateTransactions;
@property (weak,nonatomic) id transdelegate;

@end
