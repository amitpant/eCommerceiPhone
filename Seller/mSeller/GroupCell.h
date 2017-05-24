//
//  GroupCell.h
//  mSeller
//
//  Created by WCT iMac on 02/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;

@end
