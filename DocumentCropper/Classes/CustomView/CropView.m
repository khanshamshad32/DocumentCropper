//
//  CropView.m
//  OpenCVDemo
//
//  Created by Shamshad Khan on 05/09/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "CropView.h"
#import "UIView+View.h"
#import "MTGeometry.h"

#define kCropButtonSize 20

@interface CropView ()
{
	CGPoint touchOffset;
	CGPoint a;
	CGPoint b;
	CGPoint c;
	CGPoint d;
	
	CGPoint e,f,g,h;
	CGFloat _minX, _maxX, _minY, _maxY;
	CGPoint prevPoint;
	BOOL frameMoved,middlePoint;
	NSUInteger currentIndex,previousIndex;
	int k;
}

@end

@implementation CropView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setClipsToBounds:NO];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:YES];
		[self setContentMode:UIViewContentModeRedraw];
		
		[self prepareSubviews];
		[self setPoints];
		[self setButtons];
	}
	return self;
}

- (void) prepareSubviews
{
	self.points=[[NSMutableArray alloc] init];
	
	[self addVertices];
	[self addEdgeCenters];
}

- (void) addVertices
{
	_pointA = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	_pointB = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	_pointC = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	_pointD = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];	

	[self addPoint:_pointD];
	[self addPoint:_pointC];
	[self addPoint:_pointB];
	[self addPoint:_pointA];
}

- (void) addEdgeCenters
{
	_pointE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	_pointF = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	_pointG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	_pointH = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCropButtonSize, kCropButtonSize)];
	
	[self addPoint:_pointE];
	[self addPoint:_pointF];
	[self addPoint:_pointG];
	[self addPoint:_pointH];
}

- (void) addPoint:(UIView*)point
{
	[point makeCircular];
	[self addSubview: point];
	[self.points addObject:point];
}

- (void)setPoints
{
	a = CGPointMake(0 , self.bounds.size.height);
	b = CGPointMake(self.bounds.size.width, self.bounds.size.height);
	c = CGPointMake(self.bounds.size.width, 0);
	d = CGPointMake(0, 0);
	
	//middle
	e = CGPointMake((a.x+b.x)/2 ,a.y);
	f = CGPointMake(b.x, (b.y + c.y)/2);
	g = CGPointMake((c.x+d.x)/2, c.y);
	h = CGPointMake(a.x, (a.y + d.y)/2);
	
	_minX = self.bounds.origin.x;
	_minY = self.bounds.origin.y;
	_maxX = self.bounds.origin.x + self.bounds.size.width;
	_maxY = self.bounds.origin.y + self.bounds.size.height;
}

- (void)setButtons
{
	_pointA.center = a;
	_pointB.center = b;
	_pointC.center = c;
	_pointD.center = d;
	_pointE.center = e;
	_pointF.center = f;
	_pointG.center = g;
	_pointH.center = h;
}

- (void) resetFrame
{
	[self setPoints];
	[self setNeedsDisplay];
	[self drawRect:self.bounds];
	
	[self setButtons];
}

- (BOOL) frameEdited
{
	return frameMoved;
}

- (void)needsRedraw
{
	
	[self setNeedsDisplay];
	[self setButtons];
	[self cornerControlsMiddle];
	[self drawRect:self.bounds];
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect;
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (context)
	{
		CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.0f);
		
		if([self checkForValidQuad] >= 0 ){
			frameMoved=YES;
			CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
		}
		else
		{
			frameMoved=NO;
			CGContextSetRGBStrokeColor(context, 1.0f, 0.0f, 0.0f, 1.0f);
		}
		
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, 4.0f);
		
		CGRect boundingRect = CGContextGetClipBoundingBox(context);
		CGContextAddRect(context, boundingRect);
		CGContextFillRect(context, boundingRect);
		
		CGMutablePathRef pathRef = CGPathCreateMutable();
		
		CGPathMoveToPoint(pathRef, NULL, _pointA.center.x, _pointA.center.y);
		CGPathAddLineToPoint(pathRef, NULL, _pointB.center.x, _pointB.center.y);
		CGPathAddLineToPoint(pathRef, NULL, _pointC.center.x, _pointC.center.y);
		CGPathAddLineToPoint(pathRef, NULL, _pointD.center.x, _pointD.center.y);
		
		CGPathCloseSubpath(pathRef);
		CGContextAddPath(context, pathRef);
		CGContextStrokePath(context);
		
		CGContextSetBlendMode(context, kCGBlendModeClear);
		
		CGContextAddPath(context, pathRef);
		CGContextFillPath(context);
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGPathRelease(pathRef);
	}
}

#pragma mark - Check for Valid Rect

