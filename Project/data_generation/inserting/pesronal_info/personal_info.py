import random

g = ['f', 'm']
chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz'
digits = '01234567890123456789'
phone_size = 11

def random_string():
    size = random.randint(3, 20)
    return ''.join(random.sample(chars, size))

def random_number():
    phone = ''.join(random.sample(digits, phone_size))
    form_phone = ''
    for i in range(len(phone)):
        if(i == 6 or i == 8):
            form_phone += phone[i] + '-'
        elif(i == 0):
            form_phone += phone[i] + '('
        elif(i == 3):
            form_phone += phone[i] + ')'
        else:
            form_phone += phone[i]
    return form_phone

with open('employee_personal_info.txt', 'w') as f:
    for i in range(100):
        phone = random_number()
        first_name = random_string()
        second_name = random_string()
        f.write("INSERT INTO employee_personal_info VALUES({}, '{}', '{}', '{}', {}, '{}');\n".format(i + 1, first_name, second_name, g[random.randint(0, 1)],
        random.randint(18, 123), phone))
