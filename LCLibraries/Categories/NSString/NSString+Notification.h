//
//  NSString+Notification.h
//  
//
//  Created by leon@dev on 15/11/4.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Notification)

#pragma mark - Post Notification

- (void)post;

- (void)postWithObject:(id)object;

- (void)postWithObject:(id)object userInfo:(NSDictionary *)userInfo;

#pragma mark - Observer Notification

- (void)addObserver:(id)observer selector:(SEL)aSelector;

- (void)addObserver:(id)observer selector:(SEL)aSelector object:(id)anObject;

#pragma mark - Remove Notification

- (void)removeObserver:(id)observer;

- (void)removeObserver:(id)observer object:(id)anObject;

@end
