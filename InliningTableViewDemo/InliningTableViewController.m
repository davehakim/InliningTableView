//
//  InliningTableViewController.m
//
//  Created by David Hakim on 8/12/13.
//  Copyright (c) 2013 David Hakim.
//  License: http://www.opensource.org/licenses/mit-license.html
//

#import "InliningTableViewController.h"

@implementation InliningTableViewCell
@end

@interface InliningTableViewController ()

@property (strong,nonatomic) UITableViewCell* inputViewCell;
@property BOOL rotating;
@end

@implementation InliningTableViewController

- (NSIndexPath*)delegateIndexPath:(NSIndexPath*)indexPath {
	if (!self.inputViewIndexPath || indexPath.section != self.inputViewIndexPath.section || indexPath.row < self.inputViewIndexPath.row) {
		return indexPath;
	} else {
		NSIndexPath* modifiedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
		return modifiedIndexPath;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self numberOfSectionsInInliningTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rowsInSection;
    // Return the number of rows in the section.
	if (!self.inputViewIndexPath || section != self.inputViewIndexPath.section) {
		rowsInSection = [self inliningTableView:tableView numberOfRowsInSection:section];
	} else {
		rowsInSection = [self inliningTableView:tableView numberOfRowsInSection:section] + 1;
	}
	return rowsInSection;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell* cell;
	if ([indexPath isEqual: self.inputViewIndexPath]) {
		UITableViewCell* tvc = [self.tableView dequeueReusableCellWithIdentifier:@"InputViewCell"];
		tvc.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// In case this inputview is already a child of another cell, remove it
		if (self.inputView.superview) {
			[self.inputView removeFromSuperview];
		}
		
		// In case this cell already has other children (previous input views) remove them
		if (tvc.contentView.subviews.count > 0){
			NSArray* subviews = [tvc.contentView.subviews copy];
			for (UIView* v in subviews){
				[v removeFromSuperview];
			}
		}
		
		[tvc.contentView addSubview:self.inputView];
		
		[_inputView removeObserver:self forKeyPath:@"frame"];
		CGRect f = self.inputView.frame;
		f.origin = CGPointMake(0, 0);
		f.size = CGSizeMake(tvc.contentView.frame.size.width,f.size.height);
		self.inputView.frame = f;
		[_inputView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
		
		// Set the z position of the layer for the inputview cell to -1. This is important for iOS 7
		// in order to make sure that input view cells appear behind 'normal' cells
		tvc.layer.zPosition = -1;
		
		cell= tvc;
		
		// FIXME: I shouldn't need to do this but there is a repeatable bug with calling self.tableView
		// cellForRowAtIndexPath within the willShowTableViewCell callback
		self.inputViewCell = tvc;
	} else {
		NSIndexPath* delegateIndexPath = [self delegateIndexPath:indexPath];
		cell = [self inliningTableView:tableView cellForRowAtIndexPath:delegateIndexPath];
	}
	if (cell == nil) {
		NSLog(@"Badness %@, %@",self.inputViewIndexPath,indexPath);
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath isEqual: self.inputViewIndexPath]) {
		// NSLog(@"returning height for inlined row %f",self.inputView.frame.size.height);
		return  self.inputView.frame.size.height;
	
	} else {
		NSIndexPath* delegateIndexPath = [self delegateIndexPath:indexPath];
		return [self inliningTableView:tableView heightForRowAtIndexPath:delegateIndexPath];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath isEqual: self.inputViewIndexPath]) {
		// Do nothing if the input view was selected
	} else {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		NSIndexPath* delegateIndexPath = [self delegateIndexPath:indexPath];
		return [self inliningTableView:tableView didSelectRowAtIndexPath:delegateIndexPath];
	}
	

}

#pragma mark - protected methods

- (NSInteger)numberOfSectionsInInliningTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)inliningTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Override me
	return 0;
}

- (UITableViewCell*) inliningTableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
	// Override me
	return nil;
}

