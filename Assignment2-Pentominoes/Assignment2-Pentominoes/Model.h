//
//  Model.h
//  Assignment3
//
//  Created by alex on 9/18/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject
@property NSInteger currentBoardImageID;
-(NSDictionary*)createPentominoesPieces;
-(NSArray*)createBoardImages;
-(UIImage*)getBoardImage:(NSInteger)boardNumber;
-(NSDictionary*)getSolution:(NSInteger)boardNumber;
@end
