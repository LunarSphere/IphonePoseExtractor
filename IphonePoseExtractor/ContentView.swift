//
//  ContentView.swift
//  IphonePoseExtractor
//
//  Created by James Tribble on 6/26/25.
//

import SwiftUI
import RealityKit

// I think this struct defines what you see in your smartphone window

//camera.txt needs information about the camera should be consistent I can probably write this without a script
//points3D.txt is empty
//images.txt needs
//ImageID, Quarternion(QW, QX, QY, QZ), Translation(TX,TY,TZ), CameraID, Image Name
// easiest way to test if this works is to run colmap on it.
// 3D construct can realistically be from any camera.
//use splat to create a 3d model or use splat to generate new data.
// GPS data would be good according to Rashik. the Iphone is advantageous to this becuase GPS data will scale easier.
// When making the try inverting the initial 4x4 Matrix. First thing I should try when I debug the matrix.
// Reason: iPhone camera may not line up with colmap convention
// I should use the model view view model

struct ContentView : View {
    // calls the ARViewModel class
    @StateObject private var viewModel = ARViewModel()
    @State private var showShareSheet = false
    //use this to make the body
    var body: some View {
        // ZStack lets you define UI
        ZStack{
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all) // allow the camera feed to take up the whole app window
            VStack{
                // Display zip file path when available
                if let zipURL = viewModel.zipFileURL {
                Text("Saved to: \(zipURL.lastPathComponent)")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
                }
                Spacer()
                ShutterButton(isLogging: viewModel.isLogging) {
                    viewModel.togglelog()
                }
                    .padding(.bottom, 20)
            }
        }
        if let zipURL = viewModel.zipFileURL {
                       Button("Share Zip File") {
                           showShareSheet = true
                       }
                       .sheet(isPresented: $showShareSheet) {
                           ActivityView(activityItems: [zipURL])
                       }
                   }
    }
}

// I think this container defines the UI
struct ARViewContainer: UIViewRepresentable {
    let viewModel: ARViewModel
    // Define more of what I want to see in use interface
    func makeUIView(context: Context) -> ARView {
        return viewModel.getARView()
    }
    
    func updateUIView(_ uiview: ARView, context: Context) {}
    
}

struct ShutterButton: View {
    let isLogging: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer white ring
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                // Inner circle (red when logging, white when not)
                Circle()
                    .fill(isLogging ? Color.red : Color.white)
                    .frame(width: isLogging ? 60 : 70, height: isLogging ? 60 : 70)
                    .animation(.easeInOut(duration: 0.2), value: isLogging)
            }
            .shadow(radius: 5)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}

