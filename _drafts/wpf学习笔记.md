---
layout: post
title: WPF学习笔记
categories: C#
tags: C# WPF
typora-root-url: ./..
---

## 开始

WPF是Windows平台的UI框架，使用C#和xaml语言编写，xaml语言是xml语言的扩展

使用Visual Studio创建WPF应用程序，生成如下文件

![image-20240311194923473](/assets/img/wpf学习笔记/image-20240311194923473.png)

-   依赖项中`NETCore.App`是.NET平台应用程序的依赖，`WindowDeskTop.App.WPF`是WPF框架的依赖

-   `App.xaml`：描述整个应用程序

    -   `StartupUri`指明主页面
    -   `xmlns:local`：将项目代码的命名空间引入到xaml中
    -   `Application.Resource`：声明当前布局中使用的资源（自定义类等）

    ```xml
    <Application x:Class="frontend.App"
                 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                 xmlns:local="clr-namespace:frontend"
                 StartupUri="MainWindow.xaml">
        <Application.Resources>
             
        </Application.Resources>
    </Application>
    ```

-   `MainWindow.xaml`：描述主页面布局

    -   `x:Class`：指明该布局编译生成的类

        一个界面后台类通常使用`partial`关键字声明，表示将该类的定义拆分，如后台C#类是`MainWindow`，使用partial声明，xaml中`x:Class="MainWindow"`，表示该xaml编译生成一个界面类，在编译时会合并到指定的后台类中

    -   `xmlns:local`：将项目代码的命名空间引入到xaml中

    ``` xml
    <Window x:Class="frontend.MainWindow"
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
            xmlns:local="clr-namespace:frontend"
            mc:Ignorable="d"
            Title="MainWindow" Height="450" Width="800">
        <Window.Resources>
            <!--
    			frontend命名空间中包含自定义类MyClass
    			public class MyClass {
    				public string Name { get; set; }
    			}
    			可通过Window子类的FindResources函数，传入Key获取到该资源，类型为Object
    		-->
        	<local x:Key="myClass" Name="Hello"/>
        </Window.Resources>
        <Grid>
    
        </Grid>
    </Window>
    ```

## XAML

XAML对XML进行了扩展，支持多种形式的属性设置，主要有以下三种方式

-   键值对赋值

    ```xml
    <Button Content="Hello"/>
    ```

-   属性标签：每个标签看做一个对象，可嵌套它的属性标签设置属性，适用于复杂对象属性赋值

    ``` xml
    <Button>
    	<Button.Content>
            <TextBlock Text="Hello"/>
        </Button.Content>
    </Button>
    ```

-   标签扩展：在`attr=value`形式上，value进行扩展，适用于复杂对象属性赋值

    ```xml
    <!--在{}中构造对象，如控件绑定、使用资源等-->
    <TextBlock Text="{Binding ElementName=obj, Path=Value, Mode=OneWay}"/>
    ```

    `Binding`为类名，后跟的键值对是对该类对象的属性进行赋值，示例中将`ElementName`赋值为`obj`，`Path`赋值为`Value`，`Mode`赋值为`OneWay`，只有`MarkupExtension`类的子类才支持标签扩展

    使用标签扩展实际是调用了类的构造器，因此可不指定属性名，按顺序赋值

    ```xml
    <!--将Path赋值为Value-->
    <TextBlock Text="{Binding Value}"/>
    ```

### 事件处理器

标签对象中有些属性接收一个处理函数，这种函数称为事件处理器，实现一个事件处理主要定义三个要素

1.   指定事件
2.   实现事件处理器
3.   建立订阅

以Button点击为例

-   指定事件

    ``` xml
    <!--在x命名空间的Name属性指定控件的id-->
    <Button x:Name="MyButton" Click=""/>
    ```

-   实现事件处理器

    ```c#
    namespace App {
        public partial class MainWindow : Window {
            // ...
            
            // 实现事件处理器
            private void MyButton_Click(object sender, RoutedEventArgs e) {
                // statements;
            }
        }
    }
    ```

-   建立订阅：有两种方式，通过xaml设置或者通过C#代码设置

    -   通过xaml设置

        ``` xml
        <Button x:Name="MyButton" Click="MyButton_Click"/>
        ```

    -   通过C#代码设置

        ```c#
        // Click是一个委托，将Click的功能委托到MyButton_Click
        this.MyButton.Click += new RoutedEventHandler(MyButton_Click);
        ```

### 引用类库

将类库引入到xaml的语法如下

```xml
xmlns:{自定义名称}="clr-namespace:{类库命名空间}";assembly={类库文件名}"
```

使用命名空间中的类

```xml
<自定义名称:类><自定义名称:类/>
```

### X命名空间

X命名空间中包含解析xaml文件的内容，通常使用其中的元素和属性来标记xaml标签

-   `x:Class`：指定编译生成的界面类合并到哪个后台类，只能用于根标签

-   `x:ClassModifier`：指定xaml界面类的访问级别，应与后台类的访问级别相同

