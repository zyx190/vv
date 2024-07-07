---
layout: post
title: 记录使用jekyll-compose的一个坑
categories:
- 博客开发
tags:
- jekyll-compose
- bug
typora-root-url: ./
date: 2024-05-24 14:51
---

## 问题背景

在使用`jekyll-compose`（[github](https://github.com/jekyll/jekyll-compose)）时，我需要创建好草稿后自动打开，这个功能在README中表述如下

---

auto-open new drafts or posts in your editor

```
  jekyll_compose:
    auto_open: true
```

and make sure that you have `EDITOR`, `VISUAL` or `JEKYLL_EDITOR` environment variable set. For instance if you wish to open newly created Jekyll posts and drafts in Atom editor you can add the following line in your shell configuration:

```
export JEKYLL_EDITOR=atom
```

`JEKYLL_EDITOR` will override default `EDITOR` or `VISUAL` value. `VISUAL` will override default `EDITOR` value.

---

大意就是在`_config.yml`中配置`auto_open: true`，在通过`JEKYLL_EDITOR`环境变量指定打开的编辑器，于是我设置`JEKYLL_EDITOR=code`，用vscode打开，这样可以正常运行

但我经常使用typora来编辑md文档，因此我设置`JEKYLL_EDITOR=typora`，此时文档**不能自动打开**，设置`JEKYLL_EDITOR=D:\Typora\Typora.exe`，此时文档可以打开，但**控制台会卡住并且报错**

我已经设置了md文件的默认打开方式为typora，因此我希望它按照我设置的默认打开方式打开

## 解决方法

要使用编辑器打开，那么源码中必然有执行一条指令调用了编辑器，于是我找到了`jekyll-compose`包的所在位置，文件树如下

```
D:\DEVELOPTOOL\RUBY32-X64\LIB\RUBY\GEMS\3.2.0\GEMS\JEKYLL-COMPOSE-0.12.0
└─lib
    │  jekyll-compose.rb
    │
    ├─jekyll
    │  └─commands
    │          compose.rb
    │          draft.rb
    │          page.rb
    │          post.rb
    │          publish.rb
    │          rename.rb
    │          unpublish.rb
    │
    └─jekyll-compose
            arg_parser.rb
            file_creator.rb
            file_editor.rb
            file_info.rb
            file_mover.rb
            movement_arg_parser.rb
            version.rb
```

可以看到commands目录存放各个子命令的源码，在jekyll-compose目录中有一个`file-editor.rb`文件，这应该就是处理文件编辑器的源码，代码量不大，如下所示

```ruby
# frozen_string_literal: true

#
# This class is aimed to open the created file in the selected editor.
# To use this feature specify at Jekyll config:
#
# ```
#  jekyll_compose:
#    auto_open: true
# ```
#
# And make sure, that you have JEKYLL_EDITOR, VISUAL, or EDITOR environment variables set up.
# This will allow to open the file in your default editor automatically.

module Jekyll
  module Compose
    class FileEditor
      class << self
        attr_reader  :compose_config
        alias_method :jekyll_compose_config, :compose_config

        def bootstrap(config)
          @compose_config = config["jekyll_compose"] || {}
        end

        def open_editor(filepath)
          run_editor(post_editor, File.expand_path(filepath)) if post_editor
        end

        def run_editor(editor_name, filepath)
          system("#{editor_name} #{filepath}")
        end

        def post_editor
          return unless auto_open?

          ENV["JEKYLL_EDITOR"] || ENV["VISUAL"] || ENV["EDITOR"]
        end

        def auto_open?
          compose_config["auto_open"]
        end
      end
    end
  end
end
```

源码使用ruby语言，我并没有学过ruby语言，但通过命名可以看出一些功能

`run_editor`函数中调用了`system("#{editor_name} #{filepath}")`，这很明显是通过系统命令行来调用编辑器，那么`editor_name`就是环境变量指定的编辑器

`run_editor`函数在`open_editor`函数中调用，传入的`editor_name`参数通过`post_editor`函数得到，而`post_editor`函数中就是读取了`JEKYLL_EDITOR`环境变量

现在，我想使用默认打开方式打开文件，在Windows中打开文件的命令是`start`，因此就**将`JEKYLL_EDITOR`环境变量设为`start`**，此时文件成功打开并且没有报错，问题解决
