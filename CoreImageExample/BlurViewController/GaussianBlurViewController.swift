//
//  GaussianBlurViewController.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/10/31.
//  Copyright © 2019 symbool. All rights reserved.
//

//import Accelerate
//vImageBoxConvolve_ARGB8888 是Accelerate 提供的方法
//[参考](https://github.com/card-io/card.io-iOS-source/blob/master/Classes/UIImage%2BImageEffects.h)
import UIKit
import CoreImage

class GaussianBlurViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    var image = UIImage(named: .Blur)
    
    var context: CIContext?
    var filter: CIFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateBlur(0.1)
    }
    
    @IBAction func slideValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        updateBlur(Double(slider.value), useFilter: false)
    }
    
    func updateBlur(_ radius: Double, useFilter: Bool = true) {
        if useFilter {
            DispatchQueue.global().async {
                guard let image = self.outputImage(filterName: CoreImageType.CIGaussianBlur.rawValue, radius: radius * 100) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        } else {
            guard let image = image?.applyBlur(blurRadius: CGFloat(radius * 100), tintColor: UIColor.clear, saturationDeltaFactor: 1) else {
                return
            }
//            guard let image = image?.applyDarkEffect() else {
//                return
//            }
            imageView.image = image
        }
    }
    
    func outputImage(filterName: String, radius: Double) -> UIImage? {
            guard let sourceImage = image else {
                return nil
            }
            guard let ciImage = CIImage(image: sourceImage) else {
                return nil
            }
            guard let filter = CIFilter(name: filterName, parameters: [kCIInputImageKey : ciImage]) else {
                return nil
            }
            filter.setValue(NSNumber(floatLiteral: radius), forKey: .inputRadius)
            self.filter = filter
            debugPrint(filter.attributes)
    //        filter?.attributes 可以查看当前滤镜支持的所有属性， 设置不支持的属性会crash
            guard let outputImage = filter.outputImage else {
                return nil
            }
            let context = CIContext(options: nil)
            self.context = context
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            let image = UIImage(cgImage: cgImage)
            
            return image
        }
}

