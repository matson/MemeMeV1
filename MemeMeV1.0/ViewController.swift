//
//  ViewController.swift
//  MemeMeV1.0
//
//  Created by Tracy Adams on 9/27/23.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // -- MARK: Attributes
    
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIButton!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor:  UIColor.white,
        NSAttributedString.Key.backgroundColor: UIColor.clear,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -2
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFields()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //keyboard code:
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        //if simulator:
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        fixShareButton(factor: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // --MARK: Create Meme Object Methods
    
    func save() {
        // Create the meme
        let meme = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, original: imagePickerView.image!, memed: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        //hide toolbar and navbar
        fixBars(factor: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show toolbar and navbar
        fixBars(factor: false)
        
        return memedImage
    }
    
    // -- MARK: Application Buttons
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        
        let imagePicker = UIImagePickerController()
        //set the delegate
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: UIButton) {
        //generate a memed image
        let memedImage: UIImage = generateMemedImage()
        //define an instance of ActivityViewController
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        //present controller
        present(activityViewController, animated: true, completion: nil)
        //completion handler
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            if completed {
                self.save()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // -- MARK: ImagePicker Delegate Methods
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            
            //to set the selected image to the UIImageView:
            if let image = info[.originalImage] as? UIImage {
                imagePickerView.image = image
                //once image is selected:
                fixShareButton(factor: true)
            }
            
            dismiss(animated: true, completion: nil)
            
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // -- MARK: KeyBoard & Helper Functions
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = .zero
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func setTextFields(){
        
        textFieldTop.defaultTextAttributes = memeTextAttributes
        textFieldBottom.defaultTextAttributes = memeTextAttributes
        textFieldTop.text = "TOP"
        textFieldBottom.text = "BOTTOM"
        textFieldTop.textAlignment = .center
        textFieldBottom.textAlignment = .center
    }
    
    //for nav and tool bar
    func fixBars(factor: Bool){
        
        toolBar.isHidden = factor
        navigationController?.navigationBar.isHidden = factor
        
    }
    
    func fixShareButton(factor: Bool){
        shareButton.isEnabled = factor
    }
    
    
}

