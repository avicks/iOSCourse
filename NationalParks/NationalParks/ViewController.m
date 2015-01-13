//
//  ViewController.m
//  NationalParks
//
//  Created by alex on 10/15/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"

static const int labelHeight = 100;

@interface ViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) Model *model;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property NSInteger parkCount;
@property (weak, nonatomic) IBOutlet UIImageView *arrowUp;
@property (weak, nonatomic) IBOutlet UIImageView *arrowLeft;
@property (weak, nonatomic) IBOutlet UIImageView *arrowDown;
@property (weak, nonatomic) IBOutlet UIImageView *arrowRight;
@property (nonatomic, retain) UIImageView *imageView;

@end

@implementation ViewController

CGPoint startPosition;     // used to determine where user has begun scrolling
int     scrollDirection;   // if 0, scrolling has just beugn. if 1, scroll vertically.  if 2, scroll horizontally. if 3, stop scrolling
//CGFloat yVelocity;

-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if(self) {
      _model = [[Model alloc] init];
   }
   
   return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _parkCount = [self.model numberOfParks];
    [self setUpScrollView];
   
    /*
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
   // set the start position as we begin scrolling
   startPosition = scrollView.contentOffset;
   scrollDirection = 0;

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   NSInteger parkNumber = (scrollView.contentOffset.x + (0.5f * screenWidth)) / screenWidth;
   NSInteger pageImageCount = [self.model photoCountOfPark:parkNumber];
   [self.scrollView setContentSize:CGSizeMake(_parkCount*screenWidth, (pageImageCount)*screenHeight)];

   if(scrollDirection == 0) {
      // determine whether the user has scrolled more horizontally or vertically
      if(abs(startPosition.x-scrollView.contentOffset.x)< abs(startPosition.y-scrollView.contentOffset.y)){
         // we are scrolling vertically,
         // so adjust content size to restrict scrolling past last image for the park being viewed
         scrollDirection = 1;
         scrollView.scrollEnabled = YES;
      } else if(startPosition.y == 0) {
            scrollDirection = 2;
            scrollView.scrollEnabled = YES;
      } else {
         scrollView.scrollEnabled = NO;
      }
    }
   
   // only change position of intended scroll direction
   if (scrollDirection == 1) {
      [scrollView setContentOffset:CGPointMake(startPosition.x,scrollView.contentOffset.y) animated:NO];
   } else if(scrollDirection == 2){
      //NSLog(@"%f",startPosition.y);
      [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x,startPosition.y) animated:NO];
   }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   //if user is ending the scroll, direction has been established already.
   if (decelerate) {
      scrollDirection = 3;
   }
   scrollView.scrollEnabled = YES;

}

// add the title and first image of the park to the scrollView
-(void)setUpPage:(NSInteger)parkNumber
{
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;

   NSDictionary *currentPark = [self.model getPark:parkNumber];
   NSArray *imageArray = [currentPark objectForKey:@"photos"];


   
   NSDictionary *imageDictionary = imageArray[0];
   
   CGRect titleFrame = CGRectMake(parkNumber*screenWidth, screenHeight/8, screenWidth, labelHeight);
   UILabel *parkTitleLabel = [[UILabel alloc] initWithFrame:titleFrame];
   parkTitleLabel.text = [self.model titleForPark:parkNumber];
   parkTitleLabel.textAlignment = NSTextAlignmentCenter;
   parkTitleLabel.font = [UIFont boldSystemFontOfSize:28];

   CGRect imageViewSize = CGRectMake(parkNumber*screenWidth, screenHeight/4, screenWidth, screenHeight/2);
   NSString *imageName = [imageDictionary objectForKey:@"imageName"];
   _imageView = [[UIImageView alloc] initWithFrame:imageViewSize];
   NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
   [_imageView setImage:[UIImage imageWithContentsOfFile:path]];
   _imageView.userInteractionEnabled = YES;

   [self.scrollView addSubview:parkTitleLabel];
   [self.scrollView addSubview:_imageView];

   // add the rest of the images for the park
   [self addAllImages:parkNumber];

}

// add all the remaining images for a park in pages below the cover page
-(void)addAllImages:(NSInteger)parkNumber
{
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;
   NSDictionary *currentPark = [self.model getPark:parkNumber];
   NSArray *imageArray = [currentPark objectForKey:@"photos"];
   NSInteger imageCount = [self.model photoCountOfPark:parkNumber];
   
   for(int imageNumber = 1; imageNumber < imageCount; imageNumber++) {
      
      CGRect ViewSize = CGRectMake(parkNumber*screenWidth, ((imageNumber)*screenHeight + screenHeight/4),
                                    screenWidth, screenHeight/2);
      
      NSDictionary *imageDictionary = imageArray[imageNumber];

      NSString *imageName = [imageDictionary objectForKey:@"imageName"];
      UIImageView *imageView = [[UIImageView alloc] initWithFrame:ViewSize];
      NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
      [imageView setImage:[UIImage imageWithContentsOfFile:path]];
      [self.scrollView addSubview:imageView];
    }
}

-(void)setUpScrollView {
   
   NSInteger maxPhotoCount = [self.model maxPhotoCount];

   self.scrollView.delegate = self;
   self.scrollView.minimumZoomScale = 1.0;
   self.scrollView.maximumZoomScale = 10;
   self.scrollView.pagingEnabled = YES;
   self.scrollView.directionalLockEnabled = YES;
   self.scrollView.contentSize = CGSizeMake(_parkCount*self.scrollView.bounds.size.width,
                                             maxPhotoCount*self.scrollView.bounds.size.height);

   // add all parks to the scrollView
   for(int parkNumber = 0; parkNumber < _parkCount; parkNumber++) {
      [self setUpPage:parkNumber];
   }

/*
   CGRect arrowDownFrame = CGRectMake((screenWidth/2 - 30), (screenHeight - 60), 60, 60);
   UIImageView *arrowDownView = [[UIImageView alloc] initWithFrame:arrowDownFrame];
   [arrowDownView setImage:[UIImage imageNamed:@"arrowDown.png"]];

   CGRect arrowRightFrame = CGRectMake((screenWidth - 60), (screenHeight/2 - 30), 60, 60);
   UIImageView *arrowRightView = [[UIImageView alloc] initWithFrame:arrowRightFrame];
   [arrowRightView setImage:[UIImage imageNamed:@"arrowRight.png"]];

   CGRect arrowUpFrame = CGRectMake((screenWidth/2 - 30), 0.0, 60, 60);
   UIImageView *arrowUpView = [[UIImageView alloc] initWithFrame:arrowUpFrame];
   [arrowUpView setImage:[UIImage imageNamed:@"arrowUp.png"]];

   CGRect arrowLeftFrame = CGRectMake(0.0, (screenHeight/2 - 30), 60, 60);
   UIImageView *arrowLeftView = [[UIImageView alloc] initWithFrame:arrowLeftFrame];
   [arrowLeftView setImage:[UIImage imageNamed:@"arrowLeft.png"]];
   //[arrowLeftView isHidden = YES];


   [self.scrollView addSubview:arrowDownView];
   [self.scrollView addSubview:arrowRightView];
   [self.scrollView addSubview:arrowUpView];
   [self.scrollView addSubview:arrowLeftView];

   //self.arrowDown.hidden = NO;
   //self.arrowRight.hidden = NO;

*/


}

