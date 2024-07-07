---
layout: post
title: JavaScript异步编程
categories:
- 前端
tags:
- JavaScript
- 前端
typora-root-url: ./
date: 2024-04-13 19:19 +0800
image:
  path: /assets/img/javascript/javascript.jpg
---
## Promise

Promise是ES6引入的异步解决方案，一个Promise对象表示一个异步操作，链式调用相关方法处理成功或失败结果

Promise有三个状态，完成和拒绝状态有相应的回调函数，指定多个回调时，所有回调都执行

-   等待（pending）：可以转换到完成和拒绝
-   完成（fulfilled）：到达该状态后不可修改
-   拒绝（rejected）：到达该状态后不可修改

### 创建和使用

-   `Promise()`：构造函数，传入一个回调函数表示异步操作
-   `then()`：包含两个回调函数参数，表示OnResolved和OnRejected，可以只传OnResolved

```js
const p = new Promise((resolve, reject) => {
    // async operation
    // 在成功时调用resolve(value)
    // 在失败时调用reject(err)
}).then(
    value => {
        // on fulfilled
        // then可以仅传入成功回调
    },
    reason => {
        // on rejected
    }
)
```

### then的返回值

在then方法的回调上可以返回一个值，then方法的返回值为Promise

-   返回非Promise值：then返回的Promise状态为resolved状态
-   返回Promise值：返回的Promise的状态就是then方法的状态
-   抛出异常：then返回的Promise状态为rejected状态

```js
const result = p.then(
    value => {
        // ...
    },
    reason => {
        // ...
    }
)
```

### 其他方法

-   catch方法：用于处理Promise的rejected状态
-   `Promise.all`：组合多个Promise，全部执行，当所有Promise执行成功时，返回成功状态，value是一个数组，包含各个Promise的value
-   `Promise.allSettled`：组合多个Promise，全部执行，只返回成功状态的Promise，value包含各个Promise的状态的value
-   `Promise.race`：传入多个Promise，取第一个改变状态的Promise作为返回的Promise

## async和await

async和await在ES8中引入，用于简化Promise编写

### async函数

使用async关键字声明，返回的任何值都包装为Promise对象

-   返回非Promise对象：返回一个成功的Promise
-   抛出异常：返回一个失败的Promise
-   返回Promise：返回的Promise的状态就是async返回的Promise的状态

```js
async function method() {
    // ...
}
```

### await语句

必须写在async函数中，后接一个表达式，表达式的结果一般为Promise对象

await的返回值为Promise成功的值，若失败则抛出异常，通过try-catch处理
