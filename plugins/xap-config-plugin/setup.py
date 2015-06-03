__author__ = 'dfilppi'
from setuptools import setup

PLUGINS_COMMON_VERSION = "3.0"
PLUGINS_COMMON_BRANCH = "develop"
PLUGINS_COMMON = "https://github.com/cloudify-cosmo/cloudify-plugins-common/tarball/{0}".format(PLUGINS_COMMON_BRANCH)

setup(
    zip_safe=True,
    name='xap-config-plugin',
    version='0.1.0',
    author='dfilppi',
    author_email='dfilppi@gigaspaces.com',
    packages=[
        'xap_config_plugin'
    ],
    license='APACHE 2.0',
    description='Sample plugin for configuring xap locators.',
    install_requires=[
        "cloudify-plugins-common"
    ],
    dependency_links=["{0}#egg=cloudify-plugins-common-{1}".format(PLUGINS_COMMON, PLUGINS_COMMON_VERSION)] 
)
