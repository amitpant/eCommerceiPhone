//
//  TransactionTableViewCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/16/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TransactionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _viewTransactionTotal.layer.borderColor=[UIColor blackColor].CGColor;
    _viewTransactionTotal.layer.borderWidth=1.0;
    _viewTransactionTotal.layer.cornerRadius=4.0;
    
    _lblitemQuantity.layer.cornerRadius=7.0;
    _lblitemQuantity.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
//    if (selected) {
//        _lblCustomerRefrenceCaption.textColor=[UIColor whiteColor];
//        _lblOrderTypeCaption.textColor=[UIColor whiteColor];
//        _lblOrderDateCaption.textColor=[UIColor whiteColor];
//        _lblDelivaryDateCaption.textColor=[UIColor whiteColor];
//        _lblTransactionRefrenceCaption.textColor=[UIColor whiteColor];
//        _lblitemQuantityCaption.textColor=[UIColor whiteColor];
//        // _viewTransactionTotal.tintColor=[UIColor whiteColor];
//        _lblTransactionValue.textColor=[UIColor blackColor];
//        _lblCustomerCode.textColor=[UIColor whiteColor];
//        _lblCustomerName.textColor=[UIColor whiteColor];
//        _lblCustomerRefrence.textColor=[UIColor whiteColor];
//        _lblOrderType.textColor=[UIColor whiteColor];
//        _lblOrderDate.textColor=[UIColor whiteColor];
//        _lblDelivaryDate.textColor=[UIColor whiteColor];
//        //_lblitemQuantity.textColor=[UIColor whiteColor];
//        _lblitemQuantity.backgroundColor=[UIColor darkGrayColor];
//        _lblTransactionValueCaption.backgroundColor=[UIColor blackColor];
//        _lblTransactionRefrence.textColor=[UIColor whiteColor];
//
////        UIView *backgroundView = [[UIView alloc] initWithFrame:self.selectedBackgroundView.frame];
////        [backgroundView setBackgroundColor:[UIColor colorWithRed:143/255.f green:141/255.f blue:147/255.f alpha:1.0]];
////        [self setSelectedBackgroundView:backgroundView];
//    }
//    else
//    {
//
//        _lblCustomerRefrenceCaption.textColor=[UIColor blackColor];
//        _lblOrderTypeCaption.textColor=[UIColor blackColor];
//        _lblOrderDateCaption.textColor=[UIColor blackColor];
//        _lblDelivaryDateCaption.textColor=[UIColor blackColor];
//        _lblTransactionRefrenceCaption.textColor=[UIColor blackColor];
//        _lblitemQuantityCaption.textColor=[UIColor blackColor];
//        // _viewTransactionTotal.tintColor=[UIColor whiteColor];
//        _lblTransactionValue.textColor=[UIColor blackColor];
//        _lblCustomerCode.textColor=[UIColor blackColor];
//        _lblCustomerName.textColor=[UIColor blackColor];
//        _lblCustomerRefrence.textColor=[UIColor blackColor];
//        _lblOrderType.textColor=[UIColor blackColor];
//        _lblOrderDate.textColor=[UIColor blackColor];
//        _lblDelivaryDate.textColor=[UIColor blackColor];
//        // _lblitemQuantity.textColor=[UIColor blackColor];
//        _lblTransactionRefrence.textColor=[UIColor blackColor];
//
////        UIView *backgroundView = [[UIView alloc] initWithFrame:self.selectedBackgroundView.frame];
////        [backgroundView setBackgroundColor:[UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1.0]];
////        [self setSelectedBackgroundView:backgroundView];
//
//    }
}


//change font color bases on OrderType
-(void)changeFontColor:(UIColor*)colorName;
{
    for (UILabel* lbl in  self.contentView.subviews)
    {
        if ([lbl isKindOfClass:[UILabel class]]) {
            if ([lbl isEqual: _lblitemQuantity])
                continue;

            lbl.textColor=colorName;
        }
    }
}


@end
