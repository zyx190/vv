---
layout: post
title: feapder爬虫框架
categories:
- Python
- 爬虫
tags:
- feapder
- Python
- 爬虫
typora-root-url: ./..
---

## 开始

feapder是一款上手简单，功能强大的Python爬虫框架，内置AirSpider、Spider、TaskSpider、BatchSpider四种爬虫解决不同场景的需求，支持断点续爬、监控报警、浏览器渲染、海量数据去重等功能，更有功能强大的爬虫管理系统feaplat为其提供方便的部署及调度

官方文档：[feapder官方文档](https://feapder.com/#/README)

安装完整版feapder

```shell
pip install "feapder[all]"
```

创建简单爬虫

```shell
feapder create -s my_spider
```

生成的简单爬虫实现

```python
import feapder


class MySpider(feapder.AirSpider):
    
    # 发送请求方法
    def start_requests(self):
        yield feapder.Request("https://spidertools.cn")

    # 解析响应方法
    def parse(self, request, response):
        # 提取网站title
        print(response.xpath("//title/text()").extract_first())
        # 提取网站描述
        print(response.xpath("//meta[@name='description']/@content").extract_first())
        print("网站地址: ", response.url)


if __name__ == "__main__":
    # 构造对象后，调用start方法启动爬虫
    MySpider().start()
```

## create命令

create命令用于创建feapder项目，常用选项有`-p`、`-s`、`-i`

使用`-p`选项创建一个爬虫项目

```
feapder create -p <project_name>
```

项目结构如下

```
my_spider
  │  CHECK_DATA.md
  │  main.py
  │  README.md
  │  setting.py
  │
  ├─items
  │  └─ __init__.py
  │
  └─spiders
     └─ __init__.py
```

-   items：文件夹存放与数据库表映射的item
-   spiders：文件夹存放爬虫脚本
-   main.py：运行入口
-   setting.py：爬虫配置文件

使用`-s`选项创建单个爬虫

```
feapder create -s <spider_name>
```

可以选择四种爬虫模板

-   AirSpider：轻量爬虫
-   Spider：分布式爬虫
-   TaskSpider：任务爬虫
-   BatchSpider：批量爬虫

使用`-i`选项创建数据库表的映射对象

```
feapder create -i <item_name>
```

可以选择四种item模板

-   Item
-   字典Item
-   UpdateItem
-   字典UpdateItem 

其他命令行工具详见文档：[命令行工具 - feapder官方文档](https://feapder.com/#/command/cmdline)

## Request

Request为feapder的下载器，基于requests进行了封装，因此支持requests的所有参数

常用属性

| 属性            | 描述                                    |
| --------------- | --------------------------------------- |
| url             | 待抓取url                               |
| retry_times     | 当前重试次数                            |
| priority        | 请求优先级，越小越优先，默认300         |
| parser_name     | 回调函数所在的类名，默认为当前类        |
| callback        | 回调函数，可以是函数，也可是函数名      |
| filter_repeat   | 是否需要去重                            |
| auto_request    | 是否需要自动请求下载网页，默认是        |
| request_sync    | 是否同步请求下载网页，默认异步          |
| use_session     | 是否使用session方式                     |
| download_midware | 下载中间件，默认为parser中的download_midware |
| render | 是否用浏览器渲染，对于动态加载页面，使用浏览器渲染后再获取源码 |
| render_time | 渲染时长，即打开网页等待指定时间后再获取源码 |
| method          | 请求方式                                |
| params          | 请求参数                                |
| data            | 请求body                                |
| headers         | 请求头                                  |
| cookies         | 字典或CookieJar对象                     |
| timeout         | 等待服务器数据的超时限制                |
| allow_redirects | 是否允许跟踪POST/PUT/DELETE方法的重定向 |
| **kwargs        | 自定义数据，可传递到解析方法中          |

### 发送请求

调用`get_response`方法获取响应，`save_cached`参数指定是否将响应缓存到Redis，需要在`setting.py`或在环境变量中设置Redis

```python
def get_response(self, save_cached=False):
    """
    获取带有selector功能的response
    @param save_cached: 保存缓存，方便调试时不用每次都重新下载
    @return:
    """
    pass
```

### 获取缓存的响应

调用`get_response_from_cached`方法从缓存中获取响应，缓存同样依赖redis，因此需要先配置好redis连接信息

```python
def get_response_from_cached(self, save_cached=True):
    """
    用于从缓存中取response
    当缓存不存在时，会先下载，然后将响应存入缓存，之后再返回响应
    @param save_cached: 保存缓存，方便调试时不用每次都重新下载
    @return:
    """
    pass
```

## Response

Response对requests返回的response进行了封装，因此支持response所有方法

### 响应解析

-   支持xpath选择器

    ```python
    response.xpath("//a/@href")
    ```

-   支持css选择器

    ```python
    response.css("a::attr(href)")
    ```

-   支持正则表达式

    ```python
    response.re("<a.*?href='(.*?)'")
    ```

-   支持BeautifulSoup

    ```python
    response.bs4().title
    ```

### 常用功能

-   获取响应源码

    ```python
    response.text
    ```

-   获取json数据

    ```python
    response.json
    ```

-   查看下载内容：打开浏览器，渲染下载内容

    ```python
    response.open()
    ```

-   将`requests.Response`转换为`feapder.Response`

    ```python
    response = feapder.Response(response)
    ```

-   序列化

    ```python
    response_dict = response.to_dict
    ```

-   反序列化

    ```python
    feapder.Response.from_dict(response_dict)
    ```

## AirSpider

AirSpider是一款轻量爬虫，面对一些数据量较少，无需断点续爬，无需分布式采集的需求，可采用此爬虫

```python
import feapder


class AirSpiderTest(feapder.AirSpider):
    
    # 爬虫自定义配置，仅对当前爬虫有效，优先级大于配置文件
    __custom_setting__ = dict(
        PROXY_EXTRACT_API="代理提取地址",
    )
    
    # 分发请求任务函数
    def start_requests(self):
        yield feapder.Request("https://www.baidu.com")
        # 设置自定义解析函数
        yield feapder.Request("url2", callback=self.parser_detail)
        # 设置自定义下载中间件
        yield feapder.Request("url3", download_midware=self.my_midware)

    # 默认响应解析函数
    def parse(self, request, response):
        # 抛出异常即可自动重试
        if response.status_code != 200:
        	raise Exception("非法页面")
        print(response)
        
    # 自定义解析函数
    def parse_detail(self, request, response):
        pass
    
    # 默认下载中间件，在parse函数之前调用
    def download_midware(self, request):
        request.headers = {'User-Agent':"lalala"}
        return request
    
    # 自定义下载中间件
    def my_midware(self, request):
        return request
    
    # 校验函数, 可用于校验response是否正确
    # 若函数内抛出异常，则重试请求
    # 若返回True 或 None，则进入解析函数
    # 若返回False，则抛弃当前请求
    # 可通过request.callback_name 区分不同的回调函数，编写不同的校验逻辑
    def validate(self, request, response):
        pass


if __name__ == "__main__":
    # 使用多线程
    AirSpiderTest(thread_count=10).start()
```



