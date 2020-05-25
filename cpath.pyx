# distutils: language = c++

from linked_list import ListGraph
from matrix import Matrix

cdef class CPath:
    def __cinit__(self, mode):
        self.first = None
        self.mode = mode
        self.maxnode = 0

    cdef void add(self, CPathNode n_next):
        n_next.n_next = self.first
        self.first = n_next
        self.maxnode = max(self.maxnode, n_next.s, n_next.e)

    def get_edges(self):
        curr = self.first
        if self.mode == 'list':
            result = ListGraph(self.maxnode+1)
            while curr is not None:
                result.add_connection(curr.s, curr.e, curr.w)
                curr = curr.n_next
        else:
            result = Matrix(self.maxnode+1)
            while curr is not None:
                result.set(curr.s, curr.e, curr.w)
                curr = curr.n_next
        return result.get_edges()

    def __str__(self):
        return str(self.get_edges())

cdef class CPathNode:
    def __cinit__(self, int s, int e, int w):
        self.s = s
        self.e = e
        self.w = w
        self.n_next = None

    def __str__(self):
        return "||%d %d %d||" % (self.s, self.e, self.w)