//
//  SidebarTableViewController.m
//  SidebarDemo
//
//  Created by Simon Ng on 10/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import "MenuItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewController.h"

#define kMenuItemsUrl @"http://www.aidin4app.com/api/PV/menu/0"

@interface SidebarTableViewController ()

@end

@implementation SidebarTableViewController {
    NSArray *menuItems;
    NSURLConnection *currentConnection;
    BOOL _draggingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *restURL = [NSURL URLWithString:kMenuItemsUrl];
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
    
    menuItems = [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys: @"در حال دریافت اطلاعات ...", @"title", nil], nil];
    _draggingView = NO;

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
        NSURL *restURL = [NSURL URLWithString:kMenuItemsUrl];
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
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    NSString *identifier = @"feed_item";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *menuItemDictObject = [menuItems objectAtIndex:index];
    [((MenuItem *)cell).nameLabel setText:[menuItemDictObject valueForKey:@"title"]];
    [((MenuItem *)cell).thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:[menuItemDictObject valueForKey:@"thumb"]]
                                             placeholderImage:[UIImage imageNamed:@"logo"]];

    return cell;
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
        menuItems = [returnedDict objectForKey:@"feed"];
        [self.tableView reloadData];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *navController = segue.destinationViewController;
    ViewController *nextController = [navController childViewControllers].firstObject;
    [nextController setTitle: [[menuItems objectAtIndex:indexPath.row] valueForKey:@"title"]];
    [nextController setContentId: [[menuItems objectAtIndex:indexPath.row] valueForKey:@"value"]];
}


@end
