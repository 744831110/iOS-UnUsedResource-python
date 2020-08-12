//
//  ASStudyRoomUserInfoViewController.m
//  ASStudyRoom
//
//  Created by 陈谦 on 2020/7/4.
//

#import "ASStudyRoomUserInfoViewController.h"
#import "ASStudyRoomMicEvent.h"
#import "ASStudyRoomUserInfoViewModel.h"
#import "ASStudyRoomBaseUserInfoAndRelModel.h"
#import "ASStudyRoomAlertView.h"
#import "ASUIConfig.h"
#import "ASUITips.h"
#import "ASLocalized.h"
#import "ASStudyRoomStatistics.h"
#import "Masonry.h"
ASBeginIgnoreNotCodeAllWarings
#import <ReactiveObjC.h>
#import <ATHContext/ATHContext.h>
#import "IASLiveRoomProtocol.h"
ASEndIgnoreNotCodeAllWarings
#import "SDWebImage.h"
#import "ASUserModel.h"
#import "IASUserInfoService.h"
#import "IASUserService.h"
#import "IASStatisticsService.h"
#import <ATHRouter/ATHRouter.h>
#import <ASUIComponent/ASUIComponent.h>

@interface ASStudyRoomUserInfoViewController () <QMUIModalPresentationContentViewControllerProtocol>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *bearingRightLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *partnerButton;
@property (nonatomic, strong) QMUIButton *micButton;
@property (nonatomic, strong) QMUIButton *offlineButton;
@property (nonatomic, strong) QMUIButton *adminPriorityButton;

@property (nonatomic, strong) ASStudyRoomUserInfoViewModel *viewModel;

@end

@implementation ASStudyRoomUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel = [[ASStudyRoomUserInfoViewModel alloc]init];
    [self setupSubview];
    [self bindViewModel];
    if (self.seatIndex != -1) {
        MFLogInfo(@"ASStudyRoomViewController", @"click seatIndex error uid %@ index %lu", self.uid, (unsigned long)self.seatIndex);
        if (self.style != ASStudyRoomUserInfoViewStyleAnchorClickOther) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bindMicButton:seatIndex:)]) {
                [self.delegate bindMicButton:self.micButton seatIndex:self.seatIndex];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bindManagerMuteMicButton:seatIndex:)]) {
                [self.delegate bindManagerMuteMicButton:self.micButton seatIndex:self.seatIndex];
            }
        }
    }
    [self.viewModel.userInfoCommand execute:@{
        @"uid" : self.uid
    }];
}

#pragma mark - private
- (void)setupSubview
{
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(280);
        make.height.mas_equalTo(345);
    }];
    
    [self.contentView addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(22);
        make.top.mas_equalTo(self.contentView).mas_offset(27);
        make.width.height.mas_equalTo(15);
    }];
    
    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).mas_offset(58);
        make.width.height.mas_equalTo(70);
    }];
    
    [self.contentView addSubview:self.nickNameLabel];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.avatarImageView.mas_bottom).mas_offset(6);
        make.left.mas_equalTo(self.contentView.mas_left).mas_offset(30);
    }];
    
    if (self.style == ASStudyRoomUserInfoViewStyleClickSelf) {
        [self.contentView addSubview:self.bearingRightLabel];
        [self.bearingRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.nickNameLabel.mas_bottom).mas_offset(11);
        }];
    }

    if (self.style != ASStudyRoomUserInfoViewStyleClickSelf) {
        [self.contentView addSubview:self.moreButton];
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).mas_offset(-22);
            make.top.mas_equalTo(self.contentView).mas_offset(27);
            make.width.height.mas_equalTo(15);
        }];

        [self.contentView addSubview:self.followButton];
        [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView).mas_offset(-54);
            make.top.mas_equalTo(self.nickNameLabel.mas_bottom).mas_offset(27);
            make.width.mas_equalTo(67);
            make.height.mas_equalTo(24);
        }];

        [self.contentView addSubview:self.partnerButton];
        [self.partnerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView).mas_offset(54);
            make.top.mas_equalTo(self.followButton);
            make.width.height.mas_equalTo(self.followButton);
        }];
    }

    UIStackView *stackView = [[UIStackView alloc]init];
    [stackView setDistribution:UIStackViewDistributionEqualCentering];
    [stackView setAxis:UILayoutConstraintAxisHorizontal];
    [stackView setAlignment:UIStackViewAlignmentTop];
