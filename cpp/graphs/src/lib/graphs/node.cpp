#ifndef _NODE_CPP_
#define _NODE_CPP_

#include "node.h"


typedef std::lock_guard<std::mutex> guard;

template<typename T>
Node<T>::Node(std::function<T(T)> computation,
        std::vector<Node<T>*>& outputNodes)
    : mValue(),
      mComputedValue(),
      mLock(std::mutex{}),
      mComputation(computation),
      mOutputNodes(outputNodes) {
}

template<typename T>
Node<T>::~Node() {
}

template<typename T>
void Node<T>::execute() {
    guard lockGuard(mLock);

    mComputedValue += mComputation(mValue);
    for(auto&& n : mOutputNodes) {
        n->setValue(mComputedValue);
        n->execute();
    }
}

template<typename T>
T Node<T>::getValue() {
    guard lockGuard(mLock);

    return mComputedValue;
}

template<typename T>
void Node<T>::setValue(T value) {
    guard lockGuard(mLock);

    mValue = value;
}


#endif // _NODE_CPP_
