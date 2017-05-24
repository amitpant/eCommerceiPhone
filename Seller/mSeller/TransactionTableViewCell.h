//
//  TransactionTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/16/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionTableViewCell : UITableViewCell
{

}
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerRefrenceCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblOrderTypeCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblOrderDateCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblDelivaryDateCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionRefrenceCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblitemQuantityCaption;
@property(weak,nonatomic)IBOutlet UIView  *viewTransactionTotal;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionValueCaption;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionValue;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerCode;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerName;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerRefrence;
@property(weak,nonatomic)IBOutlet UILabel *lblOrderType;
@property(weak,nonatomic)IBOutlet UILabel *lblOrderDate;
@property(weak,nonatomic)IBOutlet UILabel *lblDelivaryDate;
@property(weak,nonatomic)IBOutlet UILabel *lblTransactionRefrence;
@property(weak,nonatomic)IBOutlet UILabel *lblitemQuantity;
@property(weak,nonatomic)IBOutlet UIImageView *imgTransactionStatus;

-(void)changeFontColor:(UIColor*)colorName;
@end
