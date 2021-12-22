from PIL import Image
from dHash import DHash
import sys
import os
import re
from typing import List
from resourceFileInfo import ResourceFileInfo

# 需要忽略搜索图片的文件夹
excludeFolders = []
# 图片文件
imageInfoDic = {}
# 匹配各个文件夹的正则
regexDic = {}
# imageName set
imageNameSet = set()
# 无用图片info
unusedArray = []
resourceSuffixs = ["jpg", "png"]

# 可能imageName会以变量名或@"%@"的形式出现，寻找未使用图片出现误差，把这些代码找出来人工排查
imageVarRegexFront = ["\\[UIImage as_imageNamed:", "ASUIImageNamed\\(", "ASUITintImageNamed\\(", "ASUIThemeImageNamed\\(", "ASUIThemeTintImageNamed\\("]
imageVarRegexBack = ["\\s*@\"[\\s\\S]*%@", "\\s*\\w+"]
imageVarResult = []

# 搜索给定文件名下的各个文件，并匹配正则，存储结果
def searchImageName(filePath, imageSet):
    for file_path in os.listdir(filePath):
        path = os.path.join(filePath, file_path)
        if "/Pods/" in path:
            continue
        if os.path.isdir(path):
            searchImageName(path, imageSet)
        else:
            (dirPath, tempfilename) = os.path.split(path)
            (filename, extension) = os.path.splitext(tempfilename)
            suffix = extension.strip(".")
            if os.path.exists(path) and suffix in regexDic.keys():
                file = open(path, encoding="ISO-8859-1")
                content = file.read()
                file.close()
                regex = regexDic[suffix]
                pattern = re.compile(regex)
                result = pattern.findall(content)
                for imageName in result:
                    imageSet.add(imageName)
                # if suffix == "m":
                #     lineList = content.split("\n")
                #     for front in imageVarRegexFront:
                #         for back in imageVarRegexBack:
                #             regex = front + back
                #             p = re.compile(regex)  
                #             for line in lineList:
                #                 results = p.findall(line)
                #                 for r in results:
                #                     imageVarResult.append((r, path))



def isImageSetUnUsed(info: ResourceFileInfo, resourceSuffixs: list, imageNameSet: set):
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


def isInImageSet(info: ResourceFileInfo):
    isImageSet = (info.suffix == "imageset" or info.suffix ==
                  "appiconset" or info.suffix == "launchimage")
    pathContinaerSuffix = info.path.find("imageset") != -1 or info.path.find(
        "appiconset") != -1 or info.path.find("launchimage") != -1
    if not isImageSet and pathContinaerSuffix:
        return True
    return False

# 需要把学生端和教师端两端代码更新到最新，并传入
def findUnuseImage(results, projectPath, otherProjectPath):
    for result in results:
        info = ResourceFileInfo(result)
        # 获取.imageset 且过滤pod
        if not isInImageSet(info) and result.find(".bundle") == -1 and "/Pods/" not in info.path and "ASImageTheme.xcassets" not in info.path and "AppIcon" not in info.path and "doraemon" not in info.path:
            if not info.name in imageInfoDic:
                imageInfoDic[info.name] = info

    # 初始化正则
    fileSuffixs = ["h", "m", "mm", "swift", "xib", "storyboard", "strings", "c", "cpp", "html", "js", "json", "plist", "css"]

    cRegex = "([a-zA-Z0-9_-]*)\\.(" + "|".join(resourceSuffixs) + ")"

    objcRegex = "@\"(.*?)\""

    xibRegex = "image name=\"(.+?)\""

    fileRegex = [cRegex, objcRegex, objcRegex, "\"(.*?)\"", xibRegex, xibRegex, "=\\s*\"(.*)\"\\s*;", cRegex, cRegex,"img\\s+src=[\"\'](.*?)[\"\']", "[\"\']src[\"\'],\\s+[\"\'](.*?)[\"\']", ":\\s*\"(.*?)\"", ">(.*?)<", cRegex]

    for i in range(0, len(fileSuffixs)-1):
        regexDic[fileSuffixs[i]] = fileRegex[i]
    searchImageName(projectPath, imageNameSet)
    searchImageName(otherProjectPath, imageNameSet)
    for key in imageInfoDic.keys():
        info = imageInfoDic[key]
        if not info.name in imageNameSet:
            if info.isDir:
                if not isImageSetUnUsed(info, resourceSuffixs, imageNameSet):
                    unusedArray.append(info)
            else:
                unusedArray.append(info)
    for info in unusedArray:
        print(info.name + " " + info.path)

# 传入学生端或教师端路径，如果找出重复图片，需要删除其中一张，需要在学生端和教师端将删除图片的相关信息改为新图片信息
def findRepeatImage(results, projectPath):
    #dhash dic
    dHashDic = {}
    repeatImage = []
    for result in results:
        info = ResourceFileInfo(result)
        # 用name是因为x1 x2 x3的图片只需要算一张图片
        # 过滤pod 主题图片文件夹 AppIcon 和 development pod下的doraemon库 中的图片
        if info.suffix in resourceSuffixs and info.name not in dHashDic.keys() and "/Pods/" not in info.path and "ASImageTheme.xcassets" not in info.path and "AppIcon" not in info.path and "doraemon" not in info.path:
            dHashDic[info.name] = (DHash.calculate_hash(Image.open(info.path)), info)
    
    for key, value in dHashDic.items():
        for otherKey, otherValue in dHashDic.items():
            if key == otherKey:
                continue
            if DHash.hamming_distance(value[0], otherValue[0]) <= 2:
                result = set([value[1].path, otherValue[1].path])
                if result not in repeatImage:
                    repeatImage.append(result)
                
    for t in repeatImage:
        print(t)