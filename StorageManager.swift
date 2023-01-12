//
//  StorageManager.swift
//  ModelPickerApp
//
//  Created by David Tsang on 6/1/2023.
//

import Foundation
import SwiftUI
import FirebaseStorage

class FileMetaData {
    var name: String
    var imagePath: String
    var objectPath: String
    var downloadImageUrl: URL?
    var downloadObjectUrl: URL?
    var uiImage: UIImage?
    
    init(name: String, imagePath: String, objectPath: String) {
        self.name = name
        self.imagePath = imagePath
        self.objectPath = objectPath
    }
}

class StorageManager: ObservableObject {
    @Published var objects: [FileMetaData] = []
    @Published var callBack: (_ name: String) -> Void = {name in }
    
    let storage = Storage.storage()
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func checkIfImageObjectAreDownloaded (index: Int) -> Bool {
        if (objects[index].uiImage != nil && objects[index].downloadObjectUrl != nil) {
            return true
        } else {
            return false
        }
    }
    
    
    func getFilesFromFireBase() {
        self.createDicectory(name: "DownloadedContent")
        //        let storageRef = storage.reference().child("toy_drummer")
        let storageRef = storage.reference()
        
        
        storageRef.listAll (completion:) { (result, error) in
            if let error = error {
                print("DEBUG-FM: Error while listing all files: ", error)
            }
            
            if let result {

                for prefix in result.prefixes {
                    
                    let metaData = FileMetaData(name: prefix.name, imagePath: "\(prefix.name)/image.jpg", objectPath: "\(prefix.name)/object.usdz")
                    //                    print("DEBUG-FM: Item in images folder: \(metaData)")
                    self.objects.append(metaData)
                }
                
                self.downloadAllFiles()

            }
            
        }
    }

    
    func downloadAllFiles() {
        let storageRef = storage.reference()
        for (index, object) in self.objects.enumerated() {
            let localImageURL = self.documentsURL.appendingPathComponent("DownloadedContent/\(object.imagePath)")
            let localObjectURL = self.documentsURL.appendingPathComponent("DownloadedContent/\(object.objectPath)")

            if self.checkIfDataIsExisted(url: object.imagePath) {
                self.objects[index].downloadImageUrl = localImageURL
                do {
                    let imageData = try Data(contentsOf: localImageURL)
                    self.objects[index].uiImage = UIImage(data: imageData)
                    
                    if (objects[index].downloadObjectUrl != nil) {
                        callBack(objects[index].name)
                    }
                } catch {
                    print("Error loading image : \(error)")
                }
                
            } else {
                let remoteImageRef = storageRef.child(object.imagePath)
                remoteImageRef.write(toFile: localImageURL) { url, error in
                    if let error = error {
                        print("DEBUG-FM: \(error)")
                    } else {
                        print(url!)
                        self.objects[index].downloadImageUrl = url
                        
                        do {
                            let imageData = try Data(contentsOf: url!)
                            self.objects[index].uiImage = UIImage(data: imageData)
                        
                        } catch {
                            print("Error loading image : \(error)")
                        }
                        

                        if (self.checkIfImageObjectAreDownloaded(index: index)) {
                            self.callBack(self.objects[index].name)
                        }
                    }
                }
            }
            
            if self.checkIfDataIsExisted(url: object.objectPath) {
                self.objects[index].downloadObjectUrl = localObjectURL
                if (objects[index].uiImage != nil) {
                    callBack(objects[index].name)
                }
            } else {
                let remoteObjectRef = storageRef.child(object.objectPath)
                remoteObjectRef.write(toFile: localObjectURL) { url, error in
                    if let error = error {
                        print("DEBUG-FM: \(error)")
                    } else {
                        print(url!)
                        self.objects[index].downloadObjectUrl = url
                        
                        if (self.checkIfImageObjectAreDownloaded(index: index)) {
                            self.callBack(self.objects[index].name)
                        }
                    }
                }
            }
            
        }
    }
    
    
    func createDicectory(name: String) {
        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderPath = root.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            do {
                 try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
             } catch {
                 print(error.localizedDescription)
             }
        }
    }
    
    func checkIfDataIsExisted(url: String) -> Bool {
        let downloadedContentUrl = documentsURL.appendingPathComponent("DownloadedContent/\(url)")
        
        if FileManager.default.fileExists(atPath: downloadedContentUrl.path) {
            print("fileURL.path \(downloadedContentUrl.path)")
            return true
        } else {
            return false
        }
    }
    
}
