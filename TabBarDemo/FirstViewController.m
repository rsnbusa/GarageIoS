//
//  FirstViewController.m
//  FoodAuto
//
//  Created by Robert on 3/2/16.
//  Copyright © 2016 Robert. All rights reserved.
//

#import "FirstViewController.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "petInfoViewController.h"
#import "miColl.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "httpVC.h"
#import "btSimplePopUp.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotHelper.h>

//#import <AdSupport/ASIdentifierManager.h>
@interface FirstViewController ()

@end

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@implementation FirstViewController

@synthesize host,answer,effects,petName,collect,picScroll,mqttServer,album,fotoSize,onOff,netServiceBrowser,passSW,addBut;

struct CTServerConnection *sc=NULL;
//struct CTResult result;
void callback() { }
id yo;

-(void)blurScreen
{
    return;
    CGRect screenSize = [UIScreen mainScreen].bounds;
    UIImage *screenShot = [self.view screenshot];
    UIImage *blurImage  = [screenShot blurredImageWithRadius:10.5 iterations:2 tintColor:nil];
    backGroundBlurr = [[UIImageView alloc]initWithImage:blurImage];
    backGroundBlurr.frame = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
    [self.view addSubview:backGroundBlurr];
}

-(void)oneTap:(id)sender
{

    UIStoryboard *storyboard=self.storyboard;
    petInfoViewController *myVC = (petInfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PetInfo"];
    appDelegate.addf=NO;
    [self presentViewController:myVC animated:YES completion:nil];
}

-(void)showMensajeTimer:(NSString*)mensaje
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Server Information"
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

 -(void)showMensaje:(NSString*)title withMessage:(NSString*)mensaje doExit:(BOOL)salir
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                               if (salir) exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)confirmDelete
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete Heater"
                                                                   message:[NSString stringWithFormat:@"You really want to remove %@",[appDelegate.workingBFF valueForKey:@"bffName"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              NSString *mis=[NSString stringWithFormat:@"erase?bff=%@",
                                                                                [appDelegate.workingBFF valueForKey:@"bffName"]];
                                                              [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue]];
                                                              //return;//should be return
                                                              [self deleteAllEntity:@"Emails"];
                                                              [self deleteAllEntity:@"Servings"];
                                                              [appDelegate.bffs removeObject: appDelegate.workingBFF];
                                                              NSManagedObjectContext *context =
                                                              [appDelegate managedObjectContext];
                                                              
                                                              NSError *error;
                                                              [context deleteObject:appDelegate.workingBFF];
                                                              if(![context save:&error])
                                                              {
                                                                  LogDebug(@"Delete error %@",error);
                                                                  return;//if we cant save it return and dont send anything toi the esp8266
                                                              }
                                                              for(UIImageView *subview in picScroll.subviews) {
                                                                  [subview removeFromSuperview];
                                                              }
                                                              [appDelegate.imageArray removeObjectAtIndex:indexOfPage];

                                                              [self loadBffs];
                                                              [self getArrays];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                          }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(IBAction)prepareForUnwindFirst:(UIStoryboardSegue *)segue {
    
}

- (IBAction)bffOnOff:(UIButton*)sender
{
    [comm lsender:@"openDoor?password=zipo" andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue]];
  }


- (IBAction)refresh:(UIButton*)sender
{
    [comm lsender:@"status" andAnswer:NULL andTimeOut:1 vcController:self];
}

- (IBAction)fotoSizeSlider:(UISlider*)sender
{
    fotoHV=(int)sender.value;
    [album reloadData];}

- (uint8_t *)buffer
{
    return self->buffer;
}

