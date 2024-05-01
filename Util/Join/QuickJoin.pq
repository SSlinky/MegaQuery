// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Join
// QueryName: QuickJoin
// Dependencies:
//  - /Util/Validation/ListIsDistinct

(select as list, from as table, joinKind as nullable number,
    to as table, on as list) as table =>
// A more SQL like join experience for Power Query.
//
// Automatically prefixes column names with a and b to
// prevent Join from throwing an exception. Will remove
// the prefixes if selected column names are unique.
//
// SELECT * FROM t1 AS a INNER JOIN t2 AS b ON a.ID=b.ID
// QuickJoin({}, t1, JoinKind.Inner, t2, {"a.ID", "b.ID"})
//
// Left and right table columns are prefixed with a and b
// respectively to eliminate the risk of naming clash.
//
// Args:
//    select: the columns to select or an empty list for all.
//    from: the left side of the join.
//    joinKind: the type of join.
//    to: the right side of the join.
//    on: the columns to join on, prefixed with a and b.
//
// Returns:
//    The joined table.

let
    // Separate the join on key lists.
    onL = List.Select(on, each Text.StartsWith(_, "a.")),
    onR = List.Select(on, each Text.StartsWith(_, "b.")),
    
    // Prefix the tables with a and b to prevent name clash.
    fromTbl = Table.PrefixColumns(from, "a"),
    toTbl = Table.PrefixColumns(to, "b"),

    // Perform the join.
    joinedTbl = Table.Join(
        fromTbl, onL,
        toTbl, onR,
        joinKind
    ),

    // Select the columns to return.
    selectedCols = if List.Count(select) > 0
        then Table.SelectColumns(joinedTbl, select)
        else joinedTbl,

    // Remove the a and b prefixes if we have unique names.
    dePrefix = let
        dePrefixedHeaders = List.Transform(
            Table.ColumnNames(selectedCols),
            each Text.End(_, Text.Length(_) - 2)
        )
        in if ListIsDistinct(dePrefixedHeaders)
        then Table.RenameColumns(
            selectedCols,
            List.Zip({
                Table.ColumnNames(selectedCols),
                dePrefixedHeaders}))
        else selectedCols

in
    dePrefix