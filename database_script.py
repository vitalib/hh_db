import psycopg2

def allDataTransfered(conn):
    cursor = conn.cursor()
    cursor.execute('SELECT count(*) FROM copied_tables where is_copied=false')
    tables = cursor.fetchone()[0]
    print(tables)
    cursor.close()
    return tables == 0

def transferBatch(conn):
    cursor = conn.cursor()
    results = cursor.callproc('copy', [10000,])
    cursor.close()
    conn.commit()

if __name__ == '__main__':
    conn = psycopg2.connect(host='localhost', database='hh_homework',
            user='vitalib', password="dbnfkbr83")
    while (not allDataTransfered(conn)):
        print("in while loop")
        transferBatch(conn)
