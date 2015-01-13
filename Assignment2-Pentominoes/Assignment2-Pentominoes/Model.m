//
//  Model.m
//  Assignment3
//
//  Created by alex on 9/18/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "Model.h"

@interface Model ()
@property (strong, nonatomic) NSArray *boardImages;
@property (strong, nonatomic) NSArray *solutions;

@end

@implementation Model

-(id)init
{
    self = [super init];
    if (self) {
        _solutions = [self createSolutions];
        _boardImages = [self createBoardImages];
        _currentBoardImageID = 0;
    }
    return self;
}

-(NSDictionary*)createPentominoesPieces
{
   NSMutableDictionary *piecesDictionary = [[NSMutableDictionary alloc] init];
   
   NSArray *pieceArray =
      [NSArray arrayWithObjects:@"F",@"I",@"L",@"N",@"P",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
   
   for(NSString *path in pieceArray) {
      NSString *imagePathString = [NSString stringWithFormat:@"tile%@.png",path];
      UIImage *pieceImage = [UIImage imageNamed:imagePathString];
      [piecesDictionary setObject:pieceImage forKey:path];
   }
   
   return piecesDictionary;
}

-(NSArray*)createBoardImages
{
   NSArray *boardImages = [[NSArray alloc] initWithObjects:
      [UIImage imageNamed:@"Board0.png"], [UIImage imageNamed:@"Board1.png"],
      [UIImage imageNamed:@"Board2.png"], [UIImage imageNamed:@"Board3.png"],
      [UIImage imageNamed:@"Board4.png"], [UIImage imageNamed:@"Board5.png"], nil];
    
   return boardImages;
}

-(UIImage*)getBoardImage:(NSInteger)boardNumber
{
    return self.boardImages[boardNumber];
}

-(NSArray*)createSolutions {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"Solutions" ofType:@"plist"];
    NSArray *solutions = [NSArray arrayWithContentsOfFile:path];
    return solutions;
}

-(NSDictionary*)getSolution:(NSInteger)boardNumber
{
    NSDictionary *solution = [[NSDictionary alloc] initWithDictionary:self.solutions[boardNumber-1]];
    return solution;
}

@end
