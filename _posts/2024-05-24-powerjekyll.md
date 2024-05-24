---
layout: post
title: PowerJekyll开发记录
categories:
- 博客开发
tags:
- Jekyll
- PowerShell
- CLI
typora-root-url: ./..
date: 2024-05-24 16:31
---

## 项目背景

前段时间写了挺多博客，一直是用`jekyll-compose`（[github](https://github.com/jekyll/jekyll-compose)）来完成创建、发布等功能，但使用过程中也遇到挺多不满意的地方，比如命令太长、`typora-root-url`加上引号导致typora预览失效、不能在任意目录执行命令等

起初，我使用`git bash`来代替Windows下的cmd，编写了一个shell脚本来封装compose的命令，解决了命令太长的问题，但功能始终不够强大，比如输入文件名时没有自动补全，命令解析太麻烦等

于是我使用Python脚本来代替shell脚本，Python脚本可以非常容易地实现强大的功能，借助`argparse`库和`argcomplete`库也能轻松做到命令解析和自动补全

这里有一个小插曲，`argcomplete`库在`git bash`下的支持不好，于是我又灰溜溜地换到了PowerShell，这时候才发现原来系统自带的PowerShell是5.1版本，而现在PowerShell7的功能已经很强了，又是一顿疯狂配置，现在已经用的非常顺手了

言归正传，我基于这样的背景开发了`PowerJekyll`项目，它是一个PowerShell模块，虽然功能简单，但非常实用，基本满足了我的日常使用

项目github：[Baymax104/PowerJekyll: Jekyll博客的PowerShell命令行工具 (github.com)](https://github.com/Baymax104/PowerJekyll)

## 项目结构

项目中主要的代码文件如下

```
PowerJekyll
│  PowerJekyll.psd1
│  PowerJekyll.psm1
│
└─core
        blog.py
        config.yml
        main.py
        parser.py
```

-   `PowerJekyll.psm1`：PowerShell模块文件，提供启动命令`blog`以及注册自动补全
-   `PowerJekyll.psd1`：PowerShell模块清单，包含模块的元数据
-   `main.py`：脚本主程序
-   `blog.py`：博客的基本功能，包含创建、发布、打开等
-   `parser.py`：初始化命令解析
-   `config.yml`：配置文件

## argparse库

argparse库用于Python脚本的命令行参数解析，通过配置解析器对象来设置命令的参数、格式等

官方文档：[argparse --- 用于命令行选项、参数和子命令的解析器 — Python 3.12.3 文档](https://docs.python.org/zh-cn/3/library/argparse.html#)

基本使用流程

-   创建`argparse.ArgumentParser`解析器对象，设置程序名称、帮助文档等
-   调用`add_argument`方法来添加参数，设置参数的名称、类型、帮助文档等
-   调用`parse_args`方法来解析命令，返回参数对象`args`
-   调用`args`的参数属性来获取参数值

### 实现子命令

argparse可以创建多个子命令解析器，每个子命令解析器可以独立添加参数，可直接调用`args`的子命令的参数属性来获取参数值

基本示例

```python
# 创建主解析器
parser = argparse.ArgumentParser(prog='PROG')
# 主解析器独立添加参数
parser.add_argument('--foo', action='store_true', help='foo help')
# 子命令占位参数
subparsers = parser.add_subparsers(dest='command', help='sub-command help')

# 创建子命令解析器
parser_a = subparsers.add_parser('a', help='a help')
# 子命令添加参数
parser_a.add_argument('bar', type=int, help='bar help')

# 解析参数
parser.parse_args()
```

## argcomplete库

argcomplete库基于argparse库实现参数的自动补全

官方github：[kislyuk/argcomplete: Python and tab completion, better together. (github.com)](https://github.com/kislyuk/argcomplete)

基本使用：在调用`parse_args`方法解析参数之前，调用`argcomplete.autocomplete(parser)`，argcomplete会自动根据解析器来实现补全

### 自定义补全

在设置解析器时，可以设置参数的completer（补全器）来实现自定义补全，库中提供了以下几种completer

-   `ChoicesCompleter`：集合补全
-   `DirectoriesCompleter`：目录补全
-   `FilesCompleter`：文件名补全
-   `SuppressCompleter`：抑制特定参数补全

使用`ChoicesCompleter`的基本示例

```python
parser = argparse.ArgumentParser(prog='PROG')
action = parser.add_argument('--foo', action='store_true', help='foo help')
# 自定义集合
value_list = [1, 2, 3]
# add_argument方法的返回值是一个Action对象，设置Action对象的completer属性
action.completer = argcomplete.completers.ChoicesCompleter(value_list)
```

## PowerShell模块

PowerShell模块是一个自包含的可重用单元，可以包含cmdlet、提供程序、函数、变量等

官方文档：[关于模块 - PowerShell](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.4)

编写PowerShell模块参考：[如何编写 PowerShell 脚本模块 - PowerShell](https://learn.microsoft.com/zh-cn/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.2)

安装PowerShell模块参考：[安装 PowerShell 模块 - PowerShell](https://learn.microsoft.com/zh-cn/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.2)

