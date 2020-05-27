# distutils: language = c++
# distutils: sources = DoublyLinkedList.cpp
from matrix import Matrix
cdef extern from "DoublyLinkedList.cpp":    # wrapping of C++ class
    struct Node:
        int value
        int weight

    cppclass DoublyLinkedList:
        int size
        DoublyLinkedList() except +
        void add_front(int, int)
        void add_back(int, int)
        Node pop_front()
        Node pop_back()
        void clear()
        int length()
        void add(int, int, int)
        Node remove(int)
        Node get(int)

cdef class PNode:   # node of list of lists
    cpdef PNode _prev
    cpdef PNode _next
    cpdef DoublyLinkedList* value

cdef class ListGraphRoot:   # list of lists
    cdef PNode front
    cdef PNode rear
    cdef int size

    cdef void add_front(self, DoublyLinkedList* value)
    cdef void add_back(self, DoublyLinkedList* value)

    cdef void add(self, DoublyLinkedList* value, int index)

    cdef PNode _find(self, int index)

    cdef DoublyLinkedList* get(self, int index)

    cdef DoublyLinkedList* pop_front(self)

    cdef DoublyLinkedList* pop_back(self)

    cdef DoublyLinkedList* remove(self, int index)

    cdef void check_index(self, int index, char mode)


cdef class ListGraph:
    cpdef ListGraphRoot root
    cpdef int size

    cpdef void add_connection(self, int begin, int end, int weight)
    cpdef void remove_connection(self, int begin, int end)

    cdef DoublyLinkedList* get_connections(self, int node_id)

    cpdef getsize(self)
