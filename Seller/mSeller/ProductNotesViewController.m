//
//  ProductNotesViewController.m
//  mSeller
//
//  Created by Satish Kr Singh on 27/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductNotesViewController.h"
#import "TransactionNotesViewController.h"

@interface ProductNotesViewController ()<NotesViewControllerDelegate>{
    NSString *strNote;
}

@property (weak, nonatomic) IBOutlet UIView *viewStandardMessage;
@property (weak, nonatomic) IBOutlet UIView *viewTextMessage;

@property (weak, nonatomic) IBOutlet UILabel *standardMessageLbl;

@property (weak, nonatomic) IBOutlet UIButton *dropDownClickBtn;
@property (weak, nonatomic) IBOutlet UITextView *txtViewNotes;

@end

@implementation ProductNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
    
//    _txtViewNotes.layer.cornerRadius=5.0;
    _txtViewNotes.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _txtViewNotes.layer.borderWidth=1.0;
    if ([strNote length]==0) {
        
        if (self.transactionInfo ) {
           
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_productDetail valueForKey:@"stock_code"]];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
            if ([filteredArr count]>0)
                strNote=[[filteredArr lastObject] valueForKey:@"linetext"];
            
        }
        
       // strNote=[_productDetail valueForKey:@"notes"];
    }
    
    _txtViewNotes.text =strNote;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self saveProductNote];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toAddNote"]) {
        TransactionNotesViewController *noteObj = segue.destinationViewController;
        [noteObj setDelegate:self];
        [noteObj setNoteType:@"L"];
        [noteObj setReturnDictionary:(NSMutableDictionary* )[NSDictionary dictionaryWithObject:_txtViewNotes.text forKey:@"Note"]];
    }
}


#pragma  mark -TransactionNotesViewControllerDelegate
-(void)finishedNoteSelectionWithOption:(NSDictionary*)selDictionary{
    NSString *strngNote=_txtViewNotes.text;
    if ([strngNote  length]>0 && ![strngNote isEqualToString:@"\n"]) {
        strNote=[strngNote stringByAppendingString:[NSString stringWithFormat:@"\n%@",[selDictionary valueForKey:@"Note"]]];
    }else
        strNote=[NSString stringWithFormat:@"%@",[selDictionary valueForKey:@"Note"]];
    
    _txtViewNotes.text=strNote;
    
}


- (void)saveProductNote {
    
    
//    NSError *error = nil;
//    if ([[_notesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]>0) {
//        [_productDetail setValue:[_notesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"notes"];
//    }
    
//    NSError *error = nil;
    
    //if (![[_txtViewNotes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[_productDetail valueForKey:@"notes"]]) {
       
        if (self.transactionInfo && [_txtViewNotes.text length]>0) {
          //  productNotes
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"productid == %@", [_productDetail valueForKey:@"stock_code"]];
            NSArray *filteredArr = [[[self.transactionInfo valueForKey:@"orderlinesnew"] allObjects] filteredArrayUsingPredicate:pred];
          
            
            
            for (NSManagedObject* obj in filteredArr) {
                NSError *error = nil;
                [obj setValue:_txtViewNotes.text forKey:@"linetext"];
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    DebugLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
            }

            
       // }
        
        
        
// [_productDetail setValue:[_txtViewNotes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"notes"];
//        if (![kAppDelegate.managedObjectContext save:&error]) {
//            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
//        }
//        else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Note save successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//        }
    }
}
@end
