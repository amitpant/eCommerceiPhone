//
//  CostAndMarginViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 4/22/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "CostAndMarginViewController.h"

@interface CostAndMarginViewController ()
{
    NSDictionary *dicMain;
    
    double orderCost;
    double margin;
    double markup;
    double orderValue;
    double profitiability;
    NSArray *arrKey;
}
@end

@implementation CostAndMarginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mainView.layer.borderColor=[UIColor grayColor].CGColor;
    _mainView.layer.borderWidth=2.0;
    _mainView.layer.cornerRadius=4.0;

    for (NSInteger i=0; i<[_arrRecords count]; i++) {
        NSManagedObject *record=[_arrRecords objectAtIndex:i];
        double priceOrdered=[[record valueForKey:@"saleprice"] doubleValue];
       // [CommonHelper convertCurrencyFromCurrencyCode:strcurr Value:priceOrdered ToCurrencyCode:@"GBP" ExchangeRate:exchrate DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] UseExchangeRate:YES];
        
        NSInteger ordQty=[[record valueForKey:@"quantity"]integerValue];
        double costPrice=[[[record valueForKey:@"product"] valueForKey:@"cost_price"] doubleValue];
        //[CommonHelper convertCurrencyFromCurrencyCode:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] Value:costPrice ToCurrencyCode:strcurr ExchangeRate:exchrate DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"] UseExchangeRate:YES];
        
        double ordval=(priceOrdered*ordQty);
        double profitability2=(priceOrdered-costPrice)*ordQty;
        double margin2=((profitability2/ordQty)/priceOrdered)*100;
        double markup2=((profitability2/ordQty)/costPrice)*100;
        profitiability+=profitability2;
        orderValue+=ordval;
        margin+=margin2;
        markup+=markup2;
    }
    
    orderCost = (orderValue-profitiability);
    margin=((orderValue-orderCost)/orderValue)*100;
    markup=((orderValue-orderCost)/orderCost)*100;

    //[CommonHelper getCurrencyFormatWithCurrency:strcurr Value:orderCost DefaultCurrency:[CompanyConfigDelegate.dicGenInfo objectForKey:@"DefaultCurrency"]];
    dicMain=[[NSDictionary alloc] initWithObjectsAndKeys:[CommonHelper getCurrencyFormatWithCurrency:_strCurr Value: orderCost],@"Order Cost:",[NSString stringWithFormat:@"%.02f %%",margin],@"Margin:",[NSString stringWithFormat:@"%.02f %%",markup],@"Mark Up:",[CommonHelper getCurrencyFormatWithCurrency:_strCurr Value: orderValue],@"Order Value:",[CommonHelper getCurrencyFormatWithCurrency:_strCurr Value: profitiability],@"Profitability:", nil];
    arrKey=[[NSArray alloc] initWithObjects:@"Order Cost:",@"Margin:",@"Mark Up:",@"Order Value:",@"Profitability:", nil];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CostAndMarginTableViewCell";
    
        CostAndMarginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[CostAndMarginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.lblCaption.text=[arrKey objectAtIndex:indexPath.row] ;
        cell.lblValue.text=[dicMain valueForKey:[arrKey objectAtIndex:indexPath.row]];

        
        return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeClicked:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
