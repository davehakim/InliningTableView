//
//  AlarmInputViewController.m
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 8/21/13.
//  Copyright (c) 2013 David Hakim. All rights reserved.
//

#import "AlarmInputViewController.h"

@interface AlarmInputViewController ()
@end

@implementation AlarmInputViewController

- (void) _updateUI {
	[UIView animateWithDuration:.3 animations:^{
		CGRect r = self.view.frame;
		if (self.alarmEnabled) {
			r.size.height = 255;
		} else {
			r.size.height = 50;
		}
		
		self.view.frame = r;
	} completion:nil];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	// So I'm not sure when this started... maybe with the introduction of autolayout. But if you embed a view
	// from IB in a table cell and subviews of that view are located relative to the 'top layout guide', when the cell scrolls
	// off the top of the screen and then back down those subviews will be at the BOTTOM of the cell. I expect this is
	// just a tableview bug. Locking the subview to the top of their containing view fixes.
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:alarmEnabledControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTopMargin multiplier:1 constant:10]];
	
	[self _updateUI];
}

- (IBAction) save:(id)sender {
	[super save:self];
	
	[self.delegate alarmInputViewDidSave:self];
}

- (IBAction) selectedAlarmTypeDidChange:(id)sender {
	[self save:self];
	
	[self _updateUI];
}

- (void) setAlarmEnabled:(BOOL)alarmEnabled {
	alarmEnabledControl.selectedSegmentIndex = alarmEnabled ? 0 : 1;
	
	[self _updateUI];
}

- (BOOL) alarmEnabled {
	return alarmEnabledControl.selectedSegmentIndex == 0;
}

@end
