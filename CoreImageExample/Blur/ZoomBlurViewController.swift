//
//  MaskedVariableBlurViewController.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/11/14.
//  Copyright © 2019 symbool. All rights reserved.
//

import UIKit
import Combine

class ZoomBlurViewController: UIViewController {
    
    let machToSeconds: Double = {
        var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        return Double(timebase.numer) / Double(timebase.denom) * 1e-9
    }()

    var context: CIContext?
    var filter: CIFilter?
    
    var cancelable: AnyCancellable?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var yTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
        cancelable = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification).map({ ($0.object as! UITextField).text
        }).sink(receiveCompletion: { (completion) in
            debugPrint("test")
        }) { [unowned self] noti in
            self.updateBlur()
        }
        
        updateBlur()
    }
    
    @IBAction func slideValueChanged(_ sender: Any) {
        updateBlur()
    }
    
    @objc func textFieldDidChange() {
        updateBlur()
    }
    
    @objc func updateBlur() {
        guard let xs = xTextField.text, let ys = yTextField.text, let x = Double(xs), let y = Double(ys)  else {
            return
        }
        updateBlur(CGPoint(x: x, y: y) , Double(slider.value * 100))
    }
    
    func updateBlur(_ point: CGPoint, _ zoom: Double) {
            
            let startTime = mach_absolute_time()
            DispatchQueue.global().async {
                guard let image = self.outputImage(filterName: CoreImageType.CIZoomBlur.rawValue, origin: CIVector(cgPoint: point), zoom: zoom) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                let endTime = mach_absolute_time()
                print("  \(CoreImageType.CIMaskedVariableBlur.rawValue)", (self.machToSeconds * Double(endTime - startTime)))
            }
        }
    
    func outputImage(filterName: String, origin: CIVector, zoom: Double) -> UIImage? {
        let sourceImage = #imageLiteral(resourceName: "Blur")
        
        guard let ciImage = CIImage(image: sourceImage) else {
            return nil
        }
        guard let filter = CIFilter(name: filterName, parameters: [kCIInputImageKey : ciImage]) else {
            return nil
        }
        filter.setValue(origin, forKey: .inputCenter)
        filter.setValue(NSNumber(floatLiteral: zoom), forKey: .inputAmount)
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

extension ZoomBlurViewController: UITextFieldDelegate {
}