- (void)startSend:(NSString *)filePath withImage:laImagen
{
    BOOL                    success;
    NSURL *                 url;
    int w,h;
    float rel;
    
    // save for the HttpStatus image
    
    w=(int)imagel.size.width;
    h=(int)imagel.size.height;
    NSString *elNombre=[filePath lastPathComponent];
    rel=1.0;
    if ((int)imagel.size.height>700 || (int)imagel.size.width>700){
        if((int)imagel.size.height>(int)imagel.size.width)
        {
            rel=imagel.size.height/imagel.size.width;
            h=700;
            w=h/rel;
        }
        else
        {
            rel=imagel.size.width/imagel.size.height;
            w=700;
            h=w /rel;
        }
        //resize it
        CGSize newSize;
        newSize = CGSizeMake(w, h);
        UIGraphicsBeginImageContext(newSize);
        [imagel drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *final=[NSString stringWithFormat:@"%tmp.txt"];
        NSString *lfilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
        [UIImagePNGRepresentation(newImage) writeToFile:lfilePath atomically:YES];
        filePath=lfilePath;
    }
    
    assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    if(self.networkStream!=nil)
    {
        [self showMensaje:@"Image Upload" withMessage:@"Still one pending. Retry later" doExit:NO];
        return;
    }
 //   assert(self.networkStream == nil);      // don't tap send twice in a row!
//    assert(self.fileStream == nil);         // ditto
    NSString *filef=[NSString stringWithFormat:@"ftp://feediot.co.nf/%@",elNombre];
    NSString *mis=[NSString stringWithFormat:@"image?w=%d&h=%d",w,h];
    [comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];

    
    // First get and check the URL.
    url = [NSURL URLWithString:filef];
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    assert(self.fileStream != nil);
    
    [self.fileStream open];
    // Open a CFFTPStream for the URL.
    self.networkStream = CFBridgingRelease(CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url));
    assert(self.networkStream != nil);
    
    
    success = [self.networkStream setProperty:@"2121429_rsn" forKey:(id)kCFStreamPropertyFTPUserName];
    assert(success);
    success = [self.networkStream setProperty:@"Ziposimpson0179" forKey:(id)kCFStreamPropertyFTPPassword];
    assert(success);
    
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.networkStream open];
    
    // Tell the UI we're sending.
}

- (void)stopSend
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
#pragma unused(aStream)
    // assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            // [self updateStatus:@"Opened connection"];
            //      LogDebug(@"Open connection  [%s]");
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            //   [self updateStatus:@"Sending"];
            //  LogDebug(@"Sending  [%s]");
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:32768];
                
                if (bytesRead == -1) {
                    [self showMensaje:@"Image FTP Transfer" withMessage:@"Error reading file" doExit:NO];
                    [self stopSend];
                } else if (bytesRead == 0) {
                    //   [self showErrorMessage:@"Image FTP Transfer" andMsg:@"Picture Uploaded"];
                    [self stopSend];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self showMensaje:@"Image FTP Transfer" withMessage:@"Network write error. Retry" doExit:NO];
                    [self stopSend];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self showMensaje:@"Image FTP Transfer" withMessage:@"Stream Open error." doExit:NO];
            [self stopSend];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *estai = [info valueForKey:UIImagePickerControllerOriginalImage];
    imagel=[UIImage imageWithCGImage:estai.CGImage scale:1.0 orientation:estai.imageOrientation];
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];//.txt hasta que tengamos webiste ue nos permita usar .png
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
       // Save image.
    [UIImagePNGRepresentation(imagel) writeToFile:filePath atomically:YES];
  //  [UIImageJPEGRepresentation(imagel,1.0) writeToFile:filePath atomically:YES];

    [picker dismissViewControllerAnimated:YES completion:nil];
    lscrollView.image=imagel;
    appDelegate.imageArray[indexOfPage]=imagel;

    if (appDelegate.workingBFF)
    {
        [appDelegate.workingBFF setValue:[appDelegate.workingBFF valueForKey:@"bffName"] forKey:@"bffImage"];
          NSError *error;
           if(![[appDelegate managedObjectContext] save:&error])
              LogDebug(@"Save error Image bff %@",error);
    }
    if (![[appDelegate.workingBFF valueForKey:@"bffOffline"] boolValue])
        [self startSend:filePath withImage:imagel]; //save the original one
    
   }

