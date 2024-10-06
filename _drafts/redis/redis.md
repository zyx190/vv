---
layout: post
title: Redis基础
categories:
- 后端
tags:
- Redis
- 数据库
---

## 开始

Redis是一个基于内存的非关系型数据库，使用key-value存储

Redis支持以下的基本数据类型

-   String：字符串
-   Hash：散列
-   List：列表
-   Set：集合
-   Sorted Set：有序集合
-   bitmap：位图
-   bitfield：位域
-   GEO：地理空间
-   Stream：流

## 基本命令

安装Redis后，在命令行使用`redis-cli`命令连接到本地的Redis服务，**添加`--raw`选项可原样显示中文**

键命令用于管理Redis中的键，基本格式为

```
[COMMAND] [KEY] [VALUE]
```

常用命令

-   `DEL [KEY]`：删除一个键
-   `EXISTS [KEY]`：查看键是否存在
-   `KEYS [PATTERN]`：查找给定模式的键，支持`*`、`?`、`[]`三种通配符
-   `RENAME KEY] [NAME]`：修改键名
-   `TYPE KEY]`：查看键对应值的类型
-   `EXPIRE KEY] [SECONDS]`：设置键的过期时间，以秒为单位
-   `TTL KEY]`：查看键的剩余时间
-   `PERSIST [KEY]`：删除键的过期时间

## 数据类型

redis支持字符串、列表、集合、有序集合、哈希、bitmap等类型，每种类型有对应的操作命令

### 字符串

字符串命令操作的数据是String类型

-   `SET [KEY] [VALUE]`：设置一个key-value
-   `GET [KEY]`：查看键对应的值

更多命令见：[Commands](https://redis.io/docs/latest/commands/?group=string)

### 列表

列表命令操作的数据是List类型，以L开头的命令表示处理列表的起始位置，以R开头的命令表示处理列表的末尾位置

-   `[LPUSH | RPUSH] [KEY] [VALUE1] [VALUE2] [VALUE3]`：在起始或末尾添加元素
-   `[LPOP | RPOP] [KEY] [COUNT]`：删除起始或末尾的指定个数的元素
-   `LRANGE [KEY] [START] [END]`：返回列表中指定范围的元素，起始从0开始，支持负数索引
-   `LTRIM [KEY] [START] [END]`：保留列表中指定范围内的元素

更多命令见：[Commands](https://redis.io/docs/latest/commands/?group=list)

### 集合

集合命令操作的数据是Set类型，数据无序且唯一，集合命令都是以S开头

-   `SADD [KEY] [VALUE1] [VALUE2] [VALUE3]`：将元素添加到集合中
-   `SCARD [KEY]`：查看集合中的元素个数
-   `SMEMBERS [KEY]`：查看集合中的元素
-   `SISMEMBERS [KEY] [VALUE]`：判断元素是否在集合中
-   `SREM [KEY] [VALUE]`：删除集合中的元素

更多命令见：[Commands](https://redis.io/docs/latest/commands/?group=set)

### 有序集合

有序集合命令操作的数据是Sorted Set类型，数据有序且唯一，有序集合命令都是以Z开头

-   `ZADD [KEY] [VALUE1] [SCORE1] [VALUE2] [SCORE2]`：将元素添加到集合中，添加时每个值附带一个分数Score，用于在有序集合中排序，Score必须是一个表示数值的字符串
-   `ZRANGE [KEY] [START] [END] [WITHSCORES]`：查看集合中指定范围的元素，添加`WITHSCORES`选项会同时输出分数
-   `ZSCORE [KEY] [VALUE]`：查看集合中元素的分数
-   `ZRANK [KEY] [VALUE]`：查看集合中元素的升序排名
-   `ZREVRANK [KEY] [VALUE]`：查看集合中元素的降序排名
-   `ZREM [KEY] [VALUE]`：删除集合中的元素

### Hash

redis中Hash可以表示一个键值对的集合，Hash命令都是以H开头

-   `HSET [KEY] [HASH_KEY] [HASH_VALUE]`：将键值对添加到Hash中
-   `HGET [KEY] [HASH_KEY]`：获取Hash中的键值
-   `HGETALL [KEY]`：获取Hash中的所有键值
-   `HDEL [KEY] [HASH_KEY]`：删除Hash中的键值
-   `HEXISTS [KEY] [HASH_KEY]`：判断Hash中键是否存在
-   `HKEYS [KEY]`：获取Hash中的所有键
-   `HLEN [KEY]`：获取Hash中的键值对数量

### bitmap

bitmap位图表示一个仅有0和1的二进制数组，可存储大量二元状态，需要通过偏移量获取值

-   `SETBIT [KEY] [OFFSET] [VALUE]`：设置bitmap指定位置的值
-   `GETBIT [KEY] [OFFSET]`：获取bitmap指定位置的值
-   `BITCOUNT [KEY] [START] [END]`：获取bitmap指定范围内1的个数

### bitfield

bitfield位域命令将字符串和数值作为二进制串处理，可以对该二进制串中的任意一个或多个位进行修改

-   `BITFIELD [KEY] GET [TYPE] [OFFSET]`：从指定位置开始，获取指定类型范围的二进制值
-   `BITFIELD [KEY] SET [TYPE] [OFFSET] [VALUE]`：从指定位置开始，设置指定类型范围的二进制值
-   `BITFIELD [KEY] INCRBY [TYPE] [OFFSET] [INCREMENT]`：从指定位置开始，对指定类型范围的二进制值做加法

### HyperLogLog

HyperLogLog可以计算集合的基数，通过牺牲一定的精确度换取非常小的内存占用

-   `PFADD [KEY] [VALUE1] [VALUE2] [VALUE3]`：将元素添加到HyperLogLog中
-   `PFCOUNT [KEY]`：获取集合的基数估算值
-   `PFMERGE [DEST_KEY] [SRC_KEY1] [SRC_KEY2]`：合并多个HyperLogLog，基数由多个集合的并集计算得到

### GEO



### Stream





## 发布订阅模式

redis提供了发布订阅功能

-   `PUBLISH [CHANNEL] [MESSAGE]`：向指定通道发布一个消息
-   `SUBSCRIBE [CHANNEL]`：订阅一个通道

## 持久化





## 主从复制





## 哨兵模式





## 集群分片





