import threading
import requests
import json
from datetime import datetime
from db_connect import connect_db

def importer():
    threading.Timer(60.0, importer).start()
#    f = open('log.log', 'a')
    api = '2639ccac02d7c15359d45f9a2bc9d8ea'
    params = {'access_key': api,'currencies': 'AED, CNY, HKD, RUB, EUR, JPY, CHF', 'format': 1}
    r = requests.get('http://apilayer.net/api/live', params = params)
    OutTxt = json.loads(r.text)
    value = str(OutTxt['quotes']['USDAED'])
    time=datetime.utcfromtimestamp(OutTxt['timestamp']).strftime('%Y-%m-%d %H:%M:%S')
    Session_connect=connect_db()
    cursor=Session_connect.cursor()
    cursor.execute("insert into  public.AED_history_data(date, value) values(%s,%s);",(time,value))
    Session_connect.commit()
    cursor.close()
    Session_connect.close()
#    f.write(time + " " + value + "\n")
#    f.close()

importer()


