# helper functions for cafe example

import os

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')
    
def cf_output(outputs, requested_output):
    for output in outputs:
        keyName = output["OutputKey"]
        if keyName == requested_output:
            output_value = output["OutputValue"]
            print("Output: %s = %s" % ( requested_output, output_value))
            return(output_value)
    return(None)