"""
Custom lint rules for this project
"""

import chapel
from rule_types import BasicRuleResult, AdvancedRuleResult
from fixits import Fixit, Edit
import sys
import os


def log(*args, **kwargs):
    print(*args, **kwargs, file=sys.stderr)


def is_in_lib(node: chapel.AstNode) -> bool:
    """
    These are custom checks for this library that should only be applied to
    library code, not tests
    """
    workspace = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    folders = ["src"]
    workspace_dirs = [os.path.join(workspace, d) for d in folders]

    file_path = node.location().path()
    for d in workspace_dirs:
        if os.path.commonpath([d, file_path]) == d:
            return True
    return False


def rules(driver):

    @driver.basic_rule(chapel.Function)
    def OnlyInlineProc(_, node: chapel.Function):
        """
        functions should be inline or resolved at compile time(type/param)
        extern functions and init/deinit cannot be inlined
        serialize is ok
        """
        if not is_in_lib(node):
            return True

        is_compile_time = node.return_intent() in ("param", "type")
        is_extern = node.linkage() in ("extern", "export")
        is_serialize = node.name() in ("serialize", "deserialize")
        return node.is_inline() or is_compile_time or is_extern or is_serialize

    @driver.fixit(OnlyInlineProc)
    def FixOnlyInlineProc(context: chapel.Context, result: BasicRuleResult):
        lines = chapel.get_file_lines(context, result.node)
        loc = result.node.location()
        proc_text = chapel.range_to_text(loc, lines)
        proc_text = "inline " + proc_text
        # TODO: this works only because private/public is
        # not included in location
        fixit = Fixit.build(Edit.build(loc, proc_text))
        fixit.description = "Add inline keyword"
        return fixit

    @driver.basic_rule(chapel.Function)
    def NoInlineAtCompileTime(_, node: chapel.Function):
        """
        compile time functions (type/param return intent) do not need to be
        marked inline
        """
        if not is_in_lib(node):
            return True

        is_compile_time = node.return_intent() in ("param", "type")
        return not (node.is_inline() and is_compile_time)

    @driver.fixit(NoInlineAtCompileTime)
    def FixNoInlineAtCompileTime(
        context: chapel.Context, result: BasicRuleResult
    ):
        lines = chapel.get_file_lines(context, result.node)
        loc = result.node.location()
        proc_text = chapel.range_to_text(loc, lines)
        proc_text = proc_text.removeprefix("inline").lstrip()
        # TODO: this works only because private/public is
        # not included in location
        fixit = Fixit.build(Edit.build(loc, proc_text))
        fixit.description = "Remove inline keyword"
        return fixit

    @driver.basic_rule(chapel.Function)
    def MissingSynchronizationFree(_, node: chapel.Function):
        """
        All extern functions should have the pragma "fn synchronization free"
        """
        if not is_in_lib(node):
            return True

        is_extern = node.linkage() in ("extern", "export")
        has_pragma = "fn synchronization free" in node.pragmas()
        return not (is_extern and not has_pragma)

    @driver.fixit(MissingSynchronizationFree)
    def FixMissingSynchronizationFree(
        context: chapel.Context, result: BasicRuleResult
    ):
        lines = chapel.get_file_lines(context, result.node)
        loc: chapel.Location = result.node.location()
        proc_text = chapel.range_to_text(loc, lines)
        indent = loc.start()[1] - 1
        pragma = 'pragma "fn synchronization free"'
        proc_text = pragma + f"\n{' '*indent}" + proc_text
        fixit = Fixit.build(Edit.build(loc, proc_text))
        fixit.description = 'Add `pragma "fn synchronization free"`'
        return fixit

    @driver.basic_rule(chapel.Formal)
    def NoGenericFormals(_, node: chapel.Formal):
        """
        All formals should have some form of type constraint
        formals like 'type t' are ok
        serialize/deserialize is ok

        if there is a where clause, its ok
        """
        if not is_in_lib(node):
            return True

        is_type = node.intent() == "type"
        type_expr = node.type_expression()
        parent_func = node.parent()
        assert isinstance(parent_func, chapel.Function)

        is_this = node.name() == "this" and parent_func.is_method()
        is_serialize = parent_func.name() in ("serialize", "deserialize")

        has_where = parent_func.where_clause() is not None

        return is_type or type_expr or is_this or is_serialize or has_where

    @driver.basic_rule(chapel.Function)
    def NoGenericReturn(_, node: chapel.Function):
        """
        All functions should be explicit about their return type
        Functions with return intent of type are ok
        serialize/deserialize is ok
        Functions with no return statement are ok
        casts are ok
        """
        if not is_in_lib(node):
            return True

        ret_type = node.return_type()
        returns_type = node.return_intent() == "type"
        is_init_deinit = node.name() in ("init", "init=", "deinit", "postinit")
        is_serialize = node.name() in ("serialize", "deserialize")
        is_cast = node.name() == ":"

        rets_and_yields = chapel.each_matching(
            node, set([chapel.Return, chapel.Yield])
        )
        has_no_ret = len(list(rets_and_yields)) == 0

        if not (
            ret_type
            or returns_type
            or is_init_deinit
            or is_serialize
            or has_no_ret
            or is_cast
        ):
            return BasicRuleResult(node, ignorable=True)
        return True

    @driver.basic_rule(chapel.Use)
    def NoUnqualifiedImport(_, node: chapel.Use):
        """
        All imports should be qualified, no 'use Module;'
        """
        if not is_in_lib(node):
            return True

        # we only consider nodes that are at module scope
        if not isinstance(node.parent(), chapel.Module):
            return True

        # we only consider 'use' statements that aren't explicitly qualified
        # as private or public
        if node.visibility() in ("public", "private"):
            return True

        # if any of the vis clauses don't have 'only' as the limitation, warn
        return all(
            [
                vis.limitation_kind() == "only"
                for vis in node.visibility_clauses()
            ]
        )

    @driver.advanced_rule
    def TypeOnlyRecord(_, root: chapel.AstNode):
        """
        if a record is marked '@lint.typeOnly', there should only be type
        fields, type methods, param fields, and param methods
        """
        # TODO: this lint rule does not handle secondary methods
        if isinstance(root, chapel.Comment):
            return

        if not is_in_lib(root):
            return

        for rec, _ in chapel.each_matching(root, chapel.Record):
            assert isinstance(rec, chapel.Record)
            attrs = rec.attribute_group()
            if attrs is None:
                continue
            a = attrs.get_attribute_named("lint.typeOnly")
            if a is None:
                continue

            for nd in rec:
                if isinstance(nd, chapel.Function):
                    assert nd.is_method()
                    this = nd.this_formal()
                    assert isinstance(this, chapel.Formal)
                    if this.intent() not in ("type", "param"):
                        type_fixit = Fixit.build(
                            Edit.build(
                                nd.name_location(), "type {}".format(nd.name())
                            )
                        )
                        type_fixit.description = "Make this a type method"
                        param_fixit = Fixit.build(
                            Edit.build(
                                nd.name_location(), "param {}".format(nd.name())
                            )
                        )
                        param_fixit.description = "Make this a param method"
                        fixits = [type_fixit, param_fixit]
                        yield AdvancedRuleResult(nd, anchor=nd, fixits=fixits)
                if isinstance(nd, chapel.Variable):
                    assert nd.is_field()
                    if nd.intent() not in ("type", "param"):
                        yield nd
