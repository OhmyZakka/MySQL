#!/usr/bin/env python
#:***********************************************
#:Program: MariaDB Openstack User privilege check
#:
#:Author: ohmyzakka@gmail.com
#:
#:History: 2017-11-27
#:
#:Version: 1.0
#:***********************************************
#:Mode: MySQL-python.x86_64

import MySQLdb as mdb

#Please configure the follow variables
mysql_ip = ''
mysql_port = ''
mysql_user = ''
mysql_pass = ''
allow_ipnet = ''
mysql_db = ''

user_lista = [
    #['db_user','allow_db_name','allow_host','grant1,grant2']

    # nova
    ['nova', 'nova', 'localhost', 'select,insert,update,delete'],
    ['nova', 'nova_api', 'localhost', 'select,insert,update,delete'],
    ['nova', 'nova_cell0', 'localhost', 'select,insert,update,delete'],
    ['nova', 'nova', allow_ipnet, 'select,insert,update,delete'],
    ['nova', 'nova_api', allow_ipnet, 'select,insert,update,delete'],
    ['nova', 'nova_cell0', allow_ipnet, 'select,insert,update,delete'],

    # keystone
    ['keystone', 'keystone', 'localhost', 'select,insert,update,delete'],
    ['keystone', 'keystone', allow_ipnet, 'select,insert,update,delete'],

    # cinder
    ['cinder', 'cinder', 'localhost', 'select,insert,update,delete'],
    ['cinder', 'cinder', allow_ipnet, 'select,insert,update,delete'],

    # glance
    ['glance', 'glance', 'localhost', 'select,insert,update,delete'],
    ['glance', 'glance', allow_ipnet, 'select,insert,update,delete'],

    # neutron
    ['neutron', 'neutron', 'localhost', 'select,insert,update,delete'],
    ['neutron', 'neutron', allow_ipnet, 'select,insert,update,delete'],

    # sstuser
    ['sstuser', '*', 'localhost', 'reload,process,lock tables,replication client'],

    # bkpuser
    ['bkpuser', '*', 'localhost', 'reload,process,lock tables,replication client'],

    # admin
    ['admin', '*', 'localhost', 'select,insert,update,delete,create,drop,reload,shutdown,process,index,alter,show databases,super,lock tables,execute,replication slave,replication client,create view,show view,create routine,alter routine,create user'],

    # clustercheckuser
    ['clustercheckuser', '*', 'localhost', 'process'],
]

