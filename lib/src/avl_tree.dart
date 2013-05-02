part of avl_tree;

class _AvlTreeNode<T> {
  _AvlTreeNode<T> parent;
  _AvlTreeNode<T> left;
  _AvlTreeNode<T> right;
  int height=0;

  // value is either a single value of type T or a list of value List<T>
  var _value;

  _AvlTreeNode(T value, this.parent) {
    _value = value;
  }

  /**
   * Return balance factor for this node. If the return value is negative,
   * the left subtree is higher than the right subtree, if it is 0, both
   * the subtrees have the same height, if is positive, the right subtree
   * is heigher than the left subtree.
   */
  int get _balanceFactor {
    var lh = left == null ? 0 : left.height;
    var rh = right == null ? 0 : right.height;
    return rh - lh;
  }

  _updateHeight() {
    var lh = left == null ? 0: left.height;
    var rh = right == null ? 0: right.height;
    height = lh > rh ? lh + 1 : rh + 1;
  }

  bool get isRoot => parent == null;
  bool get isLeaf => left == null && right == null;

  bool get hasSingleValue => _value is T;
  bool get hasMultipleValues => _value is List<T>;

  T get compareValue => _value is List ? _value.first : _value;

  bool containsIdentical(T value) {
    if (_value is List) return _value.any((v) => identical(v, value));
    return identical(_value, value);
  }

  addEquivalent(T value) {
    if (_value is T) {
      _value = [_value, value];
    } else if (_value is List<T>) {
      _value.add(value);
    } else {
      throw new StateError("unexpected value");
    }
  }

  bool removeEquivalent(T value) {
    if (! hasMultipleValues) throw new StateError("can't remove from a single value");
    _value.remove(value);
  }

  T get value => _value;

  Iterable<T> get valuesAsIterable {
    if (_value is List) {
      return new UnmodifiableListView(_value);
    } else {
      return new UnmodifiableListView([_value]);
    }
  }
}

/**
 * [AvlTree] is an implementation of a [AVL Tree](http://en.wikipedia.org/wiki/AVL_tree),
 * a self-balancing binary search-tree.
 *
 * The implementation is basically a port from the [implementation in Java
 * by Justin Wheterell](https://code.google.com/p/java-algorithms-implementation/).
 *
 * This implementation provides two custom features usually not present in
 * AVL trees:
 *
 * 1. The method `add` not only accepts the value to be added to the tree,
 *    but also a compare function to be used in this very invocation only.
 *    This comes in handy, if a more efficient compare function can be
 *    used in a specific invocation of `add`. For instance, it can be used
 *    to maintain the dynamically changing search tree of intersecting
 *    line segments in the [Bentley-Ottman-Algorithm](http://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm).
 *
 * 2. The tree can (optionally) store multiple values which are equal with respect
 *    to the tree ordering, but not identical with respect to Darts `identical()`
 *    function. One application is again the implementation of the Y-structure
 *    in the [Bentley-Ottman-Algorithm](http://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm).
 *
 * ## Example
 * [:
 * // create a tree, add three values and remove one
 * var tree = new AvlTree<int>();
 * tree.add(0);
 * tree.add(1);
 * tree.add(2);
 * print tree.inorder.toList()  // -> [0,1,2]
 * tree.remove(2);
 * :]
 */
class AvlTree<T> {

  static const _LEFT_LEFT = 1;
  static const _LEFT_RIGHT = 2;
  static const _RIGHT_LEFT = 3;
  static const _RIGHT_RIGHT = 4;

  static const _NONE = 0;
  static const _LEFT = 1;
  static const _RIGHT = 2;

  _AvlTreeNode<T> _root;
  int _size = 0;
  int _modifications = 0;

  var _compare = null;
  var _allowEquivalenceClasses = false;

  /**
   * Creates a tree.
   *
   * [compare] is an optional compare function for two values of
   * type [T]. If missing or null, T must extend [Comparable] and
   * the tree compares two values `v1` and `v2` using `T`s
   * `compareTo` function.
   *
   * If [allowEquivalenceClasses] is true, the tree stores multiple values
   * which are equal with respect to `compare` but not identical with
   * respect to Darts `identical()`-function.
   */
  AvlTree({int compare(T v1, T v2), allowEquivalenceClasses:false}) {
    if (compare != null) {
      _compare = compare;
    } else {
      _compare = (T v1,  T v2) => v1.compareTo(v2);
    }
    this._allowEquivalenceClasses = allowEquivalenceClasses;
  }

  /// returns the size of the tree
  int get size => _size;

