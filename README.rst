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
