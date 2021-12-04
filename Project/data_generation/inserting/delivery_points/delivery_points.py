import random

countries = ['Kazakhstan', 'Russia', 'China']
cities = {
    'Kazakhstan': ['Almaty', 'Astana', 'Atyrau'], 
    'Russia': 'Moscow', 
    'China': 'Beijing'
}

with open('employee_work_info.txt', 'w') as f:
    for i in range(100):
        date = random_date()
        f.write("INSERT INTO employee_work_info VALUES({}, '{}', {});\n".format(i + 1, date, salaries[random.randint(0, 3)]))
