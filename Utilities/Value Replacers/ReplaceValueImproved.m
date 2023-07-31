// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Dependencies:
//  - ApplyColumnTypes

(tbl as table, value as function, replacer as function, fieldNames as list) as table =>
// Shorthand value replacement that maintains original types.
//
// Args:
//    tbl: the table to act on.
//    value: the value to replace function.
//    replacer: the replacement value function.
//    fieldNames: the fields to apply the default to.
//
//  Returns:
//    The replaced table with its original field types.
//
// Usage:
// ReplaceValueEach(
//    Source,
//    each [myCol],
//    each if [myCol] = null then ":(" else ":)",
//    {"myCol1"}
// )

ApplyColumnTypes(
    tbl,
    Table.ReplaceValue(
        tbl,
        value,
        replacer,
        Replacer.ReplaceValue,
        fieldNames))
