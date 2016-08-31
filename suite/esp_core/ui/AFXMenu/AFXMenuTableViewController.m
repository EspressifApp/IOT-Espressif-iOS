//
//  AFXMenuTableViewController.m
//  AFXMenu
//
//  Created by 白 桦 on 7/11/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "AFXMenuTableViewController.h"
#import "AFXMenuItemCell.h"

@interface AFXMenuTableViewController ()

@property (nonatomic, strong) UIView *afxOverlayView;
@property (nonatomic, strong) UIView *afxContentView;
@property (nonatomic, strong) UITableView *afxTableView;
@property (nonatomic, strong) UITapGestureRecognizer *afxTap;
@property (nonatomic, strong) NSMutableArray *afxMenuItems;

@property (nonatomic, assign) CGFloat afxTotalHeight;
@property (nonatomic, assign) BOOL afxIsShowed;
@end

@implementation AFXMenuTableViewController

- (void)initInternal
{
    _afxMenuItems = [[NSMutableArray alloc]init];
    _afxTotalHeight = 0;
    _afxIsShowed = NO;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initInternal];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initInternal];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initInternal];
    }
    return self;
}


-(void) addMenuItem:(AFXMenuItem *)menuItem
{
    [_afxMenuItems addObject:menuItem];
    _afxTotalHeight += menuItem.afxMenuItemHeight;
    [_afxTableView reloadData];
}

-(void) removeMenuItem:(AFXMenuItem *)menuItem
{
    [_afxMenuItems removeObject:menuItem];
    _afxTotalHeight -= menuItem.afxMenuItemHeight;
    [_afxTableView reloadData];
}

-(UIView *)afxOverlayView
{
    if (!_afxOverlayView) {
        UIViewController *rootVC = self.afxParentViewController;
        UIView *rootView = rootVC.view;
        _afxOverlayView = [[UIView alloc]initWithFrame:rootView.bounds];
        _afxOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _afxOverlayView.backgroundColor = [UIColor colorWithRed:0 green:0.0 blue:0 alpha:0.3f];
        _afxOverlayView.alpha = 0.0;
        _afxOverlayView.userInteractionEnabled = YES;
        
    }
    return _afxOverlayView;
}

-(UIView *)afxContentView
{
    if (!_afxContentView) {
        _afxContentView = [[UIView alloc]init];
        _afxContentView.backgroundColor = [UIColor clearColor];
    }
    return _afxContentView;
}

-(UITableView *)afxTableView
{
    if (!_afxTableView) {
        _afxTableView = [[UITableView alloc]initWithFrame:_afxContentView.bounds style:UITableViewStylePlain];
        _afxTableView.dataSource = self;
        _afxTableView.delegate = self;
        _afxTableView.scrollEnabled = NO;
        _afxTableView.backgroundColor = [UIColor whiteColor];
        _afxTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _afxTableView;
}

-(UITapGestureRecognizer *)afxTap
{
    if (!_afxTap) {
        _afxTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponse:)];
    }
    return _afxTap;
}

-(void) tapResponse:(UITapGestureRecognizer*)tapRecognizer
{
    [self dismissMenuItems];
}

-(void) showMenuItems
{
    if (DEBUG_ON_AFXMENU) {
        NSLog(@"%@ %@",[self class],NSStringFromSelector(_cmd));
    }
    _afxIsShowed = YES;
    
    UIViewController *rootViewController = self.afxParentViewController;
    
    [rootViewController addChildViewController:self];
    [self didMoveToParentViewController:rootViewController];
    
    UIView *rootView = rootViewController.view;
    
    CGRect contentRect = [self onScreenContentViewFrame];
    self.afxContentView.frame = CGRectOffset(contentRect, 0, contentRect.size.height);
    
    [rootView addSubview:self.view];
    self.view.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.afxOverlayView.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.afxContentView.frame = contentRect;
    }completion:nil];
}

