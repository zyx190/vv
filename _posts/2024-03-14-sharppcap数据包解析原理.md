---
layout: post
title: SharpPcap数据包解析原理
categories: C#
tags: C# SharpPcap
typora-root-url: ./..
date: 2024-03-14 19:24 +0800
---
## 前言

SharpPcap与WinPcap基本用法上相差不多，但对数据包解析这个功能，SharpPcap提供了很多方法来帮我们解析数据包，而在WinPcap中，我们需要定义好包的实体类型，通过指针强转来解析包的内容字节数组，SharpPcap着实方便不少。但好奇心驱使我去看看SharpPcap是如何实现解析的，正好也学习一下，因此阅读了SharpPcap的GitHub仓库的部分源码，主要是PacketDotNet的解析部分，本文含有大量源码，展示时会进行一定程度简化，谨慎阅读

## PcapCapture结构和RawCapture类

在`ICaptureDevice.GetNextPacket()`和`OnPacketArrival`回调中都包含一个`PcapCapture`类型的参数，这个参数在捕获回调中代替了`CaptureEventArgs`，在`ICaptureDevice.GetNextPacket()`中作为输出参数，可以看出这个类型统一了捕获返回的数据类型，下面给出源码看看里面有哪些属性

``` c#
public readonly ref struct PacketCapture {
    
    // 构造一个RawCapture返回，RawCapture表示一个未处理的数据包
    public RawCapture GetPacket() {
        return new RawCapture(Device, Header, Data);
    }

    // 进行捕获的接口设备
    public ICaptureDevice Device { get; }

    // 数据包头部
    public ICaptureHeader Header { get; }

    // 数据包内容，ReadOnlySpan可以看做一个只读的字节数组，调用ToArray方法可以转换为byte[]
    public ReadOnlySpan<byte> Data { get; }
    
    // 构造器
    public PacketCapture(ICaptureDevice device, 
                         ICaptureHeader header, 
                         ReadOnlySpan<byte> data) {
        this.Header = header;
        this.Device = device;
        this.Data = data;
    }
}
```

可以看到`PcapCapture`中包含了数据包的相关属性，`GetPacket()`中构造了一个`RawCapture`对象返回，接下来继续看看`RawCapture`中有什么，这里只给出主要属性，省略构造器和无关方法

``` c#
public class RawCapture {
    
    // 接口链路层类型
    public LinkLayers LinkLayerType { get; set; }

    // 时间戳
    public PosixTimeval Timeval { get; set; }

    // 数据包内容字节数组
    public byte[] Data;

    // 数据包长度
    public int PacketLength { get; set; }

    // 解析数据包，返回PacketDotNet库中的Packet类型
    public virtual Packet GetPacket() {
        return Packet.ParsePacket(LinkLayerType, Data);
    }
}
```

从上面的代码中，我们可以看出`RawCapture`中包含的属性，**抽象程度更低**，并且包含了原始的数据包内容字节数组，因此`PcapCapture`可以看做对`RawCapture`中的属性进行封装的结构体，**用于统一两种捕获方法的参数类型**

## ParsePacket方法

在`RawCapture`中，可以看到有一个`GetPacket`方法，其中调用了`Packet.ParsePacket`方法，可以看出这个方法是`Packet`类的静态方法，实际上这个方法就是**PacketDotNet库用于解析数据包的入口方法**，将SharpPcap中的`RawCapture`类转换为PacketDotNet的`Packet`类，而解析过程都是围绕这个`Packet`类展开的，下面我们先看看`ParsePacket`方法的源码

