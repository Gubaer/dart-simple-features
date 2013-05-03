library test_avl_tree;

import "package:unittest/unittest.dart";
import "dart:collection";

import "dart:math";
part "../lib/src/avl_tree.dart";

main() {
  group("an int tree with default ordering -", () {
    test("create the tree", () {
      var tree = new AvlTree<int>();
      expect(tree.size, 0);
    });

    test("add one element", () {
      var tree = new AvlTree<int>();
      tree.add(0);
      expect(tree.size, 1);
    });

    test("adding [2,1,0] should result in a balanced tree", () {
      var tree = new AvlTree<int>();
      tree.add(2);
      tree.add(1);
      tree.add(0);
      expect(tree.size, 3);
      expect(tree._root.value, 1);
      expect(tree._root.left.value, 0);
      expect(tree._root.right.value, 2);
    });
  });

  group("an int tree with inverse ordering -", () {
    test("using a custom compare function", () {
      var compare = (a, b) => b.compareTo(a);
      var tree = new AvlTree<int>(compare:compare);
      tree.add(2);
      tree.add(1);
      tree.add(0);
      expect(tree.size, 3);
      expect(tree._root.value, 1);
      expect(tree._root.left.value, 2);
      expect(tree._root.right.value, 0);
    });

    test("using a custom compare function in the add operation", () {
      var compare = (a, b) => b.compareTo(a);
      var tree = new AvlTree<int>();
      tree.add(2, compare);
      tree.add(1, compare);
      tree.add(0, compare);
      expect(tree.size, 3);
      expect(tree._root.value, 1);
      expect(tree._root.left.value, 2);
      expect(tree._root.right.value, 0);
    });
  });

  group("removing -", () {
    test("removing from an empty tree is possible and returns false", () {
      var tree = new AvlTree<int>();
      var ret = tree.remove(0);
    });

    test("removing the single root element from a tree is possible and yields an empty tree", () {
      var tree = new AvlTree<int>();
      tree.add(0);
      var ret = tree.remove(0);
      expect(tree.size, 0);
      expect(tree._root, isNull);
    });

    test("removing two leafs, then the root is possible", () {
      var tree = new AvlTree<int>();
      tree.add(2);
      tree.add(1);
      tree.add(0);
      tree.remove(0);
      expect(tree.size, 2);
      expect(tree._root.value, 1);
      expect(tree._root.right.value, 2);
      expect(tree._root.left, isNull);

      var ret = tree.remove(2);
      expect(ret, true);
      expect(tree.size, 1);
      expect(tree._root.value, 1);
      expect(tree._root.right, isNull);
      expect(tree._root.left, isNull);

      ret = tree.remove(1);
      expect(ret, true);
      expect(tree.size, 0);
      expect(tree._root, isNull);
    });
  });

  /* ------------------------------------------------------------------- */
  group("balance and integriy -", () {
    ensureBalanceAndConsistency(node) {
      if (node == null) return;
      var lh = node.left == null ? 0 : node.left.height;
      var rh = node.right == null ? 0 : node.right.height;
      expect((lh - rh).abs() <= 1, true);
      expect(lh < node.height, true);
      expect(rh < node.height, true);
      if (node.left != null) ensureBalanceAndConsistency(node.left);
      if (node.right != null) ensureBalanceAndConsistency(node.right);
    }

    test("add 10 random rumbers and check balance and integrity of the tree", () {
      var random = new Random();
      Set numbers = new Set();
      while(numbers.length < 10) {
        numbers.add(random.nextInt(100));
      }
      var tree = new AvlTree<int>();
      numbers.forEach((n) {
        tree.add(n);
        ensureBalanceAndConsistency(tree._root);
      });
      var values = tree.inorder.toList();
      expect(values.length, 10);
      var sortedNumbers = numbers.toList();
      sortedNumbers.sort();
      for(int i=0; i< 10; i++) {
        expect(values[i], sortedNumbers[i]);
      }
   });

    test("remove 10 random rumbers and check balance and integrity of the tree", () {
      var random = new Random();
      var numbers = new Set();
      while(numbers.length < 10) {
        numbers.add(random.nextInt(100));
      }
      var tree = new AvlTree<int>();
      numbers.forEach((n) {
        tree.add(n);
        ensureBalanceAndConsistency(tree._root);
      });
      numbers = numbers.toList();
      while(!numbers.isEmpty) {
        var i = random.nextInt(numbers.length);
        var v = numbers[i];
        numbers.remove(v);
        expect(tree.remove(v), true);
        ensureBalanceAndConsistency(tree._root);
      }
    });
  });

  /* ------------------------------------------------------------------- */
  group("contains -", () {
    test("in an empty tree", () {
      var tree = new AvlTree<int>();
      expect(tree.contains(0), false);
    });

    test("in a tree with one element", () {
      var tree = new AvlTree<int>();
      tree.add(0);
      expect(tree.contains(0), true);
      expect(tree.contains(1), false);
    });

    test("in a tree with multiple elements", () {
      var tree = new AvlTree<int>();
      for (int i=0; i < 10; i++) tree.add(i);
      expect(tree.contains(5), true);
      expect(tree.contains(11), false);
      expect(tree.contains(4), true);
      expect(tree.contains(-1), false);
    });
  });

  /* ------------------------------------------------------------------- */
  group("inorder iterator -", () {
    test("of an empty tree", () {
      var tree = new AvlTree<int>();
      expect(tree.inorder.isEmpty, true);
    });

    test("in a tree with one element ", () {
      var tree = new AvlTree<int>();
      tree.add(0);
      expect(tree.inorder.length, 1);
      expect(tree.inorder.first, 0);
    });

    test("in a tree with multiple elements", () {
      var tree = new AvlTree<int>();
      for (int i=0; i < 10; i++) tree.add(i);
      var inorder = tree.inorder.toList();
      expect(inorder.length, 10);
      for (int i=0; i< 10; i++) {
        expect(inorder[i], i);
      }
    });
  });

  /* ------------------------------------------------------------------- */
  group("custom comparison -", () {
    int inverseStringCompare(String s, String t)
      => t.compareTo(s);

    test("of a tree with custom compare function", () {
      var tree = new AvlTree<String>(compare:inverseStringCompare);
      tree.add("a");
      tree.add("bCD");
      var values = tree.inorder.toList();
      expect(values[0], "bCD");
      expect(values[1], "a");
    });
  });

  int lowerCaseStringCompare(String s, String t)
  => s.toLowerCase().compareTo(t.toLowerCase());


  /* ------------------------------------------------------------------- */
  group("tree with equivalence classes -", () {

    test("identical", () {
      expect(identical("abc", "abc"), true);
    });


    test("adding two equal, but non-identical values", () {
      var tree = new AvlTree<String>(
          compare:lowerCaseStringCompare,
          allowEquivalenceClasses: true
      );
      tree.add("abc");
      tree.add("ABC");
      expect(tree.size, 2);
      expect(tree.contains("abc"), true);
      expect(tree.contains("ABC"), true);
      expect(tree.contains("aBC"), false);
    });

    test("removing an equal, but non-identical value", () {
      var tree = new AvlTree<String>(
          compare:lowerCaseStringCompare,
          allowEquivalenceClasses: true
      );
      tree.add("abc");
      tree.add("ABC");
      expect(tree.size, 2);
      expect(tree.contains("abc"), true);
      expect(tree.contains("ABC"), true);

      expect(tree.remove("abc"), true);
      expect(tree.remove("AbC"), false); // "AbC" isn't in tree
      expect(tree.size, 1);
    });
  });

  /* ------------------------------------------------------------------- */
  group("smallest -", () {
    test("of an empty tree is an empty iterator", () {
      var tree = new AvlTree();
      expect(tree.smallest.isEmpty, true);
    });

    test("of a tree with >0 elements is an iterator with one value", () {
      var tree = new AvlTree<int>();
      tree.add(0);
      expect(tree.smallest.length, 1);
      expect(tree.smallest.first, 0);
    });

    test("of a tree with equivalence classes with >0 elements is an "
        "iterator with multiple value", () {
      var tree = new AvlTree<String>(
          compare:lowerCaseStringCompare,
          allowEquivalenceClasses: true
      );
      tree.add("abc");
      tree.add("ABC");
      expect(tree.smallest.length, 2);
      expect(tree.smallest.contains("abc"), true);
      expect(tree.smallest.contains("ABC"), true);
    });
  });

  /* ------------------------------------------------------------------- */
  group("largest -", () {
    test("of an empty tree is an empty iterator", () {
      var tree = new AvlTree();
      expect(tree.largest.isEmpty, true);
    });

    test("of a tree with >0 elements is an iterator with one value", () {
      var tree = new AvlTree<int>();
      tree.add(0);
      expect(tree.largest.length, 1);
      expect(tree.largest.first, 0);
    });

    test("of a tree with equivalence classes with >0 elements is an "
        "iterator with multiple values", () {
      var tree = new AvlTree<String>(
          compare:lowerCaseStringCompare,
          allowEquivalenceClasses: true
      );
      tree.add("abc");
      tree.add("ABC");
      expect(tree.largest.length, 2);
      expect(tree.largest.contains("abc"), true);
      expect(tree.largest.contains("ABC"), true);
    });
  });


  /* ------------------------------------------------------------------- */
  group("leftNeighbour -", () {
    test("in an int tree", () {
      var tree = new AvlTree<int>();
      for(int i=0; i<10; i++) tree.add(i);
      expect(tree.leftNeighbour(-1).isEmpty, true);
      expect(tree.leftNeighbour(0).isEmpty, true);
      for (int i=1; i < 10; i++) {
        expect(tree.leftNeighbour(i).first, i-1, reason: "left neighour $i failed");
      }
      expect(tree.leftNeighbour(10).first, 9);
      expect(tree.leftNeighbour(11).first, 9);
    });
  });

  /* ------------------------------------------------------------------- */
  group("reightNeighbour -", () {
    solo_test("in an int tree", () {
      var tree = new AvlTree<int>();
      for(int i=0; i<10; i++) tree.add(i);
      expect(tree.rightNeighbour(10).isEmpty, true);
      expect(tree.rightNeighbour(9).isEmpty, true);
      for (int i=8; i >= 0; i--) {
        expect(tree.rightNeighbour(i).first, i+1, reason: "reight neighour $i failed");
      }
      expect(tree.rightNeighbour(-1).first, 0);
      expect(tree.rightNeighbour(-2).first, 0);
    });
  });
}