// Copyright (C) 2023 Samuel Vanderslink
// Decodes a url by performing text replacements.

(encodedUrl as text) as text =>
    List.Accumulate(
        // The encoded and decoded value pairs.
        {
            {"%20", " "},
            {"%2F", "/"},
            {"%5F", "_"},
            {"%2D", "_"},
            {"%26", "&"}
        },
        encodedUrl,
        (src, pair) =>
            Text.Replace(
                src,
                pair{0},
                pair{1})
    )
