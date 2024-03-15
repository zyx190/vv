---
layout: post
title: SharpPcap学习总结
category: C#
tags: C# SharpPcap
typora-root-url: ./..
---

## 前言

SharpPcap是.NET环境中跨平台的抓包框架，对WinPcap和LibPcap进行了统一的封装，使用C#语言

本人的毕设需要使用WinPcap进行抓包解析，还需要做一个UI界面，正好.NET有这样一个库，同时还有WPF这样的UI框架，之前参与过Android项目，WPF的xaml布局写法和Android很类似，上手WPF难度应该不算很高，综合考虑下选择使用C#完成毕设（~~根本原因是C++用不顺手​~​~~:broken_heart::broken_heart::broken_heart:）

理想是丰满的，现实是骨感的，当我兴致勃勃准备查找文档开始干的时候，发现怎么网上搜出来的例子跑不通。找到GitHub仓库，在Tutorial找到一篇文档，但是还是有例子跑不通，猜测是版本的问题，结果发现在releases中写“Please see nuget for releases”，这个nuget又是啥，咋还跑到那里去发布，后来了解到nuget是.NET的包管理平台，类似Java的Maven。一路搜索过去，倒是找到了SharpPcap的Nuget地址，但是还是找不到最新的文档，此时我的内心是崩溃的

没办法，只能硬着头皮看Tutorial的文档和反编译的源码慢慢调试了，在此记录一下SharpPcap新版本的API使用，SharpPcap版本为6.3.0

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

## 获取接口列表

在SharpPcap中获取接口列表非常简单，只需要一行代码

```c#
var list = CaptureDeviceList.Instance;

// 打印接口信息
foreach (var device in list) {
    Console.WriteLine(device);
}
```

获取到的`CaptureDeviceList`继承了`ReadOnlyCollection<ILiveDevice>`，是一个`ILiveDevice`类型的只读集合，由此可见获取到的设备实例是`ILiveDevice`类型的

`ILiveDevice`继承了`ICaptureDevice`和`IInjectionDevice`两个接口，这两个接口都继承了`IPcapDevice`接口，这两个接口中主要包含了各自功能模块的方法接口

```c#
// ILiveDevice
public interface ILiveDevice : ICaptureDevice , IInjectionDevice {
}

// IInjectionDevice
public interface IInjectionDevice : IPcapDevice {
    // 发送数据包
    void SendPacket(ReadOnlySpan<byte> p, ICaptureHeader header = null);
}

// ICaptureDevice
public interface ICaptureDevice : IPcapDevice {

    // 数据包捕获回调
    event PacketArrivalEventHandler OnPacketArrival;

    // 停止捕获回调
    event CaptureStoppedEventHandler OnCaptureStopped;

    // 是否开始捕获
    bool Started { get; }

    // 捕获超时时间
    TimeSpan StopCaptureTimeout { get; set; }

    // 开始异步捕获
    void StartCapture();

    // 停止捕获
    void StopCapture();

    // 开始同步捕获
    void Capture();

    // 捕获一个数据包
    GetPacketStatus GetNextPacket(out PacketCapture e);

    // 捕获统计信息
    ICaptureStatistics Statistics { get; }
}
```

`IPcapDevice`中包含了接口设备相关的信息

```c#
public interface IPcapDevice : IDisposable {
    
    // 设备名
    string Name { get; }

    // 设备描述
    string Description { get; }

    // 最后一次发生的错误信息
    string LastError { get; }

    // 过滤表达式
    string Filter { get; set; }

    // 设备MAC地址
    System.Net.NetworkInformation.PhysicalAddress MacAddress { get; }

    // 打开设备
    void Open(DeviceConfiguration configuration);

    // 关闭设备
    void Close();

    // 设备的链路层类型
    PacketDotNet.LinkLayers LinkType { get; }
}
```

## 打开接口并捕获

从上面的接口方法中，可以看到相关的打开、捕获等方法，基本使用如下

``` c#
var devices = CaptureDeviceList.Instance;
// 获取第一个接口
var dev = devices[0];
// 设置捕获回调
device.OnPacketArrival += new PacketArrivalEventHandler(OnPacketArrival);
dev.Open();  // 打开接口
dev.StartCapture();  // 开始异步捕获
Console.ReadLine();  // 阻塞主进程
dev.StopCapture();  // 停止捕获
dev.Close();  // 关闭接口

// 回调捕获函数，捕获的包类型为PacketCapture
public static void OnPacketArrival(object sender, PacketCapture p) {
    var data = p.Data;  // 数据包数据，字节数组
    var date = p.Timeval.Date;  // 时间戳
    // ......
}
```

