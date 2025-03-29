# stitcher

A boilerplate Flutter project that utilizes the [`opencv_core`](https://pub.dev/packages/opencv_dart) dart package.

## How to Use the App

### Prerequisites
1. Ensure you have Flutter installed on your system. Follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install) if needed.
2. Install the required dependencies by running:
    ```bash
    flutter pub get
    ```

### Running the App
1. Connect a physical device or start an emulator.
2. Run the app using:
    ```bash
    flutter run
    ```

### How It Works
1. The app allows you to upload multiple images for stitching.
2. Images are processed using the `opencv_core` package, which handles image manipulation and stitching.
3. The stitched image is displayed on the app using the `Image.memory` widget.

### Features
- Upload multiple images.
- Automatically stitch images into a single panoramic view.
- Save the stitched image locally.

### Notes
- Ensure the images have overlapping regions for better stitching results.
- The app uses OpenCV's image stitching algorithms for high-quality output.
- Refer to the [opencv_core documentation](https://pub.dev/packages/opencv_dart) for more details on the underlying library.
## NOTEs for the dev

Here's a brief overview of how the flutter opencv image situation works with the `opencv_core` package installed.

`Image.memory(<Uint8List>)` is the widget that is to be used to view the image on the flutter application. But the `opencv_core` package works with the images with the `cv.Mat` datatype.

**To convert a image bytes (Uint8List) into a `cv.Mat` datatype, use the following:**

- `mat = cv.imdecode(bytes, cv.IMREAD_COLOR)`


**And to convert a `cv.Mat` data type into a `Uint8List` datatype, use the following:**

- `bytes = cv.imencode(".png", mat).$2`





Refer for image stitching: https://github.com/rainyl/awesome-opencv_dart/blob/main/examples/stitching/lib/main.dart