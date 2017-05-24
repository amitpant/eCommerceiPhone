//
//  EmailHOCell.h
//  mSeller
//
//  Created by WCT iMac on 25/02/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailHOCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *textTitlevalue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLayoutWith;
@property (weak, nonatomic) IBOutlet UISwitch *emailSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lbldivider;
@property (weak, nonatomic) IBOutlet UILabel *lblLayoutType;
@end
