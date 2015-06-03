########
# Copyright (c) 2014 GigaSpaces Technologies Ltd. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and

# * limitations under the License.
import commands
from cloudify.decorators import operation
import subprocess
import urllib
import os


def get_ip_from_interface_name(interface_name):
    intf_ip = commands.getoutput("ip address show dev " + interface_name).split()
    intf_ip = intf_ip[intf_ip.index('inet') + 1].split('/')[0]
    return intf_ip

@operation
def deploy_grid(ctx, **kwargs):
    grid_name = kwargs["grid_name"]
    schema = kwargs["schema"]
    partitions = str(kwargs["partitions"])
    backups = str(kwargs["backups"])
    max_per_vm = str(kwargs["max_per_vm"])
    max_per_machine = str(kwargs["max_per_machine"])

    xapdir = "".join([line.strip() for line in open('/tmp/gsdir')])

    ip = get_ip_from_interface_name(ctx.node.properties['interfacename'])
    deployment_command = [
        xapdir + "/bin/gs.sh",
        "deploy-space",
        "-cluster",
        "schema="+schema+" total_members="+partitions+","+backups,
        "-max-instances-per-vm "+max_per_vm,
        "-max-instances-per-machine "+max_per_machine,
        grid_name
    ]

    my_env = os.environ.copy()
    locators = ",".join([line.strip() for line in open('/tmp/locators')])
    my_env['LOOKUPLOCATORS'] = locators
    my_env['NIC_ADDR'] = ip
    ctx.logger.info("Executing: %s", deployment_command)
    output = subprocess.check_output(deployment_command, env=my_env)
    ctx.logger.info("Finished executing, output: %s", output)


@operation
def undeploy_grid(ctx, **kwargs):
    grid_name = kwargs["grid_name"]

    xapdir = "".join([line.strip() for line in open('/tmp/gsdir')])

    ip = get_ip_from_interface_name(ctx.node.properties['interfacename'])
    deployment_command = [
        xapdir + "/bin/gs.sh",
        "undeploy",
        grid_name
    ]

    my_env = os.environ.copy()
    locators = ",".join([line.strip() for line in open('/tmp/locators')])
    my_env['LOOKUPLOCATORS'] = locators
    my_env['NIC_ADDR'] = ip
    ctx.logger.info("Executing: %s", deployment_command)
    output = subprocess.check_output(deployment_command, env=my_env)
    ctx.logger.info("Finished executing, output: %s", output)


@operation
def deploy_pu(ctx, **kwargs):
    override_pu_name = kwargs["override_pu_name"]
    schema = kwargs["schema"]
    partitions = str(kwargs["partitions"])
    backups = str(kwargs["backups"])
    max_per_vm = str(kwargs["max_per_vm"])
    max_per_machine = str(kwargs["max_per_machine"])

    xapdir = "".join([line.strip() for line in open('/tmp/gsdir')])

    ip = get_ip_from_interface_name(ctx.node.properties['interfacename'])

    tmp_pus = '/tmp/pus'
    if not os.path.exists(tmp_pus):
        os.makedirs(tmp_pus)
    jar_name = kwargs["pu_url"].split("/")[-1]

    pu_location = tmp_pus + '/' + jar_name
    urllib.urlretrieve(kwargs["pu_url"], pu_location)
    if override_pu_name != {}:
        pu_name = override_pu_name
    else:
        pu_name = jar_name.split(".jar")[0]

    deployment_command = [
        xapdir + "/bin/gs.sh",
        "deploy",
        "-cluster",
        "schema="+schema+" total_members="+partitions+","+backups,
        "-max-instances-per-vm "+max_per_vm,
        "-max-instances-per-machine "+max_per_machine,
        "-override-name "+pu_name,
        pu_location
    ]

    my_env = os.environ.copy()
    locators = ",".join([line.strip() for line in open('/tmp/locators')])
    my_env['LOOKUPLOCATORS'] = locators
    my_env['NIC_ADDR'] = ip
    ctx.logger.info("Executing: %s", deployment_command)
    output = subprocess.check_output(deployment_command, env=my_env)
    ctx.logger.info("Finished executing, output: %s", output)

