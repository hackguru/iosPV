//
//  ViewController.m
//  PersianVideo
//
//  Created by Edward Rezaimehr on 1/12/15.
//  Copyright (c) 2015 Edward Rezaimehr. All rights reserved.
//

#import "ViewController.h"
#import "ListItem.h"
#import "SWRevealViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kMenuItemsUrl @"http://www.aidin4app.com/api/PV/all/%@"
#define kPlayCountUrl @"http://www.aidin4app.com/api/PV//1/%@"

@interface ViewController ()
@end

@implementation ViewController {
    NSArray *items;
    NSURLConnection *currentConnection;
    BOOL _draggingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    items = [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys: @"در حال دریافت اطلاعات ...", @"description", nil], nil];

    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    if (self.contentId == nil){
        self.contentId = @"0";
    }
    NSURL *restURL = [NSURL URLWithString:[NSString stringWithFormat:kMenuItemsUrl, self.contentId]];
    NSURLRequest *restRequest = [NSURLRequest requestWithURL:restURL];
    
    // we will want to cancel any current connections
    if(currentConnection)
    {
        [currentConnection cancel];
        currentConnection = nil;
        self.apiReturnData = nil;
    }
    
    currentConnection = [[NSURLConnection alloc]   initWithRequest:restRequest delegate:self];
    
    // If the connection was successful, create the data that will be returned.
    self.apiReturnData = [NSMutableData data];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _draggingView = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _draggingView = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger pullingDetectFrom = 50;
    if (scrollView.contentOffset.y < -pullingDetectFrom) {
        _draggingView = NO;
        //Pull Down
        NSURL *restURL = [NSURL URLWithString:[NSString stringWithFormat:kMenuItemsUrl, self.contentId]];
        NSURLRequest *restRequest = [NSURLRequest requestWithURL:restURL];
        
        // we will want to cancel any current connections
        if(currentConnection)
        {
            [currentConnection cancel];
            currentConnection = nil;
            self.apiReturnData = nil;
        }
        
        currentConnection = [[NSURLConnection alloc]   initWithRequest:restRequest delegate:self];
        
        // If the connection was successful, create the data that will be returned.
        self.apiReturnData = [NSMutableData data];
        
    } else if (scrollView.contentSize.height <= scrollView.frame.size.height && scrollView.contentOffset.y > pullingDetectFrom) {
        _draggingView = NO;
        //Pull Up
    } else if (scrollView.contentSize.height > scrollView.frame.size.height &&
               scrollView.contentSize.height-scrollView.frame.size.height-scrollView.contentOffset.y < -pullingDetectFrom) {
        _draggingView = NO;
        //Pull Up
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    NSString *identifier = @"video-item";
    NSDictionary *item = [items objectAtIndex:index];
    ListItem *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell.videoImage sd_setImageWithURL:[NSURL URLWithString:[item valueForKey:@"thumburl"]]
                    placeholderImage:[UIImage imageNamed:@"place-holder"]];
    [cell.playButton setTag: index];
    [cell.descriptionLabel setText:[item valueForKey:@"description"]];
    [cell.playButton setAlpha:1];
    
    if([[item valueForKey:@"description"] isEqualToString:@"در حال دریافت اطلاعات ..."]){
        [cell.playButton setAlpha:0];
    }

    return cell;
}

- (IBAction)playMovie:(id)sender{
    NSDictionary *itemDictObject = [items objectAtIndex:[(UIButton*)sender tag]];
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[itemDictObject valueForKey:@"videolqurl"]]];
    self.player.controlStyle = MPMovieControlStyleDefault;
    self.player.shouldAutoplay = YES;
    
    [self.view addSubview:self.player.view];
    [self.player setFullscreen:YES animated:YES];
    
    
    NSURL *restURL = [NSURL URLWithString:[NSString stringWithFormat:kMenuItemsUrl, [itemDictObject valueForKey:@"videoid"]]];
    NSURLRequest *restRequest = [NSURLRequest requestWithURL:restURL];
    [NSURLConnection sendAsynchronousRequest:restRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        return;
    }];

}

- (IBAction)share:(id)sender{
    NSInteger index = [(UIButton*)sender tag];
    NSDictionary *item = [items objectAtIndex:index];
    NSString *textToShare = [item valueForKey:@"description"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://deeplink.me/amsusacorp.com/?pvid=%@", [item valueForKey:@"videoid"]]];
    ListItem *cell = (ListItem *)[[[[(UIButton*)sender superview] superview] superview] superview];
    UIImage *image = [[cell videoImage] image];

    NSArray *objectsToShare = @[textToShare, url, image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [self.apiReturnData setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.apiReturnData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"URL Connection Failed!");
    currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    currentConnection = nil;
    NSError *error;
    NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:self.apiReturnData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        items = [returnedDict objectForKey:@"feed"];
        [self.tableView reloadData];
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
