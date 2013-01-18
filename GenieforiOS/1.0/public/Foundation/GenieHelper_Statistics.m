//
//  GenieHelper_Statistics.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieHelper_Statistics.h"
#import "GenieRoute_Info.h"

//
#include <stdio.h>
#include <string.h>
#include <sys/sysctl.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/sockio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if_dl.h> 
#include <net/ethernet.h>
#include <net/if.h>
//

#define    min(a,b)    ((a) < (b) ? (a) : (b))
#define    max(a,b)    ((a) > (b) ? (a) : (b))
#define BUFFER_SIZE   (64*1024)
#define statistics_server @"lrs.netgear.com"
//#define statistics_server @"192.168.7.200"
@implementation GenieHelper (GenieHelper_netinfo)

typedef bool GenieHelperLock;
#define status_locked       true
#define status_unlocked     false

+ (NSString*) getLocalMacAddress
{
    struct ifconf ifc;
    struct ifreq *ifr;
    char activeInterfaceName[20];
    char macaddr[20];
    char *buffer;
    if ((buffer = (char*)malloc(BUFFER_SIZE)) == NULL)
    {
        return nil;
    }
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        free(buffer);
        return nil;
    }
    
    ifc.ifc_len = BUFFER_SIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        free(buffer);
        close(sockfd);
        return nil;
    }
    
    int interfaceFlag = 0x00;
    memset(activeInterfaceName, 0x00, sizeof(activeInterfaceName));
    for (char* ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        printf("[ifr_name] %s\n",ifr->ifr_name);
        if (strncmp(ifr->ifr_name, "lo0", 3) != 0 && ifr->ifr_addr.sa_family == AF_INET)
        {
            if (-1 != ioctl(sockfd, SIOCGIFFLAGS, ifr))//
            {
                interfaceFlag = ifr->ifr_flags;
                if (interfaceFlag & IFF_UP)
                {
                    strncpy(activeInterfaceName, ifr->ifr_name, min(sizeof(activeInterfaceName), sizeof(ifr->ifr_name)));
                    activeInterfaceName[sizeof(activeInterfaceName)-1] = 0x00;
                    break;
                }
            }
        }
        ptr += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }

    bool flag = false;
    char * p_name = activeInterfaceName[0] == 0x00 ? "en0" : activeInterfaceName;//所有接口都为非up状态时，取默认网卡地址
    for (char * p = buffer; p < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)p;
        if (ifr->ifr_addr.sa_family == AF_LINK && strncmp(ifr->ifr_name, p_name, strlen(p_name)) == 0)
        {
            struct sockaddr_dl * sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            //printf("[ifr_name] %s\n",ifr->ifr_name);
            printf("[link_ntoa] %s\n",link_ntoa(sdl));
            int a,b,c,d,e,f;
            struct ether_addr* en_p = (struct ether_addr*)LLADDR(sdl); 
            if (en_p)
            {
                memset(macaddr, 0x00, sizeof(macaddr));
                strcpy(macaddr, ether_ntoa(en_p));
                sscanf(macaddr, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
                sprintf(macaddr, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
                flag = true;
                break;
            }
        }
        p += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    
    free(buffer);
    close(sockfd);
    
    NSString * mac = nil;
    if (flag)
    {
        mac = [NSString stringWithCString:macaddr encoding:NSUTF8StringEncoding];
    }
    return mac;
}

+ (NSString*) getLocalIpAddress
{
    int                 flags;
    struct ifconf       ifc;
    struct ifreq        *ifr;
    char temp[20];
    char * buffer;
    if ((buffer = (char*)malloc(BUFFER_SIZE)) == NULL)
    {
        return nil;
    }
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        free(buffer);
        return nil;
    }
    
    ifc.ifc_len = BUFFER_SIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        free(buffer);
        close(sockfd);
        return nil;
    }
    
    bool flag = false;
    for (char* ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        //printf("[ifr_name] %s\n",ifr->ifr_name);
        if (strncmp(ifr->ifr_name, "lo0", 3) != 0 && ifr->ifr_addr.sa_family == AF_INET)
        {
            if (-1 != ioctl(sockfd, SIOCGIFFLAGS, ifr))//
            {
                flags = ifr->ifr_flags;
                if (flags & IFF_UP)
                {
                    struct sockaddr_in *sin = (struct sockaddr_in *)&ifr->ifr_addr;
                    memset(temp, 0x00, sizeof(temp));
                    strcpy(temp, inet_ntoa(sin->sin_addr));
                    printf("[inet] %s\n",temp);
                    flag = true;
                    break;
                }
            }
        }
        ptr += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    
    free(buffer);
    close(sockfd);
    
    NSString * ip = nil;
    if (flag)
    {
        ip = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
    }
    return ip;
}
+ (NSString*) getRouterIpAddress
{
    NSString* routerIP = nil;
	NSMutableArray *routerArray = [GenieRoute_Info getRoutes];
	for(int i = 0; i < (int)[routerArray count]; i++)
	{
		GenieRoute_Info* router = (GenieRoute_Info*)[routerArray objectAtIndex:i];
		routerIP = [router getGateway];
	}
    return routerIP;
}
@end

