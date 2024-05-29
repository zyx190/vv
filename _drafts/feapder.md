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

