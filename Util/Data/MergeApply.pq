// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Data
// QueryName: MergeApply
// Dependencies:
//  - /Util/String/GenRandomString

(tbl as table, column as text, mapTo as list, mapFrom as list, mergeMode as nullable number) as table =>
// Replaces values using a column of records or a column of tables.
//
// Functionally the same as Table.ExpandTableColumn except that values
// are conditionally merged into the existing data set. No additional
// columns are added and the expandable column is consumed.
//
// Args:
//    tbl: the table to act on.
//    column: the expandable column.
//    mapTo: the list of columns to perform replacements on.
//    mapFrom: the list of columns to be expand mapped.
//    mergeMode: accepts the same arguments as NestedJoin.
//      0: Default. Supplement if mapTo is null.
//      1: Override if mapFrom is not null.
//      2: Keep both values.

let
    // Shortcut accessor for Record.Field
    rf = (x as record, y as text) => Record.Field(x, y),

    // Prefix the Right columns with a random string to avoid duplicate field errors.
    prefix = GenRandomString(),
    mapFromPrefixed = List.Transform(mapFrom, each prefix & _),

    // Expand the column and rename with the prefixed names.
    ExpandedTableColumn = Table.ExpandTableColumn(
        tbl, column, mapFrom, mapFromPrefixed
    ),

    // Replace values that are null in Left with values from Right.
    replaceSupplement = (src as table, i as number) as table => let
        mt = mapTo{i},
        mf = mapFromPrefixed{i}
        in Table.RemoveColumns(
            Table.ReplaceValue(
                src,
                each Record.Field(_, mt),
                each if rf(_, mt) = null then rf(_, mf) else rf(_, mt),
                Replacer.ReplaceValue,
                {mt}
            ),
            {mf}
        ),

    // Replace values in Left with values that are not null from Right.
    replaceOverride = (src as table, i as number) as table => let
        mt = mapTo{i},
        mf = mapFromPrefixed{i}
        in Table.RemoveColumns(
            Table.ReplaceValue(
                src,
                each Record.Field(_, mt),
                each if rf(_, mf) = null then rf(_, mt) else rf(_, mf),
                Replacer.ReplaceValue,
                {mt}
            ),
            {mf}
        ),

    // Keep both values as a list.
    mergeToList = (src as table, i as number) as table => let
        mt = mapTo{i},
        mf = mapFromPrefixed{i}
        in Table.RemoveColumns(
            Table.ReplaceValue(
                src,
                each Record.Field(_, mt),
                each {mt, mf},
                Replacer.ReplaceValue,
                {mt}
            ),
            {mf}
        ),

    // Execute the action
    executeAction = List.Accumulate(
        {0..List.Count(mapTo) - 1},
        ExpandedTableColumn,
        if mergeMode = null or mergeMode = 0 then replaceSupplement
        else if mergeMode = 1 then replaceOverride
        else if mergeMode = 2 then mergeToList
        else error Text.Format("mergeMode #{0} invalid", mergeMode)
    )
in
    executeAction
