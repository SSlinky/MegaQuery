// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Data
// QueryName: GetTypeTable

(tbl as table) as type =>
// Returns the type table of the passed in table.
//
// Args:
//    tbl: the table to generate the type from.

let
    // Get the table metadata.
    colNames = Table.ColumnNames(tbl),
    colTypes = List.Transform(
        colNames,
        (x) => [Type=Value.Type(Table.Column(tbl, x)), Optional=false]
    )
in
    // Package into a type table.
    type table Type.ForRecord(
        Record.FromList(
            colTypes,
            colNames
        ),
        false
    )
