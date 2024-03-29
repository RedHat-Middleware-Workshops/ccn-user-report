#!/usr/bin/python3
import yaml
import io
import glob
import re
import csv
import os
import argparse
import sys
import pandas as pd
import json
#import debugpy #uncomment to debug
import time


# 5678 is the default attach port in the VS Code debug configurations. Unless a host and port are specified, host defaults to 127.0.0.1
# https://code.visualstudio.com/docs/python/debugging
#debugpy.breakpoint()
#print('break on this line')
#sec = input('Let us wait for user input. Let me know how many seconds to sleep now.\n')
#print('Going to sleep for', sec, 'seconds.')
#time.sleep(int(sec))
#print('Enough of sleeping, I Quit!')

def createcsvfile():
  if not os.path.exists('/opt/app-root/src/workspace/report.csv'):
    with open('/opt/app-root/src/workspace/report.csv', 'w'): pass
    

def createcsvheader(module_type):
  modules=generateuserheading(module_type)
  with open('/opt/app-root/src/workspace/report.csv', 'w') as csvfile:
    filewriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    filewriter.writerow(modules)

def make_json(csvFilePath, jsonFilePath): 
	data = {} 
	with open(csvFilePath, encoding='utf-8') as csvf: 
		csvReader = csv.DictReader(csvf) 
		for rows in csvReader: 
			key = rows['User'] 
			data[key] = rows 
	with open(jsonFilePath, 'w', encoding='utf-8') as jsonf: 
		jsonf.write(json.dumps(data, indent=4)) 


def createcsvreport(item):
  with open('/opt/app-root/src/workspace/report.csv', 'a') as csvfile:
    filewriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    filewriter.writerow(item)
    
def load_modules():
  try:
    with open('libs/modules.yml') as stream:
      data = yaml.load(stream , Loader=yaml.FullLoader)
      return data
  except IOError as error:
    print ('File error: ' + str(error))


def generateuserheading(module_type):
  List = [] 
  List.append("User")
  List.append("Full Name")
  List.append("Email")
  settings=load_modules()
  if module_type == "module1":
    for modulelist in settings['module1']:
      List.append(modulelist)
  elif module_type == "module2":
    for modulelist in settings['module2']:
      List.append(modulelist)
  elif module_type == "module3":
    for modulelist in settings['module3']:
      List.append(modulelist)
  elif module_type == "module4":
    for modulelist in settings['module4']:
      List.append(modulelist)
  elif module_type == "openshift101":
    for modulelist in settings['openshift101']:
      List.append(modulelist)
  elif module_type == "machinelearning":
    for modulelist in settings['machinelearning']:
      List.append(modulelist)
  else:
    sys.exit("Incorrect Module passed '"+ module_type + "' is invalid.")
  return List


def generatelist(module_type):
  List = [] 
  settings=load_modules()
  if module_type == "module1":
    for modulelist in settings['module1']:
      List.append(modulelist)
  elif module_type == "module2":
    for modulelist in settings['module2']:
      List.append(modulelist)
  elif module_type == "module3":
    for modulelist in settings['module3']:
      List.append(modulelist)
  elif module_type == "module4":
    for modulelist in settings['module4']:
      List.append(modulelist)
  elif module_type == "openshift101":
    for modulelist in settings['openshift101']:
      List.append(modulelist)
  elif module_type == "machinelearning":
    for modulelist in settings['machinelearning']:
      List.append(modulelist)
  else:
    sys.exit("Incorrect Module passed '"+ module_type + "' is invalid.")
  return List

def readyaml(module_type):
  stream = open("libs/modules.yml", 'r')
  dictionary = yaml.load(stream, Loader=yaml.FullLoader)
  for key, value in dictionary.items():
    generatelist(module_type) 
  return generatelist(module_type) 


def userreport(module_type, verbose):
  #report=glob.glob("/opt/app-root/src/workspace/*")
  report=sorted(glob.glob("/opt/app-root/src/workspace/*"),key=os.path.getmtime)
  modules=readyaml(module_type)
  for user in report:
    print("Before if statement "+str(user))
    if (user not in ["/opt/app-root/src/workspace/userlist", "/opt/app-root/src/workspace/report.json", "/opt/app-root/src/workspace/report.csv"]):
      print("USERNAME: "+str(os.path.split(user)[1]))
      generatereport=[]
      generatereport.append(str(os.path.split(user)[1]))
      generatereport.append("UNKNOWN")
      generatereport.append("UNKNOWN")
      print("Reading "+str(user))
      count = 1
      with open(user, 'r') as f:
        for line in f:
            if verbose:
              print(len(modules)) 
            for i in range(len(modules)):
              if verbose:
                print("LINE: {}: {}".format(i + 1, modules[i]))
              if re.match("("+modules[i]+":)(.*)", line):
                x = line.split(": ")
                if verbose:
                  print("STRING: "+str(count)+" <-> "+x[0]+" <--> "+x[1])
                generatereport.append(re.sub('[^A-Za-z0-9]+', '', x[1]))
                if verbose:
                  print("LENGTH OF "+str(user)+" Report TRUE/FALSE: "+str(len(generatereport)-3))
            count+=1
            if verbose:
              print(generatereport)
        createcsvreport(generatereport)
      csvFilePath = r'/opt/app-root/src/workspace/report.csv'
      jsonFilePath = r'/opt/app-root/src/workspace/report.json'
      make_json(csvFilePath, jsonFilePath)

def main(module, verbose):
  createcsvfile()
  createcsvheader(module)
  userreport(module,verbose)

#main()
