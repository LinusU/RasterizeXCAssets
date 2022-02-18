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
    case invalidSize(String)

    var description: String {
        switch self {
        case .unsupportedOS: return "Only macOS 10.13 and newer is supported..."
        case .unexpectedAssetType(let type): return "Unexpected asset type: \(type)"
        case .unexpectedContainerType(let type): return "Unexpected container type: \(type)"
        case .invalidSize(let size): return "Invalid size: \(size)"
        }
    }
}

func main(source: String, output: String, size: Size) throws -> Promise<Void> {
    guard #available(macOS 10.13, *) else {
        throw UserError.unsupportedOS
    }

    let sourceURL = URL(fileURLWithPath: source)
    let outputURL = URL(fileURLWithPath: output)

    let xcassetsURL = outputURL.deletingLastPathComponent()

    if xcassetsURL.pathExtension != "xcassets" {
        throw UserError.unexpectedContainerType(xcassetsURL.pathExtension)
    }

    let sourceString = String(data: try Data(contentsOf: sourceURL), encoding: .utf8)!

    switch outputURL.pathExtension {
        case "appiconset": return appiconset(source: sourceString, outputURL: outputURL)
        case "imageset": return imageset(source: sourceString, outputURL: outputURL, size: size)
        default: throw UserError.unexpectedAssetType(outputURL.pathExtension)
    }
}

command(
    Argument<String>("source", description: "Source SVG file"),
    Argument<String>("output", description: "Output path for resulting asset"),
    Option<Size>("size", default: Size(width: 64, height: 64), description: "Size (in points) of the output asset (e.g. 120x120)"),
    main
).run()
