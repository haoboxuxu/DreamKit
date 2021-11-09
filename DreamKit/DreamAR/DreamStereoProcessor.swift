//
//  DreamStereoProcessor.swift
//  DreamKit01
//
//  Created by 徐浩博 on 2021/11/5.
//

import SceneKit
import ARKit

class DreamStereoProcessor {
    
    var sceneView: ARSCNView!
    var scnViewLeft: ARSCNView!
    var scnViewRight: ARSCNView!
    
    var eyeCamera: SCNCamera = SCNCamera()
    
    let eyeFOV = 60
    var cameraImageScale = 3.478
    
    let _HEADSET_IS_PASSTHROUGH_OR_SEETHROUGH = true //是否显示相机内容
    let _CAMERA_IS_ON_LEFT_EYE = false //相机只有单眼，用于后续左右view适配
    
    let interpupilaryDistance : Float = 0.066
    
    func setUpView(sceneView: ARSCNView,
                   scnViewLeft: ARSCNView,
                   scnViewRight: ARSCNView,
                   scnName: String) {
        
        self.sceneView = sceneView
        self.scnViewLeft = scnViewLeft
        self.scnViewRight = scnViewRight
        
        //自动锁屏
        UIApplication.shared.isIdleTimerDisabled = true
        // 防旋转
        let currentScreenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = currentScreenBrightness
        // debug帧数
        let scene = SCNScene(named: scnName)!
        
        //世界坐标原点=眼睛中点
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light?.type = SCNLight.LightType.directional
        directionalLightNode.light?.color = UIColor.red
        directionalLightNode.light?.intensity = 2000
        // 开启阴影
        directionalLightNode.light?.castsShadow = true
        sceneView.pointOfView?.addChildNode(directionalLightNode)
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, .showFeaturePoints]
        
        sceneView.isHidden = true//false
        
        // 是否显示相机内容
        if _HEADSET_IS_PASSTHROUGH_OR_SEETHROUGH {
            //sceneView.scene.background.contents = UIColor.clear
        }
        
        //左眼view
        scnViewLeft.scene = scene
        scnViewLeft.showsStatistics = sceneView.showsStatistics
        scnViewLeft.isPlaying = true
        //右眼view
        scnViewRight.scene = scene
        scnViewRight.showsStatistics = sceneView.showsStatistics
        scnViewRight.isPlaying = true
        
        cameraImageScale = cameraImageScale * 1080.0 / 720.0
        
        eyeCamera.zNear = 0.001
        
        eyeCamera.fieldOfView = CGFloat(eyeFOV)
    }
    
    func updateFrame() {
        updatePOVs()
        if _HEADSET_IS_PASSTHROUGH_OR_SEETHROUGH {
            updateImages()
        }
    }
    
    func updatePOVs() {
        let pointOfView: SCNNode = SCNNode()
        pointOfView.transform = (sceneView.pointOfView?.transform)!
        pointOfView.scale = (sceneView.pointOfView?.scale)!
        pointOfView.camera = eyeCamera
        
        let sceneViewMain = _CAMERA_IS_ON_LEFT_EYE ? scnViewLeft! : scnViewRight!
        let sceneViewScnd = _CAMERA_IS_ON_LEFT_EYE ? scnViewRight! : scnViewLeft!
        
        sceneViewMain.pointOfView = pointOfView
        
        let pointOfView2: SCNNode = (sceneViewMain.pointOfView?.clone())!
        
        //四元数/方向/不懂
        let orientation: SCNQuaternion = pointOfView2.orientation
        let orientation_glk: GLKQuaternion = GLKQuaternionMake(orientation.x,
                                                               orientation.y,
                                                               orientation.z,
                                                               orientation.w)
        let xdir: Float = _CAMERA_IS_ON_LEFT_EYE ? 1.0 : -1.0
        let alternateEyePos: GLKVector3 = GLKVector3Make(xdir, 0.0, 0.0)
        
        // Calculate Transform Vector
        let transformVector = getTransformForNewNodePovPosition(orientationQuaternion: orientation_glk, eyePosDirection: alternateEyePos, magnitude: interpupilaryDistance)
        
        // Add Transform to PointOfView2
        pointOfView2.localTranslate(by: transformVector) // works - just not entirely certain
        
        // Set PointOfView2 for SceneView-RightEye
        sceneViewScnd.pointOfView = pointOfView2
    }
    
    // buffer视频流到imageView
    func updateImages() {
        
    }
    
    private func getTransformForNewNodePovPosition(orientationQuaternion: GLKQuaternion, eyePosDirection: GLKVector3, magnitude: Float) -> SCNVector3 {
        
        // Rotate POV's-Orientation-Quaternion around Vector-to-EyePos.
        let rotatedEyePos : GLKVector3 = GLKQuaternionRotateVector3(orientationQuaternion, eyePosDirection)
        // Convert to SceneKit Vector
        let rotatedEyePos_SCNV : SCNVector3 = SCNVector3Make(rotatedEyePos.x, rotatedEyePos.y, rotatedEyePos.z)
        
        // Multiply Vector by magnitude (interpupilary distance)
        let transformVector : SCNVector3 = SCNVector3Make(rotatedEyePos_SCNV.x * magnitude,
                                                          rotatedEyePos_SCNV.y * magnitude,
                                                          rotatedEyePos_SCNV.z * magnitude)
        
        return transformVector
        
    }
}

