#!/usr/bin/env python3
"""
Generate operators the vector types
"""

from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import List, Optional
import string
import argparse as ap
import textwrap


class OperandType(Enum):
    VECTOR = "vector"
    SCALAR = "scalar"

    @classmethod
    def from_string(cls, type_str: str):
        if type_str.strip() == "V":
            return cls.VECTOR
        elif type_str.strip() == "S":
            return cls.SCALAR
        else:
            raise ValueError(f"Unknown operand type: {type_str}")


class OperatorType(Enum):
    ADD = ("+", "add", False)
    ADD_ASSIGN = ("+=", "add", True)
    SUBTRACT = ("-", "sub", False)
    SUBTRACT_ASSIGN = ("-=", "sub", True)
    MULTIPLY = ("*", "mul", False)
    MULTIPLY_ASSIGN = ("*=", "mul", True)
    DIVIDE = ("/", "div", False)
    DIVIDE_ASSIGN = ("/=", "div", True)
    AND = ("&", "and", False)
    AND_ASSIGN = ("&=", "and", True)
    OR = ("|", "or", False)
    OR_ASSIGN = ("|=", "or", True)
    XOR = ("^", "xor", False)
    XOR_ASSIGN = ("^=", "xor", True)

    NEGATE = ("-", "neg", False, "NEG")
    BW_NEGATE = ("~", "not", False)

    COMPARE_EQ = ("==", "cmpEq", False)
    COMPARE_NE = ("!=", "cmpNe", False)
    COMPARE_LT = ("<", "cmpLt", False)
    COMPARE_LE = ("<=", "cmpLe", False)
    COMPARE_GT = (">", "cmpGt", False)
    COMPARE_GE = (">=", "cmpGe", False)

    def is_assign_op(self):
        return self.is_assign

    def __init__(self, operator, intrinsic, is_assign, parse_name=None):
        self.operator = operator
        self.key = parse_name or operator
        self.intrinsic = intrinsic
        self.is_assign = is_assign

    @classmethod
    def from_string(cls, operator_str: str):
        operator_str = operator_str.strip()
        for member in cls:
            if member.key == operator_str:
                return member
        raise ValueError(f"Unknown operator: {operator_str}")


@dataclass
class Expression:
    lhs_type: OperandType
    operator: OperatorType
    rhs_type: Optional[OperandType]

    @classmethod
    def from_string(cls, expr_str: str):
        parts = expr_str.strip().split()
        if len(parts) != 3 and len(parts) != 2:
            raise ValueError(f"Invalid expression format: {expr_str}")

        if len(parts) == 2:
            operator, lhs = parts
            rhs = None
        else:
            lhs, operator, rhs = parts

        lhs_type = OperandType.from_string(lhs)
        rhs_type = OperandType.from_string(rhs) if rhs else None
        operator_type = OperatorType.from_string(operator)
        return cls(lhs_type, operator_type, rhs_type)

    def is_unary(self):
        return self.rhs_type is None

    def __str__(self):
        if self.is_unary():
            return f"{self.operator.value} {self.lhs_type.value}"
        return (
            f"{self.lhs_type.value} {self.operator.value} {self.rhs_type.value}"
        )


class Parser:

    START_OPS_MARKER = "=== START OPERATORS ==="
    END_OPS_MARKER = "=== END OPERATORS ==="

    def __init__(self, filename: Path):
        self.filename = filename

    def _parse_line(self, line: str) -> List[Expression]:
        # parse a semicolon-separated line into expressions
        expressions = []
        for expr_str in line.strip().split(";"):
            expr_str = expr_str.strip()
            if expr_str:
                expressions.append(Expression.from_string(expr_str))
        return expressions

    def _parse_lines(self, lines: List[str]) -> List[Expression]:
        expressions = []
        for line in lines:
            if line.strip():
                expressions.extend(self._parse_line(line))
        return expressions

    def parse(self) -> List[Expression]:
        expressions = []
        with open(self.filename, "r") as file:
            content = file.read()

        start = content.find(self.START_OPS_MARKER)
        end = content.find(self.END_OPS_MARKER, start)
        if start == -1 or end == -1:
            raise ValueError("Operator section not found in the file.")

        operator_section = content[
            start + len(self.START_OPS_MARKER) : end
        ].strip()

        lines = operator_section.splitlines()
        expressions = self._parse_lines(lines)
        return expressions


