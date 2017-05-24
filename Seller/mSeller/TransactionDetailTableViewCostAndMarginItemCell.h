//
//  TransactionDetailTableViewCostAndMarginItemCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 4/26/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionDetailTableViewCostAndMarginItemCell : UITableViewCell
{
}
@property(weak,nonatomic)IBOutlet UILabel *lblProductCode;
@property(weak,nonatomic)IBOutlet UILabel *lblProductCDescription;
@property(weak,nonatomic)IBOutlet UILabel *lblItemCostCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblItemCost;
@property(weak,nonatomic)IBOutlet UILabel *lblMarginCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblMargin;
@property(weak,nonatomic)IBOutlet UILabel *lblMarkUpCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblMarkUp;
@property(weak,nonatomic)IBOutlet UILabel *lblProfitabiltyCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblProfitabilty;
@property(weak,nonatomic)IBOutlet UILabel *lblOredrTypeCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblOrderType;
@property(weak,nonatomic)IBOutlet UILabel *lblItemQuantityCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblItemQuantity;
@property(weak,nonatomic)IBOutlet UILabel *lblPriceCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblPrice;
@property(weak,nonatomic)IBOutlet UIView  *viewItemTotal;
@property(weak,nonatomic)IBOutlet UILabel *lblItemValueCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblItemValue;
@property(weak,nonatomic)IBOutlet UIImageView *imgProductImage;
@property (weak, nonatomic) IBOutlet UIView *valueView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowWithLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end
