#test python script
from hipchat_notify import hipchat_notify

def test_func():
	try:
		message = 1/0
	except Exception as exception:
		message = str(exception)
		return hipchat_notify('room_id', 'room_name', message, 'purple')
