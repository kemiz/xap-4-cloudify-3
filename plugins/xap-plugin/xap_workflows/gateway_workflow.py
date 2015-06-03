########
# Copyright (c) 2015 GigaSpaces Technologies Ltd. All rights reserved
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

from cloudify.decorators import workflow
from cloudify.workflows import ctx


def get_ip_from_interfacename(interfacename):
    intf_ip = commands.getoutput("ip address show dev " + interfacename).split()
    intf_ip = intf_ip[intf_ip.index('inet') + 1].split('/')[0]
    return intf_ip


@workflow
def start_gateway(**kwargs):
    graph = ctx.graph_mode()
    management_instance = None
    gateway_instance = None
    for node in ctx.nodes:
        if "xap_management" == node.id:
            for i in node.instances:
                management_instance = i
                break
        if "xap_gateway" == node.id:
            for i in node.instances:
                gateway_instance = i
                break
        if management_instance is not None and gateway_instance is not None:
            break

    sequence = graph.sequence()
    ctx.logger.info("executing instance {}".format(management_instance))

    lookups = kwargs['gateway_lookups']

    sequence.add(
        management_instance.send_event('Deploying space'),
        management_instance.execute_operation("admin.commands.deploy_gateway_space",
                                              kwargs={'space_name': kwargs['space_name'],
                                                      'space_zones': kwargs['space_zones'],
                                                      'gateway_name': kwargs['gateway_name'],
                                                      'gateway_targets': kwargs['gateway_targets']}),
        gateway_instance.send_event('Deploying gateway'),
        gateway_instance.execute_operation("admin.commands.deploy_gateway_pu",
                                              kwargs={'space_name': kwargs['space_name'],
                                                      'gateway_zones': kwargs['gateway_pu_zones'],
                                                      'gateway_name': kwargs['gateway_name'],
                                                      'gateway_discoport': kwargs['gateway_discoport'],
                                                      'gateway_commport': kwargs['gateway_commport'],
                                                      'gateway_targets': kwargs['gateway_targets'],
                                                      'gateway_sources': kwargs['gateway_sources'],
                                                      'gateway_lookups': lookups,
                                                      'gateway_natmappings': kwargs['gateway_natmappings']}),
        management_instance.send_event('Deploying rest service'),
        management_instance.execute_operation("admin.commands.deploy_rest",
                                              kwargs={'space_name': kwargs['space_name'],
                                                      'rest_zones': kwargs['rest_zones'],
                                                      'rest_port': kwargs['rest_port']}),
        management_instance.send_event('Done running workflow')

    )

    graph.execute()