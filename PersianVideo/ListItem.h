//
//  ListItem.h
//  PersianVideo
//
//  Created by Edward Rezaimehr on 1/17/15.
//  Copyright (c) 2015 Edward Rezaimehr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListItem : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *videoImage;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end
