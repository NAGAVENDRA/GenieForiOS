//
//  GenieGlobalData.h
//  GenieiPhoneiPodtest
//
//  Created by cs Siteview on 12-3-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
//#define __GENIE_DEBUG__

#ifdef __GENIE_DEBUG__
#define PrintObj(obj)  NSLog(@"GenieLog:%@",obj)
#define GeniePrint(msg,obj) {\
                    PrintObj(@"###########################################################");\
                    PrintObj(msg);\
                    PrintObj(obj);\
                    PrintObj(@"###########################################################");\
                    }
#else
#define PrintObj(obj)  ;
#define GeniePrint(msg,obj) ;
#endif


#pragma mark Global Value
#ifdef __GENIE_IPHONE__

#define iOSDeviceScreenWidth                320
#define iOSDeviceScreenHeight               480
#define iOSStatusBarHeight                  20
#define Navi_Bar_Height_Portrait            44
#define Navi_Bar_Height_Landscape           32

#else

#define iOSDeviceScreenWidth                768
#define iOSDeviceScreenHeight               1024
#define iOSStatusBarHeight                  20
#define Navi_Bar_Height_Portrait            44
#define Navi_Bar_Height_Landscape           44

#endif

#define CGZero                              0.0
#define BACKGROUNDCOLOR                     [UIColor colorWithRed:229.0/255 green:229.0/255 blue:251.0/255 alpha:1.0]

//_____________________configuration files name
/*
 *v1.0.15的配置文件(除mymedia模块):
 *GenieCofig.ini    存储了路由器的账号密码、LPC的最近成功登陆账号密码、timeperiod信息 （已备份处理并删除）
 *routerMap.info    network map 的用户自定义信息  （已备份处理并删除）
 *routerinfo.info   统计数据---》路由器发送信息记录  （无影响，可直接删除）
 *GenieIstInfo.ini  统计数据---》安装信息发送记录    （无影响，可直接删除）
 */
#define Genie_File_ConfigInfo                            @"genie_configuration.info"
#define Genie_File_UserHabits_Info                       @"genie_userhabits.info"
#define Genie_File_NetworkMap_UserDefined_Info           @"genie_networkmap_userdefine.info"
#define Genie_File_LPC_Config_Info                       @"genie_parentalcontols_config.info"
#define Genie_File_GuestAccess_TimePeriod_Info           @"genie_file_guestaccess_timeperiod.info"
#define Genie_File_Statistics_Installation_Info          @"genie_file_statistics_installation.info"
#define Genie_File_Statistics_Router_Info                @"genie_file_statistics_router.info"

#define Genie_File_SN_Authenticated_Routers_Info         @"genie_file_sn_authenticated_routers.info"//记录登陆过的远端路由器的账号和密码
#define Genie_File_SN_SmartNetworkAvailable_Flag_Info    @"genie_file_sn_smartnetworkavailable_flag.info"//记录Genie是否要开启smart network


///////////business process  timeout
#define Genie_NoTimeOut                               -1

#define Genie_Login_ProcessTimeout                    Genie_NoTimeOut //60
//............time for get info
#define Genie_Get_Wireless_Process_Timeout            Genie_NoTimeOut //20
#define Genie_Get_Guest_Process_Timeout               Genie_NoTimeOut //20
#define Genie_Get_NetworkMap_Process_Timeout          Genie_NoTimeOut //30
#define Genie_Get_LPC_Process_Timeout                 Genie_NoTimeOut
#define Genie_Get_LPC_AccountRelay_Timeout            Genie_NoTimeOut //10
#define Genie_Create_OpenDNSAccount_Timeout           Genie_NoTimeOut
#define Genie_Get_Traffic_Process_Timeout             Genie_NoTimeOut //20
//..............time for set info
#define Genie_Set_Wireless_Process_Timeout            90
#define Genie_Set_Guest_Process_Timeout               90
#define Genie_Set_NetworkMap_Process_Timeout          Genie_NoTimeOut //30
#define Genie_Set_LPC_Enable_Process_Timeout          Genie_NoTimeOut
#define Genie_Set_LPC_Filter_Process_Timeout          Genie_NoTimeOut
#define Genie_Set_Traffic_Process_Timeout             Genie_NoTimeOut //40
///////////
#define Genie_ADMIN                                 @"admin"//路由器默认登陆账号
#define Genie_N_A                                   @"N/A"
#define AutoChannel                                 @"Auto"

#define GenieSecurityModeStringNone                 @"None"
#define GenieSecurityModeStringWPA_PSK              @"WPA2-PSK[AES]"
#define GenieSecurityModeStringWPA_PSK_WPA2_PSK     @"WPA-PSK[TKIP] + WPA2-PSK[AES]"

