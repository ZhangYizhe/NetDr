# NetDr

---

NetDr is a network check tool for iOS / MacOS / TV OS. You can integration this tool on your project very easy. 

### What function does it have?

1、You can get some basic info about device and net status. Like device type / system version / carrier name / current network type (3G / 4G / Wi-Fi...) / this device's public IP address / local dns address.

2、You can test the reachability of a [host](https://en.wikipedia.org/wiki/Host_(network)) on an [Internet Protocol](https://en.wikipedia.org/wiki/Internet_Protocol) (IP) network by ping function.

### How to use it?

1、You need to choose the tag for look up which version is your need. And if you want to experience latest version, you can direct choose the developer branch.

2、When you did choose the needly branch, you have two way to integration the tool in your project:

1）Create a Framework for yourself.

You can downland the entire repository, open the "NetDrFramework" folder and run the "NetDrFramework.xcodeproj" with Xcode. Then build and run the current scheme in two environments (Simulators and Generic iOS Device). When you complete all operations. You will see a framework in "Products" directory. Right click this directory and choose "Show in Folder". The "Folder" will open a new window, and it will show two file. One is the real machine version framework, another is the simulator version. You need use "Terminal" App to merge both frameworks. The command is :

```
lipo -create Debug-iphoneos/NetDrFramework.framework/NetDrFramework Debug-iphonesimulator/NetDrFramework.framework/NetDrFramework -output ./NetDrFramework
```

When you did run this command, you will get a framework file under the "Products" directory. You need move this framework to overwrite the old same framework in this path: "./Products/Debug-iphoneos/NetDrFramework.framework/".

In the end you only need to move the "NetDrFramework.framework" folder in the "./Products/Debug-iphoneos/" path to to your project.

2) Use the Compiled Framework.

When you download and open the repository, you will see the "NetDrFramework.framework" on root directory.