import os
import sys
from tinify import tinify

#使用tiny压缩图片
#每个月500张
tinify.key = "DYwxvJSFGG6qZXTDdbJQ6B4v566vMdkv"

imagePath = sys.argv[1]
imageOutputPath = sys.argv[2]

source = tinify.from_file(imagePath)
source.to_file(imageOutputPath)

