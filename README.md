# RasterizeXCAssets

Rasterize svg files into your XCAssets.

## Installation

Installation via [Mint](https://github.com/yonaskolb/Mint):

```sh
mint install LinusU/RasterizeXCAssets
```

## Usage

e.g. converting `logo.svg` to an appiconset xcasset:

```sh
rasterizexcassets logo.svg Sources/Assets.xcassets/AppIcon.appiconset
```

The command will load the svg file `logo.svg`, and then rasterize it to all sizes that should be present for an appiconset. It will also create the neccesary `Contents.json` file, and create `Assets.xcassets` if it doesn't exist.
