//
//  TransformsExport.swift
//  IphonePoseExtractor
//
//  Created by James Tribble on 7/6/25.
//

import Foundation
import simd

struct FrameEntry: Codable {
    let file_path: String
    let transform_matrix: [[Double]]
    let colmap_im_id: Int
}

struct NerfstudioTransforms: Codable {
    let w: Int
    let h: Int
    let fl_x: Double
    let fl_y: Double
    let cx: Double
    let cy: Double
    let camera_model: String
    let frames: [FrameEntry]
}

func exportTransformsJSON(
    frames: [(filePath: String, transform: simd_float4x4, imageId: Int)],
    fx: Double, fy: Double, cx: Double, cy: Double,
    width: Int, height: Int,
    outputURL: URL
) {
    // Build the frames array
    let frameEntries: [FrameEntry] = frames.map { (filePath, transform, imageId) in
        // Convert simd_float4x4 to [[Double]]
        let matrix: [[Double]] = (0..<4).map { row in
            (0..<4).map { col in
                Double(transform[row, col])
            }
        }
        return FrameEntry(file_path: filePath, transform_matrix: matrix, colmap_im_id: imageId)
    }
    
    let transforms = NerfstudioTransforms(
        w: width,
        h: height,
        fl_x: fx,
        fl_y: fy,
        cx: cx,
        cy: cy,
        camera_model: "PINHOLE",
        frames: frameEntries
    )
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    do {
        let data = try encoder.encode(transforms)
        try data.write(to: outputURL)
        print("transforms.json exported to \(outputURL.path)")
    } catch {
        print("Failed to export transforms.json: \(error)")
    }
}
