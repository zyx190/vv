---
layout: post
title: Python数据分析——Pandas
categories:
- Python
- 数据分析
tags:
- Pandas
- Python
- 数据分析
typora-root-url: ./
---

## Series

Series是一维数据结构，能够存储各种数据类型

### 创建

调用`pd.Series()`构造Series对象

```python
s = pd.Series(data, index, dtype, copy)
```

- data：输入的数据，传入一个序列，可以是列表、元组或ndarray
- index：传入索引列表，与数据个数一一对应，若没有对应元素，则填充NaN
- dtype：指定数据类型
- copy：指定是否返回视图，默认为False

`data`参数也可以传入一个标量，默认存储一个值，当设置了`index`时，会根据`index`的长度复制标量值

```python
s = pd.Series(5, index=range(5))
'''
0,5
1,5
2,5
3,5
4,5
'''
```

Series可以看做一个定长的字典，可直接使用字典创建一个Series

```python
data = {'a' : 0, 'b' : 1, 'c' : 2}
s = pd.Series(data)
# 支持字典查找
'a' in s  # True
```

### 索引

Series通过标签来索引，也支持numpy的索引方式

```python
# 自动生成数字标签，通过数字标签索引
s = pd.Series(['a', 'b', 'c', 'd', 'e', 'f', 'g'])
s[2]  # 一般索引
s[2:5:2]  # 区间索引
s[[1, 3, 5]]  # 数组索引
s[s > 'b']  # 布尔索引
```

若Series设置了自定义标签，则使用自定义标签索引

```python
# 自定义标签
s = pd.Series(range(7), index=['a', 'b', 'c', 'd', 'e', 'f', 'g'])
s['b']  # 一般索引
s['b':'f':2]  # 区间索引，步长必须为int值
s[['b', 'd', 'f']]  # 数组索引
s[s > 2]  # 布尔索引
```

使用Series中的`loc`属性和`iloc`属性进行索引，两个属性都是索引对象，通过`[]`访问

-   `loc[]`：标签索引，与`s[]`索引相同
-   `iloc[]`：位置下标索引

>   注意，自动生成的数字标签不应理解成数组中的下标，会导致`loc`和`iloc`的理解混乱
{: .prompt-info }

### 常用属性

| 属性     | 描述                            |
| -------- | ------------------------------- |
| `axes`   | 返回索引对象列表                |
| `dtype`  | 返回元素数据类型                |
| `ndim`   | 返回数据维度，始终为1           |
| `empty`  | 返回Series是否为空              |
| `size`   | 返回元素个数                    |
| `values` | 以ndarray类型返回Series所有元素 |
| `index`  | 返回索引对象                    |

### 常用方法

| 方法        | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| `head()`    | 返回前n条数据<br />- n：整数，默认为5                        |
| `tail()`    | 返回后n条数据<br />- n：整数，默认为5                        |
| `isnull()`  | 返回一个Series，其中每个元素表示标签对应的值是否为None或NAN  |
| `isna()`    | 与`isnull()`等价                                             |
| `notnull()` | 返回一个Series，其中每个元素表示标签对应的值是否不为None或NAN |
| `isin()`    | 返回一个Series，其中每个元素表示标签对应的值是否在指定序列中<br />- values：序列 |

## DataFrame

DataFrame表示一个二维表结构，每列的数据类型可以不相同，通过层次索引，DataFrame可以表示更高维度的数据

### 创建

调用`pd.DataFrame()`创建DataFrame对象

```python
df = pd.DataFrame(data, index, columns, dtype, copy)
```

- data：输入的数据
- index：行索引标签，若未指定则自动生成数字标签，若没有对应元素，则填充NaN
- columns：列标签，若未指定则自动生成数字标签，若没有对应元素，则填充NaN
- dtype：指定每一列的数据类型
- copy：表示是否返回视图，默认为False

通常传入一个由等长列表或ndarray组成的字典来创建DataFrame

