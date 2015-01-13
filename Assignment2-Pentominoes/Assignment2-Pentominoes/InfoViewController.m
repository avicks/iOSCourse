//
//  InfoViewController.m
//  Assignment3
//
//  Created by alex on 9/22/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

-(IBAction)dismissViewPressed:(id)sender;

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissViewPressed:(id)sender
{
   [self.delegate dismissMe];

}


@end
