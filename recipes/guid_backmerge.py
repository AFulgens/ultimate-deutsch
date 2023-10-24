import pandas as pd
import merge_and_sort as sort


generated = pd.read_csv("build/data/c/guid.csv")
generated.set_index("wort")

base = pd.read_csv("src/data/guid.csv")
base.set_index("wort")

sort.sort_by_caseless_columns(
      pd.concat((base, generated)).groupby("wort").first().reset_index(), ["wort"]
    ) \
    .to_csv("src/data/guid.csv", header=True, index=False)
