import pandas as pd


# https://stackoverflow.com/a/44409712
def sort_by_caseless_columns(df, columns=None, ascending=True):
    # https://stackoverflow.com/a/29247821
    import unicodedata

    def normalize_caseless(text):
        return unicodedata.normalize("NFKD", text.casefold())

    df_temp = pd.DataFrame(index=df.index, columns=columns)
    if columns:
        for kol in columns:
            df_temp[kol] = df[kol].apply(normalize_caseless)
        new_index = df_temp.sort_values(columns, ascending=ascending).index
    else:
        df_temp = df.apply(normalize_caseless)
        new_index = df_temp.sort_values(ascending=ascending).index

    return df.reindex(new_index)


substantiv = pd.read_csv("src/data/substantiv.csv")
substantiv.set_index("wort")
sort_by_caseless_columns(substantiv, ["wort"]) \
    .to_csv("src/data/substantiv.csv", header=True, index=False)

verb = pd.read_csv("src/data/verb.csv")
verb.set_index("wort")
sort_by_caseless_columns(verb, ["wort"]) \
    .to_csv("src/data/verb.csv", header=True, index=False)

union = (pd.concat([substantiv['wort'], verb['wort']], join="outer"))
union = union.reset_index(drop=True)
union = sort_by_caseless_columns(union)
union = union.drop_duplicates(ignore_index=True)

guid = pd.read_csv("src/data/guid.csv")
guid.set_index("wort")
guid.merge(union, how="outer") \
    .to_csv("src/data/guid.csv", header=True, index=False)

wort = pd.read_csv("src/data/wort.csv")
wort.set_index("wort")
wort.merge(union, how="outer") \
    .to_csv("src/data/wort.csv", header=True, index=False)