#define GenieSecurityModeStringWPA_PSK_SET          @"WPA2-PSK"
#define GenieSecurityModeStringWPA_PSK_WPA2_PAK_SET @"WPA-PSK/WPA2-PSK"
#define GenieSecurityModeStringMixed_SET            @"Mixed WPA"

#define Genie_Security_Mode_Set                     [[[NSSet alloc]initWithObjects:@"WPA-PSK",@"Mixed WPA",@"WPA-PSK/WPA2-PSK",@"WPA-PSK[TKIP] + WPA2-PSK[AES]",nil] autorelease]

#define Genie_Guest_TimePeriod_Always               @"TimePeriod_Always"
#define Genie_Guest_TimePeriod_OneHour              @"TimePeriod_OneHour"
#define Genie_Guest_TimePeriod_FiveHours            @"TimePeriod_FiveHours"
#define Genie_Guest_TimePeriod_TenHours             @"TimePeriod_TenHours"
#define Genie_Guest_TimePeriod_OneDay               @"TimePeriod_OneDay"
#define Genie_Guest_TimePeriod_OneWeek              @"TimePeriod_OneWeek"
#define Genie_Traffic_Option_NoLimit                @"No Limit"
#define Genie_Traffic_Option_DownloadLimit          @"Download only"
#define Genie_Traffic_Option_BothLimit              @"Both directions"
#define Genie_LPC_Bundle_None                       @"None"
#define Genie_LPC_Bundle_Minimal                    @"Minimal"    
#define Genie_LPC_Bundle_Low                        @"Low"
#define Genie_LPC_Bundle_Moderate                   @"Moderate"
#define Genie_LPC_Bundle_High                       @"High"
#define Genie_LPC_Bundle_Custom                     @"custom"

///////////////////////
#pragma mark -----------------------------------
#pragma mark --------Resource Localized Begin-------
#define Localization_Back                                          NSLocalizedString(@"back",nil)
#define Localization_Cancel                                        NSLocalizedString(@"cancel",nil)
#define Localization_Close                                         NSLocalizedString(@"close",nil)
#define Localization_Ok                                            NSLocalizedString(@"ok",nil)
#define Localization_Login                                         NSLocalizedString(@"login",nil)
#define Localization_Logout                                        NSLocalizedString(@"logout",nil)
#define Localization_Save                                          NSLocalizedString(@"save",nil)


#pragma mark         Msg Box Localization
#define Local_Wait                                              NSLocalizedString(@"wait",nil)
#define Local_WaitForLoadWirelessInfo                           NSLocalizedString(@"waitForLoadWirelessInfo",nil)
#define Local_WaitForRefreshWirlessInfo                         NSLocalizedString(@"waitForRefreshWirelessInfo",nil)
#define Local_WaitForSetWirelessInfo                            NSLocalizedString(@"waitForSetWirelessInfo",nil)
#define Local_WaitForLoadGuestInfo                              NSLocalizedString(@"waitForLoadGuestInfo",nil)
#define Local_WaitForRefreshGuestInfo                           NSLocalizedString(@"waitForRefreshGuestInfo",nil)
#define Local_WaitForSetGuestInfo                               NSLocalizedString(@"waitForSetGuestInfo",nil)
#define Local_WaitForLoadNetworkMapInfo                         NSLocalizedString(@"waitForLoadNetworkMapInfo",nil)
#define Local_WaitForRefreshNetWorkMapInfo                      NSLocalizedString(@"waitForRefreshNetworkMapInfo",nil)
#define Local_WaitForSetNetWorkMapInfo                          NSLocalizedString(@"waitForSetNetworkMapInfo",nil)
#define Local_WaitForLoadTrafficInfo                            NSLocalizedString(@"waitForLoadTrafficMeterInfo",nil)
#define Local_WaitForRefreshTrafficInfo                         NSLocalizedString(@"waitForRefreshTrafficMeterInfo",nil)
#define Local_WaitForSetTrafficInfo                             NSLocalizedString(@"waitForSetTrafficMeterInfo",nil)

#define Local_WaitForLoadLPCInfo                                NSLocalizedString(@"waitForLoadLPCInfo",nil)
#define Local_WaitForRefreshLPCInfo                             NSLocalizedString(@"waitForRefreshLPCInfo",nil)
#define Local_WaitForSetLPCEnableStatus                         NSLocalizedString(@"waitForSetLPCEnableStatus",nil)
#define Local_WaitForSetLPCFilter                               NSLocalizedString(@"waitForSetLPCFilter",nil)
#define Local_WaitForSignInOpenDNS                              NSLocalizedString(@"waitForSignInOpenDns",nil)
#define Local_WaitForCreateOpenDNSAccount                       NSLocalizedString(@"waitForCreateOpenDNSAccount",nil)
#define Local_WaitForGetLPCAccountRelay                         NSLocalizedString(@"waitForGetLPCAccountRelay",nil)

