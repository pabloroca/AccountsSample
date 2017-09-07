//
//  AccountsViewController.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel: AccountsViewModel!
    
    //MARK: - Views
    
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    //MARK: - Init
    
    init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AccountsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        showRightButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureUI() {
        tableView.dataSource = self
        tableView.register(AccountTableViewCell.self)
        tableView.estimatedRowHeight = Constants.cellsRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.addSubview(self.refreshControl)
        view.backgroundColor = .white
        viewIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = NSLocalizedString("AccountsTitle", comment: "")
    }
    
    //MARK: - UI Actions
    
    @objc private func rightButtonAction() {
        viewModel.changeshowOnlyVisibleAccounts()
        showRightButton()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    //MARK: - Custom methods
    
    private func refreshData() {
        viewIndicator.isHidden = false
        viewModel.readData {[unowned self] (success) in
            self.viewIndicator.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    private func showRightButton() {
        var button1: UIBarButtonItem
        if viewModel.showOnlyVisibleAccounts {
            button1 = UIBarButtonItem(image: UIImage(named: "star"), style: .plain, target: self, action: #selector(rightButtonAction))
        } else {
            button1 = UIBarButtonItem(image: UIImage(named: "eye"), style: .plain, target: self, action: #selector(rightButtonAction))
        }
        navigationItem.rightBarButtonItem = button1
        refreshData()
    }
}

//MARK: - UITableViewDataSource

extension AccountsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as AccountTableViewCell
        let row = viewModel.row(at: indexPath)
        
        cell.configure(viewModel: row)
        return cell
    }
    
}
