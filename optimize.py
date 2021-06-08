import getopt, sys
import os
from classUnrefs import findUnuseClass
from findUnuseImage import findUnuseImage
import ImageOptimize

def usage():
    print("this is help")

def findImageResult(projectPath):
    result = []
    resourceSuffixs = ["imageset", "jpg", "gif", "png"]
    print("find image result")
    for suffix in resourceSuffixs:
        command = "/usr/bin/find " + projectPath + " -name *." + suffix
        result = result + os.popen(command).read().splitlines()
    return result

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:v", ["help", "unuse-class", "unuse-image", "compress-image", "delete-low-multiple-image"])
    except getopt.GetoptError as err:
        # print help information and exit:
        print(err)  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    if len(args)<1:
        assert False, "arg error"
    projectPath = args[-1]
    findImageResults = []
    isFindImage = False
    print(args)
    print(opts)
    for o, a in opts:
        print("o is " + o)
        print("a is " + a)
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o == "--unuse-class":
            findUnuseClass(projectPath)
        elif o == "--unuse-image":
            if not isFindImage:
                findImageResults = findImageResult(projectPath)
                isFindImage = True
            print("unuse image")
            findUnuseImage(findImageResults, projectPath)
        elif o == "--compress-image":
            if not isFindImage:
                findImageResults = findImageResult(projectPath)
                isFindImage = True
            ImageOptimize.compressImage(findImageResults)
        elif o == "--delete-low-multiple-image":
            if not isFindImage:
                findImageResults = findImageResult(projectPath)
                isFindImage = True
            ImageOptimize.deleteLowMultipleImage(findImageResults)
        else:
            assert False, "unhandled option"

if __name__ == "__main__":
    main()