//
//  ProductDeliveryViewController.m
//  mSeller
//
//  Created by Mahendra Pratap Singh on 8/29/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import "ProductDeliveryViewController.h"
#import "ProductDetailContentDeliveryTableViewCell.h"
#import "ProductDetailContentDeliveryTableViewCell.h"
#import "globalObject.h"

@interface ProductDeliveryViewController ()<CustomerDeliveryAddressViewControllerDelegate>{
    NSDictionary* priceConfigDict;//   fetch feature
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary* userDict;
    NSString *selectedDeliveryAddress;
    
    NSDate *selectedDate;
    NSString *strSelectedQty;
    NSDateFormatter *dateFormat;
    NSIndexPath *selIndexPath;
    int rowCount;
    

}


@property (nonatomic,strong) NSMutableArray* arrRows;
@property (nonatomic,strong) NSString *deliveryId;
@property (nonatomic,strong) NSMutableArray *updatedDeliveryAddressArray;
@property (nonatomic,strong) NSMutableArray *customisedDelAdds;
@property (weak, nonatomic) IBOutlet UITableView *productdeliveryAddTable;

@end

@implementation ProductDeliveryViewController



-(void)currentPageProductDetail:(id)object{
    _productDetail=object;
    
}
#pragma mark - Custom Methods
-(void)reloadConfigData{
    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self reloadConfigData];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yy"];
    
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


#pragma mark -  UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    //for showing product delivery
        static NSString* identifier=@"ProductDeliveryTableViewCell";
        ProductDetailContentDeliveryTableViewCell *cellDelivery=(ProductDetailContentDeliveryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        NSDictionary *record = [_arrRows objectAtIndex:indexPath.row];
        cellDelivery.delIdValue.text=[record valueForKey:@"DelAdd"];
        selectedDeliveryAddress=cellDelivery.delIdValue.text;
        cellDelivery.townValue.text=[record valueForKey:@"addr4"];
        [cellDelivery.btnDate setTitle:[CommonHelper showDateWithCustomFormat:@"dd/MM/yy" Date:[record valueForKey:@"Deldate"]] forState:UIControlStateNormal];
        [cellDelivery.btnQuantity setTitle:[record valueForKey:@"DelQty"] forState:UIControlStateNormal];
        
        [cellDelivery.btnDate setTag:indexPath.row];
        [cellDelivery.btnQuantity setTag:indexPath.row];
        cell=cellDelivery;
    
    
    return cell;
}

#pragma mark -  UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString* identifier= nil;
    UITableViewCell *cellHeader = nil;
    //for  product  delivery
    
        identifier=@"ProductDeliveryTableViewHeaderCell";
        ProductDetailContentDeliveryTableViewCell *cellHeadertmp=[tableView dequeueReusableCellWithIdentifier:identifier];
        
        UIButton *btndelivery =(UIButton *)  [cellHeader.contentView viewWithTag:111];
        if(!btndelivery){
            btndelivery = [UIButton buttonWithType:UIButtonTypeContactAdd];
            btndelivery.tag = 111;
            btndelivery.frame = CGRectMake(50, 3, 20, 20);
            [btndelivery setTitle:@"" forState:UIControlStateNormal];
            [btndelivery addTarget:self action:@selector(deliveryAddress:) forControlEvents:UIControlEventTouchUpInside];
            
            [cellHeadertmp.contentView addSubview:btndelivery];
        }
        cellHeader = cellHeadertmp;
   
    return  cellHeader;;
}

#pragma mark - UITableViewDataSource
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // DebugLog(@"%i",indexPath.row);
    if (indexPath.row >0)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >0 ){
        UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self TableCell_DeleteClicked:indexPath];
        }];
        button.backgroundColor = [UIColor redColor];
        return @[button];
    }else{
        return nil;
    }
    
}

