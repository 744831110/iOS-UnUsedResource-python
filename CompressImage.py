import os
import sys
from tinify import tinify

# 使用tiny压缩图片
# 每个月500张
tinify.key = "DYwxvJSFGG6qZXTDdbJQ6B4v566vMdkv"

imagePath = "/Users/chenqian/Desktop/test.png"
imageOutputPath = "/Users/chenqian/Desktop/test.png"

source = tinify.from_file(imagePath)
source.to_file(imageOutputPath)
print("压缩完成，本月剩余次数：%d" % (500-tinify.compression_count))
