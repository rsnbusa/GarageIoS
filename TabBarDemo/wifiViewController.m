//
//  wifiViewController.m
//  FeedIoT
//
//  Created by Robert on 3/13/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "wifiViewController.h"
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "wifiCell.h"
@implementation wifiViewController
@synthesize myTable,bffIcon,webPort,fixip,webTemp,b1,b2,l1,l2,initer,clone;



-(uint)lsender: (NSString*) que andAnswer:(NSMutableString *) quedijo andTimeOut:(float) cuantoEspero

{
    NSString *final;
    
    //will add date and time to message to piggyback time management in the esp8266 with NO RTC
    NSArray *bits = [que componentsSeparatedByString: @"?"];
    bool hayf=bits.count>1;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString  *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM:dd:yyyy"];
    NSString  *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    unsigned long utc=(unsigned long)timeZoneSeconds*-1;
 //   NSLog(@"Domain %@ port %d que %@",[appDelegate.workingBFF valueForKey:@"bffDomain"],[[appDelegate.workingBFF valueForKey:@"bffPort"]integerValue],que);
    if(![arranca isEqualToString:@"AP"])
    {
    if ([[appDelegate.workingBFF valueForKey:@"bffDomain"] isEqualToString:@""])
    {
        final=[NSString stringWithFormat:hayf?@"%@%@_%@&date=%@&time=%@&UTC=%lu&uid=%@&bff=%@&q=v":@"%@%@_%@?date=%@&time=%@&UTC=%lu&uid=%@&bff=%@&q=v",
               [appDelegate.workingBFF valueForKey:@"bffLastIpPort"],[[NSUserDefaults standardUserDefaults]  objectForKey:@"appId"],que,dateStr,timeStr,utc,[[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"]];
    }
    else
        
        final=[NSString stringWithFormat:hayf?@"http://%@:%ld/%@_%@&date=%@&time=%@&UTC=%lu&uid=%@&bff=%@&q=v":@"http://%@:%ld/%@_%@?date=%@&time=%@&UTC=%lu&uid=%@&bff=%@&q=v",[appDelegate.workingBFF valueForKey:@"bffDomain"],[[appDelegate.workingBFF valueForKey:@"bffPort"] integerValue],[[NSUserDefaults standardUserDefaults]  objectForKey:@"appId"],que,dateStr,timeStr,utc,[[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"]];
    }
    else
                final=[NSString stringWithFormat:hayf?@"http://%@/%@_%@&date=%@&time=%@&UTC=%lu&uid=%@&bff=%@&q=v":@"http://%@/%@_%@?date=%@&time=%@&UTC=%lu&uid=%@&bff=%@&q=v",@"192.168.4.1:81",[[NSUserDefaults standardUserDefaults]  objectForKey:@"appId"],que,dateStr,timeStr,utc,[[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"]];
    
    
  //  NSLog(@"Lsender -%@-%s",final,__func__);

    //need to sen UTC timing diff
//    NSString *final=[NSString stringWithFormat:hayf?@"%@&date=%@&time=%@&UTC=%lu&bff=%@":@"%@?date=%@&time=%@&UTC=%lu&bff=%@&uid=%@",que,dateStr,timeStr,utc,[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffUID"]];
 //   NSString *final=[NSString stringWithFormat:hayf?@"%@&date=%@&time=%@&UTC=%lu&bff=%@":@"%@?date=%@&time=%@&UTC=%lu&bff=%@&uid=%@",que,dateStr,timeStr,utc,@"s",@"s"];

 //   NSLog(@"Lsender %@ %s",final,__func__);
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:[NSURL URLWithString:final]
                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:cuantoEspero];
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if(error==nil)
    {
        NSMutableString *news=[[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(news !=NULL)
            [quedijo setString:news];
        else
            [quedijo setString:@""];
        return 1;
    }
    else
    {
      //  NSLog(@"error %@",error);
        return 0;
    }
}

-(uint)lsender: (NSString*) que withMes:(bool) show andAnswer:(NSMutableString *) quedijo

{
    //  [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    uint8_t quefue=[self lsender:que andAnswer:quedijo andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"."] intValue]];
    //  acti.hidden=true;
    // [acti stopAnimating];
    if (!quefue && show)
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ESP8266"
                                                                       message:quedijo
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return 1;
    }
    if (!quefue)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ESP8266"
                                                                       message:@"Probably sleeping. Hit the Wake Button"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return 0;
    }
    return 0;
    
}



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

-(IBAction)forcePort
{

    mis=[NSString stringWithFormat:@"http://%@:%ld/scan",@"192.168.4.1",webTemp.text.integerValue];//uid will be your controller CRITICAL for MQTT queues
    if( [self lsender:mis andAnswer:answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue]*2])
    {
       
        if (![answer  isEqual:@""])
            wifis = [answer componentsSeparatedByString: @"/"];
      //   NSLog(@"Force reload %@ wifis %@",answer,wifis);
        [myTable reloadData];
    }

}

-(IBAction)savePort
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Fixed Ip"
                                  message:[NSString stringWithFormat:@"You really want to change Ip and Port?"]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                      
                                                   [appDelegate.workingBFF setValue:[NSNumber numberWithInt:(int)[webPort.text integerValue]] forKey:@"bffPort"];
                                               //    NSLog(@"Web Port %d working %@",[webPort.text integerValue],appDelegate.workingBFF);
                                                   [appDelegate.workingBFF setValue:fixip.text forKey:@"bffLastIpPort"];
                                                   [appDelegate.bffs removeObject:appDelegate.workingBFF];
                                                   [appDelegate.bffs addObject:appDelegate.workingBFF];
                                                //    NSLog(@"Saving Fixed %@",appDelegate.workingBFF);
                                                
                                                   NSManagedObjectContext *context =
                                                   [appDelegate managedObjectContext];
                                                   NSError *error;
                                                   if(![context save:&error])
                                                   {
                                                       NSLog(@"Save error WiFi %@",error);
                                                       return;//if we cant save it return and dont send anything toi the esp8266
                                                   }
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                  // NSLog(@"Not Saving Fixed");
                                               }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)after_clean
{
 
    arranca=[self valueForKey:@"initer"];//same as argv from a main call . In the IB VC setting User defined runtime attribues. The variable name must be a Property to be accessed.
//    NSLog(@"initer %@",arranca);
    if ([arranca isEqualToString:@"AP"] )
       ipaddress=@"http://192.168.4.1:81/";
    else
          ipaddress=[appDelegate.workingBFF valueForKey:@"bffLastIpPort"];
    
        if([[appDelegate.workingBFF valueForKey:@"bffLastIpPort"] isEqualToString:@""])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Service Not Available"
                                                                           message:@"Heater Not Online"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
   /*     webPort.hidden=YES;
        webTemp.hidden=YES;
        fixip.hidden=YES;
        b1.hidden=YES;
        b2.hidden=YES;
        l1.hidden=YES;
        l2.hidden=YES;
    */
    
  
 //   fc=(FirstViewController*)appDelegate.firstViewController;
    answer=[NSMutableString string];
 //   NSLog(@"After %@",appDelegate.workingBFF);
  //  int cualport=81; //default
 //   if (appDelegate.workingBFF)
     int   cualport=(int)[[appDelegate.workingBFF valueForKey:@"bffPort"] integerValue] ;
    webPort.text= [NSString stringWithFormat:@"%d", cualport ];
   
//    NSLog(@"LastipPort %@",[appDelegate.workingBFF valueForKey:@"bffLastIpPort" ]);
    NSArray *subsubStrings=[[[ipaddress componentsSeparatedByString:@"/"] objectAtIndex:2] componentsSeparatedByString:@":"];
     fixip.text=[subsubStrings objectAtIndex:0];
  //  mis=[NSString stringWithFormat:@"%@scan",ipaddress];//uid will be your controller CRITICAL for MQTT queues
    mis=[NSString stringWithFormat:@"scan"];//uid will be your controller CRITICAL for MQTT queues
    int tm=[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue];
    if (tm<20) tm=20;
    if( [self lsender:mis andAnswer:answer andTimeOut:tm])
    {
        if (![answer  isEqualToString:@""])
        {
            wifis = [answer componentsSeparatedByString: @"/"];
            [myTable reloadData];
        }
        else
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Service Not Available"
                                                                           message:@"Heater Not Online"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
    }
    BOOL hide=NO;
    if([[appDelegate.workingBFF valueForKey:@"bffDomain"] isEqualToString:@""])
        hide=YES;
    /*
     webPort.hidden=hide;
     webTemp.hidden=hide;
     fixip.hidden=hide;
     b1.hidden=hide;
     b2.hidden=hide;
     l1.hidden=hide;
     l2.hidden=hide;
     */
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
 //   int whoAmI=appDelegate.lastpos;
    wifis=nil;
    [myTable reloadData];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(after_clean) userInfo:nil repeats:NO];//give him time to clean screen
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
    wifis=nil;
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)get_connection:(NSString*)thepass
{
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString  *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM:dd:yyyy"];
    NSString  *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    int cualport =(int)[[appDelegate.workingBFF valueForKey:@"bffPort"] integerValue];
  //  NSLog(@"Webport %d %@ %d",webPort.text.integerValue,webTemp,cualport);
      if(webPort!=NULL)
      {
    if (![webPort.text isEqualToString:@""])
        cualport=(int)webPort.text.integerValue;
    [appDelegate.workingBFF setValue:[NSNumber numberWithInt:cualport] forKey:@"bffPort"];
      }
    [appDelegate.workingBFF setValue:[NSNumber numberWithBool:NO] forKey:@"bffOffline"];

    /*
    NSString *uid=[[[UIDevice currentDevice]identifierForVendor]UUIDString];
    NSString *trimmedString=[uid substringFromIndex:MAX((int)[uid length]-17, 0)];
    [[NSUserDefaults standardUserDefaults] setObject:trimmedString  forKey:@"bffUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];*/
     NSString *trimmedString=[[NSUserDefaults standardUserDefaults] objectForKey:@"bffUID"];
    mis=[NSString stringWithFormat:@"apsetup?ap=%@&passw=%@&uid=%@&date=%@&time=%@&fixedip=%@&webport=%@",ap,thepass,trimmedString,dateStr,timeStr,fixip.text,webPort.text];
  //  if (clone.isOn)
  //  mis=[NSString stringWithFormat:@"%@apbatch?ssid=%@&passw=%@&uid=%@&date=%@&time=%@",ipaddress,ap,thepass,trimmedString,dateStr,timeStr];

    [self lsender:mis andAnswer:answer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue]*4];
    
    NSString *temp=[NSString stringWithFormat:@"http://%@:%@/",fixip.text,webPort.text];
   [appDelegate.workingBFF setValue:temp forKey:@"bffLastIpPort"];

    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    NSError *error;
    if(![context save:&error])
    {
        NSLog(@"Save error WiFi %@",error);
        return;//if we cant save it return and dont send anything toi the esp8266
    }

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:[NSString stringWithFormat:@"Connection to %@",ap]
                                  message:answer
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                               [appDelegate.workingBFF setValue:[NSNumber numberWithBool:NO] forKey:@"bffOffline"];
                             [self dismissViewControllerAnimated:YES completion:nil];
                             
                         }];

     [alert addAction:ok];
     [self performSelector:@selector(dismiss:) withObject:alert afterDelay:15.0];
}

-(void)dismiss:(UIAlertController*)alert
{
    if (alert){
       [self dismissViewControllerAnimated:YES completion:nil];
        alert=nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *wifiLink = [[wifis objectAtIndex:indexPath.row] componentsSeparatedByString:@":"];
    ap=[wifiLink objectAtIndex:0];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Password"
                                  message:[NSString stringWithFormat:@"Enter Password for %@",[wifiLink objectAtIndex:0]]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self performSelectorOnMainThread:@selector(get_connection:) withObject:[[alert textFields]objectAtIndex:0].text waitUntilDone:NO];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
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

    NSArray *wifiLink = [[wifis objectAtIndex:indexPath.row] componentsSeparatedByString:@":"];
    cell.nameLabel.text = [wifiLink objectAtIndex:0];
    int fuerza = (int)[[wifiLink objectAtIndex:1] integerValue];
    fuerza=abs(fuerza);
  //  NSLog(@"Fuerza %d",fuerza);
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
