//
//  AddNewCustomerMultipleOptionViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/13/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AddNewCustomerMultipleOptionViewController <NSObject>
-(void)selectedIndexValue:(NSString *)selectedValue Option:(NSInteger)option;
@end

@interface AddNewCustomerMultipleOptionViewController : UIViewController<NSFetchedResultsControllerDelegate>
{
}
@property(weak,nonatomic)IBOutlet UITableView *tblMain;
@property(nonatomic,unsafe_unretained) NSInteger selectedOption;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,assign)id<AddNewCustomerMultipleOptionViewController> delegate;
@end
