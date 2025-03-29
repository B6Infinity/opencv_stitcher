from imutils import paths
import numpy as np
import argparse
import imutils
import cv2

# Get Data from user arguments
# ap = argparse.ArgumentParser()
# ap.add_argument("-i", "--images", type=str, required=True,
# 	help="path to input directory of images to stitch")
# ap.add_argument("-o", "--output", type=str, required=True,
# 	help="path to the output image")
# args = vars(ap.parse_args())
# -----

IMAGES_DIR = "images" # Comment this out when inputing images to stitch directory from the terminal
OUTPUT_PATH = "output.png"

print("[INFO] loading images...")
# imagePaths = sorted(list(paths.list_images(args["images"])))
imagePaths = sorted(list(paths.list_images(IMAGES_DIR))) # Comment this out when inputing images to stitch directory from the terminal
images = []

for imagePath in imagePaths:
	image = cv2.imread(imagePath)
	images.append(image)
	
print(len(images))


print("[INFO] stitching images...")
#stitcher = cv2.createStitcher() if imutils.is_cv3() else cv2.Stitcher_create()
stitcher = cv2.Stitcher_create() # Since this is being written for opencv 4
(status, stitched) = stitcher.stitch(images)

print(status)

if status == 0:
	cv2.imwrite(OUTPUT_PATH, stitched)
	print("[SUCCESS] Stiched images successfully! Output dimensions:", stitched.shape)
else:
	print("[ERROR] Image stitching failed!")