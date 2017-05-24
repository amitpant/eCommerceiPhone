//
//  TransactionDetailViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/14/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionDetailTableViewHeaderCell.h"
#import "TransactionDetailTableViewItemCell.h"
#import "TransactionDetailTableViewFooterCell.h"
#import "TransactionNotesViewController.h"
#import "CustomDatePickerViewController.h"
#import "CustomerDeliveryAddressViewController.h"
#import "DatePickerViewController.h"
#import "TransactionDetailTableViewHeaderCell1.h"
#import "CostAndMarginViewController.h"
#import "TransactionDetailTableViewCostAndMarginItemCell.h"
#import "CostAndMarginTableViewCell.h"
@interface TransactionDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,CustomerDeliveryAddressViewControllerDelegate,CustomerNewDeliveryAddressDelegate,DatePickerViewControllerDelegate>
{
    
}
@property(weak,nonatomic)IBOutlet UIBarButtonItem *btnCancel;
@property(weak,nonatomic)IBOutlet UIBarButtonItem *btnSave;
@property(weak,nonatomic)IBOutlet UITableView *tblTransactionDetail;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
//@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,readwrite) NSInteger OheadCount;
@property (nonatomic,unsafe_unretained) BOOL isEditing;
@property (nonatomic,unsafe_unretained) BOOL isFirstTimeTransaction;

@property (nonatomic,strong) NSString *orderNumber;
@property (nonatomic,strong) NSManagedObject *Headrecorddata;
@property (weak, nonatomic) IBOutlet UISearchBar *tranDetailSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchHeightConstraints;
@property (weak, nonatomic) IBOutlet UILabel *lblTransactionTotal;
@property (weak, nonatomic) IBOutlet UIView *viewTransactionTotal;
@property(nonatomic,strong)IBOutlet UILabel *lblUnits;
@property(nonatomic,strong)IBOutlet UILabel *lblCartons;
@property(nonatomic,strong)IBOutlet UILabel *lblCBM;
@property(nonatomic,strong)IBOutlet UILabel *lblLines;
@property(nonatomic,strong)IBOutlet UIButton *btnDeliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *lblCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;


@end
