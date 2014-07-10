//
//  MSStylerTests.m
//  Tests
//
//  Created by Eric Horacek on 6/22/14.
//
//

#import <XCTest/XCTest.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerHelperFunctions.h>
#import <Aspects/Aspects.h>
#import <libextobjc/EXTScope.h>

@interface MSTestStyler : NSObject <MSDynamicsDrawerStyler>

@end

@implementation MSTestStyler

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)didMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction { }

@end

@interface MSStylerTests : XCTestCase

@property (nonatomic, strong) MSDynamicsDrawerViewController *drawerViewController;

@end

@implementation MSStylerTests

- (void)testStylerLifecycleAddedRemoved
{
    void(^testStylerLifecycleForDirection)(MSDynamicsDrawerDirection direction) = ^(MSDynamicsDrawerDirection direction) {
        
        __block NSInteger invocationCount = 0;
        MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection) {
            invocationCount++;
        });
        
        UIWindow *window = [UIWindow new];
        MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];
        window.rootViewController = drawerViewController;
        
        MSTestStyler *testStyler = [MSTestStyler new];
        
        __block BOOL willMoveInvoked = NO;
        __block NSInteger willMoveInvocationCount = 0;
        __block MSDynamicsDrawerDirection willMoveDirection = MSDynamicsDrawerDirectionNone;
        
        id <AspectToken> willMoveToken = [testStyler aspect_hookSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer");
            XCTAssertTrue((direction & stylerDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertNil(drawerViewController.view.window, @"Drawer view controller view not yet have window at this point");
            willMoveInvoked = YES;
            willMoveInvocationCount++;
            willMoveDirection |= stylerDirection;
        } error:NULL];
        
        __block BOOL didMoveInvoked = NO;
        __block NSInteger didMoveInvocationCount = 0;
        __block MSDynamicsDrawerDirection didMoveDirection = MSDynamicsDrawerDirectionNone;
        
        id <AspectToken> didMoveToken = [testStyler aspect_hookSelector:@selector(didMoveToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer");
            XCTAssertTrue((direction & stylerDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertEqual(drawerViewController.view.window, window, @"Drawer view controller view must have window at this point");
            didMoveInvoked = YES;
            didMoveInvocationCount++;
            didMoveDirection |= stylerDirection;
        } error:NULL];
        
        [drawerViewController addStyler:testStyler forDirection:direction];

        XCTAssertFalse(willMoveInvoked, @"Styler must be not yet have will move invoked");
        XCTAssertFalse(didMoveInvoked, @"Styler must be not yet have did move invoked");
        
        // Show the window (with the drawer as root view controller)
        window.hidden = NO;
        
        XCTAssertTrue(willMoveInvoked, @"Styler must be added when the view has been loaded");
        XCTAssertEqual(willMoveInvocationCount, invocationCount, @"Styler must be added individually for each direction it's added for");
        XCTAssertEqual(willMoveDirection, direction, @"Styler must be added individually for each direction it's added for");
        
        XCTAssertTrue(didMoveInvoked, @"Styler must be not yet be removed");
        XCTAssertEqual(didMoveInvocationCount, invocationCount, @"Styler must be added individually for each direction it's added for");
        XCTAssertEqual(didMoveDirection, direction, @"Styler must be added individually for each direction it's added for");
        
        [didMoveToken remove];
        [willMoveToken remove];
        
        willMoveInvoked = NO;
        willMoveInvocationCount = 0;
        willMoveDirection = MSDynamicsDrawerDirectionNone;
        
        [testStyler aspect_hookSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertNil(stylerDrawerViewController, @"Must be called with nil drawer");
            XCTAssertTrue((direction & stylerDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertEqual(drawerViewController.view.window, window, @"Drawer view controller view must have window at this point");
            willMoveInvoked = YES;
            willMoveInvocationCount++;
            willMoveDirection |= stylerDirection;
        } error:NULL];
        
        didMoveInvoked = NO;
        didMoveInvocationCount = 0;
        didMoveDirection = MSDynamicsDrawerDirectionNone;
        
        [testStyler aspect_hookSelector:@selector(didMoveToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertNil(stylerDrawerViewController, @"Must be called with nil drawer");
            XCTAssertTrue((direction & stylerDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertNil(drawerViewController.view.window, @"Drawer view controller view must not have window at this point");
            didMoveInvoked = YES;
            didMoveInvocationCount++;
            didMoveDirection |= stylerDirection;
        } error:NULL];
        
        // Remove the view controller
        window.rootViewController = nil;
        
        XCTAssertTrue(willMoveInvoked, @"Styler must be added when the view has been loaded");
        XCTAssertEqual(willMoveInvocationCount, invocationCount, @"Styler must be added individually for each direction it's added for");
        XCTAssertEqual(willMoveDirection, direction, @"Styler must be added individually for each direction it's added for");
        
        XCTAssertTrue(didMoveInvoked, @"Styler must be not yet be removed");
        XCTAssertEqual(didMoveInvocationCount, invocationCount, @"Styler must be added individually for each direction it's added for");
        XCTAssertEqual(didMoveDirection, direction, @"Styler must be added individually for each direction it's added for");
    };
    
    // Test for all values individually
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection direction) {
        testStylerLifecycleForDirection(direction);
    });
    
    // Test for masked values
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionAll);
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionHorizontal);
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionVertical);
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionRight);
}

