import json
from cloudify.decorators import operation
from cloudify import ctx
import subprocess
import os
import commands


def get_ip_from_interface_name(interface_name):
    intf_ip = commands.getoutput("ip address show dev " + interface_name).split()
    intf_ip = intf_ip[intf_ip.index('inet') + 1].split('/')[0]
    return intf_ip


def list_to_str(lst):
    return str(json.dumps(lst))


@operation
def deploy_gateway_space(**kwargs):
    script = "xap-scripts/deploy-space-with-gateway.groovy"
    spacename = kwargs['space_name']
    spacezones = kwargs['space_zones']
    gwname = kwargs['gateway_name']
    targets = kwargs['gateway_targets']
    script_path = ctx.download_resource(script)
    ctx.download_resource("xap-scripts/space-pu.xml", "/tmp/space-pu.xml")
    xapdir = "".join([line.strip() for line in open('/tmp/gsdir')])
    locators = ",".join([line.strip() for line in open('/tmp/locators')])

    ip = get_ip_from_interface_name(ctx.node.properties['interfacename'])
    space_deployment_command = [
        xapdir + "/tools/groovy/bin/groovy",
        "-Dspacename=" + spacename,
        "-Dzones=" + spacezones,
        "-Dtargets=" + list_to_str(targets),
        "-Dgwname=" + gwname,
        "-Dlocallocators=" + locators,
        "-Djava.rmi.server.hostname=" + ip,
        script_path
    ]
    my_env = os.environ.copy()
    my_env['LOOKUPLOCATORS'] = locators

    my_env['NIC_ADDR'] = ip
    ctx.logger.info("Executing: %s", space_deployment_command)
    output = subprocess.check_output(space_deployment_command)
    ctx.logger.info("Finished executing, output: %s", output)


@operation
def deploy_gateway_pu(**kwargs):
    script = "xap-scripts/deploy-gateway.groovy"
    puname = kwargs['space_name'] + "-gw"
    spacename = kwargs['space_name']
    gwname = kwargs['gateway_name']
    gatewayzones = kwargs['gateway_zones']
    targets = kwargs['gateway_targets']
    sources = kwargs['gateway_sources']
    lookups = kwargs['gateway_lookups']
    natmappings = kwargs['gateway_natmappings']
    script_path = ctx.download_resource(script)
    ctx.download_resource("xap-scripts/gateway-pu.xml", "/tmp/gateway-pu.xml")
    xapdir = "".join([line.strip() for line in open('/tmp/gsdir')])
    locators = ",".join([line.strip() for line in open('/tmp/locators')])

    ip = get_ip_from_interface_name(ctx.node.properties['interfacename'])
    mylocators = {'gwname': gwname, 'address': ip, 'discoport': kwargs['gateway_discoport'],
                  'commport': kwargs['gateway_commport']}
    lookups.append(mylocators)

    gateway_deployment_command = [
        xapdir + "/tools/groovy/bin/groovy",
        "-Dpuname=" + puname,
        "-Dspacename=" + spacename,
        "-Dzones=" + gatewayzones,
        "-Dtargets=" + list_to_str(targets),
        "-Dgwname=" + gwname,
        "-Dlocallocators=" + locators,
        "-Dlocalgwname=" + gwname,
        "-Dsources=" + list_to_str(sources),
        "-Dlookups=" + list_to_str(lookups),
        "-Dnatmappings=" + natmappings,
        "-Djava.rmi.server.hostname=" + ip,
        script_path
    ]

    my_env = os.environ.copy()
    my_env['LOOKUPLOCATORS'] = locators
    my_env['NIC_ADDR'] = ip
    ctx.logger.info("Executing: %s", gateway_deployment_command)
    output = subprocess.check_output(gateway_deployment_command, env=my_env)
    ctx.logger.info("Finished executing, output: %s", output)


@operation
def deploy_rest(**kwargs):
    spacename = kwargs['space_name']
    port = kwargs['rest_port']
    zones = kwargs['rest_zones']
    xapdir = "".join([line.strip() for line in open('/tmp/gsdir')])

    ip = get_ip_from_interface_name(ctx.node.properties['interfacename'])
    rest_deployment_command = [
        xapdir + "/bin/gs.sh",
        "deploy-rest",
        "-spacename " + spacename,
        "-port " + str(port)
    ]
    if len(zones) > 0:
        rest_deployment_command.append("-zones " + zones)

    my_env = os.environ.copy()
    locators = ",".join([line.strip() for line in open('/tmp/locators')])
    my_env['LOOKUPLOCATORS'] = locators
    my_env['NIC_ADDR'] = ip
    ctx.logger.info("Executing: %s", rest_deployment_command)
    output = subprocess.check_output(rest_deployment_command, env=my_env)
    ctx.logger.info("Finished executing, output: %s", output)
