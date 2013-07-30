//
//  ReadViewController.m
//  YesWeScan
//
//  Created by Steven Baranski on 7/14/13.
//

#import "ReadViewController.h"

#import "CodeScanner.h"

#import <AVFoundation/AVFoundation.h>

@interface ReadViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) CodeScanner *codeScanner;
@property (nonatomic, strong) NSTimer *highlightTimer;

@property (nonatomic, strong) NSString *lastBarCode;
@property (nonatomic, strong) NSArray *barCodeCorners;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *barcodeHighlightView;

@end

@implementation ReadViewController

#pragma mark - UIViewController lifecycle methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.codeScanner = [[CodeScanner alloc] initWithDelegate:self];
    self.highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                           target:self
                                                         selector:@selector(updateView)
                                                         userInfo:nil
                                                          repeats:YES];
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.codeScanner.captureSession];
    previewLayer.frame = self.view.bounds;
    previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.masksToBounds = YES;
    self.previewLayer = previewLayer;
    [self.view.layer addSublayer:self.previewLayer];
    
    self.barcodeHighlightView = [[UIView alloc] initWithFrame:self.view.bounds];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(screenTapped:)];
    [self.barcodeHighlightView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:self.barcodeHighlightView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.codeScanner beginScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.codeScanner endScanning];
    
    [self.highlightTimer invalidate];
    self.highlightTimer = nil;
    
    self.previewLayer = nil;
    self.barcodeHighlightView = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    self.codeScanner = nil;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] == 0)
    {
        self.lastBarCode = @"";
        self.barCodeCorners = [NSArray array];
        [self clearHighlight];
        return;
    }
    
    AVMetadataMachineReadableCodeObject *rawObject = [metadataObjects firstObject];
    AVMetadataMachineReadableCodeObject *transformedObject = (AVMetadataMachineReadableCodeObject *) [self.previewLayer transformedMetadataObjectForMetadataObject:rawObject];
    
    self.lastBarCode = transformedObject.stringValue;
    self.barCodeCorners = transformedObject.corners;
}

#pragma mark - Private behavior
     
- (void)screenTapped:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Successful Scan", @"Successful Scan")
                               message:self.lastBarCode
                              delegate:self
                     cancelButtonTitle:nil
                     otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil] show];
}

- (void)updateView
{
    if (!self.barCodeCorners)
    {
        return;
    }
    
    CGPathRef outline = [self pathForPoints:self.barCodeCorners];
    
    [CATransaction begin];
    
        [CATransaction setDisableActions:YES];
    
        [self clearHighlight];
        [self.barcodeHighlightView.layer addSublayer:[self barcodeOverlayForPath:outline]];
    
    [CATransaction commit];
    
    CFRelease(outline);
}

- (void)clearHighlight
{
    [self.barcodeHighlightView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (CALayer *sublayer in self.barcodeHighlightView.layer.sublayers)
    {
        [sublayer removeFromSuperlayer];
    }
}

- (CAShapeLayer *)barcodeOverlayForPath:(CGPathRef)path
{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = path;
    maskLayer.lineJoin = kCALineJoinMiter;
    maskLayer.lineWidth = 1.5f;

    UIColor *overlayColor = [UIColor yellowColor];
    maskLayer.strokeColor = overlayColor.CGColor;
    maskLayer.fillColor = [overlayColor colorWithAlphaComponent:0.25f].CGColor;
	
	return maskLayer;
}

- (CGMutablePathRef)pathForPoints:(NSArray *)points
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point;
	
	if ([points count] > 0)
    {
		CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:0], &point);
		CGPathMoveToPoint(path, nil, point.x, point.y);
		
		int i = 1;
		while (i < [points count])
        {
			CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:i], &point);
			CGPathAddLineToPoint(path, nil, point.x, point.y);
			i++;
		}
		
		CGPathCloseSubpath(path);
	}
	
	return path;
}

@end
