//
//  syncTableVC.m
//  FeedIoT
//
//  Created by Robert on 3/21/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

#import "syncTableVC.h"
#import "AppDelegate.h"
#import "syncCellTableViewCell.h"
@interface syncTableVC ()

@end

@implementation syncTableVC
@synthesize servingsArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    blueC=[UIColor colorWithRed:64.0/255.0 green:136.0/255.0 blue:248.0/255.0 alpha:1.0];
    redC=[UIColor colorWithRed:224.0/255.0 green:52.0/255.0 blue:48.0/255.0 alpha:1.0];
    orangeC=[UIColor colorWithRed:251.0/255.0 green:183.0/255.0 blue:50.0/255.0 alpha:1.0];
    greenC=[UIColor colorWithRed:141.0/255.0 green:182.0/255.0 blue:36.0/255.0 alpha:1.0];
    settingC=[UIColor colorWithRed:252.0/255.0 green:86.0/255.0 blue:25.0/255.0 alpha:1.0];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Servings"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    //  [request setReturnsObjectsAsFaults:NO];
    //get all
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"servDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    servingsArray = [[context executeFetchRequest:request
                                                     error:&error] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //   NSLog(@"Text %d",wifis.count);
    return servingsArray.count;
}
#pragma mark - UITableViewDataSource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *lco;
    
    syncCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"servingCell"];
    NSManagedObject *matches = nil;
    matches = [servingsArray objectAtIndex:indexPath.row];
    int sid=[[matches valueForKey:@"servId"] integerValue]+1;
    switch(sid)
    {
        case 1:lco=blueC;
            break;
        case 2:
            lco=redC;
            break;
        case 3:
            lco=orangeC;
            break;
        case 4:
            lco=greenC;
            break;
        case 5:
            lco=settingC;
            break;
        default:
            break;
    }
    cell.nameLabel.text = [matches valueForKey:@"servName"];
    cell.nameLabel.textColor=lco;
    uint8_t days=[[matches valueForKey:@"servDays"]integerValue];
    NSString *dias=[NSString stringWithFormat:@"%c%c%c%c%c%c%c",(days & 0x1)? 'S':'-',(days & 0x2)? 'M':'-',(days & 0x4)? 'T':'-',(days & 0x8)? 'W':'-',
                    (days & 0x10)? 'T':'-',(days & 0x20)? 'F':'-',(days & 0x40)? 'S':'-'];
    
    cell.dayLabel.text=dias;
    cell.dayLabel.textColor=lco;
    NSString *rsimage=[NSString stringWithFormat:@"serving%ds",sid];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString  *formatedDate = [dateFormatter stringFromDate:[matches valueForKey:@"servDate"]];
    cell.timeLabel.text=formatedDate;
    cell.timeLabel.textColor=lco;
    cell.servingView.image=[UIImage imageNamed:rsimage];
    
    //   NSLog(@"Dias %@ Image %@ match %@ ",dias,rsimage,matches);
    return cell;
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
