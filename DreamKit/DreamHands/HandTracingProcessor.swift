//
//  HandTracingProcessor.swift
//  DreamKit01
//
//  Created by 徐浩博 on 2021/11/8.
//

import Vision
import CoreImage

class HandTracingProcessor {
    let request = VNDetectHumanHandPoseRequest()
    var requestHandler: VNImageRequestHandler?
    var tacingPoints: [VNRecognizedPoint]?
    
    func setUpRequestHandler(_ buffer: CMSampleBuffer) {
        requestHandler = VNImageRequestHandler(cmSampleBuffer: buffer, orientation: .up)
    }
    
    func setUpRequestHandlerFromCGImage(_ cgImage: CGImage) {
        requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    }
    
    func setUpRequestHandlerFromCIImage(_ ciImage: CIImage) {
        requestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
    }
    
    
    func getPoints() -> [CGPoint] {
        do {
            try requestHandler?.perform([request])
            if let observations = request.results {
    
                tacingPoints = []
    
                try observations.forEach { observation in
                    let allPoints = try observation.recognizedPoints(.all)
                    allPoints.forEach { _, value in
                        tacingPoints?.append(value)
                    }
                }
    
                let cgPoints = tacingPoints?.filter {
                    $0.confidence > 0.7
                }.map({ point in
                    CGPoint(x: point.location.x, y: point.location.y)
                })
    
    
                return cgPoints ?? []
            }
        } catch {
            print(error)
        }
    
        return []
    }
    
}
