from fastapi import APIRouter, Body, Depends
from db_connect import connect_db

router = APIRouter()

@router.get('/get_info', name='user:create')
def select():
    Session_connect=connect_db()
    cursor=Session_connect.cursor()
    cursor.execute("select * from public.AED_history_data")
    i=0
    for row in cursor:
      if i==0:
       tmp_string = "Date: " + row[1].strftime("%d-%m-%Y")+ " Time: " + row[1].strftime("%H:%M") + " Value: " + str(round(row[2],4)) 
       result = tmp_string + "z"
       i= i + 1
       tmp = row[2]
      else : 
       tmp_string = "Date: " + row[1].strftime("%d-%m-%Y") + " Time: " + row[1].strftime("%H:%M") + " Value: " + str(round(row[2],4)) + " Change: " + str(round((((row[2]/tmp)-1)*100),2)) + "%"  
       result += tmp_string + "z"
       i= i + 1
       tmp = row[2]
    print(result)
    cursor.close()
    Session_connect.close()
    return(result)

@router.get('/')
def hello():
  string_out = "Hello"
  return string_out