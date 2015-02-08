//
//  TimeInputViewController.m
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 3/14/14.
//  Copyright (c) 2014 David Hakim. All rights reserved.
//

#import "TimeInputViewController.h"

@implementation TimeInputViewController

@synthesize delegate,hours=_hours,minutes=_minutes,seconds=_seconds;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	timePicker.delegate = self;
	timePicker.dataSource = self;
	
	self.view.clipsToBounds = YES;
	
	CGRect r = self.view.frame;
	r.size.height = 216;
	// NSLog(@"resizing to height %f",r.size.height );
	self.view.frame = r;
	
	UIImage* resizableOverlay = [pickerViewOverlay.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
	pickerViewOverlay.image = resizableOverlay;
}

- (void) setTime:(NSDate*)time {
	_time = time;
	
	// Change the due date on the task but keep the original due time
	NSCalendar* cc = [NSCalendar currentCalendar];
	NSDateComponents *timeComps = [cc components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:time];
	
	self.hours = timeComps.hour;
	self.minutes = timeComps.minute;
	self.seconds = timeComps.second;
}

- (void) setHours:(NSInteger)hours {
	_hours = hours;
	if (self.uses24HrTimeFormat) {
		[timePicker selectRow:hours%24 inComponent:0 animated:YES];
	} else {
		[timePicker selectRow:hours%12 inComponent:0 animated:YES];
		[timePicker selectRow:hours/12 inComponent:2 animated:YES];
	}
}

- (NSInteger) hours {
	if (timePicker) {
		if (self.uses24HrTimeFormat) {
			_hours = [timePicker selectedRowInComponent:0];
		} else {
			_hours = [timePicker selectedRowInComponent:0] + 12*[timePicker selectedRowInComponent:2];
		}
	}
	return _hours;
}

- (void) setMinutes: (NSInteger)minutes {
	_minutes = minutes;
	[timePicker selectRow:minutes inComponent:1 animated:YES];
}

- (NSInteger) minutes {
	if (timePicker) _minutes = [timePicker selectedRowInComponent:1] ;
	return _minutes;
}

- (IBAction) save:(id)sender {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_time ];
	components.hour = self.hours;
	components.minute = self.minutes;
	components.second = self.seconds;
	
	_time = [calendar dateFromComponents:components];
	
	if ([self.delegate respondsToSelector:@selector(timeInputViewDidSave:)])
		[self.delegate timeInputViewDidSave:self];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*) pv {
	return self.uses24HrTimeFormat ? 2 : 3;
}

- (NSInteger) pickerView:(UIPickerView*)pv numberOfRowsInComponent:(NSInteger) component {
	if (component == 0) return self.uses24HrTimeFormat ? 24 : 12;
	else if (component == 1) return 60;
	else return 2;
}

#pragma mark UIPickerViewDelegate methods

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[self save:self];
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	UIButton* button = nil;
	
	if (view == nil) {
		button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
		// Set the text color of the given period picker to white under iOS 7
		if ([pickerView respondsToSelector:@selector(setTintColor:)]) {
			[button setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
		}else {
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		}
		button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
		
		button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
		button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		view = button;
	} else {
		button = (UIButton*)view;
	}
	
	NSString* title = [self _pickerView:pickerView titleForRow:row forComponent:component];
	[button setTitle:title forState:UIControlStateNormal];
	
	// Set the tag to the row
	button.tag = row;
	
	// Remove all current target actions
	[button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	
	if (component == 0) {
		[button addTarget:self action:@selector(selectHour:) forControlEvents:UIControlEventTouchUpInside];
	} else if (component == 1) {
		[button addTarget:self action:@selector(selectMinute:) forControlEvents:UIControlEventTouchUpInside];
	} else if (component == 2) {
		[button addTarget:self action:@selector(selectAMPM:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	
	return button;
}

- (void)selectHour:(UIButton*)button {
	[timePicker selectRow:button.tag inComponent:0 animated:YES];
	[self save:self];
}
- (void)selectMinute:(UIButton*)button  {
	[timePicker selectRow:button.tag inComponent:1 animated:YES];
	[self save:self];
}
- (void)selectAMPM:(UIButton*)button  {
	[timePicker selectRow:button.tag inComponent:2 animated:YES];
	[self save:self];
}

- (NSString*)_pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component == 0) {
		if (self.uses24HrTimeFormat) {
			return [NSString stringWithFormat:@"%02d",(int)row];
		} else {
			return row == 0 ? @"12" : [NSString stringWithFormat:@"%02d",(int)row];
		}
	} else if (component == 1) {
		return [NSString stringWithFormat:@"%02d",(int)row];
	} else {
		return row == 0 ? @"am" : @"pm";
	}
}
@end
