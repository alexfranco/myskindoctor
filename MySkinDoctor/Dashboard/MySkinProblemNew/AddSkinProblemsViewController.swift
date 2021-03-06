//
//  AddSkinProblemsViewController.swift
//  MySkinDoctor
//
//  Created by Alex on 26/02/2018.
//  Copyright © 2018 TouchSoft. All rights reserved.
//

import Foundation
import UIKit

class AddSkinProblemsViewController: BindingViewController {
	
	@IBOutlet weak var undiagnosedStatusView: UIView!
	@IBOutlet weak var undiagnosedImageView: UIImageView!
	@IBOutlet weak var undiagnosedViewHeight: NSLayoutConstraint!
	@IBOutlet weak var undiagnosedInfoLabel: UILabel!
	
	@IBOutlet weak var diagnosedStatusView: UIView!
	@IBOutlet weak var diagnosedImageView: UIImageView!
	@IBOutlet weak var diagnosedViewHeight: NSLayoutConstraint!
	@IBOutlet weak var diagnosedInfoLabel: UILabel!
	@IBOutlet weak var diagnosedViewButton: UIButton!
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var descriptionLabel: GrayLabel!
	@IBOutlet weak var descriptionLabelTop: NSLayoutConstraint!
	
	@IBOutlet weak var descriptionTextView: FormTextView! {
		didSet {
			descriptionTextView.bind { self.viewModelCast.skinProblemDescription = $0 }
		}
	}
	
	var photoUtils: PhotoUtils!
	var viewModelCast: AddSkinProblemsViewModel!
	
	let diagnosedViewHeightDefault = CGFloat(80)
	let descriptionLabelTopDefault = CGFloat(5)
	
