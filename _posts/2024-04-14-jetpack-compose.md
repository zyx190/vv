---
layout: post
title: Jetpack Compose基础指南
categories:
- Android
tags:
- Android
- Jetpack Compose
typora-root-url: ./..
image:
  path: "/assets/img/jetpack-compose/jetpack_compose.png"
date: 2024-04-14 15:12 +0800
---
## 开始

Compose设计原则

-   一切组件都是函数

    Compose组件通过可组合函数表示，使用Composable注解标识函数

-   组合优于继承

    所有组件之间没有继承关系，Composable函数可以任意嵌套，而不会损失性能

-   单一数据源

    所有组件只能通过一个参数来改变状态，当组件的状态需要改变时，只能通过该参数来改变

    视图树一旦生成不可改变，当视图树中的参数改变时，整个视图树基于新数据刷新，称为重组

    单一数据源决定了数据流的的单向流动，数据总是自上而下流动，事件总是自下而上传递

    <img src="/assets/img/jetpack-compose/udf-hello-screen.png" alt="img" style="zoom: 33%;" />

Compose与View的关系：Compose树中的视图节点是LayoutNode，Compose树可以通过一个挂载点挂载到View树中，挂载点通过AbstractComposeView实现，AbstractComposeView有三个子类，分别用于适配Activity、Dialog和PopupWindow，它的子节点AndroidComposeView持有Compose树，同时它也是一个ViewGroup，实现了Compose树和View树的连接

## UI组件

Compose提供了基本UI组件以及Row、Column、Box三种布局，父组件默认适应子组件大小

### Modifier

#### 基本Modifier

每个组件都有一个modifier参数，可以传入一个Modifier对象，Modifier对象可以设置组件的基本样式，如边距、大小、背景等

-   size：设置组件大小，可分别设置width和height参数，也可调用width和height函数分别设置

-   background：设置组件背景颜色、形状，通过Color对象设置纯色，通过Brush对象设置渐变色

-   fillMaxSize：使组件充满父组件

    -   fillMaxWidth
    -   fillMaxHeight

-   border：设置组件边框，可设置粗细、颜色等

-   padding：设置组件的边距，在Compose中没有margin，通过background和padding共同作用实现内边距和外边距，在background之前的padding为外边距，background之后的padding为内边距，当没有background时，padding默认为外边距

    >   background和padding需要设置在width、height相关设置之前
    {: .prompt-info }

-   offset：设置组件的偏移量，需要注意该函数的调用顺序

Modifier中包含了许多关于手势的修饰符

-   clickable：使组件变为可点击，也可通过状态控制enable参数
-   CombinedClickable：复合点击，可设置单击、长按、双击等
-   Draggable：拖动，可对水平和垂直方向的拖动偏移进行监听
-   Swipeable：滑动，需要设置锚点，可对水平和垂直方向的拖动偏移进行监听
-   Scrollable：滚动，支持水平和垂直滚动，需要scrollState参数，使用rememberScrollState创建
-   NestedScroll：嵌套滚动，需要NestedScrollConnection参数，其中包含父组件使用子组件的滚动事件回调

#### 作用域Modifier

使用作用域Modifier可以使得modifier函数被安全调用，减少不必要的调用

Compose中的作用域不允许跨层调用，若需要跨层调用，需要显示指明Receiver

-   BoxScope
    -   matchParentSize：使内部组件与Box大小相同
-   RowScope、ColumnScope
    -   weight：通过百分比设置内部组件大小

#### Modifier原理

Modifier是一个接口，每个修饰符函数实现了`Modifier.Element`接口，Modifier包含一个伴生对象，在起始位置通过Modifier伴生对象调用第一个修饰符函数后，会创建相应修饰符的Modifier实例对象，修饰符函数之间通过then函数连接，Modifier对象在其中传递

then函数返回一个CombinedModifier

``` kotlin
class CombinedModifier(
	private val outer: Modifier,
    private val inner: Modifier
) : Modifier
```

outer指向当前修饰符的前一个Modifier对象，inner指向当前修饰符的Modifier对象

<img src="/assets/img/jetpack-compose/image-20230716132120185.png" alt="image-20230716132120185" style="zoom:50%;" />

Compose在绘制UI时，会遍历Modifier链，使用foldIn和foldOut函数进行遍历

foldIn进行正向遍历，foldOut进行反向遍历

``` kotlin
fun <R> foldIn(initial: R, operation: (R, Element) -> R): R
fun <R> foldOut(initial: R, operation: (Element, R) -> R): R
```

