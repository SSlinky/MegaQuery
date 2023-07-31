// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

(tbl as table, predicate as function, optional dateField as text) as record =>
// Returns the most recent file matching the given predicate.
//
// This function requires a "Date Modified" field to work.
// Requires SharePoint authentication.
//
// Args:
//    tbl: the source table to act on.
//    predicate: the row selection predicate.
//    dateField: the field to sort on.
//
// Returns:
//    A record containing the file and its attributes.
//

    Table.Sort(
        Table.SelectRows(tbl, predicate),
        {{
            if dateField = null then "Date modified" else dateField,
            Order.Descending
        }}
    ){0}
