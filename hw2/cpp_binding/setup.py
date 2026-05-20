from pybind11.setup_helpers import Pybind11Extension, build_ext
from setuptools import setup


setup(
    name="hw1_cpp",
    ext_modules=[
        Pybind11Extension(
            "hw1_cpp",
            sources=["hw1_cpp.cpp"],
            cxx_std=17,
        )
    ],
    cmdclass={"build_ext": build_ext},
)
