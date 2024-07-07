---
layout: post
title: Python数据分析——Matplotlib
categories:
- Python
- 数据分析
tags:
- Matplotlib
- Python
- 数据分析
typora-root-url: ./
---

## matplotlib

### 基础

####mayplotlib图形组成

<img src="https://typora-images-1309988842.cos.ap-beijing.myqcloud.com/img/1519122294-2.gif" alt="Matplotlib图像组成" style="zoom:67%;" />

- Figure：指整个图形，您可以把它理解成一张画布，它包括了所有的元素，比如标题、轴线等；
- Axes：绘制 2D 图像的实际区域，也称为轴域区，或者绘图区；
- Axis：指坐标系中的垂直轴与水平轴，包含轴的长度大小(图中轴长为7)、轴标签指(x轴，y轴)和刻度标签
- Artist：您在画布上看到的所有元素都属于 Artist 对象，比如文本对象（title、xlabel、ylabel）、Line2D 对象（用于绘制2D图像）等。

#### pyplot接口

- 绘图类型

    | 函数名称  | 描述                                       |
    | --------- | ------------------------------------------ |
    | Bar       | 绘制条形图                                 |
    | Barh      | 绘制水平条形图                             |
    | Boxplot   | 绘制箱型图                                 |
    | Hist      | 绘制直方图                                 |
    | his2d     | 绘制2D直方图                               |
    | Pie       | 绘制饼状图                                 |
    | Plot      | 在坐标轴上画线或者标记                     |
    | Polar     | 绘制极坐标图                               |
    | Scatter   | 绘制x与y的散点图                           |
    | Stackplot | 绘制堆叠图                                 |
    | Stem      | 用来绘制二维离散数据绘制（又称为“火柴图”） |
    | Step      | 绘制阶梯图                                 |
    | Quiver    | 绘制一个二维按箭头                         |

- Image函数

    | 函数名称 | 描述                               |
    | -------- | ---------------------------------- |
    | Imread   | 从文件中读取图像的数据并形成数组。 |
    | Imsave   | 将数组另存为图像文件。             |
    | Imshow   | 在数轴区域内显示图像。             |

- Axis函数

    | 函数名称 | 描述                          |
    | -------- | ----------------------------- |
    | Axes     | 在画布(Figure)中添加轴        |
    | Text     | 向轴添加文本                  |
    | Title    | 设置当前轴的标题              |
    | Xlabel   | 设置x轴标签                   |
    | Xlim     | 获取或者设置x轴区间大小       |
    | Xscale   | 设置x轴缩放比例               |
    | Xticks   | 获取或设置x轴刻标和相应标签   |
    | Ylabel   | 设置y轴的标签                 |
    | Ylim     | 获取或设置y轴的区间大小       |
    | Yscale   | 设置y轴的缩放比例             |
    | Yticks   | 获取或设置y轴的刻标和相应标签 |

- Figure函数

    | 函数名称 | 描述             |
    | -------- | ---------------- |
    | Figtext  | 在画布上添加文本 |
    | Figure   | 创建一个新画布   |
    | Show     | 显示数字         |
    | Savefig  | 保存当前画布     |
    | Close    | 关闭画布窗口     |

#### 基本使用

```python
from matplotlib import pyplot as plt
import numpy as np
import math
#调用math.pi方法弧度转为角度
x = np.arange(0, math.pi*2, 0.05)
y = np.sin(x)
plt.plot(x,y)
plt.xlabel("angle")
plt.ylabel("sine")
plt.title('sine wave')
#使用show展示图像
plt.show()
```

导入包：`import matplotlib.pyplot as plt`，调用plot()传入x,y序列，绘制曲线图

### Figure对象

通过Figure对象可以设置画布的属性，还可以创建多个Figure对象来创建多个画布

```python
fg = plt.figure() #在创建新的figure对象之前，之后的社协属性代码均对该画布有效
```

基本参数

- figsize：设置画布的大小(宽高)，单位为英寸
- dpi：设置绘图的分辨率，每英寸多少个像素，默认为80
- facecolor：设置背景颜色
- edgecolor：设置边框颜色
- frameon：设置边框

Figure对象为最顶层的对象，其属性包含其他Artist对象

- axes：Axes对象列表
- patch：作为背景的Rectangle对象
- images：FigureImage对象列表，用于显示图像
- legends：Legend 对象列表，用于显示图示
- lines：Line2D对象列表
- patches：Patch对象列表
- texts：Text 对象列表，用于显示文字

#### 创建图像

通过figure对象调用add_axes()添加一个axes对象并返回该对象，设置其属性并调用plot()进行绘图