- (void) TableCell_DeleteClicked :(NSIndexPath *)indexPath{
    DebugLog(@"delevery deleted");
    
    NSDictionary *deleteDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:indexPath.row]];
    
    NSInteger Quantity=[[deleteDict valueForKey:@"DelQty"] integerValue];//Deleted row quantity
    
    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:0]];
    Quantity=Quantity+[[tempDict valueForKey:@"DelQty"]integerValue];//Add deleted quantity in first row
    [tempDict setValue:[NSString stringWithFormat:@"%li",(long)Quantity]  forKey:@"DelQty"];
    [_arrRows replaceObjectAtIndex:0 withObject:tempDict];
    
    
    //update first row db
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
    NSArray *descriptor = @[sortDescriptor];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]];
    NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate]sortedArrayUsingDescriptors:descriptor];
    NSManagedObject *lineObject=[tempLinesArr firstObject];
    
    [lineObject setValue:[NSNumber numberWithInteger:Quantity ] forKey:@"quantity"];
    [lineObject setValue:[NSNumber numberWithDouble:([[lineObject valueForKey:@"saleprice"] doubleValue]*Quantity)] forKey:@"linetotal"];
    
    //delete   row db
    predicate=nil;
    predicate=[NSPredicate predicateWithFormat:@" productid ==%@ && requireddate==%@ && deliveryaddresscode ==%@",[_productDetail valueForKey:@"stock_code"],[deleteDict valueForKey:@"Deldate"],[deleteDict valueForKey:@"DelAdd"]];
    NSArray*  tempLinesArr2=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:predicate];
    if ([tempLinesArr2 count]>0) {
        [kAppDelegate.managedObjectContext deleteObject:[tempLinesArr2 lastObject]];
        
    }
    
    [_arrRows removeObjectAtIndex:indexPath.row];
    //
    NSError *error = nil;
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
    
    //Reload new data rows
    [_productdeliveryAddTable reloadData];
}


#pragma mark - Delivery Address Delegate Methods
-(void)finishedDeliveryDoneSelection:(NSMutableArray*)selAcc_Ref{
    self.updatedDeliveryAddressArray =[[NSMutableArray alloc]init];
    [self.updatedDeliveryAddressArray addObjectsFromArray:selAcc_Ref];
    if (self.updatedDeliveryAddressArray.count>0) {
        // [self getDeliveryData];
        NSDate *date=[self upadateDate:[self.updatedDeliveryAddressArray lastObject]];
        
        [self addNewDeliveryAdd:date];
        [self.productdeliveryAddTable reloadData];
        
       
    }
}

-(NSDate*)upadateDate:(NSString *)delAdd{
    NSDate *date=[NSDate date];
    NSArray *delAddArr=[_arrRows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" self.DelAdd ==%@ && self.Deldate==%@",delAdd,[dateFormat stringFromDate:date]]];
    if ([delAddArr count]>0) {
        int daysToAdd = 1;
        date=[[NSDate date] dateByAddingTimeInterval:60*60*24*daysToAdd];
    }
    return date;
}

#pragma mark - CustomDatePickerViewController Delegate
-(void)finishedSelectionWithDate:(NSDate *)seldate{
    selectedDate = seldate;
    [_productdeliveryAddTable reloadData];
    
    //Notification update data in ProductOrderPanel
    NSString *delAdd=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"DelAdd"];
    NSString *delQty=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"];
    
    //update Row
    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
    [tempDict setValue:seldate forKey:@"Deldate"];
    [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
    [_productdeliveryAddTable reloadData];
    //ended
    
    
    if (delQty >0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[delAdd,seldate,delQty ]  forKeys:@[@"delAdd", @"deldate",@"delQty"]];
        [kNSNotificationCenter postNotificationName:kDeliverInfoChange  object:self userInfo:dict];
    }
}

