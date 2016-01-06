//
//  PostsDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "BmobRelation.h"
#import "DOPNavbarMenu.h"
#import "LogInViewController.h"
#import "PostsDetailContentCell.h"
#import "PostsDetailViewController.h"

@interface PostsDetailViewController () <UITableViewDelegate, UITableViewDataSource, DOPNavbarMenuDelegate> {
    
    NSInteger numberOfItemsInRow;
    DOPNavbarMenu *menu;
    CGFloat cell0Height;
    NSArray *commentsArray;
}

@end

@implementation PostsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBarButton];
    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.tableFooterView = [[UIView alloc] init];
    commentsArray = [NSArray array];
    [self createDetailView];
    [self createBottomBtnView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu) {
        [self.menu dismissWithAnimation:NO];
    }
}

- (void)createNavBarButton {
    numberOfItemsInRow = 3;
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Share selectedImageName:png_Btn_Share selector:@selector(openMenu:)];
}

- (DOPNavbarMenu *)menu {
    if (menu == nil) {
        DOPNavbarMenuItem *item1 = [DOPNavbarMenuItem ItemWithTitle:@"item" icon:[UIImage imageNamed:png_Btn_Share]];
        menu = [[DOPNavbarMenu alloc] initWithItems:@[item1,item1,item1,item1,item1,item1] width:self.view.dop_width maximumNumberInRow:numberOfItemsInRow];
        menu.backgroundColor = color_Blue;
        menu.separatarColor = [UIColor whiteColor];
        menu.delegate = self;
    }
    return menu;
}


- (void)openMenu:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu {
//    [self.navigationItem.rightBarButtonItem setTitle:@"dismiss"];
//    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
//    [self.navigationItem.rightBarButtonItem setTitle:@"menu"];
//    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you selected" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)createDetailView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *content = [self.posts objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setTextColor:color_333333];
        UIFont *font = font_Normal_16;
        [label setFont:font];
        [label setText:content];
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(12, yOffset, labelsize.width, labelsize.height);
        [self.scrollView addSubview:label];
        yOffset = labelsize.height + 20;
    }
    NSArray *imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    if (imgURLArray && imgURLArray.count > 0) {
        
        for (NSInteger i=0; i < imgURLArray.count; i++) {
            NSURL *URL = nil;
            if ([imgURLArray[i] isKindOfClass:[NSString class]]) {
                URL = [NSURL URLWithString:imgURLArray[i]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
                NSString *pathExtendsion = [URL.pathExtension lowercaseString];
                
                CGSize size = CGSizeZero;
                if ([pathExtendsion isEqualToString:@"png"]) {
                    size =  [CommonFunction getPNGImageSizeWithRequest:request];
                } else if([pathExtendsion isEqual:@"gif"]) {
                    size =  [CommonFunction getGIFImageSizeWithRequest:request];
                } else {
                    size = [CommonFunction getJPGImageSizeWithRequest:request];
                }
                if (CGSizeEqualToSize(CGSizeZero, size)) { // 如果获取文件头信息失败,发送异步请求请求原图
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        size = image.size;
                    }
                    CGFloat kWidth = WIDTH_FULL_SCREEN;
                    CGFloat kHeight = fabs(WIDTH_FULL_SCREEN * fabs(size.height) / fabs(size.width));

                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, kWidth, kHeight)];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.image = image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFit; //UIViewContentModeScaleToFill;
                    [self.scrollView addSubview:imageView];
                    yOffset += kHeight + 3;
                } else {
                    CGFloat kWidth = WIDTH_FULL_SCREEN;
                    CGFloat kHeight = fabs(WIDTH_FULL_SCREEN * fabs(size.height) / fabs(size.width));
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, kWidth, kHeight)];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFit;//UIViewContentModeScaleToFill;
                    [imageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:png_Bg_LaunchImage]];
                    [self.scrollView addSubview:imageView];
                    yOffset += kHeight + 3;
                }
            }
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(WIDTH_FULL_SCREEN, yOffset)];
}

