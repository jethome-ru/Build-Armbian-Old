#include <cstdlib>

#include "get_efuse_raw_key.h"

int main (/*int argc, char *argv[]*/) {
  auto mac = getKey("mac");
  if (mac.size() == 6) {
    for (auto it = mac.begin(); it != mac.end(); ++it) {
      std::cout << std::hex << static_cast<int>(*it);
      if (it < mac.end() - 1) {
        std::cout << ":";
      }
    }
    std::cout << std::endl;
  }
  
  return EXIT_SUCCESS;
}
