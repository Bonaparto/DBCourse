import random

size = ['flat envelope', 'small', 'medium', 'large']
b = ['True', 'False']
chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz'
digits = '01234567890123456789'

def random_string():
    size = random.randint(3, 30)
    return ''.join(random.sample(chars, size))

def random_number():
    return round(random.random() * 10, 2)

with open('products.txt', 'w') as f:
    for i in range(100):
        number = random_number()
        name = random_string()
        f.write("INSERT INTO products VALUES({}, '{}', '{}', {}, '{}');\n".format(i + 1, name, b[random.randint(0, 1)], random_number(), size[random.randint(0, 3)]))
