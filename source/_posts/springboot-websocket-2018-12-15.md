---
title: springboot websocket使用
date: 2018-12-26 09:39:02
tags: websocket
categories: ["springboot","websocket","java"]
---


## 简介
使用springboot websocket过程整理


### 配置pom依赖
```xml
<!--配置springboot web项目-->
 <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

<!--配置springboot websocket-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>

```
### 配置config

```
 /**
     * 设置websocket bean
     * @return
     */
    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }

```

如果是由外部tomcat自己管理则不需要设置，如果是springboot，因为内置tomcat，所以需要设置


### websocket主类

```
@ServerEndpoint(value = "/webms/{user}")
@Component
public class Wstest {


    private final static Logger logger = LoggerFactory.getLogger(Wstest.class);

    private static AtomicLong count = new AtomicLong(0);

    private static CopyOnWriteArrayList onlineList = new CopyOnWriteArrayList();

    private static ConcurrentHashMap<String,Wstest> onLineMap =new ConcurrentHashMap();

   
    //与某个客户端的连接会话，需要通过它来给客户端发送数据
    private Session session;

    /**
     * 连接建立成功调用的方法
     */
    @OnOpen
    public void onOpen(@PathParam("user") String user, Session session) {
        this.session = session;
        onLineMap.put(user,this);
        count.incrementAndGet();      //在线数加1
        logger.info("有新连接加入！用户为："+user+"    当前在线人数为" + count.get());
    }


    /**
     * 连接关闭调用的方法
     */
    @OnClose
    public void onClose(@PathParam("user")  String user) {
        onLineMap.remove(user);
        count.decrementAndGet();           //在线数减1
        logger.info("有一连接关闭！用户为："+user+"    当前在线人数为" + count.get());
    }

    /**
     * 收到客户端消息后调用的方法
     *
     * @param message 客户端发送过来的消息
     */
    @OnMessage
    public void onMessage(String message, Session session) {
        System.out.println("来自客户端的消息:" + message);
    }

    /**
     * 发生错误时调用
     *
     * @OnError
     */
    public void onError(Session session, Throwable error) {
        System.out.println("发生错误");
        error.printStackTrace();
    }


    /**
     * 发送消息
     * @param message
     * @throws IOException
     */
    public void sendMessage(String message) throws IOException {
        this.session.getBasicRemote().sendText(message);
    }


    /**
     * 群体发送消息
     * @param message
     * @throws IOException
     */
    public void sendMessageToAll(String message) throws IOException {
        for (Map.Entry<String,Wstest> ws:onLineMap.entrySet()) {
            System.out.println("当前用户："+ws.getKey());
            ws.getValue().session.getBasicRemote().sendText(message);
        }
    }



    public static synchronized int getOnlineCount() {
        return (int) count.get();
    }


}
```

### 前台页面

index.html，内容如下

```
<html>
    <head>

    </head>
    <body>
    <title>WebSocket Echo Client</title>
    <h2>Websocket Echo Client</h2>
    <div id="output"></div>
    <script>
    // Initialize WebSocket connection and event handlers
    function setup() {
        output = document.getElementById("output");
        ws = new WebSocket("ws://localhost:8080/webms/hz");
        // Listen for the connection open event then call the sendMessage function
        ws.onopen = function(e) {
            log("Connected");
            sendMessage("这是发送的数据")
        }
        // Listen for the close connection event
        ws.onclose = function(e) {
            log("Disconnected: " + e.reason);
        }
        // Listen for connection errors
        ws.onerror = function(e) {
            log("Error ");
        }
        // Listen for new messages arriving at the client
        ws.onmessage = function(e) {
            log("Message received: " + e.data);
        // Close the socket once one message has arrived.
            //ws.close();
        }
    }
    // Send a message on the WebSocket.
    function sendMessage(msg){
        ws.send(msg);
        log("Message sent");
    }
    // Display logging information in the document.
    function log(s) {
        var p = document.createElement("p");
        p.style.wordWrap = "break-word";
        p.textContent = s;
        output.appendChild(p);
        // Also log information on the javascript console
        console.log(s);
    }
    // Start running the example.
    setup();
    </script>
</body>

</html>

```





