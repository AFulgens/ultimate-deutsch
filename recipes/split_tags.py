import pandas as pd


def get_niveau(row):
    if "::A1" in row["tags"]:
        return "A1"
    if "::A2" in row["tags"]:
        return "A2"
    if "::B1" in row["tags"]:
        return "B1"
    if "::B2" in row["tags"]:
        return "B2"
    return "C"


def get_freq_class(row):
    for tag in row["tags"].split(','):
        if "::UniLeipzig::" in tag:
            return int(tag.split("::")[-1])
    return None


def normalize_freq(row, minFreq, maxFreq):
    return 100.0 - (int(int(row["haeufigkeitsklasse"]) - minFreq) / (maxFreq - minFreq) * (100.0 - 1.0))


generated = pd.read_csv("build/data/c/wort.csv")
generated.set_index("wort")

generated["niveau"] = generated.apply(get_niveau, axis=1)
generated["haeufigkeitsklasse"] = generated.apply(get_freq_class, axis=1)

minFreq = 1000
maxFreq = -1
for index, row in generated.iterrows():
    minFreq = min(minFreq, int(row["haeufigkeitsklasse"]))
    maxFreq = max(maxFreq, int(row["haeufigkeitsklasse"]))

generated["haeufigkeitsklasse"] = generated.apply(normalize_freq, args=(minFreq, maxFreq), axis=1)


generated.to_csv("build/data/c/wort.csv", header=True, index=False)
