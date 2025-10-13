#include <stdio.h> // standart input/ouput6 header file

// & address of operator 
// * dereference operator

int main() {
    int x = 10;
    int* ptr = &x;
    printf("Adress of x: %p\n", ptr);    // output memory address of x
    printf("Value of x: %d\n", *ptr);    // output: 10
}