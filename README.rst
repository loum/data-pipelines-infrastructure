###############################
Data Pipelines - Infrastructure
###############################

Infrastructure component of a Data Workflow Management system using these components:

- `Airflow <https://airflow.apache.org/docs/1.10.10/>`_ | version 1.10.10

This repository manages the customised Docker image build of Airflow.  The new Docker image is based on `Docker Hub apache/airflow <https://hub.docker.com/r/apache/airflow>`_.  Customised Airflow DAGs and Plugins are built into the image and must be installable as a Python ``pip`` package.  This provides an immutable deploy bound within the Docker container during run time.  The dependent DAG ``pip`` install defaults to a `simple Airflow DAG bookend example <https://github.com/loum/data-pipelines-dags>`_.

.. note::

    The dependent DAG ``pip`` install can be overriden to suit your project's requirements as detailed under `Image Build`_.

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

************
Getting Help
************

There should be a ``make`` target to be able to get most things done.  Check the help for more information::

    $ make help

***********
Image Build
***********

The image build process takes the `Docker Hub apache/airflow <https://hub.docker.com/r/apache/airflow>`_ image and installs a Python package of custom Airflow DAGs and Plugin definitions via the normal Python package management process using ``pip``.  The upstream dependency for the Airflow image build is defined by the ``DATA_PIPELINES_DAG_REPO`` variable in the ``Makefile``.  This defaults to ``git+https://github.com/loum/data-pipelines-dags.git@0.0.0`` which is a simple DAG for the purposes of satisfying the requirement of our new Docker image build.  To start the default ``data-pipelines-infrastructure`` Docker image build::

    $ make build-image

To list the available ``data-pipelines-infrastructure`` Docker images::

    $ make search-image

On the successful build of the Docker image, the typical output would be::

    REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
    data-pipelines-infrastructure   eda36a5             0671ab41ad37        19 hours ago        766MB

Here, the ``TAG`` is important as it identifies the local ``data-pipelines-infrastructure`` build and is used directly in the `Infrastructure Build and Setup`_.

******************************
Infrastructure Build and Setup
******************************

Start Infrastructure Components
===============================

.. note::

    Triggering the ``local-build-up`` target forces a ``make build-image`` to ensure a ``data-pipelines-infrastructure`` Docker image exists locally.

To build a Dockerised Airflow platform running under `Celery Executor mode <https://airflow.apache.org/docs/1.10.10/executor/celery.html?highlight=celery%20executor>`_::

    $ make local-build-up

Navigate to the Airflow console `<http://localhost:\<AIRFLOW__WEBSERVER__WEB_SERVER_PORT\>>`_

.. note::

   The ``AIRFLOW__WEBSERVER__WEB_SERVER_PORT`` value can be identified with::

      make print-AIRFLOW__WEBSERVER__WEB_SERVER_PORT

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
