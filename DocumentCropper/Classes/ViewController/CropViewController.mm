//
//  CropViewController.m
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//

#import "CropViewController.h"
#include <vector>
#import "OpenCVHelper.h"
#define backgroundHex @"2196f3"
#define kCameraToolBarHeight 100
#import "UIColor+HexRepresentation.h"
#import "CropView.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+ContentFrame.h"


@interface CropViewController ()
{
	CGFloat _rotateSlider;
	CGRect _initialRect,final_Rect;
	UIImage *_cropImage;
	CropView * _cropView;
}

	@property (strong, nonatomic) IBOutlet UIImageView *sourceImageView;
	@property (strong, nonatomic) IBOutlet UIView* croppedView;
	@property (strong, nonatomic) IBOutlet UIImageView *croppedImageView;

	@property (strong, nonatomic) CropView * cropView;

@end

@implementation CropViewController


+ (CropViewController*)getCropViewController:(CGRect)frame image:(UIImage*)image
{
	CropViewController* vc = [[CropViewController alloc] initWithNibName:@"CropViewController" bundle:[NSBundle mainBundle] ];
	vc.view.frame = frame;
	vc.adjustedImage = image;
	return vc;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	[self prepareViewController];
	[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [super viewWillAppear:YES];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[super viewWillDisappear:animated];
}

- (void)orientationChanged:(NSNotification *)notification
{
	[_cropView removeFromSuperview];
	[self prepareViewController];
}

- (void)prepareViewController
{
	[self prepareCropFrame];
	[self detectEdges];
	_initialRect = self.sourceImageView.frame;
	final_Rect =self.sourceImageView.frame;
}

-(void)prepareCropFrame
{
    [_sourceImageView setImage:_adjustedImage];
	[self.view layoutIfNeeded];
	_cropView= [[CropView alloc] initWithFrame:[_sourceImageView contentFrame]];
	[self.view addSubview:_cropView];
	
	UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePan:)];
	singlePan.maximumNumberOfTouches = 1;
	[_cropView addGestureRecognizer:singlePan];
}

#pragma mark - PanGesture
-(void)singlePan:(UIPanGestureRecognizer *)gesture{
	
	CGPoint posInStretch = [gesture locationInView:_cropView];
	
	//NSLog(@"Point X: %lf, Y: %lf", posInStretch.x, posInStretch.y);
    if(gesture.state==UIGestureRecognizerStateBegan)
        [_cropView findPointAtLocation:posInStretch];
	
    if(gesture.state==UIGestureRecognizerStateEnded)
	{
        _cropView.activePoint.backgroundColor = [UIColor grayColor];
        _cropView.activePoint = nil;
        [_cropView checkangle:0];
    }
    [_cropView moveActivePointToLocation:posInStretch];
}

#pragma mark - IBAction
- (IBAction)cropClicked:(id)sender
{
	if([_cropView frameEdited])
	{
		[self prepareImageFromCroppedFrame];
		[self showCroppedView];
	}
	else
		NSLog(@"nvalid Rect");
}

- (IBAction)cropCompleteClicked:(id)sender
{	
	[_cropdelegate cropView:self didFinishWithImage:_cropImage];
}

- (IBAction)cropBackClick:(id)sender
{
	[_croppedView removeFromSuperview];
	[_cropView removeFromSuperview];
	[self prepareViewController];
}

- (IBAction)backClicked:(id)sender {
	
	[_cropdelegate cropView:self failedCroppingImage:_adjustedImage];
}

- (IBAction)rightRotateClicked:(id)sender {
	
	CGFloat value = (int)floorf((_rotateSlider + 1)*2) + 1;
	__weak typeof(self) weakSelf = self;
	
	if(value>4){ value -= 4; }
	_rotateSlider = value / 2 - 1;
	[UIView animateWithDuration:0.5 animations:^{
		[weakSelf rotateStateDidChange];
	}];
}

- (IBAction)leftRotateClicked:(id)sender
{
	CGFloat value = (int)floorf((_rotateSlider + 1)*2) - 1;
	__weak typeof(self) weakSelf = self;
	
	if(value>4){ value -= 4; }
	_rotateSlider = value / 2 - 1;
	[UIView animateWithDuration:0.5 animations:^{
		[weakSelf rotateStateDidChange];
		//[weakSelf.cropView rotateLeft];
	}];
}

- (void)showCroppedView
{
	_croppedView.frame = self.view.frame;
	_croppedImageView.image = _cropImage;
	[self.view addSubview:_croppedView];
}