-(void)getPhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = (id)self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)createDefaults
{
       // no ip, must get it from Device or scan network
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: 0x11223344]  forKey:@"centinel"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:@"txTimeOut"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"transport"];
    [[NSUserDefaults standardUserDefaults] setObject:@"ga"  forKey:@"appId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)deleteAllEntity:(NSString *)cualEntity
{
     NSError *error;
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:cualEntity
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
//    NSArray *nada=[context executeFetchRequest:request
//                            error:&error] ;
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    [[appDelegate persistentStoreCoordinator] executeRequest:delete withContext:context error:&error];
    [context save:&error];
}


-(void)dmyTapMethod:(UITapGestureRecognizer *)gr {
    lscrollView=(UIImageView*)gr.view;
   [self getPhoto];
}

-(void)getArrays
{
    // Get emails, count and order them by address
      NSError *error;
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"Servings" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //Sort them
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"servBFFName", [appDelegate.workingBFF valueForKey:@"bffName"]];
    [request setPredicate:predicate];
    appDelegate.servingsArray = [[context executeFetchRequest:request
                                                        error:&error] mutableCopy];
    [[appDelegate.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld",(unsigned long)appDelegate.bffs.count]];

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [appDelegate unsubscribeMQTT:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
    
    indexOfPage = roundf(scrollView.contentOffset.x / scrollView.frame.size.width);
    appDelegate.lastpos=indexOfPage;
    appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
    // Subscribe new mqtt queues
    [appDelegate subscribeMQTT:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
    [comm lsender:@"status" andAnswer:NULL andTimeOut:2 vcController:self];
     appDelegate.messageType=(int)[[appDelegate.workingBFF valueForKey:@"bffLimbo"]integerValue];
    NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
      dispatch_async(dispatch_get_main_queue(), ^{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.8;
    [petName.layer addAnimation:animation forKey:@"kCATransitionFade"];
    petName.textColor=[appDelegate.appColors objectAtIndex:randomNumber];
    petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
      });

    [self getArrays];
}


- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    return image;
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
    //return imageCopy;
}


-(void)loadBffs
{
    UIImage *licon,*l22;
    
    //get all BFFs in DB
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"BFF"
                inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //get all and sort them by name
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"bffName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    [request setReturnsObjectsAsFaults:NO];
    NSError *error;
    appDelegate.bffs = [[context executeFetchRequest:request error:&error] mutableCopy];//get them
    //Now read images from files and insert them in the scrollView and set touch actions for single and double tap
    //Scrollview dimensions
    CGFloat width = picScroll.bounds.size.width;
    CGFloat heigth = picScroll.bounds.size.height;
    int van=0;
    
    for(NSManagedObject *pet in appDelegate.bffs)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *final=[NSString stringWithFormat:@"%@.txt",[pet valueForKey:@"bffName"]];
      //  NSString *final=[NSString stringWithFormat:@"%@.png",[pet valueForKey:@"bffName"]];

        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
        l22=[UIImage imageWithContentsOfFile:filePath];
        licon=[self scaleAndRotateImage:l22];
   //     licon = [[UIImage alloc] initWithCGImage:[UIImage imageWithContentsOfFile:filePath].CGImage scale:1.0 orientation:UIImageOrientationUp];
                              //    initialImage.CGImage, scale: 1, orientation: initialImage.imageOrientation)
       
        if (licon==NULL)
                licon = [UIImage imageNamed:@"camera"];//need a photo
        [appDelegate.imageArray addObject:licon];
        UITapGestureRecognizer *dobleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dmyTapMethod:)];//for chosing image
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];//for chosing image
        UIImageView *limage = [[UIImageView alloc] initWithFrame:CGRectMake(van*width, 0, width,heigth)];
        dobleTap.numberOfTapsRequired = 2;
        [limage addGestureRecognizer:dobleTap];
        [limage addGestureRecognizer:singleTap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTap:)];
        [limage addGestureRecognizer:longPress];
        limage.image=licon;
        limage.tag=van++;
        [limage setMultipleTouchEnabled:YES];
        [limage setUserInteractionEnabled:YES];
        [limage setContentMode:UIViewContentModeScaleAspectFit];
        [singleTap requireGestureRecognizerToFail:dobleTap];
        [picScroll addSubview:limage];
  //      [pet setValue:@"" forKey:@"bffLastIpPort"];
    }

    //Scroll to first position and show name
    
    if (appDelegate.bffs.count>0)
            appDelegate.workingBFF=appDelegate.bffs[0]; //First record is the working record
    picScroll.contentSize = CGSizeMake(width * appDelegate.bffs.count, heigth);

    [picScroll scrollRectToVisible: CGRectMake(0, 0, width, heigth) animated: true];
    petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
    NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
    petName.textColor=[appDelegate.appColors objectAtIndex:randomNumber];
}

-(IBAction)deleteBFF:(id)sender
{

    [self confirmDelete];
}


