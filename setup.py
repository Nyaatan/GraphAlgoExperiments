from setuptools import setup
from Cython.Build import cythonize

files = ["matrix.pyx", "linked_list.pyx", "priorityqueue.pyx", "algorithms.pyx", "cpath.pyx"]

for file in files:
    setup(name='sdizo',
          ext_modules=cythonize(file),
          zip_safe=False,
          language='c++'
          )