VECTOR_X_VECTOR_TEMPLATE = """
/* VECTOR @@{op} VECTOR */
inline operator@@{op}(x: vector(?eltType, ?numElts), y: x.type): x.type {
  var result: x.type;
  result.data = Intrin.@@{intrin}(eltType, numElts, x.data, y.data);
  return result;
}
"""
VECTOR_X_VECTOR_ASSIGN_TEMPLATE = """
/* VECTOR @@{op} VECTOR */
inline operator@@{op}(x: vector(?eltType, ?numElts), y: x.type): x.type {
  x.data = Intrin.@@{intrin}(eltType, numElts, x.data, y.data);
}
"""
VECTOR_X_SCALAR_TEMPLATE = """
/* VECTOR @@{op} SCALAR */
inline operator@@{op}(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
  where isCoercible(scalarType, eltType) {
  var result: x.type;
  result.data = Intrin.@@{intrin}(eltType, numElts, x.data,
                  Intrin.splat(eltType, numElts, y));
  return result;
}
"""
VECTOR_X_SCALAR_ASSIGN_TEMPLATE = """
/* VECTOR @@{op} SCALAR */
inline operator@@{op}(x: vector(?eltType, ?numElts), y: ?scalarType): x.type
  where isCoercible(scalarType, eltType) {
  x.data = Intrin.@@{intrin}(eltType, numElts, x.data,
                  Intrin.splat(eltType, numElts, y));
}
"""
SCALAR_X_VECTOR_TEMPLATE = """
/* SCALAR @@{op} VECTOR */
inline operator@@{op}(x: ?scalarType, y: vector(?eltType, ?numElts)): y.type
  where isCoercible(scalarType, eltType) {
  var result: y.type;
  result.data = Intrin.@@{intrin}(eltType, numElts,
                  Intrin.splat(eltType, numElts, x), y.data);
  return result;
}
"""
VECTOR_UNARY_TEMPLATE = """
/* @@{op} VECTOR */
inline operator@@{op}(x: vector(?eltType, ?numElts)): x.type {
  var result: x.type;
  result.data = Intrin.@@{intrin}(eltType, numElts, x.data);
  return result;
}
"""


MODULE_TEMPLATE = """
//
// Autogenerated by generate_ops.py: DO NOT EDIT
//
module @@{mod_name} {
  use Vector only vector;
  import Intrin;

  @@{contents}
}
"""


class BinaryOpsGenerator:

    class Template(string.Template):
        delimiter = "@@"

    def __init__(self, expressions: List[Expression]):
        self.expressions = expressions
        self.templates = {
            k: self.Template(v)
            for k, v in {
                "vector_x_vector": VECTOR_X_VECTOR_TEMPLATE,
                "vector_x_vector_assign": VECTOR_X_VECTOR_ASSIGN_TEMPLATE,
                "vector_x_scalar": VECTOR_X_SCALAR_TEMPLATE,
                "vector_x_scalar_assign": VECTOR_X_SCALAR_ASSIGN_TEMPLATE,
                "scalar_x_vector": SCALAR_X_VECTOR_TEMPLATE,
                "vector_unary": VECTOR_UNARY_TEMPLATE,
            }.items()
        }

    def _convert_expression(self, expr: Expression) -> str:
        if expr.is_unary():
            key = "vector_unary"
        else:
            key = f"{expr.lhs_type.value}_x_{expr.rhs_type.value}"
            if expr.operator.is_assign_op():
                key += "_assign"

        template = self.templates.get(key)
        if not template:
            raise ValueError(f"No template found for {key}")

        return template.substitute(
            op=expr.operator.operator,
            intrin=expr.operator.intrinsic,
        )

    def generate(self, output_file: Path) -> str:
        output = []

        for expr in self.expressions:
            output.append(self._convert_expression(expr))

        contents = "".join(output)
        contents = textwrap.indent(contents, " " * 2)

        mod_name = output_file.stem
        module_content = self.Template(MODULE_TEMPLATE).substitute(
            mod_name=mod_name,
            contents=contents.strip(),
        )
        output_file.parent.mkdir(parents=True, exist_ok=True)
        with open(output_file, "w") as f:
            f.write(module_content)


if __name__ == "__main__":

    parser = ap.ArgumentParser(
        description="Generate binary operations for vectors."
    )
    parser.add_argument(
        "--filename",
        type=Path,
        help="Path to the Chapel file containing operator definitions.",
        required=True,
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Path to save the generated code.",
        required=True,
    )
    args = parser.parse_args()

    expressions = Parser(args.filename).parse()

    generator = BinaryOpsGenerator(expressions)
    generator.generate(args.output)
