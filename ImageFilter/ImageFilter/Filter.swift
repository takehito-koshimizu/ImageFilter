//
//  Filter.swift
//  ImageFilter
//
//  Created by Takehito KOSHIMIZU on 2015/06/13.
//  Copyright © 2015年 Takehito KOSHIMIZU. All rights reserved.
//

import CoreImage
import Foundation

public typealias Filter = CIImage -> CIImage
internal typealias Parameters = Dictionary<String, AnyObject>

private extension CIFilter {

    convenience init?(name: String, parameters: Parameters) {
        self.init(name: name)
        setDefaults()
        for (key, value) in parameters {
            setValue(value, forKey: key)
        }
    }

    func out() -> CIImage {
        return valueForKey(kCIOutputImageKey) as! CIImage
    }
}

public struct ImageFilter {
    private init() {}

    public static func blur(radius: Double) -> Filter {
        return { image in
            let parameters : Parameters = [kCIInputRadiusKey: radius, kCIInputImageKey: image]
            let filter = CIFilter(name:"CIGaussianBlur", parameters:parameters)
            return filter!.out()
        }
    }

    public static func colorGenerator(color: UIColor) -> Filter {
        return { _ in
            let filter = CIFilter(name:"CIConstantColorGenerator", parameters: [kCIInputColorKey: color])
            return filter!.out()
        }
    }

    public static func compositeSourceOver(overlay: CIImage) -> Filter {
        return { image in
            let parameters : Parameters = [
                kCIInputBackgroundImageKey: image,
                kCIInputImageKey: overlay
            ]
            let filter = CIFilter(name:"CISourceOverCompositing", parameters: parameters)
            return filter!.out().imageByCroppingToRect(image.extent)
        }
    }

    public static func colorOverlay(color: UIColor) -> Filter {
        return { image in
            let overlay = colorGenerator(color)(image)
            return compositeSourceOver(overlay)(image)
        }
    }
}