```python
data = {
    'state': ['Ohio', 'Ohio', 'Ohio', 'Nevada', 'Nevada', 'Nevada'],
    'year': [2000, 2001, 2002, 2001, 2002, 2003],
    'pop': [1.5, 1.7, 3.6, 2.4, 2.9, 3.2]
}
df = pd.DataFrame(data)
'''
   pop   state  year
0  1.5    Ohio  2000
1  1.7    Ohio  2001
2  3.6    Ohio  2002
3  2.4  Nevada  2001
4  2.9  Nevada  2002
5  3.2  Nevada  2003
'''
```

在通过字典创建时列标签以字典的key为准，若设置`columns`，通常用于标签重新排序，`columns`的值需要与字典key匹配，若`columns`中存在不匹配的key，则该列填充NaN

```python
# 列重新排序
df = pd.DataFrame(data, columns=['year', 'state', 'pop'])
'''
   year   state  pop
0  2000    Ohio  1.5
1  2001    Ohio  1.7
2  2002    Ohio  3.6
3  2001  Nevada  2.4
4  2002  Nevada  2.9
5  2003  Nevada  3.2
'''

# 若不匹配，则填充NaN
df1 = pd.DataFrame(data, columns=['year', 'abc', 'pop'])
'''
   year  abc  pop
0  2000  NaN  1.5
1  2001  NaN  1.7
2  2002  NaN  3.6
3  2001  NaN  2.4
4  2002  NaN  2.9
5  2003  NaN  3.2
'''
```

### 索引

DataFrame的索引分为行索引和列索引

-   行索引：使用`loc`属性和`iloc`属性访问
-   列索引：使用`df[]`访问

```python
'''
       year   state  pop
one    2000    Ohio  1.5
two    2001    Ohio  1.7
three  2002    Ohio  3.6
'''

# 列索引
df['state']  # 列索引
df[['year', 'state']]  # 多列索引

# 行索引
df.loc['two']  # 标签索引，同Series
df.iloc[1]  # 下标索引，同Series
```

### 列索引操作

添加一列有两种方法

-   直接赋值：若存在匹配列，则修改该列
-   调用`insert`方法：在指定位置插入新列

```python
# 直接赋值
df['new_col'] = 5  # 用5填充整列
df['new_col'] = [1, 2, 3]  # 按顺序赋值，缺失填充NaN
df['new_col'] = pd.Series([10, 20, 30], index=['a', 'b', 'c'])  # 按匹配标签赋值，未匹配忽略

# 调用insert方法
# loc：插入列位置
# column：列标签，通常为字符串
# values：填充数据，可填充类型同直接赋值
# allow_duplicates：允许插入同名列，默认为False
df.insert(2, 'new_col', [1, 2, 3])
```

删除一列有两种方法

-   通过`del`关键字删除
-   调用`pop`方法删除

```python
# del关键字
def df['new_col']

# 调用pop方法
poped = df.pop('new_col')  # 返回被删除的一列
```

### 行索引操作









- append()：添加行，可以传入其他DataFrame对象，按行拼接
- drop()：删除行，输入整数索引，若有重复行索引，则被一起删除
- set_index()：传入一个列标签，指定已存在的列作为index列，或创建新的标签，自动分配索引值

    - 分层索引操作：传入列标签列表，转换为分层行索引，drop参数设置在更新索引时是否删除原列标签，append参数设置是否添加默认的整数索引值
- reset_index()：重置index索引

常用方法

