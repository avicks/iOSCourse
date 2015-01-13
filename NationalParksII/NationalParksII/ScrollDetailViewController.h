//
//  ScrollDetailViewController.h
//  NationalParksII
//
//  Created by alex on 11/3/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *parkImage;
@property (nonatomic, strong) NSString *photoCaption;
@property (nonatomic, strong) NSString *parkTitle;

@end
