//
//  UIViewController+LCPageJumper.h
//  LCLibraries
//
//  Created by leon@dev on 5/31/15.
//  Copyright (c) 2015 Leon Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LCPageJumperType){
    LCPageJumperType_None = -1,
    LCPageJumperType_Push,          // the default value
    LCPageJumperType_Present,
    LCPageJumperType_Pop
};

typedef void (^LCBeforeOpenBlock)(UIViewController *aViewController, LCPageJumperType jumperType);

@interface UIViewController (LCPageJumper)

#pragma mark - Class Method

/**
 *  创建页面
 *
 *  @param aController 页面类
 *  @param arguments   参数
 *
 *  @return 页面实例
 */
+ (UIViewController *)viewController:(NSString *)aController
                           arguments:(id)arguments, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Instance Method

/**
 *  设置页面参数
 *
 *  @param arguments 参数
 */
- (void)setArguments:(id)arguments, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  打开页面
 *
 *  @param aController 页面类,默认打开方式Push，有动画，无参数
 *
 *  @return 是否成功
 */
- (BOOL)openViewController:(NSString *)aController;

/**
 *  打开页面
 *
 *  @param aController 页面类,默认有动画，无参数
 *  @param jumperType  转场类型
 *
 *  @return 是否成功
 */
- (BOOL)openViewController:(NSString *)aController
                jumperType:(LCPageJumperType)jumperType;

/**
 *  打开页面
 *
 *  @param aController 页面类,默认默认打开方式Push，有动画，无参数
 *  @param arguments   页面参数
 *
 *  @return 是否成功
 */
- (BOOL)openViewController:(NSString *)aController
                 arguments:(id)arguments, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  打开页面
 *
 *  @param aController 页面类,默认有动画，无参数
 *  @param jumperType  转场类型
 *  @param arguments   页面参数
 *
 *  @return 是否成功
 */
- (BOOL)openViewController:(NSString *)aController
                jumperType:(LCPageJumperType)jumperType
                 arguments:(id)arguments, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  打开页面
 *
 *  @param aController       页面类
 *  @param jumperType        转场类型
 *  @param animated          是否动画
 *  @param beforeOpenBlock   打开前的回调
 *  @param afterOpenBlock    打开后的回调
 *  @param shouldRemovedList 需要在打开后移除的Controller
 *  @param arguments         页面参数
 *
 *  @return 是否成功
 */
- (BOOL)openViewController:(NSString *)aController
                jumperType:(LCPageJumperType)jumperType
                  animated:(BOOL)animated
           beforeOpenBlock:(LCBeforeOpenBlock)beforeOpenBlock
            afterOpenBlock:(LCBeforeOpenBlock)afterOpenBlock
         shouldRemovedList:(NSArray *)shouldRemovedList
                 arguments:(id)arguments, ... NS_REQUIRES_NIL_TERMINATION;

@end
