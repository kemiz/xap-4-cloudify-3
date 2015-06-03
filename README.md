xap-singlenode
==============================

### Overview

A sample Cloudify 3 blueprint simulates a 2 node Gigaspaces XAP installation. The blueprint consist of a management and container nodes.

#####Blueprint Installation

######Configuration
The most critical configuration option is the <i>license_key</i> property, which needs to be set to a valid XAP license key (look in your gs-license.xml file).   The recipe will function without it, but the grid will be limited per the "lite" license (limited memory and instances).

###Blueprint Details

#####Node #1 : xap_management_vm
The <i>xap_management_vm</i> node contains the XAP management processes: GSA, GSM, LUS, Web UI and web terminal based called butterfly.
<br/>XAP web ui url: <a href="http://localcloud:8089">http://localcloud:8089</a>.
<br/>Butterfly Url: <a href="http://localcloud:9099">http://localcloud:9099</a>.

#####Node #2 : xap_container_vm
The <i>xap_container_vm</i> node contains the XAP container process: GSC.

###### workflows

The blueprint provides several workflows:


<dl>
<dt>deploy_pu</dt>
<dd> Deploys a stateful/grid processing unit.  Usage: <i>cfy deployments execute deploy_pu -d xap -p '{"override_pu_name":"myPU"}'</i>.  Arguments (all args are required):
<ul>
<li><i>pu_url</i>: A URL where the processing unit jar can be found</li>
<li><i>override_pu_name</i>: The deployd name for the processing unit.  Defaults to the pu file name unless overridden.</li>
<li><i>schema</i>: The cluster schema (e.g. partitioned-sync2backup)</li>
<li><i>partitions</i>: The number of partitions. Ignored if not partitioned.</li>
<li><i>backups</i>: The number of backups per partition. Ignored if not partitioned.</li>
<li><i>max-per-vm</i>: Maximum instances per JVM/container.  See <a href="http://docs.gigaspaces.com/xap100adm/the-sla.html">here</a> for details</li>
<li><i>max-per-machine</i>: Maximum instances per physical machine/cloud vm.   See <a href="http://docs.gigaspaces.com/xap100adm/the-sla.html">here</a> for details</li>
</dd>
<dt>deploy_grid</dt>
<dd>Deploys a space.  Usage: <i>cfy deployments execute deploy_grid -d xap -p '{"grid_name":"myGrid"}'</i>.
<ul>
<li><i>grid_name</i>: The deployed name for the data grid.</li>
<li><i>schema</i>: The cluster schema (e.g. partitioned-sync2backup)</li>
<li><i>partitions</i>: The number of partitions. Ignored if not partitioned.</li>
<li><i>backups</i>: The number of backups per partition. Ignored if not partitioned.</li>
<li><i>max-per-vm</i>: Maximum instances per JVM/container.  See <a href="http://docs.gigaspaces.com/xap100adm/the-sla.html">here</a> for details</li>
<li><i>max-per-machine</i>: Maximum instances per physical machine/cloud vm.   See <a href="http://docs.gigaspaces.com/xap100adm/the-sla.html">here</a> for details</li>
</dd>
<dt>undeploy_grid</dt>
<dd>undeploys a space or a processing unit.  Usage: <i>cfy deployments execute undeploy_grid -d xap -p '{"grid_name":"myGrid"}'</i>.
<ul>
<li><i>grid_name</i>: The deployed name for the data grid/processing unit.</li>
</dd>
</dl>


#####XAP demo
This blueprint deploy a data grid called **myDataGrid** which enable you to use Butterfly to perform space operations.
Butterfly runs a Groovy script that prompts the user to choose:<br/>
(1) Start a demo that connects to the myDataGrid space and performs write, read, read with JDBC, read with SQLQuery on Pojos and Documents Objects. When it ends, it opens a Groovy Shell as in option (2) below.<br/>
(2) Open Groovy Interactive Shell. All XAP's classes are imported to the Groovy Shell.