#define Local_MsgForNoWIFI                                      NSLocalizedString(@"msgForNoWIFI",nil)
#define Local_MsgForNoInternetDetected                          NSLocalizedString(@"msgForNoInternet",nil)
#define Local_MsgForNetworkError                                NSLocalizedString(@"msgForNetworkError",nil)
#define Local_MsgForGenieFuncNotSupport                         NSLocalizedString(@"msgForRouterFirmwareNotSupport",nil)
#define Local_MsgForNotNetgearRouter_HTML                       NSLocalizedString(@"msgForNotNetgearRouter",nil)
#define Local_MsgForLoginGenieKeyInvalid                        NSLocalizedString(@"msgForLoginGeniePasskeyInvalid",nil)
#define Local_MsgForTimeout                                     NSLocalizedString(@"msgForTimeout",nil)
#define Local_MsgForSetAndRebootRouterPrompt                    NSLocalizedString(@"msgForSetAndRebootRouter",nil)
#define Local_MsgForSetAndRebootRouterSuccessedPrompt           NSLocalizedString(@"msgForSetAndRebootRouterSuccessed",nil)
#define Local_MsgForTimePeriodOutdatePrompt                     NSLocalizedString(@"msgForTimePeriodOutdate",nil)
#define Local_MsgForPasswordNoMatchUsername                     NSLocalizedString(@"msgForPasswordNoMatchUsername",nil)

#define Local_MsgForAskUserIfHaveOpenDnsAccount                 NSLocalizedString(@"msgForAskIfUserHaveOpenDNSAccount",nil)
#define Local_MsgForOpenDNSHostIsNotAvailable                   NSLocalizedString(@"msgForOpenDNSHostIsNotAvailable",nil)
#define Local_MsgForAuthenticationFailed                        NSLocalizedString(@"msgForAuthenticationFailed",nil)
#define Local_MsgForLPCCheckUserNameNotAvailable                NSLocalizedString(@"msgForLPCCheckUserNameNotAvailable",nil)
#define Local_MsgForLPCSignInOpenDNSPassKeyWrong                NSLocalizedString(@"msgForLPCSignInOpenDNSPassKeyWrong",nil)
#define Local_MsgForLPCSignInOpenDNSDeviceIsNotMine             NSLocalizedString(@"msgForLPCSignInOpenDNSDeviceIsNotMine",nil) 

#define Local_MsgForLPCCreateAccountUserNameFormatIllegal           NSLocalizedString(@"msgForLPCCreateAccountUserNameFormatIllegal",nil)
#define Local_MsgForLPCCreateAccountPasswordLengthIllegal           NSLocalizedString(@"msgForLPCCreateAccountPasswordLengthIllegal",nil)
#define Local_MsgForLPCCreateAccountConfirmPasswordIllegal          NSLocalizedString(@"msgForLPCCreateAccountConfirmPasswordIllegal",nil)
#define Local_MsgForLPCCreateAccountEmailFormatIllegal              NSLocalizedString(@"msgForLPCCreateAccountEmailFormatIllegal",nil)
#define Local_MsgForLPCCreateAccountConfirmEmailIllegal             NSLocalizedString(@"msgForLPCCreateAccountConfirmEmailIllegal",nil)
#define Local_MsgForLPCCreateAccountEmailIsUnavailable              NSLocalizedString(@"msgForLPCCreateAccountEmailIsUnavailable",nil)
#define Local_MsgForLPCCreateAccountFailed                          NSLocalizedString(@"msgForLPCCreateAccountFailed",nil)
#define Local_MsgForLPCCreateAccountSuccessed                       NSLocalizedString(@"msgForLPCCreateAccountSuccessed",nil)

