#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <array>

std::string getCmdOutput(const char* cmd) {
  std::array<char, 128> buffer;
  std::string result;
  std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
  if (!pipe) {
    std::cerr << "popen() failed!" << std::endl;
    exit(EXIT_FAILURE);
  }
  while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
    result += buffer.data();
  }
  return result;
}

int main() {
  const std::string result = getCmdOutput("fw_printenv --noheader cpuid");
  std::cout << result;
  return EXIT_SUCCESS;
}