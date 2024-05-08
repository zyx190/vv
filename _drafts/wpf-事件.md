---
layout: post
title: WPF基础——事件
categories: [C#, WPF]
tags: [C#, WPF]
typora-root-url: ./..
---

## 开始

事件模型的3个关键点

-   事件拥有者：消息的发送者
-   事件响应者：消息的接收者，使用事件处理器处理事件
-   订阅关系

C#中使用event关键字修饰的委托实现事件模型，event事件是一个只允许内部调用的委托

## 路由事件

与直接响应事件不同，路由事件可以在Visual Tree中传播，Visual Tree中的元素设置事件监听，若监听到事件传播到当前元素，则调用事件响应器进行处理

### 基本使用

元素添加路由事件响应器

```c#
MyElement.AddHandler(Button.ClickEvent, new RoutedEventHandler(MyClick));

private void MyClick(object sender, RoutedEventArgs e) {
    // ...
}
```

当某个Button被点击时，点击事件会沿着Visual Tree向上传播，当传播到MyElement时调用MyClick进行处理，sender参数是响应器的调用者，即MyElement，通过`e.OriginalSource`可以获取事件的发送者，即被点击的按钮

### 自定义路由事件

自定义路由事件使用与依赖属性类似的定义形式，分别定义一个静态事件字段和一个CLR属性包装器
