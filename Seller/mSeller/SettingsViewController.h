//
//  SettingsViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/11/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblSetting1;

@property (weak, nonatomic) IBOutlet UISearchBar *settingSearchBar;

@end
