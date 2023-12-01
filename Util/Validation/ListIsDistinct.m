// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Namespace: /Util/Validation
// QueryName: ListIsDistinct

(lst as list) as logical =>
// Validates the list has unique values.
//
// Args:
//    lst: the list to validate.
//
// Returns:
//    true if the list does not contain duplicates.

    List.Count(lst) - List.Count(List.Distinct(lst)) = 0