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
    cdef bool* visited = <bool*> PyMem_Malloc(graph.size*sizeof(bool))  # bool array with information wether the node was visited
    cdef int i = 0
    cdef int visited_count = 0
    visited[starting_vertex] = True

    i = 0
    for i in range(graph.root.get(starting_vertex).size):   # fill connection list of starting vertex
        start_connections.add_back(
            graph.root.get(starting_vertex).get(i).value,
            graph.root.get(starting_vertex).get(i).weight)

    for i in range(graph.size):
        visited[i] = False


    i = 0
    for i in range(start_connections.size):     # add every neighbor edge of starting vertex to queue
        queue.add(start_connections.get(i).weight, starting_vertex, start_connections.get(i).value)


    cdef CNode next_node = queue.queue_pop()    # get edge of minimal weight

    cdef DoublyLinkedList* connections = new DoublyLinkedList()
    while next_node is not None:
        connections = graph.get_connections(next_node.end)  # get connections of next node
        i = 0

        for i in range(connections.size):
            if not visited[connections.get(i).value]:  # if destination vertex is not visited, add the edge to queue
                queue.add(connections.get(i).weight, next_node.end, connections.get(i).value)

        if not visited[next_node.end]:  # if the vertex haven't been visited already, add the edge to result graph
            visited[next_node.end] = True
            result.add_connection(next_node.start, next_node.end, next_node.data)
            result.add_connection(next_node.end, next_node.start, next_node.data)
            visited_count += 1
            if visited_count == graph.size:     # break if all vertices have been visited
                break
        next_node = queue.queue_pop()
    PyMem_Free(visited)
    del queue
    return result

cpdef Matrix prim_matrix(Matrix graph, tuple args):
    cdef starting_vertex = args[0]
    cpdef Matrix result = Matrix(graph.size)
    cdef PriorityQueue queue = PriorityQueue()
    cdef bool* visited = <bool*> PyMem_Malloc(graph.size*sizeof(bool))  # bool array with information wether the node was visited
    cdef int i = 0
    cdef int visited_count = 0
    visited[starting_vertex] = True

    i = 0
    for i in range(graph.size):
        visited[i] = False

    i = 0
    for i in range(graph.size):  # add every neighbor edge of starting vertex to queue
        if graph.get(starting_vertex, i) != 0:
            queue.add(graph.get(starting_vertex, i), starting_vertex, i)

    cdef CNode next_node = queue.queue_pop()    # get edge of minimal weight
    while next_node is not None:
        i = 0
        for i in range(graph.size):    # if destination vertex (i) is not visited and edge exists, add the edge to queue
            if not visited[i] and graph.get(next_node.end, i) > 0:
                queue.add(graph.get(next_node.end, i), next_node.end, i)
        if not visited[next_node.end]:  # if the vertex haven't been visited already, add the edge to result graph
            visited[next_node.end] = True
            visited_count += 1
            result.set(next_node.start, next_node.end, next_node.data)
            result.set(next_node.end, next_node.start, next_node.data)
            if visited_count == graph.size:     # break if all vertices have been visited
                break
        next_node = queue.queue_pop()
    PyMem_Free(visited)
    del queue
    return result

cpdef ListGraph kruskal_list(ListGraph graph, tuple args):
    cdef int i = 0
    cdef int visited_count = 0
    cpdef ListGraph result = ListGraph(graph.getsize())
    cdef PriorityQueue queue = PriorityQueue()
    cdef DoublyLinkedList* connections
    cdef int max_group = 0  # group iterator
    cdef int j
    cdef int* groups = <int*> PyMem_Malloc(graph.size*sizeof(int))  # array assigning group number to a vertex
    for i in range(graph.size):     # add all edges to queue
        groups[i] = -1
        connections = graph.get_connections(i)
        j = 0
        for j in range(connections.size):
            queue.add(connections.get(j).weight, i, connections.get(j).value)
    cdef CNode next_node = queue.queue_pop()    # get first edge
    visited_count += 1
    cdef int old_group
    while next_node is not None:
        if groups[next_node.start] == -1 and groups[next_node.end] == -1:   # if both vertices are grupless, create new group
            groups[next_node.start] = max_group
            groups[next_node.end] = max_group
            max_group += 1
            result.add_connection(next_node.start, next_node.end, next_node.data)
            result.add_connection(next_node.end, next_node.start, next_node.data)
            visited_count += 1
        elif groups[next_node.start] != -1 and groups[next_node.end] == -1 \
                or groups[next_node.start] == -1 and groups[next_node.end] != -1:   # if one of vertices is groupless, assign the other's group to it
            groups[next_node.start] = max(groups[next_node.start], groups[next_node.end])
            groups[next_node.end] = max(groups[next_node.start], groups[next_node.end])
            result.add_connection(next_node.start, next_node.end, next_node.data)
            result.add_connection(next_node.end, next_node.start, next_node.data)
            visited_count += 1
        elif groups[next_node.start] != -1 and groups[next_node.end] != -1:  # if both have groups, merge the groups
            if groups[next_node.start] != groups[next_node.end]:
                j = 0
                old_group = groups[next_node.end]
                for j in range(graph.getsize()):
                    if groups[j] == old_group:
                        groups[j] = groups[next_node.start]
                result.add_connection(next_node.start, next_node.end, next_node.data)
                result.add_connection(next_node.end, next_node.start, next_node.data)
                visited_count += 1
        if visited_count == graph.getsize():    # if all vertices have been visited, break
            break

        next_node = queue.queue_pop()

    PyMem_Free(groups)
    return result

