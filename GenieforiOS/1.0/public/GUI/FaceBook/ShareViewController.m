//
//  ShareViewController.m
//  GenieiPad
//
//  Created by siteview siteview on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"popController list";
    listArray = [[NSArray alloc]initWithObjects:@"Twitter",@"FaceBook",@"Sina weibo", nil];
//    UIActionSheet *shareList = [[UIActionSheet alloc]
//                                initWithTitle:nil
//                                delegate:self
//                                cancelButtonTitle:nil
//                                destructiveButtonTitle:@"Close"
//                                otherButtonTitles:nil,
//                                nil];
//    [shareList addButtonWithTitle:@"About Genie"];
//    [shareList addButtonWithTitle:@"Share to FaceBook"];
//    [shareList addButtonWithTitle:@"Share to Twitter"];
//    
//    [shareList addButtonWithTitle:@"Share to Google+"];
//    [shareList addButtonWithTitle:@"Share to Yahoo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    [shareList addButtonWithTitle:@"Share to Sina weibo"];
//    
////    
//    shareList.actionSheetStyle=UIActionSheetStyleDefault;
//    [self.view addSubview:shareList];
//    //    shareList.cancelButtonIndex=shareList.numberOfButtons-1;
//    
//    [shareList showFromToolbar:self.navigationController.toolbar];
//    [shareList release];

    // Do any additional setup after loading the view from its nib.
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellID = [NSString stringWithFormat:@"cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
    }
    
    cell.textLabel.text=[listArray objectAtIndex:indexPath.row];
//    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fg.jpg"]];
    cell.imageView.image=[UIImage imageNamed:@"fb.jpg"];
//    [self customCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    
    if (buttonIndex ==1) {
        [self showSpecialAlertViewForShowAboutInfo];
        
    }
    else if (buttonIndex ==2) {
        [self handleFaceBook];
    }
    else if (buttonIndex ==3) {
        [self handleTwitter];
    }
    else {
        //        [actionSheet cancelButtonIndex];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [super dealloc];
    [listArray release];
}

@end