-(IBAction)viewMode:(UIButton*)sender
{
    CATransition *t1,*t2,*t4;
;
    if (viewmodef)// Scroll is TRUE
    {
        t1 = [CATransition animation];
        t1.duration = 0.80;
        t1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t1.type = kCATransitionFade;
        [picScroll.layer addAnimation:t1 forKey:nil];
        
        t2 = [CATransition animation];
        t2.duration = 0.80;
        t2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t2.type = kCATransitionFade;
        [album.layer addAnimation:t2 forKey:nil];

    
        t4 = [CATransition animation];
        t4.duration = 0.80;
        t4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t4.type = kCATransitionFade;
        [fotoSize.layer addAnimation:t2 forKey:nil];
        
     //   [gridPano setImage:grid forState:UIControlStateNormal];
        album.hidden=YES;
        picScroll.hidden=NO;
        petName.hidden=NO;
        fotoSize.hidden=YES;
        if(appDelegate.bffs.count>0 )
        {
        //scroll to last selected item in Grid mode
        appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
        CGFloat width = picScroll.bounds.size.width;
        CGFloat heigth = picScroll.bounds.size.height;
        [picScroll scrollRectToVisible: CGRectMake(indexOfPage*width, 0, width, heigth) animated: true];
        petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
        }
        
    }
    else
    {
        if (appDelegate.bffs.count<2) return; //no need Just one
        t1 = [CATransition animation];
        t1.duration = 0.80;
        t1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t1.type = kCATransitionFade;
        [picScroll.layer addAnimation:t1 forKey:nil];
        
        t2 = [CATransition animation];
        t2.duration = 0.80;
        t2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t2.type = kCATransitionFade;
        [album.layer addAnimation:t2 forKey:nil];
        
        t4 = [CATransition animation];
        t4.duration = 0.80;
        t4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        t4.type = kCATransitionFade;
        [fotoSize.layer addAnimation:t2 forKey:nil];
        
       // [gridPano setImage:pano forState:UIControlStateNormal];
        album.hidden=NO;
        picScroll.hidden=YES;
        petName.hidden=YES;
        fotoSize.hidden=NO;
        
        if (appDelegate.bffs.count>0)
        {
        appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
         NSIndexPath *selection = [NSIndexPath indexPathForItem:indexOfPage
         inSection:1];
         [album selectItemAtIndexPath:selection
         animated:YES
         scrollPosition:UICollectionViewScrollPositionNone];
        [album reloadData];
        [album
         selectItemAtIndexPath:[NSIndexPath indexPathForItem:indexOfPage inSection:0]
         animated:YES
         scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
       
    }
    viewmodef= !viewmodef;
    
}

-(IBAction)sleep:(id)sender
{
    [comm lsender:@"sleep?password=zipo" andAnswer:NULL andTimeOut:1 vcController:self];

}

-(IBAction)activateOnBreak:(id)sender
{
    
    [comm lsender:@"break?password=zipo" andAnswer:NULL andTimeOut:1 vcController:self];
}

-(IBAction)addBFF:(id)sender
{
    // Create basic structure but do not save it
    appDelegate.oldbff=appDelegate.workingBFF;
    appDelegate.lastpos = picScroll.contentOffset.x / picScroll.bounds.size.width;
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSManagedObject *newBFF= [NSEntityDescription
                                    insertNewObjectForEntityForName:@"BFF"
                                            inManagedObjectContext:context];

    [newBFF setValue:@"Chillo" forKey:@"bffName"];
    [newBFF setValue:@"" forKey:@"bffEmail"];
    [newBFF setValue:@"" forKey:@"bffGroup"];
    [newBFF setValue: @"" forKey:@"bffDomain"];
    [newBFF setValue: @"" forKey:@"bffMQTT"];
    [newBFF setValue: @81 forKey:@"bffPort"];
    [newBFF setValue: @0 forKey:@"bffMQTTPort"];
    [newBFF setValue: @NO forKey:@"bffOnOff"];
    [newBFF setValue:@1500 forKey:@"bffWatts"];
    [newBFF setValue:@220 forKey:@"bffVolts"];
    [newBFF setValue:@20 forKey:@"bffGalons"];
    [newBFF setValue:@0.12 forKey:@"bffKwH"];
    [newBFF setValue:@0.01 forKey:@"bffWater"];
    appDelegate.workingBFF=newBFF;
  
    CGFloat width = picScroll.bounds.size.width;
    CGFloat heigth = picScroll.bounds.size.height;

    int van=(int)appDelegate.bffs.count;
    UITapGestureRecognizer *dobleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dmyTapMethod:)];
    UIImageView *limage = [[UIImageView alloc] initWithFrame:CGRectMake((van)*(int)width, 0, width,heigth)];
    UIImage *licon= [UIImage imageNamed:@"camera"];
    [appDelegate.imageArray addObject:licon];
    limage.image=licon;
    limage.tag=van+1;
    dobleTap.numberOfTapsRequired = 2;
    [limage addGestureRecognizer:dobleTap];
    [limage setMultipleTouchEnabled:YES];
    [limage setUserInteractionEnabled:YES];
    [limage setContentMode:UIViewContentModeScaleAspectFit];
    [picScroll addSubview:limage];

    picScroll.contentSize = CGSizeMake(width * (van+1), heigth);
    [picScroll scrollRectToVisible: CGRectMake(width * van, 0, width, heigth) animated: true];
 //   [self OnOffState:(int)[[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue]];
    UIStoryboard *storyboard=self.storyboard;
    petInfoViewController *myVC = (petInfoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PetInfo"];
    appDelegate.addf=YES;
    [self presentViewController:myVC animated:YES completion:nil];
}

-(void)bj {
    //   LogDebug(@"BJloop");
    [netServiceBrowser stop];
}

-(BOOL) startBonjour
{
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if( !netServiceBrowser ) {
        return NO;
    }
    netServiceBrowser.delegate = self;
    [appDelegate.feeders removeAllObjects];
    [netServiceBrowser searchForServicesOfType:@"_garageiot._tcp." inDomain:@"local."];
    return YES;
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
      LogDebug(@"WillSearch %@",aNetServiceBrowser);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
    //  LogDebug(@"DidNotSearch: %@", errorInfo);
}

- (void) netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    //  LogDebug(@"didUpdateTXTRecordData: %@", data);
    
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
    //  LogDebug(@"DidStopSearch");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    
    //   LogDebug(@"DidNotResolve: %@", errorDict);
}

