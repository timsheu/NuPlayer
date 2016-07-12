//
//  StartPageViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/25.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "StartPageViewController.h"

@implementation StartPageViewController 
-(void)viewDidLoad{
    [super viewDidLoad];
    [[self navigationController]setNavigationBarHidden:YES animated:NO];
    _pageTitles = @[@"Select Platform!", @"Select Camera!", @"Start Streaming!", @"Play Files!", @"Do Settings!"];
    _pageImages = @[@"platform.jpg", @"select.jpg", @"streaming.jpg", @"files.jpg", @"settings.jpg"];
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSString *didTutorial = [manager.dictionarySetting objectForKey:@"DidTutorial"];
    if ([didTutorial isEqualToString:@"NO"]) {
        [self showTutorial:self];
        [manager.dictionarySetting setObject:@"YES" forKey:@"DidTutorial"];
        [manager updateSettingPropertyList];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[self navigationController]setNavigationBarHidden:YES animated:YES];
//    [_skyEyeButton setEnabled:NO];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    TrailerContentViewController *controller = (TrailerContentViewController *)viewController;
    NSUInteger index = controller.pageIndex;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    TrailerContentViewController *controller = (TrailerContentViewController *)viewController;
    NSUInteger index = controller.pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == 5) {
        [controller.dismissButtonOutlet setHidden:NO];
        controller.delegate = self;
    }
    if (index == _pageTitles.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (TrailerContentViewController *) viewControllerAtIndex: (NSUInteger) index{
    if ((_pageTitles.count == 0) || (index >= _pageTitles.count)) {
        return nil;
    }
    TrailerContentViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrailerContentViewController"];
    
    viewController.imageFile = _pageImages[index];
    viewController.titleText = _pageTitles[index];
    viewController.pageIndex = index;
    return viewController;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return _pageTitles.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}

- (void)removeTrailer{
    [_pageViewController.view removeFromSuperview];
    [_pageViewController removeFromParentViewController];
}

- (IBAction)showTutorial:(id)sender {
    _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrailerViewController"];
    _pageViewController.dataSource = self;
    
    TrailerContentViewController *staringViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[staringViewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
}

@end
