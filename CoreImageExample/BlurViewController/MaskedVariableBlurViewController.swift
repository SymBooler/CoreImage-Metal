//
//  MaskedVariableBlurViewController.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/11/14.
//  Copyright © 2019 symbool. All rights reserved.
//

import UIKit

class MaskedVariableBlurViewController: UIViewController {
    
    let machToSeconds: Double = {
        var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        return Double(timebase.numer) / Double(timebase.denom) * 1e-9
    }()

    var context: CIContext?
    var filter: CIFilter?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBlur(0)
    }
    
    @IBAction func slideValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        updateBlur(Double(slider.value))
    }
    
    func updateBlur(_ radius: Double) {
            
            let startTime = mach_absolute_time()
            DispatchQueue.global().async {
                guard let image = self.outputImage(filterName: CoreImageType.CIMaskedVariableBlur.rawValue, radius: radius * 100) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                let endTime = mach_absolute_time()
                print("  \(CoreImageType.CIMaskedVariableBlur.rawValue)", (self.machToSeconds * Double(endTime - startTime)))
            }
        }
    
    func outputImage(filterName: String, radius: Double) -> UIImage? {
        let sourceImage = #imageLiteral(resourceName: "Blur")
        let maskImage = #imageLiteral(resourceName: "Mask")
        let imageRect = CGRect(origin: .zero, size: sourceImage.size).muilti(ratio: UIScreen.main.scale)
        
        guard let ciImage = CIImage(image: sourceImage) else {
            return nil
        }
        guard let maskCIImage = CIImage(image: maskImage) else {
            return nil
        }
        guard let filter = CIFilter(name: filterName, parameters: [kCIInputImageKey : ciImage]) else {
            return nil
        }
        filter.setValue(NSNumber(floatLiteral: radius), forKey: .inputRadius)
        filter.setValue(maskCIImage, forKey: .inputMask)
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
