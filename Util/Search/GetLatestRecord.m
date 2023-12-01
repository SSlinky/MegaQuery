// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Search
// QueryName: GetLatestRecord

(tbl as table, predicate as function, optional dateField as text) as record =>
// Returns the most recent file matching the given predicate.
//
// This function is useful for returning the most recently edited version
// of a file. It is designed to complement the output of SharePointDirectory, e.g.,
// Source = GetLatestRecord(srcSharePoint, each Text.Contains([Name], "myFile"))
//
// Args:
//    tbl: the source table to act on.
//    predicate: the row selection predicate.
//    dateField: the field to sort on.
//
// Returns:
//    A record containing the file and its attributes.

    Table.Sort(
        Table.SelectRows(tbl, predicate),
        {{
            if dateField = null then "Date modified" else dateField,
            Order.Descending
        }}
    ){0}
