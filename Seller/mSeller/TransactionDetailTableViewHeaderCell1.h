//
//  TransactionDetailTableViewHeaderCell1.h
//  mSeller
//
//  Created by Rajesh Pandey on 1/6/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionDetailTableViewHeaderCell1 : UITableViewCell
{
}
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerPhoneCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerPhone;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerEmailCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerEmail;
@property(weak,nonatomic)IBOutlet UILabel *lblContactCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblContact;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionDateCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionDate;
@property(weak,nonatomic)IBOutlet UILabel *lblCallBackDateCaption;
@property(weak,nonatomic)IBOutlet UIButton *btnCallBackDate;

@end
