//
//  GenieItemListController.m
//  GenieiPhoneiPod
//
//  Created by cs Siteview on 12-4-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GenieItemListController.h"
#import "GenieGlobal.h"


@implementation GenieItemListController

- (id) initWithItmeList:(NSArray*)list andSelectedItem:(NSString*) item
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        m_items = [list retain];
        m_selectedItem = item;
        m_selectedRow = [m_items indexOfObject:m_selectedItem];
        if (m_selectedRow >= [m_items count] || m_selectedRow < 0)
        {
            m_selectedRow = 0;
            m_selectedItem = [m_items objectAtIndex:m_selectedRow];
        }
    }
    return self;
}

- (void) setModifyCallback:(id) target callback:(SEL) selector
{
    [m_target release];
    m_target = [target retain];
    m_selector = selector;
}
- (void)dealloc
{
    [m_target release];
    [m_items release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
#ifndef __GENIE_IPHONE__
    UIView * bg = [[UIView alloc] init];
    bg.backgroundColor = BACKGROUNDCOLOR;
    [self.tableView setBackgroundView:bg];
    [bg release];
#endif
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:m_selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSInteger index = [indexPath row];
    cell.textLabel.text = [m_items objectAtIndex:index];
#ifdef __GENIE_IPHONE__
    cell.textLabel.font = [UIFont systemFontOfSize:15];
#else
    cell.textLabel.font = [UIFont systemFontOfSize:16];
#endif
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (m_selectedRow == [indexPath row])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:m_selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == m_selectedRow)
    {
        return;
    }
    
    UITableViewCell* cell = nil;
    cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_selectedRow inSection:0]];
	cell.accessoryType = UITableViewCellAccessoryNone;	
    
	cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;	
    m_selectedRow = indexPath.row;
    m_selectedItem = [m_items objectAtIndex:m_selectedRow];
    
    [m_target performSelector:m_selector withObject:m_selectedItem];
}

@end
