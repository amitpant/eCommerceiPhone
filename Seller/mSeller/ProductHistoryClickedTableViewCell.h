//
//  ProductHistoryClickedTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 10/23/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductHistoryClickedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *referenceCaption;
@property (weak, nonatomic) IBOutlet UILabel *referenceValue;
@property (weak, nonatomic) IBOutlet UILabel *dateCaption;
@property (weak, nonatomic) IBOutlet UILabel *dateValue;
@property (weak, nonatomic) IBOutlet UILabel *customerRefCaption;
@property (weak, nonatomic) IBOutlet UILabel *customerRefValue;
@property (weak, nonatomic) IBOutlet UILabel *delIDCaption;
@property (weak, nonatomic) IBOutlet UILabel *delIdValue;
@property (weak, nonatomic) IBOutlet UILabel *valueCaption;
@property (weak, nonatomic) IBOutlet UILabel *valuedetail;
@property (weak, nonatomic) IBOutlet UILabel *requiredCaption;
@property (weak, nonatomic) IBOutlet UILabel *requiredValue;

@end
