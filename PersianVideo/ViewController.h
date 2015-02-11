//
//  ViewController.h
//  PersianVideo
//
//  Created by Edward Rezaimehr on 1/12/15.
//  Copyright (c) 2015 Edward Rezaimehr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UITableViewController <NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (retain, nonatomic) NSMutableData *apiReturnData;
@property (retain, nonatomic) NSString *contentId;

@end

