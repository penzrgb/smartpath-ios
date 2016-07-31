//
//  LightSurface.swift
//  SmartPathClient
//
//  Created by Glenn Schmidt on 30/07/2016.
//  Copyright © 2016 SmartPath. All rights reserved.
//

import UIKit

class LightSurface: UIView {
    
    private var lights: [LightSource] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.postInit()
    }
    
    override func drawRect(rect: CGRect) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = self.bounds.width
        let height = self.bounds.height
        let imageScale = self.contentScaleFactor
        
        //Create white-to-black radial gradient
        let colors: [CGFloat] = [1.0, 1.0, 1.0, 1.0,
                                 0.0, 0.0, 0.0, 1.0]
        let gradient = CGGradientCreateWithColorComponents(colorSpace, colors, [0.0, 1.0], 2)
        
        //Create mask
        var imgCtx = CGBitmapContextCreate(nil, Int(width * imageScale), Int(height * imageScale), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        CGContextSetRGBFillColor(imgCtx, 0, 0, 0, 1)
        CGContextFillRect(imgCtx, CGRectMake(0, 0, width * imageScale, height * imageScale))
        CGContextSetBlendMode(imgCtx, .PlusLighter)
        for light in self.lights {
            let pixelCoord = CGPointMake(light.center.x * imageScale, light.center.y * imageScale)
            CGContextDrawRadialGradient(imgCtx, gradient, pixelCoord, 0,
                                        pixelCoord, light.radius * imageScale, [])
        }
        var image = CGBitmapContextCreateImage(imgCtx)
        let mask = CGImageMaskCreate(
            CGImageGetWidth(image),
            CGImageGetHeight(image),
            CGImageGetBitsPerComponent(image),
            CGImageGetBitsPerPixel(image),
            CGImageGetBytesPerRow(image),
            CGImageGetDataProvider(image),
            nil,
            true
        )
        
        //Create image
        imgCtx = CGBitmapContextCreate(nil, Int(width * imageScale), Int(height * imageScale), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        CGContextSetRGBFillColor(imgCtx, 0, 0, 0, 1)
        CGContextFillRect(imgCtx, CGRectMake(0, 0, width * imageScale, height * imageScale))
        image = CGImageCreateWithMask(CGBitmapContextCreateImage(imgCtx), mask)
        
        //Draw image
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, self.bounds, image)
    }
    
    private func postInit() {
        self.contentMode = .Redraw
        self.userInteractionEnabled = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    func addLight(light: LightSource) {
        self.lights.append(light)
        self.setNeedsDisplay()
    }
    
    func removeAllLights() {
        self.lights.removeAll()
        self.setNeedsDisplay()
    }
}

class LightSource: NSObject {
    var center: CGPoint
    var radius: CGFloat
    var color: UIColor
    
    init(center: CGPoint, radius: CGFloat, color: UIColor) {
        self.center = center
        self.radius = radius
        self.color = color
        super.init()
    }
}
