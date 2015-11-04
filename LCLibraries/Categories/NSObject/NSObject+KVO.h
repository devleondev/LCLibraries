//
//  NSObject+KVO.h
//  LCLibraries
//
//  Created by leon on 5/4/15.
//  Copyright © 2015 Leon Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVOCallback)(NSString *keyPath, id object, NSDictionary *change, void *context);


@interface NSObject (KVO)

/**
 *  @author leon, 15-05-04 17:11:37
 *
 *  Begin Observing the target object.
 *
 *  @param target   The object which is observed.
 *  @param keyPath  Observing keyPath.
 *  @param callback Callback block.
 */

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath usingBlock:(KVOCallback)callback;

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options usingBlock:(KVOCallback)callback;

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context usingBlock:(KVOCallback)callback;

/**
 *  @author leon, 15-05-04 17:19:07
 *
 *  Begin Observing the target object.
 *
 *  @param target The object which is being observed now.
 */
- (void)stopObserving:(NSObject *)target;

@end