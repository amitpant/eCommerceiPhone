//
//  CategoryGroupTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/22/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryGroupTableViewCell : UITableViewCell
{
}
@property(weak,nonatomic)IBOutlet UIImageView *imgViewCategoryGroup;
@property(weak,nonatomic)IBOutlet UILabel *lblCategoryName;
@property(weak,nonatomic)IBOutlet UILabel *lblCategoryItemQuantityCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblCategoryItemQuantity;

@end
