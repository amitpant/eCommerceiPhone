//
//  ScannerViewController.m
//  mSeller
//
//  Created by Ashish Pant on 12/14/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ScannerViewController.h"

#define kScanWaitingTime 10

@interface ScannerViewController (){
    NSTimer *waitingTimer;
    BOOL isViewLoaded;
}

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;
@property(nonatomic,strong)NSMutableArray *scannedCodes;

-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end


@implementation ScannerViewController


-(void)viewDidLayoutSubviews
{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scannedCodes=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, 207);
    _viewPreview.frame=CGRectMake(0, 0, self.view.frame.size.width, 207);
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    // Set the initial value of the flag to NO.
    _isReading = NO;

    if ([_scanningTypeArray count]==0) {
        _scanningTypeArray=[[NSMutableArray alloc]init];
        [_scanningTypeArray addObject:AVMetadataObjectTypeEAN13Code];
        [_scanningTypeArray addObject:AVMetadataObjectTypeCode128Code];
        [_scanningTypeArray addObject:AVMetadataObjectTypeCode39Code];
        
    }
    //EAN13Code,Code128Code,Code39Code,Code93Code,QRCode,EAN8Code,UPCECode,ITF14Code,PDF417Code,DataMatrixCode,Code39Mod43Code,Interleaved2of5Code,AztecCode
         
         
//    if(!_scanningType)
//        _scanningType = AVMetadataObjectTypeEAN13Code;
//    
    // Begin loading the sound effect so to have it ready for playback when it's needed.
    //code comment by Ashish
   // [self loadBeepSound];

    isViewLoaded = YES;
    /* Use this code to play an audio file */
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(isViewLoaded){
        waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];

        [self startStopReading:nil];
    }
    isViewLoaded = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [waitingTimer invalidate];
    [super viewWillDisappear:animated];
}

-(void)timerTick:(NSTimer *)sender{
    static NSInteger timeCount = 1;
    DebugLog(@"%li",timeCount);
    [self loadBeepSound];
    if(kScanWaitingTime - timeCount<=0)
    {
        timeCount = 0;
        [waitingTimer invalidate];
        [self startStopReading:nil];
    }
    timeCount++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBAction method implementation

- (IBAction)startStopReading:(id)sender {
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading]) {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
//            [_bbitemStart setTitle:@"Stop" forState:UIControlStateNormal];
//            [_lblStatus setText:@"Scanning for Code..."];
        }
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
//        if([[_lblStatus.text lowercaseString] hasPrefix:@"scan"])
//            [_bbitemStart setTitle:@"Tap here to Start" forState:UIControlStateNormal];
//        else
//            [_bbitemStart setTitle:@"Scan " forState:UIControlStateNormal];
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
}


#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.accessibilityFrame= CGRectMake(0.0, 0.0, self.view.frame.size.width, 207.0);
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:_scanningTypeArray];//[NSArray arrayWithObject:_scanningType]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CGRect videoRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, 207.0);
    _videoPreviewLayer.frame = videoRect; // Assume you want the preview layer to fill the view.
    [_videoPreviewLayer setBackgroundColor:[[UIColor grayColor] CGColor]];
    
    
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
   DebugLog(@" AAA--   %f  %f",_viewPreview.frame.size.height,_videoPreviewLayer.frame.size.height);
    
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];

    if ([self.delegate respondsToSelector:@selector(getScannedBarCodes:)]) {
        [self.delegate getScannedBarCodes:self.scannedCodes];
    }

//    [_bbitemStart setTitle:@"Tap here to Start" forState:UIControlStateNormal];
}


-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];

    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //if ([[metadataObj type] isEqualToString:_scanningType]) {
        
        if ([_scanningTypeArray containsObject:[metadataObj type]]) {
            
        
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
           
                if (![self.scannedCodes containsObject:[metadataObj stringValue]])
                     [self.scannedCodes addObject:[metadataObj stringValue]];
                    
//            NSString *finalScannedCode=  [self.scannedCodes componentsJoinedByString:@","];

//            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:finalScannedCode waitUntilDone:NO];

            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
//            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Tap here to Start" waitUntilDone:NO];

            _isReading = NO;
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
    
    
}


- (IBAction)Done_Click:(id)sender{
    if ([self.delegate respondsToSelector:@selector(getScannedBarCodes:)]) {
        [self.delegate getScannedBarCodes:self.scannedCodes];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
