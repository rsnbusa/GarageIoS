
#import "httpVC.h"
#import "AppDelegate.h"
#import "queueEntry.h"
#import "MQTTKit.h"
#import "queueEntry.h"

#if 1 // set to 1 to enable logs
#define LogDebug(frmt, ...) NSLog([frmt stringByAppendingString:@"[%s]{%d}"], ##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__);
#else
#define LogDebug(frmt, ...) {}
#endif

@implementation httpVC

-(NSString*)findPartialKey:(NSString*)cual
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *monton=[appDelegate.feed_addr allKeys];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@", cual];
    NSArray * searchResults = [monton filteredArrayUsingPredicate:predicate];
   // LogDebug(@"Find HTTP name %@ %@ %@",searchResults,cual,monton);
    if (searchResults.count>0)
    return [appDelegate.feed_addr valueForKey:[searchResults objectAtIndex:0]];
    else
        return NULL;
}
-(NSString*) makeJson:(NSString*)que
{
    NSArray *bits;
    NSArray *json = [que componentsSeparatedByString: @"/"];
    if(json.count>3)
        bits=[json[3] componentsSeparatedByString:@"?"];
    else
        bits=[que componentsSeparatedByString:@"?"];
    NSString *cmd=bits[0];
    NSArray *params=[bits[1] componentsSeparatedByString:@"&"];
    NSString *local=[NSString stringWithFormat:@"{\"batch\":[{\"cmd\":\"/%@\",",cmd];
    for (int a=0;a<params.count;a++)
    {
        bits=[params[a] componentsSeparatedByString:@"="];
        local=[local stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",bits[0],bits[1]]];
        if (a<params.count-1)
            local=[local stringByAppendingString:@","];
    }
    local=[local stringByAppendingString:@"}]}"];
    return local;
}

-(uint)lsender: (NSString*) que andAnswer:(NSMutableString **) quedijo andTimeOut:(float) cuantoEspero
{
    uint ret=[self lsender:que andAnswer:quedijo andTimeOut:cuantoEspero vcController:NULL];
    return ret;
}

-(uint)lsender: (NSString*) que andAnswer:(NSString **) quedijo andTimeOut:(float) cuantoEspero vcController:(id)quien

{
    NSString *final,*ipAddress,*verbose;
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data;
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // if( [[appDelegate.workingBFF valueForKey:@"bffLastIpPort"] isEqualToString:@""]) return NO;
    //will add date and time to message to piggyback time management in the esp8266 with NO RTC
    NSArray *bits = [que componentsSeparatedByString: @"?"];
    bool hayf=bits.count>1;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString  *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM:dd:yyyy"];
    NSString  *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    int utc =(int) [[NSTimeZone systemTimeZone] secondsFromGMT];
     //need to send UTC timing diff
    // Are we working totally offline, Use 192.168.4.1:81 FIXED 
    if ([[appDelegate.workingBFF valueForKey:@"bffOffline"] boolValue])
       ipAddress=@"http://192.168.4.1/";
    else
        ipAddress=[appDelegate.workingBFF valueForKey:@"bffLastIpPort"];
    if(quedijo==NULL)
        verbose=@"";
    else
        verbose=@"v";
    final=[NSString stringWithFormat:hayf?@"%@%@_%@&uid=%@&bff=%@&q=%@":@"%@%@_%@?uid=%@&bff=%@&q=%@",
           ipAddress,[[NSUserDefaults standardUserDefaults]  objectForKey:@"appId"],que,[[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"],verbose];
    int transport=(int)[[appDelegate.workingBFF valueForKey:@"bffLimbo"]integerValue];
    if (transport>0)
    {
    appDelegate.rxIn=NO;
    final=[NSString stringWithFormat:hayf?@"%@%@_%@&date=%@&time=%@&UTC=%d&uid=%@&bff=%@&q=%@":@"%@%@_%@?date=%@&time=%@&UTC=%d&uid=%@&bff=%@&q=%@",
           ipAddress,[[NSUserDefaults standardUserDefaults]  objectForKey:@"appId"],que,dateStr,timeStr,utc,
           [[NSUserDefaults standardUserDefaults]  objectForKey:@"bffUID"],[appDelegate.workingBFF valueForKey:@"bffName"],verbose];
        NSString *cola=[NSString stringWithFormat:@"DoorIoT/%@/%@/CMD",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"]];
          LogDebug(@"json %@ queue -%@-",[self makeJson:final],cola);
        [appDelegate.client publishString:[self makeJson:final] toTopic:cola withQos:AtMostOnce retain:NO completionHandler:^(int mid) {
            LogDebug(@"message has been delivered");
            float vueltas=cuantoEspero/10.0;
            int van=0;
            if (quedijo!=NULL)
            {
                while(YES)
                {
                    if (appDelegate.rxIn)
                        break; //already in
                    [NSThread sleepForTimeInterval:vueltas];
                    van++;
                    if(van>10)
                        break;
                }
            }
            else
                {
                    [NSThread sleepForTimeInterval:0.5];
                    NSMutableArray *temp=[appDelegate.queues objectForKey:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
                    [temp removeAllObjects];
                 }
            appDelegate.rxIn=NO;
                       //     LogDebug(@"Sleep done");
        }];
    
        if (quedijo!=NULL)
        {
                NSMutableArray *temp=[appDelegate.queues objectForKey:[NSString stringWithFormat:@"DoorIoT/%@/%@/%@/MSG",[appDelegate.workingBFF valueForKey:@"bffName"],[appDelegate.workingBFF valueForKey:@"bffName"],[[NSUserDefaults standardUserDefaults]objectForKey:@"bffUID"]]];
                if(temp.count>0)
                {
                    queueEntry * a=[temp lastObject];
                    if(a!=NULL)
                        *quedijo=a.que;
           //         LogDebug(@"answer %@ count %d",*quedijo,(int)temp.count);
                    [temp removeAllObjects];
                    return YES;
                }
         //   LogDebug(@"Did not get message");
            return NO;
                 }

        
    // send mqtt
        return YES;
}

    LogDebug(@"Lsender -%@",final);
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:[NSURL URLWithString:final]
                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:cuantoEspero];
    [urlRequest setHTTPMethod:@"POST"];
    
    data = [NSURLConnection sendSynchronousRequest:urlRequest
                                 returningResponse:&response
                                             error:&error];

  //  LogDebug(@"response %@ error %@",response,error);
    if(error==nil)
    {
        NSMutableString *news=[[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    LogDebug(@"News %@",news);
        if(quedijo!=NULL)
        {
        if(news !=NULL)
            *quedijo=news;
        else
            *quedijo=@"";
        }
        return YES;
    }
    else
        return NO;
}

@end
