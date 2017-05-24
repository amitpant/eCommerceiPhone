//
//  TransactionDetailTableViewHeaderCell1.m
//  mSeller
//
//  Created by Rajesh Pandey on 1/6/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionDetailTableViewHeaderCell1.h"
#import "Constants.h"
@implementation TransactionDetailTableViewHeaderCell1

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _btnCallBackDate.layer.cornerRadius = 8;
    _btnCallBackDate.layer.borderWidth = 1;
    _btnCallBackDate.layer.borderColor = btnTitleBlueColor.CGColor;
    // Configure the view for the selected state
}

@end