  /**
   * Adds a [value] to the tree.
   *
   * If supplied, [customCompare] is used to compare values during this
   * add operation instead of the standard compare function.
   * [customCompare] should be consistent with the ordering of values already
   * present in this tree, but it may supply a more efficient implementation
   * of the comparison operation for this very invocation of [add].
   */
  add(T value, [int customCompare(T v1, T v2)]) {
    var localCompare = customCompare;
    if (localCompare == null) localCompare = _compare;

    _AvlTreeNode<T> addValue(T value) {
      var newNode = new _AvlTreeNode(value, null);

      // If root is null, assign
      if (_root == null) {
        _root = newNode;
        _size++;
        return newNode;
      }

      var  node = _root;
      while (node != null) {
        var c = localCompare(newNode.compareValue, node.compareValue);
        switch(c) {
          case -1:
            if (node.left != null) {
              node = node.left;
              continue;
            }
            // New left node
            node.left = newNode;
            newNode.parent = node;
            _size++;
            return newNode;

          case 1:
            if (node.right != null) {
              node = node.right;
              continue;
            }
            // New right node
            node.right = newNode;
            newNode.parent = node;
            _size++;
            return newNode;

          case 0:
            if (!_allowEquivalenceClasses) {
              throw new StateError(
                  "can't add value, value already present: $value"
              );
            }
            if (node.containsIdentical(value)) {
              throw new StateError(
                  "can't add value, value already present: $value"
              );
            }
            node.addEquivalent(value);
            _size++;
            return null;

        }
      }
      return newNode;
    }

    var newNode = addValue(value);
    _forEachAncestor(newNode, (n) {
      n._updateHeight();
      _balanceAfterInsert(n);
    });
  }

  static _forEachAncestor(node, doit(n)) {
    if (node == null) return;
    doit(node);
    _forEachAncestor(node.parent, doit);
  }

  /**
   * Balance the sub-tree with root [node]  according to the AVL post-insert
   * algorithm.
   */
  _balanceAfterInsert(node) {
    int balanceFactor = node._balanceFactor;
    if (balanceFactor > 1 || balanceFactor < -1) {
      var parent, child;
      int balance = 0;
      if (balanceFactor < 0) {
        parent = node.left;
        balanceFactor = parent._balanceFactor;
        if (balanceFactor < 0) {
          child = parent.left;
          balance = _LEFT_LEFT;
        } else {
          child = parent.right;
          balance = _LEFT_RIGHT;
        }
      } else {
        parent =  node.right;
        balanceFactor = parent._balanceFactor;
        if (balanceFactor < 0) {
          child =  parent.left;
          balance = _RIGHT_LEFT;
        } else {
          child =  parent.right;
          balance = _RIGHT_RIGHT;
        }
      }

      if (balance == _LEFT_RIGHT) {
        // Left-Right (Left rotation, right rotation)
        _rotateLeft(parent);
        _rotateRight(node);
      } else if (balance == _RIGHT_LEFT) {
        // Right-Left (Right rotation, left rotation)
        _rotateRight(parent);
        _rotateLeft(node);
      } else if (balance == _LEFT_LEFT) {
        // Left-Left (Right rotation)
        _rotateRight(node);
      } else {
        // Right-Right (Left rotation)
        _rotateLeft(node);
      }

      node._updateHeight(); // New child node
      child._updateHeight(); // New child node
      parent._updateHeight(); // New Parent node
    }
  }

  /**
   * Rotate tree left at sub-tree rooted at [node]
   */
  _rotateLeft(_AvlTreeNode<T> node) {
    int parentPosition = _NONE;
    var parent = node.parent;
    if (parent != null) {
      parentPosition = node == parent.left ? _LEFT : _RIGHT;
    }

    var right = node.right;
    node.right = null;
    var left = right.left;

    right.left = node;
    node.parent = right;

    node.right = left;
    if (left != null) left.parent = node;

    if (parentPosition != _NONE) {
      if (parentPosition == _LEFT) {
        parent.left = right;
      } else {
        parent.right = right;
      }
      right.parent = parent;
    } else {
      _root = right;
      right.parent = null;
    }
  }

  /**
   * Rotate tree right at sub-tree rooted at [node].
   */
  _rotateRight(_AvlTreeNode<T> node) {
    int parentPosition = _NONE;
    var parent = node.parent;
    if (parent != null) {
      parentPosition = node == parent.left ? _LEFT : _RIGHT;
    }

    var left = node.left;
    node.left = null;
    var right = left.right;

    left.right = node;
    node.parent = left;

    node.left = right;
    if (right != null)
      right.parent = node;

    if (parentPosition != _NONE) {
      if (parentPosition == _LEFT) {
        parent.left = left;
      } else {
        parent.right = left;
      }
      left.parent = parent;
    } else {
      _root = left;
      left.parent = null;
    }
  }