- T：行和列转置
- axes：返回一个以行标签和列标签为元素的列表
- dtypes：返回每列数据的数据类型
- empty()：若DataFrame中没有数据或任意轴长度为0，返回True
- ndim：返回数组的维数
- shape：返回DataFrame的维度元组
- size：返回元素数量
- values：返回所有元素值的ndarray对象
- head()：返回前n行数据
- tail()：返回后n行数据
- to_numpy()：将DataFrame转换为ndarray数组，dtype参数指定数据类型，copy设置是否返回视图
- shift()：将行或列移动指定的长度
    - peroids：int类型，表示移动的步幅，正数为向下移动，负数为向上移动，默认为1
    - freq：日期偏移量，默认为None，适用于时间序，传入符合时间规则的字符串
    - axis：0表示行移动，1表示列移动，默认为0
    - fill\_value：设置填充值

#### 分层索引

分层索引用于处理高维数据，对象本质上是一个元组序列

创建分层索引

- 调用MultiIndex()，设置levels参数为列表序列，列表的个数表示层级，同时也是元组序列中元组内元素的个数，codes参数为一个数字序列，表示levels序列的下标，-1表示NaN
- 调用from_tuples()创建，创建一个元组序列，将其传入from_tuples()，names参数为每一层命名
- 调用from_frame()，传入一个DataFrame表示分层的索引，返回值传入DataFrame的index参数，DataFrame自动从index列开始分层
- 调用from_product()，传入列表序列，按序列中相邻列表的笛卡尔积，生成不同的组合从而分层
- 调用from_array()，传入一个列表序列

多层行列索引操作

```python
df = pd.DataFrame(np.arange(1,13).reshape((4, 3)),
               index=[['a', 'a', 'b', 'b'], [1, 2, 1, 2]],
               columns=[['Jack', 'Jack', 'Helen'],
              ['Python', 'Java', 'Python']])

# 直接索引，只能使用列索引
#选择同一层级的索引,切记不要写成['Jack','Helen']
print(df[['Jack','Helen']])
#在不同层级分别选择索引
print(df['Jack','Python'])

# 行列索引都可以使用，[行,列]，行/列索引中的层级索引用括号包围
#iloc整数索引
print(df.iloc[:3,:2])
#loc列标签索引
print(df.loc[:,('Helen','Python')])

df:	# 行分为两层，[a,b],[1,2],列分为两层，[Jack,Helen],[Python,Java]
      Jack       Helen
    Python Java Python
a 1      1    2      3
  2      4    5      6
b 1      7    8      9
  2     10   11     12
```

使用聚合函数

使用groupby()的level参数，将某个层级分组后调用聚合函数，axis参数指定沿哪个轴指定层级，level参数可以传入整数，从0开始，表示从外到内的层级，也可以指定层级标签名

```python
# 为行列层级命名
df.index.names=['key1','key2']
df.columns.names=['name','course']
df:
name        Jack       Helen
course    Python Java Python
key1 key2
a    1         1    2      3
     2         4    5      6
b    1         7    8      9
     2        10   11     12
```

将行索引转换为列索引

调用unstack()，传入层级序号或层级名称，将该层索引转换为列索引，同时将Series对象转换为DataFrame对象

交换层级

调用df.swaplevel()，传入层级序号或层级名称，交换两个层级，axis参数指定轴

层级排序

调用sort_index()，level参数设置排序的层级序号或层级名称，排序时移动一整行或一整列，axis指定轴



### 描述性统计函数

聚合类函数都有一个axis参数用于指定轴，0为沿行标签，1为沿列标签，默认为0

- count()：统计某个非空值的数量
- sum()：求和
- mean()：求均值
- median()：求中位数
- mode()：求众数
- std()：求标准差
- min()：求最小值
- max()：求最大值
- abs()：求绝对值，无法操作字符串
- prod()：求所有数值的乘积
- cumsum()：计算累计和
- cumprod()：计算累计积，无法操作字符串
- corr()：计算数列或变量之间的相关系数，值越大，关联性越强
- describe()：数据汇总描述，include参数设置统计数字列还是字符列
    - object： 表示对字符列进行统计信息描述
    - number：表示对数字列进行统计信息描述
    - all：汇总所有列的统计信息

### 自定义函数

