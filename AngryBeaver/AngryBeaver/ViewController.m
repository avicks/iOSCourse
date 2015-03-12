//
//  ViewController.m
//  AngryBeaver
//
//  Created by alex on 10/5/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "ViewController.h"

#define kBladeDimension 89
#define kSawAnimationDuration 0.2
#define kTimerDuration 0.5
#define kYVelocity 450
#define kXVelocityBase 100

#define kParticleScale 0.5
#define kParticleLifetime 0.5
#define kEmitterCellBirthRate 100
#define kEmitterCellVelocity 300
#define kEmitterCellVelocityRange 200
#define kEmitterCellEmissionRange 2*M_PI
#define kEmitterCellSpinRange 4*M_PI

#define kNumberOfRotations 3.0


@import CoreMotion;
@import QuartzCore;

static CMMotionManager *motionManager;

@interface ViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *gameOverImage;
@property (weak, nonatomic) IBOutlet UIImageView *beaverImageView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
-(IBAction)startPressed:(id)sender;

@property (nonatomic,strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic,strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic,strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (assign, nonatomic) CMAcceleration acceleration;

@property NSInteger score;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation ViewController

+(void)startMotionManager{
    if (!motionManager) {
            motionManager = [[CMMotionManager alloc] init];
    }
    motionManager.gyroUpdateInterval = 1.0/60.0; // Update every 1/60 second.
    [motionManager startDeviceMotionUpdates];
}
+(void)stopMotionManager{
    [motionManager stopDeviceMotionUpdates];
}


- (void)viewDidLoad
{
   [super viewDidLoad];
   [self woodchipLayer];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// scale up the image into it's full size
-(CAAnimation *)scaleAnimation
{
   CABasicAnimation* scaleAnimation;
   scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
   
   [scaleAnimation setFromValue:[NSNumber numberWithFloat:0.4f]];
   [scaleAnimation setToValue:[NSNumber numberWithFloat:1.f]];
   
   [scaleAnimation setDuration:kNumberOfRotations];

   return scaleAnimation;
}

-(CAAnimation *)rotateAnimation
{
   CABasicAnimation* rotationAnimation;
   rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
   
   // rotating by k*2*M_PI completes one full spin
   [rotationAnimation setToValue:[NSNumber numberWithFloat:2*M_PI*kNumberOfRotations]];
   
   // by setting the duration to the number of rotations, we make sure the animation completes with the image with positioned as it started
   [rotationAnimation setDuration:kNumberOfRotations];

   return rotationAnimation;
}

-(void)woodchipLayer
{
   // Create emitter layer
   _emitterLayer = [[CAEmitterLayer alloc] init];
   
   //Set the bounds to be full screen
   _emitterLayer.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
   //Place it at the center
   _emitterLayer.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
   _emitterLayer.emitterPosition = CGPointZero;

   NSArray *chipImages = @[[UIImage imageNamed:@"woodchip1.png"], [UIImage imageNamed:@"woodchip2.png"], [UIImage imageNamed:@"woodchip3.png"], [UIImage imageNamed:@"woodchip4.png"], [UIImage imageNamed:@"woodchip5.png"]];

    NSMutableArray *woodchipCAEmitterCellArray = [[NSMutableArray alloc] init];

    // Create emitter cells
    for(int i = 0; i < chipImages.count; i++) {
        woodchipCAEmitterCellArray[i] = [self createEmitterCellWithContents:(id)[chipImages[i] CGImage]];
    }
    
   // add cells to emitterLayer
    _emitterLayer.emitterCells = woodchipCAEmitterCellArray;
}

-(IBAction)startPressed:(id)sender
{
   self.startButton.hidden = YES;
   self.beaverImageView.hidden = YES;
   self.gameOverImage.hidden = YES;
   _score = 0;
   _scoreLabel.text = [NSString stringWithFormat:@"%li", (long)_score];
   [self addBehaviors];
   [self createBlade];

   // start the continuous log/rock drops
   if(self.timer) {
      [self.timer invalidate];
      self.timer = nil;
   } else {
      self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
   }
}

-(void)addBehaviors
{
   [ViewController startMotionManager];
   [motionManager startGyroUpdates];
   
   // used for determining the "floor" boundary of the game for rocks
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;
   CGPoint bottomLeft = CGPointMake(0,screenHeight);
   CGPoint bottomRight = CGPointMake(screenWidth, screenHeight);
   
   _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
   
   _gravityBehavior = [[UIGravityBehavior alloc] init];
   _gravityBehavior.gravityDirection = CGVectorMake(0.0, 0.0);
   
   __weak typeof(self) self_ = self;
   _gravityBehavior.action = ^{
      CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
      CMAcceleration gravity = deviceMotion.gravity;
      self_.gravityBehavior.gravityDirection = CGVectorMake(2.5*gravity.x, -2.5*gravity.y);
   };
   
   _collisionBehavior = [[UICollisionBehavior alloc] init];
   [_collisionBehavior addBoundaryWithIdentifier:@"Bottom" fromPoint:bottomLeft toPoint:bottomRight];
   _collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
   _collisionBehavior.collisionDelegate = self;
   
   [_dynamicAnimator addBehavior:_collisionBehavior];
   [_dynamicAnimator addBehavior:_gravityBehavior];
   
}

/*  Create a CAEmitterCell object.  In AngryBeaver, CAEMitterCells are used to provide the
      woodchip animations that appear when the blade object makes contact with a log object.  As many of the
      properties are constant across all CAEmitterCell objects in this app, it is not necessary
      to pass them in.
    Inputs: the contents of the CAEmitterCell.
*/
-(CAEmitterCell *)createEmitterCellWithContents:(id)contents
{
    CAEmitterCell *emitterCell = [[CAEmitterCell alloc] init];
    emitterCell.contents = contents;
    emitterCell.scale = kParticleScale;
    emitterCell.lifetime = kParticleLifetime;
    emitterCell.birthRate = kEmitterCellBirthRate;
    emitterCell.velocity = kEmitterCellVelocity;
    emitterCell.velocityRange = kEmitterCellVelocityRange;
    emitterCell.emissionRange = kEmitterCellEmissionRange;
    emitterCell.spinRange = kEmitterCellSpinRange;

    return emitterCell;
}

// create the blade saw, animate it, and give it collision and gyroscope attributes
-(void)createBlade
{
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   NSInteger screenHeight = [UIScreen mainScreen].bounds.size.height;

   NSArray *bladeImages = @[[UIImage imageNamed:@"blade0.png"], [UIImage imageNamed:@"blade1.png"], [UIImage imageNamed:@"blade2.png"], [UIImage imageNamed:@"blade3.png"], [UIImage imageNamed:@"blade4.png"], [UIImage imageNamed:@"blade5.png"]];
   
   // initiate image and draw it onto the view
   UIImageView *bladeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2 - kBladeDimension/2, screenHeight - 2*kBladeDimension, kBladeDimension, kBladeDimension)];
   
   // set animation features
   bladeImageView.animationImages = bladeImages;
   bladeImageView.animationDuration = kSawAnimationDuration;
   bladeImageView.tag = 3;
   // add to parent view
   [self.view addSubview:bladeImageView];
   
   // set collision properties on blade
   [self.collisionBehavior addItem:bladeImageView];
   [self.gravityBehavior addItem:bladeImageView];
   
   // animate the image
   [bladeImageView startAnimating];
}

