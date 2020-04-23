###############################
Data Pipelines - Infrastructure
###############################

Infrastructure component of a Data Workflow Management system using these components:

- `Airflow <https://airflow.apache.org/docs/1.10.10/>`_ | version 1.10.10

*************
Prerequisties
*************

- `Docker <https://docs.docker.com/install/>`_
- `GNU make <https://www.gnu.org/software/make/manual/make.html>`_

***************
Getting Started
***************

Get the code and change into the top level ``git`` project directory::

    $ git clone https://github.com/loum/data-pipelines-infrastructure.git && cd data-pipelines-infrastructure

.. note::

    Run all commands from the top-level directory of the ``git`` repository.

For first-time setup, get the `Makester project <https://github.com/loum/makester.git>`_::

    $ git submodule update --init

Keep `Makester project <https://github.com/loum/makester.git>`_ up-to-date with::

    $ make submodule-update

Setup the environment::

    $ make init

******************************
Infrastructure Build and Setup
******************************

Start Infrastructure Components
===============================

To build a Dockerised Airflow instance running under `Celery Executor mode <https://airflow.apache.org/docs/1.10.10/executor/celery.html?highlight=celery%20executor>`_::

    $ make local-build-up

Naviagate to the `Airflow Console <http://localhost:8080/>`_

Destroy Infrastructure Components
=================================

To release all Docker resources::

    $ make local-build-down

*********
Image Tag
*********

To tag the image as ``latest``::

    $ make tag

Or to align with tagging policy ``<airflow-version>-<data-pipeline-dags-tag>-<image-release-number>``::

    $ make tag-version

.. note::

    Control version values by setting ``MAKESTER__VERSION`` and ``MAKESTER__RELEASE_NUMBER`` in the project `Makefile <https://github.com/loum/data-pipelines-infrastructure/blob/master/Makefile>`_.

**********************
Kubernetes Integration
**********************

Kubernetes shakeout and troubleshooting.

Prerequisites
=============

- `Minikube <https://kubernetes.io/docs/tasks/tools/install-minikube/>`_
- `kubectll <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_
- `kompose <https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/#install-kompose>`_ if you would like to convert `docker-compose.yml` files to Kubernetes manifests

(Optional) Convert existing ``docker-compose.yml`` to Kubernetes Manifests
--------------------------------------------------------------------------

Kubernetes provides the `kompose <https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes>`__ conversion tool that can help you migrate to Kubernetes from ``docker-compose``.  Ensure that your ``docker-compose.yml`` file exists in the top-level directory of your project repository.

To create your Kubernetes manifests::

    $ make k8s-manifests

This will deposit the generated Kubernetes manifests under the ``./k8s`` directory.

Create A Local Kubernetes Cluster (Minikube) and Create Resources
-----------------------------------------------------------------

Create a Pod and requires Services taken from manifests under ``./k8s`` directory::

    $ make kube-apply

Interact with Kubernetes Resources
----------------------------------

View the Pods and Services::

    $ make kube-get

Delete the Pods and Services::

    $ make kube-del

Bring up the Airflow Webserver UI
---------------------------------

The Kubernetes deployment will expose the Airflow Webserver UI that can be browsed to.  The URL can be obtained with::

    $ minikube service webserver --url

Cleanup Kubernetes
------------------

::

    $ make mk-del
