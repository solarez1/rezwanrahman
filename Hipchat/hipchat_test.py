import requests, json
#8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y
#c6cS2qXSv1zRyUUXpPsu3bebVF43wx8bvPQK5vg6

amessage = 'Hello World!'
room = 'https://api.hipchat.com/v2/room/room_name/notification'
headers = {'Authorization':'Bearer room_id', 'Content-type':'application/json'}
requests.post(url = room, data = json.dumps({'message':amessage}), headers = headers)
