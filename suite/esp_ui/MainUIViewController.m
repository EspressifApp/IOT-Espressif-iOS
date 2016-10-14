//
//  MainUIViewController.m
//  suite
//
//  Created by 白 桦 on 5/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "MainUIViewController.h"
#import "MJRefresh.h"
#import "ESPUser.h"
#import "ESPConstantsNotification.h"
#import "ESPVersionMacro.h"
#import "ESPDeviceLightViewController.h"
#import "ESPDevicePlugViewController.h"
#import "ESPEsptouchViewController.h"
#import "UITableViewRowAction+JZExtension.h"
#import "ESPUIAlertView.h"

#define kCellReuseIdentifier    @"MainUIViewControllerCell"


/**
 *       ------------------
 *       | 111111111111111 |
 *       | 222222222222222 |
 *       | ............... |
 *       |                 |
 *       |                 |
 *       |                 |
 *       |                 |
 *       | ................|
 *       | 222222222222222 |
 *       | 333333333333333 |
 *       -------------------
 *
 *       1: titlebar
 *       2: tableView
 *       3: toolbar
 *
 *       titlebar:
 *       ------------------
 *       |44             55|
 *       -------------------
 *
 *       4: titlebarLeftBtn
 *       5: titlebarRightBtn
 *       
 *       toolbar:
 *       ------------------
 *       |66    77777    88|
 *       -------------------
 *
 *       6: addDeviceBtn
 *       7: sceneBtn
 *       8: editBtn
 */
@interface MainUIViewController()
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ESPUser *user;
@property (strong, nonatomic) NSMutableArray *deviceArray;
@property (strong, nonatomic) ESPDevice *deviceSelected;

@property (strong, nonatomic) UIActivityIndicatorView *aiv;
@property (strong, nonatomic) ESPUIAlertView *alertView;
@end


@implementation MainUIViewController

