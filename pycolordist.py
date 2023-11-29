import ctypes

# Load the shared library
color_distance_lib = ctypes.CDLL("./color_distance.so")

# Set the argument and return types
color_distance_lib.color_distance.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
color_distance_lib.color_distance.restype = ctypes.c_double


def get_dist(a, b):
    def normalize(c):
        if type(c) not in [str, bytes]:
            raise TypeError("Invalid type!")
        if type(c) is str:
            return bytes(c.replace("#", ""), encoding="utf8")
        else:
            return b"#" + c.replace(b"#", b"")

    if not all(
        [any([type(ea) == type(""), type(ea) == type(b"#000000")]) for ea in [a, b]]
    ):
        return "Error!"
    else:
        result = color_distance_lib.color_distance(normalize(a), normalize(b))
        return f"Color distance: {result}"


if __name__ == "__main__":
    print("Running tests...\n")
    failures = 0
    tests = [
        ("000000", "FFFFFF"),
        ("#C0FFEE", "#DECAFF"),
        (b"#696969", b"#420420"),
    ]
    for a, b in tests:
        result = None
        try:
            result = get_dist(a, b)
        except Exception as e:
            result = e
            failures += 1
        print("", f"Inputs: {a}, {b}", result, sep="\n", end="\n")
    print("", f"All tests completed. {len(tests)-failures}/{len(tests)} passed.", sep="\n")
