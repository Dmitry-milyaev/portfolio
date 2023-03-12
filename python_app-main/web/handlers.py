import requests
from fastapi import APIRouter, Body, Depends

router = APIRouter()

@router.get('/')
def get_info():
    url= 'http://gate:8000/get_info'
    response = requests.get(url)
    result = response.text.split("z")
    i = len(result)
    result[0]= result[0][1:-1]
    result.pop(i-1)
    i = len(result)
    while i!=0:
        print(result[i-1])
        i-=1
    return(result)

