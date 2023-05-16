import time
from uuid import uuid4
from random import randint, choice
from datetime import datetime, timedelta

import requests
from faker import Faker
from faker.providers import company

fake = Faker()
fake.add_provider(company)


TICKET_API_URL = 'https://3v6s2g0n3b.execute-api.us-east-1.amazonaws.com/dev/ticket'


def generate_data(
    items,
    total_of_opened_items,
    total_of_closed_items,
    total_of_approved_items,
    total_of_deleted_items,
):
    tickets_id = []

    for item in range(1, items + 1):
        data = {
            'owner_id': str(uuid4()),
            'subject': fake.catch_phrase(),
            'text': fake.text(),
        }

        response = requests.post(
            url=TICKET_API_URL, json=data, headers={'Content-Type': 'application/json'}
        )
        total_of_opened_items += 1
        time.sleep(0.1)

        if item % 2 == 0:
            tickets_id.append(response.json()['ticket_id'])

    for ticket_id in tickets_id:
        status = choice(['closed', 'deleted'])
        data = {'status': status}

        response = requests.patch(
            url=f'{TICKET_API_URL}/{ticket_id}',
            json=data,
            headers={'Content-Type': 'application/json'},
        )

        if status == 'deleted':
            del tickets_id[ticket_id]
            total_of_deleted_items += 1
        else:
            total_of_closed_items += 1

        time.sleep(0.1)

    for idx in range(len(tickets_id)):
        if idx % 2 == 0:
            requests.patch(
                url=f'{TICKET_API_URL}/{tickets_id[idx]}',
                json={'status': 'approved'},
                headers={'Content-Type': 'application/json'},
            )
            total_of_approved_items += 1
            time.sleep(0.05)


if __name__ == '__main__':
    total_of_opened_items = 0
    total_of_closed_items = 0
    total_of_approved_items = 0
    total_of_deleted_items = 0
    start_time = time.perf_counter()

    print('starting generator for 1000 rounds')
    for round_number in range(1, 1001):
        start_round_time = time.perf_counter()
        random_value = randint(1, 11)
        print(f'starting round {round_number} with {random_value} values')
        generate_data(
            random_value,
            total_of_opened_items,
            total_of_closed_items,
            total_of_approved_items,
            total_of_deleted_items,
        )
        total_of_round_time = round((time.perf_counter() - start_round_time) / 60, 2)
        print(f'round {round_number} finished in {total_of_round_time} minutes')
        # fmt: off
        print(f'waiting next round starting on {(datetime.now() + timedelta(minutes=1)).isoformat()}\n')
        time.sleep(60)

    total_of_time = round((time.perf_counter() - start_time) / 60, 2)

    print(
        f'''
        Summary:
            Opened: {total_of_opened_items}
            Closed: {total_of_closed_items}
            Approved: {total_of_approved_items}
            Deleted: {total_of_deleted_items}

            Time elapsed: {total_of_time} minutes
    '''
    )
