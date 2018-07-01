//
//  launchVC.m
//  FoodIoT
//
//  Created by Robert on 3/4/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "launchVC.h"

@implementation launchVC
@synthesize label;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *string =@"FoodIoT";
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:string forKey:@"string"];
    [dict setObject:@0 forKey:@"currentCount"];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(typingLabel:) userInfo:dict repeats:YES];
    [timer fire];
    
    
}

-(void)typingLabel:(NSTimer*)theTimer
{
    NSString *theString = [theTimer.userInfo objectForKey:@"string"];
    int currentCount = [[theTimer.userInfo objectForKey:@"currentCount"] intValue];
    currentCount ++;
    NSLog(@"%@", [theString substringToIndex:currentCount]);
    
    [theTimer.userInfo setObject:[NSNumber numberWithInt:currentCount] forKey:@"currentCount"];
    
    if (currentCount > theString.length-1) {
        [theTimer invalidate];
    }
    
    [self.label setText:[theString substringToIndex:currentCount]];
}
@end
