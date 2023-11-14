import pandas as pd
import re
import sys
import urllib.request
from bs4 import BeautifulSoup
from merge_and_sort import sort_by_caseless_columns

verb_columns = [
    "praesens_singular_1",
    "praesens_singular_2",
    "praesens_singular_3",
    "praesens_plural_1",
    "praesens_plural_2",
    "praesens_plural_3",
    "praeteritum_singular_1",
    "praeteritum_singular_2",
    "praeteritum_singular_3",
    "praeteritum_plural_1",
    "praeteritum_plural_2",
    "praeteritum_plural_3",
    "praesens_konjunktiv_i_singular_1",
    "praesens_konjunktiv_i_singular_2",
    "praesens_konjunktiv_i_singular_3",
    "praesens_konjunktiv_i_plural_1",
    "praesens_konjunktiv_i_plural_2",
    "praesens_konjunktiv_i_plural_3",
    "praeteritum_konjunktiv_ii_singular_1",
    "praeteritum_konjunktiv_ii_singular_2",
    "praeteritum_konjunktiv_ii_singular_3",
    "praeteritum_konjunktiv_ii_plural_1",
    "praeteritum_konjunktiv_ii_plural_2",
    "praeteritum_konjunktiv_ii_plural_3",
    "imperativ_singular_2",
    "imperativ_plural_2",
    "infinitiv",
    "partizip_i",
    "partizip_ii",
    "perfekt_mit",
    "perfekt_hinweis"
]


def fetch_klass(word):
    url = "https://corpora.uni-leipzig.de/de/res?corpusId=deu_news_2022&word=" + urllib.parse.quote(word)
    site = urllib.request.urlopen(url).read()

    return BeautifulSoup(site, features="html.parser") \
        .find("span", {"title": "Die Häufigkeitsklasse des Wortes"}) \
        .string \
        .split(": ")[1] \
        .split(" ")[0]


def fetch_verb_from_duden(wort, link):
    site = urllib.request.urlopen(link).read()

    column_iter = iter(verb_columns)
    new_verb = pd.DataFrame([{"wort": wort}])

    anchors = [
        ["Präsens", 0],
        ["Präteritum", 0],
        ["Präsens", 1],
        ["Präteritum", 1]
    ]

    for anchor in anchors:
        current = iter(BeautifulSoup(site, features="html.parser")
                       .find_all(attrs={"class": "accordion__item"}, string=anchor[0])[anchor[1]]
                       .parent
                       .children)
        next(current)
        for entry in current:
            new_verb[next(column_iter)] = entry.contents[0]

    imperativ = \
        BeautifulSoup(site, features="html.parser") \
            .find_all(attrs={"class": "accordion-tables__header"}, string="Imperativ")[0] \
            .next_sibling.next_sibling.div.div.div.ul.next_sibling
    new_verb[next(column_iter)] = imperativ.li.contents[0]
    new_verb[next(column_iter)] = imperativ.li.next_sibling.contents[0]

    infinite = \
        BeautifulSoup(site, features="html.parser") \
            .find_all(attrs={"class": "accordion-tables__header"}, string="Infinite Formen")[0] \
            .next_sibling.next_sibling.div
    new_verb[next(column_iter)] = infinite.div.div.ul.li.next_sibling.contents[0]
    new_verb[next(column_iter)] = infinite.div.next_sibling.div.ul.li.next_sibling.contents[0]
    new_verb[next(column_iter)] = infinite.div.next_sibling.next_sibling.div.ul.li.next_sibling.contents[0]

    aux_verb = BeautifulSoup(site, features="html.parser") \
        .find(string=re.compile(".*Perfektbildung mit „.*"))
    if aux_verb is None:
        new_verb[next(column_iter)] = "TODO"
    else:
        new_verb[next(column_iter)] = aux_verb.split("„")[1][:-1]

    return new_verb


def fetch_verb_from_wiktionary(wort, link):
    return None


def fetch_verb_into(wort, link, verbs):
    new_verb = None
    if "duden" in link:
        new_verb = fetch_verb_from_duden(wort, link)
    elif "wiktionary" in link:
        new_verb = fetch_verb_from_wiktionary(wort, link)

    if new_verb is not None:
        new_verb = new_verb.replace({"–": None})
        return pd.concat([verbs, new_verb], ignore_index=True)


source = pd.read_csv("sources/word-lists/a1/A1.csv")
words = pd.read_csv("src/data/wort.csv")
verbs = pd.read_csv("src/data/verb.csv")

print("Word            Uni Leipzig     Duden", flush=True)
for word in sys.argv[1:]:

    print('{0:<16}'.format(word), end='', flush=True)
    new_word = pd.DataFrame(
        [{"wort": word, "tags": "UD::Goethe::A1,UD::UniLeipzig::" + fetch_klass(word)}])
    words = pd.concat([words, new_word], ignore_index=True)
    print("     ✓          ", end='', flush=True)

    entry = source.loc[source["wort"] == word]
    if entry.wortart.values[0] == "Verb":
        verbs = fetch_verb_into(word, entry.link.values[0], verbs)
    elif entry.wortart.values[0] == "Substantiv":
        print("TODO")

    print("  ✓  ", flush=True)

sort_by_caseless_columns(words, ["wort"]) \
    .to_csv("src/data/wort.csv", header=True, index=False)
sort_by_caseless_columns(verbs, ["wort"]) \
    .to_csv("src/data/verb.csv", header=True, index=False)
exec(open("recipes/merge_and_sort.py").read())
