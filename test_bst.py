import unittest
import sys
from io import StringIO
from bst import BST, TreeNode


class TestBST(unittest.TestCase):
    
    def setUp(self):
        self.bst = BST()
    
    def test_empty_tree_initialization(self):
        self.assertIsNone(self.bst.root)
    
    def test_insert_single_value(self):
        self.bst.insert(10)
        self.assertIsNotNone(self.bst.root)
        self.assertEqual(self.bst.root.value, 10)
        self.assertIsNone(self.bst.root.left)
        self.assertIsNone(self.bst.root.right)
    
    def test_insert_multiple_values(self):
        self.bst.insert(10)
        self.bst.insert(5)
        self.bst.insert(15)
        
        self.assertEqual(self.bst.root.value, 10)
        self.assertEqual(self.bst.root.left.value, 5)
        self.assertEqual(self.bst.root.right.value, 15)
    
    def test_insert_maintains_bst_property(self):
        values = [10, 5, 15, 3, 7, 12, 20]
        for val in values:
            self.bst.insert(val)
        
        self.assertEqual(self.bst.root.value, 10)
        self.assertEqual(self.bst.root.left.value, 5)
        self.assertEqual(self.bst.root.left.left.value, 3)
        self.assertEqual(self.bst.root.left.right.value, 7)
        self.assertEqual(self.bst.root.right.value, 15)
        self.assertEqual(self.bst.root.right.left.value, 12)
        self.assertEqual(self.bst.root.right.right.value, 20)
    
    def test_insert_duplicate_values(self):
        self.bst.insert(10)
        self.bst.insert(5)
        self.bst.insert(10)
        self.bst.insert(10)
        
        # Duplicates go to the right subtree
        self.assertEqual(self.bst.root.value, 10)
        self.assertEqual(self.bst.root.left.value, 5)
        self.assertIsNotNone(self.bst.root.right)
        self.assertEqual(self.bst.root.right.value, 10)
    
    def test_find_existing_value(self):
        values = [10, 5, 15, 3, 7, 12, 20]
        for val in values:
            self.bst.insert(val)
        
        node = self.bst.find(7)
        self.assertIsNotNone(node)
        self.assertEqual(node.value, 7)
    
    def test_find_root_value(self):
        self.bst.insert(10)
        node = self.bst.find(10)
        self.assertIsNotNone(node)
        self.assertEqual(node.value, 10)
    
    def test_find_non_existing_value(self):
        values = [10, 5, 15, 3, 7, 12, 20]
        for val in values:
            self.bst.insert(val)
        
        node = self.bst.find(100)
        self.assertIsNone(node)
    
    def test_find_in_empty_tree(self):
        node = self.bst.find(10)
        self.assertIsNone(node)
    
    def test_find_after_single_insert(self):
        self.bst.insert(42)
        node = self.bst.find(42)
        self.assertIsNotNone(node)
        self.assertEqual(node.value, 42)
    
    def test_print_inorder_empty_tree(self):
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        self.assertEqual(captured_output.getvalue(), '\n')
    
    def test_print_inorder_single_node(self):
        self.bst.insert(10)
        
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        self.assertEqual(captured_output.getvalue(), '10 \n')
    
    def test_print_inorder_multiple_nodes(self):
        values = [10, 5, 15, 3, 7, 12, 20]
        for val in values:
            self.bst.insert(val)
        
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        # Inorder traversal should print in sorted order
        self.assertEqual(captured_output.getvalue(), '3 5 7 10 12 15 20 \n')
    
    def test_print_inorder_with_duplicates(self):
        values = [10, 5, 10, 3, 10]
        for val in values:
            self.bst.insert(val)
        
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        # Duplicates should appear in the output
        self.assertEqual(captured_output.getvalue(), '3 5 10 10 10 \n')
    
    def test_lookup_min_single_node(self):
        self.bst.insert(10)
        min_node = self.bst._lookup_min(self.bst.root)
        self.assertEqual(min_node.value, 10)
    
    def test_lookup_min_multiple_nodes(self):
        values = [10, 5, 15, 3, 7, 12, 20]
        for val in values:
            self.bst.insert(val)
        
        min_node = self.bst._lookup_min(self.bst.root)
        self.assertEqual(min_node.value, 3)
    
    def test_lookup_min_from_subtree(self):
        values = [10, 5, 15, 3, 7, 12, 20]
        for val in values:
            self.bst.insert(val)
        
        # Find min in right subtree
        min_node = self.bst._lookup_min(self.bst.root.right)
        self.assertEqual(min_node.value, 12)
    
    def test_insert_negative_values(self):
        values = [0, -5, 5, -10, -3]
        for val in values:
            self.bst.insert(val)
        
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        self.assertEqual(captured_output.getvalue(), '-10 -5 -3 0 5 \n')
    
    def test_insert_large_values(self):
        values = [1000000, 500000, 1500000]
        for val in values:
            self.bst.insert(val)
        
        node = self.bst.find(500000)
        self.assertIsNotNone(node)
        self.assertEqual(node.value, 500000)
    
    def test_sequential_insertion(self):
        # Insert in ascending order (creates right-skewed tree)
        values = [1, 2, 3, 4, 5]
        for val in values:
            self.bst.insert(val)
        
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        self.assertEqual(captured_output.getvalue(), '1 2 3 4 5 \n')
    
    def test_reverse_sequential_insertion(self):
        # Insert in descending order (creates left-skewed tree)
        values = [5, 4, 3, 2, 1]
        for val in values:
            self.bst.insert(val)
        
        captured_output = StringIO()
        sys.stdout = captured_output
        self.bst.print_inorder()
        sys.stdout = sys.__stdout__
        
        self.assertEqual(captured_output.getvalue(), '1 2 3 4 5 \n')


def main():
    # Create a test suite
    suite = unittest.TestLoader().loadTestsFromTestCase(TestBST)
    
    # Run the tests with verbosity
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Print summary
    print("\n" + "="*70)
    print("Test Summary")
    print("="*70)
    print(f"Tests run: {result.testsRun}")
    print(f"Successes: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print("="*70)
    
    # Return exit code based on test results
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(main())
