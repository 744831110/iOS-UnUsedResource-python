import os
import sys
import shutil
from resourceFileInfo import ResourceFileInfo
from progressBar import ProgressBar

resourceSuffixs = ["jpg", "png"]
compressSuffix = "_optim_compress"
projectpath = sys.argv[1]
compressArray = []
cantCompressArray = []
deleteArray = []

def __deleteAllCompressImage():
    for suffix in resourceSuffixs:
        command = "/usr/bin/find" + projectpath + " -name *." + suffix
        results = os.popen(command).read().splitlines()
        for result in results:
            info = ResourceFileInfo(result)
            if info.suffix == "png" or info.suffix == "jpg":
                if compressSuffix in info.fileName:
                    os.remove(info.path)


def deleteLowMultipleImage(results):
    for result in results:
        info = ResourceFileInfo(result)
        if "/Pods/" not in info.path and "AppIcon" not in info.path and info.suffix == "imageset":
            files = []
            for dirpath, dirnames, tempfiles in os.walk(info.path):
                files = tempfiles
            for suffix in resourceSuffixs:
                deleteFileName = info.name+"."+suffix
                if deleteFileName in files:
                    print(info.path)


def compressImage(results):
    for result in results:
        info = ResourceFileInfo(result)
        if info.suffix == "png" or info.suffix == "jpg":
            # 只对ASImage.xcassets下的进行压缩
            if info.path.find("./Pods") == -1 and info.path.find("AppIcon.appiconset") == -1 and info.path.find("AppIcon") == -1 and compressSuffix not in info.path:
                compressArray.append(info)
        progress = ProgressBar(len(compressArray), fmt=ProgressBar.FULL)
    for i in range(len(compressArray)):
        __compress(compressArray[i].path)
        progress.current += 1
        progress()
    progress.done()

def __compress(imagePath):
    pathList = imagePath.split(".")
    if len(pathList) < 2:
        print("can't compress path")
        cantCompressArray.append(imagePath)
        return
    pathList[-2] = pathList[-2] + compressSuffix
    newPath = ".".join(pathList)
    # 先复制一个做比较，可不要这行
    # shutil.copyfile(imagePath, newPath)
    lines = os.popen('imageoptim -Q --no-imageoptim --imagealpha --number-of-colors 150 --quality 70-100 %s' %
                     imagePath).readlines()
    print(lines)



def __test():
    for suffix in resourceSuffixs:
        command = "/usr/bin/find " + projectpath + " -name *." + suffix
        results = os.popen(command).read().splitlines()
        for result in results:
            info = ResourceFileInfo(result)
            dirList = info.path.split("/")
            if len(dirList) >= 2:
                dicName = dirList[-2]
                if ".imageset" in dicName and info.fileName == dicName.replace(".imageset", ""):
                    os.remove(info.path)
                    deleteArray.append(info.path)

            if info.suffix == "png" or info.suffix == "jpg":
                if info.path.find("./Pods") == -1 and info.path.find("AppIcon.appiconset") == -1 and info.path.find("AppIcon") == -1 and compressSuffix not in info.path:
                    compressArray.append(info)

    progress = ProgressBar(len(compressArray), fmt=ProgressBar.FULL)
    for i in range(len(compressArray)):
        __compress(compressArray[i].path)
        progress.current += 1
        progress()
    progress.done()


# fastlane打包
# 相关编译选项
# 修改bug