``` c#
public static Packet ParsePacket(LinkLayers linkLayers, byte[] packetData) {
    Packet p;
    
    // 使用ByteArraySegment类包装数据包字节数组，这个类很重要，后面重点讲解
    var byteArraySegment = new ByteArraySegment(packetData);

    Log.DebugFormat("LinkLayer {0}", linkLayers);

    // 根据链路层类型构造不同的Packet子类
    switch (linkLayers) {
        case LinkLayers.Ethernet: {
            p = new EthernetPacket(byteArraySegment);
            break;
        }
        case LinkLayers.LinuxSll: {
            p = new LinuxSllPacket(byteArraySegment);
            break;
        }
        case LinkLayers.Null: {
            p = new NullPacket(byteArraySegment);
            break;
        }
        case LinkLayers.Ppp: {
            p = new PppPacket(byteArraySegment);
            break;
        }
        case LinkLayers.Ieee80211: {
            p = MacFrame.ParsePacket(byteArraySegment);
            break;
        }
        case LinkLayers.Ieee80211RadioTap: {
            p = new RadioPacket(byteArraySegment);
            break;
        }
        case LinkLayers.Ppi: {
            p = new PpiPacket(byteArraySegment);
            break;
        }
        case LinkLayers.Raw:
        case LinkLayers.RawLegacy: {
            p = new RawIPPacket(byteArraySegment);
            break;
        }
        default: {
            // 若没有匹配的链路层类型，抛出异常
            ThrowHelper.ThrowNotImplementedException(ExceptionArgument.linkLayer);
            p = null;
            break;
        }
    }

    return p;
}
```

可以看到这个入口方法是根据链路层类型返回不同的链路层实体类，这些实体类**实际上就是Packet类的子类**，我们在往上看看`Packet`类的修饰符，可以看到`Packet`用`abstract`修饰，**Packet类就是一个抽象类**，在`ParsePacket`方法中首先构造的就是链路层相关的实体类，因此可以得知PacketDotNet**从链路层开始解析**

此外我们看到最后当`linkLayers`没有匹配时，就抛出了一个异常，我们就来看看这个`LinkLayers`中有哪些类型

``` c#
public enum LinkLayers : ushort {
    Null = 0,
    Ethernet = 1,
	// ......
    Ieee80211 = 105,
    // ......
    Ieee80211RadioTap = 127,
    // ......
    IPv4 = 228,
    IPv6 = 229,
	// ......
}
```

可以看到其中包含了非常多的枚举类型，其中包含了常用的Ethernet（IEEE 802.3 以太网）和IEEE 802.11 无线网等，但是在`ParsePacket`方法中，这些类型并不是全部支持，因此要注意`ParsePacket()`支持哪些类型

现在看完`ParsePacket`方法、`RawCapture`类和`PcapCapture`类，我们可以很自如地使用`ParsePacket()`

``` c#
private static void device_OnPacketArrival(object sender, PacketCapture p) {
    try {
        var packet = Packet.ParsePacket(packet.Device.LinkType, packet.Data.ToArray());
        // 或者获取到RawCapture，调用GetPacket()，GetPacket()中调用了ParsePacket()
        // var packet = p.GetPacket().GetPacket()
        
        // 获取到的是Packet抽象类的子类对象，而packet的类型是Packet，因此需要类型转换
        // 现在大多数接口都是以太网，因此直接转换为Ethernet
        var ethernet = packet as Ethernent;
        
    } catch (Exception ex) {
        Console.WriteLine($"{ex.Message}");
    }
}
```

## Packet类

在获取到链路层Packet后，我们要继续解析，就要使用`Packet`类中的属性和方法了，`Packet`类是PacketDotNet库中所有数据包类型的顶级抽象父类，因此研究清楚它，我们也就大概了解其他的包类型了

Packet类的内容非常多，仓库源码有500多行，因此要抓住主线来研究它，分清主要矛盾和次要矛盾

### Extract方法

在我们继续解析时，会调用一个叫`Extract`的方法，顾名思义，这是一个在`Packet`类型的包中提取内层数据包的方法（协议栈是一个层次结构），在旧版本中传入要提取的包实体类的类型，在6.3.0版本中，类型信息通过泛型传入，它的源码也非常简单

```c#
public T Extract<T>() where T : Packet {
    // 从当前层开始
    var t = this;
    while (t != null) {
        // 若某个内层的实体类型和指定类型相同，则返回该层的实体对象
        if (t is T packet)
            return packet;
        
        // 转到内层，即负载数据包
        t = t.PayloadPacket;
    }
    return null;
}
```

该方法实现的提取有点类似于链表遍历，从当前层开始，每次循环判断该层是否是指定层，不是就跳转到下一层

那么现在的关键就是弄清楚`PayloadPacket`是如何得到的

### PayloadPacket属性

我们找到`Packet`类的`PayloadPacket`属性，它是`PayloadPacketOrData`字段的属性，下面给出源码，省略无关部分

