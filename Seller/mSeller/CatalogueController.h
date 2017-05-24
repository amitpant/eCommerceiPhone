//
//  CatalogueController.h
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryGroupTableViewCell.h"
#import "ProductController.h"
@interface CatalogueController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSManagedObject *selectedGroup1;
@property (strong, nonatomic) NSMutableArray *selectedGroup1Array;
@end
