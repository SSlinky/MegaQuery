// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Data
// QueryName: IndexOver

(tbl as table, over as list, newColName as text,
    optional startAt as number,
    optional sortComparisonData as list) as table =>
// Adds an incrementing index that resets over groups.
//
// Args:
//    tbl: the table to index over a column.
//    over: the names of the columns to group on.
//    newColName: the name of the index column.
//    startAt: the index value to start at.
//
// Returns:
//    A table with child-parent steps unpivoted.
//
let
    // Set a unique column name.
    tempCol = "hsjknbvlsjkbvubn",

    // Group the rows to index over.
    Grouped = Table.SelectColumns(
        Table.Group(tbl, over, {{tempCol, each _, type table [tbl]}}),
        {tempCol}),

    // Sort the rows if we have criteria.
    Sorted = if sortComparisonData = null
        then Grouped
        else Table.TransformColumns(
            Grouped, {{tempCol, each Table.Sort(_, sortComparisonData)}}),

    // Add an index to each group.
    Indexed = Table.TransformColumns(
        Sorted,
        {{
            tempCol,
            each Table.AddIndexColumn(
                _,
                newColName,
                startAt)
        }}),

    // Expand the groups, using the first table in the first row as a ref.
    Expanded = Table.ExpandTableColumn(
        Indexed,
        tempCol,
        Table.ColumnNames(Table.Transpose(Indexed)[Column1]{0})),

    // Reset column types.
    ResetTypes = ApplyColumnTypes(
        tbl, Table.TransformColumnTypes(Expanded,{{newColName, Int64.Type}})),

    // Safely return the indexed table, or original table plus a faux index if we had nothing.
    Result = if Table.RowCount(tbl) > 0
        then ResetTypes
        else Table.AddColumn(tbl, newColName, each null, Int64.Type)
in
    Result