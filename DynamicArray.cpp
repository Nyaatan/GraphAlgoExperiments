#include <iostream>
#include <stdexcept>

using namespace std;

class DynamicArray{

public:
    int* array;  // pointer at first element of the array
    int size = 0;
    DynamicArray(int n){
        array = new int[n];  // allocate memory equivalent of n ints
    }

    DynamicArray(){
        array = new int[32];
    }

    ~DynamicArray(){
        delete [] array;
    }
    void add_back(int a){  // adds value at the end of the array
        ++size;
        int* temparray = new int[size];  // allocate memory for bigger array
        for(int i=0; i<size;++i) temparray[i] = array[i];  // copy elements to new array
        temparray[size-1] = a;  // add new element at back
        array = temparray;  // overwrite pointer
    }

    void add_front(int a){  // adds value at the front of the array
        ++size;
        int* temparray = new int[size];  // allocate memory for bigger array
        for(int i=1; i<size;++i) temparray[i] = array[i];  // copy elements to new array starting at index 1
        temparray[0] = a;  // add new element at front
        array = temparray;  // overwrite pointer
    }
    void add(int val, int j){  // adds value at given index
        ++size;
        int* temparray = new int[size];  // allocate memory for bigger array
        int a_was_there = 0;  // a value that states that we added (1) or haven't added the value yet (0)
        for(int i=0; i<size;++i) {
                if(i == j) {
                    ++a_was_there;
                    temparray[i] = val;
                }
                else temparray[i] = array[i-a_was_there];
        }
        array = temparray;
    }
    int get(int i){ // returns value at given index
        if(i>=size) throw underflow_error("Index out of bounds.");
        return array[i];
    }
    int pop_front(){  // removes value from the beginning of the array
        if(size == 0) throw underflow_error("Array empty");
        size--;
        int val = array[0];
        int* temparray = new int[size];
        for(int i=1;i<=size;++i){
            temparray[i-1] = array[i];
        }
        array = temparray;
        return val;
    }
    int pop_back(){  // removes value from the end of the array
        if(size == 0) throw underflow_error("Array empty");
        size--;
        int val = array[size];
        int* temparray = new int[size];
        for(int i=0;i<size;++i){
            temparray[i] = array[i];
        }
        array = temparray;
        return val;
    }
    int remove(int j){  // removes value at given index
        if(j>=size) throw underflow_error("Index out of bounds");
        size--;
        int val, val_was_there=0;
        int* temparray = new int[size];
        for(int i=0;i<=size;++i){
            if(i==j) {
                ++val_was_there;
                val = array[i];
            }
            else temparray[i-val_was_there] = array[i];
        }
        array = temparray;
        return val;
    }

    void replace(int val, int i){  // overwrites value at given index
        if(i>=size) throw underflow_error("Index out of bounds");
        array[i] = val;
    }

    void swap(int i, int j){  // switches values of given indexes
        if(i>=size || j>=size) throw underflow_error("Index out of bounds");
        int temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }

    void print(){  // prints array at stdout
        cout << '[';
        for(int i=0;i<size-1;++i) cout << array[i] << ", ";
        if (size != 0) cout << array[size-1];
        cout << ']' << endl;
    }

    void append(DynamicArray _array){  // appends a DynamicArray to this array
        int prev_size = size;
        size += _array.size;
        int* temparray = new int[size];
        int i=0;
        for(i;i<prev_size;++i) temparray[i] = array[i];
        for(i; i<size; ++i) temparray[i+prev_size] = _array.get(i);
    }

    int find(int j){  // returns index of given value
        for (int i=0;i<size;++i){
            if(array[i]==j) return i;
        }
        throw underflow_error("Index out of bounds");
    }

    void clear(){
        array = new int[0];
        size = 0;
    }
};


