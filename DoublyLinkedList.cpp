#include <iostream>
#include <stdexcept>

using namespace std;

class DoublyLinkedList {
	struct Node {
		int value;
		int weight;
		Node* next = NULL;
		Node* prev = NULL;
		Node(int val, int w) {
			value = val;
			weight = w;
		}
	};

	Node* front = NULL;
	Node* back = NULL;

	public:
	    DoublyLinkedList(){
	    }

	    ~DoublyLinkedList(){
            free(front);
            free(back);
	    }

		int size = 0;
		void add_front(int a, int weight) {
			if (front != NULL) {
				Node* newfront = new Node(a, weight);
				newfront->next = front;
				front->prev = newfront;
				front = newfront;
			}
			else front = back = new Node(a, weight);
			++size;
		}

		void add_back(int a, int weight) {
			if (front != NULL) {
				Node* newback = new Node(a, weight);
				newback->prev = back;
				back->next = newback;
				back = newback;
			}
			else front = back = new Node(a, weight);
			++size;
		}

		Node pop_front() {
			if (size == 0) throw underflow_error("List empty");
			if ((*front).next == NULL) {
				clear();
				return *front;
			}
			Node* newfront = (*front).next;
			(*newfront).prev = NULL;
			front = newfront;
			--size;
			return *front;
		}

		Node pop_back() {
			if (size == 0) throw underflow_error("List empty");
			if ((*back).prev == NULL) {
				clear();
				return *back;
			}
			Node* _newback = (*back).prev;
			(*_newback).next = NULL;
			back = _newback;
			--size;
			return *back;
		}

		void clear() {
			front = NULL;
			back = NULL;
			size = 0;
		}

		int length() {
			return size;
		}

		Node* find(int j) {
            if(j>=size) throw underflow_error("Index out of bounds");
			Node* curr = front;
			for (int i = 0;i < j;++i) {
				curr = curr->next;
			}
			return curr;
		}

		void add(int val, int i, int weight) {
		    if(i>=size) throw underflow_error("Index out of bounds");
			if (i == 0) {
				add_front(val, weight);
				return;
			}
			else if (i == size - 1) {
				add_back(val, weight);
				return;
			}
			else if (front != NULL) {
				Node* rep = find(i);
				Node* newnode = new Node(val, weight);
				rep->prev->next = newnode;
				newnode->prev = rep->prev;
				newnode->next = rep;
				rep->prev = newnode;
			}
		}

		Node remove(int i) {
			if (size == 0) throw underflow_error("List empty");
			else if (i == 0) return pop_front();
			else if (i == size - 1) return pop_back();
			else {
				Node* del = find(i);
				del->prev->next = del->next;
				del->next->prev = del->prev;
				return *del;
			}
		}

		void print(){
		    Node* curr = front;
		    cout << '[' << curr->value << ", ";
		    curr = curr -> next;
		    for(int i=1;i<size-1;++i){
                cout << curr->value << ", ";
                curr = curr->next;
		    }
		    cout << back->value << ']' << endl;
		}

		Node get(int i){
		    Node* curr = find(i);
		    return *curr;
		}
};


