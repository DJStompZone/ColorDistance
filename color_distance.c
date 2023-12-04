#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#ifdef _WIN32
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT
#endif

// Function to convert a single hexadecimal digit to its decimal value
int hex_char_to_int(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    return -1; // Invalid character
}

// Function to convert a hexadecimal color string to RGB values
void hex_to_rgb(const char *hex, int *r, int *g, int *b)
{
    *r = hex_char_to_int(hex[1]) * 16 + hex_char_to_int(hex[2]);
    *g = hex_char_to_int(hex[3]) * 16 + hex_char_to_int(hex[4]);
    *b = hex_char_to_int(hex[5]) * 16 + hex_char_to_int(hex[6]);
}

// Function to calculate the distance between two colors
double color_distance(const char *hex1, const char *hex2)
{
    int r1, g1, b1, r2, g2, b2;

    hex_to_rgb(hex1, &r1, &g1, &b1);
    hex_to_rgb(hex2, &r2, &g2, &b2);

    return sqrt(pow(r2 - r1, 2) + pow(g2 - g1, 2) + pow(b2 - b1, 2));
}

// Check if a string is a valid hex color
int is_valid_hex_color(const char *hex)
{
    if (hex[0] != '#' || strlen(hex) != 7)
    {
        return 0; // Invalid format
    }
    for (int i = 1; i < 7; i++)
    {
        if (!(hex[i] >= '0' && hex[i] <= '9') &&
            !(hex[i] >= 'a' && hex[i] <= 'f') &&
            !(hex[i] >= 'A' && hex[i] <= 'F'))
        {
            return 0; // Invalid character
        }
    }
    return 1; // Valid hex color
}

// Python wrapper function
static PyObject *py_color_distance(PyObject *self, PyObject *args)
{
    char *hex1, *hex2;
    if (!PyArg_ParseTuple(args, "ss", &hex1, &hex2))
    {
        return NULL; // Error if input parsing fails
    }
    if (!is_valid_hex_color(hex1) || !is_valid_hex_color(hex2))
    {
        PyErr_SetString(PyExc_ValueError, "Invalid hex color format");
        return NULL;
    }
    double result = color_distance(hex1, hex2);
    return Py_BuildValue("d", result);
}

// Method definitions
static PyMethodDef ColorDistanceMethods[] = {
    {"color_distance", py_color_distance, METH_VARARGS, "Calculate distance between two colors."},
    {NULL, NULL, 0, NULL} // Sentinel
};

// Module definition
static struct PyModuleDef color_distance_module = {
    PyModuleDef_HEAD_INIT,
    "color_distance", // Module name
    NULL,             // Module documentation (could be NULL)
    -1,               // Size of per-interpreter module state, -1 means module keeps state in global variables
    ColorDistanceMethods};

// Module initialization function
DLL_EXPORT PyMODINIT_FUNC PyInit_color_distance(void)
{
    return PyModule_Create(&color_distance_module);
}

// Obligatory main function for testing
int main() {
    const char *color1 = "#555555";
    const char *color2 = "#777777";
    double threshold = 69.0;
    double dist = color_distance(color1, color2);

    printf("Distance between %s and %s is: %.2f\n", color1, color2, dist);
    printf("Within Threshold: %s\n", (dist <= threshold) ? "Yes" : "No");

    return 0;
}
