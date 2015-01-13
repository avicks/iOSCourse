//
//  DetailViewController.h
//  NationalParksII
//
//  Created by alex on 11/2/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) IBOutlet UIButton *scrollViewButton;
@property (nonatomic, strong) IBOutlet UILabel *detailParkImageCaption;
@property (nonatomic, strong) IBOutlet UITextField *captionTextField;
@property (nonatomic, strong) IBOutlet UITextView  *commentsTextView;

@property (nonatomic, strong) UIImage *detailImage;

@property (nonatomic, strong) NSString *imageLabel;
@property (nonatomic, strong) NSString *captionText;
@property (nonatomic, strong) NSString *commentsText;
@property (nonatomic, strong) NSString *parkTitle;
@property NSInteger parkNumber;
@property NSInteger photoNumber;
@property (nonatomic,strong) CompletionBlock completionBlock;


@end