对DataFrame使用自定义的函数，将自定义的函数传入指定的DataFrame函数中，自定义函数只能有一个参数，若需要多个参数，则在传入DataFrame函数时，在后面输入参数

- 操作整个 DataFrame 的函数：pipe()
- 操作行或者列的函数：apply()，axis参数控制操作的是行还是列
- 操作单一元素的函数：applymap()

### 重置索引

reindex()：自定义重置标签，返回一个新的对象

```python
df.reindex(index, columns)
```

index、columns参数分别传入新的行标签和列标签，若标签与原标签相同，则填充原标签的数据，否则填充NaN

reindex_like()：复制其他DataFrame对象的标签，a与b的列标签必须相同

```python
a = a.reindex_like(b)
```

填充元素值：使用method参数选择取哪一行进行填充

- pad/ffill：采用前一行数据进行填充
- bfill/backfill：采用后一行数据进行填充
- nearest：从距离最近的索引值开始填充

限制填充行数：使用limit参数，limit=n，则填充n行

rename()：将标签重命名

```python
df.rename(index, columns)
```

index/columns传入一个字典形式的标签，用键表示修改前的值，值表示修改后的值

### 遍历

Series对象使用for循环遍历可以得到value，DataFrame对象使用for循环遍历得到列标签

遍历DataFrame的每一行

迭代器返回原数组的副本

- iteritems()

    以列标签为键，遍历每一行数据，带index

- iterrows()

    以行标签为键，遍历每一行数据，带column

- itertuples()

    将每一行数据生成一个元组，带index，每个列标签对应value

### 排序

- 按标签排序

    sort_index()，axis参数指定轴，默认按行排序，ascending参数指定是否升序排序

- 按值排序

    sort_values()，by参数指定排序依据的列标签或列标签列表，kind参数指定排序方法，可选mergesort，heapsort，quicksort，默认为快排

### 去重

使用函数drop_duplicates()

```python
df.drop_duplicates(subset=['A','B','C'],keep='first',inplace=True)
```

- subset：表示要进去重的列名，默认为None
- keep：有三个可选参数，分别是first、last、False，默认为first，表示只保留第一次出现的重复项，删除其余重复项，last表示只保留最后一次出现的重复项，False则表示删除所有重复项
- inplace：布尔值参数，默认为 False,表示删除重复项后返回一个副本，若为Ture,则表示直接在原数据上删除重复项

### 字符串处理

字符串处理针对series对象的str对象，DataFrame需要先使用索引访问

| 函数名称            | 函数功能和描述                                               |
| ------------------- | ------------------------------------------------------------ |
| lower()             | 将的字符串转换为小写。                                       |
| upper()             | 将的字符串转换为大写。                                       |
| len()               | 得出字符串的长度。                                           |
| strip()             | 去除字符串两边的空格（包含换行符）。                         |
| split()             | 用指定的分割符分割字符串。                                   |
| cat(sep="")         | 用给定的分隔符连接字符串元素。                               |
| get_dummies()       | 返回一个带有独热编码值的 DataFrame 结构。                    |
| contains(pattern)   | 如果子字符串包含在元素中，则为每个元素返回一个布尔值 True，否则为 False。 |
| replace(a,b)        | 将值 a 替换为值 b。                                          |
| count(pattern)      | 返回每个字符串元素出现的次数。                               |
| startswith(pattern) | 如果 Series 中的元素以指定的字符串开头，则返回 True。        |
| endswith(pattern)   | 如果 Series 中的元素以指定的字符串结尾，则返回 True。        |
| findall(pattern)    | 以列表的形式返出现的字符串。                                 |
| swapcase()          | 交换大小写。                                                 |
| islower()           | 返回布尔值，检查 Series 中组成每个字符串的所有字符是否都为小写。 |
| issupper()          | 返回布尔值，检查 Series 中组成每个字符串的所有字符是否都为大写。 |
| isnumeric()         | 返回布尔值，检查 Series 中组成每个字符串的所有字符是否都为数字。 |
| repeat(value)       | 以指定的次数重复每个元素。                                   |
| find(pattern)       | 返回字符串第一次出现的索引位置。                             |