add_axes()参数需要传入一个4个数的列表，分别表示左，底，宽，高，每个数介于0到1之间

左底表示距左边和底边的距离，宽高表示图像的宽高

```python
fig.add_axes([0.25, 0.25, 0.5, 0.5]) # 图像居中显示且到四边距离为0.25
```

### Axes对象

Axes表示一个轴域，是画图的核心区域，一个Figure对象中可以包含多个Axes对象，但一个Axes对象只能在一个Figure对象中使用

2D图像，一个Axes对象包含两个Axis对象，3D图像，一个Axes对象包含三个Axis对象

#### 设置图例

调用legend(handles, labels, loc)

- handles：是一个包含所有要处理的线型的实例列表
- labels：是一个字符串列表，指定线型的标签，与handles中的线型一一对应
- loc：指定图例显示的位置，有11个预选项，有字符串表示和整数数字表示
    - 自适应：best,0
    - 右上方：upper right,1
    - 左上方：upper left,2
    - 左下方：lower left,3
    - 右下方：lower right,4
    - 右侧：right,5
    - 居中左侧：center left,6
    - 居中右侧：center right,7
    - 底部居中：lower center,8
    - 顶部居中：upper center,9
    - 居中：center,10

#### 绘制图像

调用plot()绘制曲线图，可以设置颜色，线型，标记，简写形式：颜色/标记/线型

颜色

- 蓝色：b
- 绿色：g
- 红色：r
- 青色：c
- 品红色：m
- 黄色：y
- 黑色：k
- 白色：w

线型

- 实线：-
- 虚线：--
- 点划线：-.
- 点线：:

标记

- 点标记：.
- 圆圈标记：o
- X标记：x
- 钻石标记：D
- 六角标记：H
- 正方形标记：s
- 加号标记：+
- 五角星标记：**

### 画布切分

#### subplot()

```python
plt.subplot(nrows, ncols, index) # plt.subplot(231)
```

该函数将一个画布均分为多个区域，nrows,ncols为行和列，index为选择第几个区域进行绘图，以左上为第一个

多次调用subplot()时，若子图之间有重叠，则包含重叠部分的子图会被最后一个子图替换，无论大小

保留所有子图，实现画中画

- 通过figure调用add_subplot(nrows,ncols,index)，会保留所有包含重叠部分的子图，重叠部分为最后一个子图
- 通过向画布中添加Axes对象，调用fig.add_axes()添加的Axes对象可以重叠

#### subplots()

```python
fig, ax = plt.subplots(nrows, ncols)
ax[0][0].plot(...) # 在第一行第一列绘制图像
```

函数返回一个figure对象和所有的Axes对象，通过二维下标可以获取到每个区域的Axes对象，设置属性并进行绘图

#### subplot2grid()

```python
plt.subplot2grid(shape, location, rowspan, colspan)
```

该函数将画布进行不均等切分，返回一个Axes对象对切分的区域进行画图

- shape：该参数传入一个元组，指定画布切分的行和列
- location：该参数传入一个元组，指定图像的位置(行列)
- rowspan/colspan：该参数指定图像跨越多少行多少列

### 设置图像元素

#### 设置网格样式

调用Axes对象的grid()可以开启网格和设置网格样式，默认情况下网格关闭，grid(True)开启不带样式的网格

- color：设置网格颜色
- ls：设置网格线型
- lw：设置网格线宽度

#### 设置坐标轴格式

调用Axes对象的xscale()/yscale()设置刻度的格式，如对数刻度等

默认的刻度格式为linear，常用可选有log(对数),symmetric log(对称对数),logit(逻辑回归)

##### Axes脊柱

脊柱指Axes四周的边界，包括刻度、标签，通过调用axes对象的spines属性，可以对每个脊柱设置样式

```python
ax.spines['left'].set_color('red')
ax.spines['top'].set_linewidth(2)
ax.spines['right'].set_color(None) # 颜色设置为None，脊柱为隐藏状态
```

##### 设置坐标轴范围

调用set_xlim()/set_ylim()设置坐标轴的取值范围，传入最小值和最大值

```python
ax.set_xlim(0, 50) # 设置x轴范围为0到50
```

##### 设置刻度和标签

- 自定义刻度

    调用axes对象的set_xticks(x_seq)/set_yticks(y_seq)设置刻度，xy序列为一个列表，刻度显示为列表中的值

- 自定义刻度标签

    调用axes对象的set_xticklabels(strings)/set_yticklabels(strings)设置刻度标签，与刻度一一对应，字符串使用为LaTeX格式

##### 添加双轴

调用axes对象的twinx()/twiny()添加另一图像的==y轴或x轴==，返回一个axes对象

