//
//  ProductImageViewController.m
//  mSeller
//
//  Created by WCT iMac on 06/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductImageViewController.h"
#import "productImageIteams.h"

@interface ProductImageViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>{
    NSString *stractualpath;
    BOOL isViewLoaded;
}

@property (nonatomic, strong) UIPageViewController *ProductpageViewController;
@end

@implementation ProductImageViewController
@synthesize productArray;

- (void)viewDidLoad {
    [super viewDidLoad];

    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];

    isViewLoaded = YES;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self refreshTitle];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(isViewLoaded){
        [self createPageViewController];
        // [self setupPageControl];
        isViewLoaded = NO;
    }
}

-(void)refreshTitle{
    // code added by Satish to display current item postion of total items
    self.title = [NSString stringWithFormat:@"%i of %li",_currentSelectedIndex+1,(long)[productArray count]];
    // end of code by Satish
}


- (void) createPageViewController
{
    //productArray = @[@"nature_pic_1.jpg",  @"nature_pic_2.jpg",   @"nature_pic_3.jpg",  @"nature_pic_4.jpg"];

    self.ProductpageViewController = [self.storyboard instantiateViewControllerWithIdentifier: @"CommonPageViewController"];
    self.ProductpageViewController.dataSource = self;
    self.ProductpageViewController.delegate = self;
//    self.ProductpageViewController.view.backgroundColor=[UIColor greenColor];
    if([productArray count])
    {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: _currentSelectedIndex]];
        [self.ProductpageViewController setViewControllers: startingViewControllers
                                                 direction: UIPageViewControllerNavigationDirectionForward
                                                  animated: NO
                                                completion: nil];

    }

    self.ProductpageViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height );
    [self addChildViewController: self.ProductpageViewController];
    [self.view addSubview: self.ProductpageViewController.view];
    [self.ProductpageViewController didMoveToParentViewController: self];
}

- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor whiteColor]];
    [[UIPageControl appearance] setBackgroundColor: [UIColor darkGrayColor]];
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController
{
    if ([productArray count]==0) {
        return nil;
    }
    productImageIteams *itemController = (productImageIteams *) viewController;

    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex: itemController.itemIndex-1];
    }

    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController
{
    if ([productArray count]==0) {
        return nil;
    }

    productImageIteams *itemController = (productImageIteams *) viewController;

    if (itemController.itemIndex+1 < [productArray count])
    {
        return [self itemControllerForIndex: itemController.itemIndex+1];
    }

    return nil;
}

- (productImageIteams *) itemControllerForIndex: (NSUInteger) itemIndex
{
    if ([productArray count]==0) {
        return nil;
    }

    if (itemIndex < [productArray count])
    {
        NSManagedObject *record=productArray[itemIndex];
        NSString *strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[record valueForKey:@"stock_code"]] lowercaseString]] stringByAppendingString:@".jpg"];

        productImageIteams *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"productImageIteams"];
        pageItemController.record=record;
        pageItemController.itemIndex = itemIndex;
        pageItemController.imageName = strfinalimage;
        return pageItemController;
    }

    return nil;
}

#pragma mark - UIPageViewController Delegate
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if(completed){
        _currentSelectedIndex =  ((productImageIteams*) [pageViewController.viewControllers lastObject]).itemIndex;
        [self refreshTitle];
    }
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

@end