### 统计函数

- 百分比变化

    调用pct_change()：将每个元素与前一个元素进行比较，计算前后数值的百分比变化，axis=1沿columns操作

- 协方差

    s1.cov(s2)，计算series对象之间的协方差，自动排除NaN值，数据为DataFrame时，计算所有列之间的协方差

- 相关系数

    s1.corr(s2)，计算两个series对象之间的相关系数，自动去除NaN值

- 排名

    s.rank()，对series中的元素排名，返回一个名次序列

    - method：对于相同的数据，method参数指定他们的排名方式
        - average：默认值，如果数据相同则分配平均排名
        - min：给相同数据分配最低排名
        - max：给相同数据分配最大排名
        - first：对于相同数据，根据出现在数组中的顺序进行排名
    - axis：沿指定轴排名，默认为0，按行排名，1为按列排名
    - ascending：设置是否升序

### 窗口函数

用于处理数字数据，对其中某个范围方便的进行计算，这个范围称为窗口

- rolling()：移动窗口函数，DataFrame对象默认按行移动

    相应的聚合方法：rolling_mean,rolling_sum,rolling_count等

    ```Python
    rolling(window=n, min_periods=None, center=False)
    ```

    - window：表示观测的数量，默认为1
    - min_periods：表示窗口的最小观测值，默认等于window
    - center：是否把中间值作为窗口标准，默认为False

- expanding()：扩展窗口函数，从第一个元素开始，逐个向后计算聚合值，参数只能设置min_periods

- ewm()：指数加权移动

### 聚合函数

使用aggregate()将聚合函数传入窗口对象中，对窗口对象进行聚合操作

```python
r = df.rolling(window=3,min_periods=1)
r['A'].aggregate(np.sum) # 对窗口中的一列进行聚合
r['A','B'].aggregate(np.sum) # 对多列进行聚合
r['A','B'].aggregate([np.sum,np.mean]) # 对单列应用多个函数
r['A','B'].aggregate([np.sum,np.mean]) # 对不同列应用相应的函数
```

### 缺失值处理

检查缺失值

使用isnull()/notnull()，适用于Series和DataFrame及其中的行和列

缺失数据计算：将NaN视为0，若计算的数据为NaN，则结果为NaN

填充缺失值：调用fillna()

- 用标量值填充NaN
- 用method参数设置以前面数据还是后面数据进行填充
- 用replace()替换，传入一个以修改前数据为键，修改后数据为值的字典

删除缺失值：调用dropna()删除NaN，axis参数指定轴

### groupby分组

将列标签进行分组

- 创建分组对象：调用groupby()，默认沿index分组，分组后传入的标签作为键

    ```python
    g = df.groupby("col") # 对单个标签分组
    g = df.groupby(["col1", "col2"]) # 对多个标签分组
    ```

- groups属性：返回分组对象

- g.get_group(value)：返回分组对象中的一个组

- 应用聚合函数：`g.agg(func)`对组内元素应用func函数，可传入函数列表

- 组内过滤操作：调用filter()筛选符合条件的数据，返回一个新的数据集

    ```python
    df.groupby('Team').filter(lambda x: len(x) >= 2)
    ```

### merge合并

调用merge()，将两个DateFrame合并为一个

```python
pd.merge(left, right, how='inner', on=None, left_on=None, right_on=None,left_index=False, right_index=False, sort=True,suffixes=('_x', '_y'), copy=True)
```

