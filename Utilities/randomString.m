// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

(optional len as number) as text =>
// Returns a random alpha-numeric string.
//
// The returned string will always start with a character
// and can be a mix of upper and lower case letters, and numbers.
//
// Args:
//    len: the length of random string (default 6).
//
// Returns:
//    A random string of the passed in length.

let
    // Random Number Generator.
    rng = (x as number) as number => Number.RoundDown(Number.RandomBetween(0, x)),

    // Use the passed in len if it's a positive number or default to 6.
    useLen = if (len = null or len < 1) then 6 else len,

    // Generate list of upper and lower case characters.
    chars = List.Combine({
        List.Transform({65..65+25}, each Character.FromNumber(_)),
        List.Transform({97..97+25}, each Character.FromNumber(_))
    }),

    // Generate list of numbers and cast to text.
    nums = List.Transform({0..9}, each Text.From(_)),

    // Combine the letters and numbers.
    numChars = List.Combine({chars, nums}),

    // Generate the characters as lists.
    firstChar = {chars{rng(List.Count(chars))}},
    otherChars =
        if useLen > 1
        then List.Transform(
            List.Repeat({List.Count(numChars)}, useLen - 1),
            each numChars{rng(_)}
        )
        else {},

    // Combine the results.
    result = Text.Combine(
        List.Combine({
            firstChar,
            otherChars
        })
    )
in
    result
