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
    
    enum RadiusBlur: Int {
        case Gassian = 0
        case Box
        case Disc
    }
    
    lazy var blurMap: [RadiusBlur: CoreImageType] = [.Gassian: .CIGaussianBlur, .Box: .CIBoxBlur, .Disc: .CIDiscBlur]
    
    let machToSeconds: Double = {
        var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        return Double(timebase.numer) / Double(timebase.denom) * 1e-9
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
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
        updateBlur(Double(slider.value))
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        imageView.image = image
        updateBlur(Double(slider.value))
    }
    
    func updateBlur(_ radius: Double, useFilter: Bool = true) {
        
        if useFilter {
            let startTime = mach_absolute_time()
            let index = segmentedControl.selectedSegmentIndex
            DispatchQueue.global().async {
                guard let blurType = RadiusBlur(rawValue: index),let image = self.outputImage(filterName: self.blurMap[blurType]!.rawValue, radius: radius * 100) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                let endTime = mach_absolute_time()
                print("  \(self.blurMap[blurType]!.rawValue)", (self.machToSeconds * Double(endTime - startTime)))
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
        let sourceImage = #imageLiteral(resourceName: "Blur")
        let imageRect = CGRect(origin: .zero, size: sourceImage.size).muilti(ratio: UIScreen.main.scale)
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
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
                return nil
            }
            let image = UIImage(cgImage: cgImage)
            
            return image
        }
}

