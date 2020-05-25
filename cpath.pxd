
cdef class CPathNode:
    cdef public:
        cpdef int s, e, w
        cpdef CPathNode n_next

cdef class CPath:
    cpdef int maxnode
    cpdef str mode
    cpdef CPathNode first
    cdef void add(self, CPathNode n_next)
