//
//  File.swift
//  Sublime
//
//  Created by Eular on 2/18/16.
//  Copyright © 2016 Eular. All rights reserved.
//
import UIKit
import Foundation
import Photos
import SSZipArchive

enum FileType {
    case Regular, Directory, SymbolicLink, Socket, CharacterSpecial, BlockSpecial, Unknown
}

// MARK: - File Class
class File {
    var name = ""
    var ext = ""
    var path = ""
    var url: NSURL
    var isDir: Bool = false
    var type: FileType = .Unknown
    var size: Int = 0
    var img: String {
        get {
            if isDir {
                return "folder"
            } else if isExistImageResource("file_\(ext)") {
                return "file_\(ext)"
            } else {
                return "file_unknown"
            }
        }
    }
    var isImg: Bool {
        return (["jpg", "png", "gif"] as NSArray).containsObject(ext)
    }
    var isAudio: Bool {
        return (["mp3"] as NSArray).containsObject(ext)
    }
    var isVideo: Bool {
        return (["mp4", "rmvb", "avi", "flv", "mov"] as NSArray).containsObject(ext)
    }
    var data: NSData? {
        get {
            return NSData(contentsOfFile: path)
        }
    }
    var codeLang: String {
        let codeLangs = [
            "swift": "swift",
            "m": "objective-c",
            "h": "objective-c",
            "c": "c",
            "py": "python",
            "cpp": "cpp",
            "css": "css",
            "js": "javascript",
            "html": "html",
            "htm": "html",
            "xml": "xml",
            "jsp": "jsp",
            // "m": "matlab",
            "sh": "shell",
            "f90": "fortran",
            "java": "java",
            "md": "markdown",
            "asm": "asm",
            "bat": "bat",
            "scala": "scala",
            "tex": "latex",
            "pl": "perl",
            "cs": "c-sharp",
            "php": "php",
            "json": "json",
            "yml": "yml",
        ]
        return codeLangs[ext] ?? "txt"
    }
    
    let readable: Bool
    let writeable: Bool
    let executable: Bool
    let deleteable: Bool
    
    private let filemgr = NSFileManager.defaultManager()
    
    init(path: String) {
        self.path = path
        self.name = path.lastPathComponent
        self.ext = name.pathExtension
        self.url = NSURL(fileURLWithPath: path)
        
        self.readable = filemgr.isReadableFileAtPath(path)
        self.writeable  = filemgr.isWritableFileAtPath(path)
        self.executable = filemgr.isExecutableFileAtPath(path)
        self.deleteable = filemgr.isDeletableFileAtPath(path)
        
        do {
            let attribs = try filemgr.attributesOfItemAtPath(path)
            
            let filetype = attribs["NSFileType"] as! String
            switch filetype {
            case "NSFileTypeDirectory":
                self.type = .Directory
                self.isDir = true
            case "NSFileTypeRegular":
                self.type = .Regular
            case "NSFileTypeSymbolicLink":
                self.type = .SymbolicLink
            case "NSFileTypeSocket":
                self.type = .Socket
            case "NSFileTypeCharacterSpecial":
                self.type = .CharacterSpecial
            case "NSFileTypeBlockSpecial":
                self.type = .BlockSpecial
            default:
                self.type = .Unknown
            }
            
            self.size = attribs["NSFileSize"] as! Int
        } catch {}
    }
    
    func delete() -> Bool {
        do {
            try filemgr.removeItemAtPath(path)
            return true
        } catch {
            return false
        }
    }
    
    func read() -> String {
        if let data = filemgr.contentsAtPath(path) {
            return String(data: data, encoding: NSUTF8StringEncoding) ?? ""
        }
        return ""
    }
    
    func readlines() -> [String] {
        return (self.read() ?? "").split("\n")
    }
    
    func write(str: String) -> Bool {
        do {
            try str.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            return false
        }
        
    }
    