cpdef Matrix kruskal_matrix(Matrix graph, tuple args):
    cdef int i = 03
    cdef int visited_count = 0
    cpdef Matrix result = Matrix(graph.getsize())
    cdef PriorityQueue queue = PriorityQueue()
    cdef int max_group = 0  # group iterator
    cdef int j
    cdef int* groups = <int*> PyMem_Malloc(graph.size*sizeof(int))  # array assigning group number to a vertex
    for i in range(graph.size):     # add all edges to queue
        groups[i] = -1
        j = 0
        for j in range(i+1, graph.getsize()):
            if graph.get(i, j) != 0:
                queue.add(graph.get(i, j), i, j)
    cdef CNode next_node = queue.queue_pop()    # get first edge
    visited_count += 1
    cdef int old_group
    while next_node is not None:
        if groups[next_node.start] == -1 and groups[next_node.end] == -1:   # if both vertices are grupless, create new group
            groups[next_node.start] = max_group
            groups[next_node.end] = max_group
            max_group += 1
            result.set(next_node.start, next_node.end, next_node.data)
            result.set(next_node.end, next_node.start, next_node.data)
            visited_count += 1
        elif groups[next_node.start] != -1 and groups[next_node.end] == -1 \
                or groups[next_node.start] == -1 and groups[next_node.end] != -1:   # if one of vertices is groupless, assign the other's group to it
            groups[next_node.start] = max(groups[next_node.start], groups[next_node.end])
            groups[next_node.end] = max(groups[next_node.start], groups[next_node.end])
            result.set(next_node.start, next_node.end, next_node.data)
            result.set(next_node.end, next_node.start, next_node.data)
            visited_count += 1
        elif groups[next_node.start] != -1 and groups[next_node.end] != -1: # if both have groups, merge the groups
            if groups[next_node.start] != groups[next_node.end]:
                j = 0
                old_group = groups[next_node.end]
                for j in range(graph.getsize()):
                    if groups[j] == old_group:
                        groups[j] = groups[next_node.start]
                result.set(next_node.start, next_node.end, next_node.data)
                result.set(next_node.end, next_node.start, next_node.data)
                visited_count += 1
        if visited_count == graph.getsize():    # if all vertices have been visited, break
            break
        next_node = queue.queue_pop()

    PyMem_Free(groups)
    return result


cpdef CPath dijkstra_list(ListGraph graph, tuple args):
    cdef int start = args[0], end = args[1]
    cdef int* distances = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # distances from start
    cdef int* prevs = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # prevs[i] - previous vertex ID of vertex i in shortest path to i from the start
    cdef int i=0
    if graph.get_connections(start).size == 0:  # if start has no neighbours, no need to check anything
        return None
    for i in range(graph.getsize()):
        distances[i] = MAX_INT
        prevs[i] = -1
    distances[start] = 0
    cdef PriorityQueue queue = PriorityQueue()
    i = 0
    for i in range(graph.size): # add all vertices to queue
        queue.add(distances[i], i, 0)
    cdef CNode next_node = queue.queue_pop()
    cdef DoublyLinkedList* connections

    while next_node is not None:
        if next_node.data == MAX_INT:   # if no path to the vertex exists, there will be no more paths to check
            break
        connections = graph.get_connections(next_node.start)
        i = 0
        for i in range(connections.size):
            if distances[next_node.start]+connections.get(i).weight < distances[connections.get(i).value]:  # if the path through current vertex is shorter, update distances and queue
                distances[connections.get(i).value] = distances[next_node.start]+connections.get(i).weight
                prevs[connections.get(i).value] = next_node.start
                queue.queue_update_node(connections.get(i).value,
                                        distances[connections.get(i).value])

        next_node = queue.queue_pop()

    cpdef CPath result = CPath('list')
    cdef int currid = end
    if prevs[currid] == -1:  # prevs[i] = -1 means no path was found to vertex i
        return None
    while currid != start:  # recreate the path
        result.add(CPathNode(prevs[currid], currid, distances[currid]-distances[prevs[currid]]))
        currid = prevs[currid]
    PyMem_Free(distances)
    PyMem_Free(prevs)
    del queue
    return result