#pragma mark -  Image Processing
-(UIImage *)grayImage:(UIImage *)processedImage
{
    cv::Mat grayImage = [OpenCVHelper cvMatGrayFromAdjustedUIImage:processedImage];
	
    cv::GaussianBlur(grayImage, grayImage, cvSize(11,11), 0);
    cv::adaptiveThreshold(grayImage, grayImage, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
    
    UIImage *grayeditImage=[OpenCVHelper UIImageFromCVMat:grayImage];
     grayImage.release();
    
    return grayeditImage;
}

-(UIImage *)magicColor:(UIImage *)processedImage{
    cv::Mat  original = [OpenCVHelper cvMatFromAdjustedUIImage:processedImage];
    
    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
    
    original.convertTo(new_image, -1, 1.9, -80);
    
    original.release();
    UIImage *magicColorImage=[OpenCVHelper UIImageFromCVMat:new_image];
    new_image.release();
    return magicColorImage;
}

-(UIImage *)blackandWhite:(UIImage *)processedImage{
    cv::Mat original = [OpenCVHelper cvMatGrayFromAdjustedUIImage:processedImage];
    
    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
    
    original.convertTo(new_image, -1, 1.4, -50);
    original.release();
    
    UIImage *blackWhiteImage=[OpenCVHelper UIImageFromCVMat:new_image];
    new_image.release();
    return blackWhiteImage;
}

#pragma mark - Animate
- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise
{
    CGFloat arg = _rotateSlider*M_PI;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    transform = CATransform3DRotate(transform, 0*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, 0*M_PI, 1, 0, 0);
    
    return transform;
}

- (void)rotateStateDidChange
{
    CATransform3D transform = [self rotateTransform:CATransform3DIdentity clockwise:YES];
    
    CGFloat arg = _rotateSlider*M_PI;
    CGFloat Wnew = fabs(_initialRect.size.width * cos(arg)) + fabs(_initialRect.size.height * sin(arg));
    CGFloat Hnew = fabs(_initialRect.size.width * sin(arg)) + fabs(_initialRect.size.height * cos(arg));
    
    CGFloat Rw = final_Rect.size.width / Wnew;
    CGFloat Rh = final_Rect.size.height / Hnew;
    CGFloat scale = MIN(Rw, Rh) * 1;
    transform = CATransform3DScale(transform, scale, scale, 1);
    _sourceImageView.layer.transform = transform;
    _cropView.layer.transform = transform;
}

#pragma mark - OpenCV
- (void)detectEdges
{
	cv::Mat original = [OpenCVHelper cvMatFromUIImage:_sourceImageView.image];
	CGSize targetSize = [_sourceImageView contentSize];
	cv::resize(original, original, cvSize(targetSize.width, targetSize.height));
	
	std::vector<std::vector<cv::Point>>squares;
	std::vector<cv::Point> largest_square;
	
	find_squares(original, squares);
	find_largest_square(squares, largest_square);
	
	if (largest_square.size() == 4)
	{
		NSDictionary* sortedPoints = sortPoints(largest_square);
		[_cropView topLeftCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"0"] CGPointValue]];
		[_cropView topRightCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"1"] CGPointValue]];
		[_cropView bottomRightCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"2"] CGPointValue]];
		[_cropView bottomLeftCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"3"] CGPointValue]];
		
		NSLog(@"%@ Sorted Points",sortedPoints);
	}	
	original.release();
}

NSDictionary* sortPoints(std::vector<cv::Point> largest_square){

	NSMutableArray *points = [NSMutableArray array];
	NSMutableDictionary *sortedPoints = [NSMutableDictionary dictionary];
	
	for (int i = 0; i < 4; i++)
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:CGPointMake(largest_square[i].x, largest_square[i].y)], @"point" , [NSNumber numberWithInt:(largest_square[i].x + largest_square[i].y)], @"value", nil];
		[points addObject:dict];
	}
	
	int min = [[points valueForKeyPath:@"@min.value"] intValue];
	int max = [[points valueForKeyPath:@"@max.value"] intValue];
	
	int minIndex = 0;
	int maxIndex = 0;
	
	int missingIndexOne = 0;
	int missingIndexTwo = 0;
	
	for (int i = 0; i < 4; i++)
	{
		NSDictionary *dict = [points objectAtIndex:i];
		
		if ([[dict objectForKey:@"value"] intValue] == min)
		{
			[sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"0"];
			minIndex = i;
			continue;
		}
		
		if ([[dict objectForKey:@"value"] intValue] == max)
		{
			[sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"2"];
			maxIndex = i;
			continue;
		}
		
		NSLog(@"MSSSING %i", i);
		missingIndexOne = i;
	}
	
	for (int i = 0; i < 4; i++)
		if (missingIndexOne != i && minIndex != i && maxIndex != i)
			missingIndexTwo = i;
	
	if (largest_square[missingIndexOne].x < largest_square[missingIndexTwo].x)
	{	//2nd Point Found
		[sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"3"];
		[sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"1"];
	}
	else
	{	//4rd Point Found
		[sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"1"];
		[sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"3"];
	}
	
	return sortedPoints;
}

