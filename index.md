# AI roll resolver

### 下载

[`dhdj_roll_resolver_v2.lua`](dhdj_roll_resolver_v2.lua)

默认服务器为国内代理服务器，比较卡但相对稳定

12/27更新: 所有付费甚至免费服务器均已完成大脑升级并负载均衡，可多承载五倍的人数

### 免费服务器列表

| 名称 | 地址 | 地区 |
| --- | --- | --- |
| 国内代理服务器（理论最大120人，实际上超过10个人就会被分配到慢速节点） | ws://ws.resolver.moeyy.cn | 中国 |
| cf代理服务器（最大20人） | ws://ws.resolver.dhdj.io:8080 | 全球 |

#### 为什么我无法使用

免费服务器可能会因不可抗力 (在线用户爆满, 到期, ddos) 而无法连接 付费服务器请联系QQ 1044566663 或 2658563338 (其他QQ号均为骗子)

#### 为什么需要使用付费服务器

免费服务器可能会带来比较高的延迟，解析jitter可能比较费劲

#### 付费服务器是谁的

付费服务器(至少目前)都是由喵内提供的，其中50%会进入dhdj的腰包

#### 付费服务器不会被ddos吗

付费服务器都是每个用户独立专用的，不会与其他用户共享，自然也就不会被ddos

#### 为什么有人卖付费的加密的lua啊

圈狗来的

### 如何更改服务器

更改第54行 `HOST_ADDR = "服务器地址"`

### 工作原理

1. MELCHIOR_1 (Deep learning AI) 根据 `animstate`/`animlayer` 16个tick的历史来决定roll的角度
2. BALTHASAR_2 (Freestanding) 根据敌人的位置决定roll角度
3. CASPER_3 (Desync) 根据sk解析到的敌人desync角度来决定roll角度以及限制最大roll角度
4. majority_vote() 最终角度 = 多数赞成的角度

### 好用吗

爱用不用

### 源码发我

不发

### 如何编写我自己的`animstate`/`animlayer`解析服务器
begin with something like this:
```python
async def resolve_handle_request(websocket, path):
    while True:
        data = await websocket.recv()
        data = json.loads(data)
        # implement the protocol
        # implement your resolve logic
        msg_arr = {"tick":data['tick'], "0": 0}
        # return the roll angles for each player and current tick count
        await websocket.send(json.dumps(msg))
```
