//
//  httpVC.m
//  FeedIoT
//
//  Created by Robert on 4/14/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "httpAVC.h"
#import "AppDelegate.h"

@implementation httpAVC

-(NSString*)findPartialKey:(NSString*)cual
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *monton=[appDelegate.feed_addr allKeys];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@", cual];
    NSArray * searchResults = [monton filteredArrayUsingPredicate:predicate];
    // NSLog(@"Find HTTP name %@ %@ %@",searchResults,cual,monton);
    if (searchResults.count>0)
        return [appDelegate.feed_addr valueForKey:[searchResults objectAtIndex:0]];
    else
        return NULL;
}

-(uint)lsender: (NSString*) que andAnswer:(NSMutableString *) quedijo andTimeOut:(float) cuantoEspero vcController:(id)quien

{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if( [[appDelegate.workingBFF valueForKey:@"bffLastIpPort"] isEqualToString:@""]) return NO;
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
    //need to send UTC timing diff
    
    NSString *final=[NSString stringWithFormat:hayf?@"%@%@&date=%@&time=%@&UTC=%lu&uid=%@&bff=%@":@"%@%@?date=%@&time=%@&UTC=%lu&uid=%@&bff=%@",
                     //       [appDelegate.workingBFF valueForKey:@"bffLastIpPort"],que,dateStr,timeStr,utc,[appDelegate.workingBFF valueForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"]
                     [appDelegate.workingBFF valueForKey:@"bffLastIpPort"],que,dateStr,timeStr,utc,[[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"]];
   // NSLog(@"Lsender %@ %s",final,__func__);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:final]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSMutableString *news=[[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if(news !=NULL)
                    [quedijo setString:news];
                else
                    [quedijo setString:@""];
            }] resume];
    
    return YES;
    
}


@end
