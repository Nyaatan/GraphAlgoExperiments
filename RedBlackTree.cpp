#include <iostream>
#include <stdexcept>

using namespace std;

struct Node
{
    int data;
    int start;
    int end;
    Node *parent;
    Node *left;
    Node *right;
    int color;
};

typedef Node *NodePtr;

class RedBlackTree
{
private:
    NodePtr root;
    NodePtr TNULL;

    void initializeNULLNode(NodePtr node, NodePtr parent)
    {
        node->data = 0;
        node->parent = parent;
        node->left = NULL;
        node->right = NULL;
        node->color = 0;
    }

    NodePtr get_recursive(NodePtr node, int key)  // finds a node recursively
    {
        if (node == TNULL || key == node->data) return node;

        if (key < node->data) return get_recursive(node->left, key);

        return get_recursive(node->right, key);
    }

    void delete_fix(NodePtr x)  // fixes the tree after node deletion
    {
        NodePtr s;
        while (x != root && x->color == 0)
        {
            if (x == x->parent->left)
            {
                s = x->parent->right;
                if (s->color == 1)
                {
                    s->color = 0;
                    x->parent->color = 1;
                    rotate_left(x->parent);
                    s = x->parent->right;
                }

                if (s->left->color == 0 && s->right->color == 0)
                {
                    s->color = 1;
                    x = x->parent;
                }
                else
                {
                    if (s->right->color == 0)
                    {
                        s->left->color = 0;
                        s->color = 1;
                        rotate_right(s);
                        s = x->parent->right;
                    }

                    s->color = x->parent->color;
                    x->parent->color = 0;
                    s->right->color = 0;
                    rotate_left(x->parent);
                    x = root;
                }
            }
            else
            {
                s = x->parent->left;
                if (s->color == 1)
                {
                    s->color = 0;
                    x->parent->color = 1;
                    rotate_right(x->parent);
                    s = x->parent->left;
                }

                if (s->right->color == 0 && s->right->color == 0)
                {
                    s->color = 1;
                    x = x->parent;
                }
                else
                {
                    if (s->left->color == 0)
                    {
                        s->right->color = 0;
                        s->color = 1;
                        rotate_left(s);
                        s = x->parent->left;
                    }

                    s->color = x->parent->color;
                    x->parent->color = 0;
                    s->left->color = 0;
                    rotate_right(x->parent);
                    x = root;
                }
            }
        }
        x->color = 0;
    }

    void rb_transplant(NodePtr u, NodePtr v)
    {
        if (u->parent == NULL) root = v;
        else if (u == u->parent->left) u->parent->left = v;
        else u->parent->right = v;
        v->parent = u->parent;
    }


    void delete_recursive(NodePtr node, int key)  // deletes a node recursively and calls delete_fix()
    {
        NodePtr z = TNULL;
        NodePtr x, y;
        while (node != TNULL)
        {
            if (node->data == key) z = node;

            if (node->data <= key) node = node->right;
            else node = node->left;
        }
        if (z == TNULL) throw underflow_error("Key not found.");

        y = z;
        int y_original_color = y->color;
        if (z->left == TNULL)
        {
            x = z->right;
            rb_transplant(z, z->right);
        }
        else if (z->right == TNULL)
        {
            x = z->left;
            rb_transplant(z, z->left);
        }
        else
        {
            y = get_min(z->right);
            y_original_color = y->color;
            x = y->right;
            if (y->parent == z) x->parent = y;
            else
            {
                rb_transplant(y, y->right);
                y->right = z->right;
                y->right->parent = y;
            }

            rb_transplant(z, y);
            y->left = z->left;
            y->left->parent = y;
            y->color = z->color;
        }
        delete z;
        if (y_original_color == 0) delete_fix(x);
    }

    void delete_recursive_queue(NodePtr node, int key)  // deletes a node recursively and calls delete_fix()
    {
        NodePtr z = TNULL;
        NodePtr x, y;

        if (node->start == key) z = node;

        else if (node->start != key && node != TNULL) {
            printf("%d\n", key);
            tprint();
            delete_recursive_queue(node->right, key);
            delete_recursive_queue(node->left, key);
        }
        if(z == TNULL) return;
        y = z;
        int y_original_color = y->color;
        if (z->left == TNULL)
        {
            x = z->right;
            rb_transplant(z, z->right);
        }
        else if (z->right == TNULL)
        {
            x = z->left;
            rb_transplant(z, z->left);
        }
        else
        {
            y = get_min(z->right);
            y_original_color = y->color;
            x = y->right;
            if (y->parent == z) x->parent = y;
            else
            {
                rb_transplant(y, y->right);
                y->right = z->right;
                y->right->parent = y;
            }

            rb_transplant(z, y);
            y->left = z->left;
            y->left->parent = y;
            y->color = z->color;
        }
        delete z;
        if (y_original_color == 0) delete_fix(x);
    }

