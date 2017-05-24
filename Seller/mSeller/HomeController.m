//
//  HomeController.m
//  mSeller
//
//  Created by Apple on 09/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "HomeController.h"

@interface HomeController ()<UITabBarControllerDelegate>{
    NSInteger selectedTabIndex;
}

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    // Do any additional setup after loading the view.
    [kNSNotificationCenter addObserver:kAppDelegate selector:@selector(reloadConfigurationData) name:UIApplicationDidBecomeActiveNotification object:nil];


    [kNSNotificationCenter addObserver:self selector:@selector(redirectToLoginIfUserInvalid) name:kRedirectToLogin object:nil];

    [kNSNotificationCenter addObserver:self selector:@selector(refreshTabItems) name:kRefreshTabItems object:nil];

    [kNSNotificationCenter addObserver:self selector:@selector(setAllTabToRootViewController) name:kRedirectToRootViewController object:nil];

    [self refreshTabItems];
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

#pragma mark - Custom Methods
-(void)redirectToLoginIfUserInvalid{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshTabItems{
    NSArray *arrItems =  self.tabBar.items;
    NSManagedObjectContext *context = kAppDelegate.managedObjectContext;

    // enable/disable catalogs tab based on data
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GROUP1CODES" inManagedObjectContext:context];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];

    NSError *err = nil;
    NSArray *results = [context executeFetchRequest:fetch error:&err];

    UITabBarItem *item = [arrItems objectAtIndex:1];
    item.enabled = [results count]>0;

    if([results count]==0 && selectedTabIndex==1)
        [self setSelectedIndex:0];

    // enable/disable catalogs tab based on data
    entity = [NSEntityDescription entityForName:@"CUST" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];

    results = [context executeFetchRequest:fetch error:&err];

    item = [arrItems objectAtIndex:2];
    item.enabled = [results count]>0;

    if([results count]==0 && selectedTabIndex==2)
        [self setSelectedIndex:0];

    // enable/disable catalogs tab based on data
    entity = [NSEntityDescription entityForName:@"OHEADNEW" inManagedObjectContext:context];
    fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:entity];

    results = [context executeFetchRequest:fetch error:&err];

    item = [arrItems objectAtIndex:3];
    item.enabled = [results count]>0;

    if([results count]==0 && selectedTabIndex==3)
        [self setSelectedIndex:0];
}

-(void)setAllTabToRootViewController{
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UINavigationController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj popToRootViewControllerAnimated:NO];
    }];
}

#pragma mark - UITabBar delegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInteger:item.tag] ]  forKeys:@[@"SelectedIndex"]];
    
    [kNSNotificationCenter postNotificationName:kLoadOtherTabController object:self userInfo:dict];
   // DebugLog(@"item %@",item);
   // DebugLog(@"didSelectItem: %d", item.tag);
    if(item.tag==3)
        kAppDelegate.transactionTabClick=YES;

    selectedTabIndex = item.tag;
}

#pragma mark -
#pragma mark UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)vc {
    UIViewController *tbSelectedController = tbc.selectedViewController;

    if ([tbSelectedController isEqual:vc]) {
        return NO;
    }

    return YES;
}

@end