- (void) viewInit
{
    // set background white
    self.view.backgroundColor = [UIColor whiteColor];
    
    UINavigationBar *titlebar = [[UINavigationBar alloc]init];
    titlebar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titlebar];
    
    // self.titlebar.leading = self.view.leading
    NSLayoutConstraint *titlebarConstraintX = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:titlebarConstraintX];
    // self.titlebar.top = self.view.top + 20.0
    NSLayoutConstraint *titlebarConstraintY = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    [self.view addConstraint:titlebarConstraintY];
    // self.titlebar.width = self.view.width
    NSLayoutConstraint *titlebarConstraintWidth = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:titlebarConstraintWidth];
    // self.titlebar.height = 44.0
    NSLayoutConstraint *titlebarConstraintHeight = [NSLayoutConstraint constraintWithItem:titlebar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:44.0];
    [self.view addConstraint:titlebarConstraintHeight];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    navigationItem.title = @"IOT Espressif";
    
    // titlebar left
    UIBarButtonItem *titlebarItemLeft = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(tapTitlebarButtonLeft)];
    navigationItem.leftBarButtonItem = titlebarItemLeft;
    
    // titlebar right: menu
    AFXMenu *menu = [[AFXMenu alloc]init];
    
    if([self addMenuItems:menu]) {
        menu.afxMenuTitle = @"Menu";
        menu.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIBarButtonItem *titlebarItemRight = [[UIBarButtonItem alloc]initWithCustomView:menu];
        navigationItem.rightBarButtonItem = titlebarItemRight;
        [titlebar pushNavigationItem:navigationItem animated:NO];
        
        CGFloat titlebarItemRightWidth = 53.0f;
        CGFloat titlebarItemRightMargin = 3.0f;
        
        // menu.leading = titlebar.trailing - titlebarItemRightWidth - titlebarItemRightMargin
        NSLayoutConstraint *menuConstraintX = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-titlebarItemRightWidth-titlebarItemRightMargin];
        [titlebar addConstraint:menuConstraintX];
        // menu.top = titlebar.top
        NSLayoutConstraint *menuConstraintY = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [titlebar addConstraint:menuConstraintY];
        // menu.width = titlebarItemRightWidth
        NSLayoutConstraint *menuConstraintWidth = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:titlebarItemRightWidth];
        [titlebar addConstraint:menuConstraintWidth];
        // menu.height = titlebar.height
        NSLayoutConstraint *menuConstraintHeight = [NSLayoutConstraint constraintWithItem:menu attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [titlebar addConstraint:menuConstraintHeight];
    } else {
        [titlebar pushNavigationItem:navigationItem animated:NO];
    }
    
    
    
    // tableView
    self.tableView = [[UITableView alloc]init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // self.tableView.leading = self.view.leading
    NSLayoutConstraint *tableViewConstraintX = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:tableViewConstraintX];
    // self.tableView.top = titlebar.bottom
    NSLayoutConstraint *tableViewConstraintY = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titlebar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:tableViewConstraintY];
    // self.tableView.width = self.view.width
    NSLayoutConstraint *tableViewConstraintWidth = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:tableViewConstraintWidth];
    // self.tableView.height = self.view.height － 108.0(108=44+44+20)
    NSLayoutConstraint *tableViewConstraintHeight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant: - 108.0];
    [self.view addConstraint:tableViewConstraintHeight];
    
    
    // toolbar
    UIToolbar *toolbar = [[UIToolbar alloc]init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbar];
    
    // toolbar.leading = self.view.leading
    NSLayoutConstraint *toolbarConstraintX = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:toolbarConstraintX];
    // toolbar.top = self.tableView.bottom
    NSLayoutConstraint *toolbarConstraintY = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:toolbarConstraintY];
    // toolbar.width = self.view.width
    NSLayoutConstraint *toolbarConstraintWidth = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:toolbarConstraintWidth];
    // toolbar.height = 44
    NSLayoutConstraint *toolbarConstraintHeight = [NSLayoutConstraint constraintWithItem:toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44.0];
    [self.view addConstraint:toolbarConstraintHeight];
    
    
    UIBarButtonItem *toolbarAdd = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tapToolbarAdd)];
//    UIBarButtonItem *toolbarEdit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(tapToolbarEdit)];
//    UIBarButtonItem *toolbarScene = [[UIBarButtonItem alloc]initWithTitle:@"Scene" style:UIBarButtonItemStyleBordered target:self action:@selector(tapToolbarScene)];
    UIBarButtonItem *toolbarFlexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    toolbar.items = @[toolbarFlexibleSpace,toolbarAdd,toolbarFlexibleSpace,toolbarScene,toolbarFlexibleSpace, toolbarEdit,toolbarFlexibleSpace];
    
    toolbar.items = @[toolbarFlexibleSpace,toolbarAdd,toolbarFlexibleSpace];
}

- (void) alertIndicatorViewInit {
    self.alertView = [[ESPUIAlertView alloc]init];
    
    // aiv
    self.aiv = [[UIActivityIndicatorView alloc]init];
    self.aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.aiv.color = [UIColor grayColor];
    self.aiv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.aiv];
    
    // self.aiv.centerX = self.view.centerX
    NSLayoutConstraint *aivConstraintX = [NSLayoutConstraint constraintWithItem:self.aiv attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:aivConstraintX];
    // self.aiv.centerY = self.view.centerY
    NSLayoutConstraint *aivConstraintY = [NSLayoutConstraint constraintWithItem:self.aiv attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:aivConstraintY];
}

- (void) showAlertViewTitle:(NSString *)title Message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ESPUIAlertView *alertView = self.alertView;
        alertView.espTitle = title;
        alertView.espMessage = message;
        [alertView showTimeInterval:kEspUIAlertViewLongTimeInterval Instant:NO];
    });
}

- (void) startAivAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = NO;
        [self.aiv startAnimating];
    });
}

- (void) stopAivAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
        [self.aiv stopAnimating];
    });
}

