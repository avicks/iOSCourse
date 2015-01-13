//
//  TableViewCell.h
//  NationalParksII
//
//  Created by alex on 10/23/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *photoCaption;
@property (weak, nonatomic) IBOutlet UIImageView *photoThumbnail;

@end
