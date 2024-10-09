---
layout: post
title: jekyll-cli开发记录
categories:
- 博客开发
tags:
- Jekyll
- CLI
- Typer
typora-root-url: ./
date: 2024-05-24 16:31
---

## 项目背景

前段时间写了挺多博客，一直是用[`jekyll-compose`](https://github.com/jekyll/jekyll-compose)来完成创建、发布等功能，但使用过程中也遇到挺多不满意的地方，比如命令太长、`typora-root-url`加上引号导致typora预览失效、不能在任意目录执行命令等

在此背景下，我首先开发了`PowerJekyll`项目，但`PowerJekyll`虽说是一个`PowerShell`模块，但却依赖于Python环境，并且模块的`PowerShell`脚本只是完成了自动补全的注册，并没有功能上的增加，显得可有可无

同时，我接触到了[`Typer`](https://typer.tiangolo.com/)框架，一个用于构建CLI应用的现代化框架，使用装饰器定义一个指令的执行函数，同时使用类型标记完成参数的类型验证，极大简化了命令行参数的解析和验证。不仅如此，相比原来的`argparse`，`Typer`打印的帮助文档更加美观，同时支持`rich`库输出美观的控制台文本。因此，我决定大刀阔斧，使用`Typer`重写项目，并且更名为`jekyll-cli`，使用`Poetry`管理依赖和打包，项目已发布在PyPi上

PyPi: [jekyll-cli · PyPI](https://pypi.org/project/jekyll-cli/)

Github: [Baymax104/jekyll-cli: Jekyll Blog CLI Tool (github.com)](https://github.com/Baymax104/jekyll-cli)

## 项目结构

```
jekyll-cli
├──.venv
├──dist
├──jekyll_cli
├──tests
├──.gitignore
├──LICENSE
├──poetry.lock
├──pyproject.toml
└──README.md
```

-   `jekyll_cli`：源代码模块
-   `pyproject.toml`：poetry项目配置文件
-   `.venv`：poetry环境依赖目录
-   `dist`：打包目标目录

## 改造Jekyll博客

`jekyll-cli`的item模式使用一个目录来管理文章，这个目录作为一个item，目录结构如下

```
/_posts/xxx
├──assets
└──xxx.md
```

直接在`_posts`目录或`_drafts`目录中创建item目录，在Jekyll生成博客时会出现两个问题

1.   `_site`目录中不存在item目录中的assets目录

     Jekyll对每一篇文章生成一个同名的目录，其中包含一个`index.html`，这个`index.html`就是生成的文章，但该目录中没有包含assets目录，导致文章中的引用的图片资源不存在

2.   生成的文章中的`img`标签链接错误

     Jekyll生成文章时，文章中的图片链接是以生成的目标目录（一般为`_site`）为根路径，而使用item目录管理时，文章中使用的图片链接一般是相对于当前item目录的相对路径，因此生成的文章中的图片链接错误

为了解决这两个问题，我使用Jekyll的hook函数在站点生成时进行调整，将hook函数作为插件添加到Jekyll博客中

-   `assets-include-hook.rb`：将assets目录复制到`_site`中

    ```ruby
    # 在整个站点写入完成后调用
    Jekyll::Hooks.register :site, :post_write do |site|
    
        site.posts.docs.each do |post|
            
            # post.path为文章在_posts下的绝对路径
            # e.g. my-blog/_posts/my-post/2024-10-09-my-post.md
            src_dir = File.join(File.dirname(post.path), 'assets')
            
            # site.dest为站点目标目录的绝对路径，e.g. my-blog/_site
            # post.id为文章的标识符，e.g. /posts/my-post
            dest_dir = File.join(site.dest, post.id, 'assets')
            
            if Dir.exist?(src_dir)
                # 创建dest_dir目录
	            FileUtils.mkdir_p(dest_dir)
	            
	            # 将src_dir下的所有文件复制到dest_dir中
	            Dir.glob(File.join(src_dir, '*')).each do |img|
	                next unless File.file?(img)
	                FileUtils.cp(img, dest_dir)
	            end
	        end
	    end
	end
	```
	{: file='assets-include-hook.rb' }
-   `relative-path-hook.rb`：调整文章中的图片链接为目标目录的相对路径

    ```ruby
    # 在渲染post之前调用
    Jekyll::Hooks.register :posts, :pre_render do |post|
    
        # 处理相对路径
        # 将doc_path与relative_path拼接，若relative_path以'./'开头，则去除后拼接
        def resolve_relative_path(doc_path, relative_path)
            if relative_path.start_with?('./')
                File.join(doc_path, relative_path[2..-1])
            else
                File.join(doc_path, relative_path)
            end
        end
    
        # 调整文章中markdown格式的图片链接
        post.content = post.content.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do |match|
            alt_text = $1
            # path是对于item的相对路径
            path = $2
    
            # 跳过绝对路径
            # path可能为'./assets/...'或'assets/...'
            next match if path.start_with?('http', '/')
    
            # 将对于item的相对路径调整为对于_site的相对路径
            # e.g. './assets/...' -> '/posts/my-post/assets/...'
            doc_path = post.id
            new_path = resolve_relative_path(doc_path, path)
            "![#{alt_text}](#{new_path})"
        end
    
        # 调整文章中的img标签的图片链接
        post.content = post.content.gsub(/<img\s+[^>]*src=["']([^"']+)["']/) do |match|
            src = $1
    
            # skip absolute path
            next match if src.start_with?('http', '/')
    
            doc_path = post.id
            new_src = resolve_relative_path(doc_path, src)
            match.gsub(src, new_src)
        end
    end
    ```
    {: file='relative-path-hook.rb' }

将以上两个`.rb`文件放在`_plugins`目录下，就可以使用`jekyll-cli`的item模式管理博客了

---

>   以下为旧版本记录

**项目背景**

前段时间写了挺多博客，一直是用`jekyll-compose`（[github](https://github.com/jekyll/jekyll-compose)）来完成创建、发布等功能，但使用过程中也遇到挺多不满意的地方，比如命令太长、`typora-root-url`加上引号导致typora预览失效、不能在任意目录执行命令等

起初，我使用`git bash`来代替Windows下的cmd，编写了一个shell脚本来封装compose的命令，解决了命令太长的问题，但功能始终不够强大，比如输入文件名时没有自动补全，命令解析太麻烦等

于是我使用Python脚本来代替shell脚本，Python脚本可以非常容易地实现强大的功能，借助`argparse`库和`argcomplete`库也能轻松做到命令解析和自动补全

这里有一个小插曲，`argcomplete`库在`git bash`下的支持不好，于是我又灰溜溜地换到了PowerShell，这时候才发现原来系统自带的PowerShell是5.1版本，而现在PowerShell7的功能已经很强了，又是一顿疯狂配置，现在已经用的非常顺手了

言归正传，我基于这样的背景开发了`PowerJekyll`项目，它是一个PowerShell模块，虽然功能简单，但非常实用，基本满足了我的日常使用

**项目结构**

项目中主要的代码文件如下

```
PowerJekyll
│  config.yml
│  PowerJekyll.psd1
│  PowerJekyll.psm1
│
└─core
    │  command.py
    │  main.py
    │  parser.py
    │  utils.py
    │
    ├─commands
    │      draft.py
    │      list.py
    │      open.py
    │      post.py
    │      publish.py
    │      remove.py
    │      serve.py
    │      unpublish.py
    │
    └─git_commands
            add.py
            commit.py
            push.py
            status.py
            __init__.py
```

-   `PowerJekyll.psm1`：PowerShell模块文件，提供启动命令`blog`以及注册自动补全
-   `PowerJekyll.psd1`：PowerShell模块清单，包含模块的元数据
-   `config.yml`：配置文件
-   `core`：命令脚本及主程序目录
-   `commands`：博客的基本命令，包含创建、发布、打开等
-   `git_commands`：与git相关命令，执行博客的git部分操作

**argparse**

argparse库用于Python脚本的命令行参数解析，通过配置解析器对象来设置命令的参数、格式等

官方文档：[argparse --- 用于命令行选项、参数和子命令的解析器 — Python 3.12.3 文档](https://docs.python.org/zh-cn/3/library/argparse.html#)

基本使用流程

-   创建`argparse.ArgumentParser`解析器对象，设置程序名称、帮助文档等
-   调用`add_argument`方法来添加参数，设置参数的名称、类型、帮助文档等
-   调用`parse_args`方法来解析命令，返回参数对象`args`
-   调用`args`的参数属性来获取参数值

**实现子命令**

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

**argcomplete**

argcomplete库基于argparse库实现参数的自动补全

官方github：[kislyuk/argcomplete: Python and tab completion, better together. (github.com)](https://github.com/kislyuk/argcomplete)

基本使用：在调用`parse_args`方法解析参数之前，调用`argcomplete.autocomplete(parser)`，argcomplete会自动根据解析器来实现补全

**自定义补全**

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

**PowerShell模块**

PowerShell模块是一个自包含的可重用单元，可以包含cmdlet、提供程序、函数、变量等

官方文档：[关于模块 - PowerShell](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7.4)

编写PowerShell模块参考：[如何编写 PowerShell 脚本模块 - PowerShell](https://learn.microsoft.com/zh-cn/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.2)

安装PowerShell模块参考：[安装 PowerShell 模块 - PowerShell](https://learn.microsoft.com/zh-cn/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.2)