//
@implementation GenieHelper (GenieHelper_Statistics)
static  NSString * key_Statistics_Installation_Send_Successed = @"key_Statistics_Installation_Send_Successed";
static  NSString * key_Statistics_Installation_Date = @"key_Statistics_Installation_Date";
static  NSString * key_Statistics_Installation_Time = @"key_Statistics_Installation_Time";
const NSTimeInterval timeout_sendInstallationInfo = 10;
+ (void) sendStatistics_InstallationInfo
{
    static GenieHelperLock lock_send_instal = status_unlocked;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (lock_send_instal == status_locked)
        {
            return ;
        }
        else
        {
            lock_send_instal = status_locked;
        }
        NSDictionary * dic = [GenieHelper readFile:Genie_File_Statistics_Installation_Info];
        if (dic && [(NSNumber*)[dic objectForKey:key_Statistics_Installation_Send_Successed] boolValue])
        {
            PrintObj(@"sendStatistics_InstallationInfo had been sended");
            lock_send_instal = status_unlocked;
            return;
        }
        NSString * deviceMac = [GenieHelper getLocalMacAddress];
        if ([deviceMac length] <= 0)
        {
            lock_send_instal = status_unlocked;
            return;
        }
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        NSString * dateStr = [dic objectForKey:key_Statistics_Installation_Date];
        NSString * timeStr = [dic objectForKey:key_Statistics_Installation_Time];
        if ([dateStr length] <= 0 || [timeStr length] <= 0)
        {
            NSDate * installationDate = [NSDate date];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            dateStr = [dateFormatter stringFromDate:installationDate];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            timeStr = [dateFormatter stringFromDate:installationDate];
        }
        NSString * deviceOs = [NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion]];
        NSString * genieVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] ;
        NSString * info = [NSString stringWithFormat:@"/I?PM=%@&D=%@&T=%@&OS=%@&GV=%@",deviceMac, dateStr, timeStr, deviceOs, genieVersion];
        BOOL send_successed = NO;
        NSURL * url = [[[NSURL alloc] initWithScheme:@"http" 
                                                host:[NSString stringWithFormat:@"%@:%d",statistics_server,80]
                                                path:info] autorelease];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        [theRequest setTimeoutInterval:timeout_sendInstallationInfo];
        NSError * error = nil;	
        PrintObj(@"sending data");
        [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&error];
        if (!error)
        {
            send_successed = YES;
            PrintObj(@"sendStatistics_InstallationInfo successed");
        }
        NSMutableDictionary * d = [[NSMutableDictionary alloc] init];
        [d setObject:[NSNumber numberWithBool:send_successed] forKey:key_Statistics_Installation_Send_Successed];
        [d setObject:dateStr forKey:key_Statistics_Installation_Date];
        [d setObject:timeStr forKey:key_Statistics_Installation_Time];
        [GenieHelper write:d toFile:Genie_File_Statistics_Installation_Info];
        [d release];
        [pool release];
        
        lock_send_instal = status_unlocked;
    });
}

