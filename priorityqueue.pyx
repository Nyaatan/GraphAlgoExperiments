# distutils: language = c++
# distutils: sources = Heap.cpp

cdef extern from "Heap.cpp":    # wrapping of C++ class, min type heap
    struct Node:
        int data
        int start
        int end

    cppclass Heap:
        Heap() except +
        void add(int, int, int)
        Node* pop_min()
        void change_key(int, int)
        void hprint()

cdef class CNode:   # heap node wrapper usable in python code
    def __cinit__(self):
        self.data = -1
        self.start = -1
        self.end = -1

    def __str__(self):
        return "{S:%d, E:%d, W:%d}" % (self.start, self.end, self.data)

cdef class PriorityQueue:

    def __cinit__(self):
        self.root = new Heap()

    def __del__(self):
        del self.root

    cpdef int add(self, int val, int start, int end):
        return self.root.add(val, start, end)

    cdef CNode queue_pop(self):
        cpdef node = CNode()
        cdef Node* popnode = self.root.pop_min()
        if popnode.start == -1:
            return None
        node.data = popnode.data
        node.start = popnode.start
        node.end = popnode.end
        return node

    cpdef void tprint(self):
        # self.root.hprint()
        pass

    cdef int  queue_update_node(self, int node_id, int newval):
        return self.root.change_key(node_id, newval)