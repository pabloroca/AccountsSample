//
//  TodayViewController.swift
//  INGAccountsToday
//
//  Created by Pablo Roca Rozas on 22/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    //MARK: - Properties
    
    var viewModel: AccountsViewModel!
    
    //MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = AccountsViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureUI() {
        extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded

        tableView.dataSource = self
        tableView.register(AccountTableViewCell.self)
        tableView.estimatedRowHeight = Constants.cellsRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()

        view.backgroundColor = .white
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        refreshData()

        completionHandler(NCUpdateResult.newData)
    }
    
    //MARK: - Custom methods
    
    private func refreshData() {
        viewModel.readData {[unowned self] (success) in
            self.tableView.reloadData()
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize;
        }
        else {
            self.preferredContentSize = CGSize(width: 0, height: 140);
        }
    }
}

//MARK: - UITableViewDataSource

extension TodayViewController: UITableViewDataSource {
    
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
