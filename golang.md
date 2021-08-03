## Golang语言笔记

### 特点

- 语法简洁
- 开发效率高
- 自带format（程序通用性强）
- 静态编译性语言，执行效率与Java相似

- 天生支持并发，可以很好支持游戏后台服务端

  

被誉为21世纪C语言，可以是真正的企业级编程语言（Java，Go）

### 发展现状
百度内部流量入口，自动驾驶
腾讯蓝鲸，云平台
知乎语言重构（python->Go），节约80%资源
蚂蚁金服
英语流利说
字节
grab



**在 2020年 成为一名 [Go](https://golang.org/) 开发者的路线图：**

在下边有一个路线图，如果你想要成为一名Go语言的开发者的话，你可以沿着这张图里面的路径去学习，里面记录了一些你可能也想学习的库。当你问到：”我想成为一名Go语言开发者，接下来我要学些什么？“，我做的这个路线图就是一个很好的建议。



## 资源

1. 先决条件

   - [Go](https://golangbot.com/)
   - [SQL](https://www.w3schools.com/sql/default.asp)
2. 通用开发技能

   - 学习GIT，在GitHub上建立一些仓库，与其它人分享你的代码
   - 了解 HTTP(S) 协议，request 方法（GET, POST, PUT, PATCH, DELETE, OPTIONS）
   - 不要害怕使用Google，[Google 搜索的力量](http://www.powersearchingwithgoogle.com/)
   - 看一些和数据结构以及算法有关的书籍
   - 学习关于认证的基础实现
   - 面向对象原则等等
3. 命令行工具
   1. [cobra](https://github.com/spf13/cobra)
   2. [urfave/cli](https://github.com/urfave/cli)
4. 网页框架 + 路由

   1. [Echo](https://github.com/labstack/echo)
   2. [Beego](https://github.com/astaxie/beego)
   3. [Gin](https://github.com/gin-gonic/gin)
   4. [Revel](https://github.com/revel/revel)
   5. [Chi](https://github.com/go-chi/chi)
5. 数据库

   1. 关系型
      - [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2017)
      - [PostgreSQL](https://www.postgresql.org/)
      - [MariaDB](https://mariadb.org/)
      - [MySQL](https://www.mysql.com/)
      - [CockroachDB](https://www.cockroachlabs.com/)
   2. 云数据库
      - [CosmosDB](https://docs.microsoft.com/en-us/azure/cosmos-db)
      - [DynamoDB](https://aws.amazon.com/dynamodb/)
   3. 搜索引擎
      - [ElasticSearch](https://www.elastic.co/)
      - [Solr](http://lucene.apache.org/solr/)
      - [Sphinx](http://sphinxsearch.com/)
   4. NoSQL
      - [MongoDB](https://www.mongodb.com/)
      - [Redis](https://redis.io/)
      - [Apache Cassandra](http://cassandra.apache.org/)
      - [RavenDB](https://github.com/ravendb/ravendb)
      - [CouchDB](http://couchdb.apache.org/)
6. 对象关系映射框架

   1. [Gorm](https://github.com/jinzhu/gorm)
   2. [Xorm](https://github.com/go-xorm/xorm)
7. 高速缓存

   1. [GCache](https://github.com/bluele/gcache)
   2. 分布式缓存
      - [Go-Redis](https://github.com/go-redis/redis)
      - [GoMemcached](https://github.com/bradfitz/gomemcache)
8. 日志

   1. 日志框架
      - [Zap](https://github.com/uber-go/zap)
      - [ZeroLog](https://github.com/rs/zerolog)
      - [Logrus](https://github.com/sirupsen/logrus)
   2. 日志管理系统
      - [Sentry.io](http://sentry.io)
      - [Loggly.com](https://loggly.com)
   3. 分布式追踪
      - [Jaeger](https://www.jaegertracing.io/)
9. 实时通信
   1. [Socket.IO](https://socket.io/)
10. API 客户端

    1. REST
       - [Gentleman](https://github.com/h2non/gentleman)
       - [GRequests](https://github.com/kennethreitz/grequests)
       - [heimdall](https://github.com/heimdal/heimdal)
    2. [GraphQL](https://graphql.org/)
       - [gqlgen](https://github.com/99designs/gqlgen)
       - [graphql-go](https://github.com/graph-gophers/graphql-go)
11. 最好知道

    - [Validator](https://github.com/chriso/validator.js/)
    - [Glow](https://github.com/pytorch/glow)
    - [GJson](https://github.com/tidwall/gjson)
    - [Authboss](https://github.com/volatiletech/authboss)
    - [Go-Underscore](https://github.com/ahl5esoft/golang-underscore)
12. 测试

    1. 单元、行为和集成测试
       1. [GoMock](https://github.com/golang/mock)
       2. [Testify](https://github.com/stretchr/testify)
       3. [GinkGo](https://github.com/onsi/ginkgo)
       4. [GoMega](https://github.com/onsi/gomega)
       5. [GoCheck](https://github.com/go-check/check)
       6. [GoDog](https://github.com/DATA-DOG/godog)
       7. [GoConvey](https://github.com/smartystreets/goconvey)
    2. 端对端测试
       - [Selenium](https://github.com/tebeka/selenium)
       - [Endly](https://github.com/viant/endly)
13. 任务调度

    - [Gron](https://github.com/roylee0704/gron)
    - [JobRunner](https://github.com/bamzi/jobrunner)
14. 微服务

    1. 消息代理
       - [RabbitMQ](https://www.rabbitmq.com/tutorials/tutorial-one-go.html)
       - [Apache Kafka](https://kafka.apache.org/)
       - [ActiveMQ](https://github.com/apache/activemq)
       - [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview)
    2. 构建事件驱动型服务
       - [Watermill](https://github.com/ThreeDotsLabs/watermill)
       - [Message-Bus](https://github.com/vardius/message-bus)
    3. 框架
       - [GoKit](https://github.com/go-kit/kit)
       - [Micro](https://github.com/micro/go-micro)
       - [rpcx](https://github.com/smallnest/rpcx)
    4. RPC
       - [Protocol Buffers](https://github.com/protocolbuffers/protobuf)
       - [gRPC-Go](https://github.com/grpc/grpc-go)
       - [gRPC-Gateway](https://github.com/grpc-ecosystem/grpc-gateway)
       - [Twirp](https://github.com/twitchtv/twirp)
15. [Go-模式](https://github.com/tmrts/go-patterns)



## Go入门手册

更多请参考[李文周的博客](https://www.liwenzhou.com/categories/Golang/)

### 前置准备

安装开发包

#### 配置GOPATH（WIN）

1. 新建一个目录`D:go`（存放编写的go语言代码）
2. 在环境变量里，新建一项：`GOPATH:D:\go`
3. 在`D:go`下新建三个文件夹，分别是bin（二进制可执行文件）、src（源文件）、pkg（中间编译文件）
4. 把`D:\go\bin;`添加到path（用户变量）中
5. 自己电脑中有GOPATH有默认值，通常是`%USERPROFILE%/go`，把这一项删掉，按照上面步骤重新建立。



### Go项目结构

在进行Go语言开发的时候，代码总是会保存在`#GOPATH/src`目录下。在工程经过`go build`、`go install`或`go get`等指令后，会将下载的第三方包源代码文件放在`GOPATH/src`目录下，产生的二进制可执行文件放在`$GOPATH/bin`目录下，生成的中间缓存文件会被保存在`$GOPATH/pkg`下。

如果我们使用版本管理工具（version control system，VCS，如Git）来控制我们的项目代码时，我们只需要添加`GOPATH/src`目录的源代码即可。`bin`和`pkg`目录的内容无需版本控制。

#### 适合个人开发者

可以按照下面的方式组织代码。

```mermaid
graph LR
A[GOPATH] --> B[bin]
A --> C[pkg]
A --> D[src]
	D --> E[项目一]
	D --> F[项目二]
	D --> G[项目三]
		F --> a[模块1]
		F --> b[模块2]
		F --> c[模块3]
```

#### 目前流行的结构项目

```mermaid
graph LR
A[GOPATH] --> B[bin]
A --> C[pkg]
A --> D[src 网站域名]
	D --> E[golang.org]
	D --> F[github.com]
	D --> G[gopkg.in]
		F --> a[作者/机构]
			a --> x[项目一]
			a --> y[项目二]
			a --> z[项目三]
			  y --> aa[模块]
```

#### 适合企业开发者

上层假设公司代码仓库域名code.xx.com

```mermaid
graph LR
A[code.xx.com] --> A1[前端组]
A --> A2[后端组]
A --> A3[基础架构组]
	A2 --> B1[项目一]
	A2 --> B2[项目二]
	A2 --> B3[项目三]
		B2 --> C1[模块一]
		B2 --> C2[模块二]
		B3 --> C3[模块三]
```

### 编写编译程序

在`src`下编写hello/main.go

```go
package main  // 声明 main 包，表明当前是一个可执行程序

import "fmt"  // 导入内置 fmt 包

func main(){  // main函数，是程序执行的入口
	fmt.Println("Hello World!")  // 在终端打印 Hello World!
}
```

#### 编译go build

`go build`表示将源代码编译成可执行文件

1. 在hello目录下执行`go build`，会在当前目录下生成hello.exe，如果执行`go install`，会在`bin`目录下生成exe文件

2. 在其他目录执行 `go build`，需要在后面加上项目的路径（从`GOPATH/src`后开始写起，编译之后的可执行文件保存在当前目录下）

3. 可以用`-o`参数来指定编译后得到的可执行文件的名字

   `go build -o heiheihei.exe`

#### go run

`go run main.go` 像执行脚本文件一样执行Go代码

#### go install

`go install`分为两步：

1. 先编译得到一个可执行文件
2. 将可执行文件拷贝到bin下

