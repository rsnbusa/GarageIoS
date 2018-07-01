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

extern BOOL CheckWiFi();

@interface mqttUser ()

@end

@implementation mqttUser

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
    [comm lsender:mis andAnswer:NULL andTimeOut:2 vcController:self];
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
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
    _server.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttserver"];
    _port.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttport"];
    _meterid.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttuser"];
    _startkwh.text= [[NSUserDefaults standardUserDefaults] objectForKey:@"mqttpass"];
    
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
