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

// struct to hold data for logging
struct PoseData {
    // TODO: add Camera ID, Image ID
    let translation: SIMD3<Float>
    let quarternion: simd_quatf
    let image_name: String
}

//Perform Operations on Data relevant to
class PoseModel{
    //list of pose structs
    private var poses : [PoseData] = []
    
    func logPose(from transform: simd_float4x4) -> PoseData{
        // Currently Calculates poses. Logs to termial and appends to Pose list
        let translation = transform.columns.3
        let rotation_matrix = simd_float3x3(
            simd_float3(transform.columns.0.x, transform.columns.0.y, transform.columns.0.z),
            simd_float3(transform.columns.1.x, transform.columns.1.y, transform.columns.1.z),
            simd_float3(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
        )
        let quaternion = simd_quatf(rotation_matrix)
        
        let pose = PoseData(
            translation: SIMD3(translation.x, translation.y, translation.z),
            quarternion: quaternion,
            image_name: "IMG_XXX.JPG"
        )
        poses.append(pose)
//        print("Pose: Tx=\(pose.translation.x), Ty=\(pose.translation.y), Tz=\(pose.translation.z)")
//        print("QW:\(pose.quarternion.real), QX\(pose.quarternion.imag.x), QY\(pose.quarternion.imag.y), QZ\(pose.quarternion.imag.z)")
        print("\(pose.quarternion.imag.x),\(pose.quarternion.imag.y),\(pose.quarternion.imag.z),\(pose.quarternion.real)," +
            "\(pose.translation.x),\(pose.translation.y),\(pose.translation.z)")
        return pose
    }
    
    func write2File(){
        // TODO: save images.txt for colmaps
        //Format ImageID, Quarternion(QW, QX, QY, QZ), Translation(TX,TY,TZ), CameraID, Image Name
    }
    
    func getPoses() -> [PoseData]{
        return poses
        
    //TODO: Write a call back function to start and stop logging
    //TODO: Think of a way to log 10s frames per second. 
    }
}
