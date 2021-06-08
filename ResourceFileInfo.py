import os
import string


class ResourceFileInfo:
    path = ""
    name = ""
    nameWithSuffix = ""
    suffix = ""
    fileSize = 0.0
    fileName = ""
    isDir = False

    def __init__(self, filePath):
        self.path = filePath
        (dirPath, tempfilename) = os.path.split(self.path)
        (filename, extension) = os.path.splitext(tempfilename)
        self.fileName = filename
        self.name = self.removeResourceSuffix(filename)
        self.nameWithSuffix = filename + extension
        self.suffix = extension.strip(".")
        self.isDir = os.path.isdir(self.path)
        if not(self.isDir):
            self.fileSize = os.path.getsize(self.path)

    def removeResourceSuffix(self, path):
        if path.rfind("@2x") != -1:
            path = path.replace("@2x", "")

        if path.rfind("@3x") != -1:
            path = path.replace("@3x", "")

        return path

    def describe(self):
        print("path is " + self.path + " name is " + self.name + " nameWithSufffix is " + "suffix is" + self.suffix + self.nameWithSuffix + " filesize is " + str(self.fileSize) + "filename is " + self.fileName + " isDir is " + str(self.isDir))
