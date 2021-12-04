import random

mails = ["@gmail.com", "@mail.ru", "@inbox.com", "@yahoo.com", "@hotmail.com", "@elefanto.kz"]
chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz0123456789'

def random_password():
    size = random.randint(3, 20)
    s = ''.join(random.sample(chars, size))
    return s

def random_mail():
    return random_password() + random.choice(mails)


with open('courier_account.txt', 'w') as f:
    for i in range(300):
        mail = random_mail()
        password = random_password()
        f.write("INSERT INTO courier_account VALUES(DEFAULT, '{}', '{}');\n".format(mail, password))
