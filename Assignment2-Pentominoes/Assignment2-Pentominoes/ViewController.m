//
//  ViewController.m
//  Assignment3-Pentominoes
//
//  Created by alex on 9/15/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import "InfoViewController.h"

#define boardSquareSize 30
#define heightSpacing 100
#define widthSpacing 30
#define panMultiplier 1.1

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *centerBoardImageView;

-(IBAction)solvePressed:(id)sender;
-(IBAction)resetPressed:(id)sender;
-(IBAction)changeBoard:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *solveButton;

@property Model *model;
@property NSMutableDictionary *playingPieces;
@end


@implementation ViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   _model = [[Model alloc] init];
   _playingPieces = [[NSMutableDictionary alloc] init];
    
   NSDictionary *piecesDictionary = [self.model createPentominoesPieces];
   
   for (id key in piecesDictionary){
      UIImage *pieceImage = [piecesDictionary objectForKey:key];
      UIImageView *pieceImageView = [[UIImageView alloc] initWithImage:pieceImage];
      pieceImageView.frame = CGRectMake(0.0, 0.0, pieceImage.size.width, pieceImage.size.height);
      pieceImageView.userInteractionEnabled = YES;
      [self addPlayingPieceGestures:pieceImageView];
      [self.playingPieces setObject:pieceImageView forKey:key];
   }

}

