//
//  TimeInputViewController.h
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 3/14/14.
//  Copyright (c) 2014 David Hakim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeInputViewController;

@protocol TimeInputViewDelegate
@optional
- (void) timeInputViewDidSave:(TimeInputViewController*)tiv;
@end

@interface TimeInputViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate> {
	
	// Protected
	NSDate* _time;

	IBOutlet UIPickerView* timePicker;
	IBOutlet UIImageView* pickerViewOverlay;
}

@property (readwrite,nonatomic) NSInteger hours;
@property (readwrite,nonatomic) NSInteger minutes;
@property (readwrite,nonatomic) NSInteger seconds;
@property (readwrite,nonatomic) NSDate* time;
@property (readwrite,nonatomic) BOOL uses24HrTimeFormat;

@property (readwrite,strong) NSObject <TimeInputViewDelegate>* delegate;

- (IBAction) save:(id)sender;
@end
