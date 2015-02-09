//
//  InliningTableViewController.h
//
//  Created by David Hakim on 8/12/13.
//  Copyright (c) 2013 David Hakim.
//  License: http://www.opensource.org/licenses/mit-license.html
//

#import <UIKit/UIKit.h>

@interface InliningTableViewCell : UITableViewCell
@property UIView* inputView;
@end

@interface InliningTableViewController : UITableViewController

@property (strong,nonatomic) NSIndexPath* inputViewIndexPath;
@property (strong,nonatomic) UIView* inputView;

- (NSInteger)numberOfSectionsInInliningTableView:(UITableView *)tableView ;
- (NSInteger)inliningTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section ;
- (UITableViewCell*) inliningTableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (float)inliningTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)inliningTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void) insertInputView:(UIView*)inputView atIndexPath:(NSIndexPath*)indexPath;
- (void) dismissCurrentInputView ;
- (void) refreshCurrentInputView ;

@end
