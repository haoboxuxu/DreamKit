//
//  PreviewView.swift
//  DreamKit01
//
//  Created by 徐浩博 on 2021/11/8.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    var pointLayer = CAShapeLayer()
    
    func drawCircles(points: [CGPoint]) {
        pointLayer.removeFromSuperlayer()

        let finalPath = CGMutablePath()

        points.forEach { point in
            let leftpath = UIBezierPath(ovalIn: CGRect(x: self.frame.width * point.x * 0.5,
                                                   y: self.frame.height * (1-point.y),
                                                   width: 8,
                                                   height: 8))
            
            let rightpath = UIBezierPath(ovalIn: CGRect(x: self.frame.width * point.x * 0.5 + self.frame.width * 0.5,
                                                   y: self.frame.height * (1-point.y),
                                                   width: 8,
                                                   height: 8))
            
            finalPath.addPath(leftpath.cgPath)
            finalPath.addPath(rightpath.cgPath)
        }


        pointLayer.path = finalPath
        pointLayer.strokeColor = UIColor.red.cgColor
        pointLayer.fillColor = UIColor.red.cgColor

        self.layer.addSublayer(pointLayer)
    }
    
}