    void add_fix(NodePtr k)  // colors and rotates the tree after adding a node k
    {
        NodePtr u;
        while (k->parent->color == 1)
        {
            if (k->parent == k->parent->parent->right)
            {
                u = k->parent->parent->left;
                if (u->color == 1)
                {
                    u->color = 0;
                    k->parent->color = 0;
                    k->parent->parent->color = 1;
                    k = k->parent->parent;
                }
                else
                {
                    if (k == k->parent->left)
                    {
                        k = k->parent;
                        rotate_right(k);
                    }
                    k->parent->color = 0;
                    k->parent->parent->color = 1;
                    rotate_left(k->parent->parent);
                }
            }
            else
            {
                u = k->parent->parent->right;

                if (u->color == 1)
                {
                    u->color = 0;
                    k->parent->color = 0;
                    k->parent->parent->color = 1;
                    k = k->parent->parent;
                }
                else
                {
                    if (k == k->parent->right)
                    {
                        k = k->parent;
                        rotate_left(k);
                    }
                    k->parent->color = 0;
                    k->parent->parent->color = 1;
                    rotate_right(k->parent->parent);
                }
            }
            if (k == root) break;
        }
        root->color = 0;
    }

    void print_recursive(NodePtr root, string indent, bool last)  // prints nodes recursively
    {
        if (root != TNULL)
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

            string sColor = root->color ? "RED" : "BLACK";
            printf("[%d %d %d](%s)\n", root->data, root->start, root->end, sColor);
            print_recursive(root->left, indent, false);
            print_recursive(root->right, indent, true);
        }
    }

public:
    RedBlackTree()
    {
        TNULL = new Node;
        TNULL->color = 0;
        TNULL->left = NULL;
        TNULL->right = NULL;
        TNULL->parent = NULL;
        TNULL->data = -1;
        TNULL->start = -1;
        TNULL->end = -1;
        root = TNULL;
    }

    NodePtr get_root(){return this->root;}

    NodePtr get(int k)  // returns pointer to a node of given key
    {
        return get_recursive(this->root, k);
    }

    NodePtr get_min(NodePtr node)  // returns a node of the smallest value
    {
        while (node->left != TNULL) node = node->left;
        return node;
    }

    NodePtr get_max(NodePtr node)  // returns a node of the greatest value
    {
        while (node->right != TNULL) node = node->right;
        return node;
    }

    void rotate_left(NodePtr x)  // rotates a node to the left
    {
        NodePtr y = x->right;
        x->right = y->left;

        if (y->left != TNULL) y->left->parent = x;
        y->parent = x->parent;

        if (x->parent == NULL) this->root = y;
        else if (x == x->parent->left) x->parent->left = y;
        else x->parent->right = y;

        y->left = x;
        x->parent = y;
    }

    void rotate_right(NodePtr x)  // rotates a node to the right
    {
        NodePtr y = x->left;
        x->left = y->right;
        if (y->right != TNULL) y->right->parent = x;

        y->parent = x->parent;
        if (x->parent == NULL) this->root = y;
        else if (x == x->parent->right) x->parent->right = y;
        else x->parent->left = y;

        y->right = x;
        x->parent = y;
    }

    void add(int key, int start, int end)  // adds new node with given key, puts in proper place and colors the tree
    {
        //if(this->search(key, this->root)) return;
        NodePtr node = new Node;
        node->parent = NULL;
        node->data = key;
        node->start = start;
        node->end = end;
        node->left = TNULL;
        node->right = TNULL;
        node->color = 1;  // RED

        NodePtr y = NULL;
        NodePtr x = this->root;

        while (x != TNULL)  // put new node at proper place, depending on its value
        {
            y = x;
            if (node->data < x->data) x = x->left;
            else x = x->right;
        }

        node->parent = y;
        if (y == NULL) root = node;  // if new node has no parent finally, then it's a new root
        else if (node->data < y->data) y->left = node;  // else we check if new node should be left or right son of y
        else y->right = node;

        if (node->parent == NULL)  // root has to be colored black
        {
            node->color = 0;
            return;
        }

        if (node->parent->parent == NULL) return;

        add_fix(node);  // fix the tree and color it anew
    }

    void remove(int data)  // removes a node from the tree
    {
        delete_recursive(this->root, data);
    }

    Node queue_pop(){
        if(this->root == TNULL){
            return *TNULL;
        }
        NodePtr next = get_min(this->root);
        if(this->root != next){
            if(next->right != TNULL){
                next->parent->left = next->right;
                next->right->parent = next->parent;
                if(next->parent->left->color==1 && next->parent->color==1) next->parent->left->color = 0;
            } else next->parent->left = TNULL;
        }
        else{
            if(next->right != TNULL || next->right != NULL){
                next->right->parent = TNULL;
                this->root = next->right;
                delete_fix(this->root);
            } else this->root = TNULL;
        }
        return *next;
    }

    void queue_update_node(int node_id, int newval){
        delete_recursive_queue(this->root, node_id);
        add(newval, node_id, 0);
    }

    void tprint()  // prints out tree on stdout
    {
        if (root) print_recursive(this->root, "", true);
    }

    bool search(int key, NodePtr node){
        if(node==TNULL) return false;
        if(key == node->data) return true;
        else if(key < node->data) search(key, node->left);
        else search(key, node->right);
    }
};