  /**
   * Removes the [value] from the tree.
   *
   * Returns true if the [value] was removed, false otherwise.
   */
  bool remove(T value) {
    // Find node to remove
    var nodeToRemove = this._lookupNode(value);
    if (nodeToRemove == null) return false;
    if (_allowEquivalenceClasses) {
      if (!nodeToRemove.containsIdentical(value)) return false;
      if (nodeToRemove.hasMultipleValues) {
        nodeToRemove.removeEquivalent(value);
        _size--;
        return true;
      }
      // Else continue as usual and remove the whole node from
      // the tree
    }
    // Find the replacement node
    var replacementNode = this._lookupReplacementNode(nodeToRemove);

    // Find the parent of the replacement node to re-factor the
    // height/balance of the tree
    var nodeToRefactor = null;
    if (replacementNode != null)
      nodeToRefactor =  replacementNode .parent;
    if (nodeToRefactor == null)
      nodeToRefactor =  nodeToRemove .parent;
    if (nodeToRefactor != null && nodeToRefactor == nodeToRemove)
      nodeToRefactor = replacementNode;

    // Replace the node
    _replaceNodeWithNode(nodeToRemove, replacementNode);

    // Re-balance the tree all the way up the tree
    _forEachAncestor(nodeToRefactor, (n) {
      n._updateHeight();
      _balanceAfterDelete(n);
    });
    return true;
  }

  /**
   * Replace [node] with [replacement] in the tree.
   */
  _replaceNodeWithNode(_AvlTreeNode<T> node, _AvlTreeNode<T> replacement) {
    if (replacement != null) {
      // Save for later
      var replacementLeft = replacement.left;
      var replacementRight = replacement.right;

      // Replace replacement's branches with nodeToRemove's branches
      var nodeToRemoveLeft = node.left;
      if (nodeToRemoveLeft != null && nodeToRemoveLeft != replacement) {
        replacement.left = nodeToRemoveLeft;
        nodeToRemoveLeft.parent = replacement;
      }
      var nodeToRemoveRight = node.right;
      if (nodeToRemoveRight != null && nodeToRemoveRight != replacement) {
        replacement.right = nodeToRemoveRight;
        nodeToRemoveRight.parent = replacement;
      }

      // Remove link from replacement's parent to replacement
      var replacementParent = replacement.parent;
      if (replacementParent != null && replacementParent != node) {
        var replacementParentLeft = replacementParent.left;
        var replacementParentRight = replacementParent.right;
        if (replacementParentLeft != null && replacementParentLeft == replacement) {
          replacementParent.left = replacementRight;
          if (replacementRight != null)
            replacementRight.parent = replacementParent;
        } else if (replacementParentRight != null && replacementParentRight == replacement) {
          replacementParent.right = replacementLeft;
          if (replacementLeft != null)
            replacementLeft.parent = replacementParent;
        }
      }
    }

    // Update the link in the tree from the node to the
    // replacement
    if (node.parent == null) {
      // Replacing the root node
      _root = replacement;
      if (_root != null) _root.parent = null;
    } else {
      if (replacement != null) replacement.parent = node.parent;
      var parent = node.parent;
      if (parent.left == node) {
        parent.left = replacement;
      } else if (parent.right == node) {
        parent.right = replacement;
      }
    }
    _size--;
  }

  /**
   * Returns true, if the tree contains [value].
   */
  bool contains(T value) => _lookupNode(value) != null;

  /**
   * Returns the smallest value in the tree or null, if
   * the tree is empty.
   *
   * In the standard case, the returned iterable has either 0 or
   * 1 values, but if this tree is created with the flag
   * `allowEquivalenceClasses` it may consist of more than one value.
   */
  Iterable<T> get smallest {
    var n = _root;
    if (n == null) return _EMPTY_ITERABLE;
    while (n.left != null) n = n.left;
    return n.valuesAsIterable;
  }

  static final _EMPTY_ITERABLE = [];
  /**
   * Returns the largest equivalence class of values or an empty
   * iterable, if the tree is null.
   *
   * In the standard case, the returned iterable has either 0 or
   * 1 values, but if this tree is created with the flag
   * `allowEquivalenceClasses` it may consist of more than one value.
   */
  Iterable<T> get largest {
    var n = _root;
    if (n == null) return _EMPTY_ITERABLE;
    while(n.right != null) n = n.right;
    return n.valuesAsIterable;
  }

