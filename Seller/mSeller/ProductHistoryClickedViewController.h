//
//  ProductHistoryClickedViewController.h
//  mSeller
//
//  Created by Ashish Pant on 10/23/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductHistoryClickedTableViewCell.h"
#import "ProductDetailBaseController.h"

@interface ProductHistoryClickedViewController : ProductDetailBaseController

@property(nonatomic,strong)NSString  *productCode;
-(void)setProductHistoryDetail:(NSString *)productCodes;

@end
