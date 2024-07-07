---
layout: post
title: Android基础——UI控件
categories:
- Android
tags:
- Android
typora-root-url: ./
date: 2024-04-16 13:57 +0800
image:
  path: /assets/img/android/android.jpg
---
## 开始

Android中的组件都是由View和ViewGroup组成，是一个树形结构，View就代表了一个界面控件，ViewGroup是存放多个View对象的布局容器

## 布局

### LinearLayout线性布局

表示一个横向或纵向的布局

- `orientation`:设置布局的排列方式，有horizontal(水平)、vertical(垂直，默认)两种方式

- `gravity`:控制子元素中内容对齐方式，可多种组合(left|bottom)

- `layout_gravity`:控制组件的显示内容在父容器中的对齐方式

    线性布局中以排列方向上最大的组件的**内容**位置决定对齐标准

    线性布局水平排列，button2最大，layout_gravity=bottom，则该组件的**内容**所在的位置为bottom，button3随之与button2的内容平行

- `layout_width`:通常用wrap_content(匹配内容)，match_parent(填满父容器)

- layout_height

- `id`:为组件设置一个资源ID

- `background`:设置组件的背景或背景颜色

- `weight`:用于等比例划分区域，该属性设置后排列方向上的长度/宽度设置为0dp

    在多个组件中设置该属性，使得设置的组件按比例设置大小，比例为weight值在所有组件的weight值之和的占比

    需要一个组件的大小依据另一组件的大小而定时，将该组件的大小设为0，weight设为1，该组件会依据另一组件的大小占满剩余的屏幕

- divider分割线

    - `divider`:设置分割线的图片
    - `showDividers`:设置分割线所在位置，可选none,middle,beginning,end
    - `dividerPadding`:设置分割线的padding

### RelativeLayout相对布局

表示一个控件相对于其他控件设置位置的布局

- `gravity`:设置容器内组件内容的对齐方式

- `IgnoreGravity`：设置该属性为true的组件不受gravity属性的影响

- 根据父容器定位

    - `layout_centerHrizontal`:水平居中
    - `layout_centerVertical`:垂直居中
    - `layout_centerInparent`:相对于父元素完全居中
    - `layout_alignParentLeft`:左对齐
    - `layout_alignParentRight`:右对齐
    - `layout_alignParentTop`:顶部对齐
    - `layout_alignParentBottom`:底部对齐

    ![img](./assets/44967125.jpg)

- 根据兄弟组件(处于同一布局的组件)定位，指定组件ID来定位

    - `layout_toLeftOf`：参考组件的内容
    - `layout_toRightOf`
    - `layout_above`
    - `layout_below`
    - `layout_alignTop`:参考组件的上边界
    - `layout_alignBottom`:参考组件的下边界
    - `layout_alignLeft`:同上
    - `layout_alignRight`:同上

### FrameLayout帧布局

所有控件默认摆放在左上角，控件之间可覆盖，通过`layout_gravity`设置在布局中的对齐方式

## UI控件

### TextView

表示一个简单文本

常用属性

- `id`
- `layout_width`
- `layout_height`
- `gravity`:设置控件中文字的对齐方向
- `text`:设置文本显示的内容，一般将字符串写到string.xml中
- `textColor`:设置文本的颜色，一般将颜色写到colors.xml中
- `textStyle`:设置文字的风格，可选normal,bold,italic
- `textSize`:设置字体大小，单位使用sp
- `background`:设置控件的背景

设置字体阴影

- `shadowColor`:设置阴影颜色，需要与shadowRadius配合使用
- `shadowRadius`:设置阴影的模糊程度，通常为3.0
- `shadowDx`:设置阴影水平方向的偏移
- `shadowDy`:设置阴影竖直方向的偏移

#### 带边框的TextView

需要编写一个shapeDrawable，将TextView的background属性设置为该shapeDrawable资源

shapeDrawable资源的节点及属性

- `<solid android:color = "xxx">` 这个是设置背景颜色的
- `<stroke android:width = "xdp" android:color="xxx">` 这个是设置边框的粗细,以及边框颜色的
- `<padding androidLbottom = "xdp"...>` 这个是设置边距的
- `<corners android:topLeftRadius="10px"...>` 这个是设置圆角的
- `<gradient>` 这个是设置渐变色的,可选属性有
    - `startColor`:起始颜色
    - `endColor`:结束颜色
    - `centerColor`:中间颜色
    - `angle`:方向角度,等于0时,从左到右,然后逆时针方向转,当angle = 90度时从下往上
    - `type`:设置渐变的类型

#### 带图片的TextView

在文字的上下左右添加图片，传入drawable资源ID

