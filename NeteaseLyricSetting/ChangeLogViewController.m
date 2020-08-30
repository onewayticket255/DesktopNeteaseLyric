#import "ChangeLogViewController.h"

@implementation ChangeLogViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.releases == NULL) {
        self.releases = [NSMutableArray new];
        [self fetchGithubReleases];
    }
}

- (void)fetchGithubReleases {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:@"https://api.github.com/repos/onewayticket255/DesktopNeteaseLyric/releases"]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSMutableArray *allReleases = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

            for (NSDictionary *release in allReleases) {
                [self.releases addObject:release];           
            }

        }
        else {
            NSLog(@"mlyx FetchGithubApi Error");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [task resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.releases.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"changeLogCell";
    NSDictionary *dataDict = self.releases[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (dataDict[@"body"]) {
        [cell.textLabel setText:dataDict[@"body"]];
    }
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *jsonDict = self.releases[section];
    return jsonDict[@"name"] ?: @"Error";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"alphabeticalReuse"];
    view.textLabel.font = [UIFont boldSystemFontOfSize:15];      
    return view;
}

@end