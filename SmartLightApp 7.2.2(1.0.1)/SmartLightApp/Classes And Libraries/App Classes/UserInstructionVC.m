//
//  UserInstructionVC.m
//  SmartLightApp
//
//  Created by Vithamas Technologies on 23/03/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "UserInstructionVC.h"
#import "LoginVC.h"


@interface UserInstructionVC ()
{
    UIView *viewForLogin ,*viewForGuest;
}
@end

@implementation UserInstructionVC

- (void)viewDidLoad
{
    self.view.backgroundColor = global_brown_color;
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    self.view.backgroundColor = [UIColor colorWithRed:19/255.0 green:24/255.0 blue:27/255.0 alpha:1.0];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.5;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Vithamas"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSizes+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
//    [viewHeader addSubview:lblTitle];
    
    viewForLogin = [[UIView alloc] initWithFrame:CGRectMake(15,50,DEVICE_WIDTH-30,DEVICE_HEIGHT/2-50)];
    [viewForLogin setBackgroundColor:[UIColor clearColor]];
    viewForLogin.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewForLogin.layer.shadowOffset = CGSizeMake(0.1, 0.1);
    viewForLogin.layer.shadowRadius = 25;
    viewForLogin.layer.shadowOpacity = 0.5;
    [self.view addSubview:viewForLogin];
    
    
    UIImageView * imgPopUpBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewForLogin.frame.size.width, DEVICE_HEIGHT-100)];
    [imgPopUpBG setBackgroundColor:[UIColor blackColor]];
    imgPopUpBG.alpha = 0.5;
    imgPopUpBG.layer.cornerRadius = 10;
    [viewForLogin addSubview:imgPopUpBG];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgPopUpBG.bounds];
    imgPopUpBG.layer.masksToBounds = NO;
    imgPopUpBG.layer.shadowColor = [UIColor whiteColor].CGColor;
    imgPopUpBG.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imgPopUpBG.layer.shadowOpacity = 0.5f;
    imgPopUpBG.layer.shadowPath = shadowPath.CGPath;
    [viewForLogin addSubview:imgPopUpBG];

    UILabel * lblSecureLogin = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewForLogin.frame.size.width, 50)];
    [lblSecureLogin setBackgroundColor:[UIColor clearColor]];
    [lblSecureLogin setText:@"Secure login"];
    [lblSecureLogin setTextAlignment:NSTextAlignmentCenter];
    [lblSecureLogin setFont:[UIFont fontWithName:CGBold size:textSizes+7]];
    [lblSecureLogin setTextColor:[UIColor whiteColor]];
    [viewForLogin addSubview:lblSecureLogin];
    
    UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, viewForLogin.frame.size.width-20, 100)];
    [lblMessage setBackgroundColor:[UIColor clearColor]];
    [lblMessage setText:@"If you want to secure your device in your phone Please \"Login\" , or Use as guest user."];
    [lblMessage setTextAlignment:NSTextAlignmentCenter];
    [lblMessage setFont:[UIFont fontWithName:CGRegularItalic size:textSizes+2]];
    [lblMessage setTextColor:[UIColor whiteColor]];
    lblMessage.numberOfLines = 6;
    [viewForLogin addSubview:lblMessage];
    
    UIButton *  btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setFrame:CGRectMake(15, lblMessage.frame.size.height+50, viewForLogin.frame.size.width-30, 44)];
    [btnLogin setTitle:@"Click here to Login" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLogin.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnLogin addTarget:self action:@selector(btnLoginClick) forControlEvents:UIControlEventTouchUpInside];
    btnLogin.backgroundColor = global_brown_color;
    btnLogin.layer.cornerRadius = 10;
    [viewForLogin addSubview:btnLogin];
    
    UIView * viewForGuest = [[UIView alloc] initWithFrame:CGRectMake(15,DEVICE_HEIGHT/2,DEVICE_WIDTH-30,viewForLogin.frame.size.height)];
    [viewForGuest setBackgroundColor:[UIColor clearColor]];
    viewForGuest.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewForGuest.layer.shadowOffset = CGSizeMake(0.1, 0.1);
