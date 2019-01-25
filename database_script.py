import psycopg2

def allDataTransfered(cursor):
    cursor.execute('SELECT count(*) FROM copied_tables where is_copied=false')
    return cursor.fetchone()[0] == 0

def transferBatch(cursor, script):
    cursor.execute(script)



def init():
    conn = psycopg2.connect(host='localhost', database='hh_homework',
    user='vitalib', password="dbnfkbr83")
    cursor = conn.cursor()
    cursor.execute(open('mapping.sql', 'r').read())
    return cursor

if __name__ == '__main__':
    cursor = init()
    transferBatch_script = open('transfer.sql', 'r').read()
    while (not allDataTransfered(cursor)):
        print("in while loop")
        transferBatch(cursor, transferBatch_script)
