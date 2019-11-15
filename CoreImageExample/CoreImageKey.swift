//
//  CoreImageKey.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/11/11.
//  Copyright © 2019 symbool. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

enum CoreImageKey: String {
    case inputRadius
    case inputMask
    case inputAngle
}

enum CoreImageType: String {
    case CIGaussianBlur
    case CIDiscBlur
    case CIBoxBlur
    case CIMaskedVariableBlur
    case CIMotionBlur
    case CIMedianFilter
}

enum ImageName: String {
    case Blur
}

extension CIFilter {
    
    func setValue(_ value: Any?, forKey key: CoreImageKey) {
        setValue(value, forKey: key.rawValue)
    }
}

extension UIImage {
    convenience init?(named: ImageName) {
        self.init(named: named.rawValue)
    }
}

extension CGRect {
    
    func muilti(ratio: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: CGSize(width: size.width * ratio, height: size.height * ratio))
    }
}
