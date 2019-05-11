with open('/etc/apache2/apache2.conf', 'r') as f1, open('/etc/apache2/apache2.tmp', 'w') as f2:
    f=False
    for line in f1.readlines():
        if f:
            if line == "AllowOverride None\n" or "AllowOverride None \n":
                f2.write("AllowOverride All\n")
            else:
                f2.write(line)
                if line == "</Directory>\n" or "</Directory> \n":
                    f=False
        else:
            if line == "<Directory /var/www/>\n" or "<Directory /var/www/> \n":
                f=True
                
    
    
 
