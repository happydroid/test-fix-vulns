//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "ConversationViewController.h"
#import <SignalUI/OWSViewController.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HVViewState;
@class TSThread;

@interface HomeViewController : OWSViewController

- (void)presentThread:(TSThread *)thread action:(ConversationViewAction)action animated:(BOOL)isAnimated;

- (void)presentThread:(TSThread *)thread
               action:(ConversationViewAction)action
       focusMessageId:(nullable NSString *)focusMessageId
             animated:(BOOL)isAnimated;

// Used by force-touch Springboard icon shortcut and key commands
- (void)showNewConversationView;
- (void)showNewGroupView;
- (void)focusSearch;
- (void)archiveSelectedConversation;
- (void)unarchiveSelectedConversation;

@property (nonatomic, readonly) HVViewState *viewState;
@property (nonatomic) TSThread *lastViewedThread;

// For use by Swift extension.
- (void)updateBarButtonItems;
- (void)updateViewState;
- (void)updateFirstConversationLabel;
- (void)presentGetStartedBannerIfNecessary;

@property (nonatomic) UIView *firstConversationCueView;
@property (nonatomic) BOOL hasShownBadgeExpiration;

@end

NS_ASSUME_NONNULL_END
