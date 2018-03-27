//
//  AddSkinProblemsViewModel.swift
//  MySkinDoctor
//
//  Created by Alex Núñez on 27/02/2018.
//  Copyright © 2018 TouchSoft. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddSkinProblemsViewModel: BaseViewModel {
	
	private(set) var model: SkinProblems?
	var skinProblemDescription = ""

	// Bind properties
	var refresh: (()->())?
	var onModelDiscarted: (()->())?
	var tableViewStageChanged: ((_ state: EditingStyle)->())?
	var updateNextButton: ((_ isEnabled: Bool)->())?
	var diagnosedStatusChanged: ((_ state: Diagnose.DiagnoseStatus)->())?
	var onSkinProblemAttachmentImageAdded: ((_ skinProblemAttachment: SkinProblemAttachment)->())?
	var onSaveLaterSuccess: (()->())?
	
	private(set) var tableViewState: EditingStyle = EditingStyle.none {
		didSet {
			guard let model = self.model else { return }
			
			switch tableViewState {
			case let .insert(new, _):
				let skinProblemAttachment = new
				model.addToAttachments(skinProblemAttachment)
			case let .delete(indexPath):
				if let attachment = model.attachments?.allObjects[indexPath.row] {
					model.removeFromAttachments(attachment as! SkinProblemAttachment)
					DataController.deleteManagedObject(managedObject: (attachment as! SkinProblemAttachment))
				}
			default:
				break
			}
			
			tableViewStageChanged!(tableViewState)
		}
	}
	
	required init(modelId: NSManagedObjectID?) {
		super.init()
		
		if modelId == nil {
			createModel()
		} else {
			self.model = DataController.getManagedObject(managedObjectId: modelId!) as? SkinProblems
		}
		
		loadDBModel()
	}
	
	func createModel() {
		isLoading = true
		
		ApiUtils.createSkinProblem(accessToken: DataController.getAccessToken()) { (result) in
			
			self.isLoading = false
			
			switch result {
			case .success(let model):
				print("createSkinProblem")
				
				let modelCast =  model as! SkinProblemsResponseModel
				self.model = SkinProblems.parseAndSaveResponse(skinProblemResponseModel: modelCast)
				self.refresh!()
			case .failure(let model, let error):
				print("error")
				self.showResponseErrorAlert!(model as? BaseResponseModel, error)
			}
		}
	}
	
	override func loadDBModel() {
		super.loadDBModel()

		guard let model = self.model else { return }
		
		self.skinProblemDescription = model.skinProblemDescription	?? "-"
	}
	
	func saveModel(saveLater: Bool = false) {
		guard let model = self.model else { return }
		
		isLoading = true
		ApiUtils.updateSkinProblems(accessToken: DataController.getAccessToken(), skinProblemsId: Int(model.skinProblemId), skinProblemsDescription: skinProblemDescription, healthProblems: nil, medications: nil, history: nil) { (result) in
			self.isLoading = false
			
			switch result {
			case .success(let model):
				print("updateSkinProblems")
				let _ = SkinProblems.parseAndSaveResponse(skinProblemResponseModel: model as! SkinProblemsResponseModel)
				
				if saveLater {
					self.onSaveLaterSuccess!()
				} else {
					self.goNextSegue!()
				}
			case .failure(let model, let error):
				print("error")
				self.isLoading = false
				self.showResponseErrorAlert!(model as? BaseResponseModel, error)
			}
		}
	}
	
	func discardModel() {
		guard let model = self.model else { return }
		
		isLoading = true
		
		ApiUtils.deleteSkinProblem(accessToken: DataController.getAccessToken(), skinProblemsId: Int(model.skinProblemId)) { (result) in
			self.isLoading = false
			
			switch result {
			case .success(_):
				print("deleteSkinProblems")
				DataController.deleteManagedObject(managedObject: model)
				self.onModelDiscarted!()
			case .failure(let model, let error):
				print("error")
				self.showResponseErrorAlert!(model as? BaseResponseModel, error)
			}
		}
	}
	
	func insertNewModel(model: SkinProblemAttachment, indexPath: IndexPath) {
		tableViewState = .insert(model, indexPath)
		updateNextButton!(nextButtonIsEnabled)
	}
	
	func appendAttachment(skinProblemAttachment: SkinProblemAttachment) {
		guard let model = self.model else { return }
		
		isLoading = true
		
		ApiUtils.createSkinProblemAttachment(accessToken: DataController.getAccessToken(), skinProblemsId: Int(model.skinProblemId), location: skinProblemAttachment.locationType, filename: skinProblemAttachment.filename, description: skinProblemAttachment.problemDescription, attachmentType:Int(skinProblemAttachment.attachmentType), completionHandler: { (result) in
			self.isLoading = false
			
			switch result {
			case .success(let model):
				print("createSkinProblemAttachment")
				let attachment = SkinProblemAttachment.parseAndSaveSkinProblemsAttachmentResponse(attachment: model as! SkinProblemAttachmentResponseModel)
				let appendToLastIndexPath = IndexPath.init(row: self.getDataSourceCountWithoutExtraAddPhoto(), section: 0)
				self.tableViewState = .insert(attachment, appendToLastIndexPath)
				self.updateNextButton!(self.nextButtonIsEnabled)
				
			case .failure(let model, let error):
				print("error")
				self.showResponseErrorAlert!(model as? BaseResponseModel, error)
			}
		})
	}
	
	func removeAttachment(at indexPath: IndexPath) {
		guard let model = self.model else { return }
		guard let attachment = getItemAtIndexPath(indexPath: indexPath) else { return }
		
		isLoading = true
		ApiUtils.deleteSkinProblemAttachment(accessToken: DataController.getAccessToken(), skinProblemsId: Int(model.skinProblemId), attachmentId: Int(attachment.skinProblemAttachmentId)) { (result) in
			self.isLoading = false
			
			switch result {
			case .success(_):
				print("deleteSkinProblemAttachment")
				self.tableViewState = .delete(indexPath)
				self.updateNextButton!(self.nextButtonIsEnabled)
			case .failure(let model, let error):
				print("error")
				self.showResponseErrorAlert!(model as? BaseResponseModel, error)
			}
		}
	}
	
	func createSkinProblemAttachment(image: UIImage) {
		let skinProblem = DataController.disconnectedEntity(type: SkinProblemAttachment.self)
		skinProblem.problemImage = image
		DataController.saveEntity(managedObject: skinProblem)
		onSkinProblemAttachmentImageAdded!(skinProblem)
	}
}