cpdef CPath dijkstra_matrix(Matrix graph, tuple args):
    cdef int start = args[0], end = args[1]
    cdef int* distances = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # distances from start
    cdef int* prevs = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # prevs[i] - previous vertex ID of vertex i in shortest path to i from the start
    cdef int i=0
    cdef bool no_return = False
    for i in range(graph.getsize()): # if start has no neighbours, no need to check anything
        if graph.matrix[start].array[i] != 0:
            no_return = True
        distances[i] = MAX_INT
        prevs[i] = -1
    if not no_return:
        return None
    distances[start] = 0
    cdef PriorityQueue queue = PriorityQueue()
    i = 0
    for i in range(graph.size):  # add all vertices to queue
        queue.add(distances[i], i, 0)
    cdef CNode next_node = queue.queue_pop()

    while next_node is not None:
        if next_node.data == MAX_INT:  # if no path to the vertex exists, there will be no more paths to check
            break
        i = 0
        for i in range(graph.getsize()):
            if graph.get(next_node.start, i) != 0 : # if the path through current vertex is shorter, update distances and queue
                if distances[next_node.start]+graph.get(next_node.start, i) < distances[i]:
                    distances[i] = distances[next_node.start]+graph.get(next_node.start, i)
                    prevs[i] = next_node.start
                    queue.queue_update_node(i, distances[i])

        next_node = queue.queue_pop()

    cpdef CPath result = CPath('matrix')
    cdef int currid = end
    if prevs[currid] == -1:     # prevs[i] = -1 means no path was found to vertex i
        return None
    while currid != start:      # recreate the path
        result.add(CPathNode(prevs[currid], currid, distances[currid]-distances[prevs[currid]]))
        currid = prevs[currid]
    PyMem_Free(distances)
    PyMem_Free(prevs)
    del queue
    return result

cpdef CPath ford_bellman_list(ListGraph graph, tuple args):
    cdef int start = args[0], end = args[1]
    cdef int* distances = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # distances from start
    cdef int* prevs = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # prevs[i] - previous vertex ID of vertex i in shortest path to i from the start

    cdef int i = 0
    for i in range(graph.getsize()):
        distances[i] = MAX_INT
        prevs[i] = -1
    distances[start] = 0

    cdef DoublyLinkedList* connections
    cdef bool change = True
    cdef int j = 0
    while change:   # check paths for every neighbor of every node brutally, break if no change recorded
        change = False
        i = 0
        for i in range(graph.getsize()):
            connections = graph.get_connections(i)
            j = 0
            for j in range(connections.size):
                if distances[connections.get(j).value] != MAX_INT:
                    if distances[i] > distances[connections.get(j).value] + connections.get(j).weight:
                        change = True
                        distances[i] = distances[connections.get(j).value] + connections.get(j).weight
                        prevs[i] = connections.get(j).value

    cpdef CPath result = CPath('list')
    cdef int currid = end
    if prevs[currid] == -1: # prevs[i] = -1 means no path was found to vertex i
        return None
    while currid != start:  # recreate the path
        result.add(CPathNode(prevs[currid], currid, distances[currid]-distances[prevs[currid]]))
        currid = prevs[currid]
    PyMem_Free(distances)
    PyMem_Free(prevs)
    return result

cpdef CPath ford_bellman_matrix(Matrix graph, tuple args):
    cdef int start = args[0], end = args[1]
    cdef int* distances = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # distances from start
    cdef int* prevs = <int*> PyMem_Malloc(graph.getsize()*sizeof(int))  # prevs[i] - previous vertex ID of vertex i in shortest path to i from the start

    cdef int i = 0
    for i in range(graph.getsize()):
        distances[i] = MAX_INT
        prevs[i] = -1
    distances[start] = 0

    cdef bool change = True
    cdef int j = 0
    while change:   # check paths for every neighbor of every node brutally, break if no change recorded
        change = False
        i = 0
        for i in range(graph.getsize()):
            j = 0
            for j in range(graph.getsize()):
                if graph.get(i, j) != 0 and distances[i] != MAX_INT:
                    if distances[j] > distances[i] + graph.get(i,j):
                        change = True
                        distances[j] = distances[i] + graph.get(i,j)
                        prevs[j] = i

    cpdef CPath result = CPath('matrix')
    cdef int currid = end
    if prevs[currid] == -1: # prevs[i] = -1 means no path was found to vertex i
        return None
    while currid != start:  # recreate the path
        result.add(CPathNode(prevs[currid], currid, distances[currid]-distances[prevs[currid]]))
        currid = prevs[currid]
    PyMem_Free(distances)
    PyMem_Free(prevs)
    return result