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
    private let poseModel = PoseModel()
    private let arView = ARView(frame: .zero)
    
    override init() {
        super.init()
        setupARSession()
    }
    
    private func setupARSession() {
        arView.automaticallyConfigureSession = false //disable default arkit config
        let config = ARWorldTrackingConfiguration() // enable device location tracking
        config.worldAlignment = .gravity // or .gravityAndHeading for geographic alignment
        arView.session.run(config) // run Ar session using defined config
        arView.session.delegate = self
    }
    
    // ARSessionDelegate method
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let matrix = frame.camera.transform
        // Optionally invert matrix for COLMAP, as per your comment
        // let matrix = poseModel.invertTransform(frame.camera.transform)
        
        latestPose = poseModel.logPose(from: matrix)
    }
    
    // Expose ARView for UIViewRepresentable
    func getARView() -> ARView {
        return arView
    }
}

