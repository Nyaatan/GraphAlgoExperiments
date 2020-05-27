# distutils: language = c++
# distutils: sources = Heap.cpp

cdef extern from "Heap.cpp":    # wrapping of C++ class
    struct Node:
        int data
        int start
        int end

    cppclass Heap:
        Heap() except +
        int add(int, int, int)
        Node* pop_min()
        int change_key(int, int)

cdef class CNode:   # heap node wrapper usable in python code
    cdef public int data
    cdef public int start
    cdef public int end

cdef class PriorityQueue:
    cpdef Heap* root
    cpdef int add(self, int val, int start, int end)
    cdef CNode queue_pop(self)
    cpdef void tprint(self)
    cdef int queue_update_node(self, int node_id, int newval)