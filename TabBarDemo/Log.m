//
//  Log.m
//  GarageIoT
//
//  Created by Robert on 6/15/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "Log.h"
#import "LogCell.h"

@interface Log ()

@end

@implementation Log


id yo;

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

-(NSDictionary*)getLogEntry:(NSData*) data from:(int)desde
{
    int integ;
    uint16_t code,code1,len;
    
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    
    NSRange rango=NSMakeRange(desde, 4);
    [data getBytes:&integ range:rango];
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:integ];
  //  NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
  //  NSDate *date = [date1 dateByAddingTimeInterval:timeZoneSeconds];
    rango=NSMakeRange(desde+4,2);
    [data getBytes:&code range:rango];
    NSNumber *codigo=[NSNumber numberWithInt:code];
    rango=NSMakeRange(desde+6,2);
    [data getBytes:&code1 range:rango];
    NSNumber *codigo1=[NSNumber numberWithInt:code1];
    NSDictionary * dic =[[NSDictionary alloc]
                         initWithObjectsAndKeys:date1,@"date",codigo,@"code",codigo1,@"code1",[appDelegate.logText objectAtIndex:code],@"mess",nil] ;
    return(dic);
}

-(void)showlog:(NSData *)data
{
   // NSLog(@"Datos:%@ len %u",data,(unsigned long)data.length);
    uint16_t desde,len,codeid;
    NSRange rango=NSMakeRange(0, 2);
    [data getBytes:&codeid range:rango];
    rango=NSMakeRange(2, 2);
    [data getBytes:&len range:rango];
    if(len!=0xa0a0 && codeid !=0x3939) //Centinel MSg is A0A0
    {
        NSLog(@"Wrong centinel\n");
        return;
    }
    long sobran=data.length-4;
    desde=4;
    while(sobran>0)
    {
        NSDictionary *entry=[self getLogEntry:data from:desde];
       len=[entry[@"len"] integerValue];
        desde+=8;
        sobran-=8;
        [entries addObject:entry];
    //   NSLog(@"Date %@ Code %@ Message:%@",entry[@"date"],entry[@"code"],entry[@"mess"]);
        
    }
      dispatch_async(dispatch_get_main_queue(), ^{
    [_table reloadData];
      });
}

MQTTMessageHandler llog=^(MQTTMessage *message)
{
    [yo showlog:message.payload];
};

- (void)viewDidLoad {
    [super viewDidLoad];
    comm=[httpVC new];
    entries=[[NSMutableArray alloc] initWithCapacity:20];
}

- (void)viewDidAppear:(BOOL)animated {
   
    yo=self;
    appDelegate =   (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self workingIcon];

    if(appDelegate.client)
        [appDelegate.client setMessageHandler:llog];
    [entries removeAllObjects];
    [super viewDidAppear:animated];
    [comm lsender:@"readlog?password=zipo" andAnswer:NULL andTimeOut:2 vcController:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return entries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int codenum;
    LogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
    
    UIView * theContentView = [[UIView alloc]initWithFrame:CGRectMake(0,0,_table.bounds.size.width,5)];
    theContentView.backgroundColor = [UIColor grayColor];//contentColor
    [cell addSubview: theContentView];
     NSInteger randomNumber = arc4random() % (appDelegate.appColors.count -1);
   NSDictionary *entry = [entries objectAtIndex:indexPath.row] ;
    cell.mensaje.text = entry[@"mess"];
    codenum=[entry[@"code"] integerValue];
    cell.backgroundColor= [appDelegate.appColors objectAtIndex:codenum];
    NSString *rsimage=[NSString stringWithFormat:@"codeimg%d",codenum];
    cell.codeImage.image=[UIImage imageNamed:rsimage];
    if(cell.codeImage.image==NULL)
        cell.codeImage.image=[UIImage imageNamed:@"general"];
      codenum=[entry[@"code1"] integerValue];
    cell.code1.text=[NSString stringWithFormat:@"%d",codenum];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
   [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:entry[@"date"]];
    cell.hora.text=dateString;
    [dateFormat setDateFormat:@"dd/MM/yy"];
    dateString = [dateFormat stringFromDate:entry[@"date"]];
    cell.dia.text=dateString;
    return cell;
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
