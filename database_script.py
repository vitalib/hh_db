import psycopg2

def allDataTransfered(function_list):
    return len(function_list) == 0

def transferBatch(conn, function_list):
    cursor = conn.cursor()
    function = function_list.pop()
    cursor.callproc(function, [10000,])
    rows_copied = cursor.fetchone()[0]
    print(rows_copied)
    if rows_copied and int(rows_copied) > 0:
        function_list.append(function)
    cursor.close()
    conn.commit()

if __name__ == '__main__':
    conn = psycopg2.connect(host='localhost', database='hh_homework',
            user='vitalib', password="dbnfkbr83")
    function_list = [
                    'copy_vacancy_skill_set',
                     'copy_resume_skill_set',
                     'copy_message',
                     'copy_respond',
                     'copy_invitation',
                     'copy_vacancy',
                     'copy_resume',
                     'copy_account',
                     'map_equal_account',
                     'copy_company',
                     'map_equal_company',
                     'copy_skill',
                     'map_equal_skill',
                     'copy_job_location'
    ]
    while (not allDataTransfered(function_list)):
        transferBatch(conn, function_list)
    print('Done')