-   `x:Name`

    xaml中每个元素都是一个实例对象，`x:Name`为xaml元素实例生成引用（类似创建id），若元素自带Name属性，则同时将`x:Name`赋值给Name属性

    若元素有Name属性，则设置Name属性也能引用到元素实例，但有些元素没有Name属性，此时只能使用`x:Name`，为了统一，推荐仅使用`x:Name`引用元素

-   `x:FieldModifier`：设置元素实例的访问级别，作为元素的属性使用

-   `x:Key`：用于标识资源字典中的资源，在C#中使用`FindResource`方法获取

-   `x:Shared`：与`x:Key`配合使用，值为true时，获取到的资源是同一个对象，否则是该资源的副本

-   `x:Type`：标签扩展，用于访问`Type`类型对象，传入`TypeName`属性

-   `x:Null`：标签扩展，用于将对象的某个属性设为null

-   `x:Array`：标签扩展，可以构造一个数组，`Type`属性指定数组元素的类型

-   `x:Static`：标签扩展，用于访问类的静态成员，传入类的静态成员

## 控件

### 控件模型

WPF中的控件主要分为6类控件，分别是布局控件、内容控件、带标题内容控件、集合控件、带标题集合控件、特殊内容控件，这些控件类的继承关系如下

![Screenshot_20240322_215401_cn.wps.moffice_eng](/assets/img/wpf学习笔记/Screenshot_20240322_215401_cn.wps.moffice_eng.jpg)

-   ContentControl：单一内容控件
-   HeaderedContentControl：带标题单一内容控件
-   ItemsControl：以集合为内容的控件
-   HeaderedItemsControl：带标题的以条目集合为内容的控件
-   Decorator：控件装饰元素
-   Panel：面板类控件
-   TextBox：文本输入框
-   TextBlock：静态多行文本
-   Shape：图形元素

每个控件都有一个属性用于引用内部的子控件对象，该属性称为内容属性，有些控件内容属性是`Content`，有些是`Children`，有些是`Items`，控件标签内部区域专门映射了控件的内容属性

```xml
<Button>
	Hello
</Button>
<!--相当于-->
<Button Content="Hello"></Button>
```

#### ContentControl

内容属性是`Content`，内容只能包含一个子元素，若需要包含多个元素，则使用一个容器元素包装多个元素后放入内容

-   Button
-   ButtonBase
-   CheckBox
-   ComboBoxItem
-   ContentControl
-   Frame
-   GridViewColumnHeader
-   GroupItem
-   Label
-   ListBoxItem
-   ListViewItem
-   NavigationWindow
-   RadioButton
-   RepeatButton
-   ScrollViewer
-   StatusBarItem
-   ToggleButton
-   ToolTip
-   UserControl
-   Window

#### HeaderedContentControl

该族继承自ContentControl，除了`Content`属性还包含`Header`属性用于显示标题，`Header`只能接收一个子元素

主要包含以下元素

-   Expander
-   GroupBox
-   HeaderedContentControl
-   TabItem

#### ItemsControl

内容属性为`Items`或`ItemsSource`，每个集合容器都有对应的子项容器，如`ListBoxItem`、`ListViewItem`

主要包含以下控件

-   Menu
-   MenuBase
-   ContextMenu
-   ComboBox
-   ItemsControl
-   ListBox
-   ListView
-   TabControl
-   TreeView
-   Selector
-   StatusBar

ItemsControl会对内容中的单个元素自动使用子项容器进行包装

```xml
<ListBox>
	<Button></Button>
    <Button></Button>
</ListBox>
<!--相当于-->
<ListBox>
	<ListBoxItem>
    	<Button></Button>
    </ListBoxItem>
    <ListBoxItem>
    	<Button></Button>
    </ListBoxItem>
</ListBox>
```

ItemsControl对应的子项容器如下

| ItemsControl | Item Container |
| ------------ | -------------- |
| ComboBox     | ComboBoxItem   |
| ContextMenu  | MenuItem       |
| ListBox      | ListBoxItem    |
| ListView     | ListViewItem   |
| Menu         | MenuItem       |
| StatusBar    | StatusBarItem  |
| TabControl   | TabItem        |
| TreeView     | TreeViewItem   |

#### HeaderedItemsControl

内容属性为`Items`、`ItemsSource`、`Header`

主要包含以下控件

-   MenuItem
-   TreeViewItem
-   ToolBar

#### Decorator

内容属性为`Child`，对元素起装饰作用，只能有一个元素作为内容

主要有以下元素

-   ButtonChrome
-   ClassicBorderDecorator
-   ListBoxChrome
-   SystemDropShadowChrome
-   Border
-   InkPresenter
-   BulletDecorator
-   Viewbox
-   AdornerDecorator

#### Panel

内容属性为`Children`，内容可包含多个元素

主要有以下元素

