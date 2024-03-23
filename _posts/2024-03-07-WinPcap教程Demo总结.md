---
title: WinPcap教程Demo总结
date: 2024-03-07
categories: C/C++
tags: WinPcap C/C++
typora-root-url: ./..
---

## 前言

最近学习了WinPcap，对教程中的Demo做一些函数说明补充

## Demo1: 获取接口列表

-   pcap_findalldevs_ex函数：获取接口列表
-   pcap_freealldevs(pcap_if_t*)：释放接口列表资源

```c++
 int pcap_findalldevs_ex(
     char *source,  // 使用的接口，PCAP_SRC_IF_STRING：网络接口，PCAP_SRC_FILE_STRING：文件接口
     struct pcap_rmtauth *auth,  // 用户认证，默认null
     pcap_if_t **alldevs,  // 接口链表头指针
     char *errbuf  // 错误信息缓冲区
     // return：-1表示错误
 );
```

pcap_if_t结构体是pcap_if的typedef，相关类型定义如下

``` c++
 // 接口表项
 struct pcap_if {
     struct pcap_if *next;  // 下一个接口
     char *name;     // 接口名 name to hand to "pcap_open_live()"
     char *description;  // 接口描述 textual description of interface, or NULL
     struct pcap_addr *addresses;  // 该接口的地址列表
     bpf_u_int32 flags;  // PCAP_IF_ interface flags
 };
 
 // 接口地址表项
 struct pcap_addr {
     struct pcap_addr *next;
     // sockaddr是通用地址类型，可表示IPv4、IPv6等地址
     struct sockaddr *addr;      // 网络地址
     struct sockaddr *netmask;   // 子网掩码
     struct sockaddr *broadaddr; // 当前地址对应的广播地址
     struct sockaddr *dstaddr;   // 当前地址的P2P目的地址
 };
 
 // sockaddr定义
 struct sockaddr {
     u_short sa_family;  // 地址类型，AF_INET表示IPv4，AF_INET6表示IPv6
     char    sa_data[14];  // 地址数据
 };
 // sockaddr特定变种，可将sockaddr强转为以下两种
 // IPv4地址
 struct sockaddr_in {
     short   sin_family;  // AF_INET 表示 IPv4
     u_short sin_port;  // 端口号
     struct in_addr  sin_addr;  // IPv4地址
     char    sin_zero[8];
 };
 // IPv6地址
 struct sockaddr_in6 {
     short sin6_family;
     u_short sin6_port;
     u_long sin6_flowinfo;
     struct in6_addr sin6_addr;
     __C89_NAMELESS union {
         u_long sin6_scope_id;
         SCOPE_ID sin6_scope_struct;
     };
 };
```

上述结构的关系如下图所示，一个接口可以拥有多个网络地址，都是以链表形式连接

<img src="/assets/img/2024-03-07-WinPcap教程Demo总结/51fd7ea28c69437790faa1aaf2ce1f9atplv-k3u1fbpfcp-jj-mark0000q75.png" alt="image-20240205190542864"  />

## Demo2：获取接口高级信息

对每个pcap_if对象打印其中的所有信息

-   name：接口名
-   description：接口描述
-   flags：flags & PCAP_IF_LOOPBACK，判断是否是环回地址
-   addresses：pcap_addr地址列表

IPV4地址转换字符串

``` c++
 /**
  * @param in 32位整数地址
  * @return 点分十进制字符串
 */
 char* ipv4_to_s(u_long in) {
     // 12个字符串，每个字符串最大为4个3位数+3个点+null
     static char output[12][3 * 4 + 3 + 1];
     static short which;
     u_char *p;
 
     // IP地址表示为32位整数(u_long)，将其转换为u_char，就是将in按8位拆分，并得到首字节的指针
     p = (u_char*) &in;
     which = (which + 1) % 12;
     sprintf(output[which], "%d.%d.%d.%d", p[0], p[1], p[2], p[3]);
     return output[which];
 }
```

IPv6地址转换字符串

