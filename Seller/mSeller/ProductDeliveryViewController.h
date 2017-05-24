//
//  ProductDeliveryViewController.h
//  mSeller
//
//  Created by Mahendra Pratap Singh on 8/29/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "ProductDetailBaseController.h"
#import "CustomerDeliveryAddressViewController.h"
#import "ProductDetailBaseController.h"


@interface ProductDeliveryViewController : ProductDetailBaseController<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic)id productDetail;
@property(nonatomic,assign) NSInteger productPricesIndex;//for getting product price index

@property (strong, nonatomic) NSArray *productsDetailArray;
@property(nonatomic,assign)NSIndexPath *currentSelectedIndex;
-(void)currentPageProductDetail:(id)object;

@end
