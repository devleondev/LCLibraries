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

- (void)beginObservingUsingBlock:(void (^)(NSNotification *note))block{
    [self beginObservingWithObject:nil usingBlock:block];
}

- (void)beginObservingWithObject:(id)object usingBlock:(void (^)(NSNotification *note))block{
    [self beginObservingWithObject:object inQueue:[NSOperationQueue mainQueue] usingBlock:block];
}

- (void)beginObservingWithObject:(id)object inQueue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block{
    [defaultCenter() addObserverForName:self object:object queue:queue usingBlock:block];
}

- (void)notify:(id)object {
    [defaultCenter() postNotificationName:self object:object];
}

- (void)notify:(id)object userInfo:(NSDictionary *)userInfo {
    [defaultCenter() postNotificationName:self object:object userInfo:userInfo];
}

@end
