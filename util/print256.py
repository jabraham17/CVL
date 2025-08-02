#!/usr/bin/env python3

# import lldb


class M256iSynthProvider:
    def __init__(self, valobj, internal_dict):
        self.valobj = valobj
        self.update()

    def update(self):
        # Get the raw data as an array of 16 16-bit integers
        self.data = self.valobj.GetData()
        if not self.data.IsValid():
            return
        # 256 bits = 32 bytes = 16 16-bit integers
        self.size = 16

    def num_children(self):
        return self.size

    def get_child_at_index(self, index):
        if index < 0 or index >= self.size:
            return None

        # Extract the 16-bit value at the given index
        offset = index * 2  # 2 bytes per 16-bit value
        value = int.from_bytes(
            self.data.uint8s[offset : offset + 2],
            byteorder="little",
            signed=False,
        )

        # Create a new value object for this lane
        return self.valobj.CreateValueFromExpression(f"[{index}]", str(value))

    def get_summary(self, x):
        values = []
        for i in range(self.size // 2):
            offset = i * 2
            value = int.from_bytes(
                self.data.uint8s[offset : offset + 2],
                byteorder="little",
                signed=False,
            )
            values.append(f"{value:>2}")
        # print the
        return "[" + ", ".join(values) + "]"


def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
        "type synthetic add -l print256.M256iSynthProvider __m256i -w simd"
    )
    debugger.HandleCommand(
        "type summary add __m256i "
        + "-F print256.M256iSynthProvider.get_summary -w simd"
    )
    debugger.HandleCommand("type category enable simd")
    debugger.HandleCommand("type category disable VectorTypes")
    print("256-bit SIMD Pretty Printers loaded")
