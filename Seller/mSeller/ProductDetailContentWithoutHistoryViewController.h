//
//  ProductDetailContentWithoutHistoryViewController.h
//  mSeller
//
//  Created by Ashish Pant on 10/26/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailContentWithoutHistoryTableViewCell.h"
#import "ProductDetailContentDeliveryTableViewCell.h"
#import "ProductDetailContentPricesTableViewCell.h"
#import "ProductDetailContentLastPriceCustSpecialPriceTableViewCell.h"
#import "ProductDetailContentDiscountPriceTableViewCell.h"
#import "ProductDetailContentPurchasesTableViewCell.h"
#import "CustomerDeliveryAddressViewController.h"
#import "ProductDetailBaseController.h"
#import "DatePickerViewController.h"
#import "Numerickeypad.h"

//@protocol ProductDetailContentWithoutHistoryViewControllerDelegate <NSObject>
//
//@optional
//-(void) refreshOrdPnlPrice:(NSDictionary *) arrSelectedRow;
//
//@end



@interface ProductDetailContentWithoutHistoryViewController : ProductDetailBaseController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DatePickerViewControllerDelegate,NumericKeypadDelegate>

//@property (nonatomic)id<ProductDetailContentWithoutHistoryViewControllerDelegate> delegate;


@property(strong,nonatomic)id productDetail;
@property(nonatomic,assign) NSInteger productSegmentedControlIndex;//for individual segments
@property(nonatomic,assign) NSInteger productPricesIndex;//for getting product price index
- (NSMutableArray *)loadheaderDiscount;
@end
