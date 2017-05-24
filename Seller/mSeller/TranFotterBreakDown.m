//
//  TranFotterBreakDown.m
//  mSeller
//
//  Created by Mahendra Pratap Singh on 9/27/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "TranFotterBreakDown.h"
#import "TransactionFotterBreakDownCell.h"
#import "DatePickerViewController.h"



@interface TranFotterBreakDown ()<UITableViewDelegate,UITableViewDataSource,DatePickerViewControllerDelegate,UIGestureRecognizerDelegate,CAAnimationDelegate>{
    
    NSArray *array;
    NSArray *array2;
    NSArray *array3;
    NSDictionary *featureDict;
    NSDictionary *pricingConfigDict;
    
    int pageControlIndex;
    int selectedDateOption;
    
    NSMutableArray *arrTransactionRows;
    NSInteger totalUnits;
    NSInteger totalCartons;
    NSInteger totalLines;
    double totalCbm;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lblTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tblFotterBreakDown;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *arrValue;
@end

@implementation TranFotterBreakDown
@synthesize strNow,strFuture,strTotal;
@synthesize txtsearch,orderNumber,isEditing;
@synthesize Headrecorddata;



-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];
    
    
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]]){
        pricingConfigDict = [dic objectForKey:@"data"];
        
    }
    
   
    
   /* if ([featureDict valueForKey:@"displaysplitordersummaryenabled"]!=Nil && [[featureDict valueForKey:@"displaysplitordersummaryenabled"] boolValue]){
        
        _pageControl.numberOfPages=3;
    }else{
        _pageControl.numberOfPages=1;
    }*/
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadConfigData];
    array=@[@"Units:",@"Cartons:",@"CBM:",@"Lines",@"Del Date:"];//,@"Invoice Date:"];
    array2=@[@"Units:",@"Cartons:",@"CBM:",@"Lines"];
    
    
    
  //  _arrValue=[strValue componentsSeparatedByString:@"|"];

//Left Swipe
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
//Right Swipe
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    [self reloadTitle];
}



-(void)reloadTitle{
    
 NSString *str=   [self loadTransactionInfo];
    
    if (pageControlIndex==0) {
        _lblTitleLabel.text=@"Total";
       _arrValue=[str componentsSeparatedByString:@"|"];
    }else if (pageControlIndex==1) {
        _lblTitleLabel.text=@"Now";
        _arrValue=[str componentsSeparatedByString:@"|"];
    }else if (pageControlIndex==2) {
        _lblTitleLabel.text=@"Future";
        _arrValue=[str componentsSeparatedByString:@"|"];
    }
   
    _pageControl.currentPage=pageControlIndex;
}


#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (pageControlIndex==0)
        return [array count];
    else
         return 4;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TransactionFotterBreakDownCell";
    TransactionFotterBreakDownCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



- (void)configureCell:(TransactionFotterBreakDownCell *)cell atIndexPath:(NSIndexPath *)indexPath {
   
    cell.lblTitle.text=[array objectAtIndex:indexPath.row ];
    if ( [_arrValue count]>0 && [_arrValue count]>indexPath.row){
        cell.lblDescription.text=[_arrValue objectAtIndex:indexPath.row ];
    if ([[array objectAtIndex:indexPath.row ] isEqualToString:@"Del Date:"] && isEditing) {
        cell.btnDescription.enabled=YES;
        cell.btnDescription.userInteractionEnabled=YES;
        [cell.btnDescription addTarget:self action:@selector(getDate:) forControlEvents:UIControlEventTouchUpInside];
        cell.lblDescription.textColor=btnBlueColor;
    }else{
        cell.btnDescription.enabled=NO;
        cell.btnDescription.userInteractionEnabled=NO;
        //cell.btnDescription.hidden=YES;
        cell.lblDescription.textColor=[UIColor grayColor];
    }
   
    
    }
    else
        cell.lblDescription.text=@"";
    
}





-(IBAction)getDate:(UIButton *)sender
{
    /*if([sender tag]==4){
        DatePickerViewController *datePickerViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
        datePickerViewController.selectedDate=[Headrecorddata valueForKey:@"required_bydate"];
        datePickerViewController.title=@"Delivery date";
        datePickerViewController.isCallBack=YES;
        
        selectedDateOption = 1;
        datePickerViewController.isDateRange=NO;
        datePickerViewController.delegate=self;
        [self.navigationController pushViewController: datePickerViewController animated:YES];
        
    }else if([sender tag]==5){*/
        
    DatePickerViewController *datePickerViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
    datePickerViewController.selectedDate=[Headrecorddata valueForKey:@"required_bydate"];
    datePickerViewController.title=@"Delivery date";
    datePickerViewController.isCallBack=YES;
    selectedDateOption = 1;
    
    datePickerViewController.isDateRange=NO;
    datePickerViewController.delegate=self;
    [self.navigationController pushViewController: datePickerViewController animated:YES];
    //}
    
}




#pragma mark - CustomDatePickerViewController Delegate
-(void)finishedSelectionWithDate:(NSDate *)seldate{
    if(selectedDateOption==0)
        [Headrecorddata setValue:seldate forKey:@"nextcall_date"];
    else
        [Headrecorddata setValue:seldate forKey:@"required_bydate"];
    
    NSError *error;
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
    [_tblFotterBreakDown reloadData];
}

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (pageControlIndex<_pageControl.numberOfPages-1 ){
        pageControlIndex++;
    
    //[self loadTransactionInfo];
   
        CATransition *transition = [CATransition animation];
    transition.duration = 0.45;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
        
    }
    
    
    DebugLog(@"pageControlIndex %i",pageControlIndex);
    //Do what you want here
    [self reloadTitle];
    [_tblFotterBreakDown reloadData];
    
    
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (pageControlIndex>0){
        pageControlIndex--;
    
       // [self loadTransactionInfo];
        
    CATransition *transition = [CATransition animation];
    transition.duration = 0.45;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
        
    }
    
    DebugLog(@"pageControlIndex %i",pageControlIndex);
    //Do what you want here
    [self reloadTitle];
    [_tblFotterBreakDown reloadData];
}

