import sys
from os import system, name

import gc
import matplotlib.pyplot as plt
import networkx as nx
from numpy import average
from numpy.random.mtrand import randint
from pyprind.progbar import ProgBar

import algorithms
import settings
from linked_list import ListGraph
from matrix import Matrix

from timeit import default_timer as timer


debug = True


class Panel:

    def __init__(self, options: dict, no_exit=False):
        self.options = options
        if not no_exit:
            self.options['Exit'] = self.exit
        self.stop = False

    @staticmethod
    def cls():
        if name == 'nt':
            _ = system('cls')
        else:
            _ = system('clear')

    def draw(self):
        self.cls()
        for option, i in zip(self.options.keys(), range(len(self.options.keys()))):
            print("%d. %s" % (i + 1, option))

    def select(self):
        try:
            option = int(input("Select option: ")) - 1
            if 0 > option:
                raise KeyError

            ret = self.options[list(self.options.keys())[option]]()
            if ret is not None:
                return ret

        except KeyError as e:
            if debug:
                print(e)
            input("No such option."
                  "\nPress ENTER to continue...")

        except ValueError as e:
            self.start()

    def start(self):
        while not self.stop:
            self.draw()
            ret = self.select()
            if ret is not None:
                return ret

    def exit(self):
        self.stop = True


class MainMenu(Panel):
    def __init__(self):
        options = {
            'MST problem': self.mst,
            'Shortest path problem': self.spp,
            'Maximum flow problem': self.mfp,
            'Serial test': self.serial_test
        }
        super().__init__(options)

    def mst(self):
        select_scr = Panel({
            "Prim's algorithm": self.prim,
            "Kruskal's algorithm": self.kruskal
        })
        select_scr.start()

    def spp(self):
        select_scr = Panel({
            "Dijkstra's algorithm": self.dijkstra,
            "Ford-Bellman's algorithm": self.ford_bellman
        })
        select_scr.start()

    def mfp(self):
        select_scr = Panel({
            "Ford-Fulkerson's algorithm": self.ford_fulkerson
        })
        select_scr.start()

    def prim(self):
        loader = GraphGenerator(directed=False, algorithm='prim')
        loader.start()

    def kruskal(self):
        loader = GraphGenerator(directed=False, algorithm='kruskal')
        loader.start()

    def dijkstra(self):
        loader = GraphGenerator(directed=True, algorithm='dijkstra')
        loader.start()

    def ford_bellman(self):
        loader = GraphGenerator()
        loader.start()

    def ford_fulkerson(self):
        loader = GraphGenerator()
        loader.start()

    def serial_test(self):
        result_file = open('result.txt', 'w+')
        for algorithm in settings.algorithms:
            print(algorithm.capitalize())
            alg_res = {}
            for representation in settings.representations:
                print(representation.capitalize())
                rep_res = {}
                for density in settings.densities:
                    print('Density: {}%'.format(density*100))
                    den_res = {}
                    for serie in settings.series:
                        print('Graph size: %d' % serie)
                        results = []
                        for i in range(settings.series_entries):
                            gc.disable()
                            graph = GraphGenerator.generate_graph_nx(
                                serie, density, representation, settings.is_directed[algorithm])
                            function = getattr(algorithms, '%s_%s' % (algorithm, representation))
                            args = ()
                            if algorithm == 'prim' or algorithm == 'kruskal':
                                args = tuple([randint(serie)])
                            elif algorithm == 'dijkstra' or algorithm == 'ford_bellman':
                                arg1 = randint(serie)
                                arg2 = randint(serie)
                                while arg2 == arg1:
                                    arg2 = randint(serie)
                                args = (arg1, arg2)
                            start = timer()
                            function(graph, args)
                            end = timer()
                            time = (end-start)*1000
                            print('Entry %d | Execution time: %f milliseconds' % (i+1, time))
                            result_file.write('Entry %d | Execution time: %f milliseconds' % (i+1, time))
                            results.append(time)
                            del graph
                            gc.enable()

                        avg = average(results)
                        maxi = max(results)
                        mini = min(results)
                        print('Average time in series: %f' % avg)
                        result_file.write('Average time in series: %f' % avg)
                        print('Maximum execution time: %f' % maxi)
                        result_file.write('Maximum execution time: %f' % maxi)
                        print('Minimum execution time: %f' % mini)
                        result_file.write('Minimum execution time: %f' % mini)
                        print('-'*30)
                        result_file.write('-'*30)
                        den_res[serie] = results
                    rep_res[density] = den_res
                alg_res[representation] = rep_res





