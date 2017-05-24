//
//  ProductOrderPanel.h
//  mSeller
//
//  Created by WCT iMac on 30/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailBaseController.h"

@interface ProductOrderPanel : ProductDetailBaseController<UIGestureRecognizerDelegate>


@property (strong, nonatomic) NSManagedObject *record;

//- (IBAction)longPressClicked:(UILongPressGestureRecognizer *)gestureRecognizer;

@end
