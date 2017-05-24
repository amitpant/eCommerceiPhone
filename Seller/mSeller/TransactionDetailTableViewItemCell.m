//
//  TransactionDetailTableViewItemCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/17/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionDetailTableViewItemCell.h"

@implementation TransactionDetailTableViewItemCell

- (void)awakeFromNib {
    // Initialization code
    
    _lblItemQuantity.layer.cornerRadius=6.0;
    _lblItemQuantity.layer.masksToBounds = YES;
    
    _valueView.layer.borderWidth=1.0;
    _valueView.layer.borderColor=[UIColor blackColor].CGColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