| 参数名称    | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| left/right  | 两个不同的 DataFrame 对象                                    |
| on          | 指定用于连接的键（即列标签的名字），该键必须同时存在于左右两个 DataFrame 中，如果没有指定，并且其他参数也未指定， 那么将会以两个 DataFrame 的列名交集做为连接键 |
| left_on     | 指定左侧 DataFrame 中作连接键的列名                          |
| right_on    | 指定右侧 DataFrame 中作连接键的列名                          |
| left_index  | 布尔参数，默认为 False。如果为 True 则使用左侧 DataFrame 的行索引作为连接键，若 DataFrame 具有多层 索引(MultiIndex)，则层的数量必须与连接键的数量相等 |
| right_index | 布尔参数，默认为 False。如果为 True 则使用左侧 DataFrame 的行索引作为连接键 |
| how         | 要执行的合并类型，从 {'left', 'right', 'outer', 'inner'} 中取值，默认为“inner”内连接 |
| sort        | 布尔值参数，默认为True，它会将合并后的数据进行排序；若设置为 False，则按照 how 给定的参数值进行排序 |
| suffixes    | 字符串组成的元组。当左右 DataFrame 存在相同列名时，通过该参数可以在相同的列名后附加后缀名，默认为('\_x','_y') |
| copy        | 默认为 True，表示对数据进行复制                              |

### concat连接

调用concat()，将Series对象或DataFrame沿某个轴连接在一起

```python
 pd.concat(objs,axis=0,join='outer',join_axes=None,ignore_index=False,keys=None)
```

- objs：一个序列或者是Series对象、DataFrame
- axis：指定沿哪个轴进行连接操作
- join：指定连接方式，可选inner，outer，默认为outer
- ignore_index：默认为False，若为True，则不再连接的轴上使用索引
- join_axes：表示索引对象的列表
- keys：给连接的对象指定键

append()：将Series对象与DataFrame连接，该方法沿axis=0操作(添加行)

### 时间序列处理

获取当前时间：导入datetime库，调用now()，获取当前时间

时间序列主要有三种应用场景：特定的时刻(时间戳)，固定的日期，时间间隔

- 创建时间戳

    调用pd.Timestamp()，传入时间字符串或一个数字，units参数指定单位，默认单位为纳秒

- 创建时间范围

    调用date_range(start, end, freq)创建一段连续的时间或有固定间隔的时间段，freq为时间频率，默认为D(天)，起始和终止为左闭右闭，freq参数设置该时间范围内有多少个周期，time属性查看时间

- 转换时间戳

    调用to_datetime()将Series对象和list中与时间相关的字符串转换为时间戳，NaT表示无效值

- 将频率转换为周期，如将频率“月”转换为一段时间

    使用Periods类的Period()创建一个时期，传入一个时间戳和设置freq参数，freq指明该period的长度(频率)

    - 频率转换：p.asfreq(freq, how)，freq参数设置新的频率，how设置以起始还是终止为节点，如月初月末
    - 算术运算：通过算术运算，可以将该period在时间轴上移动，单位长度为该period的长度
    - 创建时期范围：调用period_range()，输入两个时间戳和频率

### 时间格式化

常用日期格式化符号

| 符号 | 说明                                      |
| ---- | ----------------------------------------- |
| %y   | 两位数的年份表示（00-99）                 |
| %Y   | 四位数的年份表示（000-9999）              |
| %m   | 月份（01-12）                             |
| %d   | 月内中的一天（0-31）                      |
| %H   | 24小时制小时数（0-23）                    |
| %I   | 12小时制小时数（01-12）                   |
| %M   | 分钟数（00=59）                           |
| %S   | 秒（00-59）                               |
| %a   | 本地英文缩写星期名称                      |
| %A   | 本地英文完整星期名称                      |
| %b   | 本地缩写英文的月份名称                    |
| %B   | 本地完整英文的月份名称                    |
| %w   | 星期（0-6），星期天为星期的开始           |
| %W   | 一年中的星期数（00-53）星期一为星期的开始 |
| %x   | 本地相应的日期表示                        |
| %X   | 本地相应的时间表示                        |
| %Z   | 当前时区的名称                            |
| %U   | 一年中的星期数（00-53）星期天为星期的开始 |
| %j   | 年内的一天（001-366）                     |
| %c   | 本地相应的日期表示和时间表示              |

