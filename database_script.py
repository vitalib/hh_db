import psycopg2

def allDataTransfered(conn):
    cursor = conn.cursor()
    cursor.execute('SELECT count(*) FROM copied_tables where is_copied=false')
    uncopied_tables = cursor.fetchone()[0]
    print("{} tables left".format(uncopied_tables))
    cursor.close()
    return uncopied_tables == 0

def transferBatch(conn):
    cursor = conn.cursor()
    results = cursor.callproc('copy', [100000,])
    cursor.close()
    conn.commit()

if __name__ == '__main__':
    conn = psycopg2.connect(host='localhost', database='hh_homework',
            user='vitalib', password="dbnfkbr83")
    while (not allDataTransfered(conn)):
        transferBatch(conn)
    print('Done')
