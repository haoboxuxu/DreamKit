//
//  ViewController.swift
//  DreamKit
//
//  Created by 徐浩博 on 2021/11/9.
//

import UIKit
import SceneKit
import ARKit

class DreamKitVC: UIViewController {

    var debugImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 10, y: 10, width: 150, height: 150)
        return imageView
    }()
    
    let snapshotQueue = DispatchQueue(label: "SceneView Snapshot Queue")
    
    private var sceneView: ARSCNView  = {
        let sceneView = ARSCNView()
        return sceneView
    }()
    
    // DreamARs
    var dsProcessor = DreamStereoProcessor()
    var scnViewLeft: ARSCNView!
    var scnViewRight: ARSCNView!
    
    // DreamHands
    private let previewView = PreviewView()
    let cameraManager = VisionCameraManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARView()
        view.addSubview(debugImageview)
    }
    
    private func setUpARView() {
        // duo ar views
        scnViewLeft = ARSCNView(frame: CGRect(x: 0, y: 0, width: view.width/2, height: view.height))
        scnViewRight = ARSCNView(frame: CGRect(x: view.width/2, y: 0, width: view.width/2, height: view.height))
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        dsProcessor.setUpView(sceneView: sceneView,
                              scnViewLeft: scnViewLeft,
                              scnViewRight: scnViewRight,
                              scnName: "art.scnassets/ship.scn")
        
        cameraManager.previewView = previewView
        
        view.addSubview(sceneView)
        self.view.addSubview(scnViewLeft)
        self.view.addSubview(scnViewRight)
        
        self.view.addSubview(previewView)
        
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = self.view.bounds
        previewView.frame = self.view.bounds
    }
}

extension DreamKitVC: ARSCNViewDelegate, ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        snapshotQueue.async {
            let cvPixelBuffer = frame.capturedImage
            let image = UIImage(ciImage: CIImage(cvPixelBuffer: cvPixelBuffer))
            
            DispatchQueue.main.async {
                self.debugImageview.image = image
            }
            
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            
            self.cameraManager.captureCIImageFromARSession(didOutput: ciImage)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.dsProcessor.updateFrame()
        }
    }
}