-(CGRect) onScreenContentViewFrame
{
    UIView *rootView = self.afxParentViewController.view;
    CGFloat width = rootView.bounds.size.width;
    CGFloat maxTotalHeight = rootView.bounds.size.height * kAFXMenuTableViewHeightMaxRatio;
    CGFloat height = MIN(_afxTotalHeight, maxTotalHeight);
    CGFloat x = 0;
    CGFloat y = rootView.bounds.size.height - height;
    return CGRectMake(x, y, width, height);
}

-(BOOL) shouldTableViewScrollEnabled
{
    UIView *rootView = self.afxParentViewController.view;
    CGFloat maxTotalHeight = rootView.bounds.size.height * kAFXMenuTableViewHeightMaxRatio;
    BOOL shouldTableViewScrollEnabled = _afxTotalHeight > maxTotalHeight;
    if (DEBUG_ON_AFXMENU) {
        NSLog(@"%@ %@ %@",[self class],NSStringFromSelector(_cmd),shouldTableViewScrollEnabled ? @"YES" : @"NO");
    }
    return shouldTableViewScrollEnabled;
}

-(void) closeMenuItems:(BOOL)isComplete
{
    if (DEBUG_ON_AFXMENU) {
        NSLog(@"%@ %@ isComplete:%@",[self class],NSStringFromSelector(_cmd),isComplete?@"YES":@"NO");
    }
    
    [_afxOverlayView removeGestureRecognizer:_afxTap];
    _afxTap = nil;
    
    [_afxTableView removeFromSuperview];
    _afxTableView = nil;
    
    [_afxContentView removeFromSuperview];
    _afxContentView = nil;
    
    [_afxOverlayView removeFromSuperview];
    _afxOverlayView = nil;
    
    [self.view removeFromSuperview];
    self.view = nil;
    
    [self willMoveToParentViewController:nil];
    [self removeFromParentViewController];

    if (isComplete) {
        _afxIsShowed = NO;
//        _afxParentViewController = nil;
    }
}

-(void) dismissMenuItems
{
    if (DEBUG_ON_AFXMENU) {
        NSLog(@"%@ %@",[self class],NSStringFromSelector(_cmd));
    }
    [UIView animateWithDuration:0.15 animations:^{
        _afxOverlayView.alpha = 0;
    }];
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _afxContentView.frame = CGRectOffset(_afxContentView.frame, 0, _afxContentView.frame.size.height);
    }completion:^(BOOL finished){
        [self closeMenuItems:YES];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.afxOverlayView addGestureRecognizer:self.afxTap];
    [self.view addSubview:self.afxContentView];
    [self.view insertSubview:self.afxOverlayView belowSubview:self.afxContentView];
    [self.afxContentView addSubview:self.afxTableView];
    self.afxTableView.scrollEnabled = [self shouldTableViewScrollEnabled];
    [self.afxTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _afxMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierAfxMenu = @"AfxMenuCellIdentifier";
    AFXMenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierAfxMenu];
    if (!cell) {
        AFXMenuItem *item = _afxMenuItems[indexPath.row];
        cell = [[AFXMenuItemCell alloc]initWithMenuItem:item];
        cell.textLabel.text = item.afxMenuItemTitle;
        cell.imageView.image = item.afxMenuItemImage;
    }
    return cell;
}

#pragma -mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AFXMenuItem *item = _afxMenuItems[indexPath.row];
    return item.afxMenuItemHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_afxDelegate respondsToSelector:@selector(menuItemSelected:)]) {
        AFXMenuItem *item = _afxMenuItems[indexPath.row];
        [_afxDelegate menuItemSelected:item];
        if (DEBUG_ON_AFXMENU) {
            NSLog(@"%@ %@ itemTitle:%@",[self class],NSStringFromSelector(_cmd),item.afxMenuItemTitle);
        }
    }
    [self dismissMenuItems];
}

#pragma -mark support screen rotate
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_afxIsShowed) {
        [self closeMenuItems:NO];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (_afxIsShowed) {
        [self showMenuItems];
    }
}

@end
