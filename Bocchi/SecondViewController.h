//
//  SecondViewController.h
//  Bocchi
//
//  Created by Osamu Noguchi on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
    IBOutlet UINavigationItem *navigationItem;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;

@end
