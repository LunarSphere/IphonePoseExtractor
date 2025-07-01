//
//  ARViewModel.swift
//  IphonePoseExtractor
//
//  Created by James Tribble on 6/30/25.
//
// This file will handle AR Session Management and coordnate with PoseModel

import SwiftUI
import RealityKit
import ARKit
import simd

class ARViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var latestPose: PoseData? // Reactive property for View
    @Published var isLogging: Bool = false // var to see if we want to log data or not
    @Published var zipFileURL: URL?
    private let poseModel = PoseModel()
    private let arView = ARView(frame: .zero) //performing io on main thread can cause hangs?
    private let zippath: String = "" //store path of generated zip file
    private var previousCaptureTime: TimeInterval = 0
    private let Interval: TimeInterval = (1/5) // 10fps or frame every .1 second; 2fps or .5 frames per second
    
    override init() {
        super.init()
        setupARSession()
    }
    
    private func setupARSession() {
        arView.automaticallyConfigureSession = false //disable default arkit config
        let config = ARWorldTrackingConfiguration() // enable device location tracking
        config.worldAlignment = .gravityAndHeading // or .gravityAndHeading for geographic alignment
        arView.session.run(config) // run Ar session using defined config
        arView.session.delegate = self
    }
    
    // ARSessionDelegate method
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard frame.camera.trackingState == .normal else { return }
        if isLogging{
            let currentTime = Date().timeIntervalSince1970
            if (currentTime - previousCaptureTime >= Interval){
                //let matrix = frame.camera.transform
                // incase matrix needs to be inverted
                let matrix = poseModel.invertTransform(frame.camera.transform)
                latestPose = poseModel.logPose(from: matrix, image: frame.capturedImage)
                previousCaptureTime = currentTime
            }
        }
        else{
            //logCamera Intrinsics
            let intrinsics = frame.camera.intrinsics
            let resolution = frame.camera.imageResolution
            poseModel.logCameraIntrinsics(
                cameraIntrinsics: intrinsics,
                width: Int(resolution.width),
                height: Int(resolution.height)
            )
            return
        }

    }
    
    //toggle logging on or off
    func togglelog(){
        isLogging.toggle()
        if !isLogging{
            poseModel.saveToFile { [weak self] zipURL in
                self?.zipFileURL = zipURL
                self?.poseModel.reset()
            }
        }
    }
    
    // Expose ARView for UIViewRepresentable
    func getARView() -> ARView {
        return arView
    }
}
 

