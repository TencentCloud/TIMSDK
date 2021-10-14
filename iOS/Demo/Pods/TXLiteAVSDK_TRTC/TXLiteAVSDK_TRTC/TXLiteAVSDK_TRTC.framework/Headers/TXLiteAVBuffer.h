

#ifndef TXLiteAVBuffer_h
#define TXLiteAVBuffer_h

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

namespace liteav {

/**
 * Buffer 数据类型
 */
class TXLiteAVBuffer {

public:
    virtual ~TXLiteAVBuffer() {}
    
    /**
     * 获取 buffer 的内存地址
     */
    virtual uint8_t * data() = 0;

    /**
     * 获取 buffer 的内存地址
     */
    virtual const uint8_t * cdata() const = 0;

    /**
     * 获取 buffer 的内存size
     */
    virtual size_t size() const = 0;
    
    /**
     * 设置 buffe 的有效数据 size
     * 如果此 size 超过当前 capacity，会造成重新分配内存，并复制数据
     */
    virtual void SetSize(size_t size) = 0;
    
    /**
     * 确保 buffer 分配的内存空间足够，不用多次分配拷贝内存。此方法会引起内存分配，data / cdata 方法获取的指针失效
     * @param capacity buffer 预分配的内存size
     */
    virtual void EnsureCapacity(size_t capacity) = 0;
};
}

#endif /* TXLiteAVBuffer_h */
