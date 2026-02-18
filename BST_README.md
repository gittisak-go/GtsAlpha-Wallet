# Binary Search Tree Implementation

This repository contains a Python implementation of a Binary Search Tree (BST) with comprehensive unit tests.

## Files

- `bst.py` - Binary Search Tree implementation
- `test_bst.py` - Comprehensive unit tests

## BST Features

The BST implementation includes:
- **TreeNode**: A dataclass representing a node in the tree with value, left child, and right child
- **BST Class**: 
  - `insert(value)`: Insert a value into the tree (duplicates go to the right subtree)
  - `find(value)`: Find a node with the given value
  - `print_inorder()`: Print tree values in sorted order (inorder traversal)

## Running Tests

Run the comprehensive test suite:

```bash
python3 test_bst.py
```

## Test Coverage

The test suite includes 21 unit tests covering:

### Core Functionality
- Tree initialization
- Single and multiple value insertions
- Finding existing and non-existing values
- Inorder traversal printing

### Edge Cases
- Operations on empty trees
- Duplicate value handling
- Negative values
- Large values
- Sequential insertions (ascending and descending)
- Left-skewed and right-skewed trees

### Results
All 21 tests pass successfully, ensuring the correctness of the BST implementation.
