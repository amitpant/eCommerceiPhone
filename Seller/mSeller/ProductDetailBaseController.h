//
//  ProductDetailBaseController.h
//  mSeller
//
//  Created by Satish Kr Singh on 09/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailBaseController : UIViewController

@property NSUInteger pageIndex;
@property(nonatomic,weak)NSManagedObject *customerInfo;
@property(nonatomic,weak)NSManagedObject *transactionInfo;
@property(nonatomic,weak)NSManagedObject *oLineInfo;

@property (nonatomic,weak) NSString *selectedPrice;
@property (nonatomic,weak) NSDictionary* priceConfigDict;
@property (nonatomic,weak) NSString *selectedPack;
@end