-(void) tapTitlebarButtonLeft
{
    NSLog(@"tapTitlebarButtonLeft");
    ESPUser *user = [ESPUser sharedUser];
    [user logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) tapTitleBarButtonRight
{
    NSLog(@"tapTitleBarButtonRight");
}

-(void) tapToolbarAdd
{
    NSLog(@"tapToolbarAdd");
    ESPEsptouchViewController *vc = [[ESPEsptouchViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void) tapToolbarScene
{
    NSLog(@"tapToolbarScene");
}

-(void) tapToolbarEdit
{
    NSLog(@"toolbarEdit");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = [ESPUser sharedUser];
        self.deviceArray = [[NSMutableArray alloc]init];
        [self registerNotification];
    }
    return self;
}

- (void)dealloc {
    [self unregisterNotification];
}

- (void)registerNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(devicesArriveCallback) name:DEVICES_ARRIVE object:nil];
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)devicesArriveCallback
{
    @synchronized (self.deviceArray) {
        NSLog(@"devicesArriveCallback: %@",self.user.espDeviceArray);
        [self.deviceArray removeAllObjects];
        [self.deviceArray addObjectsFromArray:self.user.espDeviceArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)initMJRefresh
{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // set refreshingBlock callback
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    // go into refreshing state immediately
    [self.tableView.mj_header beginRefreshing];
}

- (void)doMJRefresh {
    [self.user doActionRefreshAllDevices:YES];
}

- (void)loadNewData
{
    NSLog(@"loadNewData");
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [weakSelf doMJRefresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            // after doMJResresh(), devicesArriveCallback will be called and the tableview will be refreshed
            
            // end refreshing state
            [self.tableView.mj_header endRefreshing];

        });
    });
}

#pragma mark - table view
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewInit];
    [self alertIndicatorViewInit];
    [self initMJRefresh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArray.count;
}

- (NSString *)tableViewCellTextLabelText:(ESPDevice *)device
{
    return device.espDeviceName;
}

