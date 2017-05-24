//
//  CustomerDetailInvoiceOutstandingTableViewCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 11/9/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerDetailInvoiceOutstandingTableViewCell.h"

@implementation CustomerDetailInvoiceOutstandingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if(_isColorChangeRequired){
//        if(selected)
//            self.contentView.backgroundColor =[UIColor darkGrayColor];
//        else
            self.backgroundColor = _isInvoiced?[UIColor colorWithRed:246/255.0 green:248/255.0 blue:158/255.0 alpha:1.0]:[UIColor colorWithRed:239/255.0 green:160/255.0 blue:160/255.0 alpha:1.0];
    }
}

@end
