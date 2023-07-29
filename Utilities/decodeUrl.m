// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

(encodedUrl as text) as text =>
// Decodes a url by performing text replacements.
//
// This function uses List.Accumulate over a list of key value
// pairs to make replacements on a string.
//
// Args:
//    encodedUrl: the URL with encoded characters.
//
// Returns:
//    A decoded url.

    List.Accumulate(
        // The encoded and decoded value pairs.
        {
            {"%20", " "},
            {"%2F", "/"},
            {"%3F", "?"},
            {"%3A", ":"},
            {"%40", "@"},
            {"%23", "#"},
            {"%24", "$"},
            {"%25", "%"},
            {"%5E", "^"},
            {"%26", "&"},
            {"%2B", "+"},
            {"%3D", "="},
            {"%7B", "{"},
            {"%7D", "}"},
            {"%7C", "|"},
            {"%5C", "\"},
            {"%3C", "<"},
            {"%3E", ">"},
            {"%5B", "["},
            {"%5D", "]"},
            {"%60", "`"},
            {"%2C", ","},
            {"%3B", ";"},
            {"%27", "'"},
            {"%22", "\"},
            {"%7E", "~"},
            {"%2E", "."},
            {"%5F", "_"},
            {"%2D", "-"},
            {"%21", "!"},
            {"%2A", "*"}
        },
        encodedUrl,
        (src, pair) =>
            Text.Replace(
                src,
                pair{0},
                pair{1})
    )
