import Foundation

import PromiseKit

@available(macOS 10.13, *)
func appiconset(source: String, outputURL: URL) -> Promise<Void> {
    let fs = FileManager.default
    let worker = Rasterizer()

    let sizes: [UInt] = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]
    let images = sizes.map { size in worker.rasterize(source: source, width: size, height: size).map { (size, $0) } }

    return firstly {
        when(fulfilled: images)
    }.done { images in
        try fs.createDirectory(at: outputURL, withIntermediateDirectories: true)

        for (size, image) in images {
            try image.write(to: outputURL.appendingPathComponent("Icon-\(size).png"))
        }

        let contents = Contents(
            info: Contents.Info(author: "xcode", version: 1),
            images: [
                Contents.Image(filename: "Icon-40.png", idiom: "iphone", size: "20x20", scale: "2x"),
                Contents.Image(filename: "Icon-60.png", idiom: "iphone", size: "20x20", scale: "3x"),
                Contents.Image(filename: "Icon-58.png", idiom: "iphone", size: "29x29", scale: "2x"),
                Contents.Image(filename: "Icon-87.png", idiom: "iphone", size: "29x29", scale: "3x"),
                Contents.Image(filename: "Icon-80.png", idiom: "iphone", size: "40x40", scale: "2x"),
                Contents.Image(filename: "Icon-120.png", idiom: "iphone", size: "40x40", scale: "3x"),
                Contents.Image(filename: "Icon-120.png", idiom: "iphone", size: "60x60", scale: "2x"),
                Contents.Image(filename: "Icon-180.png", idiom: "iphone", size: "60x60", scale: "3x"),
                Contents.Image(filename: "Icon-20.png", idiom: "ipad", size: "20x20", scale: "1x"),
                Contents.Image(filename: "Icon-40.png", idiom: "ipad", size: "20x20", scale: "2x"),
                Contents.Image(filename: "Icon-29.png", idiom: "ipad", size: "29x29", scale: "1x"),
                Contents.Image(filename: "Icon-58.png", idiom: "ipad", size: "29x29", scale: "2x"),
                Contents.Image(filename: "Icon-40.png", idiom: "ipad", size: "40x40", scale: "1x"),
                Contents.Image(filename: "Icon-80.png", idiom: "ipad", size: "40x40", scale: "2x"),
                Contents.Image(filename: "Icon-76.png", idiom: "ipad", size: "76x76", scale: "1x"),
                Contents.Image(filename: "Icon-152.png", idiom: "ipad", size: "76x76", scale: "2x"),
                Contents.Image(filename: "Icon-167.png", idiom: "ipad", size: "83.5x83.5", scale: "2x"),
                Contents.Image(filename: "Icon-1024.png", idiom: "ios-marketing", size: "1024x1024", scale: "1x"),
                Contents.Image(filename: "Icon-120.png", idiom: "car", size: "60x60", scale: "2x"),
                Contents.Image(filename: "Icon-180.png", idiom: "car", size: "60x60", scale: "3x"),
            ]
        )

        let contentsURL = outputURL.appendingPathComponent("Contents.json")
        try JSONEncoder().encode(contents).write(to: contentsURL)
    }
}
