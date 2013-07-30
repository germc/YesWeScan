//
//  CodeScanner.h
//  YesWeScan
//
//  Created by Steven Baranski on 7/29/13.
//
//

#import <AVFoundation/AVFoundation.h>

@interface CodeScanner : NSObject

@property (readonly, nonatomic, strong) AVCaptureSession *captureSession;
@property (readonly, nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

- (id)initWithDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)delegate;

- (void)beginScanning;
- (void)endScanning;

@end
