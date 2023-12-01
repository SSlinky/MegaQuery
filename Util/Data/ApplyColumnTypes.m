// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Data
// QueryName: ApplyColumnTypes

(sourceTable as table, targetTable as table) =>
// Applies the column types of one table to another table.
//
// Args:
//    sourceTable: the source of the types.
//    targetTable: the table to apply the types to.

let
    // Get the source table type.
    sourceColumnTypes = Value.Type(sourceTable),

    // Select the common columns between source and target.
    selectedColumns = List.Intersect({
        Table.ColumnNames(sourceTable),
        Table.ColumnNames(targetTable)
    }),

    // Convert list of column {name...} to {{name, type}...}.
    sourceTypes = List.Transform(
        selectedColumns, 
        each {_} & {Type.TableColumn(sourceColumnTypes, _)}
    ),

    // Apply source types to target table.
    appliedTypes = Table.TransformColumnTypes(targetTable, sourceTypes)
in
    appliedTypes
