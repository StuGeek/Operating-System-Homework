# 操作系统实验报告1

## 实验内容

+ 阅读 uCore 实验项目开始文档 (uCore Lab 0)，准备实验平台，熟悉实验工具。

+ uCore Lab 1：系统软件启动过程
(1) 编译运行 uCore Lab 1 的工程代码；
(2) 完成 uCore Lab 1 练习 1-4 的实验报告；
(3) 尝试实现 uCore Lab 1 练习 5-6 的编程作业；
(4) 思考如何实现 uCore Lab 1 扩展练习 1-2。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## uCore Lab 1 练习 1-4 实验报告

### lab1 练习 1：理解通过 make 生成执行文件的过程

列出本实验各练习中对应的 OS 原理的知识点，并说明本实验中的实现部分如何对应和体现了原理中的基本概念和关键知识点。

在此练习中，大家需要通过静态分析代码来了解：

操作系统镜像文件 ucore.img 是如何一步一步生成的？(需要比较详细地解释 Makefile 中每一条相关命令和命令参数的含义，以及说明命令导致的结果)

首先找到makefile文件中注释为```create ucore.img```这一部分的内容：

    # create ucore.img
    UCOREIMG    := $(call totarget,ucore.img)

    $(UCOREIMG): $(kernel) $(bootblock)
        $(V)dd if=/dev/zero of=$@ count=10000
        $(V)dd if=$(bootblock) of=$@ conv=notrunc
        $(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc

    $(call create_target,ucore.img)

第一行的```UCOREIMG    := $(call totarget,ucore.img)```，```UCOREIMG```表示生成ucore.img文件

一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？