``` c++
 /**
  * @param sockaddr 地址项对象
  * @param address 地址缓冲区
  * @param addrlen 缓冲区长度
  * @return 地址字符串
 */
 char* ipv6_to_s(struct sockaddr* sockaddr, char* address, int addrlen) {
     socklen_t sockaddr_len = sizeof(struct sockaddr_in6);
 
     /**
      * 调用getnameinfo将IPV6地址转换为字符串
      * @param sa sockaddr结构体，表示通用网络地址
      * @param salen sockaddr结构体大小
      * @param host 存储主机名的缓冲区指针
      * @param hostlen 主机名缓冲区大小
      * @param serv 存储服务名(端口号)缓冲区指针
      * @param servlen 端口号缓冲区大小
      * @param flags NI_NUMERICHOST：主机名转换为数字形式，NI_NUMERICSERV：服务名转换为数字形式
      * @return 0 执行成功
      */
     if (getnameinfo(sockaddr, sockaddr_len, address, addrlen,
                     nullptr, 0, NI_NUMERICHOST) != 0) {
         address = nullptr;
     }
 
     return address;
 }
```

## Demo3：打开接口捕获数据包

### 打开接口

-   pcap_open：打开接口
-   pcap_close(pcap_t*)：关闭接口

``` c++
 // 打开接口
 pcap_t *pcap_open(
     const char* source,  // 接口名，pcap_if.name
     int snaplen,  // 截断长度，即捕获的数据包长度，单位B，捕获全部数据包设为65535
     int flags,  // 默认只捕获发送给该接口的包，设置混杂模式捕获全部数据包，PCAP_OPENFLAG_PROMISCUOUS
     int read_timeout,  // 超时时间
     struct pcap_rmtauth *auth, // null
     char* errbuf  // 错误信息缓冲区
     // return pcap_t pcap结构体的typedef，表示已打开接口的描述符
 );
```

