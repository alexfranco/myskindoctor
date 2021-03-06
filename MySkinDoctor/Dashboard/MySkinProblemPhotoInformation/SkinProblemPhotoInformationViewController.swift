//
//  SkinProblemPhotoInformationViewController.swift
//  MySkinDoctor
//
//  Created by Alex on 28/02/2018.
//  Copyright © 2018 TouchSoft. All rights reserved.
//

import Foundation
import UIKit

class SkinProblemPhotoInformationViewController: PhotoViewController {

	var viewModelCast : SkinProblemPhotoInformationViewModel!
	
	@IBOutlet weak var editButton: UIButton!
	@IBOutlet weak var skinBodyOptionButton: UIButton!
	@IBOutlet weak var documentOptionButton: UIButton!
	@IBOutlet weak var skinBodyInfoLabel: UILabel!
	@IBOutlet weak var documentInfoLabel: UILabel!
	
	@IBOutlet weak var descriptionTextView: FormTextView! {
		didSet {
			descriptionTextView.bind { self.viewModelCast.problemDescription = $0 }
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
		
		descriptionTextView.placeholder = "Please enter here a description of your problem"
		userPhotoImageView.image = viewModelCast.problemImage
		
		editButton.setTitleColor(AppStyle.addSkinPhotoEditTextColor, for: .normal)
		
		skinBodyOptionButton.backgroundColor = AppStyle.addSkinPhotoBodyButtonBackgroundColor
		documentOptionButton.backgroundColor = AppStyle.addSkinPhotoDocumentButtonBackgroundColor
		
		skinBodyOptionButton.setRounded()
		documentOptionButton.setRounded()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.setBackgroundColorWithoutShadowImage(bgColor: AppStyle.defaultNavigationBarColor, titleColor: AppStyle.defaultNavigationBarTitleColor)
		navigationController?.title = NSLocalizedString("skinproblem_main_vc_title", comment: "")
	}

	// MARK: Helpers
	
	override func initViewModel(viewModel: BaseViewModel) {
		super.initViewModel(viewModel: viewModel)
		
		viewModelCast = viewModel as? SkinProblemPhotoInformationViewModel
		
		viewModelCast.goPhotoLocation = { [] () in
			DispatchQueue.main.async {
				self.performSegue(withIdentifier: Segues.goToSkinProblemLocationViewController, sender: nil)
			}
		}
		
		viewModelCast.unwind = { [] () in
			DispatchQueue.main.async {
				self.performSegue(withIdentifier: Segues.unwindToAddSkinProblemsFromPhoto, sender: nil)
			}
		}
	}
	
	// MARK: IBAction
	
	@IBAction func onEditUserProfilePressed(_ sender: Any) {
		tapUserPhoto(nil)
	}
	
	@IBAction func onBodyOptionPressed(_ sender: Any) {
		viewModelCast.saveModel(attachmentType: .photo)
	}
	
	@IBAction func onDocumentOptionPressed(_ sender: Any) {
		viewModelCast.saveModel(attachmentType: .document)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Segues.goToSkinProblemLocationViewController {
			if let dest = segue.destination as? SkinProblemLocationViewController {
				dest.initViewModel(viewModel: SkinProblemLocationViewModel(model:  viewModelCast.model))
			}
		}
	}
}

extension SkinProblemPhotoInformationViewController: PhotoViewControllerDelegate {
	
	func photoViewController(_ photoViewController: PhotoViewController, imageChanged: UIImage) {
		viewModelCast.problemImage = imageChanged
	}
}

