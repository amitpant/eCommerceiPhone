//
//  ProductImageViewController.h
//  mSeller
//
//  Created by WCT iMac on 06/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailBaseController.h"

@interface ProductImageViewController : ProductDetailBaseController

@property (strong,nonatomic) NSArray* productArray;
@property (unsafe_unretained,nonatomic) NSInteger currentSelectedIndex;
- (void) createPageViewController;
@end