实际上这里使用的`Open()`是一个扩展方法，`IPcapDevice`接口中的`Open()`接收一个`DeviceConfiguration`类型的参数，表示启动配置，而在`CaptureDeviceExtensions.cs`文件中，对`Open()`和`IInjectionDevice`接口的`SendPacket()`做了扩展

`DeviceConfiguration`中有两个常用的属性

-   `DeviceModes Mode`：接口工作模式
    -   `None`：默认模式
    -   `Promiscuous`：混杂模式
-   `int ReadTimeout`：捕获超时时间

开启接口混杂模式和设置超时时间，可以调用`CaptureDeviceExtensions.cs`文件中的扩展

```c#
device.Open(mode: DeviceModes.Promiscuous, read_timeout: 1000);
```

## 捕获数据包

与WinPcap一样，SharpPcap也有回调捕获和非回调捕获两种方式，在SharpPcap新版本中，将两种方式返回的数据包类型统一为了`PacketCapture`类型

### 回调捕获

在`ICaptureDevice`接口中有两个委托属性，可以定义回调函数

-   `PacketArrivalEventHandler OnPacketArrival`

    数据包捕获回调，函数类型为`void OnPacketArrival(object sender, PacketCapture e)`

-   `CaptureStoppedEventHandler OnCaptureStopped`

    停止捕获回调，函数类型为`void OnCaptureStop(object sender, CaptureStoppedEventStatus status)`

在调用`Open()`之前，设置接口的`OnPacketArrival`属性即可设置捕获回调

```c#
device.OnPacketArrival += new PacketArrivalEventHandler(OnPacketArrival);
```

### 非回调捕获

使用`ICaptureDevice`接口中的`GetNextPacket()`获取一个数据包，该函数接收一个`PacketCapture`类型的输出参数，`PacketCapture`是数据包类型，返回值是`GetPacketStatus`枚举类型，表示捕获数据包的状态

```c#
public enum GetPacketStatus {
    // 超时
    ReadTimeout = 0,
	// 捕获到数据包
    PacketRead = 1,
	// 捕获错误
    Error = -1,
	// 捕获中止
    NoRemainingPackets = -2,
};
```

在While循环中持续获取数据包，不需要调用`StartCapture()`

```c#
var device = devices[index];
device.Open(mode: DeviceModes.Promiscuous, read_timeout: 1000);

while (device.GetNextPacket(out PacketCapture packet) == GetPacketStatus.PacketRead) {
    Console.WriteLine(packet.GetPacket().GetPacket());
}

device.Close();
```

## 过滤数据包

在SharpPcap中设置过滤数据包非常简单，只需要设置`IPcapDevice`接口中的`Filter`属性为过滤表达式即可

```c#
device.Filter = "ip6 and icmp6";  // 过滤ICMPv6包
```

## 数据包解析

数据包主要使用到PacketDotNet库，PacketDotNet中将几乎所有类型的数据包都封装了实体类，而它们都继承了`Packet`这个抽象父类，其中也包含一些用于解析的方法，主要用到下面两个方法

-   `Packet.ParsePacket()`：将`PacketCapture`解析为`Packet`对象，
-   `Extract<T>()`：从`Packet`对象中提取指定数据包类型，返回相应的数据包对象

基本使用如下

``` c#
private static void OnPacketArrival(object s, PacketCapture packetCapture) {
    var packet = Packet.ParsePacket(
        packetCapture.Device.LinkType, 
        packetCapture.Data.ToArray()
    );
    // 也可通过以下方式获取
    // var packet = packetCaptrue.GetPacket().GetPacket();
    
    // 解析出来的首先是链路层对象，ParsePacket方法返回Packet父类引用，强转为子类
    var ethernet = packet as EthernetPacket ?? throw new NullReferenceException();
    var udp = ethernet.Extract<UdpPacket>();
    if (udp != null) {
        Console.WriteLine(udp);
    }
}
```

数据包解析的部分工作原理详见：[SharpPcap数据包解析原理]({% post_url 2024-03-14-sharppcap数据包解析原理 %})

## 堆文件处理

