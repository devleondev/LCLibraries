//
//  UIViewController+LCPageJumper.m
//  LCLibraries
//
//  Created by leon@dev on 5/31/15.
//  Copyright (c) 2015 Leon Cheung. All rights reserved.
//

#import "UIViewController+LCPageJumper.h"

@implementation UIViewController (LCPageJumper)

#pragma mark - Class Method

+ (UIViewController *)viewController:(NSString *)aController
                           arguments:(id)arguments, ...
{
    if(!aController || aController.length != 0){
        return nil;
    }
    
    Class clazz = NSClassFromString(aController);
    if(!clazz){
        return nil;
    }
 
    UIViewController *viewController = [[clazz alloc] initWithNibName:aController
                                                               bundle:nil];
    if(!viewController){
        viewController = [[clazz alloc] init];
    }
    
    [viewController setArguments:arguments, nil];
    
    return viewController;
}

#pragma mark - Helpers

// You should nerver remove a top viewControler in current navigationController
- (void)removeControllers:(NSArray *)shouldRemovedList
{
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    NSMutableArray *willRemovedControllers = [NSMutableArray new];
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSString *className = NSStringFromClass([obj class]);
        __block BOOL shouldRemoved = NO;
        [shouldRemovedList enumerateObjectsUsingBlock:^(NSString *shouldRemovedClassName, NSUInteger idx, BOOL *stop){
            if([className isEqualToString:shouldRemovedClassName]){
                shouldRemoved = YES;
                *stop = YES;
            }
        }];
        
        // Nerver remove the top viewControler
        if(shouldRemoved && idx != 0){
            [willRemovedControllers addObject:obj];
        }
    }];
    
    [viewControllers removeObjectsInArray:willRemovedControllers];
    [self.navigationController setViewControllers:viewControllers];
}

- (void)pushViewController:(UIViewController *)aViewController
                  animated:(BOOL)animated
           beforeOpenBlock:(LCBeforeOpenBlock)beforeOpenBlock
            afterOpenBlock:(LCBeforeOpenBlock)afterOpenBlock
         shouldRemovedList:(NSArray *)shouldRemovedList
{
    NSAssert(aViewController != nil, @"The target viewController should not be nil");
    if(beforeOpenBlock){
        beforeOpenBlock(aViewController, LCPageJumperType_Push);
    }
    
    [self.navigationController pushViewController:aViewController
                                         animated:animated];
    if(afterOpenBlock){
        afterOpenBlock(aViewController, LCPageJumperType_Push);
    }
    
    if(!shouldRemovedList || [shouldRemovedList count] == 0){
        return;
    }
    
    [self removeControllers:shouldRemovedList];
}

- (void)presentViewController:(UIViewController *)aViewController
                     animated:(BOOL)animated
              beforeOpenBlock:(LCBeforeOpenBlock)beforeOpenBlock
               afterOpenBlock:(LCBeforeOpenBlock)afterOpenBlock
            shouldRemovedList:(NSArray *)shouldRemovedList
{
    NSAssert(aViewController != nil, @"The target viewController should not be nil");
    if(beforeOpenBlock){
        beforeOpenBlock(aViewController, LCPageJumperType_Present);
    }
    
    [self.navigationController presentViewController:aViewController animated:animated completion:^{
        if(afterOpenBlock){
            afterOpenBlock(aViewController, LCPageJumperType_Present);
        }
        
        
        if(!shouldRemovedList || [shouldRemovedList count] == 0){
            return;
        }
        
        [self removeControllers:shouldRemovedList];
    }];
}

- (NSArray *)popToViewController:(NSString *)aController
                        animated:(BOOL)animated
                 beforeOpenBlock:(LCBeforeOpenBlock)beforeOpenBlock
                  afterOpenBlock:(LCBeforeOpenBlock)afterOpenBlock
               shouldRemovedList:(NSArray *)shouldRemovedList
{
    NSAssert(aController != nil, @"The target controller name should not be empty");
    __block UIViewController *targetVC = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSString *className = NSStringFromClass([obj class]);
        if([className isEqualToString:aController]){
            targetVC = obj;
        }
    }];
    
    NSArray *popedViewControllers = nil;
    if(!targetVC){
        if(beforeOpenBlock){
            beforeOpenBlock(targetVC, LCPageJumperType_Pop);
        }
        popedViewControllers = [self.navigationController popToViewController:targetVC
                                                                     animated:animated];
        if(afterOpenBlock){
            afterOpenBlock(targetVC, LCPageJumperType_Pop);
        }
    }

    
    if(!shouldRemovedList || [shouldRemovedList count] == 0){
        return popedViewControllers;
    }
    
    [self removeControllers:shouldRemovedList];

    return popedViewControllers;
}

#pragma mark - Instance Method

- (void)setArguments:(id)arguments, ...
{
    
}

- (BOOL)openViewController:(NSString *)aController
{
    return [self openViewController:aController
                         jumperType:LCPageJumperType_Push];
}

- (BOOL)openViewController:(NSString *)aController
                jumperType:(LCPageJumperType)jumperType
{
    return [self openViewController:aController
                         jumperType:jumperType
                          arguments:nil];
}

- (BOOL)openViewController:(NSString *)aController
                 arguments:(id)arguments, ...
{
    return [self openViewController:aController
                         jumperType:LCPageJumperType_Push
                          arguments:arguments, nil];
}

- (BOOL)openViewController:(NSString *)aController
                jumperType:(LCPageJumperType)jumperType
                 arguments:(id)arguments, ...
{
    return [self openViewController:aController
                         jumperType:jumperType
                           animated:YES
                    beforeOpenBlock:nil
                     afterOpenBlock:nil
                  shouldRemovedList:nil
                          arguments:arguments,nil];
}

- (BOOL)openViewController:(NSString *)aController
                jumperType:(LCPageJumperType)jumperType
                  animated:(BOOL)animated
           beforeOpenBlock:(LCBeforeOpenBlock)beforeOpenBlock
            afterOpenBlock:(LCBeforeOpenBlock)afterOpenBlock
         shouldRemovedList:(NSArray *)shouldRemovedList
                 arguments:(id)arguments, ...
{
    UIViewController *viewController = [[self class] viewController:aController
                                                          arguments:arguments, nil];
    if(!viewController){
        return NO;
    }
    
    switch (jumperType) {
        case LCPageJumperType_None:
        case LCPageJumperType_Push:{
            [self pushViewController:viewController
                            animated:animated
                     beforeOpenBlock:beforeOpenBlock
                      afterOpenBlock:afterOpenBlock
                   shouldRemovedList:shouldRemovedList];
            break;
        }
        case LCPageJumperType_Present:{
            [self presentViewController:viewController
                               animated:animated
                        beforeOpenBlock:beforeOpenBlock
                         afterOpenBlock:afterOpenBlock
                      shouldRemovedList:shouldRemovedList];
            break;
        }
        case LCPageJumperType_Pop:{
            [self popToViewController:aController
                             animated:animated
                      beforeOpenBlock:beforeOpenBlock
                       afterOpenBlock:afterOpenBlock
                    shouldRemovedList:shouldRemovedList];
            break;
        }
        default:
            break;
    }
    
    return NO;
}

@end
