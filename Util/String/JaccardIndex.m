// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/String
// QueryName: JaccardIndex
// Dependencies:
//  - /Util/Data/IndexOver

(str1 as text, str2 as text) as number =>
// Returns the Jaccard Coefficient for two strings.
//
// Args:
//    str1: the first string to compare.
//    str2: the second string to compare.

let
    // Prepare a string for comparison.
    PrepString = (str) => Table.SelectColumns(
        Table.AddColumn(
            IndexOver(
                Table.FromList(
                    Text.ToList(str)),
                {"Column1"},
                "idx",
                0),
            "Value",
            each [Column1] & Text.From([idx])),
        {"Value"}),

    S1 = PrepString(str1),
    S2 = PrepString(str2),

    // Count the values that appear in both sets.
    SimilarValueCount = Table.RowCount(
        Table.NestedJoin(
            S1, {"Value"},
            S2, {"Value"},
            "X",
            JoinKind.Inner)),

    // Count the distinct values across both sets.
    DistinctValueCount = Table.RowCount(
        Table.Distinct(
            Table.Combine({
                S1, S2}))),

    // Calculate the similarity index.
    Result = SimilarValueCount / DistinctValueCount
in
    Result