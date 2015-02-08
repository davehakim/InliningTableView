//
//  PickerInputView.m
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 3/26/13.
//  Copyright (c) 2013 David Hakim. All rights reserved.
//

#import "PickerInputViewController.h"

@interface PickerInputViewController () <UIPickerViewDataSource,UIPickerViewDelegate> {
	UINavigationItem* navigationItem;
	
	NSObject <PickerInputViewControllerDelegate>* _delegate;
}

@end

@implementation PickerInputViewController
@synthesize delegate = _delegate;
@dynamic title,selectedRow;

- (void) reload {
	[pickerView reloadAllComponents];
}

- (void) setSelectedRow:(NSInteger)selectedRow {
	if (selectedRow > 0 && [pickerView numberOfRowsInComponent:0] > selectedRow) {
		[pickerView selectRow:selectedRow inComponent:0 animated:YES];
	}

}

- (NSInteger) selectedRow {
	return [pickerView selectedRowInComponent:0];
}

- (void) setTitle:(NSString *)title {
	navigationItem.title = title;
}

- (NSString*) title {
	return navigationItem.title;
}

- (void) setDelegate:(NSObject<PickerInputViewControllerDelegate> *)delegate {
	_delegate = delegate;
}

- (void) viewDidLoad {
	CGRect r = self.view.frame;
	r.size = CGSizeMake(320, 216);
	self.view.frame =r;
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[pickerView]" options:0 metrics:nil views:@{@"pickerView":pickerView}]];
	
	pickerView.showsSelectionIndicator = YES;
	
	pickerView.dataSource = self;
	pickerView.delegate = self;
	
	UIImage* resizableOverlay = [pickerViewOverlay.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
	pickerViewOverlay.image = resizableOverlay;
}

- (void) save:(id)sender {

	[self.delegate pickerInputViewDidSave:self];
}

- (void) cancel:(id)sender {
	[self.delegate pickerInputViewDidCancel:self];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*) pv {
	return 1;
}

- (NSInteger) pickerView:(UIPickerView*)pv numberOfRowsInComponent:(NSInteger) component {
	return [self.delegate numberOfRowsInPickerInputView:self];
}

#pragma mark UIPickerViewDelegate methods


// In order to fix the default behavior of UIPickerView did select row to work more like a UITableView
// with selectable rows, we need to

- (UIView*)pickerView:(UIPickerView *)pv viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	UIButton* button = nil;
	
	if (view == nil) {
		button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		if ([pv respondsToSelector:@selector(setTintColor:)]) {
			[button setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
		} else {
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		}
		button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];

		button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
		button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		view = button;
	} else {
		button = (UIButton*)view;
	}
	
	// Remove all current target actions
	[button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	
	// Set the tag to the row
	button.tag = row;
	
	NSString* title = [self.delegate pickerInputView:self titleForRow:row];
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:@selector(pickerDidSave:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[self.delegate pickerInputViewDidSave:self];
}

- (void) pickerDidSave: (id)sender {
	UIButton* button = (UIButton*)sender;
	[pickerView selectRow:button.tag inComponent:0 animated:YES];
	[self.delegate pickerInputViewDidSave:self];
}


@end
