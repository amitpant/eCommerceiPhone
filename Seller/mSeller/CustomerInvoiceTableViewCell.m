//
//  CustomerInvoiceTableViewCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerInvoiceTableViewCell.h"

@implementation CustomerInvoiceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if(_isColorChangeRequired){
//        if(selected)
//            self.contentView.backgroundColor = [UIColor darkGrayColor];
//        else
           // self.backgroundColor = [UIColor colorWithRed:246/255.0 green:248/255.0 blue:158/255.0 alpha:1.0];
    }
}

@end