//    [stackView setSpacing:30];
    if (self.style == ASStudyRoomUserInfoViewStyleAnchorClickOther) {
        [stackView addArrangedSubview:self.micButton];
        [stackView addArrangedSubview:self.offlineButton];
        [stackView addArrangedSubview:self.adminPriorityButton];
    } else {
        [stackView addArrangedSubview:self.micButton];
    }
    [self.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset((self.style == ASStudyRoomUserInfoViewStyleAnchorClickOther) ? 43 : 120);
        make.right.mas_equalTo(self.contentView).mas_offset((self.style == ASStudyRoomUserInfoViewStyleAnchorClickOther) ? -22 : -120);
        make.top.mas_equalTo(self.nickNameLabel.mas_bottom).mas_offset(95);
        make.height.mas_equalTo(65);
    }];

}

- (void)bindViewModel
{
    @weakify(self)
    [[[self.viewModel.userInfoCommand executionSignals] switchToLatest] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [ASUITips hideAllTips];
        MFLogInfo(@"ASStudyRoomUserInfoViewController", @"user info command %@", x);
        [self.moreButton setHidden:NO];
        ASStudyRoomBaseUserInfoAndRelModel *model = (ASStudyRoomBaseUserInfoAndRelModel *)x;
        if (model.userInfo.avatar && ![model.userInfo.avatar isEqualToString:@""]) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.userInfo.avatar] placeholderImage:[UIImage as_imageNamed:@"icon_study_room_default_avatar"]];
        }
        [self.nickNameLabel setText:model.userInfo.nickname];
        [self setFollowButtonStyleWithStatu:model.followStatus];
        [self setPartnerButtonStyleWithStatu:model.partnerStatus];
        [self.moreButton setHidden:NO];
        [self.followButton setHidden:NO];
        [self.partnerButton setHidden:NO];
    }];
    [[self.viewModel.userInfoCommand errors] subscribeNext:^(NSError * _Nullable x) {
        [ASUITips hideAllTips];
        [ASUITips showWithText:x.as_errorMsg inView:self.view];
    }];
    
    [[[self.viewModel.followCommand executionSignals] switchToLatest] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [ASUITips hideAllTips];
        NSNumber *value = x;
        [self setFollowButtonStyleWithStatu:value.integerValue];
    }];
    [[self.viewModel.followCommand errors] subscribeNext:^(NSError * _Nullable x) {
        [ASUITips hideAllTips];
        [ASUITips showWithText:x.as_errorMsg inView:self.view];
    }];
    
    [[[self.viewModel.partnerCommand executionSignals] switchToLatest] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [ASUITips hideAllTips];
        NSNumber *value = x;
        [self setPartnerButtonStyleWithStatu:value.integerValue];
        [ASUITips showWithText:value.integerValue == ASUSUserPartnerShipStatusParter || value.integerValue == ASUSUserPartnerShipStatusApply ? ASLocalizedString(@"study_room_user_info_invite_partner_success", nil) : ASLocalizedString(@"study_room_user_info_break_partner_success", nil) inView:self.view];
    }];
    [[self.viewModel.partnerCommand errors] subscribeNext:^(NSError * _Nullable x) {
        [ASUITips hideAllTips];
        [ASUITips showWithText:x.as_errorMsg inView:self.view];
    }];
}

