//
//  TransactionDelivAddViewController.m
//  mSeller
//
//  Created by WCT iMac on 08/02/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "TransactionDelivAddViewController.h"
#import "TransactionDelivAddCell.h"


@interface TransactionDelivAddViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblTransactionDelAdd;
@end

@implementation TransactionDelivAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=[NSString stringWithFormat:@"%@ Breakdown",_productId];
    _tblTransactionDelAdd.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
   // _multiDeliveryAddArray=[self loadOrderLinesNew:_orderId ProductCode:_productId];
    [_tblTransactionDelAdd reloadData];
}



#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_multiDeliveryAddArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TransactionDelivAdd";
    TransactionDelivAddCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
    
}


- (void)configureCell:(TransactionDelivAddCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *record = [_multiDeliveryAddArray objectAtIndex:indexPath.row];
    cell.lblDeliveryQty.text=[NSString stringWithFormat:@"%li",(long)[[record valueForKey:@"quantity"]integerValue]];
    cell.lblDeliveryId.text=[record valueForKey:@"deliveryaddresscode"];
    cell.lblDeliveryDate.text=[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"requireddate"]];
    
}

/*-(NSArray*)loadOrderLinesNew :(NSString*) orderId ProductCode:(NSString*)productId{
    NSEntityDescription* entitySquence = [NSEntityDescription entityForName:@"OLINESNEW" inManagedObjectContext:kAppDelegate.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entitySquence];
    [fetchRequest setReturnsObjectsAsFaults:NO];
     NSMutableArray *arrSort = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
    [arrSort addObject:sortDescriptor];
    [fetchRequest setSortDescriptors:arrSort];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productid = %@  && orderid =%@ ",productId,orderId];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultsSeq = [kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return resultsSeq;
}*/


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
