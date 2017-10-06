//
//  CropViewController.h
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//


#import <UIKit/UIKit.h>

@class CropViewController;

@protocol CropViewDelegate <NSObject>

@required
-(void)cropView:(CropViewController*)cropView didFinishWithImage:(UIImage*)croppedImage;
-(void)cropView:(CropViewController*)cropView failedCroppingImage:(UIImage*)image;

@end

@interface CropViewController : UIViewController

@property (strong, nonatomic) UIImage *adjustedImage;
@property (weak,nonatomic) id<CropViewDelegate> cropdelegate;

+ (CropViewController*)getCropViewController:(CGRect)frame image:(UIImage*)image;

- (IBAction)cropClicked:(id)sender;
- (IBAction)backClicked:(id)sender;
- (IBAction)rightRotateClicked:(id)sender;
- (IBAction)leftRotateClicked:(id)sender;

- (IBAction)cropBackClick:(id)sender;
- (IBAction)cropCompleteClicked:(id)sender;


@end
