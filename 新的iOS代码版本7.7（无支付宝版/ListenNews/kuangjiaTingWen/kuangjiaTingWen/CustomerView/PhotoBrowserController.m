//
//  PhotoBrowserController.m
//  zfbuser
//
//  Created by Eric Wang on 15/7/17.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "PhotoBrowserController.h"
#import "SDImageCache.h"

@interface PhotoBrowserController (){
    NSMutableArray *_selections;
    UISwipeGestureRecognizer * recognizer;
}

@property(nonatomic,strong) NSMutableArray *photos;//要浏览的同事圈 包含的图片里列表

@property (nonatomic, strong) NSMutableArray *thumbs;

@end


@implementation PhotoBrowserController

+ (instancetype)browserWithPhotos:(NSArray *)photos{
    PhotoBrowserController * vc =[[self alloc] init];
    vc.displayActionButton = YES;
    [vc openPhotos:photos];
    return vc;
}

- (id)init{
    self = [super init];
    if (self) {
        self.delegate = self;
        // Clear cache for testing
        //[[SDImageCache sharedImageCache] clearDisk];
        //[[SDImageCache sharedImageCache] clearMemory];
//        [self enableAutoBack];
    }
    return self;
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIButton *backImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [backImage setFrame:CGRectMake(0, 0, 44, 30)];
    backImage.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [backImage setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backImage addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backImage];
    self.navigationItem.leftBarButtonItem = backItem;
    [self enableAutoBack];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePhotoBrower) name:@"singleTapClosePhotoBrower" object:nil];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:recognizer];
}
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        RTLog(@"swipe down");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        RTLog(@"swipe up");
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        RTLog(@"swipe left");
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        RTLog(@"swipe right");
    }
}
- (void)closePhotoBrower
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = IOS_VERSION_GREATER_THAN(@"7") ? [UIColor whiteColor] : nil;
//    navBar.barTintColor = [UIColor whiteColor];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
//    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
//        navBar.barTintColor = nil;
//        navBar.shadowImage = nil;
//    }
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleDefault;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    }
}



#define URL(httpurl) [NSURL URLWithString:httpurl]

- (void)openPhotos:(NSArray *)phs{
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
//    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    self.photos = photos;
    // Photos
    for (id ph in phs) {
        if ([ph isKindOfClass:[NSURL class]]){
            NSURL * imgUrl = ph;
            photo = [MWPhoto photoWithURL:imgUrl];
            [photos addObject:photo];
        }
        else if([ph isKindOfClass:[NSString class]]){
            NSString *urlString = (NSString *)ph;
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *imgUrl = URL(urlString);
            
            if ([imgUrl isFileURL]){
                UIImage *ph = [UIImage imageWithContentsOfFile:[imgUrl relativePath]];
                photo = [MWPhoto photoWithImage:ph];
            }
            else{
                photo = [MWPhoto photoWithURL:imgUrl];
            }
            [photos addObject:photo];
        }
        else if([ph isKindOfClass:[UIImage class]]){
            photo = [MWPhoto photoWithImage:ph];
            [photos addObject:photo];
        }
    };
    // Options
    enableGrid = NO;
    
    // Create browser
    MWPhotoBrowser *browser = self;
    //    [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    };
}


#pragma mark - 图片浏览代理  MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didLoadPhotoAtIndex:(NSUInteger)index {
    
}
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"singleTapClosePhotoBrower" object:nil];
}
@end
