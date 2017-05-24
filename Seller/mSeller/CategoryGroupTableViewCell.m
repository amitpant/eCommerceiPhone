//
//  CategoryGroupTableViewCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/22/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CategoryGroupTableViewCell.h"

@implementation CategoryGroupTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _lblCategoryItemQuantity.layer.cornerRadius=7.0;
    _lblCategoryItemQuantity.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//}

@end
