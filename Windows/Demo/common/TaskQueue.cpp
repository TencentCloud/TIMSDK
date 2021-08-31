#include "TaskQueue.h"

#include <assert.h>

TaskQueue::TaskQueue()
    : m_quit(false)
    , m_mutex()
    , m_condition()
    , m_queue()
    , m_thread(new std::thread(&TaskQueue::handle, this))
{

}

TaskQueue::~TaskQueue()
{

}

void TaskQueue::quit()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    m_quit = true;
    m_condition.notify_all();
}

void TaskQueue::wait()
{
    assert(true == m_quit && true == m_thread->joinable());
    m_thread->join();
}

void TaskQueue::post(std::function<void()> task)
{
    post(false, task);
}

void TaskQueue::post(bool mustExecute, std::function<void()> task)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (false == m_quit)
    {
        m_queue.push({ mustExecute, task });
        m_condition.notify_all();
    }
}

void TaskQueue::handle()
{
    while (true)
    {
        Task task;
        {
            std::unique_lock<std::mutex> lock(m_mutex);
            m_condition.wait(lock, [this]() {
                return (m_quit || false == m_queue.empty());
            });

            if (false == m_queue.empty())
            {
                task = m_queue.front();
                m_queue.pop();
            }
        }

        if ((false == m_quit || true == task.mustExecute) && task.executor)
        {
#if !defined(_DEBUG) && !defined(DEBUG)
            try
            {
                task.executor();
            }
            catch (const std::exception&)
            {

            }
#else
            task.executor();
#endif
        }

        {
            std::unique_lock<std::mutex> lock(m_mutex);
            if (true == m_quit && true == m_queue.empty())
            {
                break;
            }
        }
    }
}