-(double)checkForValidQuad
{
	for (int i=0; i<7; i++)
	{
		double angle = [self angleForIndex:i];
		
		if(angle < 0 ) return angle;
	}
	return 0;
}

-(double) angleForIndex:(int)index
{
	NSArray* points = [self getPoints];
	CGPoint p1;
	CGPoint p2 ;
	CGPoint p3;

	switch (index) {
		case 0:{
			
			p1 = [[points objectAtIndex:0] CGPointValue];
			p2 = [[points objectAtIndex:1] CGPointValue];
			p3 = [[points objectAtIndex:3] CGPointValue];
			
		}
			break;
		case 1:{
			p1 = [[points objectAtIndex:1] CGPointValue];
			p2 = [[points objectAtIndex:2] CGPointValue];
			p3 = [[points objectAtIndex:0] CGPointValue];
			
		}
			break;
		case 2:{
			p1 = [[points objectAtIndex:2] CGPointValue];
			p2 = [[points objectAtIndex:3] CGPointValue];
			p3 = [[points objectAtIndex:1] CGPointValue];
			
		}
			break;
			
		default:{
			p1 = [[points objectAtIndex:3] CGPointValue];
			p2 = [[points objectAtIndex:0] CGPointValue];
			p3 = [[points objectAtIndex:2] CGPointValue];
			
		}
			break;
	}

	CGPoint ab = CGPointMake( p2.x - p1.x, p2.y - p1.y );
	CGPoint cb = CGPointMake( p2.x - p3.x, p2.y - p3.y );
	float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
	float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
	float alpha = atan2(cross, dot);
	
	double angle = (-1*(float) floor(alpha * 180.0 / 3.14 + 0.5));
	return angle;
}

- (NSArray *)getPoints
{
	NSMutableArray *result = [NSMutableArray array];
	
	for (uint i=0; i<self.points.count; i++)
	{
		UIView *view = [self.points objectAtIndex:i];
		[result addObject:[NSValue valueWithCGPoint:view.center]];
	}
	return result;
}

-(void)swapTwoPoints
{
	if(k==2)
	{
		NSLog(@"Swicth  2");
		if([self checkForHorizontalIntersection])
		{
			CGRect temp0=[[self.points objectAtIndex:0] frame];
			CGRect temp3=[[self.points objectAtIndex:3] frame];
			
			[[self.points objectAtIndex:0] setFrame:temp3];
			[[self.points objectAtIndex:3] setFrame:temp0];
			[self checkangle:0];
			[self cornerControlsMiddle];
			[self setNeedsDisplay];
		}
		if ([self checkForVerticalIntersection])
		{
			CGRect temp0=[[self.points objectAtIndex:2] frame];
			CGRect temp3=[[self.points objectAtIndex:3] frame];
			
			[[self.points objectAtIndex:2] setFrame:temp3];
			[[self.points objectAtIndex:3] setFrame:temp0];
			[self checkangle:0];
			[self cornerControlsMiddle];
			[self setNeedsDisplay];
		}
	}
	else
	{
		NSLog(@"Swicth More then 2");
		CGRect temp2=[[self.points objectAtIndex:2] frame];
		CGRect temp0=[[self.points objectAtIndex:0] frame];
		
		[[self.points objectAtIndex:0] setFrame:temp2];
		[[self.points objectAtIndex:2] setFrame:temp0];
		[self cornerControlsMiddle];
		[self setNeedsDisplay];
	}
}

-(void)checkangle:(int)index
{
	k=0;
	
	for (int i=0; i<4; i++)
	{
		double angle = [self angleForIndex:i];
		if(angle < 0) ++k;
	}
	
	if(k>=2) [self swapTwoPoints];
	previousIndex=currentIndex;
}

-(BOOL)checkForHorizontalIntersection
{
	CGLine line1 = CGLineMake( _pointA.center , _pointB.center);
	CGLine line2 = CGLineMake( _pointC.center , _pointD.center);
	CGPoint temp = CGLinesIntersectAtPoint(line1, line2);
	
	if(temp.x != NULL_POINT.x && temp.y != NULL_POINT.y)
		return YES;
	return NO;
}

-(BOOL)checkForVerticalIntersection
{
	CGLine line3 = CGLineMake( _pointA.center , _pointD.center);	
	CGLine line4 = CGLineMake(_pointB.center, _pointC.center);
	CGPoint temp = CGLinesIntersectAtPoint(line3, line4);
	
	if(temp.x != NULL_POINT.x && temp.y != NULL_POINT.y)
		return YES;
	return NO;
}

- (void)bottomLeftCornerToCGPoint: (CGPoint)point
{
	a = point;
	[self needsRedraw];
}