- (void)setFollowButtonStyleWithStatu:(ASUSUserRelationShip)relationShip
{
    NSString *followString;
    switch (relationShip) {
        case ASUSUserRelationShipNone:
            followString = [NSString stringWithFormat:@"+%@", ASLocalizedString(@"userpage_userinfo_follow", nil)];
            @"asuser_icon_dui"
            @"icon_study_room_control_mic_open"
            break;
        case ASUSUserRelationShipFollow:
            followString = ASLocalizedString(@"userpage_userinfo_following", nil);
            break;
        case ASUSUserRelationShipFirend:
            followString = ASLocalizedString(@"userpage_userinfo_firends", nil);
            break;
        default:
            break;
    }
    [self.followButton setTitle:followString forState:UIControlStateNormal];
    if (relationShip == ASUSUserRelationShipNone) {
        [self.followButton setBackgroundColor:UIColor.as_orangeColor];
        [self.followButton setTitleColor:UIColor.as_whiteColor forState:UIControlStateNormal];
        [self.followButton.layer setBorderWidth:0];
    } else {
        [self.followButton setBackgroundColor:UIColor.as_whiteColor];
        [self.followButton setTitleColor:[UIColor as_orangeColor] forState:UIControlStateNormal];
        [self.followButton.layer setBorderWidth:1];
        [self.followButton.layer setBorderColor:[UIColor as_orangeColor].CGColor];
    }
}

- (void)setPartnerButtonStyleWithStatu:(ASUSUserPartnerShipStatus)partnerShipStatu
{
    NSString *partnerString;
    switch (partnerShipStatu) {
        case ASUSUserPartnerShipStatusNoShip:
        case ASUSUserPartnerShipStatusRefuse:
            partnerString = [NSString stringWithFormat:@"+ %@", ASLocalizedString(@"study_room_user_info_partner", nil)];
            [self.partnerButton setBackgroundColor:UIColor.as_orangeColor];
            [self.partnerButton setTitleColor:UIColor.as_whiteColor forState:UIControlStateNormal];
            [self.partnerButton.layer setBorderWidth:0];
            break;
        case ASUSUserPartnerShipStatusApply:
            partnerString = ASLocalizedString(@"userpage_userinfo_Inviting", nil);
            [self.partnerButton setBackgroundColor: UIColor.as_whiteColor];
            [self.partnerButton setTitleColor:[UIColor as_grayColor] forState:UIControlStateNormal];
            [self.partnerButton.layer setBorderColor:[UIColor as_grayColor].CGColor];
            [self.partnerButton.layer setBorderWidth:1];
            break;
        case ASUSUserPartnerShipStatusParter:
            partnerString = ASLocalizedString(@"userpage_userinfo_Break", nil);
            [self.partnerButton setBackgroundColor: UIColor.as_whiteColor];
            [self.partnerButton setTitleColor:[UIColor as_orangeColor] forState:UIControlStateNormal];
            [self.partnerButton.layer setBorderColor:[UIColor as_orangeColor].CGColor];
            [self.partnerButton.layer setBorderWidth:1];
            break;
        default:
            break;
    }
    [self.partnerButton setTitle:partnerString forState:UIControlStateNormal];
}

- (void)showBlockAlertView:(BOOL)isBlock
{
    NSString *title = isBlock ? ASLocalizedString(@"userpage_alter_Areyousuretoblockthisuser", nil) : ASLocalizedString(@"userpage_alter_Areyousuretounblockthisuser", nil);
    NSString *actionTitle = isBlock ? ASLocalizedString(@"study_room_action_sheet_block", nil) : ASLocalizedString(@"study_room_action_sheet_unBlock", nil);
    ASUIAlertAction *confimAction = [ASUIAlertAction actionWithTitle:actionTitle style:ASUIAlertActionStyleDefault handler:^(ASUIAlertController *aAlertController, ASUIAlertAction *action) {
        [ASUITips showLoadingInView:self.view];
        [self.viewModel blockUser:isBlock uid:self.uid sid:[ATH_EXECUTOR(IASLiveRoomProtocol) liveRoom].roomId completion:^(BOOL isSuccess, NSError * _Nullable error) {
            if (isSuccess) {
                [ASUITips showWithText:isBlock ? ASLocalizedString(@"study_room_user_info_block_user_success", nil) : ASLocalizedString(@"study_room_user_info_unblock_user_success", nil) inView:self.view];
            } else {
                [ASUITips hideAllTips];
                [ASUITips showError:error.as_errorMsg inView:self.view];
            }
        }];
    }];
    ASUIAlertController *alertController = [ASUIAlertController alertControllerWithTitle:title message:nil preferredStyle:ASUIAlertControllerStyleAlert];
    [alertController addAction:confimAction];
    [alertController addAction:[ASUIAlertAction actionWithTitle:ASLocalizedString(@"study_room_action_sheet_cancel", nil) style:ASUIAlertActionStyleDefault handler:^(__kindof ASUIAlertController * _Nonnull aAlertController, ASUIAlertAction * _Nonnull action) {
        [aAlertController hideWithAnimated:YES];
    }]];
    [alertController showWithAnimated:YES];
}

