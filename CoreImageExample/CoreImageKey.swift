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
}

enum CoreImageType: String {
    case CIGaussianBlur
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
