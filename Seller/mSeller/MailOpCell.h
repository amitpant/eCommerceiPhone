//
//  mailOpCell.h
//  mSeller
//
//  Created by Amit Pant on 3/15/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailOpCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbltitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightLayoutConstraint;

@end
