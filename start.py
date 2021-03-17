from flask_socketio import SocketIO, emit
from flask import Flask, render_template, url_for, copy_current_request_context
from random import random
from time import sleep
import fasteners
import subprocess, os
from subprocess import PIPE, CalledProcessError, check_call, Popen
import time 
import json 
import logging
import generate_csv_flask
from flask import send_file
from markupsafe import escape
import glob

__author__ = 'tosin'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True
app.config['LOG_FILE'] = 'application.log' 

if app.debug: 
    import logging 
    logging.basicConfig(level=logging.WARNING)
    from logging import FileHandler, Formatter 
    file_handler = FileHandler(app.config['LOG_FILE']) 
    app.logger.addHandler(file_handler) 
    file_handler.setFormatter(Formatter( 
        '%(asctime)s %(levelname)s: %(message)s ' 
        '[in %(pathname)s:%(lineno)d]' 
    )) 
#turn the flask app into a socketio app
socketio = SocketIO(app, async_mode=None, logger=True, engineio_logger=True)


def generate_user_file(json):
  with fasteners.InterProcessLock("generate_user_file.lock"):
    try:
      check=json['message']
      command = ['./user-generator.sh', str(check)]
      process = subprocess.Popen(command, stdout=subprocess.PIPE)
      while True:
        line = process.stdout.readline()
        app.logger.info('in while loop: ', str(line.decode("utf-8").rstrip()))
        if not line:
          break
        #the real code does filtering here
        app.logger.info('received create_user: ', str(line.decode("utf-8").rstrip()))
        socketio.emit('user_created', {'data': line.decode("utf-8").rstrip()}, callback=messageReceived)
        socketio.sleep(0.001)
      process.stdout.close()
      fasteners.InterProcessLock("generate_user_file.lock").release()
    except KeyError:
        socketio.emit('user_created', {'data': 'I have the lock on file generate_user_file.lock'}, callback=messageReceived) 
        app.logger.warning('I have the lock on file generate_user_file.lock')

