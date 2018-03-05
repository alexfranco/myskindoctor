//
//  MyConsultsViewController.swift
//  MySkinDoctor
//
//  Created by Alex on 05/03/2018.
//  Copyright © 2018 TouchSoft. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit

class MyConsultsViewController: BindingViewController {
	
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	
	var viewModelCast: MyConsultsViewModel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		title = NSLocalizedString("myskinproblems_main_vc_title", comment: "")
//
//		diagnosesSegmentedControl.setTitle(NSLocalizedString("myskinproblems_segmented_all", comment: ""), forSegmentAt: MySkinProblemsViewModel.DiagnosesSegmentedEnum.all.rawValue)
//		diagnosesSegmentedControl.setTitle(NSLocalizedString("myskinproblems_segmented_undiagnosed", comment: ""), forSegmentAt: MySkinProblemsViewModel.DiagnosesSegmentedEnum.undiagnosed.rawValue)
//		diagnosesSegmentedControl.setTitle(NSLocalizedString("myskinproblems_segmented_diagnosed", comment: ""), forSegmentAt: MySkinProblemsViewModel.DiagnosesSegmentedEnum.diagnosed.rawValue)
//
		navigationController?.setBackgroundColorWithoutShadowImage(bgColor: AppStyle.defaultNavigationBarColor, titleColor: AppStyle.defaultNavigationBarTitleColor)
		
		configureTableView()
		
		initViewModel(viewModel: MyConsultsViewModel())
	}
	
	// MARK: Helpers
	
	override func initViewModel(viewModel: BaseViewModel) {
		super.initViewModel(viewModel: viewModel)
		
		viewModelCast = viewModel as! MyConsultsViewModel
		
		viewModelCast.refresh = { [weak self] () in
			DispatchQueue.main.async {
				self?.tableView.reloadData()
				self?.tableView.refreshControl?.endRefreshing()
			}
		}
	}
	
	func configureTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		
		tableView.estimatedRowHeight = 80.0
		tableView.rowHeight = UITableViewAutomaticDimension
		
		let refreshControl = UIRefreshControl()
		refreshControl.backgroundColor = UIColor.clear
		refreshControl.tintColor = UIColor.black
		tableView.refreshControl =  refreshControl
		tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
	}
	
	@objc func handleRefresh(refreshControl: UIRefreshControl) {
		viewModelCast.refreshData()
	}
	
	// MARK: IBAction
	
	@IBAction func onSegmentedControlValueChanged(_ sender: Any) {
//		viewModelCast.selectedSegmented = MySkinProblemsViewModel.DiagnosesSegmentedEnum(rawValue: self.diagnosesSegmentedControl.selectedSegmentIndex)!
	}
	
	
	// MARK: Segues
	
	@IBAction func unwindToMySkinProblems(segue:UIStoryboardSegue) {
	}
	
}

extension MyConsultsViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: UITableView
	
	func numberOfSections(in tableView: UITableView) -> Int {
		let numOfSections = viewModelCast.getNumberOfSections()
		
		if numOfSections == 0 {
			let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
			noDataLabel.text          = NSLocalizedString("myskinproblems_no_data", comment: "")
			noDataLabel.textColor     = UIColor.black
			noDataLabel.textAlignment = .center
			tableView.backgroundView  = noDataLabel
			tableView.separatorStyle  = .none
		} else {
			tableView.separatorStyle = .singleLine
			tableView.backgroundView = nil
		}
		
		return numOfSections
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModelCast.getDataSourceCount(section: section)
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return viewModelCast.getSectionTitle(section: section)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let headerView = (view as! UITableViewHeaderFooterView)
		
		headerView.backgroundView?.backgroundColor = AppStyle.consultTableViewHeaderBGColor
		headerView.textLabel?.textColor = AppStyle.consultTableViewCellTextColor
		headerView.textLabel?.font = AppStyle.consultTableSectionTextFont
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CellId.myConsultTableViewCellId) as! MyConsultTableViewCell
		
		let viewModel = viewModelCast.getItemAtIndexPath(indexPath: indexPath)
		cell.configure(withViewModel: MyConsultTableViewCellViewModel(model: viewModel))
		
		return cell
	}
}
