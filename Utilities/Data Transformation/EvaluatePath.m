// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

(tbl as table, childCol as text, parentCol as text, steps as number) =>
// Evaluates a child-parent path to the highest node.
//
// This function takes a parent-child relationship and converts it to a full
// hierarchical chain for each object.
//
// Input table should have a parent and child column.
// Passing 2 steps converts as follows (1 and 2 are already stepped).
//  Id | Pnt
//  A  | C
//  B  | C
//  C  | D
//  D  | 
//
// Into the following.
// Id | Pnt | 1  | 2 | 3 | 4
// A  | C   | A  | C | D |
// B  | C   | B  | C | D |
// C  | D   | C  | D |   |
// D  |     | D  |   |   |
//
// Args:
//    tbl: the table with the child and parent columns.
//    childCol: the name of the child column.
//    parentCol: the name of the parent column.
//    steps: the number of steps to evaluate.
//
// Returns:
//    A table with child-parent steps unpivoted.
//

let
    // Validate the input number of steps at least 1.
    Validated = if steps < 1 then error "Steps cannot be less than 1." else tbl,

    // Prepare the table for path determination.
    Prepared = Table.Buffer(
        Table.AddColumn(
            Table.AddColumn(
                Validated, "1", each Record.Field(_, childCol)
            ),
            "2", each Record.Field(_, parentCol)
        )
    ),

    // Evaluate the paths.
    EvalPath = List.Accumulate(
        {3..steps+2},
        Prepared,
        (x, y) => Table.ExpandTableColumn(
            Table.NestedJoin(
                x, {Text.From(y - 1)},
                x, {"1"},
                "EvalPathTemp",
                JoinKind.LeftOuter
            ),
            "EvalPathTemp",
            {"2"},
            {Text.From(y)}
        )
    )
in
    EvalPath
