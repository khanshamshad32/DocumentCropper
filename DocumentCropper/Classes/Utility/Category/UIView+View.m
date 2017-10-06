//
//  UIView+View.m
//  OpenCVDemo
//
//  Created by Shamshad Khan on 05/09/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "UIView+View.h"

@implementation UIView (View)

- (void) makeCircular {
	
	self.layer.cornerRadius = self.frame.size.width/2;
	self.layer.masksToBounds = YES;
	self.alpha	= 0.5;
	self.backgroundColor = [UIColor grayColor];
}

@end
