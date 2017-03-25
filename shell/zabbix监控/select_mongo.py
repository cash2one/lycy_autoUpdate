# -*- coding: UTF-8 -*-
import pymongo
import socket

'''
判断mongodb数据库27117端口是否为Primary状态,True为真,False为假.
'''

DBUSER="op"
DBPASSWORD="yuncheng0613db"
#获取本机IP地址
local_IP = socket.gethostbyname(socket.gethostname())

def dbauth(local_IP):
    conn = pymongo.MongoClient(local_IP,27117)
    db = conn.is_primary
    return db

def db_select(db):
    if db == False:
        print '0'
    else:
	print '1'

if __name__ == "__main__":
     db = dbauth(local_IP)
     db_select(db)