- (void)testStylerLifecycleChangeState
{
    if (!NSClassFromString(@"XCTestExpectation")) {
        return;
    }
    
    void(^transitionFromStateToStateForDirectionAnimated)(MSDynamicsDrawerPaneState, MSDynamicsDrawerPaneState, MSDynamicsDrawerDirection, BOOL) = ^(MSDynamicsDrawerPaneState fromPaneSate, MSDynamicsDrawerPaneState toPaneState, MSDynamicsDrawerDirection direction, BOOL animated) {
        
        UIWindow *window = [UIWindow new];
        self.drawerViewController = [MSDynamicsDrawerViewController new];
        window.rootViewController = self.drawerViewController;
        
        UIViewController *rightDrawerViewController = [UIViewController new];
        [self.drawerViewController setDrawerViewController:rightDrawerViewController forDirection:direction];
        
        UIViewController *paneViewController = [UIViewController new];
        self.drawerViewController.paneViewController = paneViewController;
        
        self.drawerViewController.paneState = fromPaneSate;
        
        MSTestStyler *styler = [MSTestStyler new];
        MSTestStyler *oppositeDirectionStyler = [MSTestStyler new];
        
        __block BOOL mayUpdateToPaneStateInvoked = NO;
        id <AspectToken> mayUpdateToPaneStateToken = [MSTestStyler aspect_hookSelector:@selector(dynamicsDrawerViewController:mayUpdateToPaneState:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerPaneState stylerPaneState, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual([aspectInfo instance], styler, @"Must only be invoked for styler");
            XCTAssertEqual(self.drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylerPaneState, toPaneState, @"Must be called with correct pane state");
            XCTAssertEqual(stylerDirection, direction, @"Must be in correct direction");
            mayUpdateToPaneStateInvoked = YES;
        } error:NULL];
        
        __block BOOL didUpdatePaneClosedFractionInvoked = NO;
        NSMutableArray *paneClosedFractions = [NSMutableArray new];
        id <AspectToken> didUpdatePaneClosedFractionToken = [MSTestStyler aspect_hookSelector:@selector(dynamicsDrawerViewController:didUpdatePaneClosedFraction:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, CGFloat paneClosedFraction, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual([aspectInfo instance], styler, @"Must only be invoked for styler");
            XCTAssertEqual(self.drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylerDirection, direction, @"Must be in correct direction");
            XCTAssertTrue(mayUpdateToPaneStateInvoked, @"May update to pane state must be invoked before paneClosedFraction");
            [paneClosedFractions addObject:@(paneClosedFraction)];
            didUpdatePaneClosedFractionInvoked = YES;
        } error:NULL];
        
        __block BOOL didUpdateToPaneStateInvoked = NO;
        id <AspectToken> didUpdateToPaneStateToken = [MSTestStyler aspect_hookSelector:@selector(dynamicsDrawerViewController:didUpdateToPaneState:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerPaneState stylerPaneState, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual([aspectInfo instance], styler, @"Must only be invoked for test styler");
            XCTAssertEqual(self.drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylerPaneState, toPaneState, @"Must be called with correct pane state");
            XCTAssertEqual(stylerDirection, direction, @"Must be in correct direction");
            XCTAssertTrue(didUpdatePaneClosedFractionInvoked, @"Must be invoked after didUpdatePaneClosedFraction");
            didUpdateToPaneStateInvoked = YES;
        } error:NULL];
        
        MSDynamicsDrawerDirection(^oppositeDirection)(MSDynamicsDrawerDirection) = ^(MSDynamicsDrawerDirection ofDirection) {
            switch ((NSInteger)ofDirection) {
            case MSDynamicsDrawerDirectionTop:
                return MSDynamicsDrawerDirectionBottom;
            case MSDynamicsDrawerDirectionLeft:
                return MSDynamicsDrawerDirectionRight;
            case MSDynamicsDrawerDirectionBottom:
                return MSDynamicsDrawerDirectionTop;
            case MSDynamicsDrawerDirectionRight:
                return MSDynamicsDrawerDirectionLeft;
            }
            return (MSDynamicsDrawerDirection)-1;
        };
        
        [self.drawerViewController addStyler:oppositeDirectionStyler forDirection:oppositeDirection(direction)];
        [self.drawerViewController addStyler:styler forDirection:direction];
        
        // Show the window (with the drawer as the rootViewController)
        window.hidden = NO;

#if __IPHONE_8_0
        XCTestExpectation *stateUpdateExpectation = [self expectationWithDescription:@"Update Pane State"];
#endif
        @weakify(self);
        [self.drawerViewController setPaneState:toPaneState animated:animated allowUserInterruption:NO completion:^{
            @strongify(self);
            XCTAssertTrue(didUpdateToPaneStateInvoked, @"Must invoke did update to pane state");
            CGPoint fromPaneStatePaneCenter = [self.drawerViewController.paneLayout paneCenterForPaneState:fromPaneSate direction:direction];
            CGFloat fromPaneStatePaneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:fromPaneStatePaneCenter forDirection:direction];
            XCTAssertEqualObjects([paneClosedFractions firstObject], @(fromPaneStatePaneClosedFraction), @"Pane closed fractions must start at fromPaneStatePaneClosedFraction");
            CGPoint toPaneStatePaneCenter = [self.drawerViewController.paneLayout paneCenterForPaneState:toPaneState direction:direction];
            CGFloat toPaneStatePaneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:toPaneStatePaneCenter forDirection:direction];
            XCTAssertEqualObjects([paneClosedFractions lastObject], @(toPaneStatePaneClosedFraction), @"Pane closed fractions must end at toPaneStatePaneClosedFraction");
#if __IPHONE_8_0
            [stateUpdateExpectation fulfill];
#endif
        }];
        XCTAssertTrue(mayUpdateToPaneStateInvoked, @"Must invoke may update to pane state immedately after setPaneState:");
        
#if __IPHONE_8_0
        [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
            [mayUpdateToPaneStateToken remove];
            [didUpdatePaneClosedFractionToken remove];
            [didUpdateToPaneStateToken remove];
        }];
#else 
        [mayUpdateToPaneStateToken remove];
        [didUpdatePaneClosedFractionToken remove];
        [didUpdateToPaneStateToken remove];
#endif
    };
    
    // Test transitioning between all states in all directions both animated and non-animated
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedDirection) {
        for (MSDynamicsDrawerPaneState fromPaneState = MSDynamicsDrawerPaneStateClosed; fromPaneState <= MSDynamicsDrawerPaneStateOpenWide; fromPaneState++) {
            for (MSDynamicsDrawerPaneState toPaneState = MSDynamicsDrawerPaneStateClosed; toPaneState <= MSDynamicsDrawerPaneStateOpenWide; toPaneState++) {
                if (fromPaneState != toPaneState) {
                    transitionFromStateToStateForDirectionAnimated(fromPaneState, toPaneState, maskedDirection, NO);
                    transitionFromStateToStateForDirectionAnimated(fromPaneState, toPaneState, maskedDirection, YES);
                }
            }
        }
    });
}

@end
