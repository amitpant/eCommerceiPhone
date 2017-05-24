//
//  productImageIteams.m
//  mSeller
//
//  Created by WCT iMac on 06/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "productImageIteams.h"
#import "MoreImgCollCell.h"

@interface productImageIteams ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>{
    NSMutableArray *moreImageArray;
    NSArray *dirContents;
    NSString *stractualpath;
    NSArray *moreArr;
    
    NSDictionary* priceConfigDict;//   fetch price Config
    NSDictionary *userDict;//   user CompanyConfig
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *moreImageCollViewController;
- (IBAction)tapImageView:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *freeStockView;
@property (weak, nonatomic) IBOutlet UILabel *lblFreeStockValue;
@property (weak, nonatomic) IBOutlet UILabel *lblFreeStockCaption;

@end



@implementation productImageIteams


-(void)reloadConfigData{
    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
   
    //  Mahendra user CompanyConfig
    NSDictionary *dic1=[CommonHelper loadFileDataWithVirtualFilePath:UserConfigFileName];
    if(dic1 && ![[dic1 objectForKey:@"data"] isEqual:[NSNull null]])
        userDict = [dic1 objectForKey:@"data"];
    
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    
    
        _lblFreeStockValue.text=@"";
        [_freeStockView setHidden:YES];
        [_txtLongDesc setHidden:YES];
        [_lblShortDesc setHidden:YES];
    
    _txtLongDesc.text=[NSString stringWithFormat:@"%@",[_record valueForKey:@"longdesc"]];
    _lblShortDesc.text=[NSString stringWithFormat:@"%@",[_record valueForKey:@"gdescription"]];
    
    if (![[priceConfigDict valueForKey:@"IsDisplayOnImageScreen"] isEqual:[NSNull null]] && [[priceConfigDict valueForKey: @"IsDisplayOnImageScreen" ] boolValue]) {
        [_freeStockView setHidden:NO];
        
        if(![[priceConfigDict valueForKey:@"stocklabels"] isEqual:[NSNull null]]){
            NSArray *arr=[priceConfigDict valueForKey:@"stocklabels"];
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"field=='qty_free'"];
            NSArray *freeArr=[arr filteredArrayUsingPredicate:predicate];
            NSString *fileldVal=[[[freeArr lastObject] objectForKey:@"field"] lowercaseString];
            _lblFreeStockValue.text=[NSString stringWithFormat:@"%@",[_record valueForKey:fileldVal]];
        
        }
    }
    
   
    if (![[[companyConfigDict valueForKey:@"generalconfig"] valueForKey:@"showproductdesc2onimagescreen" ] isEqual:[NSNull null]] && [[[companyConfigDict valueForKey: @"generalconfig" ] valueForKey:@"showproductdesc2onimagescreen" ] boolValue]) {
        [_txtLongDesc setHidden:NO];
        [_lblShortDesc setHidden:NO];
       
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadConfigData];
    
    // Do any additional setup after loading the view.
    
