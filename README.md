# isolate.dws and samples for Dyalog v17.0

Since version 14.0, Dyalog APL has included the workspace `isolate.dws`, which enables simple asynchronous and parallel programming in Dyalog APL. From version 17.0, the source for the isolate workspace and associated samples have been moved to GitHub.

## Documentation

Documentation for the futures and isolates can be found in the [Dyalog Documentation Centre](http://docs.dyalog.com/16.0/Parallel%20Language%20Features.pdf).

## Version 17.0 Enhancements

A project was started at Dyalog with the goal of enhancing the isolate workspace so that it would be possible to run *isolate servers* in the cloud. In the end, it turned out that a couple of bugfixes in the code which validated peer IP addresses to deal with IPv6 addresses was all that was really required.

We also added a "sample" called `AWS`, which provides an interface to the Amazon Webservices Command Line Interface. This can be used to launch and manage AWS instances. [Dyalog Webinar 10](https://dyalog.tv/Webinar/?v=bpP99KEfUxI) demonstrates how to use this to run a large number of parallel isolates on the cloud.

## Samples

In addition to the workspace which can be found in the `ws` folder along with most other distributed workspaces, a new folder of isolate-related samples are now installed in the folder `Samples/isolate` below the main Dyalog folder.

It contains the AWS class and an example of how to use it, and also includes the `IIPageStats` sample, which computes letter frequencies used on all major newspaper sites in a given state in the USA, as an example of how to use the `ll.EachX` (extended parallel each) tool:

### Contents of the Samples folder

|File|Type|Description|
|----|----|-----------|
|AWS.dyalog|Class|Interface to the Amazon Webservices Command Line Interface|
|AWSIsolates.dyalog|Function|Shows how to use the AWS class to start a set of virtual machines and use them to run Isolates|
|IIPageStats.dyalog|Namespace|Demonstrates the use of `ll.EachX` tool|


