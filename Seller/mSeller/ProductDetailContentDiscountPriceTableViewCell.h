//
//  ProductDetailContentDiscountPriceTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 10/28/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailContentDiscountPriceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblBand;
@property (weak, nonatomic) IBOutlet UILabel *lblDisc;
@property (weak, nonatomic) IBOutlet UILabel *lblOnOrder;
@property (weak, nonatomic) IBOutlet UILabel *lblThisYear;
@property (weak, nonatomic) IBOutlet UILabel *lblLastYear;
@property (weak, nonatomic) IBOutlet UIButton *btnDiscount;
@end
