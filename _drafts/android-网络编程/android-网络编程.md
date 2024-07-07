---
layout: post
title: Android基础——网络编程
categories: [Android]
tags: [Android]
typora-root-url: ./
---

### 网络编程

#### WebView

WebView控件用于展示网页

在代码中获取控件，调用setSettings()设置相关属性

setJavaScriptEnabled(true)使WebView支持JavaScript脚本

setWebViewClient(new WebViewClient())使网页在当前WebView中显示而不是打开浏览器

使用网络需要声明权限`<uses-permission android:name="android:permission.INTERNET">`

#### 使用HttpURLConnection

- 创建URL对象，调用url.openConnection()获取HttpURLConnection实例
- 设置属性：请求方式requestMethod，连接超时connectionTimeout等
- 调用getInputStream()获取输入流，通过输入流读取数据
- 发送POST请求，设置requesMethod为POST，构造`DataOutputStream(connection.getOutputStream())`，调用writeBytes(“key=value&key1=value1”)写入
- 调用disconnect()关闭连接

#### 使用OkHttp

- 构造OkHttpClient对象
- 调用Request.Builder().build()构造request对象，通过连缀调用设置属性：URL，post等
- 调用client.newCall(request)获取Call对象，调用execute()发送请求，返回response对象，通过response对象获取信息
- 发送post请求，先调用FormBody.Builder().build()构造requestBody对象，通过连缀调用设置属性，将该对象传入request对象的setPost()中

#### XML解析

##### Pull

调用xmlPullParser的方法进行解析

##### SAX解析

创建类继承DefaultHandler，重写方法，将该对象设置到XMLReader中

#### JSON解析

##### JSONObject

调用JSONObject的相关方法解析

##### GSON

调用gson.fromJson()，自动解析为指定类型的实体类对象

#### 网络请求回调

网络请求是耗时的任务，一般在子线程中进行

在子线程中发送请求无法接收数据，定义一个接口listener，用于在接收数据后回调listener中的方法，将接收的数据传入方法中，在方法中处理数据，实现数据接收

在使用OkHttp时，调用newCall(request)调用enqueue(callback)，在enqueue中会自动开启子线程，callback是okhttp3的内置参数，是okhttp3.Callback类型

#### Retrofit

- 定义不同种类的接口文件，接口中的方法使用注解来指定访问地址和访问方法，返回值为指定泛型的Call对象
- 在代码中调用`Retrofit.Builder().build()`构造Retrofit对象，使用连缀调用设置属性，baseUrl指定所有请求的根路径，addConverterFactory(GsonConverterFactory.create())设置解析时使用的转换库
- 调用retrofit.create()，传入接口文件的Class，返回接口的动态代理对象
- 调用接口中的方法返回Call对象，调用enqueue()在子线程中发起请求

---

处理复杂的接口地址

GET请求

- URL地址中处理变化的页数

    在注解中使用\{page\}占位，在方法中添加该参数，在参数前加上注解@Path(“page”)

- 处理URL地址中？后附带数据

    在方法中添加参数，在参数前加上注解@Query(“key”)

DELETE请求

使用@DELETE注解，返回Call对象的泛型指定为ResponseBody，表示可接受任意类型的响应且不会对数据进行解析

POST请求

使用@POST注解，在方法中添加参数，加上@Body注解

指定header参数

使用@Headers注解，静态声明在方法上直接指定参数，动态声明在方法中添加参数，加上注解

---

Retrofit构建器

构造出的Retrofit对象全局通用，将获取接口动态代理对象的步骤封装，使用单例类封装

