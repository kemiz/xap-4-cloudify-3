import org.openspaces.admin.AdminFactory
import org.openspaces.admin.gsa.GridServiceContainerOptions
import java.net.NetworkInterface
import java.util.concurrent.TimeUnit

if (args.length != 3) {
	System.err.println("Should provide arguments in the following order: interfacename gsc_count GSC_JAVA_OPTIONS. Found: "+args);
	System.exit(1);
}

interfacename=args[0]
int gsc_cnt;
try {
	gsc_cnt = Integer.valueOf(args[1])
} catch (NumberFormatException e) {
	System.err.println("gsc_count must be number")
	System.exit(1);
}
vmargs=args[2].trim().split(" ")

e=NetworkInterface.getByName(interfacename).getInetAddresses()
ip=null
while(e.hasMoreElements()){
	addr=e.nextElement()
	if (addr instanceof java.net.Inet4Address)ip=addr.hostAddress
}

if (ip==null) throw new RuntimeException("no ip found")

admin=new AdminFactory().addLocator(ip).useDaemonThreads(true).create()

admin.gridServiceAgents.waitForAtLeastOne()

agt=admin.gridServiceAgents.agents[0]

println "Starting " +gsc_cnt +" GSCs"
for (int i=0; i<gsc_cnt ;i++) {
opts=new GridServiceContainerOptions()
if(vmargs!=null){
	vmargs.each{
		println it
		opts.vmInputArgument(it)
	}
}
gsc = agt.startGridServiceAndWait(opts, 1, TimeUnit.MINUTES);
	assert (gsc != null), "Failed to start GSC within 1 minute"
}

println "Finished starting GSCs"