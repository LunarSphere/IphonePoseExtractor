//
//  PoseModel.swift
//  IphonePoseExtractor
//
//  Created by James Tribble on 6/30/25.
//
// This file will handle pose data and logic
//

import Foundation
import ARKit
import simd
import UIKit
import Zip

// struct to hold data for logging
struct PoseData {
    // TODO: add Camera ID, Image ID
    let translation: SIMD3<Float>
    let quaternion: simd_quatf
    let image_name: String
    let imageID: Int
}

//Perform Operations on Data relevant to
class PoseModel{
    //list of pose structs
    private var poses : [PoseData] = []
    private var imageCounter: Int = 0 //track the image we are on
    private let fileManager = FileManager.default
    private let documentsURL: URL
    
    init(){
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func logPose(from transform: simd_float4x4, image: CVPixelBuffer) -> PoseData?{
        // Currently Calculates poses. Logs to termial and appends to Pose list
        imageCounter+=1
        let imageName = "IMG_\(imageCounter).jpg"
        guard saveImage(image, name: imageName)
        else{
            print("Failed to save image: \(imageName)")
            return nil
        }
        let translation = transform.columns.3
        let rotation_matrix = simd_float3x3(
            simd_float3(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z),
            simd_float3(transform.columns.1.x, transform.columns.1.y, transform.columns.1.z),
            simd_float3(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
        )
        let quaternion = simd_quatf(rotation_matrix)
        
        let pose = PoseData(
            translation: SIMD3(translation.x, translation.y, translation.z),
            quaternion: quaternion,
            image_name: imageName,
            imageID: imageCounter
        )
        poses.append(pose)
//        print("Pose: Tx=\(pose.translation.x), Ty=\(pose.translation.y), Tz=\(pose.translation.z)")
//        print("QW:\(pose.quarternion.real), QX\(pose.quarternion.imag.x), QY\(pose.quarternion.imag.y), QZ\(pose.quarternion.imag.z)")
        print("\(pose.quaternion.imag.x),\(pose.quaternion.imag.y),\(pose.quaternion.imag.z),\(pose.quaternion.real)," +
            "\(pose.translation.x),\(pose.translation.y),\(pose.translation.z)")
        return pose
    }
    // Save image to /images folder
    private func saveImage(_ pixelBuffer: CVPixelBuffer, name: String) -> Bool {
        guard let image = pixelBufferToUIImage(pixelBuffer) else { return false }
        
        let imagesURL = documentsURL.appendingPathComponent("images")
        do {
            // Create /images directory if it doesn't exist
            try fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: true, attributes: nil)
            
            let imageURL = imagesURL.appendingPathComponent(name)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return false }
            try imageData.write(to: imageURL)
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }
    
    // Convert CVPixelBuffer to UIImage
    private func pixelBufferToUIImage(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // Save poses to images.txt and create zip file
    func saveToFile() -> URL? {
        let imagesTxtURL = documentsURL.appendingPathComponent("images.txt")
        var output = "# ImageID, QW, QX, QY, QZ, TX, TY, TZ, CameraID, NAME\n"
        
        for pose in poses {
            let line = "\(pose.imageID) \(pose.quaternion.real) \(pose.quaternion.imag.x) \(pose.quaternion.imag.y) \(pose.quaternion.imag.z) \(pose.translation.x) \(pose.translation.y) \(pose.translation.z) 1 \(pose.image_name)\n"
            output.append(line)
        }
        
        do {
            // Write images.txt
            try output.write(to: imagesTxtURL, atomically: true, encoding: .utf8)
    
            // Create zip file
            let zipURL = documentsURL.appendingPathComponent("pose_data_\(Int(Date().timeIntervalSince1970)).zip")
            let imagesFolderURL = documentsURL.appendingPathComponent("images")
            try Zip.zipFiles(paths: [imagesFolderURL, imagesTxtURL], zipFilePath: zipURL, password: nil, progress: nil)
            return zipURL
        } catch {
            print("Error saving files or creating zip: \(error)")
            return nil
        }
        
    }
    
    func getPoses() -> [PoseData]{
        return poses
    }
    //resets counter and poses list between recordings.
    func reset() {
        imageCounter = 0
        poses.removeAll()
        }
    
}
