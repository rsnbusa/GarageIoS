//
//  logViewerVC.m
//  FeedIoT
//
//  Created by Robert on 5/6/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "logViewerVC.h"
#import "logCell.h"
#import "httpVC.h"

@interface logViewerVC ()

@end

@implementation logViewerVC
@synthesize table,bffIcon;


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


-(void)removeMessages
{
  
}

-(IBAction)regresa:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)eraseLog:(id)sender
{
    [self showErrorMessage:@"Erase Log" andMessage:@"Clean all entries"];
}
-(void)showErrorMessage:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self borraLogs];
                                                              [logs removeAllObjects];// local core data but will be reloaded if not sent a blank mqtt to each bff
                                                              [self removeMessages];
                                                              [table reloadData];
                                                          }];
    
    [alert addAction:defaultAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                          }];
    
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void) borraLogs
{
 
}
-(void) checkLogin
{
    if (!appDelegate.passwordf)
    {
        //  NSLog(@"Need to get password again");
        [self performSegueWithIdentifier:@"getPassword" sender:self];
    }
}

- (void)viewDidLoad {
    bool reply;
    [super viewDidLoad];
    comm=[httpVC new];
    NSString *aanswer;
    mis=@"logs";
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    lines=nil;
    NSNumber *passw=[[NSUserDefaults standardUserDefaults]objectForKey:@"password"];
    if (passw.integerValue>0)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [self workingIcon];
    reply=[comm lsender:mis andAnswer:&aanswer andTimeOut:[[[NSUserDefaults standardUserDefaults]objectForKey:@"txTimeOut"] intValue] vcController:self];
    if (!reply)
    {
    //    [self showErrorMessage:@"Service Not Available" andMsg:@"Garage Not Online"];
        return;
    }
    else
    {
        if (![answer isEqualToString:@""])
            lines=[aanswer componentsSeparatedByString:@"|"];
    }
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return lines.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get a cell
    logCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logc" forIndexPath:indexPath];
    
    //set name of bff
 //   cell.bffname.text=[logs[indexPath.row] valueForKey:@"logBffName"];
    
    //set date
    NSArray *partes=[[lines objectAtIndex:indexPath.row] componentsSeparatedByString:@"?"];
    if(partes.count>0)
    cell.fecha.text=[partes objectAtIndex:1];
    if(partes.count>1)
    cell.bffname.text=[partes objectAtIndex:0];
    
    //get image of Bff
    
    return cell;
}
@end
