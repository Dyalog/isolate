# isolate.dws and samples for Dyalog v17.0

Since version 14.0, Dyalog APL has included the workspace `isolate.dws`, which enables simple asynchronous and parallel programming in Dyalog APL. From version 17.0, the source for the isolate workspace and associated samples have been moved to GitHub.

## Documentation

Documentation for the futures and isolates can be found in the [Dyalog Documentation Centre](http://docs.dyalog.com/16.0/Parallel%20Language%20Features.pdf).

## Samples

In addition to the workspace which can be found in the `ws` folder along with most other distributed workspaces, a new folder of isolate-related samples are now installed in the folder `Samples/isolate` below the main Dyalog folder:

|File|Type|Description|
|----|----|-----------|
|AWS.dyalog|Class|The AWS class provides an interface to the Amazon Webservices Command Line Interface, which can be used to launch and manage AWS instances.|
|AWSIsolates.dyalog|Function|This example shows how to use the AWS class to start a set of virtual machines and use them to run Isolates. This is the code used in [Dyalog Webinar 10](https://dyalog.tv/Webinar/?v=bpP99KEfUxI)|
|IIPageStats.dyalog|Namespace|Demonstration of the `ll.EachX` utility function which reuses a set of isolates to perform a large number of parallel function calls|