- (void)createBottomBtnView {
    __weak typeof(self) weakSelf = self;
    [self getThreeSubViewForLeftBlock: ^{
        [weakSelf likeAction];
    } centerBlock:^{
        
    } rightBlock: ^{

    }];
    
    [self.bottomBtnView autoLayout];
    
    BOOL isLike = NO;
    if ([LogIn isLogin]) {
        isLike = [[self.posts objectForKey:@"isLike"] boolValue];
    }
    if (isLike) {
        self.bottomBtnView.leftButton.selected = YES;
        [self.bottomBtnView.leftButton setAllTitleColor:color_Red];
    }
    NSInteger likesCount = [[self.posts objectForKey:@"likesCount"] integerValue];
    [self.bottomBtnView.leftButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
}

- (void)getThreeSubViewForLeftBlock:(ButtonSelectBlock)leftBlock centerBlock:(ButtonSelectBlock)centerBlock rightBlock:(ButtonSelectBlock)rightBlock {
    
    [self.bottomBtnView setLeftButtonSelectBlock:leftBlock centerButtonSelectBlock:centerBlock rightButtonSelectBlock:rightBlock];
    
    self.bottomBtnView.backgroundColor = color_e9eff1;
    CGFloat btnWidth = WIDTH_FULL_SCREEN / 2 - 10;
    
    self.bottomBtnView.fixLeftWidth = btnWidth;
    self.bottomBtnView.fixCenterWidth = 10;
    self.bottomBtnView.fixRightWidth = btnWidth;
    
    [self.bottomBtnView.leftButton setImage:[UIImage imageNamed:png_Icon_Posts_Praise_Normal] forState:UIControlStateNormal];
    [self.bottomBtnView.leftButton setImage:[UIImage imageNamed:png_Icon_Posts_Praise_Selected] forState:UIControlStateSelected];
    
    [self.bottomBtnView.centerButton setAllTitle:@"|"];
    
    [self.bottomBtnView.rightButton setImage:[UIImage imageNamed:png_Icon_Posts_Comment] forState:UIControlStateNormal];
    [self.bottomBtnView.rightButton setImage:[UIImage imageNamed:png_Icon_Posts_Comment] forState:UIControlStateSelected];
    [self.bottomBtnView.rightButton setAllTitle:@"回复"];
    
    self.bottomBtnView.leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.bottomBtnView.centerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.bottomBtnView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.bottomBtnView.leftButton.titleLabel.font = font_Normal_13;
    self.bottomBtnView.centerButton.titleLabel.font = font_Normal_14;
    self.bottomBtnView.rightButton.titleLabel.font = font_Normal_14;
    self.bottomBtnView.leftButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomBtnView.leftButton setAllTitleColor:color_8f8f8f];
    [self.bottomBtnView.centerButton setAllTitleColor:color_8f8f8f];
    [self.bottomBtnView.rightButton setAllTitleColor:color_8f8f8f];
}

