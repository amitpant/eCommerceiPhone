//
//  CustomerOutstandingTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerOutstandingTableViewCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionRefCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionRef;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryDateCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionDateCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionDate;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerRefCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerRef;
@property (weak, nonatomic) IBOutlet UILabel *lblDelIDCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryID;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionValueCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionValue;

@property (unsafe_unretained,nonatomic)BOOL isColorChangeRequired;
@end
