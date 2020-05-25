# distutils: language = c++
# distutils: sources = DynamicArray.cpp
from cpython.mem cimport PyMem_Malloc, PyMem_Free

from linked_list import ListGraph

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

    def __init__(self, size):
        self.size = size
        self.matrix = <DynamicArray**> PyMem_Malloc(size * sizeof(DynamicArray*))
        cpdef int i = 0
        cpdef int j = 0
        for i in range(size):
            self.matrix[i] = new DynamicArray(size)
            j = 0
            for j in range(size):
                self.matrix[i].array[j] = 0
    def __del__(self):
        for i in range(self.size):
            del self.matrix[i]
        PyMem_Free(self.matrix)

    def __str__(self):
        ret = []
        cpdef int i=0
        cpdef int j=0
        for i in range(self.size):
            row = []
            j = 0
            for j in range(self.size):
                row.append(self.matrix[i].array[j])
            ret.append(row)
        return str(ret)

    cpdef int get(self, int i, int j):
        return self.matrix[i].array[j]

    cpdef int set(self, int i, int j, int value):
        self.matrix[i].array[j] = value

    cpdef void resize(self, int size):
        cpdef int i = 0
        cpdef int j = 0
        cpdef DynamicArray* temparr
        cpdef DynamicArray** tempmat = <DynamicArray**> PyMem_Malloc(size * sizeof(DynamicArray*))
        for i in range(self.size):
            temparr = new DynamicArray(size)
            j = 0
            for j in range(self.size):
                temparr.array[j] = self.matrix[i].array[j]
            j = self.size
            for j in range(self.size, size):
                temparr.array[j] = 0
            tempmat[i] = temparr
        i = 0
        j = self.size
        for j in range(self.size, size):
            tempmat[j] = new DynamicArray(size)
            for i in range(size):
                tempmat[j].array[i] = 0
        self.matrix = tempmat
        self.size = size
        PyMem_Free(tempmat)

    def get_edges(self):
        result = []
        for x in range(self.size):
            for y in range(self.size):
                if self.get(x, y) > 0:
                    result.append((x, {'value' : y,'weight' : self.get(x, y)}))
        return result

    cpdef getsize(self):
        return self.size

