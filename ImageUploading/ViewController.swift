//
//  ViewController.swift
//  ImageUploading
//
//  Created by LetMeCall Corp on 17/12/18.
//  Copyright © 2018 LetMeCall Corp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.handleProfilePicker()
    }
    
    
    func handleProfilePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
//        ....(your custom code for navigationBar in Picker color)
        self.present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"]   as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        if let selectedImages = selectedImage {

            if let dataa = selectedImages.jpegData(compressionQuality: 1) {
                
                let parameters:Parameters = ["access_token" : "YourToken"]
                
                // You can change your image name here, i use NSURL image and convert into string
                let imageURL = info["UIImagePickerControllerReferenceURL"] as! NSURL
                let fileName = imageURL.absoluteString
                // Start Alamofire
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(dataa, withName: "/Users/letmecallcorp/Library/Developer/CoreSimulator/Devices/B9009086-50F9-4146-925E-200DD817D9A5/data/Containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles", fileName: fileName!, mimeType: "image/jpeg")
                   
                    for (key,value) in parameters {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                }, to:"http://server1/upload_img.php")
                { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (Progress) in
                            print("Upload Progress: \(Progress.fractionCompleted)")
                        })
                        
                        upload.responseJSON { response in
                            //self.delegate?.showSuccessAlert()
                            print(response.request)  // original URL request
                            print(response.response) // URL response
                            print(response.data)     // server data
                            print(response.result)   // result of response serialization
                            //                        self.showSuccesAlert()
                            //self.removeImage("frame", fileExtension: "txt")
                            if let JSON = response.result.value {
                                print("JSON: \(JSON)")
                            }
                        }
                        
                    case .failure(let encodingError):
                        //self.delegate?.showFailAlert()
                        print(encodingError)
                    }
                    
                }
            }
            
        }
    }

    @IBAction func clickOnButton(_ sender: Any) {
        
        let img = UIImage(named:"Radha.jpg")
        let dataa = img?.jpegData(compressionQuality: 1.0)
        
        self.requestWith(endUrl: "https://rss.itunes.apple.com/api/v1/in/ios-apps/top-free/all/10/explicit.json", imageData: dataa, parameters: ["https://itunes.apple.com/in/app/google-pay-for-india-tez/id1193357041?mt=8" : dataa as Any])
        
    }
    
    
    func requestWith(endUrl: String, imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let url = "https://rss.itunes.apple.com/api/v1/in/ios-apps/top-free/all/10/explicit.json"
        /* your API url */
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "Radha", fileName: "Radha.jpg", mimeType: "image/jpeg")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .get, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    print(result)
                    print(response)
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    onCompletion?(nil)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    
    
}

