//
//  CodeScanner.m
//  YesWeScan
//
//  Created by Steven Baranski on 7/29/13.
//
//

#import "CodeScanner.h"

@interface CodeScanner ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) dispatch_queue_t metadataOutputQueue;

@end

@implementation CodeScanner

#pragma mark - Initialization

- (id)initWithDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)delegate
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.captureSession = [AVCaptureSession new];
    
    self.metadataOutputQueue = dispatch_queue_create("yeswescan.metadata.output", NULL);
    
    self.metadataOutput = [AVCaptureMetadataOutput new];
    [self.metadataOutput setMetadataObjectsDelegate:delegate
                                              queue:self.metadataOutputQueue];
    
    return self;
}

#pragma mark - Public API methods

- (void)beginScanning
{
    [self.captureSession beginConfiguration];
    
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
        AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
        NSError *deviceInitError = nil;
        AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice
                                                                                  error:&deviceInitError];
        if ([self.captureSession canAddInput:videoInput])
        {
            [self.captureSession addInput:videoInput];
        }
    
    [self.captureSession commitConfiguration];
    
    if ([self.captureSession canAddOutput:self.metadataOutput])
    {
		[self.captureSession addOutput:self.metadataOutput];
	} // else: properly handle the error
    
    [self.captureSession startRunning];
    
    if ([[self.metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode])
    {
        self.metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode ];
    } // else: properly handle the error
}

- (void)endScanning
{
    if (self.metadataOutput)
    {
        [self.captureSession removeOutput:self.metadataOutput];
    }
    [self.captureSession stopRunning];

    self.captureSession = nil;
    self.metadataOutput = nil;
    self.metadataOutputQueue = nil;
}

@end