```python
ax2 = ax1.twinx() # ax2有新添加的y轴，与ax1共享x轴
```

### 柱状图

调用axes对象的bar()来绘制柱状图

```python
ax.bar(x, height, width, bottom, align)
```

- x：表示柱状图x轴坐标的一个列表，x取值默认为柱状图的中点
- height：表示柱状图高度的一个列表
- align：表示x取值在柱状图的位置，可选center(中点),edge(左侧边缘)
- width：表示柱状图的宽度，可以传入一个值或与柱状图一一对应的列表
- bottom：表示柱状图底部的y坐标，默认为None，传入一个值或与柱状图一一对应的列表

#### 绘制多个柱状图

```python
import numpy as np
import matplotlib.pyplot as plt
#准备数据
data = [
    [30, 25, 50, 20],
    [40, 23, 51, 17],
    [35, 22, 45, 19]
]
X = np.arange(4)
fig = plt.figure()
#添加子图区域
ax = fig.add_axes([0.25,0.25,0.5,0.5])
#绘制柱状图
ax.bar(X - 0.25, data[0], color = 'b', width = 0.25)
ax.bar(X + 0.00, data[1], color = 'g', width = 0.25)
ax.bar(X + 0.25, data[2], color = 'r', width = 0.25)
plt.show()
```

以两个x刻度的距离为1个单位，通过以x刻度为中心向两侧加减n个单位来移动一系列柱状图

#### 绘制堆叠柱状图

```python
import numpy as np
import matplotlib.pyplot as plt

countries = ['USA', 'India', 'China', 'Russia', 'Germany'] 
bronzes = np.array([38, 17, 26, 19, 15]) 
silvers = np.array([37, 23, 18, 18, 10]) 
golds = np.array([46, 27, 26, 19, 17]) 
# 此处的 _ 下划线表示将循环取到的值放弃，只取下标[0,1,2,3,4]
ind = [x for x, _ in enumerate(countries)] 
#绘制堆叠图
plt.bar(ind, golds, width=0.5, label='golds', color='gold', bottom=silvers+bronzes) 
plt.bar(ind, silvers, width=0.5, label='silvers', color='silver', bottom=bronzes) 
plt.bar(ind, bronzes, width=0.5, label='bronzes', color='#CD853F') 
#设置坐标轴
plt.xticks(ind, countries) 
plt.ylabel("Medals") 
plt.xlabel("Countries") 
plt.legend(loc="upper right") 
plt.title("2019 Olympics Top Scorers")
plt.show()
```

设置bar()的bottom参数，将其设为其他柱状图的顶部，可实现堆叠柱状图

<img src="https://typora-images-1309988842.cos.ap-beijing.myqcloud.com/img/13221435b-2.gif" alt="柱状图堆叠图画法" style="zoom: 50%;" />

### 直方图

调用Axes对象的hist()来绘制直方图

```
ax.hist(x, bins, range, density, histtype)
```

- x：一个数字列表
- bins：可选，传入整数或列表，为区间的分隔值，默认为10个间隔
- range：指定间隔的上限和下限，传入一个元组(min, max)，默认为None
- density：若为True，返回概率密度直方图，否则，返回相应区间元素个数的直方图
- histtype：指定直方图的类型，默认为bar，可选barstacked(堆叠条形图)、step(未填充的阶梯图)、stepfilled(已填充的阶梯图)

### 饼状图

调用Axes对象的pie()绘制饼状图

```python
ax.pie(x, labels, color, autopct, explode, shadow)
```

- x：传入数据序列，饼状图显示每一项的占比

- labels：指定每一个数据的标签，与x序列一一对应

- color：指定每一块数据的背景颜色，与x序列一一对应

- autopct：设置占比数字的格式，传入一个格式字符串或一个格式函数

    格式字符串：%d、%.2f等，百分号需要转义(%%)

- explode：传入一个序列，指定哪一块突出显示，序列的值为离开中心的距离，一般为0.1

- shadow：设置是否显示阴影

### 散点图

调用Axes对象的scatter()绘制散点图

```python
ax.scatter(x, y, color, marker, label)
```

- x：散点的x坐标列表
- y：散点的y坐标列表
- color：设置散点的颜色
- marker：设置散点的标记
- label：设置散点系列的标签

### 等高线图

用于研究z=f(x,y)的函数值变化情况

