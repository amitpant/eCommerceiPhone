//
//  CustomerDeliveryAddressTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/15/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerDeliveryAddressTableViewCell : UITableViewCell
{
}

@property (weak, nonatomic) IBOutlet UILabel *lblDeliveryAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerTown;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerPostCode;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;


@end
