import random, datetime, math

start_date = datetime.date(2020, 12, 3)
end_date = datetime.date(2021, 12, 3)
time_between_date = end_date - start_date
days_between_dates = time_between_date.days

salaries = ['10000', '20000', '30000', '40000']
delivery = ['truck', 'car']

def random_date():
    random_number_of_days = random.randrange(days_between_dates)
    random_date = start_date + datetime.timedelta(days=random_number_of_days)
    return random_date

with open('employee_work_info.txt', 'w') as f:
    for i in range(100):
        date = random_date()
        f.write("INSERT INTO employee_work_info VALUES({}, '{}', {}, '{}');\n".format(i + 1, date, salaries[random.randint(0, 3)], delivery[int(math.floor(random.random() + 0.7))]))