/////////
static  NSString * key_Statistics_RouterInfo_List = @"key_Statistics_RouterInfo_List";
static  NSString * key_Statistics_RouterInfo_Send_Successed = @"key_Statistics_RouterInfo_Send_Successed";
static  NSString * key_Statistics_RouterInfo_RouterMac = @"key_Statistics_RouterInfo_RouterMac";
const NSTimeInterval timeout_sendRouterInfo = 10;
+ (void) sendStatistics_RouterInfo
{
    /*
     *查询已发送信息的列表 --------匹配路由器MAC以及发送成功状态 若匹配成功，则不再发送
     *发送当前路由器的信息 若成功，则将该信息加入到list并写入到文件  否则，退出函数
     */
    static GenieHelperLock lock_sent_routerinfo = status_unlocked;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (lock_sent_routerinfo == status_locked)
        {
            return ;
        }
        else
        {
            lock_sent_routerinfo = status_locked;
        }
        NSString * localMac = [GenieHelper getLocalMacAddress];
        NSString * routerMac = [[GenieHelper getRouterInfo].mac retain];//若Genie在路由器统计数据发送前logout 这里会出先僵死内存  所以要retain
        if ([localMac length] <= 0 || [routerMac length] <= 0)
        {
            [routerMac release];
            lock_sent_routerinfo = status_unlocked;
            return;
        }
        PrintObj(routerMac);
        NSString * routerModelName = [GenieHelper getRouterInfo].modelName;
        NSString * routerFirmware = [GenieHelper getRouterInfo].firmware;
        NSString * routerSN = @"00";
        NSDictionary * dic = [GenieHelper readFile:Genie_File_Statistics_Router_Info];
        NSMutableArray * list = [dic objectForKey:key_Statistics_RouterInfo_List];
        if (list)
        {
            [list retain];
        }
        else
        {
            list = [[NSMutableArray alloc] init];
        }

        for (NSDictionary * routerInfoDic in list)
        {
            if ([(NSString*)[routerInfoDic objectForKey:key_Statistics_RouterInfo_RouterMac] isEqualToString:routerMac])
            { 
                if ([(NSNumber*)[routerInfoDic objectForKey:key_Statistics_RouterInfo_Send_Successed] boolValue])
                {
                    [list release];
                    PrintObj(@"RouterInfo had been sended");
                    [routerMac release];
                    lock_sent_routerinfo = status_unlocked;
                    return;
                }
                else
                {
                    [list removeObject:routerInfoDic];//防止同一个路由器的信息多次被写入
                    break;
                }
            }
        }
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        NSString * info=[NSString stringWithFormat:@"/R?RM=%@&PM=%@&SN=%@&MN=%@&FV=%@",routerMac, localMac, routerSN,routerModelName,routerFirmware];
        BOOL send_successed = NO;
        NSURL * url = [[[NSURL alloc] initWithScheme:@"http" 
                                                host:[NSString stringWithFormat:@"%@:%d",statistics_server,80]
                                                path:info] autorelease];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        PrintObj(@"sending data");
        [theRequest setTimeoutInterval:timeout_sendRouterInfo];
        NSError * error = nil;	
        [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:&error];
        if (!error)
        {
            PrintObj(@"sendStatistics_RouterInfo successed");
            send_successed = YES;
        }
        
        NSMutableDictionary * d = [[NSMutableDictionary alloc] init];
        [d setObject:[NSNumber numberWithBool:send_successed] forKey:key_Statistics_RouterInfo_Send_Successed];
        [d setObject:routerMac forKey:key_Statistics_RouterInfo_RouterMac];
        [routerMac release];
        [list addObject:d];
        [d release];
        [GenieHelper write:[NSDictionary dictionaryWithObject:list forKey:key_Statistics_RouterInfo_List] toFile:Genie_File_Statistics_Router_Info];
        [list release];
        [pool release]; 
        
        lock_sent_routerinfo = status_unlocked;
    });
}

@end