```c#
public abstract class Packet {
    // ......
    
    // (1)
    protected LazySlim<PacketOrByteArraySegment> PayloadPacketOrData = new(null);
    
    public virtual Packet PayloadPacket {
    	get => PayloadPacketOrData.Value.Packet;
    	set {
            // (2)
        	if (this == value) {
    			ThrowHelper.ThrowInvalidOperationException(
                	ExceptionDescription.PacketAsPayloadPacket
            	);
        	}
            // (3)
        	PayloadPacketOrData.Value.Packet = value;
        	PayloadPacketOrData.Value.Packet.ParentPacket = this;
    	}
	}
    
    // ......
}
```

光是这两个属性，都有不少东西可以说，下面一点一点来说

1.   `PayloadPacketOrData`初始化

     这句在语法上用到了类型省略的new，已知声明类型时，构造对象可以省略new后面的类型，这里先设置为null

     初始化时使用了`LazySlim`来包装，这实际上是PacketDotNet实现的用于实现延迟初始化的类，和Kotlin的`Lazy`一样

     `PayloadPacketOrData`真正有意义的类型是`PacketOrByteArraySegment`，这是一个包装`Packet`对象和`ByteArraySegment`对象的容器，`ByteArraySegment`可以先看做一个字节数组，在后面会进行讲解。总的来说，`PayloadPacketOrData`字段表示当前Packet对象的负载，负载可能是一个`Packet`包，也可能是一个`ByteArraySegment`字节数组

2.   不合法操作判断

     在设置`PayloadPacketOrData`时，判断负载是否等于当前数据包，若相等，则抛出不合法操作异常，一个包中包含首部和负载，将包设置成负载自然是不合法的

3.   设置`PayloadPacketOrData`

     这里`Value`属性获取到`PacketOrByteArraySegment`对象，设置它的`Packet`属性为输入值，`Packet`的上一层包为当前数据包

接下来，我们看看与它相关的其他属性，大多是为了访问方便的只读属性，下面给出源码，省略无关和不重要部分

``` c#
public abstract class Packet {
    // ......
    
    // 判断当前包的负载是否是字节数组
    public virtual bool HasPayloadData => 
        PayloadPacketOrData.Value.Type == PayloadType.Bytes;
    
    // 判断当前包的负载是否是一个包
    public virtual bool HasPayloadPacket => 
        PayloadPacketOrData.Value.Type == PayloadType.Packet;
    
    // 延迟初始化判断PayloadPacketOrData是否已经初始化
    public virtual bool IsPayloadInitialized => PayloadPacketOrData.IsValueCreated;
    
    // PayloadPacketOrData的ByteArraySegment属性，与PayloadPacket类似
    public ByteArraySegment PayloadDataSegment {
    	get {
        	if (PayloadPacketOrData.Value.ByteArraySegment == null) {
            	Log.Debug("returning null");
            	return null;
        	}

        	Log.DebugFormat(
                "result.Length: {0}", 
                PayloadPacketOrData.Value.ByteArraySegment.Length
            );
        	return PayloadPacketOrData.Value.ByteArraySegment;
    	}
    	set => PayloadPacketOrData.Value.ByteArraySegment = value;
	}

    // ......
}
```

>   顺带提一嘴，`Packet`类中有一个`PrintHex`方法，可以返回数据包的十六进制字节，可以用于调试

## ByteArraySegment

在理解其他属性前，我们先来看看这个在之前出现过多次的类型`ByteArraySegment`，数据包的内容字节数组的解析很大程度上要归功于它

在前面的讲解中，我们说`ByteArraySegment`可以看做一个字节数组，的确如此，那么它和普通的字节数组有什么不同呢，我们分成几个部分来分析它的源码，源码中去除了日志等无关内容，首先来看它的属性和构造器