void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point>>&squares) {
	
	// blur will enhance edge detection
	cv::Mat blurred(image);
	
	GaussianBlur(image, blurred, cvSize(11,11), 0);//change from median blur to gaussian for more accuracy of square detection
	
	cv::Mat gray0(blurred.size(), CV_8U), gray;
	std::vector<std::vector<cv::Point> > contours;
	
	// find squares in every color plane of the image
	for (int c = 0; c < 3; c++)
	{
		int ch[] = {c, 0};
		mixChannels(&blurred, 1, &gray0, 1, ch, 1);
		
		// try several threshold levels
		const int threshold_level = 2;
		for (int l = 0; l < threshold_level; l++)
		{
			// Use Canny instead of zero threshold level!
			// Canny helps to catch squares with gradient shading
			if (l == 0)
			{
				Canny(gray0, gray, 10, 20, 3);
				
				// Dilate helps to remove potential holes between edge segments
				dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
			}
			else
				gray = gray0 >= (l+1) * 255 / threshold_level;
			
			// Find contours and store them in a list
			findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
			
			// Test contours
			std::vector<cv::Point> approx;
			for (size_t i = 0; i < contours.size(); i++)
			{
				// approximate contour with accuracy proportional
				// to the contour perimeter
				approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
				
				// Note: absolute value of an area is used because
				// area may be positive or negative - in accordance with the
				// contour orientation
				if (approx.size() == 4 &&
					fabs(contourArea(cv::Mat(approx))) > 1000 &&
					isContourConvex(cv::Mat(approx)))
				{
					double maxCosine = 0;
					
					for (int j = 2; j < 5; j++)
					{
						double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
						maxCosine = MAX(maxCosine, cosine);
					}
					
					if (maxCosine < 0.3)
						squares.push_back(approx);
				}
			}
		}
	}
}

void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
	if (!squares.size())
	{
		// no squares detected
		return;
	}
	
	int max_width = 0;
	int max_height = 0;
	int max_square_idx = 0;
	
	for (int i = 0; i < squares.size(); i++)
	{
		// Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
		cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
		
		// Store the index position of the biggest square found
		if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
		{
			max_width = rectangle.width;
			max_height = rectangle.height;
			max_square_idx = i;
		}
	}
	
	biggest_square = squares[max_square_idx];
}

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
	double dx1 = pt1.x - pt0.x;
	double dy1 = pt1.y - pt0.y;
	double dx2 = pt2.x - pt0.x;
	double dy2 = pt2.y - pt0.y;
	return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

- (void)prepareImageFromCroppedFrame
{
	CGFloat scaleFactor =  [_sourceImageView contentScale];
	CGPoint ptBottomLeft = [_cropView coordinatesForPoint:1 withScaleFactor:scaleFactor];
	CGPoint ptBottomRight = [_cropView coordinatesForPoint:2 withScaleFactor:scaleFactor];
	CGPoint ptTopRight = [_cropView coordinatesForPoint:3 withScaleFactor:scaleFactor];
	CGPoint ptTopLeft = [_cropView coordinatesForPoint:4 withScaleFactor:scaleFactor];
	
	CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
	CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
	CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
	CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
	
	CGFloat maxWidth = (w1 > w2) ? w1 : w2;
	CGFloat maxHeight = (h1 > h2) ? h1 : h2;
	
	cv::Point2f src[4], dst[4];
	src[0].x = ptTopLeft.x;
	src[0].y = ptTopLeft.y;
	src[1].x = ptTopRight.x;
	src[1].y = ptTopRight.y;
	src[2].x = ptBottomRight.x;
	src[2].y = ptBottomRight.y;
	src[3].x = ptBottomLeft.x;
	src[3].y = ptBottomLeft.y;
	
	dst[0].x = 0;
	dst[0].y = 0;
	dst[1].x = maxWidth - 1;
	dst[1].y = 0;
	dst[2].x = maxWidth - 1;
	dst[2].y = maxHeight - 1;
	dst[3].x = 0;
	dst[3].y = maxHeight - 1;
	
	cv::Mat undistorted = cv::Mat( cvSize(maxWidth,maxHeight), CV_8UC4);
	cv::Mat original = [OpenCVHelper cvMatFromUIImage:_adjustedImage];
	cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
	
	_cropImage = [OpenCVHelper UIImageFromCVMat:undistorted];
	original.release();
	undistorted.release();
}

@end