- (void)showWithAnimated:(BOOL)animated
{
    QMUIModalPresentationViewController *modalViewController = [[QMUIModalPresentationViewController alloc] init];
    modalViewController.contentViewController = self;
    modalViewController.contentViewMargins = UIEdgeInsetsZero;
    modalViewController.modal = YES;
    modalViewController.animationStyle = QMUIModalPresentationAnimationStylePopup;
    [modalViewController showWithAnimated:animated completion:nil];
}

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller keyboardHeight:(CGFloat)keyboardHeight limitSize:(CGSize)limitSize
{
    return CGSizeMake(ASWidth(280), ASHeight(345));
}

#pragma mark - action
- (void)closeButtonAction:(UIButton *)sender
{
    [self.qmui_modalPresentationViewController hideWithAnimated:YES completion:nil];
}

- (void)moreButtonAction:(UIButton *)sender
{
    ASUIAlertAction *reportAction = [ASUIAlertAction actionWithTitle:ASLocalizedString(@"study_room_action_sheet_report", nil) style:ASUIAlertActionStyleDefault handler:^(ASUIAlertController *aAlertController, ASUIAlertAction *action) {
        [ASUITips showLoadingInView:[UIApplication sharedApplication].keyWindow];
        [self.viewModel reportUser:self.uid completion:^(BOOL isSuccess, NSError * _Nullable error) {
            if (isSuccess) {
                [ASUITips hideAllTips];
                [ASUITips showWithText:ASLocalizedString(@"study_room_report_success", nil) inView:self.view];
            } else {
                [ASUITips hideAllTips];
                [ASUITips showWithText:error.as_errorMsg inView:self.view];
            }
        }];
    }];
//    study_room_action_sheet_unBlock
    NSString *blockActionTitle = self.viewModel.blackListStatu == ASUSUserBlackListStatusOutBlack ? @"study_room_action_sheet_block" : @"study_room_action_sheet_unBlock";
    ASUIAlertAction *blockAction = [ASUIAlertAction actionWithTitle:ASLocalizedString(blockActionTitle, nil) style:ASUIAlertActionStyleDefault handler:^(ASUIAlertController *aAlertController, ASUIAlertAction *action) {
        BOOL isBlock = self.viewModel.blackListStatu == ASUSUserBlackListStatusOutBlack;
        [aAlertController dismissViewControllerAnimated:YES completion:^{
            [self showBlockAlertView:isBlock];
        }];
    }];
    ASUIAlertController *alertController = [ASUIAlertController alertControllerWithTitle:nil message:nil preferredStyle:ASUIAlertControllerStyleActionSheet];
    [alertController addAction:reportAction];
    [alertController addAction:blockAction];
    [alertController addAction:[ASUIAlertAction actionWithTitle:ASLocalizedString(@"Cancel", nil) style:(ASUIAlertActionStyleCancel) handler:nil]];
    [alertController showWithAnimated:YES];
}

- (void)followButtonAction:(UIButton *)sender
{
    [ASUITips showLoadingInView:self.view];
    [self.viewModel.followCommand execute:@{
        @"uid" : self.uid
    }];
}

- (void)partnerButtonAction:(UIButton *)sender
{
    if (self.viewModel.partnerShipStatu == ASUSUserPartnerShipStatusApply) {
        return;
    }
    [ASUITips showLoadingInView:self.view];
    [self.viewModel.partnerCommand execute:@{
        @"uid" : self.uid
    }];
}