#define Local_MsgForSmartNetworkLoginKeyWrong                       NSLocalizedString(@"msgForSmartNetworkLoginKeyWrong",nil)
#define Local_MsgForSmartNetworkForgetPasswordHTML                  NSLocalizedString(@"msgForSmartNetworkForgetPasswordHTML",nil)
#define Local_MsgForSmartNetworkSignUpHTML                          NSLocalizedString(@"msgForSmartNetworkSignUpHTML",nil)
#define Local_MsgForSmartNetworkNoDeviceFound                       NSLocalizedString(@"msgForSmartNetworkNoRemoteRouterFound",nil)
////////////////////////////////
#pragma mark            HomePage Localization
#define Localization_HP_SearchBar_PlaceHolder                    NSLocalizedString(@"searchBarPlaceHolder",nil)
#define Localization_HP_Wireless_Function_Btn_Title              NSLocalizedString(@"wirelessSettingHomeBtnTitle",nil)
#define Localization_HP_Guest_Function_Btn_Title                 NSLocalizedString(@"guestAccessHomeBtnTitle",nil)
#define Localization_HP_Map_Function_Btn_Title                   NSLocalizedString(@"networkMapHomeBtnTitle",nil)
#define Localization_HP_LPC_Function_Btn_Title                   NSLocalizedString(@"parentalControlsHomeBtnTitle",nil)
#define Localization_HP_Traffic_Function_Btn_Title               NSLocalizedString(@"trafficMeterHomeBtnTitle",nil)
#define Localization_HP_MyMedia_Function_Btn_Title               NSLocalizedString(@"myMediaHomeBtnTitle",nil)
#define Localization_HP_QR_Code_Function_Btn_Title               NSLocalizedString(@"qrCodeHomeBtnTitle",nil)
#define Localization_HP_AppStore_Function_Btn_Title              NSLocalizedString(@"appStoreBtnTitle",nil)

#define Localization_HP_AboutDialog_Title                        NSLocalizedString(@"aboutDialogTitle",nil)
#define Localization_HP_AboutDialog_RouterModel_Title            NSLocalizedString(@"aboutDialogRouterModelTitle",nil)
#define Localization_HP_AboutDialog_FirmwareVersion_Title        NSLocalizedString(@"aboutDialogFirmwareVersionTitle",nil)
#define Localization_HP_AboutDialog_GenieVersion_Title           NSLocalizedString(@"aboutDialogGenieVersionTitle",nil)
#define Localization_HP_AboutDialog_CopyRight_Info               NSLocalizedString(@"aboutDialogCopyRightInfo",nil)
#define Localization_HP_AboutDialog_AllRight_Info                NSLocalizedString(@"aboutDialogAllRightInfo",nil)
#define Localization_HP_AboutDialog_PoweredBy_Info               NSLocalizedString(@"aboutDialogPoweredByInfo",nil)
#define Localization_HP_AboutDialog_License_Title                NSLocalizedString(@"aboutDialogLicenseTitle",nil)
////////////////////////
#pragma mark Login
#define Localization_Login_MainPage_Title                                       NSLocalizedString(@"loginMainPageTitle",nil)
#define Localization_Login_MainPage_LoginMode_Switcher_Title                    NSLocalizedString(@"loginMainPageModeSwitcherTitle",nil)
#define Localization_Login_MainPage_RouterAdmin_Title                           NSLocalizedString(@"loginMainPageRouterAdminLabelTitle",nil)
#define Localization_Login_MainPage_SN_Account_Title                            NSLocalizedString(@"loginMainPageSmartNetworkAccountLableTitle",nil)
#define Localization_Login_MainPage_Password_Title                              NSLocalizedString(@"loginMainPagePasswordLabelTitle",nil)
#define Localization_Login_MainPage_RememberMe_Switcher_Title                   NSLocalizedString(@"loginMainPageRememberMeSwitcherTitle",nil)
#define Localization_Login_MainPage_DefaultPasswordPrompt                       NSLocalizedString(@"loginMainPageDefaultPasswordPrompt",nil)

#define Localization_Login_RemoteRouterList_PageTitle                           NSLocalizedString(@"loginRemoteRouterListPageTitle",nil)
#define Localization_Login_RemoteRouterList_Serial_Title                        NSLocalizedString(@"loginRemoteRouterListPageSerialLabelTtitle",nil)

#define Localization_Login_RemoteRouterLogin_PageTitle                          NSLocalizedString(@"loginRemoteRouterLoginPageTitle",nil)
#define Localization_Login_RemoteRouterLogin_Account_Title                      NSLocalizedString(@"loginRemoteRouterLoginAccountTitle",nil)
#define Localization_Login_RemoteRouterLogin_Password_Title                     NSLocalizedString(@"loginRemoteRouterLoginPasswordTitle",nil)
#define Localization_Login_RemoteRouterLogin_RememberMe_Switcher_Title          NSLocalizedString(@"loginRemoteRouterLoginRememberMeSwitcherTitle",nil)

#define Localization_Login_RemoteRouter_online_status                           NSLocalizedString(@"loginRemoteOnlineStatus",nil)
#define Localization_Login_RemoteRouter_offline_status                          NSLocalizedString(@"loginRemoteOfflineStatus",nil)

//////////////////////
#pragma mark       Wireless Setting Localization
#define Localization_Wireless_InfoPage_Title                     NSLocalizedString(@"wirelessSettingInfoPageTitle",nil)
#define Localization_Wireless_SetPage_Title                      NSLocalizedString(@"wirelessSetPageTitle",nil)

