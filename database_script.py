import psycopg2

def allDataTransfered(conn):
    cursor = conn.cursor()
    cursor.execute('SELECT count(*) FROM copied_tables where is_copied=false')
    result = cursor.fetchone()[0] == 0
    cursor.close()
    return result

def transferBatch(conn, script):
    cursor = conn.cursor()
    cursor.callproc('copy', [10])
    cursor.close()
    conn.commit()

def init():
    conn = psycopg2.connect(host='localhost', database='hh_homework',
    user='vitalib', password="dbnfkbr83")
    cursor = conn.cursor()
    cursor.execute(open('mapping.sql', 'r').read())
    return conn

if __name__ == '__main__':
    conn = init()
    transferBatch_script = open('transfer.sql', 'r').read()
    while (not allDataTransfered(conn)):
        print("in while loop")
        transferBatch(conn, transferBatch_script)
