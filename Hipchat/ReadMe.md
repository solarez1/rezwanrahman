#Usage Example of the logging module

import sys
 
sys.path.insert(0,"C:\\Users\\rrahman\\Documents\\myPythonProjects\\Hipchat")
 
from hipchat_notify import hipchat_notify
 
 
def test_func():
 
    try:
 
        message = 1/0
 
    except Exception as exception:
 
        message = str(exception)
 
        return hipchat_notify('8OaIJuU0ViOvav3SAsE504Q3XkVxpmPG8Zadq70y', 'LoggingTest', message, 'Database', __file__, 'red')
