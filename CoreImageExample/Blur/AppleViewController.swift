/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of iOS view controller that demonstrates convolution.
*/

import UIKit
import Accelerate

let kernelLength = 51

class AppleViewController: UIViewController {
    
    let machToSeconds: Double = {
        var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        return Double(timebase.numer) / Double(timebase.denom) * 1e-9
    }()
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var mode = ConvolutionModes.hann1D {
        didSet {
            applyBlur()
        }
    }
    
    enum ConvolutionModes: String, CaseIterable {
        case hann1D
        case hann2D
        case box
        case tent
        case multi
    }
    
    let cgImage: CGImage = {
        guard let cgImage = #imageLiteral(resourceName: "Blur").cgImage else {
            fatalError("Unable to get CGImage")
        }
        
        return cgImage
    }()
    
    lazy var format: vImage_CGImageFormat = {
        guard
            let format = vImage_CGImageFormat(cgImage: cgImage) else {
                fatalError("Unable to get color space")
        }
        
        return format
    }()
    
    lazy var sourceBuffer: vImage_Buffer = {
        
        guard
            var sourceImageBuffer = try? vImage_Buffer(cgImage: cgImage),
            
            var scaledBuffer = try? vImage_Buffer(width: Int(sourceImageBuffer.width / 4),
                                                  height: Int(sourceImageBuffer.height / 4),
                                                  bitsPerPixel: format.bitsPerPixel) else {
                                                    fatalError("Can't create source buffer.")
        }
        
        vImageScale_ARGB8888(&sourceImageBuffer,
                             &scaledBuffer,
                             nil,
                             vImage_Flags(kvImageNoFlags))
        
        return scaledBuffer
    }()
    
    let hannWindow: [Float] = {
        return vDSP.window(ofType: Float.self,
                           usingSequence: .hanningDenormalized,
                           count: kernelLength ,
                           isHalfWindow: false)
    }()
    
    lazy var kernel1D: [Int16] = {
        let stride = vDSP_Stride(1)
        var multiplier = pow(Float(Int16.max), 0.25)
        
        let hannWindow1D = vDSP.multiply(multiplier, hannWindow)
        
        return vDSP.floatingPointToInteger(hannWindow1D,
                                           integerType: Int16.self,
                                           rounding: vDSP.RoundingMode.towardNearestInteger)
    }()
    
    lazy var kernel2D: [Int16] = {
        let stride = vDSP_Stride(1)
        
        var hannWindow2D = [Float](repeating: 0,
                                   count: kernelLength * kernelLength)
        
        cblas_sger(CblasRowMajor,
                   Int32(kernelLength), Int32(kernelLength),
                   1, kernel1D.map { return Float($0) },
                   1, kernel1D.map { return Float($0) },
                   1,
                   &hannWindow2D,
                   Int32(kernelLength))
        
        return vDSP.floatingPointToInteger(hannWindow2D,
                                           integerType: Int16.self,
                                           rounding: vDSP.RoundingMode.towardNearestInteger)
    }()
    
    var destinationBuffer = vImage_Buffer()
    
    func buildUI() {
        let segmentedControl = UISegmentedControl(items: ConvolutionModes.allCases.map { return $0.rawValue })
        
        segmentedControl.selectedSegmentIndex = ConvolutionModes.allCases.firstIndex(of: mode) ?? -1
        
        segmentedControl.addTarget(self,
                                   action: #selector(segmentedControlChangeHandler),
                                   for: .valueChanged)
        
        toolbar.setItems([UIBarButtonItem(customView: segmentedControl)],
                         animated: false)
    }
    
    @objc
    func segmentedControlChangeHandler(segmentedControl: UISegmentedControl) {
        if let title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex),
            let newMode = ConvolutionModes(rawValue: title) {
            mode = newMode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        
        applyBlur()
    }
    
    func applyBlur() {
        do {
            destinationBuffer = try vImage_Buffer(width: Int(sourceBuffer.width),
                                                  height: Int(sourceBuffer.height),
                                                  bitsPerPixel: format.bitsPerPixel)
        } catch {
            return
        }
        
        switch mode {
        case .hann1D:
            hann1D()
        case .hann2D:
            hann2D()
        case .tent:
            tent()
        case .box:
            box()
        case.multi:
            multi()
        }
        
        if let result = try? destinationBuffer.createCGImage(format: format) {
            imageView.image = UIImage(cgImage: result)
        }
        
        destinationBuffer.free()
    }
}
