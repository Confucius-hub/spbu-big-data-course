#include <pybind11/numpy.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include <cstdint>
#include <unordered_map>
#include <utility>

namespace py = pybind11;

py::dict groupby_avg_rating_per_year(
    py::array_t<float, py::array::c_style | py::array::forcecast> ratings,
    py::array_t<int32_t, py::array::c_style | py::array::forcecast> years
) {
    auto rating_view = ratings.unchecked<1>();
    auto year_view = years.unchecked<1>();
    std::unordered_map<int32_t, std::pair<uint64_t, double>> stats;

    for (py::ssize_t i = 0; i < rating_view.shape(0); ++i) {
        auto& slot = stats[year_view(i)];
        slot.first += 1;
        slot.second += rating_view(i);
    }

    py::dict result;
    for (const auto& kv : stats) {
        result[py::int_(kv.first)] = py::make_tuple(
            kv.second.first,
            kv.second.second / kv.second.first
        );
    }
    return result;
}

PYBIND11_MODULE(hw1_cpp, module) {
    module.def("groupby_avg_rating_per_year", &groupby_avg_rating_per_year);
}
