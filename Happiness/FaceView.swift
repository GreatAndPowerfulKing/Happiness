//
//  HappinessView.swift
//  Happiness
//
//  Created by iKing on 13.05.15.
//  Copyright (c) 2015 iKing. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {
    
    weak var dataSource: FaceViewDataSource?

    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.greenColor() { didSet { setNeedsDisplay() } }
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
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            lineWidth *= gesture.scale
            gesture.scale = 1
        }
    }
    
    func rotate(gesture: UIRotationGestureRecognizer) {
        if gesture.state == .Changed {
            rotation = gesture.rotation
        }
    }
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetsRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetsRatio: CGFloat = 3
    }
    
    private enum Eye {
        case Left, Right
    }
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
        
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetsRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        
        switch whichEye {
        case .Left:
            eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right:
            eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath {
        
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthverticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetsRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthverticalOffset)
        let end = CGPoint(x: faceCenter.x + mouthWidth / 2, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    override func drawRect(rect: CGRect) {

        let affineRotation = CGAffineTransformMakeRotation(rotation)
        let affineTranslation = CGAffineTransformMakeTranslation(bounds.width / 2, bounds.height / 2)
        

        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
//        facePath.stroke()
        
//        bezierPathForEye(.Left).stroke()
//        bezierPathForEye(.Right).stroke()

        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0
//        bezierPathForSmile(smiliness).stroke()
        
        facePath.appendPath(bezierPathForEye(.Left))
        facePath.appendPath(bezierPathForEye(.Right))
        facePath.appendPath(bezierPathForSmile(smiliness))
        facePath.applyTransform(affineRotation)
        facePath.applyTransform(affineTranslation)
        facePath.stroke()
    }

}
