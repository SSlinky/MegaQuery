// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Data
// QueryName: SetDefaultValue
// Dependencies:
//  - /Util/DataApplyColumnTypes

(tbl as table, value as any, fieldNames as list) as table =>
// Replaces null values in a list of fields with the passed in value.
//
// Args:
//    tbl: the table to act on.
//    value: the default value.
//    fieldNames: the fields to apply the default to.

ApplyColumnTypes(
    tbl,
    Table.ReplaceValue(
        tbl,
        null,
        value,
        Replacer.ReplaceValue,
        fieldNames))