- (float)inliningTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	// Override me
	return 0;
}

- (void)inliningTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	// Override me
}

#pragma mark - inline input views


- (void)insertInputView:(UIView*)inputView atIndexPath:(NSIndexPath*)indexPath{
	// NSLog(@"Inserting input view at %@",indexPath);
	
	CGRect f = inputView.frame;
	f.origin = CGPointMake(0, 0);
	inputView.frame = f;
	
	if (!self.inputViewIndexPath) {
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		self.inputViewIndexPath = indexPath;
		self.inputView = inputView;
		[self.tableView endUpdates];
	} else if ([self.inputViewIndexPath isEqual:indexPath]){
		self.inputView = inputView;
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	} else {
		NSIndexPath* oldIndexPath = self.inputViewIndexPath;
		UITableViewCell* old = [self.tableView cellForRowAtIndexPath:self.inputViewIndexPath];

		
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:@[self.inputViewIndexPath] withRowAnimation:UITableViewRowAnimationTop];
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		self.inputViewIndexPath = indexPath;
		self.inputView = inputView;
		[self.tableView endUpdates];
		
		// All newly added rows need to be sent to the back in order not to overlap existing rows when they appear
		// This is a bug in ui tableview, it only makes sure the rows immediately above and below are at a higher z
		UITableViewCell* new = [self.tableView cellForRowAtIndexPath:self.inputViewIndexPath];
		[new.superview sendSubviewToBack:new];
		
		// In the case the old row being removed is above the new row we want it even farther back than the new row
		// to keep it from overlapping the new row (more table view bugs)
		if ([indexPath compare:oldIndexPath] == NSOrderedDescending) {
			[old.superview sendSubviewToBack:old];
		}
	}
	
	[self.tableView scrollRectToVisible:[self.tableView cellForRowAtIndexPath:self.inputViewIndexPath].frame animated:YES];
}

- (void) dismissCurrentInputView {
	if (self.inputViewIndexPath == nil) {
		return;
	}

	// Send the current inputview to the back
	UITableViewCell* tvc = [self.tableView cellForRowAtIndexPath:self.inputViewIndexPath];
	[tvc.superview sendSubviewToBack:tvc];
	
	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:@[self.inputViewIndexPath] withRowAnimation:UITableViewRowAnimationTop];
	self.inputViewIndexPath = nil;
	self.inputView = nil;
	[self.tableView endUpdates];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.inputViewIndexPath) {
		UITableViewCell* ivcell = self.inputViewCell;
		[ivcell.superview sendSubviewToBack:ivcell];
	}
	
	// IOS 8 separator indentation fix (http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working)
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
		cell.preservesSuperviewLayoutMargins = NO;
	}
}

//
// So the way the game is played is we watch for frame changes in the inlined view and, when they occur, we call begin
// and end updates on the table view. There are a number of cases where this causes autolayout's head to explode which
// we need to be careful of (calling begin / end updates will result in calls to get the cell height among other things).
//
// 1) If the frame changed is observed from within cellForRowAtIndexPath bad things happen (the table view is about to
// ask for a cell we're not done returning
//
// 2) If observation isn't disabled during rotation bad things can happen (generally if the inputview cell is just off
// screen. Just disable our begin / end updates in that case. The table view handles it.
//

- (void) setInputView:(UIView *)inputView {
	// If the inputview frame changes we want to refresh the table view to expand / contract as needed
	[_inputView removeObserver:self forKeyPath:@"frame"];
	_inputView = inputView;
	[_inputView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	self.rotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	self.rotating = NO;
}

- (void) refreshCurrentInputView {
	// under iOS 8 bad things happen if updates are done while rotating
	if (self.rotating)
		return;
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
	//[self.tableView scrollRectToVisible:[self.tableView cellForRowAtIndexPath:self.inputViewIndexPath].frame animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self refreshCurrentInputView];
}

- (void) dealloc{
	[_inputView removeObserver:self forKeyPath:@"frame"];
}

@end
