import random

countries = ['Kazakhstan', 'Russia', 'China']
cities = {
    'Kazakhstan': ['Almaty', 'Astana', 'Atyrau'], 
    'Russia': 'Moscow', 
    'China': 'Beijing'
}
streets = {
    'Almaty': ['Abaya', 'Tole Bi', 'Seifullina'],
    'Astana': ['Jeltoksan', 'Kabanbai Batyra', 'Pravaya Naberejnaya'],
    'Atyrau': ['Alash', 'Baimukhanova', 'Ualikhanova'],
    'Moscow': ['Arbat', 'Solyanka', 'Tverskaya'],
    'Beijing': ['Wangfujing', 'Xidan', 'Pearl Market']
}

zips = {
    'Almaty': ['050037', '050000', '050054', '050062', '050060'],
    'Astana': ['010011', '010013', '010014', '010015', '010030'],
    'Atyrau': ['060000', '060001', '060003', '060004', '060005'],
    'Moscow': ['105077', '105120', '105118', '105175', '105275'],
    'Beijing': ['100071', '100025', '100043', '100032', '101149']
}
chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz'
digits = '01234567890123456789'

with open('employee_address.txt', 'w') as f:
    for i in range(100):
        country = countries[random.randint(0, 2)]
        if country == 'Kazakhstan':
            city = cities[country][random.randint(0, 2)]
        else:
            city = cities[country]
        z = zips[city][random.randint(0, 4)]
        f.write("INSERT INTO employee_address VALUES({}, '{}', '{}', '{}', '{}');\n".format(i + 1, country, city, streets[city][random.randint(0, 2)], random.randint(1, 1000)))