    if ([[[companyConfigDict valueForKey:@"tradename"] lowercaseString] hasPrefix:@"henbrandt"]) {
        _imageName=[_imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    [_contentImageView setImageWithURL:_imageName?[NSURL fileURLWithPath:_imageName]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.scrollView.delegate = self;
    
    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];
    NSFileManager *fm = [NSFileManager defaultManager];
    dirContents = [fm contentsOfDirectoryAtPath:stractualpath error:nil];
    
    NSString* tstr = [NSString stringWithFormat:@"%@~",[[CommonHelper getStringByRemovingSpecialChars:[_record valueForKey:@"stock_code"]] lowercaseString]];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@",tstr];
    moreArr=[dirContents filteredArrayUsingPredicate:fltr];
    
    if ([moreArr count]>1) {
        NSString* tstr1 = [NSString stringWithFormat:@"%@",[[CommonHelper getStringByRemovingSpecialChars:[_record valueForKey:@"stock_code"]] lowercaseString]];
        fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@ || self BEGINSWITH %@",tstr1,tstr];
        moreImageArray=[NSMutableArray arrayWithArray:[dirContents filteredArrayUsingPredicate:fltr]];
        [_moreImageCollViewController setHidden:NO];
    }else{
        [_moreImageCollViewController setHidden:YES];
    }
    
    
    
    
    
    self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space, iOS7 (~bug?)
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([moreImageArray count]>0)
        [_moreImageCollViewController reloadData];
    
    
}


// MARK: - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return  self.contentImageView;
}


#pragma mark -
#pragma mark Content
- (void) setImageName: (NSString *) name{
    
    
    if ([[[companyConfigDict valueForKey:@"tradename"] lowercaseString] hasPrefix:@"henbrandt"]) {
        _imageName=[name stringByReplacingOccurrencesOfString:@" " withString:@""];
    }else
        _imageName=name;
        
        
        
       [_contentImageView setImageWithURL:_imageName?[NSURL fileURLWithPath:_imageName]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    return 1;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//
//    return CGSizeMake(90, 90);
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [moreImageArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"moreImgCell";
    MoreImgCollCell* collCell = (MoreImgCollCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSString *strfinalimage;
    
    if ([[[companyConfigDict valueForKey:@"tradename"] lowercaseString] hasPrefix:@"henbrandt"]) {
        _imageName=[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[[moreImageArray objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@" " withString:@""]] lowercaseString]];
        
    }else
      _imageName = [stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[moreImageArray objectAtIndex:indexPath.row]] lowercaseString]];
    
    [collCell.moreImgView setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return  collCell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strfinalimage = [stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[moreImageArray objectAtIndex:indexPath.row]] lowercaseString]];
    [self setImageName:strfinalimage];
}

- (IBAction)tapImageView:(id)sender {
    if([(UIGestureRecognizer *)sender state]==UIGestureRecognizerStateRecognized){
        
        if (self.navigationController.navigationBar.hidden == NO){
            [self hideTabBar];
            self.scrollView.zoomScale=2.0;//tap zoom in
            
        }else{
            [self showTabBar];
            self.scrollView.zoomScale=1.0;//tap zoom out
        }
    }
}

- (void)hideTabBar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *parent = tabBar.superview; // UILayoutContainerView
    UIView *content = [parent.subviews objectAtIndex:0];  // UITransitionView
    UIView *window = parent.superview;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.navigationController setNavigationBarHidden:YES animated:YES];
                         [_moreImageCollViewController setHidden:YES];
                         
                         CGRect biggerFrame = self.tabBarController.view.frame;
                         biggerFrame.size.height += self.tabBarController.tabBar.frame.size.height;
                         self.tabBarController.view.frame = biggerFrame ;
                         
                         
                         CGRect tabFrame = tabBar.frame;
                         tabFrame.origin.y = CGRectGetMaxY(window.bounds);
                         tabBar.frame = tabFrame;
                         content.frame = window.bounds;
                     }];

    
    // 1
}

- (void)showTabBar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *parent = tabBar.superview; // UILayoutContainerView
    UIView *content = [parent.subviews objectAtIndex:0];  // UITransitionView
    UIView *window = parent.superview;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         CGRect smallerFrame = self.tabBarController.view.frame;
                         smallerFrame.size.height -= self.tabBarController.tabBar.frame.size.height;
                         self.tabBarController.view.frame = smallerFrame;
                         
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                         if ([moreArr count]>0)
                             [_moreImageCollViewController setHidden:NO];
                         
                         CGRect tabFrame = tabBar.frame;
                         tabFrame.origin.y = CGRectGetMaxY(window.bounds) - CGRectGetHeight(tabBar.frame);
                         tabBar.frame = tabFrame;
                         
                         CGRect contentFrame = content.frame;
                         contentFrame.size.height -= tabFrame.size.height;
                     }];
    
    // 2
}
@end