- (void) netServiceWillResolve:(NSNetService *)sender
{
    //  LogDebug(@"willresolve");
}

-(void) checkLogin
{
    LogDebug(@"passf check %d",appDelegate.passwordf);
if (!appDelegate.passwordf)
{
    LogDebug(@"Need to get password again");
    [self performSegueWithIdentifier:@"getPassword" sender:self];
}
}

-(void)longPressTap:(UILongPressGestureRecognizer*)sender
{
  //  UIGestureRecognizer *recognizer = (UIGestureRecognizer*) sender;
    if (sender.state == UIGestureRecognizerStateEnded)
        [self viewMode:NULL];

   
}

-(void)cloneBut:(UILongPressGestureRecognizer*)sender
{
    //  UIGestureRecognizer *recognizer = (UIGestureRecognizer*) sender;
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        appDelegate.clonef=YES;
        [self addBFF:NULL];
    }
}

-(void)showVals:(NSString*) text
{
    typedef enum {CLOSED,OPENNING,OPENED,CLOSING} stateType;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *texto;

        NSArray* partes=[text componentsSeparatedByString:@"!"];

        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [_opens.layer addAnimation:animation forKey:@"kCATransitionFade"];
        animation.duration = 1.5;
        [_aborted.layer addAnimation:animation forKey:@"kCATransitionFade"];
        animation.duration = 2.0;
        [_guards.layer addAnimation:animation forKey:@"kCATransitionFade"];
        _opens.textColor= [petName textColor];
        _aborted.textColor= [petName textColor];
        _guards.textColor= [petName textColor];
        
        if(partes.count>8)
        {
        _opens.text=partes[1];
        _aborted.text=partes[2];
        _guards.text=partes[4];
        [onOff setImage:[UIImage imageNamed:[partes[7] integerValue]? @"on":@"off"] forState:UIControlStateNormal];
        stateType elestado=[partes[8]  integerValue];
            switch(elestado){
                case CLOSED:
                    texto=@"Closed";
                    break;
                case OPENED:
                    texto=@"Opened";
                    break;
                case CLOSING:
                    texto=@"Closing";
                    break;
                case OPENNING:
                    texto=@"Opening";
                    break;
                default:
                    texto=@"UNKNOWN";
            }
        _doorState.text=texto;
            
        }
    });
        }


