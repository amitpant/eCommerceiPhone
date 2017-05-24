//
//  TransactionDetailTableViewHeaderCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/17/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionDetailTableViewHeaderCell : UITableViewCell<UITextViewDelegate>
{

}
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionRefrenceCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionRefrence;
@property(weak,nonatomic)IBOutlet UILabel *lblUserIDCaption;
@property(weak,nonatomic)IBOutlet UITextField *txtFieldUserID;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerCodeCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerCode;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerNameCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerName;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerRefrenceCaption;
@property(weak,nonatomic)IBOutlet UITextField *txtFieldCustomerRefrence;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerAddressCaption;
@property(weak,nonatomic)IBOutlet UITextView *txtCustomerAddress;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerDeliveryAddressCaption;
@property(weak,nonatomic)IBOutlet UITextView *txtCustomerDeliveryAddress;
@property(weak,nonatomic)IBOutlet UILabel *lblDeliveryIDCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblDeliveryID;
@property(weak,nonatomic)IBOutlet UIButton *btnDeliveryID;
@property(weak,nonatomic)IBOutlet UIButton *btnDeliveryAddressSearch;
@property(weak,nonatomic)IBOutlet UILabel *lblOrderType;
@property(weak,nonatomic)IBOutlet UIButton *btnOrderType;



@property (weak, nonatomic) IBOutlet UIView *refView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIView *tranDateView;
@end
