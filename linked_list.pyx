# distutils: language = c++
# distutils: sources = DoublyLinkedList.cpp
from matrix import Matrix
cdef extern from "DoublyLinkedList.cpp":
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

cdef class ListGraphRoot:


    def __init__(self, int PNodes):
        self.front = None
        self.rear = None
        self.size = 0
        cpdef int i = 0
        cpdef DoublyLinkedList* row
        for i in range(PNodes):
            row = new DoublyLinkedList()
            self.add_back(row)

    def __del__(self):
        curr = self.front
        for i in range(self.size):
            n = curr._next
            del curr
            curr = n

    cdef void add_front(self, DoublyLinkedList* value):
        cdef PNode newPNode = PNode()
        newPNode.value = value
        newPNode._next = self.front

        if self.front is not None:
            self.front._prev = newPNode

        newPNode._prev = None
        self.front = newPNode
        if self.rear is None:
            self.rear = newPNode

        self.size += 1

    cdef void add_back(self, DoublyLinkedList* value):
        cpdef PNode newPNode = PNode()
        newPNode.value = value
        newPNode._next = None

        if self.rear is not None:
            newPNode._prev = self.rear

        self.rear._next = newPNode
        self.rear = newPNode
        if self.front is None:
            self.front = newPNode

        self.size += 1

    cdef void add(self, DoublyLinkedList* value, int index):
        self.check_index(index, 'g')
        if index == 0:
            self.add_front(value)
            return
        if index == self.size:
            self.add_back(value)
            return

        cpdef PNode curr_PNode = self._find(index)
        cpdef PNode new_PNode = PNode()
        new_PNode.value = value
        new_PNode._next = curr_PNode
        new_PNode._prev = curr_PNode._prev
        curr_PNode._prev = new_PNode
        new_PNode._prev._next = new_PNode
        self.size += 1

    cdef PNode _find(self, int index):
        self.check_index(index, 'l')
        cpdef PNode curr = self.front
        cpdef int i = 0
        for i in range(index):
            curr = curr._next
        return curr

    cdef DoublyLinkedList* get(self, int index):
        return self._find(index).value

    cdef DoublyLinkedList* pop_front(self):
        cpdef PNode ret = self.front
        self.front = self.front._next
        self.front._prev = None
        self.size -= 1
        return ret.value

    cdef DoublyLinkedList* pop_back(self):
        cpdef PNode ret = self.rear
        self.rear = ret._prev
        self.rear._next = None
        self.size -= 1
        return ret.value

    cdef DoublyLinkedList* remove(self, int index):
        self.check_index(index, 'l')
        if index == 0:
            return self.pop_front()
        if index == self.size-1:
            return self.pop_back()
        cpdef PNode ret = self._find(index)
        ret._prev._next = ret._next
        ret._next._prev = ret._prev
        self.size -= 1
        return ret.value

    cdef void check_index(self, int index, char mode):
        cpdef int corr = 0

        if mode == 'g':
            corr = 1

        if index > self.size + corr:
            raise IndexError("Index %d out of bounds: %d" % (index, self.size))



cdef class ListGraph:

    def __init__(self, int PNodes):
        self.root = ListGraphRoot(PNodes)
        self.size = PNodes


    def __str__(self):
        result = {}
        cpdef int i = 0
        cpdef int j = 0
        cpdef DoublyLinkedList* graphrow
        for i in range(self.size):
            row = []
            graphrow = self.root.get(i)
            for j in range(graphrow.size):
                row.append((graphrow.get(j).value, graphrow.get(j).weight))
            result[i] = row
        return str(result)

    cpdef void add_connection(self, int begin, int end, int weight):
        self.root.get(begin).add_back(end, weight)

    cpdef void remove_connection(self, int begin, int end):
        self.root.get(begin).remove(end)

    cdef DoublyLinkedList* get_connections(self, int node_id):
        return self.root.get(node_id)

    def get_edges(self):
        result = []
        for x in range(self.root.size):
            for y in range(self.root.get(x).size):
                result.append((x, {'value': self.root.get(x).get(y).value, 'weight': self.root.get(x).get(y).weight}))
        return result

    cpdef getsize(self):
        return self.size