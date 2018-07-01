#import "blurLabel.h"

@implementation blurLabel

- (void)setText:(NSString *)text {
    super.text = text;

    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    
    CIImage *imageToBlur = [CIImage imageWithCGImage:image.CGImage];
    [blurFilter setValue:imageToBlur forKey:kCIInputImageKey];
    [blurFilter setValue:@(self.blurRadius) forKey:@"inputRadius"];
    
    CIImage *outputImage = blurFilter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    [self.layer setContents:(__bridge id)cgimg];
    CGImageRelease(cgimg);

}

@end
