# RasterizeXCAssets

Rasterize svg files into your XCAssets.

## Installation

Installation via [Mint](https://github.com/yonaskolb/Mint):

```sh
mint install LinusU/RasterizeXCAssets
```

## Usage

**converting `logo.svg` to an appiconset xcasset:**

```sh
rasterizexcassets logo.svg Sources/Assets.xcassets/AppIcon.appiconset
```

The command will load the svg file `logo.svg`, and then rasterize it to all sizes that should be present for an appiconset. It will also create the neccesary `Contents.json` file, and create `Assets.xcassets` if it doesn't exist.

**converting `greeting.svg` to an imageset xcasset:**

```sh
rasterizexcassets greeting.svg Sources/Assets.xcassets/Greeting.imageset --size 120x200
```

The command will load the svg file `logo.svg`, and then rasterize it to the size specified at 1x, 2x and 3x. It will also create the neccesary `Contents.json` file, and create `Assets.xcassets` if it doesn't exist.
