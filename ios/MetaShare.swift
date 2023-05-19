import FBSDKShareKit
import MobileCoreServices
import Photos
@objc(MetaShare)
class MetaShare: NSObject, SharingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var mSharePhotosPromiseResolveBlock : RCTPromiseResolveBlock? = nil
    var mSharePhotosPromiseRejectBlock : RCTPromiseRejectBlock? = nil
    
    func sharer(_ sharer: FBSDKShareKit.Sharing, didCompleteWithResults results: [String : Any]) {
        if(mSharePhotosPromiseRejectBlock != nil){
            mSharePhotosPromiseResolveBlock!(results)
        }
    }
    
    func sharer(_ sharer: FBSDKShareKit.Sharing, didFailWithError error: Error) {
        print(error)
        if(mSharePhotosPromiseRejectBlock != nil){
            mSharePhotosPromiseRejectBlock!("error",error.localizedDescription, error)
        }
        
    }
    
    func sharerDidCancel(_ sharer: FBSDKShareKit.Sharing) {
        if(mSharePhotosPromiseRejectBlock != nil){
            mSharePhotosPromiseRejectBlock!("cancel","cancel",nil)
        }
        
    }
    
    @objc(sharePhotos:withResolver:withRejecter:)
    func sharePhotos(photos: NSArray, resolve: @escaping RCTPromiseResolveBlock,  reject: @escaping RCTPromiseRejectBlock) -> Void {
        let shareContent = SharePhotoContent()
        var photoContent : [SharePhoto] = []
        mSharePhotosPromiseRejectBlock = reject
        mSharePhotosPromiseResolveBlock = resolve
        let downloadGroup = DispatchGroup()
        for (index,photo) in photos.enumerated() {
            let filePath = NSTemporaryDirectory().appending("temp_\(index).jpg")
            let photoURL = URL(string: photo as! String)!
            downloadGroup.enter()
			downloadFile(url: photoURL, toFile:  URL(fileURLWithPath:filePath )) { result in
				
				switch result {
					case .success(let fileURL):
						
						let image = UIImage(contentsOfFile: filePath)
						let photo = SharePhoto(
							image: image!,
							userGenerated: true
						)
						photoContent.append(photo)
						downloadGroup.leave()
						break
					case .failure(let error):
						reject("error",error.localizedDescription, error)
						break
				}

			}
        }
        downloadGroup.notify(queue: .main){
            shareContent.photos = photoContent
            let dialog = ShareDialog(
				fromViewController: RCTPresentedViewController()!,
                content: shareContent,
                delegate: self
            )
            DispatchQueue.main.async {
                dialog.show()
            }
        }
    }
    
    @objc(shareVideo:withResolver:withRejecter:)
    func shareVideo(videoURI: NSString, resolve: @escaping RCTPromiseResolveBlock,  reject: @escaping RCTPromiseRejectBlock) -> Void {
        let videoURL = URL(string: videoURI as String)!
        downloadVideoAndSaveToPhotosLibrary(from: videoURL) { result in
            switch result {
            case .success(let data):
                let shareContent = ShareVideoContent()
                let videoAsset = ShareVideo(videoAsset: data)
				
                shareContent.video = videoAsset
                let dialog = ShareDialog(
					fromViewController: RCTPresentedViewController()!,
                    content: shareContent,
                    delegate: self
                )
                DispatchQueue.main.async {
                    dialog.show()
                }
                resolve("")
            case .failure(let error):
                reject("error","error",error)
                break
                // Handle the error
            }
        }
    }
    @objc(shareVideoToInstagram:withResolver:withRejecter:)
    func shareVideoToInstagram(videoURI: NSString, resolve: @escaping RCTPromiseResolveBlock,  reject: @escaping RCTPromiseRejectBlock) -> Void {
        let videoURL = URL(string: videoURI as String)!
        downloadVideoAndSaveToPhotosLibrary(from: videoURL) { result in
            switch result {
            case .success(let data):

                let assetUrl = URL(string: "instagram://library?LocalIdentifier=" + data.localIdentifier)!
                if UIApplication.shared.canOpenURL(assetUrl) {
                    UIApplication.shared.open(assetUrl, options: [:], completionHandler:nil)
                }
                resolve("")
            case .failure(let error):
                reject("error","error",error)
                break
                // Handle the error
            }
        }
    }
	@objc(shareToFacebookReels:withVideoURI:withImageURI:withResolver:withRejecter:)
	func shareToFacebookReels(appID:String,videoURI:String,imageURI:String?,resolve: @escaping RCTPromiseResolveBlock,  reject: @escaping RCTPromiseRejectBlock){
		var pasteboardItems: [String: Any] = [:]
		let downloadGroup = DispatchGroup()
		let filePath = NSTemporaryDirectory().appending("temp_0.jpg")
		
		if(imageURI != "" && imageURI != nil ){
			downloadGroup.enter()
			downloadFile(url: URL(string: imageURI!)!, toFile: URL(string: filePath)!, completion:{ result in
				
				switch result {
					case .success(let fileURL):
						let backgroundImage = UIImage(contentsOfFile: filePath)
						pasteboardItems["com.facebook.sharedSticker.stickerImage"] = backgroundImage?.pngData()
						downloadGroup.leave()
					case .failure(let error):
						reject("download fail",error.localizedDescription,nil)
						break
				}

			})
		}
		if(videoURI != ""){
			downloadGroup.enter()
			downloadVideoAndSaveToPhotosLibrary(from: URL(string: videoURI)!) { result in
				switch result {
					case .success(let data):
						
						data.requestContentEditingInput(with: nil) { input, _ in
							guard let input = input else {
								reject("error","video error",nil)
								return
							}
							guard let avAsset = input.audiovisualAsset else {
								reject("error","avAsset error",nil)
								return
							}
							
							let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)!
							exportSession.outputFileType = .mp4
							
							let tempFile = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
							exportSession.outputURL = tempFile
							
							exportSession.exportAsynchronously {
								guard exportSession.status == .completed,
									  let fileData = try? Data(contentsOf: tempFile) else {
									reject("error","file data error",nil)
									return
								}
								pasteboardItems["com.facebook.sharedSticker.backgroundVideo"] = fileData
								downloadGroup.leave()
								
							}
						}
					case .failure(let error):
						reject("error","error",error)
						break
							// Handle the error
				}
			}
		}

		downloadGroup.notify(queue: .main){
			let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
			pasteboardItems["com.facebook.sharedSticker.appID"] = appID
				// This call is iOS 10+, can use 'setItems' depending on what versions you support
			UIPasteboard.general.setItems([pasteboardItems], options:
											pasteboardOptions)
			DispatchQueue.main.async {
				UIApplication.shared.open(URL(string: "facebook-reels://share")!, options: [:], completionHandler: nil)
				resolve("open")
			}
		}
	
	}
	
    @objc(shareToInstagramStory:withData:withResolver:withRejecter:)
    func shareToInstagramStory(appID:String,data:NSDictionary,resolve: @escaping RCTPromiseResolveBlock,  reject: @escaping RCTPromiseRejectBlock){
        var pasteboardItems: [String: Any] = [:]
        let downloadGroup = DispatchGroup()
        if((data["backgroundImageAsset"]) != nil){
            downloadGroup.enter()
			downloadFileWithoutPath(from: URL(string: data["backgroundImageAsset"] as! String)!) { (url,error)  in
				if(url != nil){
					let backgroundImage = UIImage(contentsOfFile: url!.path)
					pasteboardItems["com.instagram.sharedSticker.backgroundImage"] = backgroundImage?.pngData()
					downloadGroup.leave()
				}else{
					reject("download fail",error?.localizedDescription,nil)
				}
			}
        }
        if((data["backgroundVideoAsset"]) != nil){
            downloadGroup.enter()
            downloadVideoAndSaveToPhotosLibrary(from: URL(string: data["backgroundVideoAsset"] as! String)!) { result in
                switch result {
                case .success(let data):
                    
                    data.requestContentEditingInput(with: nil) { input, _ in
                        guard let input = input else {
                            reject("error","video error",nil)
                            return
                        }
                        guard let avAsset = input.audiovisualAsset else {
                            reject("error","avAsset error",nil)
                            return
                        }
                        
                        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)!
                        exportSession.outputFileType = .mp4
                        
                        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
                        exportSession.outputURL = tempFile
                        
                        exportSession.exportAsynchronously {
                            guard exportSession.status == .completed,
                                  let fileData = try? Data(contentsOf: tempFile) else {
                                reject("error","file data error",nil)
                                return
                            }
                            pasteboardItems["com.instagram.sharedSticker.backgroundVideo"] = fileData
                            downloadGroup.leave()
                            
                        }
                    }
                case .failure(let error):
                    reject("error","error",error)
                    break
                    // Handle the error
                }
            }
        }
        if((data["stickerImageAsset"]) != nil){
            let filePath = NSTemporaryDirectory().appending("temp_1.jpg")
            downloadGroup.enter()
            downloadFile(url: URL(string: data["stickerImageAsset"] as! String)!, toFile: URL(string: filePath)!, completion:{ result in
				switch result {
					case .success(let fileURL):
						let backgroundImage = UIImage(contentsOfFile: filePath)
						pasteboardItems["com.instagram.sharedSticker.stickerImage"] = backgroundImage?.pngData()
						downloadGroup.leave()
					case .failure(let error):
						reject("download fail",error.localizedDescription,nil)
						break
				}

            })
        }
        
        if((data["backgroundTopColor"]) != nil){
            downloadGroup.enter()
            pasteboardItems["com.instagram.sharedSticker.backgroundTopColor"] = data["backgroundTopColor"]
            downloadGroup.leave()
        }
        
        
        if((data["backgroundBottomColor"]) != nil){
            downloadGroup.enter()
            pasteboardItems["com.instagram.sharedSticker.backgroundBottomColor"] = data["backgroundBottomColor"]
            downloadGroup.leave()
        }
        
        downloadGroup.notify(queue: .main){
            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
            
            // This call is iOS 10+, can use 'setItems' depending on what versions you support
            UIPasteboard.general.setItems([pasteboardItems], options:
                                            pasteboardOptions)
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: "instagram-stories://share?source_application=\(appID)")!, options: [:], completionHandler: nil)
                resolve("open")
            }
        }
        
    }
    
    @objc(shareImageToInstagram:withResolver:withRejecter:)
    func shareImageToInstagram(imageURI: NSString, resolve: @escaping RCTPromiseResolveBlock,  reject: @escaping RCTPromiseRejectBlock) -> Void {
        let filePath = NSTemporaryDirectory().appending("temp_0.jpg")
        let photoURL = URL(string: imageURI as String)!
        var assetPlaceholder: PHObjectPlaceholder?
		downloadFileWithoutPath(from: photoURL) { (localURL, error) in
			if(localURL == nil){
				reject("error", NSError(domain: "react-native-meta-share", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get localURL"]).localizedDescription,nil)
				return
			}
			PHPhotoLibrary.shared().performChanges({
				let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: localURL!)
				assetPlaceholder = request?.placeholderForCreatedAsset
			}) { success, error in
				if success {
					if let assetPlaceholder = assetPlaceholder {
						let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetPlaceholder.localIdentifier], options: nil)
						if let asset = assets.firstObject {
							let assetUrl = URL(string: "instagram://library?LocalIdentifier=" + asset.localIdentifier)!
							if UIApplication.shared.canOpenURL(assetUrl) {
								DispatchQueue.main.async {
									UIApplication.shared.open(assetUrl, options: [:], completionHandler:nil)
								}

							}
							resolve("")
						} else {
							reject("error", NSError(domain: "react-native-meta-share", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not fetch saved asset"]).localizedDescription,nil)
						}
					} else {
						reject("error", NSError(domain: "react-native-meta-share", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get asset placeholder"]).localizedDescription,nil)
					}
				} else {
					reject("error","Error saving image to Photos library: \(error)",nil)
				}
			}
		}

    }
    
    
}
