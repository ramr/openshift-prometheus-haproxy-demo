openshift-prometheus-haproxy-demo
=================================
Demo repository to publish the OpenShift HAProxy router statistics using
the prometheus haproxy exporter to prometheus.


Demo
----
1. Start your OpenShift cluster as you would normally. Instructions will
   vary depending on how you do this in your environment. Example for a
   development environment, you can do this as follows:

        export WORKAREA="/home/ramr/workarea";
        export GOPATH="${WORKAREA}"

        mkdir -p "${WORKAREA}/src/github.com/openshift"
        cd "${WORKAREA}/src/github.com/openshift"
        git clone https://github.com/openshift/origin.git

        cd origin
        make  # or make release to also build the images

        nohup ./_output/local/bin/linux/amd64/openshift start --loglevel=4 &> /tmp/openshift.log &


2. Create a router service account and add it to the privileged SCC.

        echo '{ "kind": "ServiceAccount", "apiVersion": "v1", "metadata": { "name": "router" } }' | oc create -f -


        Either manually edit the privileged SCC and add the router account.

        oc edit scc privileged
        #  ...
        #  users:
        # - system:serviceaccount:openshift-infra:build-controller
        # - system:serviceaccount:default:router

        Or you can use jq to script it:

        sudo yum install -y jq
        oc get scc privileged -o json |
          jq '.users |= .+ ["system:serviceaccount:default:router"]' |
	     oc replace scc -f -


3. Pull down the prometheus and haproxy-exporter images.

        docker pull prom/haproxy-exporter
        docker pull prom/prometheus


4. Start the router using the router service account we created above and
   make sure you expose the haproxy metrics.

        oadm router --credentials=$KUBECONFIG --service-account=router  \
                    --replicas=1  --latest-images --expose-metrics


5.  As mentioned in the https://github.com/ramr/nodejs-header-echo repo,
    create a deployment, service and route.

        #  Update submodule to the nodejs-header-echo repo and build images.
        (cd nodejs-header-echo && git submodule update --init --recursive && make)

        #  Create deployment + secure/insecure services.
        oc create -f nodejs-header-echo/openshift/dc.json
        oc create -f nodejs-header-echo/openshift/secure-service.json
        oc create -f nodejs-header-echo/openshift/insecure-service.json

        #  Add a route that allows http and https.
        oc create -f nodejs-header-echo/openshift/edge-secured-allow-http-route.json

        # check the routes.
        oc get routes


6.  Wait a bit for the service to become available.

        curl -vvv -H "Host: ig-allow-http.header.test" http://127.0.0.1/


7.  Run the prometheus server that will scrape the haproxy metrics.
    Note: we use port 9999 as some environments have cockpit running on
    port 9090 on the host.

        make run  ||  echo "see alternative instructions below ..."

        echo "Alternatively, you can just start the docker container."
        docker run -p 0.0.0.0:9999:9090 -dit ramr/openshift-prometheus-test


8.  View the haproxy statistics in the prometheus display at:

        http://<node-ipaddr>:9999/consoles/haproxy.html


9.  Generate some demo load and you will see the haproxy stats within
    prometheus.

        ab -c 5 -t 30 -H "Host: ig-allow-http.header.test" http://127.0.0.1/