class GraphGenerator(Panel):

    def __init__(self, directed=True, algorithm=None):
        self.directed = directed
        self.algorithm = algorithm
        self.modes = {
            "Matrix representation": lambda: "matrix",
            "List representation": lambda: "list"
        }

        mode_select = Panel(self.modes, no_exit=True)
        self.mode = mode_select.start()

        self.algorithm_fun = getattr(algorithms, '%s_%s' % (self.algorithm, self.mode))

        if self.mode == 'matrix':
            self.graph = Matrix(0)
        else:
            self.graph = ListGraph(0)

        self.options = {
            'Load': self.load,
            'Print': self.print_graph,
            'Generate': self.generate,
            'Show': self.show,
            'Test': self.test
        }
        super().__init__(self.options)

    def load(self):
        path = input("File name: ")
        self.graph = self.load_graph(path, self.mode, self.directed)

    def print_graph(self):
        print(self.graph)

    def generate(self):
        nodes = int(input("Number of nodes: "))
        density = float(input("Graph density in %: ").strip('%')) / 100
        self.graph = self.generate_graph_nx(nodes, density, self.mode, self.directed)

    def show(self):
        self.print_graph()
        if len(self.graph.get_edges()) != 0:
            if settings.plot_graphs:
                self.plot_graph(self.graph.get_edges(), self.directed)
        else:
            print("The graph is empty")

    def test(self):
        x = self.input_data(self.algorithm, self.graph.getsize())
        if x is None:
            print('No input.', file=sys.stderr)
            return
        start = timer()
        result = self.algorithm_fun(self.graph, x)
        end = timer()
        print('Execution time: %f milliseconds' % ((end-start)*1000))
        print(result)
        if result is None:
            print("No result.", file=sys.stderr)
            return
        if settings.plot_graphs:
            self.plot_graph(result.get_edges(), self.directed)

    @staticmethod
    def plot_graph(edges: list, directed=False):
        graph = nx.Graph()
        if directed:
            graph = nx.DiGraph()
        nodes = []
        for edge in edges:
            if edge[0] not in nodes:
                nodes.append(edge[0])
            if edge[1]['value'] not in nodes:
                nodes.append(edge[1]['value'])

        graph.add_nodes_from(nodes)

        for edge in edges:
            graph.add_edge(edge[0], edge[1]['value'], weight=edge[1]['weight'])

        pos = nx.spring_layout(graph)
        nx.draw_networkx_nodes(graph, pos, cmap=plt.get_cmap('jet'), node_size=200)
        nx.draw_networkx_labels(graph, pos)
        nx.draw_networkx_edges(graph, pos, edgelist=graph.edges, arrowstyle='->',
                               arrowsize=10)
        labels = nx.get_edge_attributes(graph, 'weight')
        nx.draw_networkx_edge_labels(graph, pos, edge_labels=labels)
        w = sum(edge[1]['weight'] for edge in edges)
        if not directed:
            w = w / 2
        print("Total weight: %d" % w)
        plt.text(0.01, -1, 'Total weight: %d' % w,
                 verticalalignment='bottom', horizontalalignment='right',
                 color='green', fontsize=15)
        plt.show()

    @staticmethod
    def load_graph(path, mode, directed):
        f = open(path, 'r+')
        for line in f.readlines():
            vals = [int(val) for val in line.split(' ')]
            if len(vals) == 2:
                if mode == 'matrix':
                    graph = Matrix(vals[1])
                else:
                    graph = ListGraph(vals[1])
            else:
                if mode == 'matrix':
                    graph.set(vals[0], vals[1], vals[2])
                    if directed and graph.get(vals[1], vals[0]) == 0:
                        graph.set(vals[1], vals[0], -1)
                    else:
                        graph.set(vals[1], vals[0], vals[2])
                else:
                    graph.add_connection(vals[0], vals[1], vals[2])
                    if not directed:
                        graph.add_connection(vals[1], vals[0], vals[2])
        return graph

    @staticmethod
    def generate_graph_nx(nodes: int, density, mode, directed, force=settings.force):
        bar = ProgBar(20, title='Generating graph', stream=sys.stdout)
        if directed:
            edges = nodes * (nodes - 1) * density
            if edges < nodes - 1 and not force:
                print("Minimum graph density for this problem is {:2.0%}. "
                      "To generate less dense graph anyway, set argument force to True."
                      .format(float(1 / nodes)), file=sys.stderr)
                edges = nodes - 1
        else:
            edges = nodes * (nodes - 1) * density / 2
            if edges < nodes - 1 and not force:
                print("Minimum graph density for this problem is {:2.0%}. "
                      "To generate less dense graph anyway, set argument force to True."
                      .format(float(2 / nodes)), file=sys.stderr)
                edges = nodes - 1
        bar.update()
        G = nx.generators.random_graphs.gnm_random_graph(nodes, edges, directed=directed)
        bar.update()
        if not directed:
            while not nx.is_connected(G):
                G = nx.generators.random_graphs.gnm_random_graph(nodes, edges, directed=directed)
        else:
            cont = False

            while not cont:
                pas = True
                for node in G.nodes:
                    if len([x for x in G.neighbors(node)]) == 0:
                        pas = False
                        G = nx.generators.random_graphs.gnm_random_graph(nodes, edges, directed=directed)
                        break
        bar.update()
        if mode == 'matrix':
            ret = Matrix(nodes)
            for x, y in G.edges:
                w = randint(1, nodes)
                ret.set(x, y, w)
                if directed and ret.get(y, x) == 0:
                    ret.set(y, x, 0)
                else:
                    ret.set(y, x, w)
                bar.update()
            return ret
        else:
            ret = ListGraph(nodes)
            for x, y in G.edges:
                w = randint(1, nodes)
                ret.add_connection(x, y, w)
                if not directed:
                    ret.add_connection(y, x, w)
                bar.update()
            return ret

    @staticmethod
    def input_data(algorithm: str, rand_range):
        if algorithm == 'prim':
            inp = input('Starting vertex (leave blank to generate random): ')
            if inp == '':
                return tuple([randint(rand_range)])
            else:
                try:
                    if int(inp) >= rand_range:
                        raise KeyError
                    return tuple([int(inp)])
                except ValueError:
                    print('Index must be an integer.', file=sys.stderr)
                except KeyError:
                    print('Index out of range - %d.' % rand_range, file=sys.stderr)
        if algorithm == 'kruskal':
            return None
        if algorithm == 'dijkstra' or algorithm == 'ford_bellman':
            inp = (input('Starting vertex (leave blank to generate random): '),
                   input('End vertex (leave blank to generate random): '))
            ret = []
            for x in inp:
                if x == '':
                    ret.append(randint(rand_range))
                else:
                    try:
                        if int(x) >= rand_range:
                            raise KeyError
                        ret.append(int(x))
                    except KeyError:
                        print('Index out of range - %d.' % rand_range, file=sys.stderr)
                    except ValueError:
                        print('Index must be an integer.', file=sys.stderr)
            return tuple(ret)


m = MainMenu()
m.start()
