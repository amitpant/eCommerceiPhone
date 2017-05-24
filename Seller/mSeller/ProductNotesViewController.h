//
//  ProductNotesViewController.h
//  mSeller
//
//  Created by Satish Kr Singh on 27/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailBaseController.h"

@interface ProductNotesViewController : ProductDetailBaseController

@property NSUInteger pageIndex;
@property(strong,nonatomic)id productDetail;

@end