def user_progress_monitoring(json):
  module_num=json['module_num']
  usernum='user'+str(json['user'])
  if int(json['user']) == 0:
    usernum="all"

  with fasteners.InterProcessLock("user_progress_monitoring_file.lock"):
    try:
      app.logger.info('in try statement: ' +str(json['module_num'])+' '+str(usernum))
      proc = subprocess.Popen([ './user-report.sh', str(json['module_num']), str(usernum)],
              bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
      for line in iter(proc.stdout.readline, b''):
        app.logger.info('received user_progress: ', line)
        socketio.emit('user_progress', {'user': line.decode("utf-8").rstrip()}, callback=user_progress_messageReceived)
      proc.stdout.close()
      proc.wait()
      fasteners.InterProcessLock("user_progress_monitoring_file.lock").release()
    except KeyError:
      socketio.emit('user_progress', {'data': 'I have the lock on file user_progress_monitoring_file.lock'}, callback=user_progress_messageReceived) 
      app.logger.warning('I have the lock on file user_progress_monitoring_file.lock')


def all_user_progress_monitoring(json):
  module_num=json['module_num']
  if int(module_num) == 0:
    module_num="all"

  with fasteners.InterProcessLock("all_user_progress_monitoring_file.lock"):
    try:
      app.logger.info('in try statement: ' +str(module_num))
      proc = subprocess.Popen([ './user-report.sh', str(module_num)],
              bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
      for line in iter(proc.stdout.readline, b''):
        app.logger.info('received user_progress: ', line)
        socketio.emit('user_progress', {'user': line.decode("utf-8").rstrip()}, callback=all_user_progress_messageReceived)
      proc.stdout.close()
      proc.wait()
      fasteners.InterProcessLock("all_user_progress_monitoring_file.lock").release()
    except KeyError:
      socketio.emit('user_progress', {'data': 'I have the lock on file all_user_progress_monitoring_file.lock'}, callback=all_user_progress_messageReceived) 
      app.logger.warning('I have the lock on file all_user_progress_monitoring_file.lock')

def user_report_status(json):
  usernum='user'+str(json['user'])
  if int(json['user']) == 0:
     app.logger.info('in if statement: '+str(json['user']))
     report=sorted(glob.glob("workspace/*"),key=os.path.getmtime)
     for user in report:
      #app.logger.info('Print report for all users: '+str(os.path.split(user)[1]))
      if (str(os.path.split(user)[1]) not in ["userlist", "report.json", "report.csv"]):
        single_user_report(str(os.path.split(user)[1]))
  else:
    single_user_report(usernum)

def single_user_report(usernum):
  app.logger.info('in try statement: '+str(usernum))
  proc = subprocess.Popen([ '/bin/cat', 'workspace/'+str(usernum)],
          bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
  socketio.emit('print_user_report_message', {'user': "*********************************"}, callback=user_report_messageReceived)
  socketio.emit('print_user_report_message', {'user': str(usernum)+" CCN Roadshow(Dev Track) Report"}, callback=user_report_messageReceived)
  socketio.emit('print_user_report_message', {'user': "*********************************"}, callback=user_report_messageReceived)
  for line in iter(proc.stdout.readline, b''):
    app.logger.info('received user_report: ', line)
    socketio.emit('print_user_report_message', {'user': line.decode("utf-8").rstrip()}, callback=user_report_messageReceived)
  proc.stdout.close()
  proc.wait()

@app.route('/')
def index():
    #only by sending this page first will the client be connected to the socketio instance
    return render_template('index.html')

@app.route('/user_generator', methods=["GET", "POST"])
def user_generator():
  #only by sending this page first will the client be connected to the socketio instance
  return render_template('user_generator.html')

@app.route('/messageReceived', methods=["GET", "POST"])
def messageReceived(methods=['GET', 'POST']):
  return  print('message was received!!!')

@socketio.on('create_user')
def handle_my_custom_event(json, methods=['GET', 'POST']):
  try:
    value = int(json['message'])
    generate_user_file(json)
  except ValueError:
      app.logger.warning('message is empty or incorrect: ')
      pass


@app.route('/all_users_report', methods=["GET", "POST"])
def all_users_generator():
  #only by sending this page first will the client be connected to the socketio instance
  return render_template('all_users_report.html')

@app.route('/all_user_progress_messageReceived', methods=["GET", "POST"])
def all_user_progress_messageReceived(methods=['GET', 'POST']):
  return  print('message was received!!!')

@socketio.on('query_all_user_progress')
def handle_user_progress(json, methods=['GET', 'POST']):
  try:
    value = str(json['user'])
    all_user_progress_monitoring(json)
  except ValueError:
      app.logger.warning('user info is empty or incorrect: ')
      pass



@app.route('/user_progress', methods=["GET", "POST"])
def user_progress():
  #only by sending this page first will the client be connected to the socketio instance
  return render_template('user_progress.html')

@app.route('/user_progress_messageReceived', methods=["GET", "POST"])
def user_progress_messageReceived(methods=['GET', 'POST']):
  return  print('message was received!!!')

@socketio.on('create_user_progress')
def handle_user_progress(json, methods=['GET', 'POST']):
  try:
    value = int(json['user'])
    user_progress_monitoring(json)
  except ValueError:
      app.logger.warning('user info is empty or incorrect: ')
      pass

@app.route('/print_user_report', methods=["GET", "POST"])
def user_report():
  #only by sending this page first will the client be connected to the socketio instance
  return render_template('print_user_report.html')

@app.route('/user_report_messageReceived', methods=["GET", "POST"])
def user_report_messageReceived(methods=['GET', 'POST']):
  return  print('message was received!!!')

@socketio.on('create_user_report')
def handle_user_progress(json, methods=['GET', 'POST']):
  app.logger.warning(json['user'])
  try:
    #value = int(json['user'])
    user_report_status(json)
  except ValueError:
      app.logger.warning('user info is empty or incorrect: ')
      pass

@app.route('/export_csv/<modulenum>', methods=["GET", "POST"])
def export_csv(modulenum):
  #only by sending this page first will the client be connected to the socketio instance
  try:
    app.logger.info(str(generate_csv_flask.main(escape(modulenum), False)))
    return send_file('/opt/app-root/src/workspace/report.csv', as_attachment=True, cache_timeout=0)
  except:
    app.logger.warning('Failed to call export_csv function: ')
    return 'Failed to genereate csv file. Please run report before calling this function.'
 

@app.route('/export_json/<modulenum>', methods=["GET", "POST"])
def export_json(modulenum):
  #only by sending this page first will the client be connected to the socketio instance
  try:
    app.logger.info(str(generate_csv_flask.main(escape(modulenum), False)))
    return send_file('/opt/app-root/src/workspace/report.json', as_attachment=True, cache_timeout=0)
  except:
    app.logger.warning('Failed to call export_json function: ')
    return 'Failed to genereate json file. Please run report before calling this function.'
 


if __name__ == '__main__':
    socketio.run(app, debug=True)
