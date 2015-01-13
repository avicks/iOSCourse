//
//  Model.h
//  NationalParksII
//
//  Created by alex on 10/22/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

+(id)sharedInstance;

-(NSInteger)numberOfParks;
-(NSMutableDictionary*)getPark:(NSInteger)parkNumber;
-(NSInteger)photoCountOfPark:(NSInteger)parkNumber;
-(NSInteger)maxPhotoCount;
-(NSString*)titleForPark:(NSInteger)parkNumber;
-(NSString*)captionForPhoto:(NSInteger)parkNumber :(NSInteger)photoNumber;
-(NSString*)commentsForPhoto:(NSInteger)parkNumber :(NSInteger)photoNumber;
-(UIImage*)parkImage:(NSInteger)parkNumber :(NSInteger)photoNumber;

// editing
-(void)removePark:(NSInteger)parkNumber :(NSInteger)photoNumber;
-(void)moveParkPhoto:(NSInteger)fromSection :(NSInteger)fromRow :(NSInteger)toSection :(NSInteger)toRow;
-(void)addPark:(NSDictionary*)newPark;
-(void)addPhoto:(UIImage*)photo withTitle:(NSString*)title inSection:(NSInteger)section;
-(void)setCaption:(NSString*)caption forPhoto:(NSInteger)photoNumber ofPark:(NSInteger)parkNumber;
-(void)setComments:(NSString*)comments forPhoto:(NSInteger)photoNumber ofPark:(NSInteger)parkNumber;
-(void)sortParks;

//[self.model setCaption:caption forPhoto:photoNumber ofPark:parkNumber];
           //[self.model setComments:comments forPhoto:photoNumber ofPark:parkNumber];

@end
