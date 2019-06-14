#include "node.h"

#include <iostream>
#include <vector>
#include "gtest/gtest.h"

TEST(graph, single_node)
{
    auto doubleIt = [](int val) -> int {
        return val * 2;
    };

    auto outputNodes = new std::vector<Node<int>*>();


    auto node = new Node<int>(doubleIt, *outputNodes);
    node->setValue(21);
    node->execute();

    EXPECT_EQ(node->getValue(), 42) << "Node value is not equal is: " << node->getValue() << " not: 42";
}

TEST(graph, multiple_nodes)
{
    auto doubleIt = [](int val) -> int {
        return val * 2;
    };

    auto outputNodesEmpty = new std::vector<Node<int>*>();
    auto outputNode1 = new Node<int>(doubleIt, *outputNodesEmpty);

    auto outputNodes = new std::vector<Node<int>*>();
    outputNodes->push_back(outputNode1);

    auto node = new Node<int>(doubleIt, *outputNodes);
    node->setValue(21);
    node->execute();

    EXPECT_EQ(node->getValue(), 42) << "Node value is not equal is: " << node->getValue() << " not: 42";
    EXPECT_EQ(outputNode1->getValue(), 84)  << "Node value is not equal is: " << outputNode1->getValue() << " not: 84";
}

TEST(graph, two_nodes_with_same_out_node)
{
    auto doubleIt = [](int val) -> int {
        return val * 2;
    };

    auto outputNodesEmpty = new std::vector<Node<int>*>();
    auto outputNode1 = new Node<int>(doubleIt, *outputNodesEmpty);

    auto outputNodes = new std::vector<Node<int>*>();
    outputNodes->push_back(outputNode1);

    auto node1 = new Node<int>(doubleIt, *outputNodes);
    auto node2 = new Node<int>(doubleIt, *outputNodes);

    node1->setValue(21);
    node1->execute();

    node2->setValue(21);
    node2->execute();

    EXPECT_EQ(node1->getValue(), 42);
    EXPECT_EQ(node2->getValue(), 42);
    EXPECT_EQ(outputNode1->getValue(), 168);
}