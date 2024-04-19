---
layout: post
title: Android基础——Activity
categories:
- Android
tags:
- Android
typora-root-url: ./..
image:
  path: "/assets/img/android-开始/android.jpg"
date: 2024-04-18 13:22 +0800
---
## 开始

Activity是四大组件之一，是一个包含用户界面的组件，用于和用户进行交互

一个程序可以存在多个Activity，每个Activity必须重写`onCreate`方法，在`onCreate`方法中设置布局文件，`setContentView(R.layout.l)`

Activity需要在`AndroidManifest.xml`中注册才能生效

在AndroidManifest中在activity标签中注册，`android:name`属性指明注册的Activity

activity标签中的`intent-filter`标签中指定该标签为主Activity

```xml
<intent-filter>
	<action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
</intent-filter>
```

Activity销毁：销毁Activity表示退出当前界面，调用`finish()`销毁当前Activity

## Activity交互

Intent是各个组件交互的方式，通过Intent在不同Activity间进行跳转，它指明了改组件想要执行的动作或者在组件间传递数据

>   注意多个Activity都需要在AndroidManifest中进行注册
{: .prompt-info }

### 显式Intent

通过构造函数构造一个Intent对象，传入启动Activity的上下文和想要启动的目标`Activity.class`，在调用`startActivity(intent)`启动Activity

```java
Intent intent = new Intent(context, Activity.class);
context.startActivity(intent);
```

### 隐式Intent

在`AndroidManifest.xml`指定`action`和`category`等信息，由系统去分析信息，启动能够响应这些信息的Activity，通过隐式Intent可以也启动其他程序的Activity

基本步骤

-   通过intent-filter标签下的action和category标签指定信息

    ```xml
    <!--设置Activity能够响应的action和category-->
    <activity android:name=".Activity">
    	<intent-filter>
    		<action android:name="com.example.activitytest.ACTION_START"/>
            <category android:name="android.intent.category.DEFAULT"/>
        </intent-filter>
    </activity>
    ```

-   构造Intent对象时传入相应的信息字符串，即可启动相应的Activity

    ```java
    Intent intent = new Intent("com.example.activitytest.ACTION_START");
    context.startActivity(intent);
    ```

-   每个Intent对象只能指定一个action信息，但可以指定多个category信息，通过`addCategory()`添加

data标签：在`intent-filter`标签中设置data标签，可以指明该Activity可以响应什么类型的数据

data标签属性

- scheme:指定协议部分，https协议，geo地理位置，tel拨打电话
- host:指定数据的主机名
- port:指定数据的端口
- path:指定数据域名后的路径
- mimeType:指定可以处理的数据类型

启动系统浏览器

```java
Intent intent = new Intent();
intent.setAction("android.intent.action.VIEW");
Uri url = Uri.parse("https://www.baidu.com/");
intent.setData(url);
startActivity(intent);
```

### 启动Activity的最佳实践

当启动一个Activity时，可能需要向Activity传递参数，但可能并不知道参数是什么

在该Activity中定义一个静态方法`actionStart()`，传入启动该Activity的上下文和需要的参数，在该方法中构造Intent对象完成数据传递，同时简化了启动代码

```java
public static void actionStart(Context context,String data1,String data2){
	Intent intent = new Intent(context,SecondActivity.class);
	intent.putExtra("param1","data1");
	intent.putExtra("param2","data2");
	context.startActivity(intent);
}

// 使用时，参数直接在参数列表中体现
SecondActivity.actionStart(FirstActivity.this,"data1","data2");
```

### 向Activity传递数据

将数据存储在Intent中，在下一个Activity中将数据中Intent中取出

调用`Intent.putExtra(key, value)`将数据存储到Intent中，采用键值对存储

在下一个Activity中调用`getIntent()`获取Intent对象

调用`intent.getStringExtra(key)`获取value，根据value的类型来调用getStringExtra()、getIntExtra()等

### 返回数据给Activity

>   `startActivityForResult`方法已弃用，仅记录最新方法
{: .prompt-info }

在新版Android中，将两个Activity的数据交互作了对象封装，使用一个`ActivityResultLauncher`对象封装返回数据的回调操作，同时通过它来启动Activity

```java
// 调用registerForActivityResult注册一个launcher
// 传入Activity返回结果的协定，即StartActivityForResult
// 传入返回数据回调
ActivityResultLauncher<Intent> intentActivityResultLauncher = registerForActivityResult(
        new ActivityResultContracts.StartActivityForResult(),
        result -> {
            if (result.getResultCode() == RESULT_OK) {
                //获取返回的结果
                String data = result.getData().getStringExtra("data");
            }
        });
 
// 通过launcher启动Activity
Intent intent = new Intent(context, Activity.class);
intent.putExtra("data", "xxx");
intentActivityResultLauncher.launch(intent);
```

### Activity的生命周期

Activity的层叠结构为栈

Activity的四种状态

- 运行状态：当前正在操作的Activity处于运行状态
- 暂停状态：Activity不再处于栈顶，但仍然可见(栈顶Activity大小没有占满屏幕)
- 停止状态：Activity不处于栈顶也不可见
- 销毁状态：Activity从栈移除后处于销毁状态，系统会回收该Activity

