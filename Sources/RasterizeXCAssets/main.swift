import Foundation

import Commander
import PromiseKit

import WebKit

struct Contents: Codable {
    struct Info: Codable {
        let author: String
        let version: Int
    }

    struct Image: Codable {
        let filename: String
        let idiom: String
        let size: String
        let scale: String
    }

    let info: Info
    let images: [Image]
}

enum UserError: Error, CustomStringConvertible {
    case unsupportedOS
    case unexpectedAssetType(String)
    case unexpectedContainerType(String)

    var description: String {
        switch self {
        case .unsupportedOS: return "Only macOS 10.13 and newer is supported..."
        case .unexpectedAssetType(let type): return "Unexpected asset type: \(type)"
        case .unexpectedContainerType(let type): return "Unexpected container type: \(type)"
        }
    }
}

func main(source: String, output: String) throws {
    guard #available(macOS 10.13, *) else {
        throw UserError.unsupportedOS
    }

    let fs = FileManager.default

    let sourceURL = URL(fileURLWithPath: source)
    let outputURL = URL(fileURLWithPath: output)

    if outputURL.pathExtension != "appiconset" {
        throw UserError.unexpectedAssetType(outputURL.pathExtension)
    }

    let xcassetsURL = outputURL.deletingLastPathComponent()

    if xcassetsURL.pathExtension != "xcassets" {
        throw UserError.unexpectedContainerType(xcassetsURL.pathExtension)
    }

    let sourceString = String(data: try Data(contentsOf: sourceURL), encoding: .utf8)!

    var worker = Rasterizer()
    let sizes: [UInt] = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]
    let images = sizes.map { size in worker.rasterize(source: sourceString, width: size, height: size).map { (size, $0) } }

    firstly {
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

        exit(0)
    }.catch { err in
        fatalError("\(err)")
    }

    CFRunLoopRun()
}

command(
    Argument<String>("source", description: "Source SVG file"),
    Argument<String>("output", description: "Output path for resulting asset"),
    main
).run()
