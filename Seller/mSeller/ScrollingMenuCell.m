//
//  ScrollingMenuCell.m
//  mSeller
//
//  Created by Satish Kr Singh on 27/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ScrollingMenuCell.h"

@implementation ScrollingMenuCell

-(void)setSelected:(BOOL)selected{
    if(selected){
        self.backgroundColor = SelectedBackgroundColor;
        _lblCaption.textColor = SelectedTextColor;
    }
    else{
        self.backgroundColor = SelectedTextColor;
        _lblCaption.textColor = SelectedBackgroundColor;
    }
}
@end
