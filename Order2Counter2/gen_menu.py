#!/usr/bin/env python3
menu = {
    'categories': [
        {
            'name': 'Machines',
            'items': [ 'ShoulderPress', 'BenchPress' ]
         },
        {
            'name': 'Drinks',
            'items': ['Ryze', 'RedBull' ]
        }
        ]
    }


import json
print(json.dumps(menu))
