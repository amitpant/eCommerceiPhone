//
//  ProductHistoryTableViewCell.m
//  mSeller
//
//  Created by Ashish Pant on 10/21/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductHistoryTableViewCell.h"

@implementation ProductHistoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if(selected){
        self.contentView.backgroundColor = [UIColor darkGrayColor];
        _productCode.textColor = _isInvoiced?[UIColor colorWithRed:246/255.0 green:248/255.0 blue:158/255.0 alpha:1.0]:[UIColor colorWithRed:239/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
    }
    else{
        self.backgroundColor = _isInvoiced?[UIColor colorWithRed:246/255.0 green:248/255.0 blue:158/255.0 alpha:1.0]:[UIColor colorWithRed:239/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
        _productCode.textColor = [UIColor blackColor];
    }

    _productDescription.textColor = _productCode.textColor;
    _freeCaption.textColor = _productCode.textColor;
    _freeValue.textColor = _productCode.textColor;
    _qtyCaption.textColor = _productCode.textColor;
    _qtyValue.textColor = _productCode.textColor;
    _priceCaption.textColor = _productCode.textColor;
    _priceValue.textColor = _productCode.textColor;
    _lastCaption.textColor = _productCode.textColor;
    _lastValue.textColor = _productCode.textColor;
}

@end
