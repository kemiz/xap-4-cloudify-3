/*******************************************************************************
 * Copyright (c) 2013 GigaSpaces Technologies Ltd. All rights reserved
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/


import groovy.json.JsonSlurper
import groovy.text.SimpleTemplateEngine
import org.openspaces.admin.AdminFactory
import org.openspaces.admin.pu.config.ProcessingUnitConfig

import java.util.concurrent.TimeUnit

def spacename = System.getProperty("spacename")
def gwname = System.getProperty("gwname")
def targets = System.getProperty("targets")
def locators = System.getProperty("locallocators")
def zones = System.getProperty("zones")

assert (spacename != null), "space name must not be null"
assert (gwname != null), "no gwname"
assert (targets != null), "no targets"

//CREATE PU
pudir = "/tmp/spacepu/META-INF/spring"
new AntBuilder().sequential() {
    delete(dir: pudir)
    mkdir(dir: pudir)
}

def slurper = new JsonSlurper()

def binding = [:]
binding['spacename'] = spacename
binding['gwname'] = gwname
println "AA"
binding['targets'] = slurper.parseText(targets)

def engine = new SimpleTemplateEngine()
def putemplate = new File('/tmp/space-pu.xml')
def template = engine.createTemplate(putemplate).make(binding)
new File("${pudir}/pu.xml").withWriter { out ->
    out.write(template.toString())
}

println "Setting Admin..."
def admin = new AdminFactory().useDaemonThreads(true).addLocators(locators).createAdmin();
def gsm = admin.gridServiceManagers.waitForAtLeastOne(1, TimeUnit.MINUTES)
assert gsm != null

def pucfg = new ProcessingUnitConfig()
if (zones != null && !zones.equals("")) {
    pucfg.setZones(zones.split(","))
}
pucfg.setClusterSchema("partitioned-sync2backup")
pucfg.setNumberOfInstances(1)
pucfg.setNumberOfBackups(1)

pucfg.setProcessingUnit("/tmp/spacepu")
pucfg.setName(spacename)

println "Deploying space..."
def pu = gsm.deploy(pucfg, 1, TimeUnit.MINUTES)

admin.close()
assert pu != null, "timed out waiting for space deployment"