	override func initViewModel(viewModel: BaseViewModel) {
		super.initViewModel(viewModel: viewModel)
		
		viewModelCast = viewModel as? AddSkinProblemsViewModel
		
		viewModelCast.diagnosedStatusChanged = { [weak self] (status) in
			DispatchQueue.main.async {
				self?.reloadUI()
				self?.showHideDiagnoseViews()
			}
		}
		
		viewModelCast.tableViewStageChanged = { [weak self] (tableViewState) in
			DispatchQueue.main.async {
				switch tableViewState {
				case .none:
					self?.tableView.reloadData()
				case let .insert(_, indexPath):
					self?.tableView.beginUpdates()
					self?.tableView.insertRows(at: [indexPath], with: .automatic)
					self?.tableView.endUpdates()
				case let .delete(indexPath):
					self?.tableView.beginUpdates()
					self?.tableView.deleteRows(at: [indexPath], with: .automatic)
					self?.tableView.endUpdates()
				}
			}
		}
		
		viewModelCast.updateNextButton = { [weak self] (isEnabled) in
			DispatchQueue.main.async {
				self?.nextButton.isEnabled = isEnabled
			}
		}
		
		viewModelCast.refresh = { [weak self] () in
			DispatchQueue.main.async {
				self?.tableView.reloadData()
			}
		}
		
		viewModelCast.goNextSegue = { [weak self] () in
			DispatchQueue.main.async {
				self?.performSegue(withIdentifier: (self?.viewModelCast.nextSegue)!, sender: nil)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		photoUtils = PhotoUtils.init(inViewController: self)
		
		descriptionTextView.placeholder = "Please enter the description of your skin problem, click on Add Photo"
		
		nextButton.isEnabled = false
		
		configureTableView()
		configureDiagnoseView()

		reloadUI()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.setBackgroundColorWithoutShadowImage(bgColor: AppStyle.defaultNavigationBarColor, titleColor: AppStyle.defaultNavigationBarTitleColor)
		navigationController?.title = NSLocalizedString("Add Skin Problem", comment: "")
	}
	
	// MARK: Helpers
	
	func configureTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		
		tableView.estimatedRowHeight = 80.0
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
	func configureDiagnoseView() {
		undiagnosedStatusView.backgroundColor = viewModelCast.infoViewBackground
		undiagnosedInfoLabel.textColor = AppStyle.addSkinProblemInfoViewTextColor
		
		diagnosedStatusView.backgroundColor = viewModelCast.infoViewBackground
		diagnosedInfoLabel.textColor = AppStyle.addSkinProblemInfoViewTextColor
		diagnosedViewButton.setTitleColor(AppStyle.addSkinProblemInfoViewTextColor, for: .normal)
	}
	
	func reloadUI() {
		// fill in values
		title = viewModelCast.navigationTitle
		
		descriptionTextView.isEditable = viewModelCast.isEditEnabled
		descriptionTextView.text = viewModelCast.skinProblemDescription
		undiagnosedInfoLabel.text = viewModelCast.diagnoseInfoText
		diagnosedInfoLabel.text = viewModelCast.diagnoseInfoText
		
		// if we are in no edit mode, we don't need to show the place holder here.
		if !viewModelCast.isEditEnabled {
			descriptionTextView.placeholder = ""
		}
		
		showHideDiagnoseViews()
		nextButton.isHidden = !viewModelCast.isEditEnabled
		
		tableView.reloadData()
	}
	
	func showHideDiagnoseViews() {
		descriptionLabelTop.constant = viewModelCast.diagnoseStatus == .none ? descriptionLabelTopDefault : descriptionLabelTopDefault + diagnosedViewHeightDefault
		
		undiagnosedViewHeight.constant = viewModelCast.diagnoseStatus == .pending ? diagnosedViewHeightDefault : 0
		undiagnosedImageView.isHidden = viewModelCast.diagnoseStatus != .pending
		undiagnosedInfoLabel.isHidden = viewModelCast.diagnoseStatus != .pending
		
		diagnosedViewHeight.constant = viewModelCast.isDiagnosed ? diagnosedViewHeightDefault : 0
		diagnosedImageView.isHidden = !viewModelCast.isDiagnosed
		diagnosedInfoLabel.isHidden = !viewModelCast.isDiagnosed
		diagnosedViewButton.isHidden = !viewModelCast.isDiagnosed
	}
	
	@IBAction func onNextButtonPressed(_ sender: Any) {
		viewModelCast.saveModel()
	}
	
	@IBAction func onViewDiagnosePressed(_ sender: Any) {
		self.performSegue(withIdentifier: viewModelCast.diagnoseNextSegue, sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Segues.goToSkinProblemPhotoInformationViewController {
		if let dest = segue.destination as? SkinProblemPhotoInformationViewController, let image = sender as? UIImage {
				let skinProblem = DataController.createNew(type: SkinProblemAttachment.self)
				skinProblem.problemImage = image
				dest.initViewModel(viewModel: SkinProblemPhotoInformationViewModel(model:  skinProblem))
			}
		} else if segue.identifier == Segues.goToDiagnosis {
			if let dest = segue.destination as? MySkinProblemDiagnosisViewController {
				dest.initViewModel(viewModel: MySkinProblemDiagnosisViewModel(model:  viewModelCast.model))
			}
		} else if segue.identifier == Segues.goToMySkinProblemDiagnoseUpdateRequest {
			if let dest = segue.destination as? MySkinProblemDiagnoseUpdateRequestViewController {
				dest.initViewModel(viewModel: MySkinProblemDiagnoseUpdateRequestViewModel(model:  viewModelCast.model))
			}
		}
	}
	
	// MARK: Unwind
	
	@IBAction func unwindToAddSkinProblems(segue: UIStoryboardSegue) {
		if let sourceViewController = segue.source as? SkinProblemLocationViewController {
			if let viewModel = sourceViewController.viewModelCast {				
				viewModelCast.appendNewModel(model: viewModel.model)
			}
		}
	}
	
	@IBAction func unwindToAddSkinProblemsFromPhoto(segue: UIStoryboardSegue) {
		if let sourceViewController = segue.source as? SkinProblemPhotoInformationViewController {
			if let viewModel = sourceViewController.viewModelCast {
				viewModelCast.appendNewModel(model: viewModel.model)
			}
		}
	}
	
}

extension AddSkinProblemsViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: UITableView
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModelCast.getNumberOfSections()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModelCast.getDataSourceCount()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if viewModelCast.isAddPhotoRow(indexPath: indexPath) {
			let cell = tableView.dequeueReusableCell(withIdentifier: CellId.addPhotoTableViewCellId) as! AddPhotoTableViewCell
			cell.configure(isFirstPhoto: viewModelCast.getDataSourceCount() == 1)
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: CellId.skinProblemTableViewCellId) as! SkinProblemTableViewCell
			let cellViewModel = SkinProblemTableCellViewModel(withModel: viewModelCast.getItemAtIndexPath(indexPath: indexPath), index: indexPath.row)
			cell.configure(withViewModel: cellViewModel)
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if viewModelCast.isAddPhotoRow(indexPath: indexPath) {
			// click on add photo
			photoUtils.showChoosePhoto { (success, image) in
				if success {
					self.performSegue(withIdentifier: Segues.goToSkinProblemPhotoInformationViewController, sender: image)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return viewModelCast.canEditRow(indexPath: indexPath)
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		viewModelCast.removeModel(at: indexPath)
	}
}

