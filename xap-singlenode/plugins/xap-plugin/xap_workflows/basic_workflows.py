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
__author__ = 'yohana'

from cloudify.decorators import workflow
from cloudify.workflows import ctx
from cloudify.workflows import parameters as p


@workflow
def deploy_grid(**kwargs):
    instance = None
    for node in ctx.nodes:
        if "xap_management" == node.id:
            for i in node.instances:
                instance = i
                break
            break

    ctx.logger.info("executing instance {}".format(instance))

    instance.execute_operation("admin.commands.deploy_grid",
                               kwargs={'grid_name': p.grid_name, 'schema': p.schema, 'partitions': p.partitions,
                                       'backups': p.backups, 'max_per_vm': p.max_per_vm,
                                       'max_per_machine': p.max_per_machine})


@workflow
def deploy_pu(**kwargs):
    instance = None
    for node in ctx.nodes:
        if "xap_management" == node.id:
            for i in node.instances:
                instance = i
                break
            break

    ctx.logger.info("executing instance {}".format(instance))

    instance.execute_operation("admin.commands.deploy_pu",
                               kwargs={'pu_url': p.pu_url, 'override_pu_name': p.override_pu_name, 'schema': p.schema,
                                       'partitions': p.partitions, 'backups': p.backups, 'max_per_vm': p.max_per_vm,
                                       'max_per_machine': p.max_per_machine})


@workflow
def undeploy_grid(**kwargs):
    instance = None
    for node in ctx.nodes:
        if "xap_management" == node.id:
            for i in node.instances:
                instance = i
                break
            break

    ctx.logger.info("executing instance {}".format(instance))

    instance.execute_operation("admin.commands.undeploy_grid", kwargs={'grid_name': p.grid_name})


