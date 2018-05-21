#test python script
from hipchat_notify import hipchat_notify

def test_func():
	try:
		message = 1/0
	except Exception as exception:
		message = str(exception)
		return hipchat_notify('8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y', 'LoggingTest', message, 'purple')