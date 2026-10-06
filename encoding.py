import pandas as pd
from sqlalchemy import create_engine

df = pd.read_csv("pizza_types.csv", encoding='cp1252')
password = 'Prxthu#123'
engine = create_engine(f"mysql+pymysql://root:{password}@localhost/PIZZA")

df.to_sql(
    name='pizza_types',
    con=engine,
    if_exists='replace',
    index=False
    )