// create a log, give it directional velocity and collision attributes
-(void)createLog
{
   NSArray *logArray = @[[UIImage imageNamed:@"Log1.png"], [UIImage imageNamed:@"Log2.png"], [UIImage imageNamed:@"Log3.png"]];
   
   // randomize log chosen to be displayed
   int logNumber = arc4random_uniform(3);
   
   UIImage *logImage = [logArray objectAtIndex:logNumber];
   UIImageView *logImageView = [[UIImageView alloc] initWithImage:logImage];
   
   // randomly choose x coordinate for log to start at
   CGFloat randomStartingXCoordinate = (CGFloat)(arc4random() % (int)[UIScreen mainScreen].bounds.size.width);
   
   // make sure logs appears within screen bounds
   if ((randomStartingXCoordinate + logImage.size.width/2) > [UIScreen mainScreen].bounds.size.width) {
      randomStartingXCoordinate -= logImage.size.width;
   } else if((randomStartingXCoordinate - logImage.size.width/2) < 0)
   {
      randomStartingXCoordinate += logImage.size.width;
   }
   
   // set display position of log at top of screen with the random x coordinate
   logImageView.center = CGPointMake(randomStartingXCoordinate, logImage.size.height/2);
   logImageView.tag = 1;

   // add log to parent view
   [self.view addSubview:logImageView];

   // give an absolute base of 100 xVelocity with a max of 150
   int xVelocity = (kXVelocityBase + arc4random_uniform(50));

   // randomly determine x direction of log (left or right)
   int direction = arc4random_uniform(2);
   if(direction == 1) {
      xVelocity = xVelocity * -1;
   }
   
   UIDynamicItemBehavior *dynamicItemBehavior =
      [[UIDynamicItemBehavior alloc] initWithItems:@[logImageView]];
   
   [dynamicItemBehavior addLinearVelocity:CGPointMake(xVelocity, kYVelocity) forItem:logImageView];
   
   [self.collisionBehavior addItem:logImageView];
   [self.dynamicAnimator addBehavior:dynamicItemBehavior];

}

