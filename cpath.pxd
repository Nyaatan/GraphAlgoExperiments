
cdef class CPathNode:
    cdef public:
        cpdef int s, e, w   # s - start node, e - end node, w - weight
        cpdef CPathNode n_next  # next node in path

cdef class CPath:
    cpdef int maxnode   # maximum index of node in path
    cpdef str mode  # 'list' or 'matrix'
    cpdef CPathNode first   # first node of path
    cdef void add(self, CPathNode n_next)   # adds new node to path
