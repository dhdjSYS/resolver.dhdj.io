# AI roll resolver

### 下载

[`dhdj_roll_resolver_v2.lua`](dhdj_roll_resolver_v2.lua)

默认服务器为dhdj的公益服务器，人多了可能会死机

### 免费服务器列表

| 名称 | 地址 | 地区 |
| --- | --- | --- |
| dhdj的中国服务器 | ws://43.138.147.94:1741 | 广州 |
| dhdj的日本服务器 | ws://139.180.196.149:1741 | 日本 |
| 仓鼠的公益服务器 | ws://43.155.186.120:1741 | 韩国 |

#### 为什么我无法使用

免费服务器可能会因不可抗力 (在线用户爆满, 到期, ddos) 而无法连接 付费服务器请联系QQ 1044566663 或 2658563338

#### 为什么需要使用付费服务器

免费服务器可能会带来比较高的延迟，解析jitter可能比较费劲

#### 付费服务器是谁的

付费服务器(至少目前)都是由喵内提供的，其中50%会进入dhdj的腰包

#### 为什么有人卖付费的加密的lua啊

圈狗来的

### 如何更改服务器

更改第54行 `HOST_ADDR = "服务器地址"`

### 工作原理

1. MELCHIOR_1 (Deep learning AI) 根据 `animstate`/`animlayer` 16个tick的历史来决定roll的角度
2. BALTHASAR_2 (Freestanding) 根据敌人的位置决定roll角度
3. CASPER_3 (Desync) 根据sk解析到的敌人desync角度来决定roll角度以及限制最大roll角度
4. majority_vote() 最终角度 = 多数赞成的角度
