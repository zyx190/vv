---
layout: post
title: SharpPcap学习总结
category: C#
tags: C# SharpPcap
typora-root-url: ./..
---

## 前言

SharpPcap是.NET环境中跨平台的抓包框架，对WinPcap和LibPcap进行了统一的封装，使用C#语言

本人的毕设需要使用WinPcap进行抓包解析，还需要做一个UI界面，正好.NET有这样一个库，同时还有WPF这样的UI框架，之前参与过Android项目，WPF的xaml布局写法和Android很类似，上手WPF难度应该不算很高，综合考虑下选择使用C#完成毕设（~~根本原因是C++用不顺手:broken_heart::broken_heart::broken_heart:~~）

理想是丰满的，现实是骨感的，当我兴致勃勃准备查找文档开始干的时候，发现怎么网上搜出来的例子跑不通。找到GitHub仓库，在Tutorial找到一篇文档，但是还是有例子跑不通，猜测是版本的问题，结果发现在releases中写“Please see nuget for releases”，这个nuget又是啥，咋还跑到那里去发布，后来了解到nuget是.NET的包管理平台，类似Java的Maven。一路搜索过去，倒是找到了SharpPcap的Nuget地址，但是还是找不到最新的文档，此时我的内心是崩溃的

没办法，只能硬着头皮看Tutorial的文档和反编译的源码慢慢调试了，在此记录一下使用过程中的坑，SharpPcap版本为6.3.0

SharpPcap的GitHub仓库：[dotpcap/sharppcap](https://github.com/dotpcap/sharppcap)

PacketDotNet的GitHub仓库：[dotpcap/packetnet](https://github.com/dotpcap/packetnet/tree/master)

NuGet地址：[NuGet Gallery SharpPcap 6.3.0](https://www.nuget.org/packages/SharpPcap)

## SharpPcap安装

SharpPcap已经发布在NuGet上，所以我们可以直接通过Visual Studio的NuGet管理器获取安装，这里使用Visual Studio 2022版本

1.   **安装SharpPcap**

     打开项目的NuGet管理器，点击浏览，在搜索框搜索SharpPcap，点击安装即可

     ![image-20240312153943050](/assets/img/sharppcap学习总结/image-20240312153943050.png)

     ![image-20240312151439319](/assets/img/sharppcap学习总结/image-20240312151439319.png)

2.   **查看依赖项**

     安装完成后，我们可以看到项目中的依赖项已经有了SharpPcap的依赖，其中也包含一个叫PacketDotNet的库，SharpPcap主要负责数据包的捕获，而PacketDotNet就是负责数据包的解析

     ![image-20240312151721004](/assets/img/sharppcap学习总结/image-20240312151721004.png)

3.   **在代码中使用SharpPcap**

     在代码中引入SharpPcap命名空间和PacketDotNet命名空间即可，打印版本检查是否可以正常使用

     ```c#
     using System;
     using SharpPcap;
     using PacketDotNet;
     
     namespace backend {
         public class Backend {
             public static void Main(string[] args) {
                 // Tutorial中获取版本为string ver = SharpPcap.Version.VersionString;
                 var version = Pcap.Version;
                 var sharpPcapVersion = Pcap.SharpPcapVersion;
                 Console.WriteLine(version);
                 Console.WriteLine($"SharpPcapVersion = {sharpPcapVersion}");
             }
         }
     }
     ```
     
     ![image-20240312152649893](/assets/img/sharppcap学习总结/image-20240312152649893.png)
     
     可以打印出Npcap版本和SharpPcap版本，接下来就可以愉快的使用了:clap::clap::clap:

## 教程示例