-(NSString*)loadTransactionInfo{
    [self loadTransactionItems];
    
    totalCartons=0;
    totalCbm=0.0;
    
    
    totalUnits = [[arrTransactionRows valueForKeyPath:@"@sum.quantity"] integerValue];
    totalLines = [[arrTransactionRows valueForKeyPath:@"linetotal"] count];
    
    [arrTransactionRows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *record=[arrTransactionRows objectAtIndex:idx];
        NSManagedObject *mObj=[record valueForKey:@"Arrays"];
        NSInteger ctns = [[record valueForKey:@"quantity"] integerValue]/[[[mObj valueForKey:@"line_outer"] objectAtIndex:0] integerValue];
        totalCartons += ctns;
        totalCbm += ctns *[[[record valueForKey:@"product"] valueForKey:@"prd_carton_cbm"]doubleValue];
    }];

    
    NSString *strValue=[NSString stringWithFormat:@"%@|%@|%@|%@|%@",[NSString stringWithFormat:@"%ld",(long)totalUnits],[NSString stringWithFormat:@"%ld",(long)totalCartons],[NSString stringWithFormat:@"%0.2f",totalCbm],[NSString stringWithFormat:@"%li",(long)totalLines],[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[Headrecorddata valueForKey:@"required_bydate"]]];

    return strValue;
    
}

-(void)loadTransactionItems{
    
    arrTransactionRows =[[NSMutableArray alloc]init];
    NSArray *tempArray=nil;
    NSPredicate *filterPredicate;
   
    NSString *stockQty=@"";
    if(![[pricingConfigDict objectForKey:@"usefieldtodefineoutofstock"] isEqual:[NSNull null]])
        stockQty=[pricingConfigDict objectForKey:@"usefieldtodefineoutofstock"];
    
    
    if ([txtsearch length] == 0){
        
         if (pageControlIndex==1 && [stockQty length]>0)
            filterPredicate = [NSPredicate predicateWithFormat:@"(product.%@ > %i) and (orderid = %@)",stockQty,0,orderNumber];
        else if (pageControlIndex==2 && [stockQty length]>0)
            filterPredicate = [NSPredicate predicateWithFormat:@"(product.%@ <= %i) and (orderid = %@)",stockQty,0,orderNumber];
        else
            filterPredicate = [NSPredicate predicateWithFormat:@"(orderid = %@)",orderNumber];
            
            
        tempArray = [[[Headrecorddata valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:filterPredicate];
    
    }else{
        
        if (pageControlIndex==0)
            filterPredicate = [NSPredicate predicateWithFormat:@"(productid CONTAINS %@ || product.gdescription CONTAINS %@) and (orderid = %@)",txtsearch, txtsearch,orderNumber];
        else if (pageControlIndex==1)
            filterPredicate = [NSPredicate predicateWithFormat:@"(productid CONTAINS %@ || product.gdescription CONTAINS %@) and (product.%@ > %i)and (orderid = %@)",txtsearch, txtsearch,stockQty,0,orderNumber];
        else if (pageControlIndex==2)
            filterPredicate = [NSPredicate predicateWithFormat:@"(productid CONTAINS %@ || product.gdescription CONTAINS %@)and (product.%@ <= %i) and (orderid = %@)",txtsearch, txtsearch,stockQty,0,orderNumber];
        
        tempArray = [[[Headrecorddata valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:filterPredicate];
    }
    
    
    
    NSMutableArray *iLineArray=[[NSMutableArray alloc]init];
    
    NSArray *distinctOlines = [tempArray valueForKeyPath:@"@distinctUnionOfObjects.productid"];
    for(NSString *pIdAsString in distinctOlines)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(productid == %@)", pIdAsString];
        NSArray *arrayofPid = [tempArray  filteredArrayUsingPredicate: predicate];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"productid"] forKey:@"productid"];
        if ([arrayofPid count]>1) {
            [dict setValue:@"Multiple" forKey:@"deliveryaddresscode"];
        }else
            [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"deliveryaddresscode"] forKey:@"deliveryaddresscode"];
        
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"saleprice"] forKey:@"saleprice"];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"orderlinetype"] forKey:@"orderlinetype"];
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"requireddate"] forKey:@"requireddate"];
        
        [dict setValue:[[arrayofPid objectAtIndex:0] valueForKey:@"product"] forKey:@"product"];
        
        [dict setValue:[arrayofPid valueForKeyPath:@"@sum.quantity"] forKey:@"quantity"];
        [dict setValue:[arrayofPid valueForKeyPath:@"@sum.linetotal"] forKey:@"linetotal"];
        
        
        [dict setObject:[NSNumber numberWithInteger:[arrayofPid count]] forKey:@"Count"];
        [dict setObject:arrayofPid forKey:@"Arrays"];
        
        
        [ iLineArray addObject:dict];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"requireddate"   ascending:NO] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    arrTransactionRows =[NSMutableArray arrayWithArray: [iLineArray sortedArrayUsingDescriptors:sortDescriptors]];
    
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