-(void)viewDidAppear:(BOOL)animated
{
   self.model.currentBoardImageID = 0;
   UIImage *boardImage = [self.model getBoardImage: self.model.currentBoardImageID];
   [self.centerBoardImageView setImage: boardImage];
   
    [UIView animateWithDuration:1 animations:^{
      [self displayPieces];
    }];
    
    self.solveButton.enabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeBoard:(id)sender
{
   if(self.solveButton.enabled == NO) {
      [self resetPressed:nil];
   }

   self.model.currentBoardImageID = [sender tag];
   UIImage *boardImage = [self.model getBoardImage:self.model.currentBoardImageID];
   
   [self.centerBoardImageView setImage: boardImage];
   
   if(self.model.currentBoardImageID == 0) {
      self.solveButton.enabled = NO;
   } else {
      self.solveButton.enabled = YES;
   }
}

- (void)displayPieces
{
   NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
   CGPoint startCoordinates = self.centerBoardImageView.frame.origin;
   startCoordinates.y += (self.centerBoardImageView.frame.size.height + heightSpacing);
   startCoordinates.x += widthSpacing;

   CGPoint currentPoint = startCoordinates;
   CGPoint newOrigin;
   
   for(id key in self.playingPieces) {
      UIImageView *currentPiece = [self.playingPieces objectForKey:key];
       
      // determine where to place next piece based on if piece will fit within screen width
      if(currentPoint.x + 2*currentPiece.frame.size.width > screenWidth) {
         currentPoint.x = startCoordinates.x;
         currentPoint.y += heightSpacing;
      }
      
      newOrigin = [currentPiece.superview convertPoint:currentPiece.frame.origin toView:self.view];
      currentPiece.frame = CGRectMake(newOrigin.x, newOrigin.y,
                              currentPiece.frame.size.width, currentPiece.frame.size.height);
      [self.view addSubview:currentPiece];
      currentPiece.frame = CGRectMake(currentPoint.x, currentPoint.y,
                              currentPiece.frame.size.width, currentPiece.frame.size.height);

      currentPoint.x += currentPiece.image.size.width + widthSpacing;
    }
}

- (IBAction)solvePressed:(id)sender
{
   // default board image has no solution, so do nothing if selected
   if(self.model.currentBoardImageID == 0) {
      return;
   } else {
      // load solutions to current board
      NSDictionary *currentBoardSolutionsDictionary =
         [self.model getSolution:self.model.currentBoardImageID];

      for(id key in self.playingPieces) {
         // find coordinates and flips/rotations in solutions for each piece
         NSDictionary *pieceDictionary = [currentBoardSolutionsDictionary objectForKey:key];
         UIImageView *currentPiece = [self.playingPieces objectForKey:key];
         
         NSInteger xBlock = [[pieceDictionary objectForKey:@"x"] integerValue];
         NSInteger yBlock = [[pieceDictionary objectForKey:@"y"] integerValue];
         NSInteger numRotations = [[pieceDictionary objectForKey:@"rotations"] integerValue];
         NSInteger numFlips = [[pieceDictionary objectForKey:@"flips"] integerValue];
  
         // set piece's coordinates to solutions specified coordinates, scaled by board square size
         CGFloat xCoordinate = self.centerBoardImageView.frame.origin.x;
         xCoordinate += xBlock*boardSquareSize;
         CGFloat yCoordinate = self.centerBoardImageView.frame.origin.y;
         yCoordinate += yBlock*boardSquareSize;
         
         // perform needed transformations to set pieces into solution on board
         [UIView animateWithDuration:1 animations:^{
            CGPoint newOrigin = [currentPiece.superview convertPoint:currentPiece.frame.origin
                                    toView:self.centerBoardImageView];
            currentPiece.frame = CGRectMake(newOrigin.x, newOrigin.y,
                                             currentPiece.frame.size.width,
                                             currentPiece.frame.size.height);
            
            [self.centerBoardImageView addSubview:currentPiece];
            
            currentPiece.transform = CGAffineTransformIdentity;
            currentPiece.transform =
               CGAffineTransformRotate(currentPiece.transform, numRotations * M_PI/2);

            if(numFlips == 1) {
               currentPiece.transform = CGAffineTransformScale(currentPiece.transform, -1, 1);
            }
      
            currentPiece.frame = CGRectMake(xCoordinate, yCoordinate,
                                            currentPiece.frame.size.width,
                                            currentPiece.frame.size.height);
            
            [self.view addSubview:currentPiece];
         }];
      }

      self.solveButton.enabled = NO;
   
   }

}

- (IBAction)resetPressed:(id)sender
{

   // default board image has no solution, so no reset is necessary for it
   if(self.model.currentBoardImageID != 0) {
      
      // get current board soltuions to undue them when resetting the tiles
      NSDictionary *currentBoardSolutionsDictionary =
         [self.model getSolution:self.model.currentBoardImageID];
      
      for(id key in self.playingPieces) {
         // find solution's flips and rotations to undo them
         NSDictionary *pieceDictionary = [currentBoardSolutionsDictionary objectForKey:key];
         UIImageView *currentPiece = [self.playingPieces objectForKey:key];
         
         NSInteger numRotations = [[pieceDictionary objectForKey:@"rotations"] integerValue];
         NSInteger numFlips = [[pieceDictionary objectForKey:@"flips"] integerValue];

         // undo solution flips and rotations
         [UIView animateWithDuration:1 animations:^{
            if(numFlips == 1) {
               currentPiece.transform = CGAffineTransformScale(currentPiece.transform, -1, 1);
            }

            currentPiece.transform = CGAffineTransformRotate(currentPiece.transform, -(numRotations * M_PI/2));
         }];
      }
   }
      // place pieces back in unsolved position
      [UIView animateWithDuration:1 animations:^{
         [self displayPieces];
      }];
      
      self.solveButton.enabled = YES;
}

-(void)addPlayingPieceGestures:(UIView*)imageView
{
   UITapGestureRecognizer *doubleTapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pieceDoubleTapped:)];
   doubleTapGesture.numberOfTapsRequired = 2;
   [imageView addGestureRecognizer:doubleTapGesture];
    
   UITapGestureRecognizer *singleTapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pieceSingleTapped:)];
   singleTapGesture.numberOfTapsRequired = 1;
   [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
   [imageView addGestureRecognizer:singleTapGesture];
   
   UIPanGestureRecognizer *panGesture =
      [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(piecePanRecognized:)];
   [imageView addGestureRecognizer:panGesture];

}

