//
//  Timers.m
//  MeterIoT
//
//  Created by Robert on 6/14/17.
//  Copyright © 2017 Colin Eberhardt. All rights reserved.
//

#import "Timers.h"

@interface Timers ()

@end

@implementation Timers

id yo;

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

-(IBAction)waitSlider:(UISlider*) sender
{
    _wait.text=[NSString stringWithFormat:@"%d",(int)sender.value];
    save=YES;
}

-(IBAction)guardsw:(UISwitch*) sender
{
    save=YES;
}

-(IBAction)autosw:(UISwitch*) sender
{
    save=YES;
}


-(IBAction)sleepSlider:(UISlider*) sender
{
    _sleep.text=[NSString stringWithFormat:@"%d",(int)sender.value];
    save=YES;

}

-(IBAction)motorSlider:(UISlider*) sender
{
    _motor.text=[NSString stringWithFormat:@"%d",(int)sender.value];
    save=YES;
    
}

-(IBAction)timeoutSlider:(UISlider*) sender
{
    _timeout.text=[NSString stringWithFormat:@"%d",(int)sender.value];
    save=YES;

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

-(void)showTimers:(NSArray*)partes{
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.75;
        [_wait.layer addAnimation:animation forKey:@"kCATransitionFade"];
        [_sleep.layer addAnimation:animation forKey:@"kCATransitionFade"];
        [_timeout.layer addAnimation:animation forKey:@"kCATransitionFade"];
        [_waitsl.layer addAnimation:animation forKey:@"kCATransitionFade"];
        [_sleepsl.layer addAnimation:animation forKey:@"kCATransitionFade"];
        [_timeoutsl.layer addAnimation:animation forKey:@"kCATransitionFade"];
         [_motorsl.layer addAnimation:animation forKey:@"kCATransitionFade"];
    if(partes.count>4)
    {
        int v=(int)[partes[1] integerValue]/1000;
        _wait.text=[NSString stringWithFormat:@"%d",v];
        _waitsl.value=(float)v;
        v=(int)[partes[3] integerValue]/1000;
        _sleep.text=[NSString stringWithFormat:@"%d",v];
        _sleepsl.value=(float)v;
        v=(int)[partes[2] integerValue]/1000;
        _timeout.text=[NSString stringWithFormat:@"%d",v];
        _timeoutsl.value=(float)v;

        if([partes[4] isEqualToString:@"0"])
            _guard.on=NO;
        else
            _guard.on=YES;
        if([partes[5] isEqualToString:@"0"])
            _autosend.on=NO;
        else
            _autosend.on=YES;
         v=(int)[partes[6] integerValue]/1000;
        _motor.text=[NSString stringWithFormat:@"%d",v];
        _motorsl.value=(float)v;
    }
    });
}

MQTTMessageHandler local=^(MQTTMessage *message)
{
    NSString *text = message.payloadString;
    LogDebug(@"MqttInTimers %@",text);
    NSArray* partes=[text componentsSeparatedByString:@"!"];
    [yo showTimers:partes];
};

- (void)viewDidLoad {
    yo=self;
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    viejo=appDelegate.client.messageHandler;
    [self workingIcon];
    comm=[httpVC new];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *lanswer;
    yo=self;
    save=false;
    _wait.text=@" ";
    _sleep.text=@" ";
    _timeout.text=@" ";
    _motor.text=@" ";
    appDelegate =   (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.client)
        [appDelegate.client setMessageHandler:local];
    
    [super viewDidAppear:animated];
    [comm lsender:@"settings?password=zipo" andAnswer:&lanswer andTimeOut:2 vcController:self];
   }

    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(save)
    {
    NSString * mmis=[NSString stringWithFormat:@"internal?password=zipo&guard=%d&auto=%d&wwww=%d&oott=%d&cctt=%d&sstt=%d&motor=%d",_guard.isOn,_autosend.isOn,(int)_waitsl.value*1000,
                     (int)_timeoutsl.value*1000,(int)_timeoutsl.value*1000,(int)_sleepsl.value*1000,(int)_motorsl.value*1000];
    
 //  if(appDelegate.client)
   //     [appDelegate.client setMessageHandler:viejo];
    [comm lsender:mmis andAnswer:NULL andTimeOut:2 vcController:self];
    }

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