- `drawableLeft`
- `drawableRight`
- `drawableBottom`
- `drawableTop`

若需要改变图片大小，在java代码中修改

autoLink链接：当文字是一个链接或一段电话号码，可使文字链接到对应网址或应用

### EditView

表示一个文本编辑框

-   设置默认提示文本

    -   `hint`:默认提示文本

    - `textColorHint`:提示文本颜色

-   获得焦点后全选组件内的文本

    - `selectAllOnFocus`

-   限制EditText输入类型：inputType

    -   文本：text,textUri,textPassword,textVisiblePassword,textMultiLine,textEmailAddress
    -   数值：number,phone,date,time, datetime,numberSigned

-   限制输入行数：默认为多行显示，能够自动换行

    - `minLines`:设置最小行数

    - `maxLines`:设置最大行数，超过最大行数时会自动向上滚动

    - `singleLine`:只允许单行输入，且不能滚动

-   设置文字间隔，设置英文字母大写类型

    - `textScaleX`:设置水平间隔

    - `textScaleY`:设置数之间各竖直间隔

    - `capitalize`:设置英文字母大写类型
        - `sentences`:第一个字母大写
        - `words`:每个单词首字母大写，用空格分隔
        - `characters`:每个字母都大写

-   获取输入文本：`editText.getText().toString()`

    获取的值不会为null，但可能为空字符串

### StateListDrawable

StateListDrawable可根据不同的状态设置不同的图片效果，根节点为`<selector>`

- `drawable`:引用的Drawable位图,我们可以把他放到最前面,就表示组件的正常状态~
- `state_focused`:是否获得焦点
- `state_window_focused`:是否获得窗口焦点
- `state_enabled`:控件是否可用
- `state_checkable`:控件可否被勾选,eg:checkbox
- `state_checked`:控件是否被勾选
- `state_selected`:控件是否被选择,针对有滚轮的情况
- `state_pressed`:控件是否被按下
- `state_active`:控件是否处于活动状态,eg:slidingTab
- `state_single`:控件包含多个子控件时,确定是否只显示一个子控件
- `state_first`:控件包含多个子控件时,确定第一个子控件是否处于显示状态
- `state_middle`:控件包含多个子控件时,确定中间一个子控件是否处于显示状态
- `state_last`:控件包含多个子控件时,确定最后一个子控件是否处于显示状态

### Button

表示一个按钮

继承了TextView，属性基本同TextView，text属性的文字会默认转换为大写，可设置`textAllCaps=false`取消

注册监听器：调用`button.setOnClickListener()`，传入一个lambda表达式

### ImageView

表示一张图片，src指定drawable中的图片资源，图片一般放在xxhdpi分辨率下

在代码中可以动态的更改图片，调用`imageView.setImageResource(R.drawable.pic)`

### ProgressBar

用于显示一个进度条，表示程序正在加载数据

-   style属性设置进度条的样式

    水平进度条：`style="?android:attr/progressBarStyleHorizontal"`

-   max属性设置进度条最大值

    在代码中`progressBar.progress`属性可动态设置进度条进度

>   通过visibility属性设置控件可见或不可见，可选visible,invisible,gone
>
>   visible和invisible表示控件可见或不可见，控件还占据原来的位置，gone表示控件消失，不占据空间，Android控件均有这一属性
>
>   在代码中调用控件的`setVisibility()`可动态控制控件的可见状态，`getVisibility()`返回控件可见状态
{: .prompt-tip }

### AlertDialog

在当前界面弹出一个提示框，能够屏蔽所有控件，置顶于所有界面元素之上

- 对话框类型为AlertDialog，创建对象类型为`AlertDialog.Builder`
- 创建`AlertDialog.Builder`对象
- 调用`setIcon()`设置图标，`setTitle()`或`setCustomTitle()`设置标题
- 设置对话框的内容：`setMessage()`还有其他方法来指定显示的内容
- 调用setPositive/Negative/NeutralButton()设置：确定，取消，中立按钮
- 调用`create()`方法创建这个对象，再调用`show()`方法将对话框显示出来

