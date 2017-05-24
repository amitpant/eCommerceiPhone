//
//  TransactionDetailTableViewFooterCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/17/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionDetailTableViewFooterCell.h"
#import "TransactionNotesViewController.h"
#import "TransactionDetailViewController.h"

@implementation TransactionDetailTableViewFooterCell

- (void)awakeFromNib {
    // Initialization code
//    _noteView.layer.cornerRadius=6.0;
//     _detailView.layer.cornerRadius=6.0;
//     _emailView.layer.cornerRadius=6.0;
//     _holdView.layer.cornerRadius=6.0;
//     _signatureView.layer.cornerRadius=6.0;
//    _txtViewNotes.layer.cornerRadius=6.0;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)btnClicked:(UIButton *)sender
{
//    UIButton *btn=(UIButton *)sender;
//    if ([[btn titleForState:UIControlStateNormal] isEqualToString:@""]) {
//        
//    }else if ([[btn titleForState:UIControlStateNormal] isEqualToString:@""]){
//        
//        
//    }
    
    
    if (sender.tag==5) {
        NSLog(@"sender.tag==5");
       // [m_parent  performSegueWithIdentifier:@"toNoteView" sender:self];
        
    }
    else if (sender.tag==6)
    {
        NSLog(@"sender.tag==6");
    }
    else if (sender.tag==7)
    {
        NSLog(@"sender.tag==7");
    }
    else
    {
    NSLog(@"sender.tag==NO");
    }
}
-(IBAction)btnSwitchClicked:(UISwitch *)sender
{
    [self.delegate Switch_click:sender];
}

- (void) setParentViewController:(TransactionDetailViewController*)parent;
{
    m_parent = parent;
    
}

@end
