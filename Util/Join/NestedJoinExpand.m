// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Join
// QueryName: NestedJoinExpand
// Dependencies:
//  - /Util/String/GenRandomString

(tbl1 as table, key1 as list, tbl2 as table, key2 as list,
    columnNames as list, optional joinKind as number) as table =>
// Performs the join and expand in one function.
//
// Args:
//    tbl1: the left table in the join.
//    key1: the left key(s) to join on.
//    tbl2: the right table in the join.
//    key2: the right key(s) to join on.
//    columnNames: {{expand cols}, optional {renamed cols}}.
//    joinKind: the join kind as a nullable number.
//
// Returns:
//    The joined and expanded table.
let
    tempName = prefix = GenRandomString(),
    result = Table.ExpandTableColumn(
        Table.NestedJoin(
            tbl1, key1, tbl2, key2, tempName, joinKind
        ),
        tempName,
        columnNames{0},
        if List.Count(columnNames) > 1 then columnNames{1} else null
    )
in
    result
