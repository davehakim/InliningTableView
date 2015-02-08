//
//  AlarmInputViewController.h
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 8/21/13.
//  Copyright (c) 2013 David Hakim. All rights reserved.
//

#import "TimeInputViewController.h"

@class AlarmInputViewController;

@protocol AlarmInputViewDelegate <TimeInputViewDelegate>
- (void) alarmInputViewDidSave:(AlarmInputViewController*)aiv;
@end

@interface AlarmInputViewController : TimeInputViewController {
	IBOutlet UISegmentedControl* alarmEnabledControl;
}

@property (readwrite,strong) NSObject <AlarmInputViewDelegate>* delegate;
@property (nonatomic) BOOL alarmEnabled;

- (IBAction) selectedAlarmTypeDidChange:(id)sender;
@end