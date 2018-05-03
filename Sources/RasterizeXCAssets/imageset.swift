import Foundation

import PromiseKit

@available(macOS 10.13, *)
func imageset(source: String, outputURL: URL, sizes: [Size]) -> Promise<Void> {
    let fs = FileManager.default
    let worker = Rasterizer()

    var rasterizedSizes = Set<Size>()

    for size in sizes {
        rasterizedSizes.insert(size)
        rasterizedSizes.insert(size.scaled(2))
        rasterizedSizes.insert(size.scaled(3))
    }

    let images = rasterizedSizes.map { size in
        worker.rasterize(source: source, width: size.width, height: size.height).map { image in (size, image) }
    }

    return firstly {
        when(fulfilled: images)
    }.done { images in
        try fs.createDirectory(at: outputURL, withIntermediateDirectories: true)

        for (size, image) in images {
            try image.write(to: outputURL.appendingPathComponent("Image-\(size).png"))
        }

        var contentImages = Array<Contents.Image>()

        for size in sizes {
            for scale in [UInt]([1, 2, 3]) {
                contentImages.append(.init(filename: "Image-\(size.scaled(scale)).png", idiom: "universal", size: size.description, scale: "\(scale)x"))
            }
        }

        let contents = Contents(
            info: Contents.Info(author: "xcode", version: 1),
            images: contentImages
        )

        let contentsURL = outputURL.appendingPathComponent("Contents.json")
        try JSONEncoder().encode(contents).write(to: contentsURL)
    }
}
