//
//  ProductDetailContentPurchasesTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 10/30/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailContentPurchasesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *purOrderRefValue;
@property (weak, nonatomic) IBOutlet UILabel *expectedDateValue;
@property (weak, nonatomic) IBOutlet UILabel *quantityValue;
@property (weak, nonatomic) IBOutlet UILabel *shippedValue;

@end
