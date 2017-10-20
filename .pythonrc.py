import pandas as pd

pd.options.display.width = 320
pd.options.display.max_columns = 20
pd.options.display.max_rows = 20


def print_df(df):
    old_col, pd.options.display.max_columns = pd.options.display.max_columns, None
    old_row, pd.options.display.max_rows = pd.options.display.max_rows, None
    print(df)
    pd.options.display.max_columns = old_col
    pd.options.display.max_rows = old_row
