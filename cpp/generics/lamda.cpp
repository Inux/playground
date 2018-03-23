#include <iostream>
#include <thread>
#include <list>
#include <algorithm>
#include <mutex>

auto lamda_fun = [](const auto & x){ std::cout << "Element is: " << x << std::endl; };
auto list = new std::list<int>{ 1,2,3,4,5,6,7,8,9 };

int main()
{
	std::for_each(list->begin(), list->end(), lamda_fun);

	return 0;
}