//
//  petInfoViewController.m
//  FeedIoT
//
//  Created by Robert on 3/13/16.
//

#import "petInfoViewController.h"
#import "AppDelegate.h"
#import "FirstViewController.h"
#import "TextFieldValidator.h"
#import "httpVC.h"
#import "wifiCell.h"
#import "btSimplePopUp.h"
#import "MBProgressHUD.h"

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

#define MOVEUP 40.0

@implementation petInfoViewController
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;


@synthesize petName,phone,email,bffIcon,bjTable,bfname,vetphone,emaill,birth,watts,galons,kwh,volts,water,offline,group,transport,limit;


-(void)blurScreen
{
    CGRect screenSize = [UIScreen mainScreen].bounds;
    UIImage *screenShot = [self.view screenshot];
    UIImage *blurImage  = [screenShot blurredImageWithRadius:10.5 iterations:2 tintColor:nil];
    backGroundBlurr = [[UIImageView alloc]initWithImage:blurImage];
    backGroundBlurr.frame = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
    [self.view addSubview:backGroundBlurr];
}

-(void)showErrorMessage
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"TimeOut"
                                                                   message:@"Maybe out of range or off"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              [self performSelectorOnMainThread:@selector(cancela:) withObject:NULL waitUntilDone:NO];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:que                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              [self performSegueWithIdentifier:@"returnFirst" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showMessageCancel:(NSString*)title withMessage:(NSString*)que
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:que                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              [self cancela:NULL];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)cancela:(id)sender
{
    bjTable.hidden=YES;
    if(appDelegate.addf)
    {
        appDelegate.addf=NO;

    // need to redo the scrollview to Shrink it by one and remove added subview which has a tag to 1 greater bffs.count and scroll to launched position
    //set workingbff to saved bff, oldbff-> name effect
    [[appDelegate managedObjectContext] deleteObject:appDelegate.workingBFF];
    appDelegate.workingBFF=appDelegate.oldbff;
    //appDelegate.workingBFF=NULL;

    fc=(FirstViewController*)appDelegate.firstViewController;
    [appDelegate.imageArray removeLastObject];//remove image entry we made
    CGFloat width = fc.picScroll.frame.size.width;
    CGFloat heigth = fc.picScroll.frame.size.height;
    fc.picScroll.contentSize = CGSizeMake(width * appDelegate.bffs.count, heigth); //size now correct
    //remove subview
    UIView *esta=[fc.picScroll viewWithTag:appDelegate.bffs.count+1];
    [esta removeFromSuperview];
    // set view to saved last view
    [fc.picScroll scrollRectToVisible: CGRectMake(width * appDelegate.lastpos, 0, width, heigth) animated: false];
    }
    [self performSegueWithIdentifier:@"returnFirst" sender:self];
}


-(IBAction)regresa:(id)sender
{
    NSIndexPath *selectedIndexPath = [bjTable indexPathForSelectedRow];
  //  NSLog(@"regresa %@",appDelegate.workingBFF);
    if (appDelegate.addf || appDelegate.clonef)
    {
        if(appDelegate.addf && !appDelegate.clonef)
        {
            if (selectedIndexPath==NULL && !offline.isOn)
            {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"DoorIoT"
                                              message:[NSString stringWithFormat:@"Please select a WiFi"]
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                           }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        }
        NSString* result = [petName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
        NSString *myNewString = [result stringByReplacingOccurrencesOfString:@"\\s"
                                                                  withString:@"%20"
                                                                     options:NSRegularExpressionSearch
                                                                       range:NSMakeRange(0, [result length])];// spaces in between are changed to %20
        for (NSManagedObject *tbff in appDelegate.bffs)
            if ([[tbff valueForKey:@"bffName"] isEqualToString:myNewString])
            {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Door Name"
                                              message:[NSString stringWithFormat:@"Door name already exists. Choose another"]
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                           }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return;
 
            }
        [appDelegate.workingBFF setValue:[NSNumber numberWithBool:offline.isOn] forKey:@"bffOffline"];
        [appDelegate.workingBFF setValue:petName.text forKey:@"bffName"];
        [appDelegate.workingBFF setValue:phone.text forKey:@"bffPhone"];
        [appDelegate.workingBFF setValue:email.text forKey:@"bffEmail"];
        [appDelegate.workingBFF setValue:group.text forKey:@"bffGroup"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:[_whichMeter selectedSegmentIndex]] forKey:@"bffWatts"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:81] forKey:@"bffPort"];

        NSManagedObjectContext *context =[appDelegate managedObjectContext];
        [appDelegate.workingBFF setValue:appDelegate.direccion forKey:@"bffLastIpPort"];
 //       NSLog(@"Add working %@",appDelegate.workingBFF);
        [appDelegate.bffs addObject:appDelegate.workingBFF];
