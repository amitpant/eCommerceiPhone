//
//  CatalogueFilterViewController.h
//  mSeller
//
//  Created by WCT iMac on 28/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CatalogueFilterViewControllerDelegate <NSObject>
-(void)finishedFilterSelectionWithValues:(NSDictionary *)values;
@end

@interface CatalogueFilterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) NSArray *selectedPromotionalCodes;
@property (nonatomic,strong) NSArray *selectedFilters;
@property (nonatomic,strong) NSArray *selectedCategory;
@property (nonatomic,strong) NSArray *selectedSubCat;
@property (nonatomic,strong) NSMutableArray *selectedStock;
@property (nonatomic,strong) NSPredicate *predicateApplied;
@property (strong,nonatomic) NSMutableDictionary* returnDictionary;
@property (nonatomic,strong) NSString *ftSelCat;
@property (nonatomic,strong) NSString *ftSelSubCat;
@property (nonatomic,strong) NSString *ftSelExgroup;
@property (nonatomic,weak)   NSManagedObject *customerInfo;
@property (nonatomic)id<CatalogueFilterViewControllerDelegate> delegate;

@end
