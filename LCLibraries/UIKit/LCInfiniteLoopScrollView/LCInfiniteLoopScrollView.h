//
//  LCInfiniteLoopScrollView.h
//  LCLibraries
//
//  Created by leon@dev on 15/11/17.
//  Copyright © 2015年 Leon Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LCInfiniteLoopScrollViewDelegate;

@interface LCInfiniteLoopScrollView : UIScrollView
@property (nonatomic, weak) id<UIScrollViewDelegate, LCInfiniteLoopScrollViewDelegate>    delegate;
@property (nonatomic, assign, readonly) NSUInteger                                        pageIndex;

// Set the layers to show, you can set layer of array or view of array, suggest layers.
// May be views.
@property (nonatomic, strong, readwrite) NSArray                               * _Nonnull layers;

/**
 *  @author leon, 15-11-17 13:11:54
 *
 *  Scroll to a new page index with animate.
 *
 *  @param idx      page index.
 *  @param animated animate or not.
 */
- (void)scrollToIndex:(NSUInteger)idx animated:(BOOL)animated;

@end


@protocol LCInfiniteLoopScrollViewDelegate <NSObject>

- (void)infiniteLoopScrollView:(nonnull LCInfiniteLoopScrollView *)infiniteLoopScrollView
          didScrollToPageIndex:(NSUInteger)pageIndex;

@end
