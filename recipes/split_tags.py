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


def get_duden_haeufigkeit(row):
    if "::Duden::1" in row["tags"]:
        return "1"
    if "::Duden::2" in row["tags"]:
        return "2"
    if "::Duden::3" in row["tags"]:
        return "3"
    if "::Duden::4" in row["tags"]:
        return "4"
    if "::Duden::5" in row["tags"]:
        return "5"
    return None


generated = pd.read_csv("build/data/c/wort.csv")
generated.set_index("wort")

generated["niveau"] = generated.apply(get_niveau, axis=1)
generated["duden_haeufigkeit"] = generated.apply(get_duden_haeufigkeit, axis=1)

generated.to_csv("build/data/c/wort.csv", header=True, index=False)