-(void)setSleepMode
{
      dispatch_async(dispatch_get_main_queue(), ^{
          CATransition *animation = [CATransition animation];
          animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
          animation.type = kCATransitionFade;
          animation.duration = 0.5;
          [onOff.layer addAnimation:animation forKey:@"kCATransitionFade"];

    [onOff setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
          if(appDelegate.client)
              [appDelegate.client setMessageHandler:aca];
      });

}

-(void)setActiveMode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [onOff.layer addAnimation:animation forKey:@"kCATransitionFade"];
        [onOff setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
        if(appDelegate.client)
            [appDelegate.client setMessageHandler:aca];
    });

}
-(void)showMessage:(NSString*)que
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Server Information"
                                                                   message:que                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];

  //      dispatch_async(dispatch_get_main_queue(), ^(void){
            [self presentViewController:alert animated:YES completion:nil];
  //      });
//    });

}

-(void)setSleepMode:(NSString*)mensa
{
    NSArray *partes=[mensa componentsSeparatedByString:@"!"];
    
    if([partes[1] isEqualToString:@"Active Mode"])
    {
        [yo setActiveMode];
        
    }
    if([partes[1] isEqualToString:@"Sleep Mode"])
    {
        [yo setSleepMode];
        
    }

}
MQTTMessageHandler aca=^(MQTTMessage *message)
{
    char tcmd[2];
    uint8_t cmd;
    LogDebug(@"Incoming msg %@ %@",message.payload,message.payloadString);
    NSString *cmdstr=[message.payloadString substringToIndex:2];
    cmd=[cmdstr integerValue];
    //Cmds are
    // 3 -> not authorized show an alert
    // 5 -- status
    // 6 -- general info, show message in alert
    // 7 -- sleep message
    // 8 -- showm message for 5 seconds and disregard

    switch(cmd)
    {
        case 3:
        case 6:
            [yo showMessage:message.payloadString];
            break;
        case 5:
        [yo showVals:message.payloadString];
            break;
        case 7:
            [yo setSleepMode:message.payloadString];
            break;
        case 8:
            [yo showMensajeTimer:message.payloadString];
            break;
        default:
            break; //do nothing
    }

};


-(void)show{
    [comm lsender:@"status" andAnswer:NULL andTimeOut:2 vcController:self];
}

- (void)viewDidLoad {
  
    [super viewDidLoad];
    yo=self;
    passOn =    ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?[UIImage imageNamed:@"lockedbig.png"]:[UIImage imageNamed:@"locked.png"];
    passOff =     ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?  [UIImage imageNamed:@"unlockedbig.png"]:[UIImage imageNamed:@"unlocked.png"];
    [[NSUserDefaults standardUserDefaults] setObject:@"ga"  forKey:@"appId"];
    comm=[httpVC new];
    NSNumber *centinel= [[NSUserDefaults standardUserDefaults]objectForKey:@"centinel"];
    if (centinel.integerValue !=0x11223344)
        [self createDefaults];

   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:4] forKey:@"txTimeOut"];
  
    [album registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cvCell"];
//    colorCube = [[CCColorCube alloc] init];
    viewmodef=NO;
    batchf=NO;
    fotoHV=100;
    picScroll.hidden=NO;
    petName.hidden=NO;
    album.hidden=YES;
    fotoSize.transform = CGAffineTransformScale(CGAffineTransformIdentity, .75, 0.75);
    
    appDelegate =   (AppDelegate *)[[UIApplication sharedApplication] delegate];
    grid =          [UIImage imageNamed:@"grid.png"];
    pano =          [UIImage imageNamed:@"panorama.png"];
    answer=[NSMutableString string];
    appDelegate.messageType=0; //web service comm
    UILongPressGestureRecognizer *longPressBut = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cloneBut:)];
    [addBut addGestureRecognizer:longPressBut];

    //Load all BFF and insert imnages into scroll view. Keep the first one as workingRecord
 //   [self loadBffs];
    loadFlag=NO;
//    [appDelegate.workingBFF setValue:maca forKey:@"bffUID"];
    [self getArrays];
    [self startBonjour];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(appDelegate.workingBFF!=NULL)
        {
            [appDelegate startTelegramService:[[NSUserDefaults standardUserDefaults] objectForKey:@"mqttserver"] withPort:[[NSUserDefaults standardUserDefaults] objectForKey:@"mqttport"] complete:aca]; //connect to MQTT server
//    [appDelegate startTelegramService:[[NSUserDefaults standardUserDefaults] objectForKey:@"mqttserver"] withPort:@"18747"]; //connect to MQTT server
            if(appDelegate.client)
               [appDelegate.client setMessageHandler:aca];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [comm lsender:@"session?password=zipo" andAnswer:NULL andTimeOut:1 vcController:self];
            });
        }
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) passwordChange:(UIButton *)sw
{
    int cual=sw.tag?0:1;
    sw.tag=cual;
    [self OnOffStatePass:cual];
  }

