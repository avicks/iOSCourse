//
//  ScrollDetailViewController.m
//  NationalParksII
//
//  Created by alex on 11/3/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "ScrollDetailViewController.h"

@interface ScrollDetailViewController ()

@property (nonatomic,strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ScrollDetailViewController

@synthesize scrollView = _scrollView;

@synthesize imageView = _imageView;

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
   self.title = self.photoCaption;
   
   self.imageView = [[UIImageView alloc] initWithImage:self.parkImage];
   self.imageView.contentMode = UIViewContentModeScaleAspectFit;

   self.scrollView.bounds = self.imageView.frame;
   self.scrollView.delegate = self;
   self.scrollView.minimumZoomScale = 1.0;
   self.scrollView.maximumZoomScale = 10.0f;
   
   self.imageView.frame = self.view.bounds;
   self.scrollView.frame = self.imageView.frame;
   
   [self.scrollView addSubview:self.imageView];


}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    // The scroll view has zoomed, so we need to re-center the contents
   [self centerScrollViewContents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = self.parkTitle;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
