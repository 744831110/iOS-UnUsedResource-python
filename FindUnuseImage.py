import sys
import os
import re
from ResourceFileInfo import ResourceFileInfo

projectpath = sys.argv[1]
# 需要忽略搜索图片的文件夹
excludeFolders = []
# 需要搜索的文件路径
resourceSuffixs = ["imageset", "jpg", "gif", "png"]
# 图片文件
imageInfoDic = {}
# 匹配各个文件夹的正则
regexDic = {}
# imageName set
imageNameSet = set()
# 无用图片info
unusedArray = []

# 搜索给定文件名下的各个文件，并匹配正则，存储结果
def searchImageName(filePath, imageSet):
    for file_path in os.listdir(filePath):
        path = os.path.join(filePath, file_path)
        if os.path.isdir(path):
            searchImageName(path, imageSet)
        else:
            if os.path.exists(path):
                file = open(path, encoding="ISO-8859-1")
                content = file.read()
                file.close()
                suffix = path.split(".")
                if len(suffix)>=2 and suffix[1] in regexDic:
                    regex = regexDic[suffix[1]]
                    pattern = re.compile(regex)
                    result = pattern.findall(content)
                    for imageName in result:
                        imageSet.add(imageName)

def isImageSetUnUsed(info:ResourceFileInfo, resourceSuffixs:[], imageNameSet:set):
    fileList = os.listdir(info.path)
    for file in fileList:
        splitArray = file.split(".")
        suffix = splitArray[len(splitArray)-1]
        fileName = splitArray[0]
        if suffix in resourceSuffixs:
            if fileName == info.name:
                return False
            if fileName in imageNameSet:
                return True
    return False

def isInImageSet(info:ResourceFileInfo):
    isImageSet = (info.suffix == "imageset" or info.suffix == "appiconset" or info.suffix == "launchimage")
    pathContinaerSuffix = info.path.find("imageset")!=-1 or info.path.find("appiconset")!=-1 or info.path.find("launchimage")!=-1
    if not isImageSet and pathContinaerSuffix:
        return True
    return False

# 检索所有的图片文件
for suffix in resourceSuffixs:
    command = "/usr/bin/find " + projectpath + " -name *." + suffix
    results = os.popen(command).read().splitlines()
    for result in results:
        info = ResourceFileInfo(result)
        if not isInImageSet(info) and result.find(".bundle") == -1:
            # imageset 和 imageSet里的图片不会重复
            if not info.name in imageInfoDic:
                imageInfoDic[info.name] = info

# 初始化正则
fileSuffixs = ["h", "m", "mm", "swift", "xib", "storyboard", "strings", "c", "cpp", "html", "js", "json", "plist", "css"]
cRegex = "([a-zA-Z0-9_-]*)\\.(" + "|".join(resourceSuffixs) + ")"
objcRegex = "@\"(.*?)\""
xibRegex = "image name=\"(.+?)\""
fileRegex = [cRegex, objcRegex, objcRegex, "\"(.*?)\"", xibRegex, xibRegex, "=\\s*\"(.*)\"\\s*;", cRegex, cRegex, "img\\s+src=[\"\'](.*?)[\"\']", "[\"\']src[\"\'],\\s+[\"\'](.*?)[\"\']", ":\\s*\"(.*?)\"", ">(.*?)<", cRegex]
for i in range(0, len(fileSuffixs)-1):
    regexDic[fileSuffixs[i]] = fileRegex[i]

searchImageName(projectpath, imageNameSet)

for key in imageInfoDic.keys():
    info = imageInfoDic[key]
    if not info.name in imageNameSet:
        if info.isDir:
            if not isImageSetUnUsed(info, resourceSuffixs, imageNameSet):
                unusedArray.append(info)
        else :
            unusedArray.append(info)

for info in unusedArray:
    print(info.nameWithSuffix)