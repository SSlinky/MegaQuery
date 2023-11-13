// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

(tbl as table, over as list, newColName as text, startAt as number) as table =>
// Adds an incrementing index that resets over groups.
//
// Args:
//    tbl: the table to index over a column.
//    over: the names of the columns to group on.
//    newColName: the name of the index column.
//    startAt: the number of steps to evaluate.
//
// Returns:
//    A table with child-parent steps unpivoted.
//
let
    // Group and Index the rows.
    #"Added Index Over Group" = Table.SelectColumns(
        Table.AddColumn(
            Table.Group(tbl, over, {{"Rows", each _, type table [tbl]}}),
            "RowsIndexed", each Table.AddIndexColumn([Rows], newColName, startAt)),
        {"RowsIndexed"}),

    // Expand the groups.
    #"Expanded Columns" = Table.ExpandTableColumn(
        #"Added Index Over Group",
        "RowsIndexed",
        Table.ColumnNames(Table.Transpose(#"Added Index Over Group")[Column1]{0}))
in
    #"Expanded Columns"