// create a rock, give it directional velocity and collision attributes
-(void)createRock
{
   UIImage *rockImage = [UIImage imageNamed:@"rock.png"];
   UIImageView *rockImageView = [[UIImageView alloc] initWithImage:rockImage];
   
   // randomly choose x coordinate for log to start at
   CGFloat randomStartingXCoordinate = (CGFloat)(arc4random() % (int)[UIScreen mainScreen].bounds.size.width);
   
   // make sure logs appears within screen bounds
   if ((randomStartingXCoordinate + rockImage.size.width/2) > [UIScreen mainScreen].bounds.size.width) {
      randomStartingXCoordinate -= rockImage.size.width;
   } else if((randomStartingXCoordinate - rockImage.size.width/2) < 0)
   {
      randomStartingXCoordinate += rockImage.size.width;
   }
   
   // set display position of log at top of screen with the random x coordinate
   rockImageView.center = CGPointMake(randomStartingXCoordinate, rockImage.size.height/2);
   rockImageView.tag = 2;
   // add log to parent view
   [self.view addSubview:rockImageView];
   
   // give an absolute base of 100 xVelocity with a max of 150
   int xVelocity = (kXVelocityBase + arc4random_uniform(50));

   // randomly determine left/right direction of rock
   int direction = arc4random_uniform(2);
   if(direction == 1) {
      xVelocity = xVelocity * -1;
   }
   
   UIDynamicItemBehavior *dynamicItemBehavior =
      [[UIDynamicItemBehavior alloc] initWithItems:@[rockImageView]];
   
   [dynamicItemBehavior addLinearVelocity:CGPointMake(xVelocity, kYVelocity) forItem:rockImageView];

   [self.collisionBehavior addItem:rockImageView];
   [self.dynamicAnimator addBehavior:dynamicItemBehavior];

}

// Once start is pressed, begin dropping items
-(void)dropItems
{
   // randomly decide next item to drop, with a greater chance of logs being chosen
   int dropNumber = arc4random_uniform(5);
   if(dropNumber == 4)
   {
      [self createRock];
   } else {
      [self createLog];
   }
}

-(void)timerFired:(NSTimer*)timer {
   [self dropItems];
}

// handle collisions between two items with collision behavior
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p {
    
   UIView *view1 = (UIView*)item1;
   UIView *view2 = (UIView*)item2;
   
   // tag 1 == log
   // tag 2 == rock
   // tag 3 == blade

   // if the saw hits a log, remove the log and add +1 to the score
   if (view1.tag == 3 && view2.tag == 1) {
      
      // add the emitterLayer to the log
      [view2.layer addSublayer:_emitterLayer];
      
      [self removeBlock:view2];
      _score++;
      _scoreLabel.text = [NSString stringWithFormat:@"%li", (long)_score];
    } else if(view1.tag == 3 && view2.tag == 2) {  // the saw has hit a rock
      
      // stop rocks and logs from being generated
      if(self.timer) {
         [self.timer invalidate];
         self.timer = nil;
      }
      
      // remove all items as the game as ended
      for (id subview in self.view.subviews) {
         UIView *theView = (UIView*)subview;
         if (theView.tag == 1 || theView.tag == 2 || theView.tag == 3) {
            [self removeBlock:theView];
         }
      }
      self.beaverImageView.hidden = NO;
      self.gameOverImage.hidden = NO;
      
      [self.gameOverImage.layer addAnimation:[self rotateAnimation] forKey:@"transform.rotation.z"];
      [self.gameOverImage.layer addAnimation:[self scaleAnimation] forKey:@"scale"];
      [self.beaverImageView.layer addAnimation:[self rotateAnimation] forKey:@"transform.rotation.z"];

      self.startButton.hidden = NO;
   }
}

// detect collisions for rocks and the ground
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
   
   UIView *view = (UIView*)item;
   NSString *const boundaryID = @"Bottom";
   NSString *newIdentifier = (NSString *)identifier;
   
   // if a rock touches the ground, remove it.
   if(view.tag == 2 && [newIdentifier isEqualToString:boundaryID])
   {
      [self removeBlock:view];
   }
}

-(void)removeBlock:(UIView*)block {
   
   // remove behaviors of block first to account for collisions occuring during removal animation
   // this behavior would cause logs to count multiple times towards the score
   [self.collisionBehavior removeItem:block];
   [self.gravityBehavior removeItem:block];

   [UIView animateWithDuration:0.5 animations:^{
      block.alpha = 0.0;
   } completion:^(BOOL finished) {
      [block removeFromSuperview];

   }];
}

@end
