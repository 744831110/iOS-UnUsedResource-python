import getopt, sys
import os
from classUnrefs import findUnuseClass
from findUnuseImage import findRepeatImage, findUnuseImage
import imageOptimize

def usage():
    print("this is help")

def filterPods(path):
    return "/Pods/" not in path

def findImageResult(projectPath):
    result = []
    resourceSuffixs = ["imageset", "jpg", "gif", "png"]
    for suffix in resourceSuffixs:
        command = "/usr/bin/find " + projectPath + " -name *." + suffix
        result = result + list(filter(filterPods, os.popen(command).read().splitlines()))
    return result

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:v", ["help", "unuse-class", "unuse-image", "compress-image", "delete-low-multiple-image", "repeat-image"])
    except getopt.GetoptError as err:
        # print help information and exit:
        print(err)  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    if len(args)<1:
        assert False, "arg error"
    projectPath = args[-1]
    otherProjectPath = args[-2] if len(args) == 2 else ""
    findImageResults = []
    isFindImage = False
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o == "--unuse-class":
            findUnuseClass(projectPath)
        elif o == "--unuse-image":
            if not isFindImage:
                findImageResults = findImageResult(projectPath)
                isFindImage = True
            findUnuseImage(findImageResults, projectPath, otherProjectPath)
        elif o == "--compress-image":
            if not isFindImage:
                findImageResults = findImageResult(projectPath)
                isFindImage = True
            imageOptimize.compressImage(findImageResults)
        elif o == "--delete-low-multiple-image":
            print("delete low multiple image")
            # 删除后asset无法读取，有误，勿使用
            # if not isFindImage:
            #     findImageResults = findImageResult(projectPath)
            #     isFindImage = True
            # imageOptimize.deleteLowMultipleImage(findImageResults)
        elif o == "--repeat-image":
            if not isFindImage:
                findImageResults = findImageResult(projectPath)
                isFindImage = True
            findRepeatImage(findImageResults, projectPath)
        else:
            assert False, "unhandled option"

if __name__ == "__main__":
    main()