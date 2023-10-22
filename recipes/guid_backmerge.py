import pandas as pd


# https://stackoverflow.com/a/44409712
def sort_by_caseless_columns(df, columns, ascending=True):
    # https://stackoverflow.com/a/29247821
    import unicodedata

    def normalize_caseless(text):
        return unicodedata.normalize("NFKD", text.casefold())

    df_temp = pd.DataFrame(index=df.index, columns=columns)
    for kol in columns:
        df_temp[kol] = df[kol].apply(normalize_caseless)

    new_index = df_temp.sort_values(columns, ascending=ascending).index
    return df.reindex(new_index)


generated = pd.read_csv("build/data/c/guid.csv")
generated.set_index("word")

base = pd.read_csv("src/data/guid.csv")
base.set_index("word")

backmerged = pd.concat((base, generated)).groupby("word").first().reset_index()
backmerged = sort_by_caseless_columns(backmerged, ["word"])
backmerged.to_csv("src/data/guid.csv", header=True, index=False)
