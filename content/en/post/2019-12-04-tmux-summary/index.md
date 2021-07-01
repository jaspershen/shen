---
authors:
- admin
categories: [Linux]
date: "2019-12-04T00:00:00Z"
draft: false
featured: true
image:
  caption: ""
  focal_point: ""
projects: []
subtitle: Learn how to use tmux
summary: Learn how to use tmux
tags: []
title: Tmux summary
---

{{% toc %}}


完整的tmux请参考下面的帖子:

http://louiszhai.github.io/2017/09/30/tmux/

# Tmux简洁

tmux是一款优秀的终端复用软件，主要得益于以下三处功能：

* 丝滑分屏（split），虽然iTem2也提供了横向和竖向分屏功能，但这种分屏功能非常拙劣，完全等同于屏幕新开一个窗口，新开的pane不会自动进入到当前目录，也没有记住当前登录状态。这意味着如果我ssh进入到远程服务器时，iTem2新开的pane中，我依然要重新走一遍ssh登录的老路（omg）。tmux就不会这样，tmux窗口中，新开的pane，默认进入到之前的路径，如果是ssh连接，登录状态也依旧保持着，如此一来，我就可以随意的增删pane，这种灵活性，好处不言而喻。

* 保护现场（attach），即使命令行的工作只进行到一半，关闭终端后还可以重新进入到操作现场，继续工作。对于ssh远程连接而言，即使网络不稳定也没有关系，掉线后重新连接，可以直奔现场，之前运行中的任务，依旧在跑，就好像从来没有离开过一样；特别是在远程服务器上运行耗时的任务，tmux可以帮你一直保持住会话。如此一来，你就可以随时随地放心地进行移动办公，只要你附近的计算机装有tmux（没有你也可以花几分钟装一个），你就能继续刚才的工作。

* 会话共享（适用于结对编程或远程教学），将 tmux 会话的地址分享给他人，这样他们就可以通过 SSH 接入该会话。如果你要给同事演示远程服务器的操作，他不必直勾勾地盯着你的屏幕，借助tmux，他完全可以进入到你的会话，然后静静地看着他桌面上你风骚的键盘走位，只要他愿意，甚至还可以录个屏。

# Tmux快捷键

## 启动新对话

```
tmux [new -s 会话名 -n 窗口名]
```
比如创建一个新的会话:

```
tmux new -s new_session
```

## 列出所有的对话

```
tmux ls
```
## 进入某个会话

```
tmux a -t session
```

## 关闭某个会话

```
tmux kill-session -t 会话名
```

## 关闭所有会话

```
tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1)}' | xargs kill
```

## 在 Tmux 中，按下 Tmux前缀ctrl+b(mac下未command+b)，然后再点击某个按键,即可进行某些操作

### 退出某个会话

先同时按下command+b,然后按d(detach的意思)

### 会话

```
:new<回车>  启动新会话
s           列出所有会话
$           重命名当前会话
```

### 窗口 (标签页)

```
c  创建新窗口
w  列出所有窗口
n  后一个窗口
p  前一个窗口
f  查找窗口
,  重命名当前窗口
&  关闭当前窗口
```

