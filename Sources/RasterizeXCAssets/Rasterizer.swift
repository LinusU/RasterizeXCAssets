import Foundation

import JSBridge
import PromiseKit

fileprivate let libraryCode = """
window.rasterize = function (source, width, height) {
    return new Promise((resolve, reject) => {
        const canvas = document.createElement('canvas')
        const image = new Image()
        const ctx = canvas.getContext('2d')

        canvas.width = width
        canvas.height = height

        image.onload = () => {
            ctx.drawImage(image, 0, 0, width, height)
            resolve(canvas.toDataURL('image/png').slice(22))
        }

        image.onerror = () => {
            reject(new Error('Failed to render SVG'))
        }

        image.src = `data:image/svg+xml;base64,${btoa(source)}`
    })
}
"""

@available(macOS 10.13, *)
class Rasterizer {
    fileprivate lazy var bridge = JSBridge(libraryCode: libraryCode)

    func rasterize(source: String, width: UInt, height: UInt) -> Promise<Data> {
        return firstly {
            self.bridge.call(function: "rasterize", withArgs: (source, width, height)) as Promise<String>
        }.map {
            Data(base64Encoded: $0)!
        }
    }
}
