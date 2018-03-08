//
//  SkinProblemPhotoInformationViewModel.swift
//  MySkinDoctor
//
//  Created by Alex on 28/02/2018.
//  Copyright © 2018 TouchSoft. All rights reserved.
//

import Foundation
import UIKit

class SkinProblemPhotoInformationViewModel: BaseViewModel {
	
	var model: SkinProblemModel!
	var problemDescription: String!
	var problemImage: UIImage!
	
	required init(model: SkinProblemModel) {
		self.model = model
		self.problemDescription = model.problemDescription
		self.problemImage = model.problemImage == nil ? UIImage(named: "logo")! : model.problemImage! // TODO change it to a default image
	}
	
	func saveModel() {
		model.problemDescription = problemDescription
		model.problemImage = problemImage
		goNextSegue!()
	}
	
}