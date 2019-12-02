---
authors:
- admin
categories: [Python]
date: "2019-12-01T00:00:00Z"
draft: false
featured: true
image:
  caption: ""
  focal_point: ""
projects: []
subtitle: Learn how to blog in Academic using Jupyter notebooks
summary: Learn how to blog in Academic using Jupyter notebooks
tags: []
title: Python数据的导入和输出总结
---

对python的数据导入和输出进行总结.

# CSV文件
## 使用python基础语法
python内置函数`open()`可以用来打开csv文件并进行处理.


```python
import os as os
```


```python
os.getcwd()
```




    'D:\\my github\\shen\\content\\en\\post\\2019-12-01-python-data-import-output'




```python
file = open("example.csv")
file
type(file)
```




    _io.TextIOWrapper




```python
file.encoding
file.read
```




    <function TextIOWrapper.read(size=-1, /)>