#pragma mark - NumPad Delegate
-(void)retuenkeyClickwithOption:(NSString *)values Button:(UIButton* )btn{
    
    NSInteger qtyvalues=[values integerValue];
    
    [_productdeliveryAddTable reloadData];
    
    //Notification update data in ProductOrderPanel
    NSString *delAdd=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"DelAdd"];
    NSDate *deldate=[[_arrRows objectAtIndex:selIndexPath.row]valueForKey:@"Deldate"];;
    
    //  NSString *delQty=values;
    
    if (self.traitCollection) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
        NSArray *descriptor = @[sortDescriptor];
        NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]]]sortedArrayUsingDescriptors:descriptor];
        //       NSInteger totVal=[[tempLinesArr valueForKeyPath:@"@sum.quantity"] integerValue];
        NSManagedObject *lineObject=[tempLinesArr firstObject];
        
        if ([tempLinesArr count]>0 && selIndexPath.row>0){
            
            
            NSInteger FirstPrevRowQty=[[lineObject valueForKey:@"quantity"] integerValue];
            NSInteger firstrowQty=0;
            if ([[[_arrRows  objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"]integerValue]>qtyvalues) {
                
                NSInteger currentQty= [[[_arrRows  objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"]integerValue]-qtyvalues;
                
                firstrowQty=FirstPrevRowQty+currentQty;
                
            }else{
                NSInteger currentQty= [[[_arrRows  objectAtIndex:selIndexPath.row]valueForKey:@"DelQty"]integerValue]-qtyvalues;
                
                if (currentQty>0) {
                    firstrowQty=  FirstPrevRowQty-currentQty;
                }else
                    firstrowQty=  FirstPrevRowQty+currentQty ;
                
            }
            
            
            
            NSInteger FQty=0;
            /* if (FirstPrevRowQty==0){
             
             FQty=(FirstPrevRowQty+qtyvalues);
             
             NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
             [tempDict setValue:@"0" forKey:@"DelQty"];
             [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
             
             }else*/{
                 FQty= firstrowQty;
                 
                 
                 NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
                 [tempDict setValue:[NSString stringWithFormat:@"%li",(long)qtyvalues]  forKey:@"DelQty"];
                 [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
                 
             }
            
            //Remove quantity from previous first row
            if (FQty>0) {
                [lineObject setValue:[NSNumber numberWithInteger:FQty ] forKey:@"quantity"];
                [lineObject setValue:[NSNumber numberWithDouble:([[lineObject valueForKey:@"saleprice"] doubleValue]*FQty)] forKey:@"linetotal"];
                
                if (qtyvalues<=0) {//delete Selected row if quantity equal to 0
                    //OLD  NSArray*  tempLinesArr=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ &&requireddate==%@ && deliveryaddresscode ==%@",[_productDetail valueForKey:@"stock_code"],deldate,delAdd]];
                    NSArray*  tempLinesArr=[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ && requireddate==%@ && deliveryaddresscode ==%@",[_productDetail valueForKey:@"stock_code"],deldate,delAdd]];
                    if ([tempLinesArr count]>0) {
                        [kAppDelegate.managedObjectContext deleteObject:[tempLinesArr lastObject]];
                    }
                }
                
                //update table Row
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:0]];
                [tempDict setValue:[NSString stringWithFormat:@"%li",(long)FQty]  forKey:@"DelQty"];
                [_arrRows replaceObjectAtIndex:0 withObject:tempDict];
                
            }else{
                //less then 0 then delete 1 st object object
                [kAppDelegate.managedObjectContext deleteObject:lineObject];
                [_arrRows removeObjectAtIndex:0];
                
                //Manage lineno
                NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]]]sortedArrayUsingDescriptors:descriptor];
                for (NSManagedObject *obj in  tempLinesArr) {
                    NSString* lineno=[obj valueForKey:@"lineno"];
                    [obj setValue:[NSString stringWithFormat:@"%li",(long)([lineno integerValue]-1)] forKey:@"lineno"];
                }
                
                NSError *error = nil;
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
                
            }
            
        }else{
            
            NSInteger firstrowQty = [[[_arrRows  objectAtIndex:0]valueForKey:@"DelQty"]integerValue];
            if (firstrowQty==0 && selIndexPath.row>0) {
                
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:0]];
                [tempDict setValue:values  forKey:@"DelQty"];
                [_arrRows replaceObjectAtIndex:0 withObject:tempDict];
                
                delAdd=[tempDict valueForKey:@"DelAdd"];
                deldate=[tempDict valueForKey:@"Deldate"];
                //                del =[dateFormat dateFromString:[tempDict valueForKey:@"Deldate"]];
                tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
                [tempDict setValue:@"0" forKey:@"DelQty"];
                [_arrRows replaceObjectAtIndex:selIndexPath.row withObject:tempDict];
                
            } else {
                //Add value in first row
                NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[_arrRows objectAtIndex:selIndexPath.row]];
                [tempDict setValue:values forKey:@"DelQty"];
                [_arrRows removeObjectAtIndex:selIndexPath.row];
                [_arrRows insertObject:tempDict atIndex:0];
                
                if (qtyvalues<=0) {//delete first row
                    
                    [_arrRows removeObjectAtIndex:selIndexPath.row];
                    
                    [kAppDelegate.managedObjectContext deleteObject:lineObject];
                    //Manage lineno
                    NSArray*  tempLinesArr=[[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" productid ==%@ ",[_productDetail valueForKey:@"stock_code"]]]sortedArrayUsingDescriptors:descriptor];
                    for (NSManagedObject *obj in  tempLinesArr) {
                        NSString* lineno=[obj valueForKey:@"lineno"];
                        [obj setValue:[NSString stringWithFormat:@"%li",(long)([lineno integerValue]-1)] forKey:@"lineno"];
                    }
                    NSError *error = nil;
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                    }
                }
                
                
            }
            
        }
        
        [_productdeliveryAddTable reloadData];
        
    }
    
    //update order panel
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[delAdd,deldate,[NSString stringWithFormat:@"%li",(long)qtyvalues] ]  forKeys:@[@"delAdd", @"deldate",@"delQty"]];
    [kNSNotificationCenter postNotificationName:kDeliverInfoChange  object:self userInfo:dict];
    
}