//    viewForGuest.layer.shadowRadius = 25;
    viewForGuest.layer.shadowOpacity = 0.5;
    [self.view addSubview:viewForGuest];
    
    UILabel * lblguest = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewForGuest.frame.size.width, 50)];
    [lblguest setBackgroundColor:[UIColor clearColor]];
    [lblguest setText:@"Guest user"];
    [lblguest setTextAlignment:NSTextAlignmentCenter];
    [lblguest setFont:[UIFont fontWithName:CGBold size:textSizes+7]];
    [lblguest setTextColor:[UIColor whiteColor]];
    [viewForGuest addSubview:lblguest];
    
    UILabel * lblMessageGuest = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, viewForGuest.frame.size.width-20, 100)];
    [lblMessageGuest setText:@"In guest user device is visible to all and Any one can connect and cotrol and  untill unless device disconnect from that user"];
    [lblMessageGuest setTextAlignment:NSTextAlignmentCenter];
    [lblMessageGuest setFont:[UIFont fontWithName:CGRegularItalic size:textSizes+2]];
    [lblMessageGuest setTextColor:[UIColor whiteColor]];
    lblMessageGuest.numberOfLines = 6;
    [viewForGuest addSubview:lblMessageGuest];
    
    UIButton * btnGuestUser = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnGuestUser setFrame:CGRectMake(15, lblMessageGuest.frame.size.height+70, viewForGuest.frame.size.width-30, 50)];
    [btnGuestUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnGuestUser.titleLabel setFont:[UIFont fontWithName:CGRegular size:textSizes]];
    [btnGuestUser addTarget:self action:@selector(btnGuestClick) forControlEvents:UIControlEventTouchUpInside];
    btnGuestUser.backgroundColor = global_brown_color;
    [btnGuestUser setTitle:@"Click here to Skip login" forState:UIControlStateNormal];
    [btnGuestUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnGuestUser.layer.cornerRadius = 10;
    [viewForGuest addSubview:btnGuestUser];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        lblBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
    }
}
#pragma mark- Buttons
-(void)btnLoginClick
{
    LoginVC * lVc = [[LoginVC alloc] init];
    [self.navigationController pushViewController:lVc animated:true];
}
-(void)btnGuestClick // skip user
{
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IS_LOGGEDIN"];
    [[NSUserDefaults standardUserDefaults] setValue:@"000" forKey:@"CURRENT_USER_ID"];
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"IS_USER_SKIPPED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self AddAlarmforLoggedinUser];

    [APP_DELEGATE GenerateEncryptedKeyforLogin:@""];
    [self ResetAllUUIDs];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
    [UIView commitAnimations];
    [APP_DELEGATE goToDashboard];
    [APP_DELEGATE addScannerView];
}
-(void)AddAlarmforLoggedinUser
{
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    
    NSString * strCheck = [NSString stringWithFormat:@"select * from Alarm_Table where user_id = '%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strCheck resultsArray:tmpArr];
    
    if ([tmpArr count]==0)
    {
        for (int i = 0; i<6; i++)
        {
            NSString * strIndex = [NSString stringWithFormat:@"%d",i+1];
            NSString * strAlarmDevice = [NSString stringWithFormat:@"insert into 'Alarm_Table'('user_id','status','AlarmIndex') values('%@','%@','%@')",CURRENT_USER_ID,@"2",strIndex];
            [[DataBaseManager dataBaseManager] execute:strAlarmDevice];
        }
    }
}
-(void)ResetAllUUIDs
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"globalUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"colorUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"whiteColorUDID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OnOffUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatternUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PingUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WhiteUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AddGroupUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteGroupUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeleteAlarmUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MusicUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RememberUDID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IdentifyUUID"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [APP_DELEGATE createAllUUIDs];

}
@end