#define Localization_Wireless_SSID_Title                         NSLocalizedString(@"wirelessSSIDTitle",nil)
#define Localization_Wireless_Channel_Title                      NSLocalizedString(@"wirelessChannelTitle",nil)
#define Localization_Wireless_Password_Title                     NSLocalizedString(@"wirelessPasswordTitle",nil)
#define Localization_Wireless_SecurityMode_Title                 NSLocalizedString(@"wirelessSecurityModeTitle",nil)
#define Localization_Wireless_Password_Length_Prompt             NSLocalizedString(@"wirelessPasswordLengthLimitPrompt",nil)

///////////////////////////
#pragma mark         GuestAccess Localization
#define Localization_Guest_InfoPage_Title                        NSLocalizedString(@"guestAccessInfoPageTitle",nil)
#define Localization_Guest_SetPage_Title                         NSLocalizedString(@"guestAccessSetPageTitle",nil)

#define Localization_Guest_Switcher_Title                        NSLocalizedString(@"guestAccessSwitcherTitle",nil)
#define Localization_Guest_SSID_Title                            NSLocalizedString(@"guestAccessSSIDTitle",nil)
#define Localization_Guest_Password_Title                        NSLocalizedString(@"guestAccessPasswordTitle",nil)
#define Localization_Guest_TimePeriod_Title                      NSLocalizedString(@"guestAccessTimePeriodTitle",nil)
#define Localization_Guest_SecurityMode_Title                    NSLocalizedString(@"guestAccessSecurityModeTitle",nil)
#define Localization_Guest_Password_Length_Prompt                NSLocalizedString(@"guestAccessPasswordLengthLimitPrompt",nil)

#define Localization_Guest_Time_Period_Allways                   NSLocalizedString(@"timePeriodAllways",nil)
#define Localization_Guest_Time_Period_OneHour                   NSLocalizedString(@"timePeriodOneHour",nil)
#define Localization_Guest_Time_Period_FiveHours                 NSLocalizedString(@"timePeriodFiveHours",nil)
#define Localization_Guest_Time_Period_TenHours                  NSLocalizedString(@"timePeriodTenHours",nil)
#define Localization_Guest_Time_Period_OneDay                    NSLocalizedString(@"timePeriodOneDay",nil)
#define Localization_Guest_Time_Period_OneWeek                   NSLocalizedString(@"timePeriodOneWeek",nil)

//////////////////////////////
#pragma mark        Network Map Localization
#define Localization_NetworkMap_InfoPage_Title                   NSLocalizedString(@"networkMapInfoPageTitle",nil)
#define Localization_NetworkMap_Internet_Lable_Text              NSLocalizedString(@"networkMapInternetLableText",nil)
#define Localization_NetworkMap_Online_status                    NSLocalizedString(@"networkMapOnlineStatus",nil)
#define Localization_NetworkMap_Offline_status                   NSLocalizedString(@"networkMapOfflineStatus",nil)

#define Localization_NetworkMap_DeviceInfo_Name_Title                   NSLocalizedString(@"networkMapDeviceInfoNameTitle",nil)
#define Localization_NetworkMap_DeviceInfo_Type_Title                   NSLocalizedString(@"networkMapDeviceInfoTypeTitle",nil)
#define Localization_NetworkMap_DeviceInfo_FirmwareVersion_Title        NSLocalizedString(@"networkMapDeviceInfoFirmwareVersionTitle",nil)
#define Localization_NetworkMap_DeviceInfo_IpAddr_Title                 NSLocalizedString(@"networkMapDeviceInfoIpAddrTitle",nil)
#define Localization_NetworkMap_DeviceInfo_NetworkStatus_Title          NSLocalizedString(@"networkMapDeviceInfoStatusTitle",nil)
#define Localization_NetworkMap_DeviceInfo_SignalStrength_Title         NSLocalizedString(@"networkMapDeviceInfoSignalStengthTitle",nil)
#define Localization_NetworkMap_DeviceInfo_LinkSpeed_Title              NSLocalizedString(@"networkMapDeviceInfoLinkSpeedTitle",nil)
#define Localization_NetworkMap_DeviceInfo_MacAddr_Title                NSLocalizedString(@"networkMapDeviceInfoMacAddrTitle",nil)
#define Localization_NetworkMap_DeviceInfo_Block_Title                  NSLocalizedString(@"networkMapDeviceInfoBlockTitle",nil)
#define Localization_NetworkMap_BlockSwitcher_Title                     NSLocalizedString(@"networkMapBlockSwitcherTitle",nil)
/////////////////////////
#pragma mark        LPC Localization
#define Localization_Lpc_FirstPage_ShowInfo_Title                           NSLocalizedString(@"lpcFirstPageForShowInfo",nil)
#define Localization_Lpc_FirstPage_Login_Title                              NSLocalizedString(@"lpcFirstPageForLogin",nil)
#define Localization_Lpc_FirstPage_CreateAccount_Title                      NSLocalizedString(@"lpcFirstPageForCreateAccount",nil)
#define Localization_Lpc_Login_Btn_Title                                    NSLocalizedString(@"lpcBtnTitleForLogin",nil)
#define Localization_Lpc_CreateAccount_Btn_Title                            NSLocalizedString(@"lpcBtnTitleForCreateAccount",nil)

