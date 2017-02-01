  export interface RunInstancesRequest {
    /**
     * Checks whether you have the required permissions for the action, without actually making the request, and provides an error response. If you have the required permissions, the error response is DryRunOperation. Otherwise, it is UnauthorizedOperation.
     */
    DryRun?: Boolean;
    /**
     * The ID of the AMI, which you can get by calling DescribeImages.
     */
    ImageId: String;
    /**
     * The minimum number of instances to launch. If you specify a minimum that is more instances than Amazon EC2 can launch in the target Availability Zone, Amazon EC2 launches no instances. Constraints: Between 1 and the maximum number you're allowed for the specified instance type. For more information about the default limits, and how to request an increase, see How many instances can I run in Amazon EC2 in the Amazon EC2 General FAQ.
     */
    MinCount: Integer;
    /**
     * The maximum number of instances to launch. If you specify more instances than Amazon EC2 can launch in the target Availability Zone, Amazon EC2 launches the largest possible number of instances above MinCount. Constraints: Between 1 and the maximum number you're allowed for the specified instance type. For more information about the default limits, and how to request an increase, see How many instances can I run in Amazon EC2 in the Amazon EC2 FAQ.
     */
    MaxCount: Integer;
    /**
     * The name of the key pair. You can create a key pair using CreateKeyPair or ImportKeyPair.  If you do not specify a key pair, you can't connect to the instance unless you choose an AMI that is configured to allow users another way to log in. 
     */
    KeyName?: String;
    /**
     * [EC2-Classic, default VPC] One or more security group names. For a nondefault VPC, you must use security group IDs instead. Default: Amazon EC2 uses the default security group.
     */
    SecurityGroups?: SecurityGroupStringList;
    /**
     * One or more security group IDs. You can create a security group using CreateSecurityGroup. Default: Amazon EC2 uses the default security group.
     */
    SecurityGroupIds?: SecurityGroupIdStringList;
    /**
     * The user data to make available to the instance. For more information, see Running Commands on Your Linux Instance at Launch (Linux) and Adding User Data (Windows). If you are using an AWS SDK or command line tool, Base64-encoding is performed for you, and you can load the text from a file. Otherwise, you must provide Base64-encoded text.
     */
    UserData?: String;
    /**
     * The instance type. For more information, see Instance Types in the Amazon Elastic Compute Cloud User Guide. Default: m1.small 
     */
    InstanceType?: InstanceType;
    /**
     * The placement for the instance.
     */
    Placement?: Placement;
    /**
     * The ID of the kernel.  We recommend that you use PV-GRUB instead of kernels and RAM disks. For more information, see  PV-GRUB in the Amazon Elastic Compute Cloud User Guide. 
     */
    KernelId?: String;
    /**
     * The ID of the RAM disk.  We recommend that you use PV-GRUB instead of kernels and RAM disks. For more information, see  PV-GRUB in the Amazon Elastic Compute Cloud User Guide. 
     */
    RamdiskId?: String;
    /**
     * The block device mapping.  Supplying both a snapshot ID and an encryption value as arguments for block-device mapping results in an error. This is because only blank volumes can be encrypted on start, and these are not created from a snapshot. If a snapshot is the basis for the volume, it contains data by definition and its encryption status cannot be changed using this action. 
     */
    BlockDeviceMappings?: BlockDeviceMappingRequestList;
    /**
     * The monitoring for the instance.
     */
    Monitoring?: RunInstancesMonitoringEnabled;
    /**
     * [EC2-VPC] The ID of the subnet to launch the instance into.
     */
    SubnetId?: String;
    /**
     * If you set this parameter to true, you can't terminate the instance using the Amazon EC2 console, CLI, or API; otherwise, you can. To change this attribute to false after launch, use ModifyInstanceAttribute. Alternatively, if you set InstanceInitiatedShutdownBehavior to terminate, you can terminate the instance by running the shutdown command from the instance. Default: false 
     */
    DisableApiTermination?: Boolean;
    /**
     * Indicates whether an instance stops or terminates when you initiate shutdown from the instance (using the operating system command for system shutdown). Default: stop 
     */
    InstanceInitiatedShutdownBehavior?: ShutdownBehavior;
    /**
     * [EC2-VPC] The primary IPv4 address. You must specify a value from the IPv4 address range of the subnet. Only one private IP address can be designated as primary. You can't specify this option if you've specified the option to designate a private IP address as the primary IP address in a network interface specification. You cannot specify this option if you're launching more than one instance in the request.
     */
    PrivateIpAddress?: String;
    /**
     * [EC2-VPC] Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface. You cannot specify this option and the option to assign a number of IPv6 addresses in the same request. You cannot specify this option if you've specified a minimum number of instances to launch.
     */
    Ipv6Addresses?: InstanceIpv6AddressList;
    /**
     * [EC2-VPC] A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet. You cannot specify this option and the option to assign specific IPv6 addresses in the same request. You can specify this option if you've specified a minimum number of instances to launch.
     */
    Ipv6AddressCount?: Integer;
    /**
     * Unique, case-sensitive identifier you provide to ensure the idempotency of the request. For more information, see Ensuring Idempotency. Constraints: Maximum 64 ASCII characters
     */
    ClientToken?: String;
    /**
     * Reserved.
     */
    AdditionalInfo?: String;
    /**
     * One or more network interfaces.
     */
    NetworkInterfaces?: InstanceNetworkInterfaceSpecificationList;
    /**
     * The IAM instance profile.
     */
    IamInstanceProfile?: IamInstanceProfileSpecification;
    /**
     * Indicates whether the instance is optimized for EBS I/O. This optimization provides dedicated throughput to Amazon EBS and an optimized configuration stack to provide optimal EBS I/O performance. This optimization isn't available with all instance types. Additional usage charges apply when using an EBS-optimized instance. Default: false 
     */
    EbsOptimized?: Boolean;
  }
