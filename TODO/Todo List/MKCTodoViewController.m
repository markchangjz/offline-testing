#import "MKCTodoViewController.h"
#import "MKCTodoViewModel.h"

@interface MKCTodoViewController () <UITableViewDelegate, UITableViewDataSource, MKCTodoViewModelDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIBarButtonItem *refreshBarButtonItem;
@property (strong, nonatomic) MKCTodoViewModel *todoViewModel;

@end

@implementation MKCTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self in_configureView];
    [self.todoViewModel fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.todoViewModel.numberOfCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.numberOfLines = 0;
    }
    
    MKCTodoCellViewModel *cellViewModel = [self.todoViewModel cellViewModelAtIndexPath:indexPath];
    cell.textLabel.text = cellViewModel.title;
    cell.accessoryType = cellViewModel.completed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private function

- (void)in_configureView {
    self.title = @"TODO";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    // refresh button
    self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem;
    
    // activity indicator view
    [self.view addSubview:self.activityIndicatorView];
    
    [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    // table view
    [self.view addSubview:self.tableView];
    
    NSArray *tableViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:@{@"tableView": self.tableView}];
    NSArray *tableViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-|" options:0 metrics:nil views:@{@"tableView": self.tableView}];
    [self.view addConstraints:tableViewHorizontalConstraints];
    [self.view addConstraints:tableViewVerticalConstraints];
}

#pragma mark - MKCTodoViewModelDelegate

- (void)updateLoadingState {
    UIState state = self.todoViewModel.currentUiState;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case UIStateLoading:
            {
                [self.activityIndicatorView startAnimating];
                self.tableView.alpha = 0.0;
            }
                break;
            case UIStateFinish:
            {
                [self.tableView reloadData];
                [self.activityIndicatorView stopAnimating];
                self.tableView.alpha = 1.0;
            }
                break;
            case UIStateError:
            {
                [self.activityIndicatorView stopAnimating];
                self.tableView.alpha = 0.0;
            }
                break;
        }
    });
}

- (void)showErrorMessageWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - IBAction

- (void)reloadData:(UIBarButtonItem *)sender {
    [self.todoViewModel fetchData];
}

#pragma mark - lazy instance

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 20.0;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _activityIndicatorView;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData:)];
    }
    return _refreshBarButtonItem;
}

- (MKCTodoViewModel *)todoViewModel {
    if (!_todoViewModel) {
        _todoViewModel = [[MKCTodoViewModel alloc] init];
        _todoViewModel.delegate = self;
    }
    return _todoViewModel;
}

@end
