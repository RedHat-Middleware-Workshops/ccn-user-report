#!/usr/bin/env python
import yaml
import io
import glob
import re
import csv
import os
import argparse
import sys
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
  if not os.path.exists('report.csv'):
    with open('report.csv', 'w'): pass
    

def createcsvheader(module_type):
  modules=generateuserheading(module_type)
  with open('report.csv', 'w') as csvfile:
    filewriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    filewriter.writerow(modules)


def createcsvreport(item):
  with open('report.csv', 'a') as csvfile:
    filewriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    filewriter.writerow(item)
    
def load_modules():
  try:
    with open('libs/modules.yml') as stream:
      data = yaml.load(stream)
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
  dictionary = yaml.load(stream)
  for key, value in dictionary.items():
    generatelist(module_type) 
  return generatelist(module_type) 


def userreport(module_type, verbose):
  #report=glob.glob("reports/*")
  report=sorted(glob.glob("workspace/*"),key=os.path.getmtime)
  modules=readyaml(module_type)
  for user in report:
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

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("module",type=str,help="Enter module types: Supported modules are module1,module2,module3,module4")
  parser.add_argument("-v", "--verbose", help="modify output verbosity", action = "store_true")
  args = parser.parse_args()
  print(args)
  createcsvfile()
  createcsvheader(args.module)
  userreport(args.module,args.verbose)

main()
