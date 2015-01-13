//
//  AddParkViewController.m
//  NationalParksII
//
//  Created by alex on 11/11/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "AddParkViewController.h"

@interface AddParkViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *parkTitleTextField;
-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)cancelPressed:(id)sender;
@property (nonatomic,strong) UIResponder *activeResponder;
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation AddParkViewController

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   self.scrollView = (UIScrollView*)self.view;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveButtonPressed:(id)sender
{
   if([self.parkTitleTextField.text isEqualToString:@""] || ![[self.parkTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
         message:@"Please enter a park name before saving a new park." delegate:nil
         cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];

        self.parkTitleTextField.text = @"";
    } else {
      self.completionBlock(self.parkTitleTextField.text);
    }

}

-(IBAction)cancelPressed:(id)sender
{
   self.completionBlock(nil);
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

@end
