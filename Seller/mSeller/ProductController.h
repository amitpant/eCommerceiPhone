//
//  ProductController.h
//  mSeller
//
//  Created by Ashish Pant on 9/14/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductTableViewCell.h"
@interface ProductController : UIViewController<UISearchBarDelegate>

@property (nonatomic,strong) NSArray *Group1Codes;
@property (nonatomic,strong) NSArray *Group2Codes;
@property (nonatomic,strong) NSArray *PromotionalCodes;

@property (nonatomic,weak) NSManagedObject *transactionInfo;
@property (nonatomic,weak) NSManagedObject *customerInfo;
@property (nonatomic,strong) NSString *selectStockCode;

@end