- (void)getCommets {
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
//    [bquery includeKey:@"author"];
//    [bquery whereKey:@"objectId" equalTo:self.posts.objectId];
////    __weak typeof(self) weakSelf = self;
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        
//        if (!error && array.count == 1) {
//            
//        }
//    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (commentsArray.count > 0) {
        return commentsArray.count + 1;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BmobObject *author = [self.posts objectForKey:@"author"];
    NSString *nickName = [author objectForKey:@"nickName"];
    if (!nickName || nickName.length == 0) {
        nickName = @"匿名者";
    }
    NSString *avatarURL = [author objectForKey:@"avatarURL"];
//    NSString *content = [self.posts objectForKey:@"content"];
//    NSString *isTop = [self.posts objectForKey:@"isTop"];
//    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
//    NSArray *imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 50)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [color_dedede CGColor];
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 40, 40)];
    avatarView.layer.cornerRadius = 20;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:avatarView];
    //昵称
    UILabel *labelNickName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, WIDTH_FULL_SCREEN / 2, 30)];
    labelNickName.textColor = color_Blue;
    labelNickName.font = font_Normal_16;
    labelNickName.text = nickName;
    [view addSubview:labelNickName];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(57, 30, WIDTH_FULL_SCREEN / 2, 20)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_13;
    labelDate.text = [CommonFunction intervalSinceNow:self.posts.createdAt];
    [view addSubview:labelDate];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (cell0Height > 0) {
            return cell0Height;
        } else {
            cell0Height = [self cellHeight:self.posts];
            return cell0Height;
        }
    } else {
        if (commentsArray.count > 0) {
            return 168.f;
        } else {
            return 168.f;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PostsDetailContentCell *cell = [PostsDetailContentCell cellView:self.posts];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        if (commentsArray.count > 0) {
            
        } else {
            static NSString *noCommentCellIdentifier = @"noCommentCellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noCommentCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noCommentCellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"";
                cell.textLabel.frame = cell.contentView.bounds;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.font = font_Bold_16;
                cell.textLabel.text = @"暂无评论";
            }
            return cell;
        }
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)cellHeight:(BmobObject *)obj {
    NSString *content = [obj objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UIFont *font = font_Normal_16;
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        yOffset = labelsize.height + 20;
    }
    NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
    if (imgURLArray && imgURLArray.count > 0) {
        
        for (NSInteger i=0; i < imgURLArray.count; i++) {
            NSURL *URL = nil;
            if ([imgURLArray[i] isKindOfClass:[NSString class]]) {
                URL = [NSURL URLWithString:imgURLArray[i]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
                NSString *pathExtendsion = [URL.pathExtension lowercaseString];
                
                CGSize size = CGSizeZero;
                if ([pathExtendsion isEqualToString:@"png"]) {
                    size =  [CommonFunction getPNGImageSizeWithRequest:request];
                } else if([pathExtendsion isEqual:@"gif"]) {
                    size =  [CommonFunction getGIFImageSizeWithRequest:request];
                } else {
                    size = [CommonFunction getJPGImageSizeWithRequest:request];
                }
                if (CGSizeEqualToSize(CGSizeZero, size)) { // 如果获取文件头信息失败,发送异步请求请求原图
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        size = image.size;
                    }
                }
                CGFloat kWidth = fabs(size.width);
                CGFloat kHeight = fabs(size.height);
                if (kWidth > WIDTH_FULL_SCREEN) {
                    kHeight = WIDTH_FULL_SCREEN * size.height / size.width;
                }
                yOffset += kHeight + 10;
            }
        }
    }
    return fabs(yOffset);
}

- (void)likeAction {
    if ([LogIn isLogin]) {
        self.bottomBtnView.leftButton.selected = !self.bottomBtnView.leftButton.selected;
        if (self.bottomBtnView.leftButton.selected) {
            [self likePosts:self.posts];
            NSInteger likesCount = [[self.posts objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [self.bottomBtnView.leftButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
            [self.bottomBtnView.leftButton setAllTitleColor:color_Red];
        } else {
            [self unlikePosts:self.posts];
            NSInteger likesCount = [[self.posts objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [self.bottomBtnView.leftButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
            [self.bottomBtnView.leftButton setAllTitleColor:color_8f8f8f];
        }
    } else {
        [self toLogInView];
    }
}

- (void)likePosts:(BmobObject *)posts {
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    [obj incrementKey:@"likesCount"];
    
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(YES) forKey:@"isLike"];
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)unlikePosts:(BmobObject *)posts {
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    [obj decrementKey:@"likesCount"];
    
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(NO) forKey:@"isLike"];
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)toLogInView {
    LogInViewController *controller = [[LogInViewController alloc] init];
//    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
