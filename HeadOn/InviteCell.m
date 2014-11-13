//
//  InviteCell.m
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "InviteCell.h"
#import "OnlineGameSelection.h"

@implementation InviteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)StartGame:(UIButton *)sender {
    [[GameLogic sharedGameLogic] popViews];
    [[CCDirector sharedDirector] replaceScene:[OnlineGameSelection sceneWithGame:_game]];
}
- (IBAction)RejectButton:(id)sender {
    UIAlertView *reject = [[UIAlertView alloc] initWithTitle:@"Reject Game?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];

    [reject show];
}

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [_game setObject:[NSNumber numberWithBool:YES] forKey:@"Ended"];
        [_game saveInBackground];
        [_parentDataSet removeObject:_game];
        [_parentTableView reloadData];
    }
}
@end