    func write(data: NSData) -> Bool {
        return data.writeToFile(path, atomically: true)
    }
    
    func append(str: String) -> Bool {
        if let handler = NSFileHandle(forUpdatingAtPath: path), let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            handler.seekToEndOfFile()
            handler.writeData(data)
            return true
        }
        return false
    }
    
    func insert(str: String, offset: UInt64) -> Bool {
        if let handler = NSFileHandle(forUpdatingAtPath: path), let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            handler.seekToFileOffset(offset)
            let data2 = handler.readDataToEndOfFile()
            handler.seekToFileOffset(offset)
            handler.writeData(data)
            handler.writeData(data2)
            return true
        }
        return false
    }
    
    func copy(dest: String) -> Bool {
        do {
            try filemgr.copyItemAtPath(path, toPath: dest)
            return true
        } catch {
            return false
        }
    }
    
    func move(dest: String) -> Bool {
        do {
            try filemgr.moveItemAtPath(path, toPath: dest)
            return true
        } catch {
            return false
        }
    }
    
    func unzip(destPath: String = "", keepFile: Bool = true) {
        if ext == "zip" {
            if destPath.isEmpty {
                SSZipArchive.unzipFileAtPath(path, toDestination: path.stringByDeletingLastPathComponent)
            } else {
                SSZipArchive.unzipFileAtPath(path, toDestination: destPath)
            }
            if !keepFile {
                self.delete()
            }
        } else {
            Log("Not zip file")
        }
    }
    
    static func exist(path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
}

// MARK: - Folder Class
class Folder: File {
    override init(path: String) {
        if !File.exist(path) {
            let upper = Folder(path: path.stringByDeletingLastPathComponent)
            upper.newFolder(path.lastPathComponent)
        }
        
        super.init(path: path)
    }
    
    func checkFileExist(name: String) -> Bool {
        return filemgr.fileExistsAtPath(path.stringByAppendingPathComponent(name))
    }
    
    func newFile(name: String) -> Bool {
        return filemgr.createFileAtPath(path.stringByAppendingPathComponent(name), contents: nil, attributes: nil)
    }
    
    func newFolder(name: String) -> Bool {
        do {
            try filemgr.createDirectoryAtPath(path.stringByAppendingPathComponent(name), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
    func listFiles() -> [File] {
        var fileList = [File]()
        do {
            let files = try filemgr.contentsOfDirectoryAtPath(path)
            for file in files {
                let p = path.stringByAppendingPathComponent(file)
                var f = File(path: p)
                if f.isDir {f = Folder(path: p)}
                fileList.append(f)
            }
        } catch {}
        return fileList
    }
    
    func saveImage(image: UIImage, name: String, url: NSURL?) {
        let imgext = name.pathExtension
        switch imgext {
        case "png":
            if let data = UIImagePNGRepresentation(image) {
                data.writeToFile(path.stringByAppendingPathComponent(name), atomically: true)
            }
        case "jpg":
            if let data = UIImageJPEGRepresentation(image, 1) {
                data.writeToFile(path.stringByAppendingPathComponent(name), atomically: true)
            }
        case "gif":
            let imgMgr = PHImageManager()
            let asset = PHAsset.fetchAssetsWithALAssetURLs([url!], options: nil)[0] as! PHAsset
            imgMgr.requestImageDataForAsset(asset, options: nil) { (data, _, _, _) -> Void in
                data?.writeToFile(self.path.stringByAppendingPathComponent(name), atomically: true)
            }
        default: return
        }
        
    }
    
    func zip(destPath: String = "") -> File {
        var zipPath: String
        if destPath.isEmpty {
            zipPath = path.stringByDeletingPathExtension.stringByAppendingPathExtension("zip")!
        } else {
            zipPath = destPath
        }
        SSZipArchive.createZipFileAtPath(zipPath, withContentsOfDirectory: path)
        return File(path: zipPath)
    }
}

