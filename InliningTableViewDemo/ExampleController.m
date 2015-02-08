//
//  FormViewController.m
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 8/16/13.
//  Copyright (c) 2013 David Hakim. All rights reserved.
//

#import "ExampleController.h"

#import "PickerInputViewController.h"
#import "AlarmInputViewController.h"

@interface LabelCell : InliningTableViewCell
@property (readwrite,weak) IBOutlet UILabel* label;
@property (readwrite,weak) IBOutlet UILabel* value;
@end

@implementation LabelCell

@end

@interface ExampleController () <PickerInputViewControllerDelegate,AlarmInputViewDelegate>
{
	LabelCell* alarmCell;
	LabelCell* pickerCell;
	UITableViewCell* textViewCell;
	
	AlarmInputViewController *alarmInputViewController; // Alarm input view controller
	PickerInputViewController *pickerInputViewController; // Picker input view controller
	
	NSDateFormatter* timeFormatter;
	UITableViewCell* activeCell;
}
@property (strong) UIView* activeFieldOrView;

@end

@implementation ExampleController

- (void)viewDidLoad {
	// Call the superclass implementation of inherited method
	[super viewDidLoad];
	
	// Link up the cells
	alarmCell = [self.tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
	pickerCell = [self.tableView dequeueReusableCellWithIdentifier:@"PickerCell"];
	textViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"TextViewCell"];
	
	alarmCell.accessoryView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inlineDisclosure"]];
	pickerCell.accessoryView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inlineDisclosure"]];
	
	// Initialize the picker input view
	pickerInputViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PickerInputViewController"];
	pickerInputViewController.delegate = self;

	// Initialize the alarm input view
	alarmInputViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmInputViewController"];
	alarmInputViewController.time = [NSDate date];
	alarmInputViewController.delegate = self;
	
	// Set the input views
	alarmCell.inputView = alarmInputViewController.view;
	pickerCell.inputView = pickerInputViewController.view;
	
	timeFormatter = [[NSDateFormatter alloc] init];
	timeFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"hh:mm" options:0 locale:timeFormatter.locale];
	
	self.navigationItem.title = @"Inlining Table View";
}

- (void) dismissCurrentInputView {
	// Call the inline table view controllers dismiss routine
	[super dismissCurrentInputView];
	
	// Animate the accessory view up
	[UIView animateWithDuration:0.3 animations:^{
		activeCell.accessoryView.transform = CGAffineTransformMakeRotation(0);
	}];
	
	// Mark the active cell as dismissed
	activeCell = nil;
}

#pragma mark - UITableViewDelegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) inliningTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 5;
	}
	return 0;
}

- (UITableViewCell*) inliningTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) return pickerCell;
	if (indexPath.row == 1) return alarmCell;
	if (indexPath.row == 2) return [self.tableView dequeueReusableCellWithIdentifier:@"DividerCell"];
	if (indexPath.row == 3) return textViewCell;
	else return [self.tableView dequeueReusableCellWithIdentifier:@"DividerCell"];
}

- (float) inliningTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((float[]){44,44,24,170,24})[indexPath.row];
}

- (void) inlineInputViewWillShow:(UIView*)inlineInputView {
	if (inlineInputView == alarmInputViewController.view) {
		
		if ([alarmCell.value.text isEqualToString:@"None"]) {
			alarmInputViewController.alarmEnabled = NO;
		} else {
			[alarmInputViewController setTime:[timeFormatter dateFromString:alarmCell.value.text]];
		}
		
	} else if (inlineInputView == pickerInputViewController.view) {
		
		pickerInputViewController.selectedRow = [@[@"red",@"green",@"blue"] indexOfObject:pickerCell.value.text];
	}
}

- (void) inliningTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell* newSelectedCell = [self inliningTableView:tableView cellForRowAtIndexPath:indexPath];
	UITableViewCell* oldSelectedCell = activeCell;
	
	if ([newSelectedCell isKindOfClass:[InliningTableViewCell class]] && newSelectedCell.inputView != nil) {
		
		// NSLog(@"newSelectedCell %@ inputView %@",newSelectedCell,newSelectedCell.inputView);
		InliningTableViewCell* selectedLabelCell = (InliningTableViewCell*)newSelectedCell;
		UIView* inputView = selectedLabelCell.inputView;
		
		if ((newSelectedCell == oldSelectedCell && self.inputView )  ) {
			
			[self dismissCurrentInputView];
			
		} else {
			[UIView animateWithDuration:0.3 animations:^{
				oldSelectedCell.accessoryView.transform = CGAffineTransformMakeRotation(0);
				newSelectedCell.accessoryView.transform = CGAffineTransformMakeRotation(-M_PI);
			}];
			
			
			[self inlineInputViewWillShow:inputView];
			
			NSIndexPath* oneBelow = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
			[self insertInputView:inputView atIndexPath:oneBelow];
			
			activeCell = newSelectedCell;
			
			// Dismiss any open non-inline input views
			[self.view endEditing:NO];
		}
	}
}


#pragma mark AlarmViewDelegate methods

- (void) alarmInputViewDidSave:(AlarmInputViewController *)aiv {
	alarmCell.value.text = !alarmInputViewController.alarmEnabled ? @"None" : [timeFormatter stringFromDate:alarmInputViewController.time];
}


#pragma mark PickerViewDelegate methods
- (void) pickerInputViewDidSave:(PickerInputViewController *)piv {
	pickerCell.value.text = [self pickerInputView:piv titleForRow:[piv selectedRow]];
}

- (NSInteger) numberOfRowsInPickerInputView:(PickerInputViewController *)pv {
	return 3;
}

- (NSString *)pickerInputView:(PickerInputViewController *)pv titleForRow:(NSInteger)row {
	return @[@"red",@"green",@"blue"][row];
}

@end

