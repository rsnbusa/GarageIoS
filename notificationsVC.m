//
//  notificationsVC.m
//  FeedIoT
//
//  Created by Robert on 4/1/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "notificationsVC.h"
#import "AppDelegate.h"
#import "FirstViewController.h"
#import "TextFieldValidator.h"
#import "httpVC.h"
#import "emailCellTableViewCell.h"
#import "btSimplePopUp.h"

@implementation notificationsVC

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@synthesize mqtt,notis,IFTTT,domain,bffIcon,exception,emailTable,editab;

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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"TimeOut"
                                                                   message:@"Maybe out of range or off."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [backGroundBlurr removeFromSuperview];
                                                              //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showOkMessage:(NSString *)title
{
    [self blurScreen];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:[NSString stringWithFormat:@"Confirmed by %@",[appDelegate.workingBFF valueForKey:@"bffName"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
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

    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    bffIcon.image=licon;
}

- (IBAction)pickerAction:(UIDatePicker*)sender
{
    changef=true;
}


-(IBAction)regresa:(id)sender
{
    if (changef)
    {
        [appDelegate.workingBFF setValue:[domain.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"bffDomain"];
        [appDelegate.workingBFF setValue:[mqtt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"bffMQTT"];
        
      //  int excep=exception.isOn;
        
        NSManagedObjectContext *context =
        [appDelegate managedObjectContext];
        NSError *error;
        if(![context save:&error])
        {
            NSLog(@"Save error Notifications %@",error);
            return;//if we cant save it return and dont send anything toi the esp8266
        }
        NSString *stIF=[NSString stringWithFormat:@"%@",[IFTTT.text isEqualToString:@""]?@"%20":IFTTT.text];//update server
        NSString *stMQ=[NSString stringWithFormat:@"%@",[mqtt.text isEqualToString:@""]?@"%20":mqtt.text];
        mis=[NSString stringWithFormat:@"notifications?mqtt=%@&uid=%@&domain=%@",stMQ,[[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],stIF];//multiple arguments
        int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        if (!reply)
           [self showErrorMessage];
        else
        {
            if(oldtrans==0 && (int)notis.selectedSegmentIndex==1)
                [appDelegate startTelegramService:[appDelegate.workingBFF valueForKey:@"bffMQTT"] withPort:@"1883"]; //connect to MQTT server
            [self performSegueWithIdentifier:@"notiRegresa" sender:self];
        }
        
    }
    else
        [self performSegueWithIdentifier:@"notiRegresa" sender:self];

    
}

-(IBAction)cancel:(id)sender{
  //    [appDelegate.emailsArray removeAllObjects];
 //   appDelegate.emailsArray =[copyArray mutableCopy];
     [self performSegueWithIdentifier:@"notiRegresa" sender:self];
}

-(IBAction)editingBegin:(UITextField*)sender{
    copyemail=[sender.text mutableCopy];
 //   NSLog(@"To edit address %@",copyemail);
}

-(IBAction)editingEnded:(UITextField*)sender{
    
    [sender resignFirstResponder];
    if(sender==mqtt || sender==domain || sender==IFTTT) return;
    
    //Get the cell to access fields inside
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    emailCellTableViewCell *tempCell = [emailTable cellForRowAtIndexPath:tempIndexPath];
    int lexception=tempCell.rule.isOn;
    
    NSString *trimmed=[tempCell.emailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trim2=[tempCell.emailName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSManagedObject *cual=[appDelegate.emailsArray objectAtIndex:sender.tag];
    [cual setValue:trimmed forKey:@"address"];
    [cual setValue:trim2 forKey:@"emailName"];
    
    changef=YES;
    
    mis=[NSString stringWithFormat:@"changeEmail?address=%@&pos=%d&ex=%d&name=%@",trimmed,(int)sender.tag,lexception,trim2];//multiple arguments
    int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply)
        [self showErrorMessage];
  //  else
    //    [self showOkMessage:@"Email changed"];

}

-(IBAction)editingChange:(UITextField*)sender{
    changef=true;
    return;
    
    
    if(sender ==domain || sender==mqtt) return;
    
    NSManagedObject *matches = nil;
    matches = [appDelegate.emailsArray objectAtIndex:sender.tag];
    [matches setValue:sender.text forKey:@"address"];
    mis=[NSString stringWithFormat:@"email?address=%@&pos=%ld",sender.text,sender.tag];//multiple arguments
 //   NSLog(@"send feeder %@",mis);
    //    int reply=[comm lsender:mis andAnswer:answer andTimeOut:2.0 vcController:self];
    //    if (!reply)
    //       [self showErrorMessage];
    //    else
    //      [self showOkMessage];

    
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
    changef=YES;
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

- (IBAction)exceptionChange:(UISwitch*)sender
{
    changef=true;
    NSManagedObject *matches = nil;
    matches = [appDelegate.emailsArray objectAtIndex:sender.tag];
    [matches setValue:[NSNumber numberWithInt:sender.isOn] forKey:@"rule"];

    
    mis=[NSString stringWithFormat:@"changeEmail?address=%@&pos=%d&ex=%d",[matches valueForKey:@"address"],(int)sender.tag,sender.isOn];//multiple arguments
    int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply)
        [self showErrorMessage];
    //  else
    //    [self showOkMessage:@"Email changed"];
}
-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        //  NSLog(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

-(IBAction)transportMode:(id)sender
{
  //  if(![mqtt.text isEqualToString:@""])
  //  {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)notis.selectedSegmentIndex] forKey:@"transport"];
        [appDelegate.workingBFF setValue:[NSNumber numberWithInt:(int)notis.selectedSegmentIndex] forKey:@"bffLimbo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        changef=YES;
  //  }
}

-(void)viewDidLoad
{
    int lnotis;
    [super viewDidLoad];
    comm=[httpVC new];
    mqtt.isMandatory=NO;
    domain.isMandatory=NO;
    IFTTT.isMandatory=NO;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];

    answer=nil;
    answer=[NSMutableString string];
    [self workingIcon];
    changef=false;

    mqtt.text=[appDelegate.workingBFF valueForKey:@"bffMQTT"];// update server name
    domain.text=[appDelegate.workingBFF valueForKey:@"bffDomain"];// domain name for Internet Access
    IFTTT.text=@"feediot.co.nf";
    NSNumber *transport=[appDelegate.workingBFF valueForKey:@"bffLimbo"];
    oldtrans=transport.integerValue;
  //  [appDelegate.workingBFF setValue:[NSNumber numberWithInt:(int)notis.selectedSegmentIndex] forKey:@"bffLimbo"];
    [notis setSelectedSegmentIndex:(long)transport.longValue];
    
/*
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (int a=0;a<7;a++)
        if (lnotis & (1<<a))
            [mutableIndexSet addIndex:a];
    [ notis setSelectedSegmentIndexes:mutableIndexSet];
 */
  //  if (IFTTT.text.length==0)
  //      [notis setEnabled:NO forSegmentAtIndex:2];
    exception.on=lnotis & 0x8;
    
}

- (void)viewWillDisappear:(BOOL)animated { //Is used as a Save Options if anything was changed Instead of Buttons
    [super viewWillDisappear:animated];
  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if(appDelegate.emailsArray.count>0)
        {
        [context deleteObject:(NSManagedObject*)[appDelegate.emailsArray objectAtIndex:indexPath.row]];
        [appDelegate.emailsArray removeObjectAtIndex:indexPath.row];
        NSMutableSet *eset=[appDelegate.workingBFF mutableSetValueForKey:@"correos"];
//        if (eset && eset.count>0)
   //         [eset removeObject:[appDelegate.emailsArray objectAtIndex:indexPath.row]];
   //     [appDelegate.workingBFF setValue:eset forKey:@"correos"];
        NSError *error;
        if(![context save:&error])
            NSLog(@"Save error %@",error);
        [emailTable reloadData];
        mis=[NSString stringWithFormat:@"delEmail?pos=%d",indexPath.row];//multiple arguments
        int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        if (!reply)
            [self showErrorMessage];
        
     //   else
        //    [self showOkMessage:@"Email Deleted"];
        }
    }
}

-(IBAction)editar:(UIButton *)sender {
    if (!editf)
    {
        editab.tintColor=[UIColor redColor];
        
        [emailTable setEditing:YES animated:YES];
    }
    else
    {
        editab.tintColor=[UIColor blueColor];
        [emailTable setEditing:NO animated:YES];
    }
    
    editf=!editf;
}

-(IBAction)manageException:(id)sender
{
    dirtyf=YES;
}

-(IBAction)adder:(id)sender
{
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSManagedObject *newEmail;
    newEmail = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Emails"
                  inManagedObjectContext:context];
    

    [newEmail setValue:@"@change to IFTTT ID" forKey:@"address"];
    [newEmail setValue:[NSNumber numberWithInt:1] forKey:@"rule"];
    [newEmail setValue:[appDelegate.workingBFF valueForKey:@"bffName"] forKey:@"bffName"];
    [newEmail setValue:@"Name" forKey:@"emailName"];
     NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
    [newEmail setValue:[appDelegate.appColors objectAtIndex:randomNumber] forKey:@"color"];
    [appDelegate.emailsArray addObject:newEmail];
    NSMutableSet *eset=[appDelegate.workingBFF mutableSetValueForKey:@"correos"];
    [eset addObject:newEmail];
    [appDelegate.workingBFF setValue:eset forKey:@"correos"];
    [emailTable reloadData];
    changef=YES; //make it save data permanently
    
        mis=[NSString stringWithFormat:@"addEmail?address=%@&exp=1&name=%@",@"gmail.com",@"Name"];//multiple arguments
        int reply=[comm lsender:mis andAnswer:NULL andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
        if (!reply)
           [self showErrorMessage];
     //   else
         //   [self showOkMessage:@"Email Added"];

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appDelegate.emailsArray.count;
    
}

#pragma mark - UITableViewDataSource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    emailCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"servingCell"];
    NSManagedObject *matches = nil;
    matches = [appDelegate.emailsArray objectAtIndex:indexPath.row];
    cell.emailAddress.text=[matches valueForKey:@"address"];
    cell.emailName.text=[matches valueForKey:@"emailName"];
    cell.emailAddress.tag=indexPath.row;
    cell.rule.tag=indexPath.row;
    cell.rule.on=[[matches valueForKey:@"rule"]integerValue];
   
    cell.emailAddress.textColor=[matches valueForKey:@"color"];
    cell.emailName.textColor=[matches valueForKey:@"color"];
    cell.rule.onTintColor = [matches valueForKey:@"color"];
    cell.rule.tintColor = [matches valueForKey:@"color"];
   
                                 
    cell.rule.on=[[matches valueForKey:@"rule"]integerValue];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //must pass data to next seque to edit
    
}


  
    @end

