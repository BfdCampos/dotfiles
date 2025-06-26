"""Tests for utility functions."""

import unittest
import os
import tempfile
from pathlib import Path
import sys

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from lib.utils import expand_path, ensure_directory_exists


class TestUtils(unittest.TestCase):
    """Test utility functions."""
    
    def test_expand_path(self):
        """Test path expansion."""
        # Test home directory expansion
        self.assertEqual(
            expand_path("~/test"),
            os.path.expanduser("~/test")
        )
        
        # Test environment variable expansion
        os.environ['TEST_VAR'] = '/tmp/test'
        self.assertEqual(
            expand_path("$TEST_VAR/file"),
            "/tmp/test/file"
        )
        
    def test_ensure_directory_exists(self):
        """Test directory creation."""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_path = os.path.join(tmpdir, "test", "nested", "dir")
            ensure_directory_exists(test_path)
            self.assertTrue(os.path.exists(test_path))
            

if __name__ == '__main__':
    unittest.main()