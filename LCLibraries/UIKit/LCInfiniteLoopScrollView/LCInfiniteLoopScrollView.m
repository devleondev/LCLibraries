//
//  LCInfiniteLoopScrollView.m
//  LCLibraries
//
//  Created by leon@dev on 15/11/17.
//  Copyright © 2015年 Leon Cheung. All rights reserved.
//

#import "LCInfiniteLoopScrollView.h"

@interface LCInfiniteLoopScrollView () <UIScrollViewDelegate>
{
@private
    id<UIScrollViewDelegate,LCInfiniteLoopScrollViewDelegate>   _lcDelegate;
    
    CALayer                                                     *_firstLayer;
    CALayer                                                     *_lastLayer;
    NSMutableArray                                              *_totalLayers;
    
    UIView                                                      *_containerView;
}

@end

@implementation LCInfiniteLoopScrollView
@synthesize pageIndex   = _pageIndex;
@synthesize totalLayers = _totalLayers;

@dynamic delegate;

#pragma mark - Life Cycle

- (id)init {
    if(self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self commonInit];
}

#pragma mark - Setter / Getter

- (void)setDelegate:(id<UIScrollViewDelegate,LCInfiniteLoopScrollViewDelegate>)delegate {
    _lcDelegate = delegate;
}

- (id<UIScrollViewDelegate,LCInfiniteLoopScrollViewDelegate>) delegate{
    return _lcDelegate;
}

- (void)setPageIndex:(NSUInteger)pageIndex {
    _pageIndex = pageIndex;
}

#pragma mark - Private

- (void)commonInit {
    self.pagingEnabled                  = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
    super.delegate                      = self;
    
    _totalLayers                        = [[NSMutableArray alloc] init];
    
    _containerView                      = [[UIView alloc] init];
}

- (void)configureLayers {
    if([_layers count] <= 0) {
        return;
    }
    
    id firstRealLayer = [_layers lastObject];
    if([firstRealLayer isKindOfClass:[CALayer class]]) {
        _firstLayer = [self captureLayer:firstRealLayer];
    }
    
    if([firstRealLayer isKindOfClass:[UIView class]]){
        _firstLayer = [self captureLayer:((UIView *)firstRealLayer).layer];
    }
    
    id lastRealLayer = [_layers firstObject];
    if([lastRealLayer isKindOfClass:[CALayer class]]) {
        _lastLayer = [self captureLayer:lastRealLayer];
    }
    
    if([lastRealLayer isKindOfClass:[UIView class]]){
        _lastLayer = [self captureLayer:((UIView *)lastRealLayer).layer];
    }
    
    
    [_totalLayers removeAllObjects];
    if(_firstLayer) {
        [_totalLayers addObject:_firstLayer];
    }
    
    [_totalLayers addObjectsFromArray:_layers];
    
    if(_lastLayer) {
        [_totalLayers addObject:_lastLayer];
    }
}

- (void)layoutSublayers {
    if([_totalLayers count] <= 0) {
        return;
    }
    
    [self addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
        make.height.mas_equalTo(self.mas_height);
        make.width.mas_equalTo(self.frame.size.width * [_totalLayers count]);
    }];
    
    [_totalLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop){
        // should consider scroll direction.
        CGRect frame = layer.frame;
        frame.origin.x += self.frame.size.width * idx;
        layer.frame = frame;
        [_containerView.layer addSublayer:layer];
    }];
    
    CGFloat contentOffsetX = self.frame.size.width * 1;
    CGPoint offset = CGPointMake(contentOffsetX, 0);
    [self setContentOffset:offset animated:NO];
}

- (void)updatePageIndex {
    NSUInteger iOffsetWidth = (NSUInteger)self.contentOffset.x;
    NSUInteger iPageWidth = (NSUInteger)self.frame.size.width;
    
    NSUInteger idx = iOffsetWidth / iPageWidth;
    
    if(idx <= 0) {
        CGFloat contentOffsetX = self.frame.size.width * ([_totalLayers count] - 2);
        CGPoint offset = CGPointMake(contentOffsetX, 0);
        [self setContentOffset:offset animated:NO];
        _pageIndex = [_totalLayers count] - 3;
    }
    else if (idx >= [_totalLayers count] - 1) {
        CGFloat contentOffsetX = self.frame.size.width * 1;
        CGPoint offset = CGPointMake(contentOffsetX, 0);
        [self setContentOffset:offset animated:NO];
        _pageIndex = 0;
    }
    else {
        _pageIndex = idx - 1;
    }
}

- (void)updatePageIndexAndNotifyDelegate {
    [self updatePageIndex];
    
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(infiniteLoopScrollView:didScrollToPageIndex:)]) {
        [_lcDelegate infiniteLoopScrollView:self didScrollToPageIndex:_pageIndex];
    }
}

#pragma mark - Public

- (void)setLayers:(nonnull NSArray *)layers {
    _layers = layers;
    [self configureLayers];
    [self layoutSublayers];
    [self updatePageIndex];
}

- (void)scrollToIndex:(NSUInteger)idx animated:(BOOL)animated {
    if(idx >= [_totalLayers count]) {
        return;
    }
    
    CGFloat contentOffsetX = self.frame.size.width * (idx + 1);
    CGPoint offset = CGPointMake(contentOffsetX, 0);
    [self setContentOffset:offset animated:animated];
    [self updatePageIndexAndNotifyDelegate];
}

#pragma mark - Helpers

- (CALayer *)captureLayer:(CALayer *)layer {
    if(!layer){
        return nil;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0,
                             layer.bounds.size.width,
                             layer.bounds.size.height);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [layer renderInContext:context];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    
    CALayer *captuedLayer = [CALayer layer];
    captuedLayer.frame = layer.frame;
    captuedLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    return captuedLayer;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_lcDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [_lcDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_lcDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_lcDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_lcDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    if(!decelerate) {
        [self updatePageIndexAndNotifyDelegate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_lcDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_lcDelegate scrollViewDidEndDecelerating:scrollView];
    }
    
    [self updatePageIndexAndNotifyDelegate];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_lcDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [_lcDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [_lcDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [_lcDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_lcDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if(_lcDelegate && [_lcDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [_lcDelegate scrollViewDidScrollToTop:scrollView];
    }
}

@end
