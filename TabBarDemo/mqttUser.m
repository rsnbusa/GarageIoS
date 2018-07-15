//
//  mqttUser.m
//  MeterIoT
//
//  Created by Robert on 2/9/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "mqttUser.h"
#import "httpVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"

#if 0 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif


extern BOOL CheckWiFi();

@interface mqttUser ()

@end

@implementation mqttUser
id yo;


-(void)killBill
{
    if(tumblrHUD)
        [tumblrHUD hide];
    [self showMensaje:@"DoorIoT Msg" withMessage:@"Comm Timeout" doExit:NO];
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
-(IBAction)update:(id)sender
{
    if([_meterid.text isEqualToString:@""] || [_startkwh.text isEqualToString:@""] || [_server.text isEqualToString:@""] || [_port.text isEqualToString:@""])
        return;
    [[NSUserDefaults standardUserDefaults] setObject:[_server.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttserver"];
    [[NSUserDefaults standardUserDefaults] setObject:[_port.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttport"];
    [[NSUserDefaults standardUserDefaults] setObject:[_meterid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttuser"];
    [[NSUserDefaults standardUserDefaults] setObject:[_startkwh.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"mqttpass"];
    [[NSUserDefaults standardUserDefaults]  synchronize];
    mis=[NSString stringWithFormat:@"internal?password=zipo&uupp=%@&passq=%@&qqqq=%@&port=%@",_meterid.text,_startkwh.text,_server.text,_port.text];
 //   NSLog(@"Mqtt send %@",mis);
    [self hud];
    [comm lsender:mis andAnswer:NULL andTimeOut:2 vcController:self];
}

MQTTMessageHandler mqttRx=^(MQTTMessage *message)
{
    LogDebug(@"Incoming msg %@ %@",message.payload,message.payloadString);
    [yo showMensaje:@"Meter Message" withMessage:message.payloadString doExit:NO];
};

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
    [super viewDidLoad];
    yo=self;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _server.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttserver"];
    _port.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttport"];
    _meterid.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttuser"];
    _startkwh.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttpass"];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    yo=self;
    if(appDelegate.client){
        [appDelegate.client setMessageHandler:mqttRx];
    }
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
