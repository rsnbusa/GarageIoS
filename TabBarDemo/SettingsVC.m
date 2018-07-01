//
//  SettingsVC.m
//  FeedIoT
//

#import "SettingsVC.h"
@import QuartzCore;
#import "AppDelegate.h"
#import "httpVC.h"
#import "btSimplePopUp.h"

@implementation SettingsVC
@synthesize bsync,tsync,bffIcon,passSW;


-(IBAction)prepareForUnwindSet:(UIStoryboardSegue *)segue {
   
}

-(void)blurScreen
{
    CGRect screenSize = [UIScreen mainScreen].bounds;
    UIImage *screenShot = [self.view screenshot];
    UIImage *blurImage  = [screenShot blurredImageWithRadius:10.5 iterations:2 tintColor:nil];
    backGroundBlurr = [[UIImageView alloc]initWithImage:blurImage];
    backGroundBlurr.frame = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
    [self.view addSubview:backGroundBlurr];
}

- (NSString *)imageToNSString:(UIImage *)image
{
    NSData *data = UIImagePNGRepresentation(image);
    
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [UIImage imageWithData:data];
}


-(void)showErrorMessage:(NSString*)title andMsg:(NSString*)dile
{
        [self blurScreen];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:dile
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [backGroundBlurr removeFromSuperview];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
}


-(void)workingIcon
{
    UIImage *licon;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  //  NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];
    picfilePath= [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:picfilePath];
 //   NSLog(@"Image size w:%f h:%f",licon.size.width,licon.size.height);
    if (licon==NULL)
    {
        licon = [UIImage imageNamed:@"camera"];//need a photo
        picfilePath=nil;
    }
    bffIcon.image=licon;
}

-(void)rotatesync
{
    CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
    rotate.removedOnCompletion = FALSE;
    rotate.fillMode = kCAFillModeForwards;
    
    //Do a series of 5 quarter turns for a total of a 1.25 turns
    //(2PI is a full turn, so pi/2 is a quarter turn)
    [rotate setToValue: [NSNumber numberWithFloat: M_PI / 2]];
    rotate.repeatCount = 0xffffff;
    
    rotate.duration = 0.50;
    rotate.beginTime = 0;
    rotate.cumulative = TRUE;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [bsync.imageView.layer addAnimation: rotate forKey: @"rotateAnimation"];
}

-(void)manda:(int)a
{
     tsync.text=[NSString stringWithFormat:@"%d",a];
    
    //add each entry again
    NSManagedObject *este=[appDelegate.servingsArray objectAtIndex:a-1];
    [este setValue:[NSDate date] forKey:@"dateAdded"];
    uint8_t days=[[este valueForKey:@"servDays"]integerValue];
    NSString *myNewString = [[este valueForKey:@"servName"] stringByReplacingOccurrencesOfString:@"\\s"
                                                                    withString:@"%20"
                                                                       options:NSRegularExpressionSearch
                                                                         range:NSMakeRange(0, [[este valueForKey:@"servName"] length])];
    
    int diff=(int)[[este valueForKey:@"hastaDate"] timeIntervalSince1970]-(int)[[este valueForKey:@"servDate"]timeIntervalSince1970];
  //  NSLog(@"Servdate %@ HastaDate %@ diff %lu",[este valueForKey:@"servDate"],[este valueForKey:@"hastaDate"],diff);
    
    mis=[NSString stringWithFormat:@"sync?pos=%d&day=%d&fromdate=%d&duration=%d&id=%@&notis=%d&onOff=%d&temp=%d",a-1,days,(int)[[este valueForKey:@"servDate"]timeIntervalSince1970],diff, myNewString,(int)[[este valueForKey:@"servNotis"] integerValue],(int)[[este valueForKey:@"servOnOff"] integerValue],(int)[[este valueForKey:@"servTempMax"] integerValue]];//multiple arguments
    int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply) [self showErrorMessage:@"Service Not Available" andMsg:@"Heater not Online"];
   
}

