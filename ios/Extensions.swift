//
//  Downloader.swift
//  react-native-meta-share
//
//  Created by Alex on 13/3/2023.
//

import Foundation
import Photos
import FBSDKShareKit
extension MetaShare{
	func downloadFile(url: URL, toFile file: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
			guard let tempURL = tempURL else {
				completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: nil)))
				return
			}
			
			do {
				if FileManager.default.fileExists(atPath: file.path) {
					try FileManager.default.removeItem(at: file)
				}
				try FileManager.default.copyItem(at: tempURL, to: file)
				
				completion(.success(tempURL))
			} catch {
				completion(.failure(error))
			}
		}
		
		task.resume()
	}
	func downloadFileWithoutPath(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
		let task = URLSession.shared.downloadTask(with: url) { (localURL, response, error) in
			if let error = error {
				completion(nil, error)
			} else if let localURL = localURL {
				let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)
				do {
					try FileManager.default.moveItem(at: localURL, to: destinationURL)
					completion(destinationURL, nil)
				} catch {
					completion(nil, error)
				}
			} else {
				completion(nil, NSError(domain: "Unknown error", code: -1, userInfo: nil))
			}
		}
		
		task.resume()
	}
    func downloadVideoAndSaveToPhotosLibrary(from url: URL, completion: @escaping (Result<PHAsset, Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0
        
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
                print(tempURL)
                do {
                    try data.write(to: tempURL)
                } catch let error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                var assetLocalIdentifier : String?
                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    assetRequest.addResource(with: .video, fileURL: tempURL, options: options)
                    assetLocalIdentifier = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)?.placeholderForCreatedAsset!.localIdentifier
                    print(assetLocalIdentifier)
                }) { (success, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    } else {
                        
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
                        if(assetLocalIdentifier != nil ){
                            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier!], options: fetchOptions)
                            
                            guard let asset = fetchResult.firstObject else {
                                DispatchQueue.main.async {
                                    completion(.failure(NSError(domain: "react-native-meta-share", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't fetch saved asset"])))
                                }
                                return
                            }
                            
                            DispatchQueue.main.async {
                                completion(.success(asset))
                            }
                        }
                        
                    }
                    
                    // Delete the temporary file URL.
                    try? FileManager.default.removeItem(at: tempURL)
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "react-native-meta-share", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't download video data"])))
                }
            }
        }
        
        dataTask.resume()
    }
    
}
extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
}