### 基本UI组件

#### 文本组件

-   Text：基于Material Design规范设计，使用BasicText则脱离Material Design规范

    <img src="/assets/img/jetpack-compose/image-20230716133340445.png" alt="image-20230716133340445"  />

    >   关于资源：Compose提供了获取不同类型资源的函数
    >
    >   -   stringResource：获取文本资源
    >   -   colorResource：获取颜色资源
    >   -   integerResource：通过资源id获取
    >   -   painterResource：获取Drawable资源
    {: .prompt-info }

-   TextStyle：文字样式，使用TextStyle构造器构造，传入相应样式属性

    若重复设置Text与TextStyle，则Text属性会覆盖TextStyle属性

-   AnnotatedString：多样式文字

    使用buildAnnotatedString函数构造AnnotatedString

    其中可调用withStyle函数传入一个SpanStyle对象或ParagraphStyle对象和子串DSL，SpanStyle表示子串的样式，ParagraphStyle表示段落样式，子串DSL中调用append添加子串文本

-   SelectionContainer：使组件可被选中

-   TextField：输入框，BasicTextField不使用Material Design规范

    BasicTextField比TextField多一个decorationBox属性，通过该属性可设置更多样式

    两种风格：filled(无边框填充)，Outlined(有边框无填充)

    <img src="/assets/img/jetpack-compose/image-20230716224029629.png" alt="image-20230716224029629"  />
    

#### 图像组件

-   Icon：图标组件，支持矢量图对象、位图对象和Canvas画笔对象，矢量图通过ImageVector加载，位图通过ImageBitmap加载

    Icons包预置了一些图标，它们拥有5种风格：Outlined、Filled、Rounded、Sharp、Two Tone

    更多图标`implementation("androidx.compose.material:material-icons-extended:$compose_version")`

-   Image：图像组件，contentScale参数指定图片的伸缩样式，类似ScaleType

#### 点击组件

-   Button：按钮，Button只是响应点击的容器，content参数传入ComposableDSL，使用其他组件填充内容，作用域为RowScope

    interactionSource参数传入一个MutableInteractionSource状态

    -   collectPressedAsState：判断是否是按下状态
    -   collectFocusedAsState：判断是否获取焦点
    -   collectDraggedAsState：判断是否拖动

    调用以上函数可获取对应的状态对象，其value属性为判断的boolean值

    其他组件可通过调用`Modifier.clickable`变为可点击组件，响应事件

-   IconButton：一个图标按钮，内部需要提供Icon组件

-   FloatingActionButton：悬浮按钮，内部提供Icon组件

-   ExtendedFloatingActionButton：可带文字的悬浮按钮

#### 选择组件

-   CheckBox：复选框
-   TriStateCheckBox：三态选择框
-   Switch：单选框
-   Slider：滑竿组件

#### 对话框

-   Dialog：传入三个属性，onDismissRequest(关闭回调)、DialogProperties(设置其他特殊属性)、content(CompossableDSL)，对话框的显示和隐藏通过设置状态实现，当状态为true则渲染Dialog
-   AlertDialog：基于Dialog封装，添加了title、text、confirmButton、dismissButton

### 布局组件

#### 基本布局

Compose只有三种布局，Row、Column、Box

对齐：verticalArrangement、horizontalAlignment，只有在设置了Column的大小时才能使用对齐

子组件对齐：布局内的组件可以通过`Modifier.align`设置自己的对齐，Column中只能设置子组件水平对齐，Row中只能设置子组件垂直对齐

<img src="/assets/img/jetpack-compose/eaf39ee39ad84a1ebf47acfe8e58cd01.gif" alt="在这里插入图片描述"  />

-   Column：垂直线性布局
-   Row：水平线性布局

#### 帧布局

-   Box：子组件可堆叠，类似FrameLayout
-   Surface：一个组件容器，可设置边框、圆角、颜色等，当需要设置布局总体样式时，可使用Surface
-   Spacer：空白，在布局中占位
-   ConstraintLayout

#### Scaffold脚手架

Scaffold组件实现了一个基于Material Design的基本UI布局

包含多个特定位置参数和content，设置组件，组件自动位于相应的位置，content为ComposableDSL

-   topBar
-   bottomBar
-   drawerContent

Scaffold拥有一个状态，包含了特定位置组件的相关状态，如侧边栏是否打开等，通过rememberScaffoldState()获取变量，设置到Scaffold的scaffoldState参数

>   BackHandler：监听返回键组件，设置enable参数和onBack回调
{: .prompt-tip }

