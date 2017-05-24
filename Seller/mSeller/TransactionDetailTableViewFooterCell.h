//
//  TransactionDetailTableViewFooterCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/17/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TDTableFooterCellDelegate <NSObject>
@optional
-(void)Switch_click:(id)sender;
@end

@class TransactionDetailViewController;
@interface TransactionDetailTableViewFooterCell : UITableViewCell
{
    TransactionDetailViewController * m_parent;
}
@property(weak,nonatomic)IBOutlet UILabel    *lblNotesCaption;
@property(weak,nonatomic)IBOutlet UITextView *txtViewNotes;
@property(weak,nonatomic)IBOutlet UIButton   *btnNotes;
@property(weak,nonatomic)IBOutlet UILabel    *lblUnitsCaption;
@property(weak,nonatomic)IBOutlet UILabel    *lblUnits;
@property(weak,nonatomic)IBOutlet UILabel    *lblCartonsCaption;
@property(weak,nonatomic)IBOutlet UILabel    *lblCartons;
@property(weak,nonatomic)IBOutlet UILabel    *lblCBMCaption;
@property(weak,nonatomic)IBOutlet UILabel    *lblCBM;
@property(weak,nonatomic)IBOutlet UILabel    *lblLinesCaption;
@property(weak,nonatomic)IBOutlet UILabel    *lblLines;
@property(weak,nonatomic)IBOutlet UILabel    *lblDeliveryDateCaption;
@property(weak,nonatomic)IBOutlet UIButton   *btnDeliveryDate;
@property(weak,nonatomic)IBOutlet UILabel    *lblEmailFromHeadOfficeCaption;
@property(weak,nonatomic)IBOutlet UISwitch   *switchMailOption;
@property(weak,nonatomic)IBOutlet UILabel    *lblHoldOrderCaption;
@property(weak,nonatomic)IBOutlet UISwitch   *switchOrderStatus;
@property(weak,nonatomic)IBOutlet UILabel    *lblSignetureCaption;
@property(weak,nonatomic)IBOutlet UIButton   *btnSignature;

@property (weak, nonatomic) IBOutlet UIView *noteView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *holdView;
@property (weak, nonatomic) IBOutlet UIView *signatureView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UITableView *tblViewFotterBreakDown;
@property (weak, nonatomic) IBOutlet UIView *FotterbreakDownView;



- (void) setParentViewController:(TransactionDetailViewController*)parent;

@property(weak,nonatomic) id<TDTableFooterCellDelegate> delegate;

@end
