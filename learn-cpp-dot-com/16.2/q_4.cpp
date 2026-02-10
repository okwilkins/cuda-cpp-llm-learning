#include <iostream>
#include <vector>

int main() {
    std::cout << "Enter 3 integers: ";

    std::vector<int> nums(3);
    std::cin >> nums[0] >> nums[1] >> nums[2];

    std::cout << "The sum is: " << (nums[0] + nums[1] + nums[2]) << '\n';
    std::cout << "The product is: " << (nums[0] * nums[1] * nums[2]) << '\n';

    return 0;
}