```c#
public sealed class ByteArraySegment : IEnumerable<byte> {

    private int _length;

    // 获取或设置在offset之后的字节数
    public int Length {
        get => _length;
        set {
            if (value < 0) {
                value = 0;
            }
            _length = value;
        }
    }
    
    // 获取被包装的字节数组
    public byte[] Bytes { get; }

    // 设置或获取Bytes中允许处理的最大字节数，这可以控制NextSegment()产生的字节数
    public int BytesLength { get; set; }

    // 获取或设置Bytes中的偏移
    public int Offset { get; set; }
    
    // 构造器
    public ByteArraySegment(byte[] bytes) : this(bytes, 0, bytes.Length) { }

	public ByteArraySegment(byte[] bytes, int offset, int length) 
    	: this(bytes, offset, length, bytes.Length) { }

	public ByteArraySegment(byte[] bytes, int offset, int length, int bytesLength) {
    	Bytes = bytes;
    	Offset = offset;
    	Length = length;
    	BytesLength = Math.Min(bytesLength, bytes.Length);
	}
    
    public ByteArraySegment(ByteArraySegment byteArraySegment) {
    	Bytes = byteArraySegment.Bytes;
    	Offset = byteArraySegment.Offset;
    	Length = byteArraySegment.Length;
    	BytesLength = byteArraySegment.BytesLength;
	}

    // ......
}
```

其中最重要的就是属性，它们表示了字节数组的相关的长度、偏移等信息，依次看一下这些属性的含义

-   `Bytes`：存储被该类包装的字节数组，其他所有属性都是依赖它来设置
-   `BytesLength`：表示字节数组的长度，当它小于`Bytes.Length`时，以该属性的长度值为准
-   `Offset`：表示字节数组的一个偏移位置
-   `_length/Length`：表示`Bytes[Offset, BytesLength)`这一部分的长度

我们画个图来明确这些属性表示的部分

![image-20240314153528345](/assets/img/sharppcap数据包解析原理/image-20240314153528345.png)

可以看到BytesLength才是表示实际可以处理的数组长度，包括在构造器中也有体现，`BytesLength`设置为`bytesLength`和`bytes.Length`的最小值。Offset表示在数组中的一个偏移，Length表示Offset之后的长度，数据包解析的首部和负载的划分就是归功于这两个属性，下面我们就来看看它是如何划分的

```c#
public sealed class ByteArraySegment : IEnumerable<byte> {
    
    public ByteArraySegment NextSegment() {
    	var numberOfBytesAfterThisSegment = BytesLength - (Offset + Length);
    	return NextSegment(numberOfBytesAfterThisSegment);
	}

	public ByteArraySegment NextSegment(int segmentLength) {
    	var startingOffset = Offset + Length; // start at the end of the current segment

    	// ensure that the new segment length isn't longer than the number of bytes
    	// available after the current segment
    	segmentLength = Math.Min(segmentLength, BytesLength - startingOffset);

    	// calculate the ByteLength property of the new ByteArraySegment
    	var bytesLength = startingOffset + segmentLength;

    	return new ByteArraySegment(Bytes, startingOffset, segmentLength, bytesLength);
	}
}
```

这个类中最重要的方法就是这个`NextSegment()`了，在讲解它的原理之前，我们先看看它在哪里使用到了

在`ParsePacket()`中，若`linkLayers`匹配到Ethernet，则构造了一个`EthernetPacket`对象，而在`EthernetPacket`类的方法中，就使用到了`NextSegment()`

```c#
public EthernetPacket(ByteArraySegment byteArraySegment) {
	Header = new ByteArraySegment(byteArraySegment);
	Header.Length = EthernetFields.HeaderLength;
	PayloadPacketOrData = 
        new LazySlim<PacketOrByteArraySegment>(() => ParseNextSegment(Header, Type));
}

internal static PacketOrByteArraySegment ParseNextSegment(ByteArraySegment header, 
                                                          EthernetType type) {
    var payload = header.NextSegment();
	// ......
    return payloadPacketOrData;
}
```

可以看到构造器中首先构造了一个`ByteArraySegment`赋值给Header，设置`Header.Length`为以太网首部的长度，之后下一句相当于将`ParseNextSegment()`的结果赋值给`PayloadPacketOrData`，在`ParseNextSegment()`中调用了`NextSegment()`。现在我们知道了`NextSegment()`在使用之前需要设置一下`Length`属性，并且是设置为首部长度，接下来我们具体看看`NextSegment()`中是如何划分的，以最开始构造`EthernetPacket`为例

构造`EthernetPacket`时传入的`ByteArraySegment`中`Bytes`为整个数据包，`Length`和`BytesLength`都等于`Bytes.Length`，`Offset`为0，调用`NextSegment()`前设置`Length = 14`（以太网首部长度为14B)，如下图所示

