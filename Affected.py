# coding: utf-8
# @autor Thyago Pereira da Silva 
import math
import csv
from math import radians, cos, sin, asin, sqrt 
import random
from datetime import datetime, timedelta, date

# -- O codigo faz muita consulta ao disco, perdemos cerca de  10 ^ -3 segundos a cada consulta --#
# -- Buscaremos usar threads ou auxilio do sistema operacional para paralelismo de processos -- #


# -- Retorna a distância(KM) entre dois pontos da terra (levando em conta a curvatura) -- # 
def get_distance(cord1,cord2):
    lat1 = radians(cord1["lat"])
    lng1 = radians(cord1["lng"])

    lat2 = radians(cord2['lat'])
    lng2 = radians(cord2['lng'])

    dlat = lat2 - lat1
    dlng = lng2 - lng1  

    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlng / 2)**2
    c = 2 * asin(sqrt(a)) 
    r = 6371

    return(c * r) 

# -- Acessa a base de ceps e retorna as cordenadas associadas a ele formato LAT,LNG -- #
def get_cord_cep(cep):
    with open('./Data/Cordenadas_Ceps.csv') as file : 
        reader  =  csv.DictReader(file)
        cord  = {'lat': 0 , 'lng': 0}
        for row in reader :
            if (row['Cep'] == cep):
                cord['lat'] = float(row['Lat'])
                cord['lng'] = float(row['Lng'])
                return cord 
        
        raise UnboundLocalError('Não foi possivel associar Lat e Lng a esse cep')



#-- Retorna uma lista de ruas dentro do raio(km) de infecção --#
def affected_area(cep,raio):
    afetadas = []
    cord1 = get_cord_cep(cep)
    with open('./Data/Cordenadas_Ceps.csv') as file:
        reader  = csv.DictReader(file)
        for row in reader:
            cord2 = get_cord_cep(row['Cep'])
            distance =  get_distance(cord1,cord2)
            if(distance <= raio):
                afetadas.append(row['Cep'])

    return afetadas

#-- Retorna o numero de casos dentro do Raio de infecção gerado --#
def number_ofCases_radius(afected_streets,base):
    with open(base +'.csv') as file:
        reader =  csv.DictReader(file)
        ceps = []
        for row in reader: 
            ceps.append(row["Cep"])

        count = 0
        for street in afected_streets:
            count += ceps.count(street)
        
        return count


#  -- Gera uma Lista com todos os dias de infecção do covid até o atual  --  #
def generate_date_interval():
    sdate = date(2020, 3, 27)   # start date - Primeiro Caso confirmado em CG - PB
    edate = date.today()   # end date - Dia de Hj

    delta = edate - sdate       # as timedelta
    days = []
    for i in range(delta.days + 1):
        day = sdate + timedelta(days=i)
        days.append(day)
    
    return days


# --  Retorna uma base de dados ficticia dentro do Raio de infecção gerado --#
# --  Para simplificar execute como python Affected.py > randomDatabase.csv --#
def randomDataBase(cep,raio_km,size):
    afected_streets =  affected_area(cep,raio_km)
    datas = generate_date_interval()
    
    print("Cep,Data")
    for i in range(size):
        data = random.choice(datas).strftime("%d/%m/%Y")
        local =  random.choice(afected_streets)
        print(local + "," + data)


numero_casos1 = number_ofCases_radius(affected_area('58429145',1),'RandomDB2')
numero_casos2 = number_ofCases_radius(affected_area('58404175',1),'RandomDB')


print( numero_casos2 - numero_casos1)




