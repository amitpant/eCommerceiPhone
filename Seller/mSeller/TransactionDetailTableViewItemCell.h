//
//  TransactionDetailTableViewItemCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/17/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionDetailTableViewItemCell : UITableViewCell
{
}
@property(weak,nonatomic)IBOutlet UILabel *lblProductCode;
@property(weak,nonatomic)IBOutlet UILabel *lblProductCDescription;
@property(weak,nonatomic)IBOutlet UILabel *lblDeliveryIDCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblDeliveryID;
@property(weak,nonatomic)IBOutlet UILabel *lblRequiredDateCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblDeliveryDate;
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
