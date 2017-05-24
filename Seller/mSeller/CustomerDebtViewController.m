//
//  CustomerDebtViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/30/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerDebtViewController.h"
#import "CustomerInfoTableViewCell.h"

@interface CustomerDebtViewController (){
    NSArray *arrRows;
}
@property(nonatomic,weak)IBOutlet UITableView *custDebtTableView;

@end

@implementation CustomerDebtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIEdgeInsets inset = _custDebtTableView.separatorInset;
    inset.left = 10;
    _custDebtTableView.separatorInset = inset;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadScrollEnable];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSString *curr = [self.customerInfo valueForKey:@"curr"];
    
    NSDictionary *dic1=[[NSDictionary alloc]initWithObjectsAndKeys:@"Credit Limit:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"credit_limit"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    
    NSDictionary *dic8=[[NSDictionary alloc]initWithObjectsAndKeys:@"Balance Due:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"total_bal"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    double remainCredit=[[self.customerInfo valueForKey:@"credit_limit"] doubleValue]-[[self.customerInfo valueForKey:@"total_bal"] doubleValue];
    NSDictionary *dic12=[[NSDictionary alloc]initWithObjectsAndKeys:@"Remaining Credit:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:remainCredit],@"Detail", nil];
    NSDictionary *dic2=[[NSDictionary alloc]initWithObjectsAndKeys:@"On Stop:",@"Value",[self.customerInfo valueForKey:@"stopflag"],@"Detail", nil];
    
    NSDictionary *dic13;
//    if ([[self.customerInfo valueForKey:@"terms"] length]>0) {
         dic13=[[NSDictionary alloc]initWithObjectsAndKeys:@"Payment Terms:",@"Value",[NSString stringWithFormat:@"%@ Days",[self.customerInfo valueForKey:@"terms"] ],@"Detail", nil];
//    }else
//        dic13=[[NSDictionary alloc]initWithObjectsAndKeys:@"Payment Terms:",@"Value",@"",@"Detail", nil];
   
    
    NSDictionary *dic4=[[NSDictionary alloc]initWithObjectsAndKeys:@"Current:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"t30days"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic5=[[NSDictionary alloc]initWithObjectsAndKeys:@"31-60 Days:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"t60days"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic6=[[NSDictionary alloc]initWithObjectsAndKeys:@"61-90 Days:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"t90days"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
                        
    NSDictionary *dic7=[[NSDictionary alloc]initWithObjectsAndKeys:@"91+ Days:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"older_bal"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic9=[[NSDictionary alloc]initWithObjectsAndKeys:@"YTD Sales:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"ytd1"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic10=[[NSDictionary alloc]initWithObjectsAndKeys:@"Last YTD Sales: ",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"lastyearsales"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    
    //arrRows=[NSArray arrayWithObjects:dic1,dic2,dic3,dic4,dic5,dic6,dic7,dic8,dic9,dic10, nil];
    arrRows=[NSArray arrayWithObjects:dic1,dic8,dic12,dic2,dic13, dic4,dic5,dic6,dic7,dic9,dic10, nil];
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0)
        return 5;
    else
        return 6;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *MheaderView=nil;
    UIView *headerView=nil;
    if (section==1){
        UILabel *lblperiod=[[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 30)];
        lblperiod.text=@"Period";
        lblperiod.textColor=SelectedTextColor;
        
        UILabel *lblbalance=[[UILabel alloc]initWithFrame:CGRectMake(190, 0, 100, 30)];
        lblbalance.text=@"Balance";
        lblbalance.textColor=SelectedTextColor;
        
        headerView= [[UIView alloc]initWithFrame:CGRectMake(0, -20, tableView.frame.size.width, 30)];
        [headerView addSubview:lblperiod];
        [headerView addSubview:lblbalance];
        headerView.backgroundColor=[UIColor colorWithRed:19/255.0 green:68/255.0 blue:143/255.0 alpha:1.0];
   
        MheaderView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        [MheaderView addSubview:headerView];
    }
    return  MheaderView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height =0.0;
    if (section==0)
        height=1.0;
    else
       height=10.01;
    return height;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"CustomerInfoTableViewCell";
    CustomerInfoTableViewCell *cell=(CustomerInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    NSInteger index1=indexPath.row+5;
    if (indexPath.section==0) {
    cell.lblFirstHeading.text =[[arrRows objectAtIndex:indexPath.row]objectForKey:@"Value"];
    cell.lblSecondHeading.text=[[arrRows objectAtIndex:indexPath.row]objectForKey:@"Detail"];
    }
    else
    {
        cell.lblFirstHeading.text =[[arrRows objectAtIndex:index1]objectForKey:@"Value"];
        cell.lblSecondHeading.text=[[arrRows objectAtIndex:index1]objectForKey:@"Detail"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