-(void)doneSync
{
    [bsync.imageView.layer removeAllAnimations];
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn
                      animations:^{ tsync.alpha = 0;}
                    completion:nil];
    mis=[NSString stringWithFormat:@"save"];//multiple arguments
    int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply) [self showErrorMessage:@"Service Not Available" andMsg:@"Feeder not Online"];
    else{
        NSManagedObjectContext *context =[appDelegate managedObjectContext];
        NSError *error;
        [context save:&error];
    }
}

-(void)nada:(int)a
{
    if (a<=1) [self doneSync];//stop rotation
}

#define CUANTODELAY 0.25

-(void)syncThem
{
    double totals=0.0;
    tsync.hidden=NO;
    syncf=true;
    for (int a=(int)appDelegate.servingsArray.count; a>0; a--)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totals * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self manda:a];
        });
        totals +=CUANTODELAY;
        
        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totals * NSEC_PER_SEC));
        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
            [self nada:a];
        });
        totals+=CUANTODELAY;
    }
}
-(void) sendUpdateRequest
{
    mis=[NSString stringWithFormat:@"Firmware"];
    NSString *answer;
    int reply=[comm lsender:mis andAnswer:&answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
            if (!reply)
            [self showErrorMessage:@"Service Not Available" andMsg:@"Heater not Online"];
         else
    [self showErrorMessage:@"Firmware" andMsg:answer];
}

-(IBAction)updateFirmware:(id)sender
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Firmware Update"
                                                                   message:@"Heater will reboot after a while"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self sendUpdateRequest];
                                                              });
                                                          }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                          }];

    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

-(IBAction)startSync:(id)sender
{
    int reply;

     if (appDelegate.servingsArray.count==0)
     {
         mis=[NSString stringWithFormat:@"Zerousers"];
         reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
         if (!reply)
         {
         [self showErrorMessage:@"Service Not Available" andMsg:@"Heater Not Online"];
             return;
         }
         mis=[NSString stringWithFormat:@"save"];//multiple aruments
         reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
         if (!reply)
         {
            [self showErrorMessage:@"Service Not Available" andMsg:@"Heater Not Online"];
             return;
         }
     }
   else
    {
    mis=[NSString stringWithFormat:@"Zerousers"];
    reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        if (!reply)
        {
           [self showErrorMessage:@"Service Not Available" andMsg:@"Heater Not Online"];
            return;
        }
    
    tsync.text=@"";
    tsync.alpha=1.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rotatesync];
    });
          [self performSelectorOnMainThread:@selector(syncThem) withObject:NULL waitUntilDone:NO];
    }
}

-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        //  NSLog(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

-(void)OnOffState:(int)como
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
    
}

-(IBAction) passwordChange:(UIButton *)sw
{
    int cual=sw.tag?0:1;
    sw.tag=cual;
    [self OnOffState:cual];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:cual]  forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color{
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    comm=[httpVC new];
    llevo=1.0;
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    passOn =    ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?[UIImage imageNamed:@"lockedbig.png"]:[UIImage imageNamed:@"locked.png"];
    passOff =     ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)?  [UIImage imageNamed:@"unlockedbig.png"]:[UIImage imageNamed:@"unlocked.png"];
    passSW.tag=(int)[[[NSUserDefaults standardUserDefaults]objectForKey:@"password"] integerValue];
    [self OnOffState:passSW.tag];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString * answer;
    [super viewWillAppear:animated];

    appDelegate =[[UIApplication sharedApplication] delegate];
    fc=(FirstViewController*)appDelegate.firstViewController;
    [self OnOffState:(int)[[[NSUserDefaults standardUserDefaults]objectForKey:@"password"] integerValue]];
    [self workingIcon];

    /*
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Servings"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //  [request setReturnsObjectsAsFaults:NO];
    //get all
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    appDelegate.servingsArray = [[context executeFetchRequest:request
                                            error:&error] mutableCopy];
     */

}

@end
