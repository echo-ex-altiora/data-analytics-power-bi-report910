from sqlalchemy import create_engine # type: ignore
from sqlalchemy import inspect # type: ignore
from sqlalchemy import text # type: ignore
import pandas as pd

DATABASE_TYPE = 'postgresql'
DBAPI = 'psycopg2'
HOST = 'powerbi-data-analytics-server.postgres.database.azure.com'
USER = 'powerbi_read_only'
PASSWORD = 'Bk78g!4j'
DATABASE = 'postgres'
PORT = 5432
engine = create_engine(f"{DATABASE_TYPE}+{DBAPI}://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}")
engine.connect() # engine.commit()

inspector = inspect(engine)


table_names = inspector.get_table_names()
print(table_names)
df = pd.Series(data=table_names)
df.to_csv("table_names.csv", sep=',',index=False)

for table in table_names:
    column_names = inspector.get_columns(table)
    df = pd.DataFrame(data=column_names)
    df.to_csv(r""+table+"_columns.csv", sep=',',index=False)

