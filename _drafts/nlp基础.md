---
layout: post
title: NLP基础
categories:
- Python
- NLP
tags:
- Python
- NLP
typora-root-url: ./..
math: true
---

## 开始

自然语言处理的六种模型

-   语音-文字：语音识别
-   文字-语音：语音合成
-   语音-语音：语音分离、声音转换
-   文字-文字：机器翻译、问答
-   语音-类别：关键词识别、语者识别
-   文字-类别

<img src="/assets/img/nlp基础/image-20240630193601004.png" alt="image-20240630193601004" style="zoom: 50%;" />

## 语音识别



对于语音识别系统，输入的声音被表示成多个向量，输出的文字表示成一串token

token有两种类型

-   phoneme：语音中具有语义的最小单位称为音素（phoneme），将语音转换成音素后，通过词典（lexicon）映射到词语
-   grapheme：书写系统中的最小单位称为字素（grapheme）
-   word：词语
-   morpheme：词素，词语中具有意义的最小单位

语音处理

-   filter bank output
-   MFCC
-   spectrogram
-   waveform

## LAS模型

LAS全称为Listen,Attend and Spell，分为Listen，Attend和Spell三步，Listen相当于Encoder，Spell相当于Decoder

### Listen

Listen部分输入一串语音向量，输出一串长度相同的向量，目标是提取内容特征，去除语者差异和噪声

Listen部分常用的模型有RNN，1-D CNN，Self Attention

下采样：输入的语音向量通常非常长，而相邻的语音特征差异较小，因此为了减小计算量，可以输出长度较短的向量，常用的模型有Pyramid RNN，Pooling over time，TDNN，Truncated Self-Attention

<img src="/assets/img/nlp基础/image-20240701102912970.png" alt="image-20240701102912970" style="zoom:67%;" />

TDNN在一定范围内只考虑首尾两个向量，Truncated Self-Attention考虑一定范围内的向量，超过该范围就不考虑

<img src="/assets/img/nlp基础/image-20240701103252119.png" alt="image-20240701103252119" style="zoom:67%;" />

### Attend

Attend部分使用一个$z_0$向量，与每个Listen的输出匹配

<img src="/assets/img/nlp基础/image-20240701103818751.png" alt="image-20240701103818751" style="zoom: 50%;" />

匹配的具体方式有Dot-product Attention，Additive Attention

Dot-product Attention将h和z向量经过线性层$W^h$和$W^z$，得到两个向量，再将两个向量点乘

<img src="/assets/img/nlp基础/image-20240701104022757.png" alt="image-20240701104022757" style="zoom:50%;" />

Additive Attention将h和z向量经过线性层后相加，得到一个向量，经过$tanh$激活后，再经过一个线性层

<img src="/assets/img/nlp基础/image-20240701104201270.png" alt="image-20240701104201270" style="zoom:50%;" />

得到一串$\alpha$向量后，经过一个Softmax，得到$\hat\alpha$，将$\hat\alpha$向量与h向量进行点乘，得到$c^0$，$c^0$称为Context Vector

<img src="/assets/img/nlp基础/image-20240701105407851.png" alt="image-20240701105407851" style="zoom:50%;" />

### Spell

Spell部分通常使用RNN

<img src="/assets/img/nlp基础/image-20240701110504501.png" alt="image-20240701110504501" style="zoom:50%;" />

### Beam Search

在Spell输出token时，每次都选择概率最大的一个输出，称为Greedy Decoding，可能会导致陷入局部极小

使用Beam Search，每次保留B个最好的结果

<img src="/assets/img/nlp基础/image-20240701121015771.png" alt="image-20240701121015771" style="zoom:50%;" />

## CTC模型

CTC模型中只有一个Encoder，经过Encoder后输入到Classifier输出token，可以实现在线学习

由于每次输入的特征，信息量通常很小，因此CTC引入了null作为token，每次输入一个特征，若无法识别则输出null，最终输出是一串包含null的token，此时将重复的token合并，再去除null得到最终的输出

<img src="/assets/img/nlp基础/image-20240701134634415.png" alt="image-20240701134634415" style="zoom:50%;" />

对齐问题

在训练时输入的标签中不包含null，而模型直接输出中包含null，此时无法得知null应该位于输出向量的哪个位置

## RNN-T

对一个Encoder输出特征，输入到RNN中输出多个token，直到输出null，之后再输入下一个特征

<img src="/assets/img/nlp基础/image-20240701140029796.png" alt="image-20240701140029796" style="zoom:50%;" />
