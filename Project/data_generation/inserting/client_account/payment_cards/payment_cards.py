import random

digits = '0123456789012345678901234567890123456789'

def random_number():
    return ''.join(random.sample(digits, 16))


with open('payment_cards.txt', 'w') as f:
    b = ['True', 'False']
    for i in range(100):
        for j in range(random.randint(1, 4)):
            card_number = random_number()
            f.write("INSERT INTO client_payment_cards VALUES(DEFAULT, {}, {});\n".format(i + 1, card_number))
