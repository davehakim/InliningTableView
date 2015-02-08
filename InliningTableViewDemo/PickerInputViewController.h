//
//  PickerInputView.h
//  WhereDoesTheTimeGo
//
//  Created by David Hakim on 3/26/13.
//  Copyright (c) 2013 David Hakim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerInputViewController;

@protocol PickerInputViewControllerDelegate <NSObject>

- (void) pickerInputViewDidSave:(PickerInputViewController *)piv;
- (NSString *)pickerInputView:(PickerInputViewController *)pv titleForRow:(NSInteger)row;
- (NSInteger) numberOfRowsInPickerInputView:(PickerInputViewController *)pv;

@optional
- (void) pickerInputViewDidCancel:(PickerInputViewController*)piv;

@end

@interface PickerInputViewController : UIViewController {
	IBOutlet UIPickerView* pickerView;
	IBOutlet UIImageView* pickerViewOverlay;
}
@property (readwrite,nonatomic,strong) NSObject <PickerInputViewControllerDelegate> * delegate;
@property (readwrite,nonatomic) NSInteger selectedRow;

-(void) reload;
@end
