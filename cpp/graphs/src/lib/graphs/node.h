#ifndef _NODE_H_
#define _NODE_H_

#include <any>
#include <vector>
#include <functional>
#include <mutex>

typedef std::lock_guard<std::mutex> guard;

template<typename T>
class Node {

public:
    Node(std::function<T(T)> computation, std::vector<Node<T>*>& outputNodes);
    ~Node();

    void execute();
    T getValue();
    void setValue(T value);

private:
    T mValue;
    T mComputedValue;
    std::mutex mLock;

    std::function<T(T)> mComputation;
    std::vector<Node<T>*>& mOutputNodes;
};


// Implementation
#include "node.cpp"


#endif // _NODE_H_