-(void )getDeliveryData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSString *entityName=@"CUST";
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    NSPredicate *predicate;
    
    /*if (self.updatedDeliveryAddressArray.count>0)
     predicate=[NSPredicate predicateWithFormat:@"acc_ref==%@ && delivery_address  IN %@",[self.customerInfo valueForKey:@"acc_ref"],self.updatedDeliveryAddressArray];
     else{*/
    NSString *filterDeliveryAddress = [NSString stringWithFormat:@"acc_ref == '%@'",[self.customerInfo valueForKey:@"acc_ref"]];
    
    
    if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0 && [[[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]]] count]>0){//delivery Address already added
        
        NSMutableArray *prearr=[[NSMutableArray alloc]init];
        
        NSPredicate *pred1=[NSPredicate predicateWithFormat:@"acc_ref==%@",[self.customerInfo valueForKey:@"acc_ref"]];
        [prearr addObject:pred1];
        
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]];
        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        if ([filteredArr count]>0) {
            NSArray *arr=[filteredArr valueForKey:@"deliveryaddresscode"];
            NSPredicate *pred2=[NSPredicate predicateWithFormat:@"delivery_address  IN %@",arr];
            [prearr addObject:pred2];
        }
        
        if([prearr count]==1){
            predicate=[prearr objectAtIndex:0];
        }else{
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:prearr];
            
        }
        
        
    }else
        // remove main account address to use as first delivery address
        if(companyConfigDict && ![[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"usemainaccountasdeliveryaddresss"] boolValue]){
            filterDeliveryAddress = [filterDeliveryAddress stringByAppendingFormat:@" && delivery_address!='000'"];
            predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
        }
        else{
            filterDeliveryAddress = [filterDeliveryAddress stringByAppendingFormat:@" && delivery_address=='%@'",[self.customerInfo valueForKey:@"delivery_address"]];
            predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
        }
    
    // }
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *arrayDel=[kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // _arrRows =[NSMutableArray arrayWithArray: ];
    NSMutableArray *tempArray=[[NSMutableArray alloc]init];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]];
    NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
    
    if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0 && [filteredArr count]>0){
        //        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ ", [_productDetail valueForKey:@"stock_code"]];
        //        NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
        
        
        [filteredArr enumerateObjectsUsingBlock:^(id  _Nonnull obj12, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray* CustArr=[arrayDel filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"delivery_address == %@ ", [obj12 valueForKey:@"deliveryaddresscode"]]];
            NSManagedObject *obj=[CustArr lastObject];
            
            NSMutableDictionary *TempDictionary = [[NSMutableDictionary alloc]init];
            [TempDictionary setValue:[obj12 valueForKey:@"deliveryaddresscode"] forKey:@"DelAdd"];
            [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
            [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
            [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
            [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
            [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
            [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
            [TempDictionary setValue:[NSNumber numberWithInteger:[[obj12 valueForKey:@"lineno"]integerValue]] forKey:@"lineno"];
            [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
            [TempDictionary setValue:[obj12 valueForKey:@"requireddate"] forKey:@"Deldate"];
            [TempDictionary setValue:[NSString stringWithFormat:@"%i",[[obj12 valueForKey:@"quantity"] integerValue]] forKey:@"DelQty"];
            [tempArray addObject:TempDictionary];
        }];
        
        
        
        
        /*if ([filteredArr count]>0){
         
         NSManagedObject *obj12=[filteredArr firstObject];
         
         [TempDictionary setValue:[obj12 valueForKey:@"deliveryaddresscode"] forKey:@"DelAdd"];
         [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
         [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
         [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
         [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
         [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
         [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
         [TempDictionary setValue:[NSNumber numberWithInt:[[obj12 valueForKey:@"lineno"]integerValue]] forKey:@"lineno"];
         [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
         [TempDictionary setValue:[obj12 valueForKey:@"requireddate"] forKey:@"Deldate"];
         [TempDictionary setValue:[NSString stringWithFormat:@"%i",[[obj12 valueForKey:@"quantity"] integerValue]] forKey:@"DelQty"];
         [tempArray addObject:TempDictionary];
         
         }else{
         [TempDictionary setValue:[obj valueForKey:@"delivery_address"] forKey:@"DelAdd"];
         [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
         [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
         [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
         [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
         [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
         [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
         [TempDictionary setValue:[NSNumber numberWithInt:0] forKey:@"lineno"];
         [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
         [TempDictionary setValue:[dateFormat stringFromDate:[NSDate date]] forKey:@"Deldate"];
         //Default Quantity
         NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
         if ([arrDefault count]>0 && [arrayDel count]==1){
         [TempDictionary setValue:[NSString stringWithFormat:@"%li",(long)[[_productDetail valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] forKey:@"DelQty"];
         }else
         [TempDictionary setValue:@"0" forKey:@"DelQty"];
         
         
         
         [tempArray addObject:TempDictionary];
         }*/
    }else{
        
        //WithCapacity:[_arrRows count]];
        [arrayDel enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // if (self.oLineInfo && [[self.oLineInfo valueForKey:@"deliveryaddresscode"] isEqualToString:[obj valueForKey:@"delivery_address"]] ) {
            DebugLog(@"FOUND %@",[obj valueForKey:@"delivery_address"]);
            {
                NSMutableDictionary *TempDictionary = [[NSMutableDictionary alloc]init];
                [TempDictionary setValue:[obj valueForKey:@"delivery_address"] forKey:@"DelAdd"];
                [TempDictionary setValue:[obj valueForKey:@"postcode"] forKey:@"postcode"];
                [TempDictionary setValue:[obj valueForKey:@"addr1"] forKey:@"addr1"];
                [TempDictionary setValue:[obj valueForKey:@"addr2"] forKey:@"addr2"];
                [TempDictionary setValue:[obj valueForKey:@"addr3"] forKey:@"addr3"];
                [TempDictionary setValue:[obj valueForKey:@"addr4"] forKey:@"addr4"];
                [TempDictionary setValue:[obj valueForKey:@"addr5"] forKey:@"addr5"];
                [TempDictionary setValue:[NSNumber numberWithInt:0] forKey:@"lineno"];
                [TempDictionary setValue:[obj valueForKey:@"acc_ref"] forKey:@"acc_ref"];
                [TempDictionary setValue:[NSDate date] forKey:@"Deldate"];
                //Default Quantity
                NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
                if ([arrDefault count]>0 && [arrayDel count]==1){
                    [TempDictionary setValue:[NSString stringWithFormat:@"%li",(long)[[_productDetail valueForKey:[[[arrDefault lastObject] objectForKey:@"field"] lowercaseString]] integerValue]] forKey:@"DelQty"];
                }else
                    [TempDictionary setValue:@"0" forKey:@"DelQty"];
                
                
                
                [tempArray addObject:TempDictionary];
            }
        }];
    }
    if ([tempArray count]>0) {
        [_arrRows removeAllObjects];
        //_arrRows=[NSMutableArray arrayWithArray:tempArray];
        
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lineno" ascending:YES];
        NSArray *descriptor = @[sortDescriptor];
        _arrRows =[NSMutableArray arrayWithArray: [tempArray sortedArrayUsingDescriptors:descriptor]];
        
        
    }
    [_productdeliveryAddTable reloadData];
    
    if (error != nil)
    {
        // handle error
        abort(); // TEMP
    }
    
}

-(void)addNewDeliveryAdd:(NSDate* )dateVal{
    NSArray *remDel=nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSString *entityName=@"CUST";
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:kAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    
    
    if (self.updatedDeliveryAddressArray.count>0){
        
        NSArray *delAddArr=[_arrRows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" self.DelAdd ==%@ && self.Deldate==%@",[self.updatedDeliveryAddressArray lastObject],dateVal]];
        if ([delAddArr count]>0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"  message:@"Please change date with this delivery address."   delegate:self  cancelButtonTitle:@"Ok"otherButtonTitles: nil];
            [alert setDelegate:self];
            [alert show];
            return;
        }
        
        /*if (self.transactionInfo && [[self.transactionInfo valueForKey:@"orderlinesnew"] count]>0){
         NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@ && deliveryaddresscode  IN %@", [_productDetail valueForKey:@"stock_code"],self.updatedDeliveryAddressArray];
         NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
         remDel=[self.updatedDeliveryAddressArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Not self IN %@",[filteredArr valueForKey:@"deliveryaddresscode"]]];
         }else*/
        remDel=self.updatedDeliveryAddressArray;
        
        if([remDel count]>0){
            
            NSString *filterDeliveryAddress = [NSString stringWithFormat:@"acc_ref=='%@' && delivery_address =='%@'",[self.customerInfo valueForKey:@"acc_ref"],[remDel lastObject]];
            NSPredicate* predicate=[NSPredicate predicateWithFormat:filterDeliveryAddress];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            NSArray *arrayDel=[kAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            NSMutableDictionary *TempDictionary = [[NSMutableDictionary alloc]init];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"delivery_address"] forKey:@"DelAdd"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"postcode"] forKey:@"postcode"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr1"] forKey:@"addr1"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr2"] forKey:@"addr2"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr3"] forKey:@"addr3"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr4"] forKey:@"addr4"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"addr5"] forKey:@"addr5"];
            [TempDictionary setValue:[[arrayDel lastObject] valueForKey:@"acc_ref"] forKey:@"acc_ref"];
            [TempDictionary setValue:dateVal forKey:@"Deldate"];
            //Default Quantity
            [TempDictionary setValue:@"0" forKey:@"DelQty"];
            
            [_arrRows addObject:TempDictionary];
            
            [globalObjectDelegate.deliveryAddArray addObject:TempDictionary];
        }
    }
    
}

-(NSString *)getValueWithFieldName:(NSString *)field Table:(NSString *)table{
    if([[table uppercaseString] hasPrefix:@"PROD"]){
        return [CommonHelper getFieldValueWithFieldName:field Source:_productDetail];
    }
    else{
        return @"";
    }
}
-(void)deliveryAddress:(UIButton*)sender{
    self.title=@"";
    CustomerDeliveryAddressViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerDeliveryAddress"];
    controller.delegate=self;
    controller.isFromProduct=YES;
    controller.isFromCustomer=NO;
    controller.customerInfo = self.customerInfo;
    // controller.selectedDeliveryAddress=selectedDeliveryAddress;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
