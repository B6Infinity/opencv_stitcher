# stitcher

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## NOTEs for the dev

Here's a brief overview of how the flutter opencv image situation works with the `opencv_core` package installed.

`Image.memory(<Uint8List>)` is the widget that is to be used to view the image on the flutter application. But the `opencv_core` package works with the images with the `cv.Mat` datatype.

**To convert a image bytes (Uint8List) into a `cv.Mat` datatype, use the following:**

- `mat = cv.imdecode(bytes, cv.IMREAD_COLOR)`


**And to convert a `cv.Mat` data type into a `Uint8List` datatype, use the following:**

- `bytes = cv.imencode(".png", mat).$2`





Refer for image stitching: https://github.com/rainyl/awesome-opencv_dart/blob/main/examples/stitching/lib/main.dart