Activity的状态缓存：Activity被回收后重建，保存输入的临时数据

Activity在被回收前会调用`onSaveInstanceState()`方法，可以重写该方法添加自定义的临时数据，以便在Activity重建时，通过`onCreate`的bundle参数获取临时数据

`onSaveInstanceState()`方法传入一个Bundle类型的参数，其中包含了当前Activity的临时数据，调用`putString()`、`putInt()`等方法通过键值对保存数据

在`OnCreate()`中判断Bundle参数是否为null，调用`getString()`、`getInt()`等方法获取保存的数据

```java
public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        String myString = "";
        // 获取状态缓存
        if (savedInstanceState != null) {
            myString = savedInstanceState.getString("MyString");
        }
    }
    
    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        // 缓存状态
        savedInstanceState.putString("MyString", "Welcome back to Android");
        super.onSaveInstanceState(savedInstanceState);
    }
}
```

> 在手机屏幕旋转时会重新创建Activity，调用onCreate()，可以使用`onSaveInstanceState()`保存临时数据或通过ViewModel保存
{: .prompt-tip }

### Activity的启动模式

Activity的启动模式有四种：standard, singleTop, singleTask, singleInstance，通过activity标签的launchMode属性指定启动模式

- standard：在Activity处于栈顶时依然会创建该Activity的新的实例
- singleTop：在Activity处于栈顶时不会重复创建实例，直接使用栈顶Activity，处于其他位置时会重复创建
- singleTask：当启动某个Activity时会检查整个栈，若已存在相同实例，则直接使用该实例并将在其之上的其他实例出栈，使其成为栈顶，若没有，则创建新的实例
- singleInstance：使用一个新的栈来管理启动的Activity，该返回栈独立于当前程序的返回栈，当其他程序访问该Activity时，会共用这个返回栈，当程序处理返回栈时，优先处理程序本身的返回栈，最后处理独立的返回栈

## Activity相关工具

### Toast弹出提示

调用Toast的静态方法makeText，返回一个Toast对象，再调用show()显示提示

```java
Toast.makeText(this, "Tip", Toast.LENGTH_SHORT).show();
```

makeText()传入三个参数

- Toast所处的上下文，传入this即可
- Toast显示的内容
- Toast显示的时长，可选`Toast.LENGTH_SHORT`,`Toast.LENGTH_LONG`

### Log日志工具

使用Log类进行日志记录

打印日志方法

- `Log.v()`：对应级别verbose，打印级别最低的日志
- `Log.d()`：对应级别debug，打印调试信息
- `Log.i()`：对应级别info，打印一般信息
- `Log.w()`：对应级别warn，打印警告信息
- `Log.e()`：对应级别error，打印错误信息

方法传入两个参数，tag和msg，tag用于对日志信息进行过滤，msg为打印的日志内容

添加自定义过滤器，tag参数输入过滤器的日志标签，可打印对应标签的的日志

## Fragment

Fragment是一种可以嵌入在Activity中的UI片段，可以充分利用大屏幕空间，用于在一个Activity中显示不同布局，当切换布局时只需引入fragment

静态添加Fragment

- 编写Fragment的布局
- 自定义Fragment类继承AndroidX的Fragment类
- 重写onCreateView，动态加载Fragment的布局
- 在Activity布局中添加fragment控件，name属性指定要在该控件处实例化的Fragment类

动态添加Fragment

- 在Activity布局中添加一个布局容器，不添加内容
- 创建要添加的Fragment实例
- 调用`getSupportFragmentManager()`获取`FragmentManager`对象
- 开启一个事务，调用`manger.beginTransaction()`，返回一个`FragmentTransaction`对象
- 调用`transaction.replace()`，传入布局容器的id和要添加的Fragment实例
- 若要返回时不退出Activity而返回上一个Fragment，调用`transaction.addToBackStack(null)`
- 调用`transaction.commit()`提交事务

### Fragment与Activity交互

-   Activity中调用Fragment

    使用FragmentManager中的findFragmentById(R.id.frag)获取该布局的Fragment类实例

-   Fragment中调用Activity

    调用getActivity()获取与该类实例相关联的Activity，Activity是Context类型，可供Fragment使用

Fragment的生命周期与Activity类似，被回收时也可通过onSaveInstanceState()保存数据

### 动态加载布局

根据设备的不同属性来自动选择资源中的布局

资源中的子文件夹命名使用限定符可以指定该资源提供给哪一类设备

屏幕特征对应的设备

- 大小
    - small：小设备
    - normal：中等设备
    - latge：大设备
    - xlarge：超大设备
- 分辨率
    - ldpi：低分辨率
    - mdpi：中分辨率
    - hdpi：高分辨率
    - xhdpi：超高分辨率
    - xxhdpi：超超高分辨率
- 方向
    - land：横屏
    - port：竖屏

最小宽度限定符：对屏幕宽度设定一个最小值(单位dp)，大于该值加载一个布局，小于该值加载另一个布局

文件夹命名后缀：\_sw600dp，最小宽度为600dp