  /**
   * Locate the node with [value] in the tree.
   */
  _lookupNode(T value) {
    var node = _root;
    while (node != null) {
      var c = this._compare(value, node.compareValue);
      switch(c) {
        case 0:
          if (!_allowEquivalenceClasses) return node;
          if (node.containsIdentical(value)) return node;
          return null;
        case -1: node = node.left; break;
        case 1: node = node.right; break;
      }
    }
    return null;
  }

  /**
   * Get the proper replacement node according to the binary search tree
   * algorithm from the tree.
   */
  _lookupReplacementNode(_AvlTreeNode<T> node) {
    if (node.left != null && node.right == null) {
      return node.left;
    } else if (node.right != null && node.left == null) {
      return node.right;
    } else if (node.right != null && node.left != null) {
      // Two children
      // Add some randomness to deletions, so we don't always use the
      // greatest/least on deletion
      var replacement;
      if (_modifications % 2 != 0) {
        replacement = this._lookupRightMostLeaf(node.left);
      } else {
        replacement = this._lookupLeftMostLeaf(node.right);
      }
      _modifications++;
      return replacement;
    } else {
      return null;
    }
  }

  /**
   * Get greatest node in sub-tree rooted at startingNode. Returns
   * [node] if [node] has no right subtree. Returns null, if
   * [node] is null.
   */
  _lookupRightMostLeaf(_AvlTreeNode<T> node) {
    if (node == null) return null;
    while (node.right != null) node = node.right;
    return node;
  }

  /**
   * Get smallest node in sub-tree rooted at startingNode. Returns
   * [node] if [node] has no left subtree. Returns null, if
   * [node] is null.
   */
  _lookupLeftMostLeaf(_AvlTreeNode<T> node) {
    if (node == null) return null;
    while (node.left != null) node = node.left;
    return node;
  }

  /**
   * Balance the sub-tree with root [node] according to the AVL post-delete
   * algorithm.
   */
  _balanceAfterDelete(_AvlTreeNode<T> node) {
    int balanceFactor = node._balanceFactor;
    if (balanceFactor == -2) {
      var ll = node.left.left;
      int lesser = (ll != null) ? ll.height : 0;
      var lr =  node.left.right;
      int greater = (lr != null) ? lr.height : 0;
      if (lesser >= greater) {
        _rotateRight(node);
        node._updateHeight();
        if (node.parent != null) node.parent._updateHeight();
      } else {
        _rotateLeft(node.left);
        _rotateRight(node);

        var p = node.parent;
        if (p.left != null) p.left._updateHeight();
        if (p.right != null) p.right._updateHeight();
        p._updateHeight();
      }
    } else if (balanceFactor == 2) {
      var rr =  node.right.right;
      int greater = (rr != null) ? rr.height : 0;
      var rl =  node.right.left;
      int lesser = (rl != null) ? rl.height : 0;
      if (greater >= lesser) {
        _rotateLeft(node);
        node._updateHeight();
        if (node.parent != null) node.parent._updateHeight();
      } else {
        _rotateRight(node.right);
        _rotateLeft(node);

        var p =  node.parent;
        if (p.left != null) p.left._updateHeight();
        if (p.right != null) p.right._updateHeight();
        p._updateHeight();
      }
    }
  }

  /**
   * Returns an iterable of all values traversing the tree
   * inorder. This is equivalent to an iterable of the
   * sorted values in the tree.
   */
  Iterable<T> get inorder => new _InorderIterable<T>(this);
}


class _InorderIterator<T> implements Iterator<T>{
  AvlTree<T> tree;
  var cursor = null;
  bool isFirst = true;
  _InorderIterator(this.tree) {
    cursor = tree._root;
    if (cursor == null) return;
    while(cursor.left != null) cursor = cursor.left;
  }

  T get current {
    if (cursor == null) return null;
    if (cursor.hasSingleValue) return cursor.value;
    if (cursor.hasMultipleValues) return cursor.valuesAsIterable.toList();
  }

  bool moveNext() {
    if (cursor == null) return false;
    if (isFirst) {
      isFirst = false;
      return true;
    }
    if (cursor.right != null) {
      cursor = cursor.right;
      while(cursor.left != null) cursor = cursor.left;
      return true;
    } else  {
       while(true) {
         if (cursor.parent == null) {
           cursor = null;
           return false;
         }
         if (cursor.parent.left == cursor) {
           cursor = cursor.parent;
           return true;
         }
         cursor = cursor.parent;
      }
    }
  }
}

class _InorderIterable<T> extends Object with IterableMixin<T>
  implements Iterable<T> {
  Iterator<T> _iterator;
  _InorderIterable(AvlTree<T> tree) :
    _iterator = new _InorderIterator<T>(tree);

  Iterator<T> get iterator => _iterator;
}
