import UIKit

protocol AGFilter {
    func applyFilter(image: RGBAImage)
    func changePixel(inout pixel: Pixel)
}

class AGColourFilter : AGFilter {
    
    var intensity: Float
    var colourFilterFunction: ((inout Pixel) -> Void)? = nil
    
    init (colourToFilter: String, intensity: Float) {
        self.intensity = intensity
        switch colourToFilter {
        case "red": colourFilterFunction = { pixel in
                pixel.green = pixel.green - UInt8(Double(pixel.green) * Double(self.intensity) / 100.0)
                pixel.blue = pixel.blue - UInt8(Double(pixel.blue) * Double(self.intensity) / 100.0)
            }
        case "green": colourFilterFunction = { pixel in
                pixel.red = pixel.red - UInt8(Double(pixel.red) * Double(self.intensity) / 100.0)
                pixel.blue = pixel.blue - UInt8(Double(pixel.blue) * Double(self.intensity) / 100.0)
            }
        case "blue": colourFilterFunction = { pixel in
                pixel.red = pixel.red - UInt8(Double(pixel.red) * Double(self.intensity) / 100.0)
                pixel.green = pixel.green - UInt8(Double(pixel.green) * Double(self.intensity) / 100.0)
            }
        default: colourFilterFunction = { pixel in
            }
        }
    }
    
    func applyFilter(image: RGBAImage) {
        for heightIndex in 0..<image.height {
            for widthIndex in 0..<image.width {
                let index = heightIndex * image.width + widthIndex
                self.changePixel(&image.pixels[index])
            }
        }
    }
    
    func changePixel(inout pixel: Pixel) {
        self.colourFilterFunction!(&pixel)
    }
    
}

class AGBlackAndWhiteFilter : AGFilter {
    
    var intensity: Float
    
    init (intensity: Float) {
        self.intensity = intensity
    }
    
    func applyFilter(image: RGBAImage) {
        for heightIndex in 0..<image.height {
            for widthIndex in 0..<image.width {
                let index = heightIndex * image.width + widthIndex
                self.changePixel(&image.pixels[index])
            }
        }
    }
    
    func changePixel(inout pixel: Pixel) {
        
        let medianValue = (UInt32(pixel.red) + UInt32(pixel.green) + UInt32(pixel.blue)) / 3
        
        let filteredValue = Pixel(value: (UInt32(medianValue) | (UInt32(medianValue) << 8) | (UInt32(medianValue) << 16) | (UInt32(pixel.alpha) << 24)))
        
        pixel.red = UInt8(Double(pixel.red) + Double(Int(filteredValue.red) - Int(pixel.red)) * Double(self.intensity) / 100)
        pixel.green = UInt8(Double(pixel.green) + Double(Int(filteredValue.green) - Int(pixel.green)) * Double(self.intensity) / 100)
        pixel.blue = UInt8(Double(pixel.blue) + Double(Int(filteredValue.blue) - Int(pixel.blue)) * Double(self.intensity) / 100)
    }
    
}

class AGSepiaFilter : AGFilter {
    
    var intensity: Float
    
    init (intensity: Float) {
        self.intensity = intensity
    }
    
    func applyFilter(image: RGBAImage) {
        for heightIndex in 0..<image.height {
            for widthIndex in 0..<image.width {
                let index = heightIndex * image.width + widthIndex
                self.changePixel(&image.pixels[index])
            }
        }
    }
    
    func changePixel(inout pixel: Pixel) {
        pixel.red = UInt8(min(255,
            Double(pixel.red) - (Double(pixel.red) - Double(pixel.red) * 0.393) * Double(self.intensity) / 100 +
            Double(pixel.green) - (Double(pixel.green) - Double(pixel.green) * 0.769) * Double(self.intensity) / 100 +
            Double(pixel.blue) - (Double(pixel.blue) - Double(pixel.blue) * 0.189) * Double(self.intensity) / 100))
        pixel.green = UInt8(min(255,
            Double(pixel.red) - (Double(pixel.red) - Double(pixel.red) * 0.349) * Double(self.intensity) / 100 +
            Double(pixel.green) - (Double(pixel.green) - Double(pixel.green) * 0.686) * Double(self.intensity) / 100 +
            Double(pixel.blue) - (Double(pixel.blue) - Double(pixel.blue) * 0.168) * Double(self.intensity) / 100))
        pixel.blue = UInt8(min(255,
            Double(pixel.red) - (Double(pixel.red) - Double(pixel.red) * 0.272) * Double(self.intensity) / 100 +
            Double(pixel.green) - (Double(pixel.green) - Double(pixel.green) * 0.534) * Double(self.intensity) / 100 +
            Double(pixel.blue) - (Double(pixel.blue) - Double(pixel.blue) * 0.131) * Double(self.intensity) / 100))
    }
    
}