-   Canvas
-   DockPanel
-   Grid
-   TabPanel
-   ToolBarOverflowPanel
-   StackPanel
-   ToolBarPanel
-   UniformGrid
-   VirtualizingPanel
-   VirtualizingStackPanel
-   WrapPanel

### 控件通用属性

-   基本属性

    -   Width
    -   Height
    -   Visibility：控件是否可见

    Width和Height支持`px`、`in`、`cm`、`pt`四种单位，支持三种方式赋值

    -   绝对值：默认单位为`px`
    -   比例值：在数值后加一个`*`，数值为占用比例
    -   自适应：`Auto`

-   颜色样式

    -   Foreground：控件文本颜色
    -   Background：控件背景色
    -   Opacity：不透明度
    -   Clip：用于定义控件的裁剪区域的几何形状

-   字体

    -   FontFamily
    -   FontSize
    -   FontStretch
    -   FontStyle
    -   FontWeight

-   边框

    -   BorderBrush：边框颜色
    -   BorderThickness：边框宽度

-   布局

    -   Margin
    -   Padding
    -   HorizontalAlignment：在父容器中的水平对齐方式
    -   VerticalAlignment：在父容器中的垂直对齐方式

-   交互

    -   IsEnabled：是否允许控件响应
    -   Name：控件唯一标识符
    -   Focusable：是否可获取焦点
    -   ContextMenu：右键点击时的上下文菜单
    -   ToolTip：当鼠标悬停在控件上时显示的提示信息
    -   Cursor：当鼠标悬停在控件上时显示的鼠标光标类型

### 布局控件

-   Grid网格布局

    -   可以定义任意数量的行列

    -   行列大小可以使用绝对数值、自适应、相对比例

    -   行列可以设置跨行跨列，使用`RowSpan`或`ColumnSpan`附加属性

    -   可设置`Children`元素的对齐方向
    -   结合`GridSplitter`可实现拖拽分隔栏动态改变行高列宽

-   StackPanel栈式布局

    -   支持水平、垂直方向布局

    -   Orientation：设置布局方向

    -   HorizontalAlignment：设置子元素的水平对齐

    -   VerticalAlignment：设置子元素的垂直对齐

-   Canvas画布

    -   为子元素附加`X`、`Y`属性，支持子元素的绝对点定位

-   DockPanel停靠布局

    -   为子元素附加`Dock`属性，拥有`Left`、`Top`、`Right`、`Bottom`四个值，子元素会根据`Dock`属性停靠到对应的边界
    -   由于`LastChildFill`属性默认值为True，因此最后一个子元素会填满`DockPanel`中的剩余空间

-   WrapPanel流式布局

    -   与StackPanel类似，当子元素超过一行或一列时，会自动换行换列

## Binding

### 基本使用

Binding对象是实现数据和界面双向绑定的基础

在数据部分，数据源需要实现`INotifyPropertyChanged`接口，其中包含一个`PropertyChangedEventHandler`类型的`PropertyChanged`属性，该属性是一个事件，当数据源内的属性变化时，需要调用`PropertyChanged`来触发属性变化事件，从而能够通知到UI改变数据

数据源的基本实现如下

```c#
public class Student : INotifyPropertyChanged {

    public event PropertyChangedEventHandler? PropertyChanged;

    private string name = "";
    public string Name {
        get => name;
        set {
            name = value;
            // 当Name被修改时，触发事件
            // 注意这里传入Name属性而不是name字段，因为外部通过Name属性来访问name字段
            PropertyChanged?.Invoke(this, new("Name"));
        }
    }
}
```

编写一个简单布局，在后台类中通过C#代码的方式将`Student`类的`Name`属性绑定到文本框中

xaml布局如下

```xml
<StackPanel 
	Orientation="Vertical"
    VerticalAlignment="Center">
    <TextBlock
    	Width="250"
        Height="50"
        Margin="30, 0"
        x:Name="MyText"/>
    <Button
        Width="250"
        Height="50"
        Margin="30, 0"
        x:Name="Button"
        Content="Click Me"/>
</StackPanel>
```

后台类如下

```c#
public partial class MainWindow : Window {
    public MainWindow() {
        InitializeComponent();

        var student = new Student();
        // 数据源就是Student对象，路径Path就是属性的访问器，即Name属性
        var binding = new Binding() {
            Source = student,
            Path = new PropertyPath("Name")
        };

        // 将Student的Name属性绑定到TextBlock的Text属性上
        BindingOperations.SetBinding(MyText, TextBlock.TextProperty, binding);
        // 基于FrameworkElement的元素也就是基本元素对SetBinding进行了封装，也拥有SetBinding方法
        // MyText.SetBinding(TextBlock.TextProperty, binding);

        // 设置Click事件
        Button.Click += (_, _) => student.Name = "Hello";
    }
}
```

上述Binding对象的`Source`属性可以接收任何对象，若对象没有实现`INotifyPropertyChanged`接口，则无法向Binding通知自身的状态变化，`INotifyPropertyChanged`提供了对象向Binding通知自身变化的能力

### Binding流向