#Note The following sections do not need to be viewed
con = None
try:
    out_file = open('./test_results.txt', 'wb+')
    try:
        con = mdb.connect(host=mysql_ip, port=mysql_port, user=mysql_user, passwd=mysql_pass, db=mysql_db)
    except:
        print 'Connect Error'
    cur = con.cursor()
    temp_stra = 'None'
    for lista in user_lista:
        temp_usera = None
        temp_hosta = None
        temp_db = None
        temp_granta = None
        temp_writea = 'None'
        temp_writeb = 'None'
        temp_lista = []
        temp_listb = ['localhost', allow_ipnet]
        flaga = False
        try:
          if lista[2] != 'localhost':
              cur.execute("select host from user where user='%s' and host !='localhost'" % lista[0])
              data1 = cur.fetchall()
              for tuplea in data1:
                  stra = str(tuplea).replace('(\'', '').lower().replace('\',)', '')
                  temp_lista.append(stra)

              if lista[2] in temp_lista:
                  cur.execute("show grants for %s@'%s'" % (lista[0], lista[2]))
                  data2 = cur.fetchall()
                  for tuplea in data2:
                      stra = str(tuplea).replace('`', '\'').lower().replace(
                          '("grant ', '').replace('",)', '')
                      if 'usage' in stra or 'identified' in stra:
                          if 'password' in stra and 'usage' not in stra:
                              temp_usera = \
                              stra.split(' identified by')[0].split('to ')[
                                  1].replace('\'', '').split('@')[0]
                              temp_hosta = \
                              stra.split(' identified by')[0].split('to ')[
                                  1].replace('\'', '').split('@')[1]
                              temp_db = \
                              stra.split(' identified by')[0].split('to ')[
                                  0].split(' on')[1].replace('\'', '').replace(
                                  '.*', '').replace(' ', '')
                              if lista[0] == temp_usera and lista[
                                  2] == temp_hosta and \
                                              lista[1] == temp_db:
                                  temp_granta = \
                                  stra.split('to ')[0].split(' on ')[0].replace(
                                      ', ', ',').split(',')
                                  temp_writea = str(
                                      set(lista[3].split(','))).replace('set([',
                                                                        '').replace(
                                      '])', '')
                                  temp_writeb = str(set(temp_granta)).replace(
                                      'set([', '').replace('])', '')
                                  grant_cpm1 = list(set(temp_granta).difference(
                                      set(lista[3].split(',')))) == []
                                  grant_cpm2 = list(
                                      set(lista[3].split(',')).difference(
                                          temp_granta)) == []
                                  if grant_cpm1 and grant_cpm2:
                                      flaga = True
                                      break
                      else:
                          temp_usera = \
                          stra.split('to ')[1].replace('\'', '').split('@')[0]
                          temp_hosta = \
                          stra.split('to ')[1].replace('\'', '').split('@')[1]
                          temp_db = stra.split('to ')[0].split(' on ')[1].replace(
                              '\'', '').replace('.*', '').replace(' ', '')
                          if lista[0] == temp_usera and lista[2] == temp_hosta and \
                                          lista[1] == temp_db:
                              temp_granta = stra.split('to ')[0].split(' on ')[
                                  0].replace(', ', ',').split(',')
                              temp_writea = str(
                                  set(lista[3].split(','))).replace('set([',
                                                                    '').replace(
                                  '])', '')
                              temp_writeb = str(set(temp_granta)).replace(
                                  'set([', '').replace('])', '')
                              grant_cpm1 = list(set(temp_granta).difference(
                                  set(lista[3].split(',')))) == []
                              grant_cpm2 = list(
                                  set(lista[3].split(',')).difference(
                                      temp_granta)) == []
                              if grant_cpm1 and grant_cpm2:
                                  flaga = True
                                  break
              else:
                  temp_writea = "Host Error: " +lista[2]+"--"+lista[0]+"--"+lista[1]
          else:
              cur.execute("show grants for %s@'%s'" % (lista[0], lista[2]))
              data2 = cur.fetchall()
              for tuplea in data2:
                  stra = str(tuplea).replace('`', '\'').lower().replace('("grant ', '').replace('",)', '')
                  if 'usage' in stra or 'identified' in stra:
                      if 'password' in stra and 'usage' not in stra:
                          temp_usera = \
                          stra.split(' identified by')[0].split('to ')[1].replace(
                              '\'', '').split('@')[0]
                          temp_hosta = \
                          stra.split(' identified by')[0].split('to ')[1].replace(
                              '\'', '').split('@')[1]
                          temp_db = \
                          stra.split(' identified by')[0].split('to ')[0].split(
                              ' on')[1].replace('\'', '').replace('.*',
                                                                  '').replace(' ',
                                                                              '')
                          if lista[0] == temp_usera and lista[2] == temp_hosta and \
                                          lista[1] == temp_db:
                              temp_granta = stra.split('to ')[0].split(' on ')[
                                  0].replace(', ', ',').split(',')
                              temp_writea = str(
                                  set(lista[3].split(','))).replace('set([',
                                                                    '').replace(
                                  '])', '')
                              temp_writeb = str(set(temp_granta)).replace(
                                  'set([', '').replace('])', '')
                              grant_cpm1 = list(set(temp_granta).difference(
                                  set(lista[3].split(',')))) == []
                              grant_cpm2 = list(
                                  set(lista[3].split(',')).difference(
                                      temp_granta)) == []
                              if grant_cpm1 and grant_cpm2:
                                  flaga = True
                                  break
                  else:
                      temp_usera = stra.split('to ')[1].replace('\'', '').split('@')[0]
                      temp_hosta = stra.split('to ')[1].replace('\'', '').split('@')[1]
                      temp_db = stra.split('to ')[0].split(' on ')[1].replace('\'', '').replace('.*', '').replace(' ', '')
                      if lista[0] == temp_usera and lista[2] == temp_hosta and lista[1] == temp_db:
                          temp_granta = stra.split('to ')[0].split(' on ')[
                              0].replace(', ', ',').split(',')
                          temp_writea = str(set(lista[3].split(','))).replace(
                              'set([', '').replace('])', '')
                          temp_writeb = str(set(temp_granta)).replace('set([',
                                                                      '').replace(
                              '])', '')
                          grant_cpm1 = list(set(temp_granta).difference(
                              set(lista[3].split(',')))) == []
                          grant_cpm2 = list(set(lista[3].split(',')).difference(
                              temp_granta)) == []
                          if grant_cpm1 and grant_cpm2:
                              flaga = True
                              break
        except:
            print "~~~~Please check the grant user info~~~~"
            temp_writea = "check user info error"
        print "--start Compare %s+%s+%s--" % (
        lista[0], lista[1], lista[2])
        if flaga:
            print ": Compare results: >>> OK "
        else:
            out_file.write("---start Compare %s+%s+%s--\n" % (
            lista[0], lista[1], lista[2]))
            out_file.write(": Compare results: False \n")
            print ": Compare results: False "
            out_file.write("You assign: " + temp_writea + "\n")
            out_file.write("SQL select: " + temp_writeb + "\n")
            out_file.write("---end---\n")
            out_file.write("\n")
        if temp_stra != lista[0]:
            cur.execute("select host from user where user='%s' and host not in('localhost','%s')" % (lista[0], allow_ipnet))
            data3 = cur.fetchall()
            for tupleb in data3:
                temp_other_ip = str(tupleb).replace('(\'', '').lower().replace('\',)', '')
                if temp_other_ip not in temp_listb:
                    out_file.write(">>>>User: %s Other IP: %s \n" % (lista[0], temp_other_ip))
            temp_stra = lista[0]
        print "---end---"
except:
    print "~~~~Exception: Exec error~~~~"
finally:
    try:
        if con != None:
            con.close()
        out_file.close()
    except:
        print 'Close Error'
