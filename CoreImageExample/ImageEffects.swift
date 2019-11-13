//
//  ImageEffects.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/11/12.
//  Copyright © 2019 symbool. All rights reserved.
//

//可develop document搜索 vImageBoxConvolve_ARGB8888， 查看blur image
//InterLeaved image format: RGBA_RGBA_RGBA
//Planar image format:      RRR_GGG_BBB_AAA

import UIKit
import Accelerate

extension CGFloat {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension vImage_Buffer {
    init(context: CGContext) {
        self.init(data: context.data, height:vImagePixelCount(context.height), width: vImagePixelCount(context.width), rowBytes: context.bytesPerRow)
    }
}

extension UIImage {
    
    func applyLightEffect() -> UIImage? {
        let tintColor = UIColor(white: 1.0, alpha: 0.3)
        return applyBlur(blurRadius: 20, tintColor: tintColor, saturationDeltaFactor: 1.8)
    }
    
    func applyExtraLightEffect() -> UIImage? {
        let tintColor = UIColor(white: 0.97, alpha: 0.82)
        return applyBlur(blurRadius: 20, tintColor: tintColor, saturationDeltaFactor: 1.8)
    }
    
    func applyDarkEffect() -> UIImage? {
        let tintColor = UIColor(white: 0.11, alpha: 0.73)
        return applyBlur(blurRadius: 20, tintColor: tintColor, saturationDeltaFactor: 1.8)
    }
    
    func applyTintEffect(tintColor: UIColor) -> UIImage? {
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor
        let componentCount = tintColor.cgColor.numberOfComponents
        if componentCount == 2 {
            var b: CGFloat = 0
            if tintColor.getWhite(&b, alpha: nil) {
                effectColor = UIColor(white: b, alpha: effectColorAlpha)
            }
        } else {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            if tintColor.getRed(&r, green: &g, blue: &b, alpha: nil) {
                effectColor = UIColor(red: r, green: g, blue: b, alpha: effectColorAlpha)
            }
        }
        return applyBlur(blurRadius: 10, tintColor: effectColor, saturationDeltaFactor: -1.0)
    }
    
    func applyBlur(blurRadius: CGFloat, tintColor: UIColor, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
//        if (self.size.width < 1 || self.size.height < 1) {
//            NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
//            return nil;
//        }
        let f = ".2"
        guard size.width >= 1, size.height >= 1 else {
            debugPrint("*** error: invalid size: (\(size.width.format(f)) x \(size.height.format(f))). Both dimensions must be >= 1: \(self)")
            return nil
        }
        guard let _cgImage = cgImage else {
            debugPrint("*** error: image must be backed by a CGImage:\(self)")
            return nil
        }
        
        if let _maskImage = maskImage, _maskImage.cgImage == nil {
            debugPrint("*** error: maskImage must be backed by a CGImage: \(maskImage!)")
            return nil
        }
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let imageRect = CGRect(origin: CGPoint.zero, size: size)
        var effectImage = self
        //CGFloat.ulpOfOne 代替了 __FLT_EPSILON__
        let hasBlur = blurRadius > CGFloat.ulpOfOne
        let hasSaturationChange = abs(saturationDeltaFactor - 1) > CGFloat.ulpOfOne
        if hasBlur || hasSaturationChange {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let effectInContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            effectInContext.scaleBy(x: 1.0, y: -1.0)
            effectInContext.translateBy(x: 0, y: -size.height)
            effectInContext.draw(_cgImage, in: imageRect)
            var effectInBuffer = vImage_Buffer(context: effectInContext)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let effectOutContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            var effectOutBuffer = vImage_Buffer(context: effectOutContext)
            if hasBlur {
                let inputRadius: Double = Double(blurRadius * UIScreen.main.scale)
                let floatRadius: Double = inputRadius * 3 * sqrt(2 * .pi) / 4
                var radius: UInt32 = UInt32(floor(floatRadius + 0.5))
                if radius % 2 != 1 {
                    radius += 1
                }
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
            }
            var effectImageBuffersAreSwapped = false
            if hasSaturationChange {
                let s = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                                      0,                    0,                    0,  1,
                ]
                let divisor: Int32 = 256
//                let matrixSize: UInt = UInt(MemoryLayout.size(ofValue: floatingPointSaturationMatrix)/MemoryLayout.size(ofValue: floatingPointSaturationMatrix.first))
//                var saturationMatrix: [Int16] = [Int16](repeating: 0, count: Int(matrixSize))
                let saturationMatrix = floatingPointSaturationMatrix.map {
                    Int16(roundf(float_t($0 * CGFloat(divisor))))
                }
                if hasBlur {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, nil, nil, vImage_Flags(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true
                } else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, nil, nil, vImage_Flags(kvImageNoFlags))
                }
            }
            if !effectImageBuffersAreSwapped {
                guard let unwrappedImage = UIGraphicsGetImageFromCurrentImageContext() else {
                    return nil
                }
                effectImage = unwrappedImage
            }
            UIGraphicsEndImageContext()
            if effectImageBuffersAreSwapped {
                guard let unwrappedImage = UIGraphicsGetImageFromCurrentImageContext() else {
                    return nil
                }
                effectImage = unwrappedImage
            }
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let outputContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        outputContext.scaleBy(x: 1.0, y: -1.0)
        outputContext.translateBy(x: 0, y: -size.height)
        outputContext.draw(_cgImage, in: imageRect)
        if hasBlur {
            outputContext.saveGState()
            if let _maskImage = maskImage,let _maskCgImage = _maskImage.cgImage {
                outputContext.clip(to: imageRect, mask: _maskCgImage)
            }
            if let cgImage = effectImage.cgImage {
                outputContext.draw(cgImage, in: imageRect)
            }
            outputContext.restoreGState()
        }
        outputContext.saveGState()
        outputContext.setFillColor(tintColor.cgColor)
        outputContext.fill(imageRect)
        outputContext.restoreGState()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
