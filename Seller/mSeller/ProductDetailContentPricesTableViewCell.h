//
//  ProductDetailContentPricesTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 10/27/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailContentPricesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblPriceCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblQty;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UIImageView *checkImg;
@end