-(void)pieceSingleTapped:(UITapGestureRecognizer*)recognizer
{
   UIView *currentPiece = recognizer.view;
   [UIView animateWithDuration:1 animations:^{
      currentPiece.transform = CGAffineTransformRotate(currentPiece.transform, M_PI/2);
   }];
}

-(void)pieceDoubleTapped:(UITapGestureRecognizer*)recognizer
{
   UIView *currentPiece = recognizer.view;
   [UIView animateWithDuration:1 animations:^{
      currentPiece.transform = CGAffineTransformScale(currentPiece.transform, -1.0, 1.0);
   }];
}

-(void)piecePanRecognized:(UIPanGestureRecognizer*)recognizer
{
   UIView *currentPiece = recognizer.view;
    
   switch (recognizer.state) {
      case UIGestureRecognizerStateBegan: {
         currentPiece.transform =
            CGAffineTransformScale(currentPiece.transform, panMultiplier, panMultiplier);
         break;
      }
      case UIGestureRecognizerStateChanged: {
         currentPiece.center = [recognizer locationInView:currentPiece.superview];
         break;
      }
      case UIGestureRecognizerStateEnded:
      case UIGestureRecognizerStateCancelled: {
         // Now that the pan has ceased, place piece back in appropriate superview
         UIView *newSuperView;
         CGPoint oldOrigin, newOrigin, lowerRightCornerBound;
         
         // step down magnification
         currentPiece.transform =
            CGAffineTransformScale(currentPiece.transform, 1/panMultiplier, 1/panMultiplier);
         
         
         oldOrigin = [currentPiece.superview convertPoint:currentPiece.frame.origin toView:self.view];
         
         currentPiece.frame =
            CGRectMake(oldOrigin.x, oldOrigin.y,
                        currentPiece.frame.size.width, currentPiece.frame.size.height);
         
         [self.view addSubview:currentPiece];
            
         lowerRightCornerBound =
            CGPointMake(currentPiece.frame.origin.x + currentPiece.frame.size.width,
                        currentPiece.frame.origin.y + currentPiece.frame.size.height);
         
         // make sure images snap correctly into their view if inside the board
         if(CGRectContainsPoint(self.centerBoardImageView.frame, currentPiece.frame.origin)
            && CGRectContainsPoint(self.centerBoardImageView.frame, lowerRightCornerBound)){
            
            newSuperView = self.centerBoardImageView;
            newOrigin =
               [currentPiece.superview convertPoint:currentPiece.frame.origin toView:newSuperView];
            
            currentPiece.frame = CGRectMake(newOrigin.x, newOrigin.y,
                                 currentPiece.frame.size.width, currentPiece.frame.size.height);
            
            // scale origin of the block to ensure a "snap" into the frame of the board tiles
            CGFloat snapOriginX = boardSquareSize*floorf((newOrigin.x/boardSquareSize)+0.5);
            CGFloat snapOriginY = boardSquareSize*floorf((newOrigin.y/boardSquareSize)+0.5);
            newOrigin = CGPointMake(snapOriginX, snapOriginY);
         
         } else {
            newSuperView = self.view;
            newOrigin =
               [currentPiece.superview convertPoint:currentPiece.frame.origin toView:newSuperView];
         }
            
         if (newSuperView != currentPiece.superview) {
            [newSuperView addSubview:currentPiece];
            currentPiece.frame = CGRectMake(newOrigin.x, newOrigin.y,
                                    currentPiece.frame.size.width, currentPiece.frame.size.height);
         }
         
         break;

        }
        default:
            break;
    }
}

-(void)dismissMe
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InfoSegue"]) {
        InfoViewController *infoViewController = segue.destinationViewController;
        infoViewController.delegate = self;
    }
}
*/
-(IBAction)unwindSegue:(UIStoryboardSegue *)segue
{

}


@end
