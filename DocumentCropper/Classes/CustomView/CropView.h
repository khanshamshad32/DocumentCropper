//
//  CropView.h
//  OpenCVDemo
//
//  Created by Shamshad Khan on 05/09/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CropView : UIView


@property (nonatomic, strong) UIView *activePoint;

@property (strong, nonatomic) UIView *pointD;
@property (strong, nonatomic) UIView *pointC;
@property (strong, nonatomic) UIView *pointB;
@property (strong, nonatomic) UIView *pointA;
//middle points
@property (strong, nonatomic) UIView *pointE,*pointF,*pointG,*pointH;
@property (nonatomic, strong) NSMutableArray *points;


- (BOOL) frameEdited;
-(void)findPointAtLocation:(CGPoint)location;
- (void)moveActivePointToLocation:(CGPoint)locationPoint;
-(void)checkangle:(int)index;

-(void)cornerControlsMiddle;
- (CGPoint)coordinatesForPoint: (int)point withScaleFactor: (CGFloat)scaleFactor;
- (void)bottomLeftCornerToCGPoint: (CGPoint)point;
- (void)bottomRightCornerToCGPoint: (CGPoint)point;
- (void)topRightCornerToCGPoint: (CGPoint)point;
- (void)topLeftCornerToCGPoint: (CGPoint)point;

@end
