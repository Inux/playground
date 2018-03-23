#include <iostream>
#include <thread>
#include <list>
#include <algorithm>
#include <mutex>

class Cmd {
public:
    Cmd(std::string command, std::string path);
    ~Cmd() = default;
    std::string getCmd() const;
    std::string getPath() const;
    bool operator==(const Cmd& cmd2) const;

private:
    std::string command;
    std::string path;
};

Cmd::Cmd(std::string command, std::string path) : command(command), path(path) {};
std::string Cmd::getCmd() const { return this->command; };
std::string Cmd::getPath() const { return this->path; };
bool Cmd::operator==(const Cmd& cmd2) const {
  return (this->getCmd() == cmd2.getCmd() && this->getPath() == cmd2.getPath());
};

int main()
{
    auto list = new std::list<const Cmd>();

    Cmd x ("hello", "script.sh");
    Cmd y ("hello", "script.sh");

    list->push_back(x);
    std::cout << list->size() << std::endl;
    list->remove(y);
    std::cout << list->size() << std::endl;
}