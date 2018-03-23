import Foundation

import PromiseKit

@available(macOS 10.13, *)
func imageset(source: String, outputURL: URL, size: Size) -> Promise<Void> {
    let fs = FileManager.default
    let worker = Rasterizer()

    let sizes = [size, size.scaled(2), size.scaled(3)]
    let images = sizes.map { worker.rasterize(source: source, width: $0.width, height: $0.height) }

    return firstly {
        when(fulfilled: images)
    }.done { images in
        try fs.createDirectory(at: outputURL, withIntermediateDirectories: true)

        try images[0].write(to: outputURL.appendingPathComponent("Image@1x.png"))
        try images[1].write(to: outputURL.appendingPathComponent("Image@2x.png"))
        try images[2].write(to: outputURL.appendingPathComponent("Image@3x.png"))

        let contents = Contents(
            info: Contents.Info(author: "xcode", version: 1),
            images: [
                Contents.Image(filename: "Image@1x.png", idiom: "universal", size: size.description, scale: "1x"),
                Contents.Image(filename: "Image@2x.png", idiom: "universal", size: size.description, scale: "2x"),
                Contents.Image(filename: "Image@3x.png", idiom: "universal", size: size.description, scale: "3x"),
            ]
        )

        let contentsURL = outputURL.appendingPathComponent("Contents.json")
        try JSONEncoder().encode(contents).write(to: contentsURL)
    }
}
