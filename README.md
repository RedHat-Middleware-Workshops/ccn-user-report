# CCN User Report 

![Landing Page](images/landingpage.png)

## Local Deployment 

### Build and Push this as an Image

A *scripts/* directory includes *build* and *push* scripts to create a build
using the docker CLI, and push it to [quay.io](https;//quay.io).


**Sample usage:**

```bash
$ # This can take a while depending on your connection speed and machine specs
$ TAG=v0.0.8 ./scripts/image.build.sh 

$ # Pushes the image to quay.io for the specified user.
$ # This is bound by your upload speed...so be patient ☕
$ QUAY_USER=your-username TAG=v0.0.8 ./scripts/image.push.sh
```

The scripts which check for the Kubernetes objects require a set of environment variables in order to find the OpenShift cluster to check against. The following example runs the image on a development machine with the corrent environment variables set.

**Run image locally**
```
$ docker run -d -p 5000:5000 --name ccn-user-report \
  -e OPENSHIFT_USERNAME=opentlc-mgr \
  -e OPENSHIFT_PASSWORD=password \
  -e OPENSHIFT_URL=https://api.cluster-GUID.GUID.sandbox1553.opentlc.com:6443/ \
  -e OPENSHIFT_SKIP_TLS=true \
  ccn-user-report:v0.0.8
```

### Local Testing and Development endpoints

There are three steps to generating a report or set of reports of user progress through a containers and cloud native workshop.

First, we generate a list of users to check against. There's a link to the list generator on the index page or you can navigate to [http://localhost:5000/user_generator](http://localhost:5000/user_generator) to generate the list. Enter the number of users that you're going to check against.

Once the userlist is populated, you can launch a progress check from the [http://localhost:5000/user_progress](http://localhost:5000/user_progress) page. These checks can take a few minutes to run and the web service will not allow more than one to run simultaneously. As the progress checks run, they populate files on the local filesystem with the status of the user's progress.

You can either check a particular user's progress (i.e. 6 for user6) or you can check the progress of all the users from the userlist generated in the first step. To check all users, enter "0" in the box instead of the user number.

Finally, once the status cache is generated, reports can be run against the cached progress data. Reports can be printed to the screen or downloaded in CSV or JSON format.

* Check user Report
[http://localhost:5000/print_user_report](http://localhost:5000/print_user_report)
* Download CSV file via cli
```
$ curl -o my_report.csv --location --request GET 'http://localhost:5000/export_csv/module1'
```
* Download JSON file via cli
```
$ curl -o my_report.json --location --request GET 'http://localhost:5000/export_json/module1'
```

## Deploy using OC CLI  

1) First, a project for the user report service to run in.

```
$ oc new-project ccn-user-report
```

2) The service uses a set of environment variables to determine the OpenShift endpoint to check against. Edit ```openshift/project.yml``` and replace the values to match your OpenShift deployment

```
            env:
              - name: OPENSHIFT_USERNAME
                value: opentlc-mgr
              - name: OPENSHIFT_PASSWORD
                value: <your password>
              - name: OPENSHIFT_URL
                value: https://api.cluster-<your cluster>.opentlc.com:6443/
              - name: OPENSHIFT_SKIP_TLS
                value: 'true'
              - name: SKIP_CODE_READY_CHECKS
                value: 'FALSE'
```

3) Deploy the service using the following DeploymentConfig
```
$ oc create -f openshift/project.yml  
```

## OpenShift Usage 
Once the application is deployed, it should be available via the OpenShift route created by the [openshift/project.yml](openshift/project.yml) template. To find the route, run:

```
$ oc get route | grep user-report | awk '{print $2}'
```

There are three steps to generating a report or set of reports of user progress through a containers and cloud native workshop.

First, we generate a list of users to check against. Either open the route in a web browser and follow the "Generate users" link on the home page, or navigate to http://$ROUTE/user_generator to generate the list. Enter the number of users that you're going to check against.

Once the userlist is populated, you can launch a progress check from the "CCN User Progress" link on the home page, or navigate to http://$ROUTE/user_progress. These checks can take a few minutes to run and the web service will not allow more than one to run simultaneously. As the progress checks run, they populate files on the local filesystem with the status of the user's progress.

You can either check a particular user's progress (i.e. 6 for user6) or you can check the progress of all the users from the userlist generated in the first step. To check all users, enter "0" in the box instead of the user number.

Finally, once the status cache is generated, reports can be run against the cached progress data. Reports can be printed to the screen or downloaded in CSV or JSON format. Links to the various reports are available on the top navigation of the tool.
