# Ultimate Deutsch

Inspired by [Ultimate Geography](https://github.com/anki-geo/ultimate-geography/).

**German flashcard deck for Anki featuring:**

- Notes for nouns, two for each [case](https://en.wikipedia.org/wiki/Grammatical_case) (singular vs. plural).
- Notes for verbs, six for each [mood](https://en.wikipedia.org/wiki/Grammatical_mood) ⊕ [tense](https://en.wikipedia.org/wiki/Grammatical_tense) (one for each [person](https://en.wikipedia.org/wiki/Grammatical_person)),
  but only those with possibly distinct forms (e.g., "Futur" is omitted entirely, because the future form of the verb never changes,
  only that of the [auxiliary verb](https://en.wikipedia.org/wiki/Auxiliary_verb)).
- More to come.

## Rationale

I have not found any Anki decks, which would fulfill my needs of:

- practicing nouns with their [grammatical gender](https://en.wikipedia.org/wiki/Grammatical_gender)
- practicing verbs in various combinations
- have a somewhat stable word-list

Thus, I had the idea to create one.

## Progress report

Based on [CEFR levels](https://coe.int/en/web/common-european-framework-reference-languages/level-descriptions).

Sources are [documented here](./sources/word-lists.md)

<table>
  <tr>
    <th>CEFR</th>
    <th>Word count</th>
    <th>Cards correct¹</th>
    <th>Nouns</th>
    <th>Verbs</th>
    <th>Adjectives</th>
    <th>Miscellaneous</th>
    <th>Translation EN</th>
    <th>Translation HU</th>
  </tr>
  <tr>
    <th>A1</th>
    <td style='text-align:center; vertical-align:middle'>WC</td>
    <td rowspan="5"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td style='text-align:center; vertical-align:middle'>N</td>
    <td style='text-align:center; vertical-align:middle'>V</td>
    <td rowspan="5"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td rowspan="5"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td style='text-align:center; vertical-align:middle'>EN</td>
    <td style='text-align:center; vertical-align:middle'>HU</td>
  </tr>
  <tr>
    <th>A2</th>
    <td rowspan="4"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td rowspan="4"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td rowspan="4"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td rowspan="4"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
    <td rowspan="4"> <a href="#to-dos"><img alt="Future work" src="https://raw.githubusercontent.com/AFulgens/ultimate-deutsch/badges/badges/Future-Work-blue.svg"/></a> </td>
  </tr>
  <tr>
    <th>B1</th>
  </tr>
  <tr>
    <th>B2</th>
  </tr>
  <tr>
    <th>C</th>
  </tr>
</table>

¹ The column shows whether the "correctness" of included cards has been checked and the deck is generated with only the
cards necessary for the particular CEFR level (e.g., A1 does not include "Konjunktiv I" cards for verbs).

## Basic grammar know-how

In table with Wiki-links:

- Adverb
- Adjektiv
- etc.

## To Dos

- badges
- basic grammar know-how
- Combination cards, for example as ideas:
  - Instead of one for each person, have one for a mood ⊕ tense
  - Instead of one for each casus, have one for singular and one for plural
- Fill descriptions
- Fill Readme, take inspiration from Ultimate Geography.
- How to include addendums?

## Open questions

- Does media also have to be split across decks or only the needed will be included?

## Prerequisites for building

Currently, it's somewhat unstable. I have only ever tested with:

- Windows 11
- python 3
  - Visual C++ distributables (6+ GiB)
  - pip
  - pipenv
- Cygwin
  - make
  - yq

See the [Makefile](./Makefile) for details about generating the decks.
