---
layout: post
title: Selenium基础
categories:
- Python
- 爬虫
tags:
- Python
- 爬虫
- Selenium
---

## 开始

Selenium是一个用于自动化Web浏览器操作的工具，广泛应用于Web应用程序测试、网页数据抓取和任务自动化等场景

Selenium通过使用WebDriver支持市场上所有主流浏览器的自动化。WebDriver是一个API和协议，它定义了一个语言中立的接口，用于控制web浏览器的行为。每个浏览器都有一个特定的WebDriver实现，称为驱动程序。驱动程序是负责委派给浏览器的组件，并处理与Selenium和浏览器之间的通信

安装selenium

```
pip install selenium
```

使用npm安装ChromeDriver或EdgeDriver

```
npm i -g chromedriver
npm i -g edgedriver
```

使用selenium完成浏览器启动和关闭

```python
from selenium import webdriver
import time

driver = webdriver.Edge()
driver.get('https://www.baidu.com')
time.sleep(5)
driver.close()
```

