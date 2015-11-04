//
//  NSObject+KVO.m
//  LCLibraries
//
//  Created by leon on 5/4/15.
//  Copyright © 2015 Leon Cheung. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+KVO.h"




#pragma mark - Target

static char kKVOCallbackKey;
static char kObservingKeyPath;


/**
 *  @author leon, 15-05-04 17:11:13
 *
 *  The object which is being observed
 */
@interface NSObject (KVO_Target)
@property (nonatomic, copy)     KVOCallback     callback;
@property (nonatomic, copy)     NSString        *observingKeyPath;

@end

@implementation NSObject (KVO_Target)

#pragma mark - Getter / Setter

- (void)setCallback:(KVOCallback)callback {
    objc_setAssociatedObject(self, &kKVOCallbackKey,
                             callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (KVOCallback)callback {
    return objc_getAssociatedObject(self, &kKVOCallbackKey);
}

- (void)setObservingKeyPath:(NSString *)observingKeyPath {
    objc_setAssociatedObject(self, &kObservingKeyPath,
                             observingKeyPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)observingKeyPath {
    return objc_getAssociatedObject(self, &kObservingKeyPath);
}

@end


@implementation NSObject (KVO)

#pragma mark - Public Method

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath usingBlock:(KVOCallback)callback {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self beginObserving:target keyPath:keyPath options:options  context:NULL usingBlock:callback];
}

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options usingBlock:(KVOCallback)callback {
    [self beginObserving:target keyPath:keyPath options:options context:NULL usingBlock:callback];
}

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context usingBlock:(KVOCallback)callback {
    if(!target) {
        return;
    }
    
    if(keyPath.length <= 0) {
        return;
    }
    
    [target addObserver:self forKeyPath:keyPath options:options context:context];
    [target setCallback:callback];
    [target setObservingKeyPath:keyPath];
    
    [self swizzleKVOSelector];
}

- (void)stopObserving:(NSObject *)target {
    if(!target) {
        return;
    }

    NSAssert(target.observingKeyPath.length > 0, @"Without observingKeyPath can't be stoped");
    
    [target removeObserver:self forKeyPath:target.observingKeyPath];
}


#pragma mark - Private Method

- (void)swizzled_observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    [self swizzled_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if(!object.callback) {
        return;
    }
    
    object.callback(keyPath, object, change, context);
}

- (void)dynamic_observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if(!object.callback) {
        return;
    }
    
    object.callback(keyPath, object, change, context);
}

- (void)swizzleKVOSelector {
    SEL originalSelector = @selector(observeValueForKeyPath:ofObject:change:context:);
    SEL dynamicSelector = @selector(dynamic_observeValueForKeyPath:ofObject:change:context:);
    SEL swizzledSelector = @selector(swizzled_observeValueForKeyPath:ofObject:change:context:);
    
    Class clazz = self.class;
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method dynamicMethod = class_getInstanceMethod(clazz, dynamicSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    IMP dynamicImp = class_getMethodImplementation(clazz, dynamicSelector);
    
    BOOL addSuccessfully = class_addMethod(clazz,
                                           originalSelector,
                                           dynamicImp,
                                           method_getTypeEncoding(dynamicMethod));
    
    if(!addSuccessfully) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