- Python内置的strptime()可将日期字符串转化为datetime对象，传入字符串和格式字符串
- pandas的to_datetime()，传入一个日期字符串，不需要指定格式，直接转化为datetime对象
- 使用DatetimeIndex()，传入一个时间字符串列表，生成一个时间序列，可以传入Series或DataFrame中作为索引

### Timedelta时间差

传递一个字符串创建一个Timedelta对象

```python
import pandas as pd
print(pd.Timedelta('5 days 8 hours 6 minutes 59 seconds'))

print(pd.Timedelta(19,unit='h')) # 传入一个整数，units参数设置单位创建一个Timedelta对象

print (pd.Timedelta(days=2,hours=6)) # 关键字传参
```

to_timedelta()：将具有Timedelta格式的对象转化为Timedelta类型，输入Series和标量时，返回类型与输入类型一致

datetime与Timedelta类型可以做加减运算

```python
import pandas as pd
s = pd.Series(pd.date_range('2012-1-1', periods=3, freq='D'))
td = pd.Series([ pd.Timedelta(days=i) for i in range(3) ])
df = pd.DataFrame(dict(A = s, B = td))
df['C']=df['A']+df['B']
df['D']=df['C']-df['B']
print(df)
```

### 随机抽样

调用sample()对数据进行随机抽样

```python
DataFrame.sample(n=None, frac=None, replace=False, weights=None, random_state=None, axis=None)
```

- n：要抽取的行数
- frac：要抽取的比例
- replace：设置是否为放回抽样，默认为False
- weights：表示每个样本的权重值，传入一个数组或一个字符串(列标签，以某列作为权重)
- random_state：控制随机状态，默认为None，表示随机数据不重复，1表示取得重复数据
- axis：指定轴抽取数据

### 重采样

重采样是将数据的频率转换到另一个频率的过程，有升采样和降采样两种方式

- 升采样：将低频转换为高频
- 降采样：将高频转换为低频

对时间的重采样，改变时间序列的频率，如将按月计变为按日计

使用resample()实现对数据的重采样，传入参数为新的频率，对返回值应用asfreq()，获取新频率的period对象

#### 插值处理

进行升采样后会出现缺失值，此时需要对缺失值进行处理

| 方法                   | 说明                         |
| ---------------------- | ---------------------------- |
| pad/ffill              | 用前一个非缺失值去填充缺失值 |
| backfill/bfill         | 用后一个非缺失值去填充缺失值 |
| interpolater('linear') | 线性插值方法                 |
| fillna(value)          | 指定一个值去替换缺失值       |

### 分类对象

用于处理数据集中同一类别的信息，分类对象具有排序、自动去重的功能，不能执行运算

创建分类对象

- 指定dtype参数创建：`s = pd.Series(["a","b","c","a"], dtype="category")`

    s包含a,b,c，分类对象进行自动去重

- 调用pd.Categorical(values, ordered, categories)构造函数，传入一个values列表，表示分类的数据，ordered参数表示是否对数据进行排序，默认为False，categories参数指定分类的类别

操作分类对象

- 分类对象的categories属性返回分类的类别信息
- 重命名类别：通过s.cat.categories属性设置每个类别名，用列表赋值
- 添加新类别：调用s.cat.add_categories()，传入一个列表，表示要添加的类别名
- 删除类别：调用s.cat.remove_categories()，输入一个类别名删除该类别
- 分类对象比较：当两个类别的ordered均等于True，并且类别相同时(categories参数相同)，可以进行比较运算

### 读取文件

- read_csv() 用于读取文本文件
- read_json() 用于读取 json 文件
- read_sql_query() 读取 sql 语句

#### CSV文件读写