-(void)OnOffStatePass:(int)como
{
    [UIView animateWithDuration:0.5 animations:^{
        passSW.alpha = 0.0f;
    } completion:^(BOOL finished) {
        passSW.imageView.animationImages = [NSArray arrayWithObjects:como?passOn:passOff,nil];
        [passSW.imageView startAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            passSW.alpha = 1.0f;
        }];
    }];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:como ] forKey:@"password"];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue==0)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


-(void)viewDidAppear:(BOOL)animated
{
    yo=self;
    appDelegate =   (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:aca];
    if(!loadFlag)
    {
        [self loadBffs];
        loadFlag=YES;
    }
    
    
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    [passSW setImage:passw.integerValue?passOn:passOff forState:UIControlStateNormal];
 //   if (passw.integerValue>0)
        if (0)

    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        LogDebug(@"passf %d",appDelegate.passwordf);
       if (!appDelegate.passwordf)
       {
           LogDebug(@"Need to get password");
           [self performSegueWithIdentifier:@"getPassword" sender:self];
       }
    }
  
    if(batchf)
    {
        [self loadBffs];
        batchf=NO;
    }
    //   petName.text = [appDelegate.workingBFF valueForKey:@"bffName"];
    
 //      NSString *uid=[[[UIDevice currentDevice]identifierForVendor]UUIDString];
