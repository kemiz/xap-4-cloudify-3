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

from cloudify import ctx

 
"""
Gets the lookup locator for the related node running the lus
"""

ip_address = ctx.target.instance.runtime_properties['ip_address']
lus_port = ctx.target.node.properties['lus_port']
locator = "%s" % ip_address
if(lus_port!=0):
    locator="%s:%d" % (locator,lus_port)

ctx.logger.info("The locator is {} ".format(locator))

with open("/tmp/locators", 'a+') as env_file:
    env_file.write("{}\n".format(locator))

