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

<em>Output Examples</em>

<strong>Hipchat</strong>

![alt text](https://github.com/solarez1/rezwanrahman/blob/master/Hipchat/image2018-5-24_17-0-17.png)

CSV

![alt text](https://github.com/solarez1/rezwanrahman/blob/master/Hipchat/image2018-5-24_17-7-7.png)

EventViewer
 
![alt text](https://github.com/solarez1/rezwanrahman/blob/master/Hipchat/image2018-5-24_17-8-2.png)
