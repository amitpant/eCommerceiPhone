//
//  ProductHistoryViewController.h
//  mSeller
//
//  Created by Ashish Pant on 10/21/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductHistoryClickedViewController.h"
#import "ProductHistoryTableViewCell.h"
#import "ProductDetailBaseController.h"

@interface ProductHistoryViewController : ProductDetailBaseController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property(strong,nonatomic)id productDetails;
-(void)setProductDetail:(id)object;
-(void)copyDone;
@end
