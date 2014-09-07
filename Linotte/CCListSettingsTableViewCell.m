//
//  CCListSettingsTableViewCell.m
//  Linotte
//
//  Created by stant on 07/09/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "CCListSettingsTableViewCell.h"

@implementation CCListSettingsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
