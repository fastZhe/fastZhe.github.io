## 关于netty的编解码

关于netty的编解码学习，一般涉及到数据的出站与入站，在出站时调用编码、在入站时调用解码，编解码都是成对出现，不能出现只有一个。

### netty的编解码类别

netty的编解码类别主要分为以下三种

* ByteToMessage 入站解码
* MessageToByte 出站编码
* MessageToMessage  出站入站均可（编解码）

* 解码继承：ByteToMessageDecoder,该类继承ChannelInboundHandlerAdapter   该类为进站处理
* 编码继承：MessageToByteEncoder，该类继承ChannelOutboundHandlerAdapter  该类为出站处理

## 例子实现编解码用一个组合handler来表示编解码（前两种）

```
例如：
package com.bj.hz.dzj;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelDuplexHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.channel.CombinedChannelDuplexHandler;
import io.netty.handler.codec.ByteToMessageDecoder;
import io.netty.handler.codec.MessageToByteEncoder;
import java.util.List;

public class MyCodec extends CombinedChannelDuplexHandler {

    public MyCodec(){
        super(new Mydecode(),new Myencode());
    }

}

class Mydecode extends ByteToMessageDecoder{


    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf, List<Object> list) throws Exception {
        //这种是需要判断字节数组的容量是否足够解码，请参考最后使用ReplayingDecoder
        if (byteBuf.readableBytes()>4){
            list.add(byteBuf.readInt());
        }
    }
}

class Myencode extends MessageToByteEncoder<Integer>{

    @Override
    protected void encode(ChannelHandlerContext channelHandlerContext, Integer integer, ByteBuf byteBuf) throws Exception {
        byteBuf.writeInt(integer);
    }
}

```



### 使用codec可以统一编解码（前两种）
* 使用codec 实现编解码一体

```
package com.bj.hz.dzj;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ByteToMessageCodec;
import java.util.List;

public class Mycodec1 extends ByteToMessageCodec<Integer> {

    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf, List list) throws Exception {
        if (byteBuf.readableBytes()>4){
            list.add(byteBuf.readInt());
        }
    }

    @Override
    protected void encode(ChannelHandlerContext channelHandlerContext, Integer integer, ByteBuf byteBuf) throws Exception {
        byteBuf.writeInt(integer);
    }
}
```

### 使用codec实现第三种
该类型主要实现编码中协议（例如api等）转换

```
public class MyMessagetoMessage extends MessageToMessageCodec<Integer,String> {
    @Override
    protected void encode(ChannelHandlerContext channelHandlerContext, String s, List<Object> list) throws Exception {
        list.add(Integer.parseInt(s));
    }

    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, Integer integer, List<Object> list) throws Exception {
        list.add(String.valueOf(integer));
    }
}
```

### 使用ReplayingDecoder,来实现自动转换，当bytebuf中没有能够转换的足够字节，则会一直等待足够才会转换

```
package com.bj.hz.dzj;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ReplayingDecoder;
import java.util.List;

public class MyreplyingDecoder extends ReplayingDecoder<Integer> {
    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf, List<Object> list) throws Exception {
        list.add(byteBuf.readInt());
    }
}
```

