// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:opencv_core/opencv.dart' as cv;
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  cv.Mat? mainImage;
  Uint8List? mainImageBytes;

  bool isProcessing = false;
  String? stitchStatusMessage;

  List<Uint8List> images2stitch_BYTES = [];
  List<cv.Mat> images2stitch = [];

  // Result of stitching
  cv.Mat? stitchedImage;
  Uint8List? stitchedImageBytes;

  // Future to hold the stitching operation
  Future<Map<String, dynamic>>? stitchingFuture;

  final stitcher = cv.Stitcher.create(mode: cv.StitcherMode.PANORAMA);

  // Widgets ---------------------------------

  Widget cvBuildInformation_Scroll = SingleChildScrollView(
    child: Text(cv.getBuildInformation()),
  );

  Widget button_takeImage = ElevatedButton(
    onPressed: () async {
      print("Opening camera...");
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.camera);

      if (img != null) {
        final path = img.path;
        final mat = cv.imread(path);
        print(
          "[INFO] cv.imread: width: ${mat.cols}, height: ${mat.rows}, path: $path",
        );
        debugPrint("mat.data.length: ${mat.data.length}");
      }
    },
    child: const Icon(Icons.camera),
  );

  Widget get button_uploadImage => ElevatedButton(
    onPressed: () async {
      print("Opening gallery...");
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);

      if (img != null) {
        final path = img.path;
        final mat = cv.imread(path);
        print(
          "cv.imread: width: ${mat.cols}, height: ${mat.rows}, path: $path",
        );
        debugPrint("mat.data.length: ${mat.data.length}");

        setState(() {
          mainImage = mat;
          mainImageBytes = cv.imencode(".png", mat).$2;
        });
      }
    },
    child: const Icon(Icons.upload),
  );

  Widget get button_uploadImages => ElevatedButton(
    onPressed:
        isProcessing
            ? null // Disable button while processing
            : () async {
              // Clear up previous selections
              setState(() {
                images2stitch = [];
                images2stitch_BYTES = [];
                stitchedImage = null;
                stitchedImageBytes = null;
                stitchStatusMessage = null;
                stitchingFuture = null;
              });
              //

              print("Opening gallery...");
              final picker = ImagePicker();
              final pickedImages = await picker.pickMultiImage(limit: 5);

              print(pickedImages.length);

              if (pickedImages.isNotEmpty) {
                for (var img in pickedImages) {
                  final path = img.path;
                  final mat = cv.imread(path);
                  print(
                    "cv.imread: width: ${mat.cols}, height: ${mat.rows}, path: $path",
                  );
                  images2stitch.add(mat);
                }
                setState(() {
                  print("[INFO] Images to stitch: ${images2stitch.length}");
                });
              }
            },
    child: const Icon(Icons.add_a_photo),
  );

  // --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Stitcher"),
        actions: [button_takeImage, button_uploadImages],
      ),
      drawer: Drawer(child: SafeArea(child: cvBuildInformation_Scroll)),
      body: SafeArea(
        child:
            stitchingFuture != null
                ? _buildStitchingView()
                : (stitchedImageBytes != null
                    ? _buildStitchedResult()
                    : _buildSelectionScreen()),
      ),
    );
  }

  Widget _buildStitchingView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: stitchingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  "Stitching ${images2stitch.length} images...\nThis may take a while depending on image size and complexity.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(
                  "Error during stitching: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      stitchingFuture = null;
                    });
                  },
                  child: const Text("Back to selection"),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final result = snapshot.data!;

          // Process completed, update the state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              stitchingFuture = null;
              if (result['status'] == cv.StitcherStatus.OK) {
                stitchedImage = result['image'];
                stitchedImageBytes = result['bytes'];
              } else {
                // Show error if stitching failed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Stitching failed: ${result['status']}"),
                  ),
                );
              }
            });
          });

          // Show loading indicator while state updates
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text("Something went wrong"));
        }
      },
    );
  }

  Widget _buildStitchedResult() {
    return Column(
      children: [
        Expanded(child: Center(child: Image.memory(stitchedImageBytes!))),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    stitchedImage = null;
                    stitchedImageBytes = null;
                  });
                },
                child: const Text("Back to selection"),
              ),
              // Add a save button here if needed
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionScreen() {
    return images2stitch.isEmpty
        ? const Center(
          child: Text("No images selected. Use + button to select images."),
        )
        : Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                "${images2stitch.length} images selected${stitchStatusMessage != null ? '\n$stitchStatusMessage' : ''}",
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.panorama_horizontal),
              label: const Text("Stitch Images"),
              onPressed: isProcessing ? null : startStitchingProcess,
            ),
            if (images2stitch.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: images2stitch.length,
                  itemBuilder: (context, index) {
                    // Convert Mat to bytes for display
                    final imageBytes =
                        cv.imencode(".jpg", images2stitch[index]).$2;
                    return Card(
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
          ],
        );
  }

  void startStitchingProcess() {
    if (images2stitch.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Need at least 2 images to stitch")),
      );
      return;
    }

    // Create and assign the Future
    setState(() {
      stitchingFuture = performStitching();
    });
  }

  Future<Map<String, dynamic>> performStitching() async {
    print("Starting Stitch operation...");

    try {
      // Create a vectorized Mat from the images
      final vecMat = cv.VecMat.fromList(images2stitch);
      print("Created vecMat with ${images2stitch.length} images");

      // Perform the stitching operation
      final (status, dst) = await stitcher.stitchAsync(vecMat);

      print("Stitch status: $status");

      if (status == cv.StitcherStatus.OK) {
        // Encode the stitched image to bytes
        final bytes = cv.imencode(".png", dst).$2;
        return {'status': status, 'image': dst, 'bytes': bytes};
      } else {
        return {'status': status, 'image': null, 'bytes': null};
      }
    } catch (e) {
      print("Error during stitching: $e");
      throw e; // Let FutureBuilder handle the error
    }
  }
}