- (NSString *)tableViewCellDetailTextLabelText:(ESPDevice *)device
{
    NSString *deviceState = device.espDeviceState.description;
    NSString *deviceVersion = device.espRomVersionCurrent;
    if (deviceVersion==nil) {
        deviceVersion = @"";
    }
    return [NSString stringWithFormat:@"%@ %@",deviceState,deviceVersion];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellReuseIdentifier];
    }
    
    ESPDevice *device = [self.deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [self tableViewCellTextLabelText:device];
    cell.detailTextLabel.text = [self tableViewCellDetailTextLabelText:device];

    // to support ios8.0
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [cell layoutSubviews];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select:%d",(int)indexPath.row);
    ESPDevice *device = [self.deviceArray objectAtIndex:indexPath.row];
    if (![device.espDeviceState isStateLocal] && ![device.espDeviceState isStateInternet]) {
#ifdef DEBUG
        NSLog(@"%@ %@ device state: %@ don't support select",[self class],NSStringFromSelector(_cmd),device.espDeviceState);
#endif
        return;
    }
    ESPDeviceLightViewController *lightViewController;
    ESPDevicePlugViewController *plugViewController;
    
    switch (device.espDeviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            lightViewController = [[ESPDeviceLightViewController alloc]init];
            lightViewController.deviceLight = (ESPDeviceLight *)device;
            [self presentViewController:lightViewController animated:YES completion:nil];
            break;
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            plugViewController = [[ESPDevicePlugViewController alloc]init];
            plugViewController.devicePlug = (ESPDevicePlug *)device;
            [self presentViewController:plugViewController animated:YES completion:nil];
            break;
        case PLUGS_ESP_DEVICETYPE:
            break;
        case REMOTE_ESP_DEVICETYPE:
            break;
        case ROOT_ESP_DEVICETYPE:
            break;
        case SOUNDBOX_ESP_DEVICETYPE:
            break;
        case VOLTAGE_ESP_DEVICETYPE:
            break;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@ %@",self.class,NSStringFromSelector(_cmd));
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // buttonIndex: cancel=0,confirm=1
    NSLog(@"input content:%@",[alertView textFieldAtIndex:0].text);
    if (buttonIndex==alertView.cancelButtonIndex) {
#ifdef DEBUG
        NSLog(@"%@ %@ cancel button is clicked",self.class,NSStringFromSelector(_cmd));
#endif
    } else if (buttonIndex==alertView.firstOtherButtonIndex) {
#ifdef DEBUG
        NSLog(@"%@ %@ confirm button is clicked",self.class,NSStringFromSelector(_cmd));
#endif
        // do rename action
        NSString *deviceName = [alertView textFieldAtIndex:0].text;
        ESPUser *user = [ESPUser sharedUser];
        [user doActionRenameDevice:self.deviceSelected DeviceName:deviceName Instantly:YES];
    }
}

-(void)doRenameAction:(ESPDevice *)device
{
    self.deviceSelected = device;
    NSString *title = @"Rename Device";
    NSString *message = [NSString stringWithFormat:@"%@",device.espDeviceName];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

-(void)doDeleteAction:(ESPDevice *)device
{
    ESPUser *user = [ESPUser sharedUser];
    [user doActionDeleteDevice:device Instantly:YES];
}

-(void)doActivateAction:(ESPDevice *)device
{
    [self startAivAnimating];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        ESPUser *user = [ESPUser sharedUser];
        // add activate state
        ESPDevice *copyDevice = [device copy];
        [copyDevice.espDeviceState clearState];
        [copyDevice.espDeviceState addStateActivating];
        [user addDeviceTransform:copyDevice];
        [user notifyDevicesArrive];
        // activate device
        BOOL isSuc = [user activateDeviceSync:device];
        // clear activate state
        copyDevice = [device copy];
        [copyDevice.espDeviceState clearStateActivating];
        [user addDeviceTransform:copyDevice];
        // refresh
        [user doActionRefreshDevices:YES];
        // show result
        NSString *title = device.espDeviceName;
        NSString *message = [NSString stringWithFormat:@"Activate %@",isSuc?@"SUC":@"FAIL"];
        [self showAlertViewTitle:title Message:message];
        
        [self stopAivAnimating];
    });
    
}

-(nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESPUser *user = [ESPUser sharedUser];
    
    __block ESPDevice *device = [self.deviceArray[indexPath.row] copy];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"Delete Action");
        // make table cell recover to normal pattern
        tableView.editing = NO;
        [self doDeleteAction:device];
    }];
    
    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Rename" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"Rename Action");
        // make table cell recover to normal pattern
        tableView.editing = NO;
        [self doRenameAction:device];
    }];
    
    UITableViewRowAction *activateAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Activate" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // make table cell recover to normal pattern
        tableView.editing = NO;
        [self doActivateAction:device];
    }];
    
    if (user.espIsLogined&&!device.isActivated&&device.espDeviceState.isStateLocal) {
        return @[deleteAction,renameAction,activateAction];
    } else {
        return @[deleteAction,renameAction];
    }
}

#pragma -mark menu
#define ESP_MENU_ID_SHARING     0
- (BOOL)addMenuItems:(AFXMenu *)menu {
    menu.afxParentViewController = self;
    menu.afxDelegate = self;
    AFXMenuItem *menuItem = [[AFXMenuItem alloc]init];
    menuItem.afxMenuItemId = ESP_MENU_ID_SHARING;
    menuItem.afxMenuItemTitle = @"Sharing";
    [menu addMenuItem:menuItem];
    return NO;
}
-(void)menuItemSelected:(AFXMenuItem*)menuItem {
    switch (ESP_MENU_ID_SHARING) {
        case ESP_MENU_ID_SHARING:
            NSLog(@"%@ %@ sharing",[self class],NSStringFromSelector(_cmd));
            break;
    }
}

@end
