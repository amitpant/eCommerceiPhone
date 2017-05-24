//
//  ProductHistoryClickedViewController.m
//  mSeller
//
//  Created by Ashish Pant on 10/23/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductHistoryClickedViewController.h"
#import "CustomerInvoicesViewController.h"
#import "CustomerOutstandingViewController.h"

@interface ProductHistoryClickedViewController (){
    NSString *productReference;
    CustomerInvoicesViewController *customerInvoiceVC;
    CustomerOutstandingViewController *customerOutstVC;
    BOOL isViewLoaded;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentHistory;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;



@end

@implementation ProductHistoryClickedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title=_productCode;

    isViewLoaded =YES;
}
-(void)setProductHistoryDetail:(NSString *)productCodes{
    _productCode=productCodes;
     
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(isViewLoaded)
        [self performSelector:@selector(loadProductHistory) withObject:nil afterDelay:0.0 ];
    isViewLoaded = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadProductHistory{
    NSArray *ordersArray =[[[self.customerInfo valueForKeyPath:@"oheads.orderlines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code==%@",_productCode]];
    NSArray *invoicesArray =[[[self.customerInfo valueForKeyPath:@"iheads.invoicelines"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY product_code==%@",_productCode]];
    NSArray *quotesArray =  [NSArray array];//[[[self.customerInfo valueForKeyPath:@"oheadsnew.orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY productid==%@ && orderlinetype=='Q'",_productCode]];

    [_segmentHistory setEnabled:[invoicesArray count]>0 forSegmentAtIndex:0];
    [_segmentHistory setEnabled:[ordersArray count]>0 forSegmentAtIndex:1];
    [_segmentHistory setEnabled:NO forSegmentAtIndex:2];
//    [_segmentHistory setEnabled:[quotesArray count]>0 forSegmentAtIndex:2];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *invoiceTitle=[NSString stringWithFormat:@"Invoices (%lu)",(unsigned long)[invoicesArray count]];
        NSString *outstandingTitle=[NSString stringWithFormat:@"Invoices (%lu)",(unsigned long)[ordersArray count]];
        NSString *quoteTitle=[NSString stringWithFormat:@"Invoices (%lu)",(unsigned long)[quotesArray count]];
        [_segmentHistory setTitle:invoiceTitle forSegmentAtIndex:0];
        [_segmentHistory setTitle:outstandingTitle forSegmentAtIndex:1];
        [_segmentHistory setTitle:quoteTitle forSegmentAtIndex:2];
    });
    
    
    
    [self loadDataWithSegmentIndex:_segmentHistory.selectedSegmentIndex];
}

-(void)loadDataWithSegmentIndex:(NSInteger)selindex{
    if(selindex==0){
        if(customerOutstVC){
            [customerOutstVC.view removeFromSuperview];
            customerOutstVC = nil;
        }
        if(!customerInvoiceVC){
            customerInvoiceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerInvoicesViewController"];
            customerInvoiceVC.ProductCode = _productCode;
            customerInvoiceVC.customerInfo = self.customerInfo;
            customerInvoiceVC.transactionInfo=self.transactionInfo;
            [self addChildViewController:customerInvoiceVC];
            [_viewContainer addSubview:customerInvoiceVC.view];
        }
    }
    else if(selindex==1){
        if(customerInvoiceVC){
            [customerInvoiceVC.view removeFromSuperview];
            customerInvoiceVC = nil;
        }

        if(!customerOutstVC){
            customerOutstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerOutstandingViewController"];
            customerOutstVC.ProductCode = _productCode;
            customerOutstVC.customerInfo = self.customerInfo;
            customerOutstVC.transactionInfo=self.transactionInfo;
            [self addChildViewController:customerOutstVC];
            [_viewContainer addSubview:customerOutstVC.view];
        }
    }
    else{
        if(customerOutstVC){
            [customerOutstVC.view removeFromSuperview];
            customerOutstVC = nil;
        }
        if(customerInvoiceVC){
            [customerInvoiceVC.view removeFromSuperview];
            customerInvoiceVC = nil;
        }
    }
}


- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    [self loadDataWithSegmentIndex:sender.selectedSegmentIndex];
}

@end
