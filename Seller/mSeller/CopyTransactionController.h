//
//  CopyTransactionController.h
//  mSeller
//
//  Created by WCT iMac on 18/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CopyTransactionTableViewCell.h"

@interface CopyTransactionController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblCopyTransaction;

@property (weak, nonatomic) IBOutlet UIView *custNameView;
@property (weak, nonatomic) IBOutlet UIView *custDetailView;
@property (strong, nonatomic) NSManagedObject* TransactionObj;
//@property (strong, nonatomic) NSString* orderNo;

- (IBAction)select_Customer:(id)sender;
- (IBAction)Done_clicked:(id)sender;
- (IBAction)Cancel_clicked:(id)sender;

@end