```python
import numpy as np
import matplotlib.pyplot as plt
#创建xlist、ylist数组
xlist = np.linspace(-3.0, 3.0, 100)
ylist = np.linspace(-3.0, 3.0, 100)
#将上述数据变成网格数据形式
X, Y = np.meshgrid(xlist, ylist)
#定义Z与X,Y之间的关系
Z = np.sqrt(X**2 + Y**2)
fig,ax=plt.subplots(1,1)
#填充等高线颜色
cp = ax.contourf(X, Y, Z)
fig.colorbar(cp) # 给图像添加颜色柱
ax.set_title('Filled Contours Plot')
ax.set_xlabel('x (cm)')
ax.set_ylabel('y (cm)')
#画等高线
plt.contour(X,Y,Z)
plt.show()
```

<img src="https://typora-images-1309988842.cos.ap-beijing.myqcloud.com/img/1332514047-0.gif" alt="matplotlib画图" style="zoom: 67%;" />



- x序列和y序列必须按顺序排列，传入np.meshgrid()中生成网格数据
- 定义Z=f(X,Y)
- 调用ax.contourf()/ax.contour()，contourf是填充的，contour是未填充的
- contourf()/ocntour()返回颜色柱对象，调用fig.colorbar()添加颜色柱，颜色柱的颜色区域为Z的取值区间

### 箱型图

调用axes对象的boxplot(data)绘制箱型图

箱型图包含六个数据：最大值，最小值，上四分位数Q~3~，下四分位数Q~1~，中位数，异常值

<img src="https://typora-images-1309988842.cos.ap-beijing.myqcloud.com/img/14213911N-0.gif" alt="箱型图结构图" style="zoom: 80%;" />

> 四分位数：将数据升序排列，四等分数据，下四分位数是第25%的数字，上四分位数是第75%的数字
>
> 四分位距IQR：上四分位数-下四分位数
>
> 内限：在Q~3~+1.5IQR和Q~1~-IQR处的两条线段
>
> 外限：在Q~3~+3IQR和Q~1~-3IQR处的两条线段
>
> 处于内限和外限之间的值为异常值，外限之外的值为极端异常值

### 3D绘图

```python
from mpl_toolkits import mplot3d # 导入3D画图工具包
import numpy as np
import matplotlib.pyplot as plt
fig = plt.figure()
ax = plt.axes(projection="3d") # 创建3D画图区域
#从三个维度构建
z = np.linspace(0, 1, 100)
x = z * np.sin(20 * z)
y = z * np.cos(20 * z)
#调用 ax.plot3D创建三维线图
ax.plot3D(x, y, z)
ax.set_title('3D line plot')
plt.show()
```

plot3D(x,y,z)根据x，y，z的值来绘制线图

- 3D散点图

    调用ax.scatter3D(x, y, z)来绘制散点图

- 3D等高线图

    需要将x序列和y序列网格化，调用np.meshgrid()

    调用ax.contour3D(x, y, z, layer)绘制等高线图，layer为填充的层级数

    cmap参数可以设置颜色的风格

- 3D曲面图

    需要将x序列和y序列网格化，在调用ax.plot_surface(x, y, z)绘制曲面图

    cmap参数设置颜色的风格

### 文本绘制

通过以下方法可以绘制不同区域的文本

- xlabel：在x轴上添加标签

- ylabel：在y轴上添加标签

- title：在Axes对象内添加标题

- figtext：在figure对象的任意位置添加文本

- suptitle：在figure对象中添加标题

- text：在Axes对象的任意位置绘制文本

    ```python
    ax.text(x,y,string,fontldict)
    ```

    x、y为内容的坐标，string为字符串，支持LaTeX，fontdict为一个设置字体格式的字典

    - fontsize：字体大小
    - color：字体颜色，支持RGB/RGBA(使用元组传入)
    - alpha：字体透明度
    - backgroundcolor：背景颜色
    - ha：水平对齐方式，可选left,right,center
    - va：垂直对齐方式，可选top,bottom,center,baseline

- annotate：在Axes对象的任意位置绘制带箭头的注释

    ```python
    ax.annotate(string, xy, xytext, textcoords, weight, color, arrowprops, bbox)
    ```

    - string：文本内容，支持LaTeX

    - xy：注释点坐标，使用元组传入

    - xytext：内容坐标

    - textcoords：注释点坐标系统，默认为data

    - weight：设置字体线型

    - color：设置字体颜色

    - bbox：设置背景样式

        - boxstyle：方框外形
        - facecolor：(简写fc)背景颜色
        - edgecolor：(简写ec)边框线条颜色
        - edgewidth：边框线条大小

    - arrowprops：设置箭头的样式，使用字典传入

        - facecolor：箭头颜色

        - width：箭头宽度

        - headlength：箭头长度

        - arrowstyle：设置箭头样式

            <img src="https://typora-images-1309988842.cos.ap-beijing.myqcloud.com/img/v2-789b8b675fc1a3df7f747baec688e574_1440w.jpg" alt="img" style="zoom: 80%;" />

