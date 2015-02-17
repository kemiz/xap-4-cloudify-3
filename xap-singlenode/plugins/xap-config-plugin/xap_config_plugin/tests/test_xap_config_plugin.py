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

__author__ = 'dewayne'

from xap_config_plugin.tasks import get_locator
from collections import namedtuple
import unittest
import os
import os.path

from cloudify.mocks import MockCloudifyContext

#MockCloudifyContext = namedtuple('MockCloudifyContext', ['node_id', 'related'])
Related = namedtuple('Related', ['properties','runtime_properties'])

class XapConfigPluginTests(unittest.TestCase):

    def test_get_locator(self):

        ctx = MockCloudifyContext(
            node_id='id',
            related=Related(
                runtime_properties={'ip_address' : 'localhost', 'port' : '28017'},
                properties={'lus_port' : 2222}
            )
        )

        get_locator(ctx)

        self.assertTrue(os.path.isfile('/tmp/locators'))

        with open("/tmp/locators") as env_file:
            env_file_lines = env_file.readlines()
            for line in env_file_lines:
                self.assertTrue(line.startswith("localhost"))

        os.remove('/tmp/locators')