#define Localization_Lpc_CreantAccountPage_UserName_Title                   NSLocalizedString(@"lpcCreateAccountPageUserNameTitle",nil)
#define Localization_Lpc_CreantAccountPage_Password_Title                   NSLocalizedString(@"lpcCreateAccountPagePasswordTitle",nil)
#define Localization_Lpc_CreantAccountPage_Password2_Title                  NSLocalizedString(@"lpcCreateAccountPageConfirmPasswordTitle",nil)
#define Localization_Lpc_CreantAccountPage_Email_Title                      NSLocalizedString(@"lpcCreateAccountPageEmailTitle",nil)
#define Localization_Lpc_CreateAccountPage_Email2_Title                     NSLocalizedString(@"lpcCreateAccountPageConfirmEmailTitle",nil)
#define Localization_Lpc_LoginPage_Username_Title                           NSLocalizedString(@"lpcLoginPageUserNameTitle",nil)
#define Localization_Lpc_LoginPage_Password_Title                           NSLocalizedString(@"lpcLoginPagePasswordTitle",nil)
#define Localization_Lpc_ShowInfoPage_Switcher_Title                        NSLocalizedString(@"lpcShowInfoPageSwitcherTitle",nil)
#define Localization_Lpc_ShowInfoPage_FilterLevel_Title                     NSLocalizedString(@"lpcShowInfoPageFilteringLevelTitle",nil)
#define Localization_Lpc_ShowInfoPage_CustomSetting_Title                   NSLocalizedString(@"lpcShowInfoPageCustomSettingTitle",nil)
#define Localization_Lpc_ShowInfoPage_OpenDNSAccount_Title                  NSLocalizedString(@"lpcShowInfoPageOpenDNSAccountTitle",nil)
#define Localization_Lpc_ShowInfoPage_BypassAccount_Title                   NSLocalizedString(@"lpcShowInfoPageBypassAccountTitle",nil)

#define Localization_Lpc_HaveOpenDNSAccount_YES_Title                   NSLocalizedString(@"lpcAskUserHadOpenDNSAccountBtnYESTitle",nil)
#define Localization_Lpc_HaveOpenDNSAccount_NO_Title                    NSLocalizedString(@"lpcAskUserHadOpenDNSAccountBtnNOTitle",nil)

#define Localization_Lpc_FilterLevel_Page_Title                         NSLocalizedString(@"lpcFilterLevelPageTitle",nil)
#define Localization_Lpc_FilterLevel_High_Title                         NSLocalizedString(@"lpcFilterLevelHighTitle",nil)
#define Localization_Lpc_FilterLevel_Moderate_Title                     NSLocalizedString(@"lpcFilterLevelModerateTitle",nil)
#define Localization_Lpc_FilterLevel_Low_Title                          NSLocalizedString(@"lpcFilterLevelLowTitle",nil)
#define Localization_Lpc_FilterLevel_Minimal_Title                      NSLocalizedString(@"lpcFilterLevelMinimalTitle",nil)
#define Localization_Lpc_FilterLevel_None_Title                         NSLocalizedString(@"lpcFilterLevelNoneTitle",nil)
#define Localization_Lpc_FilterLevel_Custom_Title                       NSLocalizedString(@"lpcFilterLevelCustomTitle",nil)

#define Localization_Lpc_FilterLevel_High_Description                   NSLocalizedString(@"lpcFilterLevelHithDescription",nil)
#define Localization_Lpc_FilterLevel_Moderate_Description               NSLocalizedString(@"lpcFilterLevelModerateDescription",nil)
#define Localization_Lpc_FilterLevel_Low_Description                    NSLocalizedString(@"lpcFilterLevelLowDescription",nil)
#define Localization_Lpc_FilterLevel_Minimal_Description                NSLocalizedString(@"lpcFilterLevelMinimalDescription",nil)
#define Localization_Lpc_FilterLevel_None_Description                   NSLocalizedString(@"lpcFilterLevelNoneDescription",nil)