### 列表

调用`Modifier.horizontalScroll()`或`Modifier.verticalScroll()`可以实现滚动，但对于长列表，不需要将全部数据加载到内存中，可以使用LazyRow或LazyColumn组件实现列表

LazyComposables内是LazyListScope作用域，调用item或items函数创建一个子项，这两个函数需要传入子项的ComposableDSL

items还可接收List参数，调用itemsIndexed可同时获取索引

-   contentPadding：设置子项**内容**外边距
-   verticalArrangement=Arrangement.spacedBy：设置子项布局外边距

## 主题

### 基本主题

项目的`ui/theme`目录下存放项目主题配置

-   Color.kt：颜色配置
-   Shape.kt：形状配置
-   Theme.kt：主题配置
-   Type.kt：字体配置

Material Design颜色字段

<img src="/assets/img/jetpack-compose/image-20230718163646166.png" alt="image-20230718163646166"  />

### CompositionLocal

CompositionLocal用于在视图树中共享数据，CompositionLocal可被定义在任何一棵子树中，数据在该子树中共享，若子树的子树重新定义CompositionLocal，则会覆盖原定义

创建CompositionLocal

-   compositionLocalOf

    若提供给CompositionLocal的值是一个状态，当状态发生变化时，CompositionLocal子树中读取了`CompositionLocal.current`值的Composable层级会发生重组

-   staticCompositionLocalOf

    若提供给CompositionLocal的值是一个状态，当状态发生变化时，整个CompositionLocal子树发生重组

CompositionLocalProvider方法可以为compositionLocal提供一个值，该值在当前子树内覆盖compositionLocal的原值

``` kotlin
val localString = staticCompositionLocalOf { "Hello in level1" }
Column {
    Text(localString.current)  // Hello in level1
    CompositionLocalProvider(
    	localString provides "Hello in level2"
    ) {
        Text(localString.current)  // Hello in level2
    }
}
```

## 状态管理

Compose通过重组来进行UI刷新

-   Stateless：一个Composable中不包含自己的状态，所有状态通过函数参数传递
-   Stateful：一个Composable中包含自己的状态，也包含函数参数传递的状态

### 状态定义

-   State：不可变状态
-   MutableState：可变状态

创建MutableState

``` kotlin
val state: MutableState<Int> = mutableStateOf(0)  // 调用value属性进行读写
val (state, setter) = mutableStateOf(0)  // state为属性值，调用setter设置属性值
val state by mutableStateOf(0)  // 属性代理
```

状态缓存：使用`remember { state }`，在Composable中记录状态

### 状态提升

将Stateful改造为Stateless，将Composable内部数据通过函数参数传入，将响应事件也作为函数对象参数传入

状态提升的作用域最好提升到使用的Composable的最小共同父Composable

### 状态持久化

remember无法实现在Activity等重建或跨进程中缓存状态，需要使用rememberSavable，rememberSavable仅支持Bundle中的数据类型，对于类，需要添加`@Parcelize`注解，实现Parcelable接口

>   使用`@Parcelize`注解需要添加gradle插件`kotlin-parcelize`，`@Parcelize`自动添加了一套Parcelable接口的实现
{: .prompt-tip }

对于需要自定义序列化时，可定义Saver实现序列化和反序列化，在调用rememberSavable时传入自定义Saver

自定义Saver实现Saver接口

``` kotlin
object PersonSaver : Saver<Person, Bundle> {
    override fun restore(value: Bundle): Person? {
        // ...
    }
    override fun SaverScope.save(value: Person): Bundle? {
        // ...
    }
}
```

Compose提供了MapSaver和ListSaver

-   MapSaver：将对象转换为`Map<String, Any>`
-   ListSaver：将对象转换为`List<Any>`

>   若只需要状态可以在因配置改变导致Activity等重建时保存，只需要在AndroidManifest.xml中设置android:configChanges，使用remember即可
{: .prompt-tip }

### 状态管理

有三种方式可以管理状态

#### Stateful

使用一个Stateful Composable统一存储Stateless的状态，适用于简单的UI逻辑

#### StateHolder

定义一个StateHolder类统一管理Stateless状态，定义相应的remember函数，在Composable中通过remember函数获取StateHolder，适用于复杂的UI逻辑

#### ViewModel

将Stateless的状态放到ViewModel中进行管理，在Composable中可直接调用viewModel()获取，该函数从最近的ViewModelStore中获取ViewModel实例

