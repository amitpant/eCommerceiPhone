//
//  CustomerInvoiceTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerInvoiceTableViewCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionRefCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionRef;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionDateCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionValueCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionValue;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerRefCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerRef;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryIDCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryID;

@property (unsafe_unretained,nonatomic)BOOL isColorChangeRequired;
@end
