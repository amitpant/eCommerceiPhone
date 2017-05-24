//
//  TeamTalkTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 11/24/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTalkTableViewCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileData;
@property (weak, nonatomic) IBOutlet UITextView *txtViewSalesMessage;

@end
