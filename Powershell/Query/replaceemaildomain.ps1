$email = "test@asdfasfa.com"
$email -match "@\S+" | Out-Null
$replace = $email.Replace($matches[0],"@mr.sdlproducts.com")  
write-host $replace