- (void)bottomRightCornerToCGPoint: (CGPoint)point
{
	b = point;
	[self needsRedraw];
}

- (void)topRightCornerToCGPoint: (CGPoint)point
{
	c = point;
	[self needsRedraw];
}

- (void)topLeftCornerToCGPoint: (CGPoint)point
{
	d = point;
	[self needsRedraw];
}

- (CGPoint)coordinatesForPoint: (int)point withScaleFactor: (CGFloat)scaleFactor
{
	CGPoint tmp = CGPointMake(0, 0);
	
	switch (point) {
		case 1:
			tmp = CGPointMake( (_pointA.center.x) / scaleFactor, (_pointA.center.y) / scaleFactor);
			break;
		case 2:
			tmp = CGPointMake((_pointB.center.x) / scaleFactor, (_pointB.center.y) / scaleFactor);
			break;
		case 3:
			tmp = CGPointMake((_pointC.center.x) / scaleFactor, (_pointC.center.y) / scaleFactor);
			break;
		case 4:
			tmp =  CGPointMake((_pointD.center.x) / scaleFactor, (_pointD.center.y) / scaleFactor);
			break;
	}	
	return tmp;
}

#pragma mark - Support methods

-(void)findPointAtLocation:(CGPoint)location
{
	self.activePoint = nil;
	
	for (UIView *point in self.points)
	{		
		CGRect extentedFrame = CGRectInset(point.frame, -20, -20);
		
		if (CGRectContainsPoint(extentedFrame, location))
		{
			_activePoint = point;
			prevPoint = location;
			NSUInteger i = [_points indexOfObject:point];
			currentIndex = i;
			middlePoint = (i==4 || i==5 || i==6 || i==7) ? YES: NO;
			self.activePoint.backgroundColor = [UIColor redColor];
			break;
		}
	}
}

- (void)moveActivePointToLocation:(CGPoint)locationPoint
{
	if (_activePoint == nil) return ;
	
	CGPoint diff = CGPointMake(locationPoint.x - prevPoint.x, locationPoint.y - prevPoint.y);
	
	if (!middlePoint)
		[self moveCornerPoint:diff];
	else
		[self movePointsForMiddleWithDiff:diff];
	
	[self cornerControlsMiddle];
	prevPoint = locationPoint;
	
	[self setNeedsDisplay];
}

//Corner Touch

-(void)cornerControlsMiddle
{
	self.pointE.center = CGPointMake((_pointA.center.x + _pointB.center.x)/2,
									 (_pointA.center.y + _pointB.center.y)/2);
	self.pointG.center = CGPointMake((_pointC.center.x + _pointD.center.x)/2,
									 (_pointC.center.y + _pointD.center.y)/2);
	self.pointF.center = CGPointMake((_pointC.center.x + _pointB.center.x)/2,
									 (_pointC.center.y + _pointB.center.y)/2);
	self.pointH.center = CGPointMake((_pointA.center.x + _pointD.center.x)/2,
									 (_pointA.center.y + _pointD.center.y)/2);
}

- (void)moveCornerPoint:(CGPoint)diff
{
	CGPoint P = CGPointMake(_activePoint.center.x + diff.x, _activePoint.center.y + diff.y);
	
	if ( (P.x >= _minX && P.y >= _minY) && (P.x <= _maxX && P.y <= _maxY) )
		_activePoint.center = P;
}

//Middle Touch
- (void)movePointsForMiddleWithDiff:(CGPoint)diff
{
	switch (currentIndex) {
		case 4:
			// A and B
			[self movePoint:_pointA andPoint:_pointB diff:diff];
			break;
		case 5:
			// B and C
			[self movePoint:_pointB andPoint:_pointC diff:diff];
			break;
		case 6:
			//C and D
			[self movePoint:_pointC andPoint:_pointD diff:diff];
			break;
		case 7:
			// A and D
			[self movePoint:_pointA andPoint:_pointD diff:diff];
			break;
	}
}

-(void)movePoint:(UIView*)pointP andPoint:(UIView*)pointQ diff:(CGPoint)diff
{
	CGPoint P = CGPointMake(pointP.center.x + diff.x, pointP.center.y + diff.y);
	CGPoint Q = CGPointMake(pointQ.center.x + diff.x, pointQ.center.y + diff.y);
	
	if ( (P.x >= _minX && P.y >= _minY) && (Q.x >= _minX && Q.y >= _minY) &&
		(P.x <= _maxX && P.y <= _maxY) && (Q.x <= _maxX && Q.y <= _maxY) )
	{
		pointP.center = P;
		pointQ.center = Q;
	}
}

@end