#define Localization_BypassAccount_ListPageTitle                        NSLocalizedString(@"lpcBypassAccountListPageTitle",nil)
#define Localization_BypassAccount_LoginAccountLabel                    NSLocalizedString(@"lpcBypassAccountLoginAccountLabel",nil)
#define Localization_BypassAccount_LoginPasswordLabel                   NSLocalizedString(@"lpcBypassAccountLoginPasswordLabel",nil)
#define Localization_BypassAccount_LogoutPageTitle                      NSLocalizedString(@"lpcBypassAccountLogoutPageTitle",nil)
#define Localization_BypassAccount_PromptOfLoggedIn                     NSLocalizedString(@"lpcBypassAccountPromptOfLoggedIn",nil)

/////////////
#pragma mark        Traffic Localization
#define Localization_Traffic_InfoPage_Title                      NSLocalizedString(@"trafficMeterInfoPageTitle",nil)
#define Localization_Traffic_NoLimit                             NSLocalizedString(@"trafficMeterNoLimit",nil)
#define Localization_Traffic_DownloadLimit                       NSLocalizedString(@"trafficMeterDownloadLimit",nil)
#define Localization_Traffic_BothLimit                           NSLocalizedString(@"trafficMeterBothLimit",nil)

#define Localization_Traffic_Switcher_Title                              NSLocalizedString(@"trafficMeterSwitchTitle",nil)
#define Localization_Traffic_MonthlyLimit_Title_InfoPage                 NSLocalizedString(@"trafficMeterMonthlyLimitTitleOnInfoPage",nil)
#define Localization_Traffic_Day_Title_InfoPage                          NSLocalizedString(@"trafficMeterDayTitleOnInfoPage",nil)
#define Localization_Traffic_Time_Title_InfoPage                         NSLocalizedString(@"trafficMeterTimeTitleOnInfoPage",nil)
#define Localization_Traffic_LimitMode_Title_InfoPage                    NSLocalizedString(@"trafficMeterLimitModeTitleOnInfoPage",nil)

#define Localization_Traffic_TotalInfoDiagram_Subject                   NSLocalizedString(@"trafficMeterTotalInfoDiagramSubject",nil)
#define Localization_Traffic_AverageInfoDiagram_Subject                 NSLocalizedString(@"trafficMeterAverageInfoDiagramSubject",nil)
#define Localization_Traffic_DiagramUnitTitle                           NSLocalizedString(@"trafficMeterDiagramUnitTitle",nil)
#define Localization_Traffic_Category_Today                             NSLocalizedString(@"trafficMeterCategoryToday",nil)
#define Localization_Traffic_Category_Yesterday                          NSLocalizedString(@"trafficMeterCategoryYesterday",nil)
#define Localization_Traffic_Category_ThisWeek                           NSLocalizedString(@"trafficMeterCategoryThisWeek",nil)
#define Localization_Traffic_Category_ThisMonth                          NSLocalizedString(@"trafficMeterCategoryThisMonth",nil)
#define Localization_Traffic_Category_LastMonth                          NSLocalizedString(@"trafficMeterCategoryLastMonth",nil)
#define Localization_Traffic_Prompt_Upload                               NSLocalizedString(@"trafficMeterPromptUpload",nil)
#define Localization_Traffic_Prompt_Download                             NSLocalizedString(@"trafficMeterPromptDownload",nil)

#define Localization_Traffic_SetPage_Title                               NSLocalizedString(@"trafficMeterSetPageTitle",nil)
#define Localization_Traffic_MonthlyLimit_Title_ModifyPage               NSLocalizedString(@"trafficMeterMonthlyLimitTitleOnModifyPage",nil)
#define Localization_Traffic_Day_Title_ModifyPage                        NSLocalizedString(@"trafficMeterDayTitleOnModifyPage",nil)
#define Localization_Traffic_Time_Title_ModifyPage                       NSLocalizedString(@"trafficMeterTimeTitleOnModifyPage",nil)
#define Localization_Traffic_Time_Hour_Label_Title                       NSLocalizedString(@"trafficMeterTimeOfHourLabelTitle",nil)
#define Localization_Traffic_Time_Minute_Label_Title                     NSLocalizedString(@"trafficMeterTimeOfMinuteLabelTitle",nil)
#define Localization_Traffic_LimitMode_Title_ModifyPage                  NSLocalizedString(@"trafficMeterLimitModeTitleOnModifyPage",nil)
#define Localization_Traffic_LimitMode_Title_ForSelectItemPage           NSLocalizedString(@"trafficMeterLimitModeTitleForSelectItemPage",nil)
#define Localization_Traffic_Conter_Start_Prompt                         NSLocalizedString(@"trafficMeterConterStartPrompt",nil)


