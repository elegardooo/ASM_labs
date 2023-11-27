#include <iostream>
using namespace std;

extern "C" void _cdecl func(float* arraay, float* result);

#define array_size 10

void print_array(float* array)
{
    for (int i = 0; i < array_size; i++)
    {
        cout << array[i] << " ";
    }
}

int main()
{
    float array[array_size];
    float result[array_size];
    for (int i = 0; i < array_size; i++)
    {
        cout << "Enter the " << i + 1 << " element of array: ";
        cin >> array[i];
    }
    func(array, result);
    print_array(array);
    cout << "Sin for the elements of array:" << endl;
    print_array(result);
}
