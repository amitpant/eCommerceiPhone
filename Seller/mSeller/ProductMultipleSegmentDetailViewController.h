//
//  ProductMultipleSegmentDetailViewController.h
//  mSeller
//
//  Created by Ashish Pant on 10/16/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailContentViewController.h"
#import "ProductHistoryViewController.h"
#import "ProductDetailBaseController.h"
#import "ProductDeliveryViewController.h"


@interface ProductMultipleSegmentDetailViewController : ProductDetailBaseController<UIPageViewControllerDataSource>


@property (strong, nonatomic) UIPageViewController *pageViewController;
-(void)setSelectectIndex:(NSInteger)indexValue totalProductsFetched:(NSArray*)totalProductsArray;
- (IBAction)segmentChanged:(id)sender;
@end