/////////////////
#pragma mark           QRCode Localization
#define Localization_QRCode_Page_Title                                  NSLocalizedString(@"qrCodeMainPageTitle",nil)
#define Localization_QRCode_Not_Support                                 NSLocalizedString(@"qrCodeCameraIsUnavailable",nil)
#define Localization_QRCode_Scan_Btn_Title                              NSLocalizedString(@"qrCodeScanBtnTitle",nil)
#define Localization_QRCode_WIFI_SSID_Title                             NSLocalizedString(@"qrCodeWifiSSIDTitle",nil)
#define Localization_QRCode_WIFI_Password_Title                         NSLocalizedString(@"qrCodeWifiPasswordTitle",nil)
#define Localization_QRCode_HowTO_Scanning_Prompt                       NSLocalizedString(@"qrCodePromptUserHowToScaning",nil)
#define Localization_QRCode_Web_Address_info_Prompt                     NSLocalizedString(@"qrCodePromptForGetWebAddressInfo",nil)
#define Localization_QRCode_WIFI_info_Prompt                            NSLocalizedString(@"qrCodePromptForGetWIFIInfo",nil)
#define Localization_QRCode_FIND_URL_Prompt                        NSLocalizedString(@"qrCodePromptForFindURL",nil)
#define Localization_QRCode_OPEN_URL_Prompt                        NSLocalizedString(@"qrCodePromptForOpenURL",nil)


#pragma mark --------Resource Localized End-------
#pragma mark -----------------------------------

#pragma mark enum Define
#define  GenieLogin   YES
#define  GenieLogout  NO
//all function type list
typedef enum 
{
    GenieFunctionTypeBegin = 100,
    //_____functionType 用来唯一标示功能模块,不可重复
    GenieFunctionWireless = 101,
	GenieFunctionGuest = 102,
	GenieFunctionMap = 103,
	GenieFunctionParentalControls = 104,
    GenieFunctionTraffic = 105,
    GenieFunctionMyMedia = 106,
    GenieFunctionQRCode  = 107,
    GenieFunctionAppStore = 108,
    //_____
    GenieFunctionTypeEnd,
    GenieFunctionHomePage = 0
} GenieFunctionType;

/////
typedef enum 
{
    GenieFunctionNotEnbaled = 0,
    GenieFunctionEnabled,
    GenieFunctionNotSupport
}GenieFunctionEnableStatus;

////genie error type
typedef enum {
    GenieErrorAsyncOpTimeout=0,
    GenieErrorAsyncOpCancel,
    GenieErrorBadError,
    GenieErrorUnknown,
    GenieErrorNoError,
    //fxsoap
    GenieErrorSoap401,
    GenieErrorSoap501,
    //login router
    GenieErrorNotNetgearRouter,
    GenieErrorLoginPasskeyInvalid,
    GenieErrorLoginUnknownErr,
    //smart network
    GenieError_SN_Authenticate_Failed,
    GenieError_SN_RouterAuth_Failed = GenieErrorLoginPasskeyInvalid,
    //lpc
    GenieError_LPC_AuthenticateRouter_Failed,
    GenieError_LPC_AutoLogin_Failed,
    GenieError_LPC_NoInternet,
    GenieError_LPC_UnavailableAccount,
    GenieError_LPC_CheckUserName_NO,
    GenieError_LPC_SignInOpenDNS_PassKey_Wrong,
    GenieError_LPC_UnexpectedError
}GenieErrorType;
//router type list
typedef enum 
{
    GenieRouterTypeNotNetgear = 0,
    GenieRouterTypeDG,
    GenieRouterTypeCG,
    GenieRouterTypeOther
}GenieRouterType;


typedef enum
{
    GenieNetWorkOffline = 0,
    GenieNetWorkOnline
}GenieNetWorkStatus;


//security mode list
typedef enum {
    GenieBasicSecurityModeWEP = 0,
    GenieBasicSecurityModeWPA
}GenieBasicSecurityMode;

typedef enum
{
    GenieBlockEnable=0,
    GenieBlockDisable,
    GenieBlockNotSupport
}GenieBlockType;
//net work connection mode


typedef enum 
{
    GenieConnectWireless = 0,
    GenieConnectWired
}GenieConnectMode;


///////////////////////////////////////////////////
//V1.0.15保存用户配置信息的一个数据结构//////////////////
//////////////////////////////////////////////////
typedef struct
{
	int  starttime;
	int  worktime;
	char isSave;
	char username[40];
	char password[40];
	char routerMac[40];
	char PCUsername[40];
	char PCPassword[40];
	char PCDeviceID[40];
	char PCLoginToken[40];
}UserInfo;