- (void)micButtonAction:(UIButton *)sender
{
    // 如果是manager静音则调接口
    if (self.style == ASStudyRoomUserInfoViewStyleAnchorClickOther) {
        ASStudyRoomManagerMuteButtonClickEvent *event = [[ASStudyRoomManagerMuteButtonClickEvent alloc]init];
        event.uid = self.uid;
        event.isForbid = sender.isSelected;
        event.seatIndex = self.seatIndex;
        event.source = ASStudyRoomMicEventSourceUserInfoPop;
        ATHDispatchEvent(KASStudyRoomManagerMuteButtonClickEvent, (event));
    } else {
    // 如果是普通的mic事件则发送event
//        BOOL isSelect = sender.isSelected;
        ASStudyRoomLocalMuteButtonClickEvent *event = [[ASStudyRoomLocalMuteButtonClickEvent alloc]init];
        event.seatIndex = self.seatIndex;
        event.source = ASStudyRoomMicEventSourceUserInfoPop;
        ATHDispatchEvent(kASStudyRoomLocalMuteButtonClickEvent, (event));
    }
}

- (void)offlineButtonAction:(UIButton *)sender
{
    [ATH_SERVICE(IASStatisticsService) sendEventWithCidParam:kASStudyRoom_KickOut_CidParam];
    [ASUITips showLoadingInView:self.view];
    // 踢下麦
    [self.viewModel closeUserLive:self.uid completion:^(BOOL isSuccess, NSError * _Nullable error) {
        MFLogInfo(@"ASStudyRoomUserInfoViewController", @"close user live %d error %@",isSuccess, error);
        if (error) {
            [ASUITips showWithText:error.as_errorMsg inView:self.view];
        } else {
            [ASUITips hideAllTips];
        }
    }];
}

- (void)adminPriorityButtonAction:(UIButton *)sender
{
    [ATH_SERVICE(IASStatisticsService) sendEventWithCidParam:kASStudyRoom_TransferAdmin_CidParam];
    //权限转移弹窗
    //退出当前userInfoiew
    // 权限转移
    [self.qmui_modalPresentationViewController hideWithAnimated:YES completion:^(BOOL finished) {
        if (finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showTransferAdminAlertViewWithTargetUid:)]) {
                [self.delegate showTransferAdminAlertViewWithTargetUid:self.uid];
            }
        }
    }];
}

- (void)avatarImageViewAction:(UITapGestureRecognizer *)gesture
{
    [self.qmui_modalPresentationViewController hideWithAnimated:YES completion:^(BOOL finished) {
        [ATHURIRouter.sharedInstance openURI:[NSString stringWithFormat:@"userpage?uid=%@",self.uid]];
    }];
}

#pragma mark - getter & setter
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        [_contentView setBackgroundColor:QMUICMI.whiteColor];
        [_contentView.layer setMasksToBounds:YES];
        [_contentView.layer setCornerRadius:10];
    }
    return _contentView;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]init];
        [_closeButton setBackgroundImage:[UIImage as_imageNamed:@"icon_study_room_user_info_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setQmui_outsideEdge:UIEdgeInsetsMake(-8, -8, -8, -8)];
    }
    return _closeButton;
}

- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [[UIButton alloc]init];
        [_moreButton setBackgroundImage:[UIImage as_imageNamed:@"icon_study_room_user_info_more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton setHidden:YES];
        [_moreButton setQmui_outsideEdge:UIEdgeInsetsMake(-8, -8, -8, -8)];
    }
    return _moreButton;
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.avatar] placeholderImage:[UIImage as_imageNamed:@"icon_study_room_default_avatar"]];
        [_avatarImageView.layer setCornerRadius:35];
        [_avatarImageView.layer setMasksToBounds:YES];
        [_avatarImageView setUserInteractionEnabled:YES];
        [_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarImageViewAction:)]];
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        [_nickNameLabel setTextColor:UIColor.as_alertViewTextColor];
        [_nickNameLabel setFont:ASUIBoldFontMake(17)];
        [_nickNameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nickNameLabel setText:self.nickName];
    }
    return _nickNameLabel;
}

- (UILabel *)bearingRightLabel
{
    if (!_bearingRightLabel) {
        _bearingRightLabel = [[UILabel alloc]init];
        [_bearingRightLabel setTextColor:UIColor.as_alertViewTextColor];
        [_bearingRightLabel setTextAlignment:NSTextAlignmentCenter];
        [_bearingRightLabel setFont:ASUIFontMake(13)];
        [_bearingRightLabel setText:@"Persistence is success"];
    }
    return _bearingRightLabel;
}

