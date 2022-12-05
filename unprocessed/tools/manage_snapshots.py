#!/usr/bin/env python
from __future__ import print_function
import atexit
import requests
import time
from datetime import datetime
from pyVim.connect import SmartConnect, Disconnect
from tools import cli
import requests
requests.packages.urllib3.disable_warnings()
import ssl
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context


def setup_args():
    parser = cli.build_arg_parser()
    parser.add_argument('command', help="Can be 'create', 'remove', or 'list'" )
    parser.add_argument('-v', '--name', required=False,
                        help="dns name of the vm to get snapshotted")
    parser.add_argument('-l', '--vmlist', required=False,
                        help="list of DNS names for many VMs to be snapshotted")
    parser.add_argument('-i', '--instance', required=False,
                        action='store_true',
                        help="Flag to indicate the UUID is an instance UUID")
    parser.add_argument('-d', '--description', required=False,
                        help="Description for the snapshot")
    parser.add_argument('-n', '--snapshotname', required=False,
                        help="Name for the Snapshot")

    my_args = parser.parse_args()
    return cli.prompt_for_password(my_args)

args = setup_args()

si = None
try:
    si = SmartConnect(host=args.host,
                      user=args.user,
                      pwd=args.password,
                      port=int(args.port))
    atexit.register(Disconnect, si)
except IOError:
    raise SystemExit("Unable to connect to host with supplied info.")

desc = None
if args.description:
    desc = args.description
elif args.description is None:
    t = datetime.now()
    snapshot_date = t.strftime('%m/%d/%Y %I:%M%p')
    desc = "Created by " + args.user + " on " + snapshot_date


class CreateSnapshot:
    def __init__(self, item):
        try:
            vm = si.content.searchIndex.FindByDnsName(None, item, True)
            vm.CreateSnapshot_Task(name=args.snapshotname,
                                        description=desc,
                                        memory=False,
                                        quiesce=True)
            print("Snapshot Completed.")
        except:
            print("Unable to locate VirtualMachine")


class RemoveSnapshots:
    def __init__(self, item):
        try:
            vm = si.content.searchIndex.FindByDnsName(None, item, True)
            vm.RemoveAllSnapshots_Task()
            print("All Snapshots Removed.")
        except:
            print("Unable to locate VirtualMachine.")


class ListSnapshots:
    def __init__(self, item):
        try:
            vm = si.content.searchIndex.FindByDnsName(None, item, True)
            snap_info = vm.snapshot
            tree = snap_info.rootSnapshotList
            while tree[0].childSnapshotList is not None:
                print("Snap: {0} => {1}".format(tree[0].name, tree[0].description))
                if len(tree[0].childSnapshotList) < 1:
                    break
                tree = tree[0].childSnapshotList
        except:
            print("Unable to locate VirtualMachine")


if args.command == 'create':
    if args.name:
        CreateSnapshot(args.name)
    elif args.vmlist:
        with open(args.vmlist) as infile:
            read_data = infile.read().splitlines()
            for server in read_data:
                print(server)
                CreateSnapshot(server)
            infile.close()
elif args.command == 'remove':
    if args.name:
        RemoveSnapshots(args.name)
    elif args.vmlist:
        with open(args.vmlist) as infile:
            read_data = infile.read().splitlines()
            for server in read_data:
                print(server)
                RemoveSnapshots(server)
            infile.close()
elif args.command == 'list':
    print("Listing snapshots:")
    if args.name:
        ListSnapshots(args.name)
    elif args.vmlist:
        del infile
        with open(args.vmlist) as infile:
            read_data = infile.read().splitlines()
            for server in read_data:
                print(server)
                ListSnapshots(server)
            infile.close()
else:
    raise SystemExit("Invalid command options. Valid options are 'create', 'remove', and 'list'.")

Disconnect(si)
