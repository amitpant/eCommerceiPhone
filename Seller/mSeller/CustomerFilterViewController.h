//
//  CustomerFilterViewController.h
//  mSeller
//
//  Created by Ashish Pant on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerController.h"

@protocol CustomerFilterViewControllerDelegate <NSObject>
@optional
-(void)finishedFilterSelectionWithOption:(NSInteger)seloption SelectedDate:(NSDate *)seldate ArrHistory:(NSArray*)arrHistory;
@end

@interface CustomerFilterViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
    
}
@property(nonatomic,weak)IBOutlet UITableView *filterTableView;
@property (nonatomic,strong) NSArray* arrFilterRows;

@property(nonatomic,unsafe_unretained) NSInteger selectedOption;
@property(nonatomic,strong) NSDate *selectedDate;
//@property(nonatomic,strong)NSFetchedResultsController *fetchedResultsController;
@property(weak,nonatomic) id<CustomerFilterViewControllerDelegate> delegate;
@end