调用read_csv(path)可以读取csv文件，获取DataFrame对象

```python
pandas.read_csv(filepath_or_buffer, sep=',', delimiter=None, header='infer',names=None, index_col=None, usecols=None)
```

- seq：指定文件中的分隔符
- names：为文件中的列再添加列标签，原标签变为第1行
- index_col：指定index列的列标签
- skiprows：指定读取时跳过的行数

调用to_csv()将DataFrame对象保存为csv文件，seq参数指定分隔符，默认为逗号

#### Excel文件读写

to_excel()：将DataFrame对象写入到Excel文件中

如果想要把单个对象写入 Excel 文件，那么必须指定目标文件名；如果想要写入到多张工作表中，则需要创建一个带有目标文件名的`ExcelWriter`对象，并通过`sheet_name`参数依次指定工作表的名称

```python
DataFrame.to_excel(excel_writer, sheet_name='Sheet1', na_rep='', float_format=None, columns=None, header=True, index=True, index_label=None, startrow=0, startcol=0, engine=None, merge_cells=True, encoding=None, inf_rep='inf', verbose=True, freeze_panes=None)
```

参数说明

| 参数名称     | 描述说明                                                     |
| ------------ | ------------------------------------------------------------ |
| excel_wirter | 文件路径或者 ExcelWrite 对象。                               |
| sheet_name   | 指定要写入数据的工作表名称。                                 |
| na_rep       | 缺失值的表示形式。                                           |
| float_format | 它是一个可选参数，用于格式化浮点数字符串。                   |
| columns      | 指要写入的列。                                               |
| header       | 写出每一列的名称，如果给出的是字符串列表，则表示列的别名。   |
| index        | 表示要写入的索引。                                           |
| index_label  | 引用索引列的列标签。如果未指定，并且 hearder 和 index 均为为 True，则使用索引名称。如果 DataFrame 使用 MultiIndex，则需要给出一个序列。 |
| startrow     | 初始写入的行位置，默认值0。表示引用左上角的行单元格来储存 DataFrame。 |
| startcol     | 初始写入的列位置，默认值0。表示引用左上角的列单元格来储存 DataFrame。 |
| engine       | 它是一个可选参数，用于指定要使用的引擎，可以是 openpyxl 或 xlsxwriter。 |

read_excel()：读取Excel文件中的表格

```python
pd.read_excel(io, sheet_name=0, header=0, names=None, index_col=None,
              usecols=None, squeeze=False,dtype=None, engine=None,
              converters=None, true_values=None, false_values=None,
              skiprows=None, nrows=None, na_values=None, parse_dates=False,
              date_parser=None, thousands=None, comment=None, skipfooter=0,
              convert_float=True, **kwds)
```

参数说明

| 参数名称   | 说明                                                         |
| ---------- | ------------------------------------------------------------ |
| io         | 表示 Excel 文件的存储路径。                                  |
| sheet_name | 要读取的工作表名称。                                         |
| header     | 指定作为列名的行，默认0，即取第一行的值为列名；若数据不包含列名，则设定 header = None。若将其设置 为 header=2，则表示将前两行作为多重索引。 |
| names      | 一般适用于Excel缺少列名，或者需要重新定义列名的情况；names的长度必须等于Excel表格列的长度，否则会报错。 |
| index_col  | 用做行索引的列，可以是工作表的列名称，如 index_col = '列名'，也可以是整数或者列表。 |
| usecols    | int或list类型，默认为None，表示需要读取所有列。              |
| squeeze    | boolean，默认为False，如果解析的数据只包含一列，则返回一个Series。 |
| converters | 规定每一列的数据类型。                                       |
| skiprows   | 接受一个列表，表示跳过指定行数的数据，从头部第一行开始。     |
| nrows      | 需要读取的行数。                                             |
| skipfooter | 接受一个列表，省略指定行数的数据，从尾部最后一行开始。       |