class AGBrightnessFilter : AGFilter {
    
    var brightnessDelta: Int = 0
    
    init (intensity: Float) {
        self.brightnessDelta = Int(255 * (intensity * 2 - 100) / 100)
    }
    
    func applyFilter(image: RGBAImage) {
        for heightIndex in 0..<image.height {
            for widthIndex in 0..<image.width {
                let index = heightIndex * image.width + widthIndex
                self.changePixel(&image.pixels[index])
            }
        }
    }
    
    func changePixel(inout pixel: Pixel) {
        pixel.red = UInt8(max(0, min(255, Int(pixel.red) + brightnessDelta)))
        pixel.green = UInt8(max(0, min(255, Int(pixel.green) + brightnessDelta)))
        pixel.blue = UInt8(max(0, min(255, Int(pixel.blue) + brightnessDelta)))
    }
    
}
/*
class AGContrastFilter : AGFilterOld {
    
    var averageRed: Int = 0
    var averageGreen: Int = 0
    var averageBlue: Int = 0
    
    var deltaCoefficient: Double = 1.0
    
    init (deltaCoefficient: Double) {
        self.deltaCoefficient = deltaCoefficient
    }
    
    func applyFilter(image: RGBAImage) {
        for heightIndex in 0..<image.height {
            for widthIndex in 0..<image.width {
                let index = heightIndex * image.width + widthIndex
                let pixel = image.pixels[index]
                self.averageRed += Int(pixel.red)
                self.averageGreen += Int(pixel.green)
                self.averageBlue += Int(pixel.blue)
            }
        }
        
        self.averageRed /= (image.width * image.height)
        self.averageGreen /= (image.width * image.height)
        self.averageBlue /= (image.width * image.height)
        
        for heightIndex in 0..<image.height {
            for widthIndex in 0..<image.width {
                let index = heightIndex * image.width + widthIndex
                self.changePixel(&image.pixels[index])
            }
        }
    }
    
    func changePixel(inout pixel: Pixel) {
        pixel.red = self.getDelta(UInt8(self.averageRed), value: pixel.red)
        pixel.green = self.getDelta(UInt8(self.averageGreen), value: pixel.green)
        pixel.blue = self.getDelta(UInt8(self.averageBlue), value: pixel.blue)
    }
    
    func getDelta(average: UInt8, value: UInt8) -> UInt8 {
        let delta: Int = Int(value) - Int(average)
        let theoreticalValue: Int = Int(value) + Int(Double(delta) * self.deltaCoefficient)
        return UInt8(max(min(theoreticalValue, 255), 0))
    }
    
}*/

enum AGFilterNames : String {
    case Brightness
    case ColourRed
    case ColourGreen
    case ColourBlue
    case BlackAndWhite
}

class AGImageProcessor {
    
    var image: RGBAImage? = nil
    var filter: AGFilter? = nil
    
    func addFilter(filterName: AGFilterNames, intensity: Float) {
        var filter: AGFilter? = nil
        switch filterName {
        case AGFilterNames.Brightness : filter = AGBrightnessFilter(intensity: intensity)
        case AGFilterNames.ColourRed : filter = AGColourFilter(colourToFilter: "red", intensity: intensity)
        case AGFilterNames.ColourGreen : filter = AGColourFilter(colourToFilter: "green", intensity: intensity)
        case AGFilterNames.ColourBlue : filter = AGColourFilter(colourToFilter: "blue", intensity: intensity)
        case AGFilterNames.BlackAndWhite : filter = AGBlackAndWhiteFilter(intensity: intensity)
        }
        self.filter = filter!
    }
    
    func applyFilter() {
        self.filter!.applyFilter(self.image!)
    }
    
    func getImage() -> UIImage {
        return self.image!.toUIImage()!
    }
    
    func setImage(image: UIImage) {
        self.image = RGBAImage(image: image)!
    }
    
}
