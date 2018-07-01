//
//  servingsVC.m
//  FeedIoT
//

#import "servingsVC.h"
#import "AppDelegate.h"
#import "FirstViewController.h" 

@implementation servingsVC
@synthesize bffIcon;


-(void)workingIcon
{
    UIImage *licon;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   // NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    bffIcon.image=licon;
}


-(IBAction)editingEnded:(id)sender{
    [sender resignFirstResponder];
}

-(IBAction)editingChange:(UITextField*)sender{

    changef=true;
}

-(IBAction)regresa:(id)sender
{
    [self performSegueWithIdentifier:@"menuReturn" sender:self];
}



-(IBAction)sliderTime:(UISlider*)sender{
    
    NSString *valor=[NSString stringWithFormat:@"%d",(int)sender.value];
    
    if (sender==_activate)  _tactivate.text=valor;
    if (sender==_relay)     _trelay.text=valor;
    if (sender==_wait)      _twait.text=valor;
    if (sender==_tx)        _ttx.text=valor;
    if (sender==_fault)     _tfault.text=valor;
    if (sender==_limbo)     _tlimbo.text=valor;
    changef=true;
}



/*
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
}*/

-(void)showErrorMessage:(NSString*)title andMsg:(NSString*)dile
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:dile
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        //  NSLog(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    answer=[NSMutableString string];
    changef=false;
    comm=[httpVC new];
    [self workingIcon];
    
    fc=(FirstViewController*)appDelegate.firstViewController;
    _activate.value= [[appDelegate.workingBFF valueForKey:@"bffActivateTime"] integerValue];
    _relay.value= [[appDelegate.workingBFF valueForKey:@"bffRelayTime"] integerValue];
    _wait.value= [[appDelegate.workingBFF valueForKey:@"bffCloseTime"] integerValue];
    _tx.value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue];
    _fault.value=[[appDelegate.workingBFF valueForKey:@"bffFaultRelay"] integerValue];;
    _limbo.value=[[appDelegate.workingBFF valueForKey:@"bffLimbo"] integerValue];;
    _tactivate.text= [NSString stringWithFormat:@"%d",(int)_activate.value];
    _trelay.text= [NSString stringWithFormat:@"%d",(int)_relay.value];
    _twait.text= [NSString stringWithFormat:@"%d",(int)_wait.value];
    _ttx.text= [NSString stringWithFormat:@"%d",(int)_tx.value];
    _tfault.text= [NSString stringWithFormat:@"%d",(int)_fault.value];
    _tlimbo.text= [NSString stringWithFormat:@"%d",(int)_limbo.value];
}

- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons
    
    [super viewWillDisappear:animated];
    if (changef)
    {
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger: (int)_activate.value] forKey:@"bffActivateTime"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger: (int)_relay.value] forKey:@"bffRelayTime"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger: (int)_wait.value] forKey:@"bffCloseTime"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger: (int)_fault.value] forKey:@"bffFaultRelay"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInteger: (int)_limbo.value] forKey:@"bffLimbo"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_tx.value] forKey:@"txTimeOut"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSManagedObjectContext *context =[appDelegate managedObjectContext];
        NSError *error;
        [context save:&error];
        mis=[NSString stringWithFormat:@"timers?activate=%d&relay=%d&close=%d&fault=%d&limbo=%d",(int)_activate.value,(int)_relay.value,(int)_wait.value,(int)_fault.value,(int)_limbo.value];//multiple arguments
        int reply=[comm lsender:mis andAnswer:answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
         if (!reply) [self showErrorMessage:@"Service Not Available" andMsg:@"Heater not Online"];
    }
}

@end