//        NSLog(@"Adding bff %@ ",appDelegate.bffs);
     
    
        NSError *error;
         if(![context save:&error])
         {
         LogDebug(@"Save error %@",error);
         return;//if we cant save it return and dont send anything toi the esp8266
         }
         
         

      //  [appDelegate.feed_addr setValue:appDelegate.direccion forKey:[petName.text uppercaseString]];
        changef=YES;
     //   LogDebug(@"Adding BFF Feed adr %@",appDelegate.feed_addr);
    }
    if ( [petName validate])
    {
    if (changef )
    {

        LogDebug(@"changef %@",appDelegate.workingBFF);
        petName.text = [petName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
        email.text = [email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
        group.text = [group.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
 //       if([email.text isEqualToString:@""])
 //           email.text=petName.text;
        NSMutableCharacterSet *chars = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy;
        [chars removeCharactersInRange:NSMakeRange('&', 1)]; // %26
        NSString *heatURL = [petName.text stringByAddingPercentEncodingWithAllowedCharacters:chars];
        if([group.text isEqualToString:@""])
            group.text=petName.text;
        NSString *groupURL=[group.text stringByAddingPercentEncodingWithAllowedCharacters:chars];
        NSString *emailURL=[email.text stringByAddingPercentEncodingWithAllowedCharacters:chars];
        NSString *lanswer;
        int reply;
        if(!appDelegate.addf && !appDelegate.clonef)// ojo clonef logic
        {
        mis=[NSString stringWithFormat:@"generalap?meter=%@&group=%@&watts=%ld&volts=%ld&galons=%ld&kwh=%.2f&email=%@&autoTemp=%d&SubMeter=%d",heatURL,groupURL, watts.text.integerValue,volts.text.integerValue,galons.text.integerValue,kwh.text.floatValue,emailURL,limit.isOn,(int)_whichMeter.selectedSegmentIndex];//multiple arguments
        reply=[comm lsender:mis andAnswer:&lanswer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        }
        else
            reply=1; //force clone
        if(!reply)
            [self showErrorMessage];
        else
        {
            
            [appDelegate.workingBFF setValue:petName.text forKey:@"bffName"];
            [appDelegate.workingBFF setValue:phone.text forKey:@"bffPhone"];
            [appDelegate.workingBFF setValue:email.text forKey:@"bffEmail"];
            [appDelegate.workingBFF setValue:group.text forKey:@"bffGroup"];
            [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:[_whichMeter selectedSegmentIndex]] forKey:@"bffWatts"];
            [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:81] forKey:@"bffPort"];
            
            NSManagedObjectContext *context =
            [appDelegate managedObjectContext];
            NSError *error;
            if(![context save:&error])
            {
                LogDebug(@"Save error Info %@",error);
                return;//if we cant save it return and dont send anything toi the esp8266
            }
            if([[appDelegate.workingBFF valueForKey:@"bffOffline"] boolValue])
            {
                NSString *mess=[NSString stringWithFormat:@"%@ was successfully added. Now connect to WiFi named %@ ",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"]];
                [self showMessage:@"New Door" withMessage:mess];
            }
            else
                [self performSegueWithIdentifier:@"returnFirst" sender:self];
        }
    }
    else
            [self performSegueWithIdentifier:@"returnFirst" sender:self];
    }

}

-(IBAction)editingEnded:(UITextField*)sender{

    [sender resignFirstResponder];

}

-(IBAction)editingChange:(UITextField*)sender{
    changef=true;
}

-(IBAction)workMode:(UISwitch*)sender{
    
    _opmode.text=sender.isOn?@"Offline Mode":@"Online Mode";
     [appDelegate.workingBFF setValue:[NSNumber numberWithBool:offline.isOn] forKey:@"bffOffline"];
    [appDelegate.workingBFF setValue:@0 forKey:@"bffLimbo"];
    [self performSegueWithIdentifier:@"returnFirst" sender:self];
    changef=YES;
}

-(IBAction)autoTemp:(UISwitch*)sender{
    
    [appDelegate.workingBFF setValue:[NSNumber numberWithBool:limit.isOn] forKey:@"bffRelayTime"];
    changef=YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (IBAction)segmentedAction:(UISegmentedControl*)sender
{
    changef=true;//touched now dirty
}

-(void)workingIcon
{
    UIImage *licon;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  //  NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];

    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    bffIcon.image=licon;
}

-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        LogDebug(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    comm=[httpVC new];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.oldbff=appDelegate.workingBFF;
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    email.keyboardType=UIKeyboardTypeEmailAddress;
    phone.keyboardType=UIKeyboardTypePhonePad;
    
    [petName addRegx:@"^.{3,20}$" withMsg:@"Your Remote name should have at least 3-20 letters"];
    email.isMandatory=NO;
    phone.isMandatory=NO;
    [self workingIcon];
    answer=nil;
    answer=[NSMutableString string];
    offline.transform = CGAffineTransformScale(CGAffineTransformIdentity, .75, 0.75);
    limit.transform = CGAffineTransformScale(CGAffineTransformIdentity, .75, 0.75);

//load from workingbff
  //  LogDebug(@"Working %@",appDelegate.workingBFF);
    petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];
    email.text=[appDelegate.workingBFF valueForKey:@"bffEmail"];
    phone.text=[appDelegate.workingBFF valueForKey:@"bffPhone"];
    group.text=[appDelegate.workingBFF valueForKey:@"bffGroup"];
    offline.on=[[appDelegate.workingBFF valueForKey:@"bffOffline"] boolValue];
    limit.on=[[appDelegate.workingBFF valueForKey:@"bffRelayTime"] boolValue];
    _opmode.text=offline.isOn?@"Offline Mode":@"Online Mode";
    transport.selectedSegmentIndex=[[appDelegate.workingBFF valueForKey:@"bffLimbo"] integerValue];
    _whichMeter.selectedSegmentIndex=[[appDelegate.workingBFF valueForKey:@"bffWatts"] integerValue];

    //from byte with each bit defining a day of the week set the selected indices
  /*  UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [bjTable addGestureRecognizer:lpgr];
   */

  }

-(void)viewWillAppear:(BOOL)animated
{
    NSString *lanswer;

    [super viewWillAppear:animated];

    if (!appDelegate.passwordf)
    {
        LogDebug(@"Need to get password");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
    
    if (appDelegate.addf && !appDelegate.clonef)
    {
        bjTable.hidden=NO;
        mis=[NSString stringWithFormat:@"scan"];
        [appDelegate.workingBFF setValue:@"http://192.168.4.1/" forKey:@"bffLastIpPort"];
 //       int tm=[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue];
        int reply=[comm lsender:mis andAnswer:&lanswer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        if(!reply)
            [self showErrorMessage];
        else
        {
            if (![lanswer  isEqualToString:@""])
            {
                wifis=[lanswer componentsSeparatedByString:@"!"];
             //   if(partes.count>3)
              //  {
               // wifis = [partes[3] componentsSeparatedByString: @"|"];
                LogDebug(@"Wifis %@",wifis);
                [bjTable reloadData];
             //   }
            }
        }
    }
    [self workingIcon];
    petName.text=[appDelegate.workingBFF valueForKey:@"bffName"];

}

- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons   
    [super viewWillDisappear:animated];
    appDelegate.clonef=NO;
    
}

-(void)dismiss:(UIAlertController*)alert
{
    if (alert){
        [self dismissViewControllerAnimated:YES completion:nil];
        alert=nil;
    }
}

-(IBAction)transportChange:(UISegmentedControl*)sender
{
    [appDelegate.workingBFF setValue:[NSNumber numberWithInt:(int)sender.selectedSegmentIndex] forKey:@"bffLimbo"];
       NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSError *error;
    if(![context save:&error])
    {
        LogDebug(@"Save error %@",error);
        return;//if we cant save it return and dont send anything toi the esp8266
    }
    [self performSegueWithIdentifier:@"returnFirst" sender:self];

}

-(IBAction)meterChosen:(UISegmentedControl*)sender
{
    [appDelegate.workingBFF setValue:[NSNumber numberWithInt:(int)sender.selectedSegmentIndex] forKey:@"bffLimbo"];
    changef=YES;
}



-(void)get_connection:(NSString*)thepass
{

        dispatch_async(dispatch_get_main_queue(), ^{
                NSString *a,*b,*c,*d;
            a= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttserver"];
            b= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttport"];
            c= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttuser"];
            d= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttpass"];

    petName.text = [petName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
    email.text = [email.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
    group.text = [group.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//left and right trim spaces
    if([group.text isEqualToString:@""])
        group.text=petName.text;
    NSMutableCharacterSet *chars = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy;
    [chars removeCharactersInRange:NSMakeRange('&', 1)]; // %26
    NSString *heatURL = [petName.text stringByAddingPercentEncodingWithAllowedCharacters:chars];
    NSString *groupURL=[group.text stringByAddingPercentEncodingWithAllowedCharacters:chars];
    NSString *emailURL=[email.text stringByAddingPercentEncodingWithAllowedCharacters:chars];
    NSString *lanswer;
    
          
//
//
//           mis=[NSString stringWithFormat:@"internal?password=zipo&uupp=%@&pasw=%@&qqqq=%@&port=%@",a,d,c,b];
//            [comm lsender:mis andAnswer:NULL andTimeOut:2 vcController:self];
            
    mis=[NSString stringWithFormat:@"generalap?meter=%@&group=%@&email=%@&ap=%@&pass=%@&reset=1&uupp=%@&passq=%@&qqqq=%@&port=%@",heatURL,groupURL,emailURL,ap,thepass,c,d,a,b];//multiple arguments
       //     NSLog(@"Mqtt %@",mis);

 //   mis=[NSString stringWithFormat:@"generalap?meter=0&ap=%@&pass=%@&index=0",ap,thepass];
    int reply=[comm lsender:mis andAnswer:&lanswer andTimeOut:1000.0 vcController:self];
    if(!reply)
    {
        //timeout is that it could not connect. Try another password
     //   [self showErrorMessage];
        [self blurScreen];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Did Not Connect to WiFi"
                                                                       message:@"Probably bad password. If it persists, reset your WiFi"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [backGroundBlurr removeFromSuperview];
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [hud hideAnimated:YES];
                                                                  });
                                                                  [self performSelectorOnMainThread:@selector(cancela:) withObject:NULL waitUntilDone:NO];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        if ([lanswer isEqualToString:@"NO WIFI"])
        { //not happening but just in case
            LogDebug(@"No wifi explict");
            [self performSelectorOnMainThread:@selector(cancela:) withObject:NULL waitUntilDone:NO];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"transport"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInt:1] forKey:@"bffLimbo"];//Mqtt transport
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate.workingBFF setValue:petName.text forKey:@"bffName"];
        [appDelegate.workingBFF setValue:phone.text forKey:@"bffPhone"];
        [appDelegate.workingBFF setValue:email.text forKey:@"bffEmail"];
        if([group.text isEqualToString:@""])
            [appDelegate.workingBFF setValue:petName.text forKey:@"bffGroup"];
        else
            [appDelegate.workingBFF setValue:group.text forKey:@"bffGroup"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:watts.text.integerValue] forKey:@"bffWatts"];
//        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:volts.text.integerValue] forKey:@"bffVolts"];
//        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:galons.text.integerValue] forKey:@"bffGalons"];
//        [appDelegate.workingBFF setValue:[NSNumber numberWithFloat:kwh.text.floatValue] forKey:@"bffKwH"];
//        [appDelegate.workingBFF setValue:[NSNumber numberWithFloat:water.text.floatValue] forKey:@"bffWater"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithBool:offline.isOn] forKey:@"bffOffline"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger:81] forKey:@"bffPort"];

        LogDebug(@"General answer %@",lanswer);
        NSManagedObjectContext *context =
        [appDelegate managedObjectContext];
        NSError *error;
        if(![context save:&error])
        {
            LogDebug(@"Save error WiFi %@",error);
    //      return;//if we cant save it return and dont send anything toi the esp8266
            [self performSelectorOnMainThread:@selector(cancela:) withObject:NULL waitUntilDone:NO];
            return;
        }
  
        UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:[NSString stringWithFormat:@"Connection to %@",ap]
                                  message:@"Door succesfully added and connected"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                           //  dispatch_async(dispatch_get_main_queue(), ^{
                                 [hud hideAnimated:YES];
                           //  });
                             [appDelegate.workingBFF setValue:[NSNumber numberWithBool:NO] forKey:@"bffOffline"];
                             [self dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
        [alert addAction:ok];
        dispatch_async(dispatch_get_main_queue(), ^{
      
        [self presentViewController:alert animated:YES completion:nil];
              });

   //     [self performSelector:@selector(dismiss:) withObject:alert afterDelay:15.0];
    }
            });
}

- (void)get_connection_pre:(NSString*)thepass {
    // Show the HUD on the root view (self.view is a scrollable table view and thus not suitable,
    // as the HUD would move with the content as we scroll).
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Setting WiFi";

    // Fire off an asynchronous task, giving UIKit the opportunity to redraw wit the HUD added to the
    // view hierarchy.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSString *a,*b,*c,*d;
        a= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttserver"];
        b= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttport"];
        c= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttuser"];
        d= [[NSUserDefaults standardUserDefaults]objectForKey:@"mqttpass"];
        if(a.length==0 || b.length==0 || c.length==0 || d.length==0){
            [self showMessageCancel:@"MqttServer Settings" withMessage:@"Need to set servers setting"];
            return;
        }
        // Do something useful in the background
        [self get_connection:thepass];
        
        // IMPORTANT - Dispatch back to the main thread. Always access UI
        // classes (including MBProgressHUD) on the main thread.

    });
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *wifiLink = [[wifis objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
    ap=[wifiLink objectAtIndex:0];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Password"
                                  message:[NSString stringWithFormat:@"Enter Password for %@",[wifiLink objectAtIndex:0]]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self performSelectorOnMainThread:@selector(get_connection_pre:) withObject:[[alert textFields]objectAtIndex:0].text waitUntilDone:NO];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self performSelectorOnMainThread:@selector(cancela:) withObject:NULL waitUntilDone:NO];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [wifis count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cualrssi=0;
    wifiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCell"];
    
    NSArray *wifiLink = [[wifis objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
    cell.nameLabel.text = [wifiLink objectAtIndex:0];
    int fuerza = (int)[[wifiLink objectAtIndex:1] integerValue];
    fuerza=abs(fuerza);
    //  LogDebug(@"Fuerza %d",fuerza);
    if (fuerza>=0 && fuerza<=20) cualrssi=5;
    else
        if (fuerza>20 && fuerza<=40) cualrssi=3;
        else
            if (fuerza>40 && fuerza<=80) cualrssi=2;
            else
                if (fuerza>80 && fuerza<=100) cualrssi=1;
                else
                    if (fuerza>100 && fuerza<=999) cualrssi=0;
    NSString *rsimage=[NSString stringWithFormat:@"rssi%d",cualrssi];
    cell.strongView.image=[UIImage imageNamed:rsimage];
    NSString *crypto = [wifiLink objectAtIndex:2];
    cell.passwordView.image=[crypto isEqualToString:@"*" ] ? [UIImage imageNamed:@"padlock.png"]:[UIImage imageNamed:@"padlock_open.png"];
    return cell;
}


@end
