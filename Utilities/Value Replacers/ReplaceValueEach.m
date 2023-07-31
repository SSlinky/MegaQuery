// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Dependencies:
//  - ApplyColumnTypes

(tbl as table, replacer as function, fieldNames as list) as table =>
// Value replacement applied to multiple columns that maintains original types.
//
// Applies a replace value to each separate column, assuming the
// value to replace is each record field.
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
//     Source,
//     (v) => if v = null then ":(" else ":)",
//     {"myCol1", "myCol2"}
// )

ApplyColumnTypes(
    tbl,
    List.Accumulate(
        fieldNames,
        tbl,
        (x, y) => Table.ReplaceValue(
            x,
            each Record.Field(_, y),
            each replacer(Record.Field(_, y)),
            Replacer.ReplaceValue,
            {y})))