extension AddSkinProblemsViewModel {
	enum EditingStyle {
		case insert(SkinProblemAttachment, IndexPath)
		case delete(IndexPath)
		case none
	}
	
	var isEditEnabled: Bool {
		get {
			return diagnoseStatus == .draft
		}
	}
	
	var diagnoseStatus: Diagnose.DiagnoseStatus {
		get {
			guard let model = self.model else { return Diagnose.DiagnoseStatus.draft}
			
			guard let diagnose = model.diagnose else {
				return Diagnose.DiagnoseStatus.draft
			}
			
			return diagnose.diagnoseStatusEnum
		}
	}
	
	var isDiagnosed: Bool {
		get {
			guard let model = self.model else { return false}
			
			return model.isDiagnosed
		}
	}
	
	var navigationTitle: String {
		get {
			switch diagnoseStatus {
			case .unknown, .draft:
				return NSLocalizedString("addskinproblems_main_vc_title_none", comment: "")
			case .submitted:
				return NSLocalizedString("addskinproblems_main_vc_title_nodiagnosed", comment: "")
			case .noFutherCommunicationRequired:
				return NSLocalizedString("addskinproblems_main_vc_title_diagnosed", comment: "")
			case .bookConsultationRequest:
				return NSLocalizedString("addskinproblems_main_vc_title_diagnosed_update_request", comment: "")
			}
		}
	}
	
