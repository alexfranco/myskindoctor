//
//  SkinProblemLocationViewController.swift
//  MySkinDoctor
//
//  Created by Alex on 28/02/2018.
//  Copyright © 2018 TouchSoft. All rights reserved.
//

import Foundation
import UIKit

class SkinProblemLocationViewController: FormViewController {
	
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var bodyImageView: UIImageView!
	@IBOutlet weak var locationHeadButton: UIButton!
	@IBOutlet weak var locationNeckButton: UIButton!
	@IBOutlet weak var locationChestButton: UIButton!
	@IBOutlet weak var locationBellyButton: UIButton!
	@IBOutlet weak var locationUpperArmLeftButton: UIButton!
	@IBOutlet weak var locationUpperArmRightButton: UIButton!
	@IBOutlet weak var locationLowerArmLeftButton: UIButton!
	@IBOutlet weak var locationLowerArmRightButton: UIButton!
	@IBOutlet weak var locationPelvisButton: UIButton!
	@IBOutlet weak var locationUpperLegLeftButton: UIButton!
	@IBOutlet weak var locationUpperLegRightButton: UIButton!
	@IBOutlet weak var locationLowerLegLeftButton: UIButton!
	@IBOutlet weak var locationLowerLegRightButton: UIButton!
	@IBOutlet weak var locationFootLeftButton: UIButton!
	@IBOutlet weak var locationFootRightButton: UIButton!
	@IBOutlet weak var bodyLeftButton: UIButton!
	@IBOutlet weak var bodyRightButton: UIButton!
	
	var viewModelCast: SkinProblemLocationViewModel!
	var locationButtons: [UIButton]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.setBackgroundColorWithoutShadowImage(bgColor: AppStyle.locationNavigationBarBackgroundColor, titleColor: AppStyle.locationTextColor)
		
		view.backgroundColor = AppStyle.locationBackgroundColor
		locationLabel.textColor = AppStyle.locationTextColor
		tipLabel.textColor = AppStyle.locationTextColor
		
		viewModelCast.isFrontSelected = true
		locationLabel.text = viewModelCast.problemLocationText

		configureLocationButtons()
		
		self.nextButton.isEnabled = false
	}

	override func initViewModel(viewModel: BaseViewModel) {
		super.initViewModel(viewModel: viewModel)
		
		viewModelCast = (viewModel as! SkinProblemLocationViewModel)
		
		viewModelCast.bodyImageChanged = { [] (isFrontSelected, bodyImage) in
			DispatchQueue.main.async {
				self.bodyImageView.image = bodyImage
			}
		}
		
		viewModelCast.locationProblemUpdated = { [] (locationProblemType) in
			DispatchQueue.main.async {
				self.nextButton.isEnabled = true
				self.selectLocationButton(locationProblemType: locationProblemType)
				self.locationLabel.text = self.viewModelCast.problemLocationText
			}
		}
		
		viewModelCast.goNextSegue = { [] () in
			DispatchQueue.main.async {
				self.performSegue(withIdentifier: Segues.unwindToAddSkinProblems, sender: nil)
			}
		}
	}
	
	func selectLocationButton(locationProblemType: SkinProblemAttachment.LocationProblemType) {
		for button in locationButtons {
			button.isSelected = button.tag == locationProblemType.index
		}
	}

	
	// MARK: Helpers
		
	func configureLocationButtons() {
		locationHeadButton.tag = SkinProblemAttachment.LocationProblemType.head.index
		locationNeckButton.tag = SkinProblemAttachment.LocationProblemType.neck.index
		locationChestButton.tag = SkinProblemAttachment.LocationProblemType.chest.index
		locationBellyButton.tag = SkinProblemAttachment.LocationProblemType.belly.index
		locationUpperArmLeftButton.tag = SkinProblemAttachment.LocationProblemType.upperArmLeft.index
		locationUpperArmRightButton.tag = SkinProblemAttachment.LocationProblemType.upperArmRight.index
		locationLowerArmLeftButton.tag = SkinProblemAttachment.LocationProblemType.lowerArmLeft.index
		locationLowerArmRightButton.tag = SkinProblemAttachment.LocationProblemType.lowerArmRight.index
		
		locationPelvisButton.tag = SkinProblemAttachment.LocationProblemType.pelvis.index
		locationUpperLegLeftButton.tag = SkinProblemAttachment.LocationProblemType.upperLegLeft.index
		locationUpperLegRightButton.tag = SkinProblemAttachment.LocationProblemType.upperLegRight.index
		locationLowerLegLeftButton.tag = SkinProblemAttachment.LocationProblemType.lowerLegLeft.index
		locationLowerLegRightButton.tag = SkinProblemAttachment.LocationProblemType.lowerLegRight.index
		locationFootLeftButton.tag = SkinProblemAttachment.LocationProblemType.footLeft.index
		locationFootRightButton.tag = SkinProblemAttachment.LocationProblemType.footRight.index
		
		locationButtons = [locationHeadButton,
						   locationNeckButton,
						   locationChestButton,
						   locationBellyButton,
						   locationUpperArmLeftButton,
						   locationUpperArmRightButton,
						   locationLowerArmLeftButton,
						   locationLowerArmRightButton,
						   locationPelvisButton,
						   locationUpperLegLeftButton,
						   locationUpperLegRightButton,
						   locationLowerLegLeftButton,
						   locationLowerLegRightButton,
						   locationFootLeftButton,
						   locationFootRightButton]
	}
	
	@IBAction func onBodyLrftButtonPressed(_ sender: Any) {
		viewModelCast.isFrontSelected = true
	}
	
	@IBAction func onBodyRightButtonPressed(_ sender: Any) {
		viewModelCast.isFrontSelected = false
	}
	
	@IBAction func onLocationPressed(_ sender: Any) {
		if let button = sender as? UIButton {
			button.isSelected = true
			let locationProblemRawValue = button.tag
			viewModelCast.locationProblemType = SkinProblemAttachment.LocationProblemType(rawValue: locationProblemRawValue)!
		}
	}
		
	@IBAction func onNextButtonPressed(_ sender: Any) {
		viewModelCast.saveModel()
	}
}