# pragma mark - Zoom Functionality Code
/*
- (void)scrollViewDidZoom:(UIScrollView *)scrollView 
{
if (scrollView.zoomScale!=1.0) 
{
    // Not zoomed, let the scroll view scroll
    scrollView.scrollEnabled = NO;

}
else
{
    // Zooming, disable scrolling
    scrollView.scrollEnabled = NO;
}
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}


-(void)pinchGestureRecognizer:(UIPinchGestureRecognizer*)recognizer
{
   NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   
   //parkNumber*screenWidth, screenHeight/4, screenWidth, screenHeight/2
   
   switch(recognizer.state) {
      case UIGestureRecognizerStateBegan: {
         CGPoint touchPoint = [recognizer locationInView:self.scrollView];
         
         NSInteger parkNumber = floor(touchPoint.x / screenWidth);
         NSInteger imageNumber = floor(touchPoint.y / screenHeight);
         
         CGFloat imageY = ((int)touchPoint.y % (int)screenHeight);
         
         // if the pinch occurs within the bounds of an image on the scrollview, create a new scrollview
         if(imageY >= screenHeight/4 && imageY <= screenHeight/2
            && touchPoint.x >= parkNumber*screenWidth && touchPoint.x <= (parkNumber+1)*screenWidth) {
            NSLog(@"image hit!");
            
            UIScrollView *zoomScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

            zoomScrollview.minimumZoomScale = 1.0;
            zoomScrollview.maximumZoomScale = 10;
            //self.zoomScrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,
                                             //self.scrollView.bounds.size.height);

            CGRect imageViewSize = CGRectMake(parkNumber*screenWidth, screenHeight/4, screenWidth, screenHeight/2);
            
            NSDictionary *currentPark = [self.model getPark:parkNumber];
            NSArray *imageArray = [currentPark objectForKey:@"photos"];
            NSDictionary *imageDictionary = imageArray[imageNumber];
            NSString *imageName = [imageDictionary objectForKey:@"imageName"];
            _imageView = [[UIImageView alloc] initWithFrame:imageViewSize];
            NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [_imageView setImage:image];
            _imageView.userInteractionEnabled = YES;
            zoomScrollview.frame = CGRectMake(0,0,image.size.width*10,image.size.height*10);
            [zoomScrollview addSubview:_imageView];
            
            [self.view addSubview:zoomScrollview];

         }
         
         //NSLog(@"park: %li, image: %li",(long)parkNumber, (long)imageNumber);
         break;
      }
      case UIGestureRecognizerStateEnded: {
         //NSLog(@"pinch ended");
         break;
      }
   }
}
*/

@end
