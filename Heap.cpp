#include <iostream>
#include <cstdlib>

using namespace std;

struct Node{
    int start;
    int end;
    int data;

    Node(int s, int e, int w){
        start = s;
        end = e;
        data = w;
    }
};

class Heap{
    Node** array;
    Node** array_key;
    int maxkey = -1;

public:
    int length = 1;
    int size = 0;

    Heap() {
        array = (Node**) malloc(length*sizeof(Node*));
        array_key = (Node**) malloc(length*sizeof(Node*));
        array[0] = new Node(-2137, -1, -1);
        }

    ~Heap(){
        free(array);
        free(array_key);
    }

    void print_helper(int index, string indent, bool last)
    {
        if (index <= size)
        {
            printf("%s", indent);
            if (last)
            {
                printf("R====");
                indent += "   ";
            }
            else
            {
                printf("L====");
                indent += "|  ";
            }
            printf("%d %d\n", array[index]->data, array[index]->start);
            print_helper(index*2, indent, false);
            print_helper(index*2+1, indent, true);
        }
    }

    int heapify(int a){  // puts key from given index at proper place in heap
        int largest = a;

        if(2*a <= size && array[2*a]->data < array[largest]->data) largest = 2*a;
        else if(2*a+1 <= size && array[2*a+1]->data < array[largest]->data) largest = 2*a+1;
        if(largest != a){
            Node* temp = array[largest];
            array[largest] = array[a];
            array[a] = temp;
            return heapify(largest);
        }
        else return largest;
    }

    void build_heap(){  // arranges keys in heap
        for(int i=size/2;i>=1;--i){
            heapify(i);
        }
    }

    int add(int w, int s, int e){  // adds new value to heap and puts it in proper place
        size++;
        length++;
        int child = size;
        array = (Node**) realloc(array, length*sizeof(Node*));
        if(maxkey < s) maxkey=s;
        array_key = (Node**) realloc(array_key, (maxkey+1)*sizeof(Node*));
        array[child] = new Node(s, e, w);
        array_key[s] = array[child];
        while(child>1 && array[child]->data <= array[child/2]->data){  // if node's key is greater than his parent, child is now parent and parent is child
            Node* temp = array[child];
            array[child] = array[child/2];
            array[child/2] = temp;
            child = child/2;
        }
        return child;
    }

    void hprint(){  // prints the heap neatly
        print_helper(1, "", true);
    }

    Node* get_min() {
        if(size==0) throw underflow_error("Heap empty");
        return array[1];
    }  // returns root value

    Node* pop_min() {  // returns root value and removes it from the heap
        if(size==0) return new Node(-1, -1, -1);
        Node* val = array[1];
        array_key[val->start] = new Node(-1, -1, -1);
        for(int i=1;i<size;++i){
            array[i] = array[i+1];
        }
        array = (Node**) realloc(array, size*sizeof(Node*));
        --size;
        --length;
        build_heap();
        return val;
    }

    int change_key(int index, int val){  // increases key
        if(index == -1) return -1;
        array_key[index]->data = val;
        build_heap();
        return 1;
    }
};


