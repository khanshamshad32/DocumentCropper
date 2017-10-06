//
//  ViewController.swift
//  PhotoCropper
//
//  Created by Shamshad Khan on 08/09/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		
	}

//	MARK: - IBAction
	
	@IBAction func onPickPhotoClick(_ sender: Any) {
		showActionSheet()
	}
	
//	MARK: - Private
	
	private func showActionSheet() {
	
		let picker = UIImagePickerController()
		picker.delegate = self
		
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
			
			let camera = UIAlertAction(title: "Camera", style: .default) { [unowned self](action) in
				
				picker.sourceType = UIImagePickerControllerSourceType.camera
				self.present(picker, animated: true, completion: nil)
			}
			
			alert.addAction(camera)
		}
		
		if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
			
			let photo = UIAlertAction(title: "Photo", style: .default) { [unowned self](action) in
				
				picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
				self.present(picker, animated: true, completion: nil)
			}
			
			alert.addAction(photo)
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
		alert.addAction(cancel)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	private func showCropVC(image: UIImage) {
		
		let cropVC = CropViewController.getCropViewController(self.view.frame, image: image)		
		cropVC!.cropdelegate = self
		self.present(cropVC!, animated: true, completion: nil)
	}

//	MARK: - ImagePickerDelegate

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		picker.dismiss(animated: true, completion: nil)
		let image = info[UIImagePickerControllerOriginalImage]
		if (image as? UIImage) != nil {
			showCropVC(image: image as! UIImage)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

//	MARK: - CropViewDelegate
	func cropView(_ cropView: CropViewController!, failedCroppingImage image: UIImage!) {
		print("cropping failed")
		cropView.dismiss(animated: true, completion: nil)
	}
	
	func cropView(_ cropView: CropViewController!, didFinishWith croppedImage: UIImage!) {
		print("Crop success")
		
		UIImageWriteToSavedPhotosAlbum(croppedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
		
		cropView.dismiss(animated: true, completion: nil)
	}
	
//MARK: - Add image to Library
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			// we got back an error!
			let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		} else {
			let ac = UIAlertController(title: "Saved!", message: "Cropped image has been saved to your photos.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
	}
}
