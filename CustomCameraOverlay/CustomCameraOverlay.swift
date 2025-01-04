//
//  CustomCameraOverlay.swift
//  CustomCameraOverlay
//
//  Created by Shamil Bayramli on 04.01.25.
//

import UIKit

@objc public protocol CameraOverlayDelegate: AnyObject {
    func didCapturePhoto(_ image: UIImage)
    func didStartNewPhotoSelection()
}

@objc public class CameraOverlayViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public weak var delegate: CameraOverlayDelegate?
    
    private var selectedImage: UIImage?
    private var popupContainerView: UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupOverlay()
    }
    
    private func setupOverlay() {
        let selectPhotoButton = UIButton(frame: CGRect(x: (view.bounds.width - 200) / 2, y: view.bounds.height - 100, width: 200, height: 50))
        selectPhotoButton.backgroundColor = .blue
        selectPhotoButton.setTitle("Select Photo", for: .normal)
        selectPhotoButton.layer.cornerRadius = 10
        selectPhotoButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        view.addSubview(selectPhotoButton)
    }
    
    @objc private func openGallery() {
        delegate?.didStartNewPhotoSelection()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            selectedImage = image
            showConfirmationPopup()
        } else {
            print("No image selected")
        }
    }
    
    private func showConfirmationPopup() {
        guard let selectedImage = selectedImage else {
            print("No image to show in popup")
            return
        }
        
        dismissPopup()
        
        popupContainerView = UIView(frame: view.bounds)
        guard let popupContainerView = popupContainerView else { return }
        
        popupContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(popupContainerView)
        view.bringSubviewToFront(popupContainerView)
        
        let popupView = UIView(frame: CGRect(x: 20, y: (view.bounds.height - 300) / 2, width: view.bounds.width - 40, height: 300))
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.3
        popupView.layer.shadowRadius = 5
        popupContainerView.addSubview(popupView)
        
        let imageView = UIImageView(image: selectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 10, y: 10, width: popupView.bounds.width - 20, height: 200)
        popupView.addSubview(imageView)
        
        let tickButton = UIButton(frame: CGRect(x: popupView.bounds.width / 4 - 25, y: popupView.bounds.height - 70, width: 50, height: 50))
        tickButton.setTitle("✔️", for: .normal)
        tickButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        tickButton.addTarget(self, action: #selector(confirmPhoto), for: .touchUpInside)
        popupView.addSubview(tickButton)
        
        let crossButton = UIButton(frame: CGRect(x: popupView.bounds.width * 3 / 4 - 25, y: popupView.bounds.height - 70, width: 50, height: 50))
        crossButton.setTitle("❌", for: .normal)
        crossButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        crossButton.addTarget(self, action: #selector(reselectPhoto), for: .touchUpInside)
        popupView.addSubview(crossButton)
    }
    
    @objc private func confirmPhoto() {
        guard let selectedImage = selectedImage else {
            print("No image to confirm")
            return
        }
        delegate?.didCapturePhoto(selectedImage)
        dismissPopup()
    }
    
    @objc private func reselectPhoto() {
        selectedImage = nil
        dismissPopup()
        openGallery()
    }
    
    private func dismissPopup() {
        popupContainerView?.removeFromSuperview()
        popupContainerView = nil
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