该函数返回的pcap_t结构是后续操作该接口的描述符，pcap结构体对用户不可见，由wpcap.dll维护，一个可能的描述（cite. [winpcap - What structure pcap_t have? - Stack Overflow](https://stackoverflow.com/questions/26699631/what-structure-pcap-t-have)）
``` c++
 struct pcap {
     int fd;
     int snapshot;
     int linktype;
     int tzoff;      /* timezone offset */
     int offset;     /* offset for proper alignment */
 
     struct pcap_sf sf;
     struct pcap_md md;
 
     /*
      * Read buffer.
      */
     int bufsize;
     u_char *buffer;
     u_char *bp;
     int cc;
 
     /*
      * Place holder for pcap_next().
      */
     u_char *pkt;
 
 
     /*
      * Placeholder for filter code if bpf not in kernel.
      */
     struct bpf_program fcode;
 
     char errbuf[PCAP_ERRBUF_SIZE];
 };
```

### 捕获数据包

打开接口后，调用pcap_loop捕获数据包，同时还有pcap_dispatch也可捕获数据包，两者参数相同

两者的不同在于pcap_loop在超时时，如果未捕获到数据包，会使进程阻塞，因而可以持续捕获，而pcap_dispatch在超时时会直接返回，不能持续捕获

``` c++
 int pcap_loop(
     pcap_t* handle,  // 打开接口描述符
     int cnt,  // 捕获数据包的数量，0或负数时持续捕获
     pcap_handler handler,  // 捕获数据包的回调函数
     u_char* param  // 传递到回调函数的第一个参数param，
     // return 成功捕获的数据包数量
 );
 
 // pcap_handler定义
 void packet_handler(
     u_char* param,  // pcap_loop传递的参数
     const struct pcap_pkthdr* header,  // 包元数据
     const u_char* pkt_data  // 包内容，字节数组
 );
 
 // 元数据定义
 struct pcap_pkthdr {
     struct timeval ts;  // 时间戳
     bpf_u_int32 caplen; // 分组长度(成功捕获的长度)
     bpf_u_int32 len;    // 包长度
 };
```

## Demo4：非回调捕获包

使用pcap_next_ex捕获一个数据包

``` c++
 int pcap_next_ex(
     pcap_t* handle,  // 打开接口描述符
     struct pcap_pkthdr**  header,  // 包元数据 
     const u_char** pkt_data  // 包内容
     /** 
      * @return 
      * 1：捕获成功
      * 0：超时失败
      * -1：捕获失败，发生异常，可通过pcap_geterr(handle)获取错误信息
      * -2：获取到离线记录文件的最后一个报文(EOF)
     */
 );
```

## Demo5：过滤数据包

-   pcap_compile：编译过滤表达式
-   pcap_setfilter：为捕获会话设置一个过滤器

``` c++
 int pcap_compile(
     pcap_t* handle,  // 打开的接口描述符
     struct bpf_program* bpf,  // 存储编译后的过滤器程序
     const char* str,  // 过滤表达式
     int optimize,  // 是否优化，1：优化，0：不优化
     bpf_u_int32 net_mask  // 子网掩码
     // return 0：成功
 );
 
 int pcap_setfilter(
     pcap_t* handle,  // 打开的接口描述符
     struct bpf_program* bpf  // 过滤器程序
     // return 0：成功
 );
```

## Demo6：UDPdump

### 主流程

1.  获取接口列表
2.  选择接口，获取pcap_if
3.  pcap_open打开接口，获取描述符handle
4.  pcap_datalink检查接口的数据链路层类型，DLT_EN10MB为以太网
5.  pcap_compile编译过滤表达式为bpf_program
6.  pcap_setfilter设置handle的过滤器
7.  pcap_freealldevs释放接口列表
8.  pcap_loop开始捕获

### 回调处理流程

1.  通过pcap_pkthdr结构获取元数据，打印时间戳等信息
2.  将pkt_data解析出IP首部和UDP首部

    处理流程主要是对捕获到的字节数组进行解析，通常的做法就是先定位到要解析的部分的首地址，然后将指针强转为其他类型，指针强转就是改变指针指向的单位，换句话说，就是不同类型的指针移动时以不同的单位进行移动，改变指针类型就是改变指针移动的步长，当指针指向解析部分首地址时，改变指针类型为解析类型，就可以得到解析部分的完整结构了

    ``` c++
     /* 获得IP数据包头部的位置 */
     ip_header* ip = (ip_header*)(pkt_data + 14); // 以太网头部长度，单位B
     
     /* 获得UDP首部的位置 */
     // ip->ver_ihl & 0xf获取低4位值，即ihl
     // 首部长度单位4B，ihl * 4 = IP首部长度字节数
     u_int ip_len = (ip->ver_ihl & 0xf) * 4;
     // ip指针转为字节表示，ip + ip_len = IP包数据部分第一字节，再转为udp_header*，得到UDP首部
     udp_header* udp = (udp_header*)((u_char*)ip + ip_len);
     
     /* 将网络字节序列转换成主机字节序列 */
     // 获取源端口和目的端口并转换，主机字节序和网络字节序不一定相同
     sport = ntohs(udp->sport);
     dport = ntohs(udp->dport);
     // 类似有ntohl, htons，htonl
     
     /* 打印IP地址和UDP端口 */
     printf("%d.%d.%d.%d:%d -> %d.%d.%d.%d:%d\n",
            ip->saddr.byte1,
            ip->saddr.byte2,
            ip->saddr.byte3,
            ip->saddr.byte4,
            sport,
            ip->daddr.byte1,
            ip->daddr.byte2,
            ip->daddr.byte3,
            ip->daddr.byte4,
            dport);
    ```

## Demo7：处理脱机堆文件

### 保存堆文件

将捕获的数据包数据保存到文件中

-   pcap_dump_open：创建并打开堆文件，通常文件名为`*.pcap`
-   pcap_dump：将数据包写入堆文件

``` c++
 pcap_dumper_t* pcap_dump_open(
     pcap_t* handle,  // 打开接口描述符
     const char* filename  // 写入文件路径，注意Windows中相对路径相对于.exe文件
     // return 打开的堆文件描述符，pcap_dumper的typedef
 );
 
 void pcap_dump(
     u_char* param,  // 堆文件描述符，将pcap_dumper_t强转得到，回调时通过param参数传递
     const struct pcap_pkthdr* pkt_header,  // 数据包header
     const u_char* pkt_data  // 数据包内容
 );
```

### 读取堆文件

-   pcap_createscrstr：根据参数生成一个描述接口的source字符串，可用于创建文件接口，使用pcap_open打开，pcap_loop捕获
-   pcap_open_offline：专用于打开文件接口

``` c++
 int pcap_createsrcstr(
     char* source,  // 存储souce字符串的缓冲区
     int type,  // source字符串类型，
     const char* host,  // 远程主机名
     const char* port,  // 远程端口号
     const char* name,  // 接口名称，打开文件接口即文件名
     char* errbuf  // 错误信息缓冲区
     // return 0：成功
 );
 /**
  * type参数
  * PCAP_SRC_FILE：文件接口
  * PCAP_SRC_IFLOCAL：本地接口
  * PCAP_SRC_IFREMOTE：远程接口，必须基于RPCAP协议
  */
 
 pcap_t* pcap_open_offline(
     const char* filename,  // 文件名
     char* errbuf  // 错误信息缓冲区
     // return 文件接口描述符
 );
```

## Demo8：发送数据包

### 发送单个数据包

pcap_sendpacket：发送单个数据包

``` c++
 int pcap_sendpacket(
     pcap_t* handle,  // 打开接口描述符 
     const u_char* packet,  // 数据包，包含首部信息
     int packet_len  // 包大小，单位B
     // return 0：成功
 );
```

### 发送队列

使用发送队列，发送队列相关函数

-   pcap_sendqueue_alloc：创建指定大小的发送队列
-   pcap_sendqueue_queue：将包添加到发送队列
-   pcap_sendqueue_transmit：传输发送队列
-   pcap_sendqueue_destroy：销毁发送队列

``` c++
 pcap_send_queue* pcap_sendqueue_alloc(
     u_int memsize  // 发送队列大小，单位B
     // return 队列对象
 );
 
 int pcap_sendqueue_queue(
     pcap_send_queue* queue,  // 发送队列对象
     const struct pcap_pkthdr *pkt_header,  // 包header
     const u_char *pkt_data  // 包内容
     // return 0：成功，-1：失败
 );
 
 u_int pcap_sendqueue_transmit(
     pcap_t* p,  // 发送接口描述符
     pcap_send_queue* queue,  // 发送队列
     int sync  // 是否同步发送
     // return 成功发送的字节数
 );
```

## Demo9：收集并统计网络流量

pcap_setmode：设置接口为统计模式

``` c++
 int pcap_setmode(
     pcap_t* p,  // 接口描述符
     int mode  // 模式
     // return 0：成功，-1：失败
 );
 /**
  * mode参数
  * MODE_CAPT：捕获模式，仅捕获数据包
  * MODE_STAT：统计模式，获取统计信息
  * MODE_MON：监视模式，接口设置为混杂模式
  */
```

开始捕获后，pkt_header和pkt_data为统计信息，具体如下所示

-   pkt_header中包含ts时间戳，成功捕获长度为包内容大小(统计信息)，pkt_data共16B

-   pkt_data中前8B为AcceptedPackets已捕获的数据包数量，后8B为AcceptedBytes已捕获字节数

    `*((LONGLONG*)pkt_data)`获取AcceptedPackets数值

    `*((LONGLONG*)(pkt_data + 8))`获取AcceptedBytes数值

<img src="/assets/img/2024-03-07-WinPcap教程Demo总结/1ae58bd0069649b7b5a1d07404199ec2tplv-k3u1fbpfcp-jj-mark0000q75.png" alt="image-20240207192014454"  />

---

补充：LARGE_INTEGER类型

LARGE_INTEGER可表示一个64位符号数，定义如下

``` c++
typedef union _LARGE_INTEGER {
  __C89_NAMELESS struct {
    DWORD LowPart;
    LONG HighPart;
  } DUMMYSTRUCTNAME;
  struct {
    DWORD LowPart;
    LONG HighPart;
  } u;
  LONGLONG QuadPart;
} LARGE_INTEGER;
```

LowPart存储64位数的低32位，HighPart存储64位数的低32位，当编译器不支持64位数时，LARGE_INTEGER通过LowPart和HighPart表示一个64位数，当支持64位数时，LARGE_INTEGER等价于LONGLONG(aka. __int64, long long)，可直接使用QuadPart

