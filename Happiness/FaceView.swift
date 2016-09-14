//
//  HappinessView.swift
//  Happiness
//
//  Created by iKing on 13.05.15.
//  Copyright (c) 2015 iKing. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForFaceView(_ sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {
    
    weak var dataSource: FaceViewDataSource?

    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.green { didSet { setNeedsDisplay() } }
    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var rotation: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    var faceCenter: CGPoint {
//        return convertPoint(center, fromView: superview)
        return CGPoint(x: 0, y: 0)
    }
    var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    func scale(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            lineWidth *= gesture.scale
            gesture.scale = 1
        }
    }
    
    func rotate(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed {
            rotation = gesture.rotation
        }
    }
    
    fileprivate struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetsRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetsRatio: CGFloat = 3
    }
    
    fileprivate enum Eye {
        case left, right
    }
    
    fileprivate func bezierPathForEye(_ whichEye: Eye) -> UIBezierPath {
        
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetsRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        
        switch whichEye {
        case .left:
            eyeCenter.x -= eyeHorizontalSeparation / 2
        case .right:
            eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    fileprivate func bezierPathForSmile(_ fractionOfMaxSmile: Double) -> UIBezierPath {
        
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthverticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetsRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthverticalOffset)
        let end = CGPoint(x: faceCenter.x + mouthWidth / 2, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {

        let affineRotation = CGAffineTransform(rotationAngle: rotation)
        let affineTranslation = CGAffineTransform(translationX: bounds.width / 2, y: bounds.height / 2)
        

        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
//        facePath.stroke()
        
//        bezierPathForEye(.Left).stroke()
//        bezierPathForEye(.Right).stroke()

        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0
//        bezierPathForSmile(smiliness).stroke()
        
        facePath.append(bezierPathForEye(.left))
        facePath.append(bezierPathForEye(.right))
        facePath.append(bezierPathForSmile(smiliness))
        facePath.apply(affineRotation)
        facePath.apply(affineTranslation)
        facePath.stroke()
    }

}