//    LogDebug(@"Uid %@ ",uid);
    petName.text = [appDelegate.workingBFF valueForKey:@"bffName"];
    [[appDelegate.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld",(unsigned long)appDelegate.bffs.count]];
  //  [self OnOffState:(int)[[appDelegate.workingBFF valueForKey:@"bffOnOff"] integerValue]];

    if(appDelegate.workingBFF)
    {
        LogDebug(@"bffUID %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]);
        [appDelegate subscribeMQTT:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
    }
    
}

#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    // Make sure that we don't have such service already (why would this happen? not sure)
    //   LogDebug(@"Found service");
    if ( ! [appDelegate.feeders  containsObject:netService] ) {
        // Add it to our list
        [appDelegate.feeders  addObject:netService];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    //sort them for easy comparison agains WiFi Ap list if needed
    appDelegate.feeders = [[appDelegate.feeders sortedArrayUsingComparator:^NSComparisonResult(NSNetService* a, NSNetService* b) {
        NSString *first = a.name;
        NSString *second = b.name;
        return [first compare:second];
    }] mutableCopy];
    
    
    ////  LogDebug(@"Done BONJ %@",appDelegate.feeders);
    for (NSNetService *comida in appDelegate.feeders )
    {
        comida.delegate=self;
        //    LogDebug(@"comida %@",comida);
        [comida resolveWithTimeout:10.0];
    }
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    // Remove from list
    
       LogDebug(@"BJ Remove %@ name %@",netService,netService.name);
    NSString *nombre=netService.name;
    [appDelegate.feeders  removeObject:netService];
    [appDelegate.feed_addr removeObjectForKey:[nombre uppercaseString]];
    /*
    [UIView transitionWithView:connected
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    
    // if ([self findPartialKey:[[appDelegate.workingBFF valueForKey:@"bffName" ] uppercaseString]])
    connected.hidden=NO;
    */
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    struct sockaddr_in ip;
    uint16_t temp;
    NSString *dir;
    [[sender.addresses objectAtIndex:0]  getBytes: &ip length:sizeof(ip)];
    temp=CFSwapInt16HostToBig(ip.sin_port);
    int hay=(int)appDelegate.bffs.count;
    if(ip.sin_family == AF_INET)
    {
        char* serviceInAddr = inet_ntoa(ip.sin_addr);
     //   dir=[NSString stringWithFormat: @"http://%s/", serviceInAddr, temp];
     //   dir=[NSString stringWithFormat: @"%s/", serviceInAddr, temp];
       dir=[NSString stringWithFormat: @"http://%s:%d/", serviceInAddr, temp];

             LogDebug(@"Adding %@ %@",dir,[sender.name uppercaseString]);
        [appDelegate.feed_addr setObject:dir forKey:[sender.name uppercaseString]];
        if (hay>0)
        {
            for (NSManagedObject *cual in appDelegate.bffs)
            {
                if ([sender.name isEqualToString:[cual valueForKey:@"bffName"]]){
                    //    LogDebug(@"set lastip %@ for %@",dir, [cual valueForKey:@"bffName"]);
                    [cual setValue:dir forKey:@"bffLastIpPort"];
                }
            }
            /*
            if ([sender.name rangeOfString:[appDelegate.workingBFF valueForKey:@"bffName"]].location != NSNotFound)
            {
                [UIView transitionWithView:connected
                                  duration:0.4
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:NULL
                                completion:NULL];
                connected.hidden=YES;
                
            }
             */
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return appDelegate.imageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    miColl *myCell = [album dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
  
    UIImage *estaa=     [appDelegate.imageArray objectAtIndex:indexPath.row];
    myCell.im.image =   estaa;  //[appDelegate.imageArray objectAtIndex:indexPath.row];
                                //   NSArray *imgColors = [colorCube extractDarkColorsFromImage:estaa avoidColor:nil count:4];
 //   NSArray *imgColors = [colorCube extractColorsFromImage:estaa flags:CCAvoidBlack];

                                //  LogDebug(@"colors %@",imgColors);
                                //  UIImage *imm=[appDelegate.imageArray objectAtIndex:indexPath.row];
                                //  LogDebug(@"size %@",NSStringFromCGSize(imm.size));
    [myCell.im setContentMode:UIViewContentModeScaleAspectFill];
    myCell.name.text=[[appDelegate.bffs objectAtIndex:indexPath.row] valueForKey:@"bffName"];
    NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
    myCell.tag=indexPath.row;// using it?
    UITapGestureRecognizer *dobleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];//for chosing image
  //  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];//for chosing image
    dobleTap.numberOfTapsRequired = 2;
    [myCell addGestureRecognizer:dobleTap];
 //   [myCell addGestureRecognizer:singleTap];
   // [singleTap requireGestureRecognizerToFail:dobleTap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTap:)];
    [myCell addGestureRecognizer:longPress];
    
    UIView* esta=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100,100)];
    
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
   // UIColor *este=[appDelegate.appColors objectAtIndex:randomNumber];
  //  NSInteger randomNumber2 = arc4random() % (imgColors.count-1);
 //   UIColor *este=imgColors[(imgColors.count-1)/2];
    myCell.name.textColor=[appDelegate.appColors objectAtIndex:randomNumber];
 //   myCell.name.textColor=[appDelegate.appColors objectAtIndex:indexPath.row];

   //  myCell.name.textColor=imgColors[(imgColors.count-1)/3];
  //  UIColor *otro=[este colorWithAlphaComponent:0.40];
  //  fillLayer.fillColor = otro.CGColor;
 //   fillLayer.fillColor = este.CGColor;
    [esta.layer addSublayer:fillLayer];
    myCell.selectedBackgroundView=esta;
  /*
    if([self findPartialKey:[[[appDelegate.bffs objectAtIndex:indexPath.row] valueForKey:@"bffName"] uppercaseString]]) //anything greater 0
        myCell.wifi.image = [UIImage imageNamed:@"rssblue.png"];
    else
        myCell.wifi.image = [UIImage imageNamed:@"rss.png"];
*/
    return myCell;
}


#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [appDelegate unsubscribeMQTT:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
    indexOfPage=(int)indexPath.row;
    appDelegate.lastpos=indexOfPage;
    appDelegate.workingBFF=appDelegate.bffs[indexOfPage];
    [appDelegate subscribeMQTT:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
  
    //only subscribe unsubscribe
//    [appDelegate startTelegramService:[appDelegate.workingBFF valueForKey:@"bffMQTT"] withPort:@"1883"]; //connect to MQTT server

    [self getArrays];

  /*  //Draw Online/Offline Icon
    [UIView transitionWithView:connected
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
   */
}

-(void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
 //   miColl* datasetCell =(miColl*)[collectionView cellForItemAtIndexPath:indexPath];
    
    //  [datasetCell replaceHeaderGradientWith:[UIColor redColor]];
   // datasetCell.backgroundColor = [UIColor grayColor];
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   //   UIImage *imm=[appDelegate.imageArray objectAtIndex:indexPath.row];
    //  LogDebug(@"size %@",NSStringFromCGSize(imm.size));
        
     //   return imm.size;
        return CGSizeMake(fotoHV, fotoHV);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

@end
