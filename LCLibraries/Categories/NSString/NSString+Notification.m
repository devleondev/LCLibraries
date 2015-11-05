//
//  NSString+Notification.m
//  
//
//  Created by leon@dev on 15/11/4.
//
//

#import "NSString+Notification.h"

static NSNotificationCenter *defaultCenter() {
     return [NSNotificationCenter defaultCenter];
};

@implementation NSString (Notification)

#pragma mark - Post Notification

- (void)post {
    [self postWithObject:nil];
}

- (void)postWithObject:(id)object {
    [self postWithObject:object userInfo:nil];
}

- (void)postWithObject:(id)object userInfo:(NSDictionary *)userInfo {
    [defaultCenter() postNotificationName:self object:object userInfo:userInfo];
}

#pragma mark - Observer Notification

- (void)addObserver:(id)observer selector:(SEL)aSelector {
    [self addObserver:observer selector:aSelector object:nil];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector object:(id)anObject {
    [defaultCenter() addObserver:observer selector:aSelector name:self object:anObject];
}

#pragma mark - Remove Notification

- (void)removeObserver:(id)observer {
    [self removeObserver:observer object:nil];
}

- (void)removeObserver:(id)observer object:(id)anObject {
    [defaultCenter() removeObserver:observer name:self object:anObject];
}

@end
