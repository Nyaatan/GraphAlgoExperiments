cdef extern from "DynamicArray.cpp":
    cppclass DynamicArray:
        int* array
        int size
        DynamicArray(int) except +
        void add_back(int)
        void add_front(int)
        void add(int, int)
        int get(int)
        int pop_fornt()
        int pop_back()
        int remove(int)
        void replace(int, int)
        void swap(int, int)
        void append(DynamicArray)
        int find(int)
        void clear()

cdef class Matrix:
    cpdef DynamicArray** matrix
    cpdef int size

    cpdef int get(self, int i, int j)
    cpdef int set(self, int i, int j, int value)

    cpdef void resize(self, int size)

    cpdef getsize(self)