![image-20240314161802543](/assets/img/sharppcap数据包解析原理/image-20240314161802543.png)

下面用画图来表示每一步中每个变量的位置

1.   `var startingOffset = Offset + Length;`

     ![image-20240314161945296](/assets/img/sharppcap数据包解析原理/image-20240314161945296.png)

2.   `segmentLength = Math.Min(segmentLength, BytesLength - startingOffset);`

     ![image-20240314162137013](/assets/img/sharppcap数据包解析原理/image-20240314162137013.png)

3.   `var bytesLength = startingOffset + segmentLength;`

     BytesLength不变

4.   `new ByteArraySegment(Bytes, startingOffset, segmentLength, bytesLength);`

     ![image-20240314161444568](/assets/img/sharppcap数据包解析原理/image-20240314161444568.png)

从上面的步骤我们可以看出，对于不同的片段，Length就是该片段的长度，例如对于首部，Length就是首部的长度，对于负载，Length就是负载的长度。那么Offset就起到一个索引的作用，Offset就是该片段在数组中的起始索引

上面的例子是`EthernetPacket`类的特例，我们看看是不是所有的包都可以通过这个过程得到首部和负载的长度，并且Offset就是起始索引

假设有下图所示的`ByteArraySegment`

![image-20240314163339691](/assets/img/sharppcap数据包解析原理/image-20240314163339691.png)

1.   设置首部Length

     Offset就是该首部的起始索引

     ![image-20240314163808828](/assets/img/sharppcap数据包解析原理/image-20240314163808828.png)

2.   调用`NextSegment()`获取负载

     ![image-20240314164807903](/assets/img/sharppcap数据包解析原理/image-20240314164807903.png)

可以看到我们依然获得了符合要求的`ByteArraySegment`对象

## 构造网络层实体

在研究`NextSegment`方法的使用时，我们看到在`EthernetPacket`类中有一个`ParseNextSegment`方法，它是用于解析下一层网络层，构造网络层实体的方法，同时它的返回值赋值给了`PayloadPacketOrData`，那么`EthernetPacket`的负载就是`ParseNextSegment()`中返回的网络层实体对象，下面来看看它的源码

```c#
internal static PacketOrByteArraySegment ParseNextSegment (ByteArraySegment header, 
                                                           EthernetType type) {
    // slice off the payload
    var payload = header.NextSegment();

    var payloadPacketOrData = new PacketOrByteArraySegment();

    // parse the encapsulated bytes
    switch (type) {
        case EthernetType.IPv4: {
            payloadPacketOrData.Packet = new IPv4Packet(payload);
            break;
        }
        case EthernetType.IPv6: {
            payloadPacketOrData.Packet = new IPv6Packet(payload);
            break;
        }
        case EthernetType.Arp: {
            payloadPacketOrData.Packet = new ArpPacket(payload);
            break;
        }
        case EthernetType.Lldp: {
            payloadPacketOrData.Packet = new LldpPacket(payload);
            break;
        }
        case EthernetType.PppoeSessionStage: {
            payloadPacketOrData.Packet = new PppoePacket(payload);
            break;
        }
        case EthernetType.WakeOnLan: {
            payloadPacketOrData.Packet = new WakeOnLanPacket(payload);
            break;
        }
        case EthernetType.VLanTaggedFrame:
        case EthernetType.ProviderBridging:
        case EthernetType.QInQ: {
            payloadPacketOrData.Packet = new Ieee8021QPacket(payload);
            break;
        }
        case EthernetType.TransparentEthernetBridging: {
            payloadPacketOrData.Packet = new EthernetPacket(payload);
            break;
        }
        default: // consider the sub-packet to be a byte array
        {
            payloadPacketOrData.ByteArraySegment = payload;
            break;
        }
    }

    return payloadPacketOrData;
}
```

可以看到中间的部分就是判断type的类型来构造不同的网络层实体对象，包括IPv4、IPv6、ARP等，与`Packet.ParsePacket`方法是类似的

## 结语

数据包解析的基本原理目前先探究到这里，当然这只是冰山一角，但对于相关函数的基本使用已经是不成问题，如果以后还有机会或又遇到了什么问题，再来继续探究