- (UIButton *)followButton
{
    if (!_followButton) {
        _followButton = [[UIButton alloc]init];
        [_followButton setBackgroundColor:UIColor.as_orangeColor];
        [_followButton setTitleColor:UIColor.as_whiteColor forState:UIControlStateNormal];
        [_followButton.titleLabel setFont:ASUIFontMake(13)];
        [_followButton setTitle:[NSString stringWithFormat:@"+ %@", ASLocalizedString(@"study_room_user_info_follow", nil)] forState:UIControlStateNormal];
        [_followButton.layer setMasksToBounds:YES];
        [_followButton.layer setCornerRadius:12];
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_followButton setHidden:YES];
    }
    return _followButton;
}

- (UIButton *)partnerButton
{
    if (!_partnerButton) {
        _partnerButton = [[UIButton alloc]init];
        [_partnerButton setBackgroundColor:UIColor.as_orangeColor];
        [_partnerButton setTitleColor:UIColor.as_whiteColor forState:UIControlStateNormal];
        [_partnerButton.titleLabel setFont:ASUIFontMake(13)];
        [_partnerButton setTitle:[NSString stringWithFormat:@"+ %@", ASLocalizedString(@"study_room_user_info_partner", nil)] forState:UIControlStateNormal];
        [_partnerButton.layer setMasksToBounds:YES];
        [_partnerButton.layer setCornerRadius:12];
        [_partnerButton addTarget:self action:@selector(partnerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_partnerButton setHidden:YES];
    }
    return _partnerButton;
}

- (QMUIButton *)micButton
{
    if (!_micButton) {
        _micButton = [[QMUIButton alloc]init];
        [_micButton setImage:[UIImage as_imageNamed:@"icon_study_room_user_info_mic_close"] forState:UIControlStateNormal];
        [_micButton setImage:[UIImage as_imageNamed:@"icon_study_room_user_info_mic_open"] forState:UIControlStateSelected];
        [_micButton setImagePosition:QMUIButtonImagePositionTop];
        [_micButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        [_micButton setTitleColor:UIColor.as_alertViewTextColor forState:UIControlStateNormal];
        [_micButton.titleLabel setFont:ASUIFontMake(13)];
        [_micButton setTitle:ASLocalizedString(@"study_room_user_info_mute", nil) forState:UIControlStateNormal];
        [_micButton addTarget:self action:@selector(micButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micButton;
}

- (QMUIButton *)offlineButton
{
    if (!_offlineButton) {
        _offlineButton = [[QMUIButton alloc]init];
        [_offlineButton setImage:[UIImage as_imageNamed:@"icon_study_room_user_info_kick_out"] forState:UIControlStateNormal];
        [_offlineButton setImagePosition:QMUIButtonImagePositionTop];
        [_offlineButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        [_offlineButton setTitleColor:UIColor.as_alertViewTextColor forState:UIControlStateNormal];
        [_offlineButton.titleLabel setFont:ASUIFontMake(13)];
        [_offlineButton setTitle:ASLocalizedString(@"study_room_user_info_offline", nil) forState:UIControlStateNormal];
        [_offlineButton addTarget:self action:@selector(offlineButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _offlineButton;
}

- (QMUIButton *)adminPriorityButton
{
    if (!_adminPriorityButton) {
        _adminPriorityButton = [[QMUIButton alloc]init];
        [_adminPriorityButton setImage:[UIImage as_imageNamed:@"icon_study_room_user_info_admin_priority"] forState:UIControlStateNormal];
        [_adminPriorityButton setImagePosition:QMUIButtonImagePositionTop];
        [_adminPriorityButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        [_adminPriorityButton setTitleColor:UIColor.as_alertViewTextColor forState:UIControlStateNormal];
        [_adminPriorityButton.titleLabel setFont:ASUIFontMake(13)];
        [_adminPriorityButton.titleLabel setNumberOfLines:2];
        [_adminPriorityButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_adminPriorityButton setTitle:ASLocalizedString(@"study_room_user_info_transfer_admin", nil) forState:UIControlStateNormal];
        [_adminPriorityButton addTarget:self action:@selector(adminPriorityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminPriorityButton;
}

@end