	var infoViewBackground: UIColor {
		get {
			switch diagnoseStatus {
			case .unknown, .draft:
				return UIColor.white
			case .submitted:
				return AppStyle.addSkinProblemUndiagnosedViewBackground
			case .noFutherCommunicationRequired:
				return AppStyle.addSkinProblemDiagnosedViewBackground
			case .bookConsultationRequest:
				return AppStyle.addSkinProblemDiagnosedUpdateRequestViewBackground
			}
		}
	}
	
	var nextButtonIsEnabled: Bool {
		get {
			guard let model = self.model else { return false }
			
			guard let attachments = model.attachments else {
				return true
			}
			
			return attachments.count > 0
		}
	}
	
	
	var diagnoseInfoText: String {
		get {
			switch diagnoseStatus {
			case .unknown, .draft:
				return "-"
			case .submitted:
				return generateNodiagnosedInfoText()
			case .noFutherCommunicationRequired:
				return generateDiagnosedInfoText()
			case .bookConsultationRequest:
				return generateDiagnosedFollowUpRequestInfoText()
			}
		}
	}
	
	var diagnoseNextSegue: String {
		get {
			switch diagnoseStatus {
			case .unknown, .draft:
				return ""
			case .submitted:
				return ""
			case .noFutherCommunicationRequired:
				return Segues.goToDiagnosis
			case .bookConsultationRequest:
				return Segues.goToMySkinProblemDiagnoseUpdateRequest
			}
		}
	}
	
	// MARK Helpers
	
	func refreshData() {
		updateNextButton!(nextButtonIsEnabled)
		refresh!()
	}
	
	func getDataSourceCount() -> Int {
		guard let model = self.model else { return 0 }
		
		guard let attachments = model.attachments else {
			return 0
		}
		
		var count = attachments.count
		
		if isEditEnabled {
			count += 1
		}
		
		return count
	}
	
	func getDataSourceCountWithoutExtraAddPhoto() -> Int {
		guard let model = self.model else { return 0 }
		
		guard let attachments = model.attachments else {
			return 0
		}
		
		return attachments.count
	}
	
	func getItemAtIndexPath(indexPath: IndexPath) -> SkinProblemAttachment? {
		guard let model = self.model else { return nil}
		
		return model.attachments?.allObjects[indexPath.row] as? SkinProblemAttachment
	}
	
	func getNumberOfSections() -> Int {
		return 1
	}
	
	func canEditRow(indexPath: IndexPath) -> Bool {
		if isEditEnabled {
			return !isAddPhotoRow(indexPath: indexPath)
		} else {
			return false
		}
	}
	
	func isAddPhotoRow(indexPath: IndexPath) -> Bool {
		if isEditEnabled {
			return getDataSourceCount() == indexPath.row + 1
		} else {
			return false
		}
	}
	
	private func generateNodiagnosedInfoText() -> String {
		return NSLocalizedString("addskinproblems_review", comment: "")
	}
	
	private func generateDiagnosedInfoText() -> String {
		
		guard let model = self.model else { return "-" }
		
		if let diagnose = model.diagnose,
			let doctor = diagnose.doctor,
			let doctorFirstName = doctor.firstName,
			let doctorLastName = doctor.lastName {
			let diagnoseDate = diagnose.diagnoseDate! as Date
			
			return String.init(format: "%@ %@ %@ %@.", doctorFirstName, doctorLastName, NSLocalizedString("addskinproblems_diagnosed", comment: ""),  diagnoseDate.ordinalMonthAndYear())
		} else {
			return "-"
		}
	}
	
	private func generateDiagnosedFollowUpRequestInfoText() -> String {
		return NSLocalizedString("addskinproblems_follow_up", comment: "")
	}
	
	func shouldShowCancelAlert() -> Bool {
		guard let model = self.model else { return false }
		guard let diagnose = model.diagnose else { return true }
		
		return diagnose.diagnoseStatusEnum == .draft
	}
}
