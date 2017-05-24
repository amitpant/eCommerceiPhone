//
//  TransactionDetailTableViewHeaderCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/17/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionDetailTableViewHeaderCell.h"

@implementation TransactionDetailTableViewHeaderCell

- (void)awakeFromNib {
    // Initialization code
    
//    _refView.layer.cornerRadius=6.0;
//    _nameView.layer.cornerRadius=6.0;;
//    _detailView.layer.cornerRadius=6.0;;
//    _phoneView.layer.cornerRadius=6.0;;
//    _emailView.layer.cornerRadius=6.0;;
//    _contactView.layer.cornerRadius=6.0;;
//    _tranDateView.layer.cornerRadius=6.0;;
    self.detailView.layer.cornerRadius=6.0;
    
//    _txtCustomerAddress.editable=NO;
//    _txtCustomerDeliveryAddress.editable=NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==_txtFieldUserID || textField==_txtFieldCustomerRefrence)
    {
        return YES;
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     if (textField==_txtFieldUserID && range.location>3 )
     return NO;
     
     else if(textField==_txtFieldCustomerRefrence && range.location>30)
     return NO;
    return YES;
}

-(IBAction)btnClicked:(UIButton *)sender
{
    DebugLog(@"sender Tag  %ld",(long)sender.tag);
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
    
}
@end
