//
//  CustomerMapAnnotationsDetailController.h
//  mSeller
//
//  Created by Ashish Pant on 9/16/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "CreateTransactionDelegate.h"
#import "StreetImageViewController.h"
@protocol CustomerMapAnnotationsDetailController <NSObject>
-(void) selectCustomerWithOption:(NSManagedObject *)custinfo Option:(NSInteger)option;
@end

@interface CustomerMapAnnotationsDetailController : UIViewController<NSFetchedResultsControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{

}
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(weak,nonatomic)IBOutlet UIButton *btnDirectionsTo;
@property(weak,nonatomic)IBOutlet UIButton *btnDirectionsFrom;
@property(weak,nonatomic)IBOutlet UIButton *btnShowCustomer;
@property(weak,nonatomic)IBOutlet UIButton *btnAddToContact;
@property(weak,nonatomic)IBOutlet UITextView *txtViewAddress;
@property(weak,nonatomic)IBOutlet UILabel *lblCustomerCode_Name;
@property(nonatomic,strong)NSString *strFrom_toTitle;
@property(nonatomic,strong)NSString *strCustomerAddSubTitle;
@property (weak, nonatomic) IBOutlet UIImageView *streetImageView;
@property (nonatomic,unsafe_unretained) NSInteger selectedTag;

@property(strong,nonatomic) NSManagedObject *customerInfo;
@property(weak,nonatomic) id transdelegate;

@property(nonatomic,assign)id<CustomerMapAnnotationsDetailController> delegate;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollImageView;
-(IBAction)btnActionDirectionTo_From_ShowCustomer_AddToContact:(UIButton *)sender;
-(void)loadImage;
@end
