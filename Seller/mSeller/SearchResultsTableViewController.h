//
//  SearchResultsTableViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 2/24/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SearchResultDelegate <NSObject>

@optional
-(void)showSearchCustomerPin:(NSString *)selectedString;

@end

@interface SearchResultsTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *searchResults;
@property (weak,nonatomic) id<SearchResultDelegate> delegate;
@end
