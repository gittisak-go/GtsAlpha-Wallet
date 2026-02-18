from dataclasses import dataclass
from typing import Optional

@dataclass
class TreeNode:
    value: int
    left: Optional['TreeNode'] = None
    right: Optional['TreeNode'] = None

class BST:
    def __init__(self):
        self.root: Optional[TreeNode] = None

    def insert(self, value: int) -> None:
        if not self.root:
            self.root = TreeNode(value)
        else:
            self._insert_helper(self.root, value)

    def _insert_helper(self, node: TreeNode, value: int) -> None:
        if value < node.value:
            if node.left is None:
                node.left = TreeNode(value)
            else:
                self._insert_helper(node.left, value)
        else:
            if node.right is None:
                node.right = TreeNode(value)
            else:
                self._insert_helper(node.right, value)

    def find(self, value: int) -> Optional[TreeNode]:
        return self._find_helper(self.root, value)

    def _find_helper(self, node: Optional[TreeNode], value: int) -> Optional[TreeNode]:
        if node is None or node.value == value:
            return node
        if value < node.value:
            return self._find_helper(node.left, value)
        return self._find_helper(node.right, value)

    def _lookup_min(self, node: TreeNode) -> TreeNode:
        current = node
        while current.left:
            current = current.left
        return current

    def print_inorder(self) -> None:
        self._print_inorder_helper(self.root)
        print()

    def _print_inorder_helper(self, node: Optional[TreeNode]) -> None:
        if node:
            self._print_inorder_helper(node.left)
            print(node.value, end=' ')
            self._print_inorder_helper(node.right)
