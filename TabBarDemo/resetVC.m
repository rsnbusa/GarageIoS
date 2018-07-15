//
//  resetVC.m
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "resetVC.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@interface resetVC ()

@end

@implementation resetVC
id yo;
//extern BOOL CheckWiFi();

-(void)showMessage:(NSString*)title withMessage:(NSString*)que
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:que
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //       [self performSegueWithIdentifier:@"doneEditVC" sender:self];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

MQTTMessageHandler resetRx=^(MQTTMessage *message)
{
    LogDebug(@"DoorIoT msg %@ %@",message.payload,message.payloadString);
    dispatch_async(dispatch_get_main_queue(), ^{
        [yo showMessage:@"DoorIoT Msg" withMessage:message.payloadString];
    });
};

-(void)showMensaje:(NSString*)title withMessage:(NSString*)mensaje doExit:(BOOL)salir
{
    if(mitimer)
        [mitimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{[tumblrHUD hide]; });
    
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:mensaje
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              if (salir) exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)killBill
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMensaje:@"Meter Msg" withMessage:@"Comm Timeout" doExit:NO];
}

-(void)hud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) (_hhud.frame.origin.x),
                                                                  (CGFloat) (_hhud.frame.origin.y), 55, 20)];
        tumblrHUD.hudColor = _hhud.backgroundColor;
        [self.view addSubview:tumblrHUD];
        [tumblrHUD showAnimated:YES];
        mitimer=[NSTimer scheduledTimerWithTimeInterval:10
                                                 target:self
                                               selector:@selector(killBill)
                                               userInfo:nil
                                                repeats:NO];
    });
}


-(void)sendCmd:(NSString*)comando withTitle:(NSString*)title
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Please Confirm" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *lanswer;
        [self hud];
        if(appDelegate.client)
            [appDelegate.client setMessageHandler:resetRx];
        [comm lsender:comando andAnswer:NULL  andTimeOut:2 vcController:self];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
  
    // Present action where needed
    [self presentViewController:alert animated:YES completion:nil];
  
}


-(IBAction)firmware:(id)sender
{
    [self sendCmd:@"firmware?password=zipo" withTitle:@"Update Firmware"];
}

-(IBAction)reset:(id)sender
{
    [self sendCmd:@"reset?password=zipo" withTitle:@"Reset System"];
}

-(IBAction)resetStats:(id)sender
{
    [self sendCmd:@"resetstats?password=zipo" withTitle:@"Reset Log"];
}

-(void)workingIcon
{
    UIImage *licon;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //   NSString *final=[NSString stringWithFormat:@"%@.png",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *final=[NSString stringWithFormat:@"%@.txt",[appDelegate.workingBFF valueForKey:@"bffName"]];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:final];
    licon=[UIImage imageWithContentsOfFile:filePath];
    if (licon==NULL)
        licon = [UIImage imageNamed:@"camera"];//need a photo
    _bffIcon.image=licon;
}

- (void)viewDidLoad {
    yo=self;
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
      
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self workingIcon];
    yo=self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
