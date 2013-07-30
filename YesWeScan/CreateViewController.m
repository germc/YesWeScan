//
//  CreateViewController.m
//  YesWeScan
//
//  Created by Steven Baranski on 7/14/13.
//

#import "CreateViewController.h"

@interface CreateViewController () <UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITextField *qrCodeInputTextField;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIImageView *qrCodeView;

@end

@implementation CreateViewController

#pragma mark - Shared class methods

+ (CIContext *)sharedCIContext
{
    static CIContext *sharedContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *options = @{ kCIContextOutputColorSpace : (__bridge id) CGColorSpaceCreateDeviceRGB() };
        sharedContext = [CIContext contextWithOptions:options];
    });
    return sharedContext;
}

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.qrCodeView.layer.magnificationFilter = kCAFilterNearest;
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    CGFloat duration = 0.3f;
    [UIView animateWithDuration:duration
                     animations:^(void){
                         self.qrCodeView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self generateCode];
                         [UIView animateWithDuration:duration
                                          animations:^(void){
                                              self.qrCodeView.alpha = 1.0f;
                                          }];
                     }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if ([self.searchBar canResignFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Private behavior

- (void)generateCode
{
    NSString *encodeable = self.searchBar.text;
    NSData *encodeData = [encodeable dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:encodeData
                forKey:@"inputMessage"];
    CIImage *unscaledImage = [qrFilter outputImage];
    
    CGImageRef cgImage = [[CreateViewController sharedCIContext] createCGImage:unscaledImage
                                                                             fromRect:[unscaledImage extent]];
	self.qrCodeView.image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
}

@end
