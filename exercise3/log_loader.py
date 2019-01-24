import sqlite3
import json
import re


# Setup functions for data processing pipeline
def line_generator(file_path):
    '''
    Open the file at the given path and return the lines in the file as
    a generator.
    '''
    f = open(file_path)
    for line in f:
        yield line
    f.close()

def json_generator(lines):
    '''
    Receive a generator of lines and convert lines to JSON for easy parsing
    '''
    for line in lines:
        try:
            yield json.loads(line)
        # Skip lines like '2018/03/14 10:58:15 net/http: invalid byte '"' in Cookie.Value; dropping invalid bytes'
        except ValueError:
            continue


def experiment_requests_generator(json_objs):
    '''
    Receive a generator of json objects and yield only those that correspond to
    experiment requests.
    '''
    for json_obj in json_objs:
        if json_obj['msg'].startswith("Request Number is"):
            yield json_obj


def parse_experiment_request(experiment_request_objs):
    '''
    Receive a generator of experiment_requests and yield the details required
    to populate the group_assignments table.
    '''
    pattern = (r"Request Number is : (?P<request_number>\d+),"
               r".* assigned to (?P<group_type>\w+)"
               r" for (?P<experiment>\w+-\w+)")
    regex_pattern = re.compile(pattern)

    for experiment_request in experiment_request_objs:
        experiment_detail = regex_pattern.search(experiment_request['msg']).groupdict()
        # test to Test, control to Control
        experiment_detail['group_type'] = experiment_detail['group_type'].capitalize()
        # Add the date from the timestamp
        experiment_detail['date'] = experiment_request['time'].split("T")[0]
        yield experiment_detail


if __name__ == '__main__':
    conn = sqlite3.connect("./exercise3/lighthouse_logs")
    cursor = conn.cursor()

    # create table
    cursor.execute(
        '''CREATE TABLE IF NOT EXISTS visitor_assignments(
            Date TEXT,
            Request_Number TEXT,
            Group_Type TEXT,
            Experiment TEXT
        );''')
    conn.commit()

    # Build data processing pipeline
    log_file_path = "./exercise3/lighthouse-logs.log"
    log_lines = line_generator(log_file_path)
    json_objects = json_generator(log_lines)
    experiment_requests = experiment_requests_generator(json_objects)
    experiment_details = parse_experiment_request(experiment_requests)

    # Push output to database
    for row in experiment_details:
        cursor.execute(
            'INSERT into visitor_assignments VALUES(?,?,?,?)',
            (row['date'], row['request_number'], row['group_type'], row['experiment'])
        )
    conn.commit()
