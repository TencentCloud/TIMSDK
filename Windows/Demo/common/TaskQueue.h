#ifndef __TASKQUEUE_H__
#define __TASKQUEUE_H__

#include <thread>
#include <mutex>
#include <functional>
#include <queue>

struct Task
{
    bool mustExecute;   // 结束任务队列时，是否执行完毕
    std::function<void()> executor;
};

class TaskQueue
{
public:
    TaskQueue();
    virtual ~TaskQueue();

    void quit();
    void wait();
    void post(std::function<void()> task);
    void post(bool mustExecute, std::function<void()> task);
private:
    void handle();
private:
    volatile bool m_quit;
    std::mutex m_mutex;
    std::condition_variable m_condition;
    std::queue<Task> m_queue;
    std::unique_ptr<std::thread> m_thread;
};

#endif /* __TASKQUEUE_H__ */
