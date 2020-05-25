# distutils: language = c++
# distutils: sources = DoublyLinkedList.cpp

from cpython.mem cimport PyMem_Malloc, PyMem_Free
from libcpp cimport bool
from priorityqueue cimport PriorityQueue, CNode
from linked_list cimport DoublyLinkedList
from linked_list cimport ListGraph
from matrix cimport Matrix
from priorityqueue import PriorityQueue
from cpath cimport CPathNode
from cpath cimport CPath
from linked_list import ListGraph
from matrix cimport Matrix, DynamicArray
from timeit import default_timer as timer

cdef int MAX_INT = 2147483000

cpdef ListGraph prim_list(ListGraph graph, tuple args):

    cdef int starting_vertex = args[0]
    cpdef ListGraph result = ListGraph(graph.root.size)
    cdef PriorityQueue queue = PriorityQueue()
    cdef DoublyLinkedList* start_connections = new DoublyLinkedList()
    cdef bool* visited = <bool*> PyMem_Malloc(graph.size*sizeof(bool))
    cdef int i = 0
    cdef int visited_count = 0
    visited[starting_vertex] = True

    i = 0
    for i in range(graph.root.get(starting_vertex).size):
        start_connections.add_back(
            graph.root.get(starting_vertex).get(i).value,
            graph.root.get(starting_vertex).get(i).weight)

    for i in range(graph.size):
        visited[i] = False


    i = 0
    for i in range(start_connections.size):
        queue.add(start_connections.get(i).weight, starting_vertex, start_connections.get(i).value)


    cdef CNode next_node = queue.queue_pop()
    cdef DoublyLinkedList* connections = new DoublyLinkedList()

    while next_node is not None:
        connections = graph.get_connections(next_node.end)
        i = 0
        # start = timer()
        for i in range(connections.size):
            if not visited[connections.get(i).value]:
                queue.add(connections.get(i).weight, next_node.end, connections.get(i).value)
        # end = timer()
        if not visited[next_node.end]:
            # print(i)
            visited[next_node.end] = True
            visited_count += 1
            result.add_connection(next_node.start, next_node.end, next_node.data)
            result.add_connection(next_node.end, next_node.start, next_node.data)
            if visited_count == graph.size:
                break
        next_node = queue.queue_pop()
    PyMem_Free(visited)
    del queue
    return result

cpdef Matrix prim_matrix(Matrix graph, tuple args):
    cdef starting_vertex = args[0]
    cpdef Matrix result = Matrix(graph.size)
    cdef PriorityQueue queue = PriorityQueue()
    cdef bool* visited = <bool*> PyMem_Malloc(graph.size*sizeof(bool))
    cdef int i = 0
    cdef int visited_count = 0
    visited[starting_vertex] = True

    i = 0
    for i in range(graph.size):
        visited[i] = False

    i = 0
    for i in range(graph.size):
        if graph.get(starting_vertex, i) > 0:
            queue.add(graph.get(starting_vertex, i), starting_vertex, i)

    cdef CNode next_node = queue.queue_pop()
    while next_node is not None:
        i = 0
        for i in range(graph.size):
            if not visited[i] and graph.get(next_node.end, i) > 0:
                queue.add(graph.get(next_node.end, i), next_node.end, i)
        if not visited[next_node.end]:
            visited[next_node.end] = True
            visited_count += 1
            result.set(next_node.start, next_node.end, next_node.data)
            result.set(next_node.end, next_node.start, next_node.data)
            if visited_count == graph.size:
                break
        next_node = queue.queue_pop()
    PyMem_Free(visited)
    del queue
    return result

cpdef ListGraph kruskal_list(ListGraph graph, tuple args):
    cdef int i = 0
    cdef PriorityQueue queue = PriorityQueue()
    cdef DoublyLinkedList* connections
    cdef int j
    for i in range(graph.size):
        connections = graph.get_connections(i)
        j = 0
        for j in range(connections.size):
            queue.add(connections.get(j).weight, i, connections.get(j).value)
    cdef int* groups = <int*> PyMem_Malloc(graph.size*sizeof(int))
    cdef int* group_aliases = <int*> PyMem_Malloc(graph.size*sizeof(int))
    i = 0
    for i in range(graph.size):
        groups[i] = -1
        group_aliases[i] = <int> new DoublyLinkedList()
        print(i)
        (<DoublyLinkedList*> group_aliases[i]).add(1, 1, 1)
    cdef int group_iter = 0
    PyMem_Free(groups)
    PyMem_Free(group_aliases)
    return graph


cpdef CPath dijkstra_list(ListGraph graph, tuple args):
    cdef int start = args[0], end = args[1]
    cdef int* distances = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))
    cdef int* prevs = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))
    cdef int i=0
    if graph.get_connections(start).size == 0:
        return None
    for i in range(graph.getsize()):
        distances[i] = MAX_INT
        prevs[i] = -1
    distances[start] = 0
    cdef PriorityQueue queue = PriorityQueue()
    i = 0
    for i in range(graph.size):
        queue.add(distances[i], i, 0)
    cdef CNode next_node = queue.queue_pop()
    cdef DoublyLinkedList* connections

    while next_node is not None:
        if next_node.data == MAX_INT:
            break
        connections = graph.get_connections(next_node.start)
        i = 0
        for i in range(connections.size):
            if distances[next_node.start]+connections.get(i).weight < distances[connections.get(i).value]:
                distances[connections.get(i).value] = distances[next_node.start]+connections.get(i).weight
                prevs[connections.get(i).value] = next_node.start
                queue.queue_update_node(connections.get(i).value,
                                        distances[connections.get(i).value])

        next_node = queue.queue_pop()

    cpdef CPath result = CPath('list')
    cdef int currid = end
    if prevs[currid] == -1:
        return None
    while currid != start:
        result.add(CPathNode(prevs[currid], currid, distances[currid]-distances[prevs[currid]]))
        currid = prevs[currid]
    PyMem_Free(distances)
    PyMem_Free(prevs)
    del queue
    return result


cpdef CPath dijkstra_matrix(Matrix graph, tuple args):
    cdef int start = args[0], end = args[1]
    cdef int* distances = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))
    cdef int* prevs = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))
    cdef int i=0
    cdef bool no_return = False
    for i in range(graph.getsize()):
        if graph.matrix[start].array[i] != 0:
            no_return = True
        distances[i] = MAX_INT
        prevs[i] = -1
    if not no_return:
        return None
    distances[start] = 0
    cdef PriorityQueue queue = PriorityQueue()
    i = 0
    for i in range(graph.size):
        queue.add(distances[i], i, 0)
    cdef CNode next_node = queue.queue_pop()

    while next_node is not None:
        if next_node.data == MAX_INT:
            break
        i = 0
        for i in range(graph.getsize()):
            if graph.get(next_node.start, i) != 0 :
                if distances[next_node.start]+graph.get(next_node.start, i) < distances[i]:
                    distances[i] = distances[next_node.start]+graph.get(next_node.start, i)
                    prevs[i] = next_node.start
                    queue.queue_update_node(i, distances[i])

        next_node = queue.queue_pop()

    cpdef CPath result = CPath('matrix')
    cdef int currid = end
    if prevs[currid] == -1:
        return None
    while currid != start:
        result.add(CPathNode(prevs[currid], currid, distances[currid]-distances[prevs[currid]]))
        currid = prevs[currid]
    PyMem_Free(distances)
    PyMem_Free(prevs)
    del queue
    return result

cpdef ListGraph ford_bellman(ListGraph graph, tuple args):
    return graph