[2.5.9 AlertDialog(对话框)详解 | 菜鸟教程 (runoob.com)](https://www.runoob.com/w3cnote/android-tutorial-alertdialog.html)

### 自定义控件

#### 引入布局

编写一个自定义的局部布局，如标题栏布局，在主布局中使用include标签引入

```xml
<include layout="@layout/title"/>
```

#### 自定义控件

为布局中的控件注册事件，使其封装为一个控件

- 新建布局类，继承小布局使用的布局(线性布局等)

- 类中构造器传入`Context`和`AttributeSet`两个参数，动态加载布局类

    ```java
    public class TitleLayout extends LinearLayout {
        public TitleLayout(Context context, @Nullable AttributeSet attrs) {
            super(context, attrs);
            // inflate()的第一个参数为要加载的布局文件id，第二个参数为加载的布局添加一个父布局
            LayoutInflater.from(context).inflate(R.layout.title,TitleLayout.this);
        }
    }
    ```
    
- 为布局中的控件注册事件

### ListView

允许用户上下滑动浏览列表

将data传入ListView：使用适配器(常用ArrayAdapter)，构造一个适配器，指定泛型，传入Activity实例，ListView子项的布局id和数据源data，最后将ListView控件的适配器设置为构造的适配器

#### 自定义ListView子项

自定义ListView子项的界面

- 编写子项的实体类存储显示的信息

- 编写子项布局

- 自定义实例类的适配器，继承`ArrayAdapter`，指定泛型

    适配器的构造器传入Activity的实例，ListView子项布局id和数据源

- 重写`getView()`，该方法在子项被滚动到屏幕中时调用

    - getView方法中使用`LayoutInflator`动态加载布局，设置inflate第三个参数为false，表示只让父布局的layout属性生效，而不添加父布局，通过调用`getItem(position)`获取当前项的Fruit实例，`findViewById`获取控件，设置当前子项的显示内容

    - `convertView`参数用于将加载好的布局进行缓存，在上下滚动时可以重用

        判断`convertView`是否为空，为空则动态加载，不为空令`view=convertView`

    - `ViewHolder`可用于对获取控件进行优化

        在Adapter类中定义一个ViewHolder内部类，类中存储布局中的控件，构造ViewHolder类对象，对加载的控件进行缓存，传入构造器中，再调用view的`setTag()`将ViewHolder存储在view中，convertView不为空时，调用`getTag()`获取ViewHolder对象

#### 点击事件

调用`listView.setOnItemClickListener()`注册监听器，传入parent，view，position，通过position获取子项的实例

### RecyclerView

RecyclerView为新增库，用于表示一个列表，可以替代ListView，在老版本Android运行需要在build.gradle添加RecyclerView的依赖

-   自定义适配器使用RecyclerView，继承`RecyclerView.Adapter`，指定泛型为class.ViewHolder，class为自定义的适配器类，重写其中的方法，ViewHolder内部类需要继承`RecyclerView.ViewHolder`
    -   重写的方法
        -   `onCreateViewHolder()`：用于创建ViewHolder实例，加载子项布局（**子项的布局高度需要调整为自适应**），将布局传入构造器中，返回ViewHolder实例
        -   `onBindViewHolder()`：用于对RecyclerView子项赋值

        -   `getItemCount()`：返回数据源长度
-   在`onCreate()`中构造一个布局管理器对象(线性布局LinearLayoutManager)，传入RecyclerView的`setLayoutManager()`中

#### onBindViewHolder中position不准的问题

调用notifyItemXXX方法时不会调用`onBindViewHolder`重新绑定，因此修改后每个holder的position不会改变

例：数据项0,1,2对应列表项0,1,2

数据索引：[0]0,[1]1,[2]2
列表索引：[0]0,[1]1,[2]2
修改后
数据索引：[0]1,[1]2
列表索引：[1]1,[2]2
点击1时，position依然是1，数据中下标1的数据是2，数据与列表不对应

调用`holder.getAbsoluteAdapterPosition`获取绝对位置

#### 横向滚动和瀑布流布局

-   横向滚动
    -   修改子项布局的排列方式为vertical，固定宽度，设置控件的对齐方式
    -   设置`LinearLayoutManager`对象的`orientation`为`HORIZONTAL`
-   瀑布流布局
    -   RecyclerView内置`GridLayoutManager`网格布局和`StaggeredGridLayoutManager`瀑布流布局
    -   构造`StaggeredGridLayoutManager`对象，传入显示的列数和排列方向
    -   子项布局的宽度根据列数自动适配，设为`match_parent`即可

#### 点击事件

需要为每个子项View注册点击事件

在适配器的`onCreateViewHolder`()中使用ViewHolder可以为最外层布局(itemView)或者布局内控件注册事件

调用`getAdapterPosition()`获取position，进而获取对象

### 9-patch图片

9-patch图片可以指定那些区域可以被拉伸，哪些区域填充内容

在Android Studio中可以从.png图片创建.9.png图片，创建后将原图片删除或重命名，在边框填充小黑点指定区域

左边框和上边框的黑点区域表示拉伸的区域，右边框和下边框的黑点区域表示内容允许放置的位置

