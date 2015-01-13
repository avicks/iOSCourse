//
//  DetailViewController.m
//  NationalParksII
//
//  Created by alex on 11/2/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "DetailViewController.h"
#import "ScrollDetailViewController.h"
#import "Model.h"

@interface DetailViewController() <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate>

@property (nonatomic,strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) ScrollDetailViewController *scrollDetailViewController;
@property (nonatomic, strong) Model *model;
@property (nonatomic,strong) UIResponder *activeResponder;
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation DetailViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      _model = [Model sharedInstance];
   }
   return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
   
   }
    return self;
}

-(void)awakeFromNib {
   if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
      
      self.scrollDetailViewController = (id)navController.topViewController;
      self.splitViewController.delegate = self.scrollDetailViewController;
   }
}

-(void)viewWillAppear:(BOOL)animated {
   self.title = self.parkTitle;
   self.captionTextField.text = self.captionText;
   self.commentsTextView.text = self.commentsText;
   [self.scrollViewButton setBackgroundImage:self.detailImage forState:UIControlStateNormal];

   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidLoad
{
   [super viewDidLoad];
   self.scrollView = (UIScrollView*)self.view;
   self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

-(void)viewDidAppear:(BOOL)animated
{
   self.scrollView.contentSize = self.view.bounds.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.completionBlock(@{@"caption":self.captionTextField.text,
                           @"comments":self.commentsTextView.text});
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Parks", @"Parks");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Segue to scrollable image
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if([segue.identifier isEqualToString:@"scrollSegue"]){

      UIImage *parkImage = [self.model parkImage:_parkNumber :_photoNumber];
      NSString *parkImageCaption = self.captionTextField.text;
      NSString *parkName = self.title;
      
      ScrollDetailViewController *scrollDetailViewController = segue.destinationViewController;
      scrollDetailViewController.parkTitle = parkName;
      scrollDetailViewController.parkImage = parkImage;
      scrollDetailViewController.photoCaption = parkImageCaption;
   }

}

-(void)keyboardWillBeShown:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGRect frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = frame.size;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    
}

-(void)keyboardWillHide:(NSNotification*)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self.commentsTextView becomeFirstResponder];
    } else {
        [self.commentsTextView resignFirstResponder];
    }
    
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.captionTextField resignFirstResponder];

    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeResponder = self.captionTextField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeResponder = nil;
}

#pragma mark - Text View Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.editing) {
        [self setEditing:YES animated:YES];
    }

}

@end
