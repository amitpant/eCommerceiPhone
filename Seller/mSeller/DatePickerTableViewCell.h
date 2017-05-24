//
//  DatePickerTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 1/7/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerTableViewCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerTo;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedDateTo;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectDate;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectedDateTo;

@end
