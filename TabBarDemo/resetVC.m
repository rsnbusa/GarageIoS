//
//  resetVC.m
//  MeterIoT
//
//  Created by Robert on 2/8/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "resetVC.h"

@interface resetVC ()

@end

@implementation resetVC

//extern BOOL CheckWiFi();

-(void)sendCmd:(NSString*)comando withTitle:(NSString*)title
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Please Confirm" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *lanswer;
        [comm lsender:comando andAnswer:&lanswer  andTimeOut:2 vcController:self];
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
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];
    comm=[httpVC new];
      
}

/*
-(void)viewDidAppear:(BOOL)animated
{
    [self viewDidAppear:animated];
    [self workingIcon];

}
 */
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