ViewModel方式可以支持Hilt依赖注入，适用于长期的业务逻辑

>   viewModel函数需要添加依赖
>
>   `androidx.lifecycle:lifecycle-viewmodel-compose:$lifecycle_version`
{: .prompt-tip }

#### 状态分层策略

<img src="/assets/img/jetpack-compose/image-20230719153741757.png" alt="image-20230719153741757"  />

### 状态重组

-   只有状态发生更新的Composable才发生重组

-   Composable会以任意顺序执行

    根据各个组件的渲染顺序执行而不是代码的顺序

-   Composable是并发执行的

    Composable之间使用同一个变量时，会产生线程安全问题

-   Composable的执行是不可预期的

    除了重组造成Composable的执行外，动画中每一帧的变化也会引起Composable的执行，因此Composable的执行次数是不可预期的，应该避免在Composable中执行耗时操作或数据操作

-   Composable的执行是乐观的

    Composable总是使用最新的状态完成重组，可能会丢弃中间状态

#### 重组原理

-   经过Compose编译器处理后的Composable代码在对State进行读取的同时，能够自动建立关联，在运行过程中当State变化时，Compose会找到关联的代码块标记为Invalid

-   在下一渲染帧到来之前，Compose会触发重组并执行invalid代码块，Invalid代码块即下一次重组的范围，能够被标记为Invalid的代码必须是非inline且无返回值的Composable函数或lambda

    -   inline函数会在调用处展开，会与调用方共享重组范围

        Column是inline的高阶函数，因此Column内部组件会在Column中展开，Column内部组件重组时，Column也处于重组范围内，也会发生重组
        
        若是其他非inline的Composable函数，内部组件重组时，外部不处于重组范围内

    -   由于返回值的变化会影响调用方，所以必须连同调用方一同参与重组，因此Composable函数不应该有返回值

#### 列表重组

Compose视图树中每个节点(LayoutNode)都具有一个索引，当发生重组时，根据索引在SlotTable中查找，若节点不存在则创建节点，节点存在则更新等

**节点的比较依赖于编译期建立的索引，在运行时进行比较会发生错误**，编译期索引由代码编写的位置决定

对于列表数据，其数据项在运行时确定，无法在编译时确定数据项，因此需要为每个数据项手动建立索引

若不手动建立索引，当在list[0]添加数据时，新数据会与[0]上的原数据进行比较，从而导致整个列表进行节点更新，手动建立索引后，重组时只会对新数据创建节点

``` kotlin
Column {
    for (e in list) {
        key(e.id) {
            MovieItem(e)
        }
    }
}
```

### Composition生命周期

Compose视图树称为Composition

生命周期

-   onActive：Composable首次执行，创建Composition
-   onUpdate：Composable由于重组不断执行，更新Composition节点
-   onDispose：Composable不再执行，Composition节点销毁

### Composable副作用

Composable中影响外界的操作称为副作用，Compose提供了一系列副作用API，保证这些操作在特定的阶段执行

-   DisposableEffect：可以感知Composable的onActive和onDispose

    ``` kotlin
    DisposableEffect(key) {
        // 当key改变(onUpdate)或onActive时执行这部分代码
        // 当key为常量时，只在onActive执行一次
        onDispose {
            // 当Composable进入onDispose时执行
        }
    }
    ```

-   SideEffect：在每次重组**成功**时执行

-   LaunchedEffect：在副作用中执行异步操作

    当Composable进行onActive时，LaunchedEffect中开启一个协程，同时也可以为该副作用指定key，当key改变时，原协程结束，新协程开启，Composable进入onDiapose时，协程自动结束

    rememberCoroutineScope：获取一个与Composable同生命周期的协程作用域

-   rememberUpdatedState

    每次状态改变会发生重组，导致副作用也进行重组，如LaunchedEffect会开启一个新协程

    若副作用的重组开销大，则应该使副作用在多次重组之间持续存在，当副作用内部引用了Composable中保存的状态时(状态使用remember保存)，状态改变只会使得Composable重组，但同时副作用内部无法获取状态的最新值，即无法使副作用内部响应

    此时应该使用rememberUpdatedState来保存状态，当状态改变时，Composable重组，同时通知副作用内部

-   snapshotFlow：在副作用内部使用FLow处理State，同时使持续存在的副作用内部可以实时感知State的变化


>   Best Practice：当副作用依赖的状态频繁变化时，应该使用状态对象本身作为副作用的Key，而在副作用内部使用snapshotFlow感知状态值的变化
{: .prompt-tip }
