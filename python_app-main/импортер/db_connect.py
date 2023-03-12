import psycopg2

def connect_db():
 connection = psycopg2.connect(user="postgres",
                              password="mysecretpassword",
                              host="database",
                              port="5432",
                              database="app_db")
 return connection
