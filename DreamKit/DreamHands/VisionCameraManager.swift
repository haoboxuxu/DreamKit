//
//  VisionCameraManager.swift
//  DreamKit01
//
//  Created by 徐浩博 on 2021/11/8.
//

import UIKit
import AVFoundation
import Vision


class VisionCameraManager: NSObject {
    
    var previewView: PreviewView!
    let handTracing = HandTracingProcessor()
    
    let context = CIContext()
    
    override init() {
        super.init()
    }
    
    func captureOutputFromARSession(didOutput sampleBuffer: CMSampleBuffer) {
        print("arsession captureOutput...")
        handTracing.setUpRequestHandler(sampleBuffer)
        let points = handTracing.getPoints()
        
        DispatchQueue.main.async {
            self.previewView?.drawCircles(points: points)
        }
    }
    
    func captureCGImageFromARSession(didOutput cgimage: CGImage) {
        handTracing.setUpRequestHandlerFromCGImage(cgimage)
        let points = handTracing.getPoints()
        DispatchQueue.main.async {
            self.previewView.drawCircles(points: points)
        }
    }
    
    func captureCIImageFromARSession(didOutput ciImage: CIImage) {
        handTracing.setUpRequestHandlerFromCIImage(ciImage)
        let points = handTracing.getPoints()
        DispatchQueue.main.async {
            self.previewView.drawCircles(points: points)
        }
    }
    
    func getCGImage(from sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
}
