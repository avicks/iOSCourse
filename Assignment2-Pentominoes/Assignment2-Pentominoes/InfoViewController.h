//
//  InfoViewController.h
//  Assignment3
//
//  Created by alex on 9/22/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoDelegate <NSObject>

-(void) dismissMe;

@end


@interface InfoViewController : UIViewController

@property (nonatomic, weak) id<InfoDelegate> delegate;

@end
