//
//  ProductDetailContentViewController.h
//  mSeller
//
//  Created by Ashish Pant on 10/16/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailContentWithoutHistoryViewController.h"
#import "ProductDetailBaseController.h"

@interface ProductDetailContentViewController : ProductDetailBaseController<UIPageViewControllerDataSource>

@property(nonatomic,assign) NSInteger segmentedControlIndex;

@property(strong,nonatomic)id productDetail;
@property (strong, nonatomic) NSArray *productsDetailArray;
@property(nonatomic,assign)NSIndexPath *currentSelectedIndex;

-(void)currentPageProductDetail:(id)object;
- (NSManagedObject *)find_OrderObject;
@end
